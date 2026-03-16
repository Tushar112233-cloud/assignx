import { apiClient } from '@/lib/api/client'
import { getSocket } from '@/lib/socket/client'
import type { Socket } from 'socket.io-client'

/**
 * Notification type
 */
interface Notification {
  id: string
  recipient_id: string
  recipient_role: string | null
  type: string | null
  title: string | null
  message: string | null
  is_read: boolean | null
  read_at: string | null
  target_role: string | null
  metadata: any
  created_at: string | null
  [key: string]: any
}

/**
 * Notification type enum
 */
type NotificationType = string

/**
 * Notification filters
 */
interface NotificationFilters {
  type?: NotificationType
  isRead?: boolean
  limit?: number
  offset?: number
}

/**
 * Notification callback
 */
type NotificationCallback = (notification: Notification) => void

/**
 * Normalize raw MongoDB notification (camelCase) to the snake_case interface.
 */
function normalizeNotification(raw: any): Notification {
  return {
    ...raw,
    id: raw.id || raw._id?.toString() || '',
    type: raw.type || raw.notificationType || null,
    notification_type: raw.type || raw.notificationType || null,
    title: raw.title || null,
    message: raw.message || null,
    body: raw.message || null,
    is_read: raw.isRead ?? raw.is_read ?? false,
    read_at: raw.readAt || raw.read_at || null,
    created_at: raw.createdAt ? new Date(raw.createdAt).toISOString() : raw.created_at || null,
    target_role: raw.targetRole || raw.target_role || null,
    metadata: raw.data || raw.metadata || null,
  }
}

/**
 * Notification service for managing user notifications.
 * Uses API client for data and Socket.IO for realtime.
 */
