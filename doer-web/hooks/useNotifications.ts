'use client'

import { useEffect, useState, useCallback } from 'react'
import { toast } from 'sonner'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { getSocket } from '@/lib/socket/client'

interface Notification {
  id: string
  _id?: string
  recipientId: string
  recipientRole: string
  type: string
  title: string
  message: string
  data?: Record<string, unknown>
  isRead: boolean
  is_read?: boolean
  createdAt: string
  created_at?: string
}

interface UseNotificationsReturn {
  notifications: Notification[]
  unreadCount: number
  isLoading: boolean
  markAsRead: (id: string) => Promise<void>
  markAllAsRead: () => Promise<void>
  refetch: () => Promise<void>
}

export function useNotifications(): UseNotificationsReturn {
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [unreadCount, setUnreadCount] = useState(0)
  const [isLoading, setIsLoading] = useState(true)

  const fetchNotifications = useCallback(async () => {
    try {
      setIsLoading(true)
      const data = await apiClient<{ notifications: any[]; unreadCount: number }>(
        '/api/notifications?role=doer&limit=20'
      )
      const normalized = (data.notifications || []).map((n: any) => ({
        id: n._id || n.id,
        recipientId: n.recipientId,
        recipientRole: n.recipientRole,
        type: n.type,
        title: n.title,
        message: n.message,
        data: n.data,
        isRead: n.isRead ?? n.is_read ?? false,
        createdAt: n.createdAt || n.created_at,
      }))
      setNotifications(normalized)
      setUnreadCount(data.unreadCount || normalized.filter((n: Notification) => !n.isRead).length)
    } catch {
      // Silently fail — notifications are non-critical
    } finally {
      setIsLoading(false)
    }
  }, [])

  const markAsRead = useCallback(async (id: string) => {
    await apiClient(`/api/notifications/${id}/read`, { method: 'PUT' })
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, isRead: true } : n))
    setUnreadCount(prev => Math.max(0, prev - 1))
  }, [])

  const markAllAsRead = useCallback(async () => {
    await apiClient('/api/notifications/read-all', {
      method: 'PUT',
      body: JSON.stringify({ role: 'doer' }),
    })
    setNotifications(prev => prev.map(n => ({ ...n, isRead: true })))
    setUnreadCount(0)
  }, [])

  useEffect(() => {
    fetchNotifications()
  }, [fetchNotifications])

  // Real-time via Socket.IO
  useEffect(() => {
    if (!getAccessToken()) return

    try {
      const socket = getSocket()

      const handleNew = (notification: any) => {
        if (notification.recipientRole && notification.recipientRole !== 'doer') return

        const normalized: Notification = {
          id: notification._id || notification.id,
          recipientId: notification.recipientId,
          recipientRole: notification.recipientRole,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          data: notification.data,
          isRead: false,
          createdAt: notification.createdAt || new Date().toISOString(),
        }

        setNotifications(prev => [normalized, ...prev])
        setUnreadCount(prev => prev + 1)

        toast(normalized.title, { description: normalized.message })
      }

      socket.on('notification:new', handleNew)
      return () => { socket.off('notification:new', handleNew) }
    } catch {
      return undefined
    }
  }, [])

  return {
    notifications,
    unreadCount,
    isLoading,
    markAsRead,
    markAllAsRead,
    refetch: fetchNotifications,
  }
}
