/**
 * @fileoverview Custom hooks for notifications management.
 * @module hooks/use-notifications
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { toast } from "sonner"
import { createClient, getAuthUser } from "@/lib/supabase/client"
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
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getAuthUser()
      if (!user) throw new Error("Not authenticated")

      // Build query - match only supervisor-specific notifications
      let query = supabase
        .from("notifications")
        .select("*")
        .eq("profile_id", user.id)
        .eq("target_role", "supervisor")
        .order("created_at", { ascending: false })
        .limit(limit)

      // Filter by type
      if (type) {
        if (Array.isArray(type)) {
          query = query.in("type", type)
        } else {
          query = query.eq("type", type)
        }
      }

      // Filter by read status
      if (isRead !== undefined) {
        query = query.eq("is_read", isRead)
      }

      const { data, error: queryError } = await query

      if (queryError) throw queryError

      setNotifications(data || [])

      // Get unread count
      const { count } = await supabase
        .from("notifications")
        .select("*", { count: "exact", head: true })
        .eq("profile_id", user.id)
        .eq("target_role", "supervisor")
        .eq("is_read", false)

      setUnreadCount(count || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch notifications"))
    } finally {
      setIsLoading(false)
    }
  }, [type, isRead, limit])

  const markAsRead = useCallback(async (notificationId: string) => {
    const supabase = createClient()

    const { error: updateError } = await supabase
      .from("notifications")
      .update({ is_read: true })
      .eq("id", notificationId)

    if (updateError) throw updateError

    setNotifications(prev =>
      prev.map(n => n.id === notificationId ? { ...n, is_read: true } : n)
    )
    setUnreadCount(prev => Math.max(0, prev - 1))
  }, [])

  const markAllAsRead = useCallback(async () => {
    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) return

    const { error: updateError } = await supabase
      .from("notifications")
      .update({ is_read: true })
      .eq("profile_id", user.id)
      .eq("target_role", "supervisor")
      .eq("is_read", false)

    if (updateError) throw updateError

    setNotifications(prev => prev.map(n => ({ ...n, is_read: true })))
    setUnreadCount(0)
  }, [])

  const deleteNotification = useCallback(async (notificationId: string) => {
    const supabase = createClient()

    const notification = notifications.find(n => n.id === notificationId)

    const { error: deleteError } = await supabase
      .from("notifications")
      .delete()
      .eq("id", notificationId)

    if (deleteError) throw deleteError

    setNotifications(prev => prev.filter(n => n.id !== notificationId))
    if (notification && !notification.is_read) {
      setUnreadCount(prev => Math.max(0, prev - 1))
    }
  }, [notifications])

  useEffect(() => {
    fetchNotifications()
  }, [fetchNotifications])

  // Real-time subscription for new and updated notifications
  useEffect(() => {
    const supabase = createClient()
    let channel: ReturnType<typeof supabase.channel> | null = null
    let cancelled = false

    const setupSubscription = async () => {
      const user = await getAuthUser()
      if (!user || cancelled) return

      channel = supabase
        .channel(`supervisor_notifications_${user.id}`)
        .on(
          "postgres_changes",
          {
            event: "INSERT",
            schema: "public",
            table: "notifications",
            filter: `profile_id=eq.${user.id}`,
          },
          (payload) => {
            const newNotification = payload.new as Notification & { target_role?: string }

            // Only handle supervisor-platform notifications
            if (newNotification.target_role && newNotification.target_role !== "supervisor") return

            setNotifications(prev => [newNotification, ...prev])
            setUnreadCount(prev => prev + 1)

            // Show toast for new notification
            toast(newNotification.title, {
              description: (newNotification as any).message || newNotification.body || undefined,
            })
          }
        )
        .on(
          "postgres_changes",
          {
            event: "UPDATE",
            schema: "public",
            table: "notifications",
            filter: `profile_id=eq.${user.id}`,
          },
          (payload) => {
            const updated = payload.new as Notification
            setNotifications(prev => {
              const newList = prev.map(n => n.id === updated.id ? updated : n)
              // Recalculate unread count in single pass
              setUnreadCount(newList.filter(n => !n.is_read).length)
              return newList
            })
          }
        )
        .subscribe()
    }

    setupSubscription().catch(() => {})

    return () => {
      cancelled = true
      if (channel) {
        supabase.removeChannel(channel)
      }
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