export const notificationService = {
  /**
   * Active cleanup function for realtime subscription
   */
  _cleanup: null as (() => void) | null,

  /**
   * Gets notifications for a user.
   */
  async getNotifications(
    userId: string,
    filters?: NotificationFilters
  ): Promise<Notification[]> {
    const params = new URLSearchParams()
    params.set('targetRole', 'user')
    if (filters?.type) params.set('type', filters.type)
    if (filters?.isRead !== undefined) params.set('isRead', String(filters.isRead))
    if (filters?.limit) params.set('limit', String(filters.limit))
    if (filters?.offset) params.set('offset', String(filters.offset))

    const result = await apiClient<{ notifications: any[] }>(
      `/api/notifications?userId=${userId}&${params.toString()}`
    )
    const raw = result.notifications || (result as any)
    return Array.isArray(raw) ? raw.map(normalizeNotification) : []
  },

  /**
   * Gets unread notification count.
   */
  async getUnreadCount(userId: string): Promise<number> {
    try {
      const result = await apiClient<{ count: number }>(
        `/api/notifications/unread-count?userId=${userId}&targetRole=user`
      )
      return result.count || 0
    } catch {
      return 0
    }
  },

  /**
   * Marks a notification as read.
   */
  async markAsRead(notificationId: string): Promise<void> {
    await apiClient(`/api/notifications/${notificationId}/read`, {
      method: 'PUT',
    })
  },

  /**
   * Marks all notifications as read.
   */
  async markAllAsRead(userId: string): Promise<void> {
    await apiClient(`/api/notifications/read-all`, {
      method: 'PUT',
      body: JSON.stringify({ userId, targetRole: 'user' }),
    })
  },

  /**
   * Deletes a notification.
   */
  async deleteNotification(notificationId: string): Promise<void> {
    await apiClient(`/api/notifications/${notificationId}`, {
      method: 'DELETE',
    })
  },

  /**
   * Deletes all read notifications.
   * Uses DELETE /api/notifications/all since clear-read endpoint does not exist.
   */
  async clearReadNotifications(userId: string): Promise<void> {
    await apiClient(`/api/notifications/all`, {
      method: 'DELETE',
      body: JSON.stringify({ userId, targetRole: 'user' }),
    })
  },

  /**
   * Subscribes to new notifications via Socket.IO.
   * @returns Cleanup function
   */
  subscribe(_userId: string, callback: NotificationCallback): () => void {
    // Clean up existing subscription
    if (this._cleanup) {
      this._cleanup()
    }

    const socket: Socket = getSocket()

    const handler = (raw: any) => {
      const normalized = normalizeNotification(raw)
      // Only pass through notifications for 'user' role or unscoped ones
      if (normalized.target_role && normalized.target_role !== 'user') return
      callback(normalized)
    }

    socket.on('notification:new', handler)

    const cleanup = () => {
      socket.off('notification:new', handler)
      this._cleanup = null
    }

    this._cleanup = cleanup
    return cleanup
  },

  /**
   * Requests browser notification permission.
   */
  async requestPermission(): Promise<NotificationPermission> {
    if (!('Notification' in window)) {
      console.warn('This browser does not support notifications')
      return 'denied'
    }
    return await Notification.requestPermission()
  },

  /**
   * Shows a browser notification.
   */
  showBrowserNotification(title: string, options?: NotificationOptions): void {
    if (!('Notification' in window)) return
    if (Notification.permission === 'granted') {
      new Notification(title, {
        icon: '/logo.png',
        badge: '/logo.png',
        ...options,
      })
    }
  },

  /**
   * Registers service worker for push notifications.
   */
  async registerServiceWorker(): Promise<ServiceWorkerRegistration | null> {
    if (!('serviceWorker' in navigator)) {
      console.warn('Service workers are not supported')
      return null
    }
    try {
      return await navigator.serviceWorker.register('/sw.js')
    } catch (error) {
      console.error('Service worker registration failed:', error)
      return null
    }
  },

  /**
   * Subscribes to push notifications.
   */
  async subscribeToPush(userId: string): Promise<boolean> {
    try {
      const registration = await this.registerServiceWorker()
      if (!registration) return false

      const vapidPublicKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY
      if (!vapidPublicKey) {
        console.warn('VAPID public key not configured')
        return false
      }

      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(vapidPublicKey),
      })

      const response = await apiClient('/api/notifications/subscribe', {
        method: 'POST',
        body: JSON.stringify({
          user_id: userId,
          subscription: subscription.toJSON(),
        }),
      })

      return !!response
    } catch (error) {
      console.error('Push subscription failed:', error)
      return false
    }
  },

  /**
   * Helper to convert VAPID key to Uint8Array.
   */
  urlBase64ToUint8Array(base64String: string): Uint8Array<ArrayBuffer> {
    const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding)
      .replace(/-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const buffer = new ArrayBuffer(rawData.length)
    const outputArray = new Uint8Array(buffer)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  },

  /**
   * Gets notification preferences.
   */
  async getPreferences(userId: string): Promise<Record<string, boolean>> {
    try {
      const result = await apiClient<{ preferences: Record<string, boolean> }>(
        `/api/notifications/preferences?userId=${userId}`
      )
      return result.preferences || {
        email_quotes: true,
        email_status: true,
        email_chat: false,
        push_quotes: true,
        push_status: true,
        push_chat: true,
        whatsapp_quotes: true,
        whatsapp_status: true,
      }
    } catch {
      return {
        email_quotes: true,
        email_status: true,
        email_chat: false,
        push_quotes: true,
        push_status: true,
        push_chat: true,
        whatsapp_quotes: true,
        whatsapp_status: true,
      }
    }
  },

  /**
   * Updates notification preferences.
   */
  async updatePreferences(
    userId: string,
    preferences: Record<string, boolean>
  ): Promise<void> {
    await apiClient(`/api/notifications/preferences`, {
      method: 'PUT',
      body: JSON.stringify({ userId, preferences }),
    })
  },
}

// Re-export types
export type {
  Notification,
  NotificationType,
  NotificationFilters,
  NotificationCallback,
}
