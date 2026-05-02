/**
 * @fileoverview Custom hooks for notifications management.
 * Uses Express API + Socket.IO instead of Supabase.
 * @module hooks/use-notifications
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { toast } from "sonner"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { getSocket } from "@/lib/socket/client"
import type { Notification, NotificationType } from "@/types/database"

interface UseNotificationsOptions {
  type?: NotificationType | NotificationType[]
  isRead?: boolean
  limit?: number
}

interface UseNotificationsReturn {
  notifications: Notification[]
  unreadCount: number
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
  markAsRead: (notificationId: string) => Promise<void>
  markAllAsRead: () => Promise<void>
  deleteNotification: (notificationId: string) => Promise<void>
}

export function useNotifications(options: UseNotificationsOptions = {}): UseNotificationsReturn {
  const { type, isRead, limit = 50 } = options
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [unreadCount, setUnreadCount] = useState(0)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchNotifications = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const params = new URLSearchParams()
      params.set("role", "supervisor")
      params.set("limit", String(limit))

      if (type) {
        const types = Array.isArray(type) ? type.join(",") : type
        params.set("type", types)
      }
      if (isRead !== undefined) {
        params.set("isRead", String(isRead))
      }

      const data = await apiFetch<{
        notifications: Notification[]
        unreadCount: number
      }>(`/api/notifications?${params.toString()}`)

      setNotifications(data.notifications || [])
      setUnreadCount(data.unreadCount || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch notifications"))
    } finally {
      setIsLoading(false)
    }
  }, [type, isRead, limit])

  const markAsRead = useCallback(async (notificationId: string) => {
    await apiFetch(`/api/notifications/${notificationId}/read`, {
      method: "PUT",
    })

    setNotifications(prev =>
      prev.map(n => n.id === notificationId ? { ...n, is_read: true } : n)
    )
    setUnreadCount(prev => Math.max(0, prev - 1))
  }, [])

  const markAllAsRead = useCallback(async () => {
    await apiFetch("/api/notifications/read-all", {
      method: "PUT",
      body: JSON.stringify({ role: "supervisor" }),
    })

    setNotifications(prev => prev.map(n => ({ ...n, is_read: true })))
    setUnreadCount(0)
  }, [])

  const deleteNotification = useCallback(async (notificationId: string) => {
    const notification = notifications.find(n => n.id === notificationId)

    await apiFetch(`/api/notifications/${notificationId}`, {
      method: "DELETE",
    })

    setNotifications(prev => prev.filter(n => n.id !== notificationId))
    if (notification && !notification.is_read) {
      setUnreadCount(prev => Math.max(0, prev - 1))
    }
  }, [notifications])

  useEffect(() => {
    fetchNotifications()
  }, [fetchNotifications])

  // Real-time via Socket.IO
  useEffect(() => {
    const user = getStoredUser()
    if (!user) return

    try {
      const socket = getSocket()

      const handleNew = (newNotification: Notification & { recipient_role?: string }) => {
        if (newNotification.recipient_role && newNotification.recipient_role !== "supervisor") return

        setNotifications(prev => [newNotification, ...prev])
        setUnreadCount(prev => prev + 1)

        toast(newNotification.title, {
          description: (newNotification as Notification & { message?: string }).message || newNotification.body || undefined,
        })
      }

      const handleUpdate = (updated: Notification) => {
        setNotifications(prev => {
          const newList = prev.map(n => n.id === updated.id ? updated : n)
          setUnreadCount(newList.filter(n => !n.is_read).length)
          return newList
        })
      }

      socket.on('notification:new', handleNew)
      socket.on('notification:update', handleUpdate)

      return () => {
        socket.off('notification:new', handleNew)
        socket.off('notification:update', handleUpdate)
      }
    } catch {
      return undefined
    }
  }, [])

  return {
    notifications,
    unreadCount,
    isLoading,
    error,
    refetch: fetchNotifications,
    markAsRead,
    markAllAsRead,
    deleteNotification,
  }
}

// Notification type groupings
export const NOTIFICATION_GROUPS = {
  project: [
    "project_submitted",
    "quote_ready",
    "payment_received",
    "project_assigned",
    "work_submitted",
    "qc_approved",
    "qc_rejected",
    "revision_requested",
    "project_delivered",
    "project_completed",
  ] as NotificationType[],
  chat: ["new_message"] as NotificationType[],
  payment: ["payout_processed"] as NotificationType[],
  system: ["system_alert", "promotional"] as NotificationType[],
}

export function useNotificationsByGroup() {
  const { notifications, unreadCount, isLoading, error, refetch, markAsRead, markAllAsRead } =
    useNotifications()

  const groupedNotifications = {
    project: notifications.filter(n =>
      NOTIFICATION_GROUPS.project.includes(n.notification_type as NotificationType)
    ),
    chat: notifications.filter(n =>
      NOTIFICATION_GROUPS.chat.includes(n.notification_type as NotificationType)
    ),
    payment: notifications.filter(n =>
      NOTIFICATION_GROUPS.payment.includes(n.notification_type as NotificationType)
    ),
    system: notifications.filter(n =>
      NOTIFICATION_GROUPS.system.includes(n.notification_type as NotificationType)
    ),
  }

  return {
    notifications,
    groupedNotifications,
    unreadCount,
    isLoading,
    error,
    refetch,
    markAsRead,
    markAllAsRead,
  }
}
