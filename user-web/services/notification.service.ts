import { createClient } from '@/lib/supabase/client'
import type { Database } from '@/types/database'
import type { RealtimeChannel } from '@supabase/supabase-js'

/**
 * Type alias for notifications table
 */
type Notification = Database['public']['Tables']['notifications']['Row']

/**
 * Notification type enum
 */
type NotificationType = Database['public']['Enums']['notification_type']

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

const supabase = createClient()

/**
 * Notification service for managing user notifications.
 * Handles fetching, marking as read, and real-time subscriptions.
 */
export const notificationService = {
  /**
   * Active subscription
   */
  subscription: null as RealtimeChannel | null,

  /**
   * Gets notifications for a user.
   * @param userId - The user's profile ID
   * @param filters - Optional filters
   * @returns Array of notifications
   */
  async getNotifications(
    userId: string,
    filters?: NotificationFilters
  ): Promise<Notification[]> {
    let query = supabase
      .from('notifications')
      .select('*')
      .eq('profile_id', userId)
      .eq('target_role', 'user')
      .order('created_at', { ascending: false })

    // Apply filters
    if (filters?.type) {
      query = query.eq('type', filters.type)
    }
    if (filters?.isRead !== undefined) {
      query = query.eq('is_read', filters.isRead)
    }
    if (filters?.limit) {
      query = query.limit(filters.limit)
    }
    if (filters?.offset) {
      query = query.range(filters.offset, filters.offset + (filters.limit || 10) - 1)
    }

    const { data, error } = await query

    if (error) throw error
    return data
  },

  /**
   * Gets unread notification count.
   * @param userId - The user's profile ID
   * @returns Unread count
   */
  async getUnreadCount(userId: string): Promise<number> {
    const { count, error } = await supabase
      .from('notifications')
      .select('*', { count: 'exact', head: true })
      .eq('profile_id', userId)
      .eq('target_role', 'user')
      .eq('is_read', false)

    if (error) throw error
    return count || 0
  },

  /**
   * Marks a notification as read.
   * @param notificationId - The notification UUID
   */
  async markAsRead(notificationId: string): Promise<void> {
    const { error } = await supabase
      .from('notifications')
      .update({ is_read: true, read_at: new Date().toISOString() })
      .eq('id', notificationId)

    if (error) throw error
  },

  /**
   * Marks all notifications as read.
   * @param userId - The user's profile ID
   */
  async markAllAsRead(userId: string): Promise<void> {
    const { error } = await supabase
      .from('notifications')
      .update({ is_read: true, read_at: new Date().toISOString() })
      .eq('profile_id', userId)
      .eq('target_role', 'user')
      .eq('is_read', false)

    if (error) throw error
  },

  /**
   * Deletes a notification.
   * @param notificationId - The notification UUID
   */
  async deleteNotification(notificationId: string): Promise<void> {
    const { error } = await supabase
      .from('notifications')
      .delete()
      .eq('id', notificationId)

    if (error) throw error
  },

  /**
   * Deletes all read notifications.
   * @param userId - The user's profile ID
   */
  async clearReadNotifications(userId: string): Promise<void> {
    const { error } = await supabase
      .from('notifications')
      .delete()
      .eq('profile_id', userId)
      .eq('target_role', 'user')
      .eq('is_read', true)

    if (error) throw error
  },

  /**
   * Subscribes to new notifications.
   * @param userId - The user's profile ID
   * @param callback - Function to call when new notification arrives
   * @returns Cleanup function
   */
  subscribe(userId: string, callback: NotificationCallback): () => void {
    // Unsubscribe from existing subscription
    if (this.subscription) {
      this.subscription.unsubscribe()
    }

    // Create new subscription
    this.subscription = supabase
      .channel(`notifications:${userId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'notifications',
          filter: `profile_id=eq.${userId}`,
        },
        (payload: any) => {
          callback(payload.new as Notification)
        }
      )
      .subscribe()

    // Return cleanup function
    return () => {
      this.subscription?.unsubscribe()
      this.subscription = null
    }
  },

  /**
   * Requests browser notification permission.
   * @returns Permission state
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
   * @param title - Notification title
   * @param options - Notification options
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
   * @returns ServiceWorkerRegistration or null
   */
  async registerServiceWorker(): Promise<ServiceWorkerRegistration | null> {
    if (!('serviceWorker' in navigator)) {
      console.warn('Service workers are not supported')
      return null
    }

    try {
      const registration = await navigator.serviceWorker.register('/sw.js')
      return registration
    } catch (error) {
      console.error('Service worker registration failed:', error)
      return null
    }
  },

  /**
   * Subscribes to push notifications.
   * @param userId - The user's profile ID
   * @returns Whether subscription was successful
   */
  async subscribeToPush(userId: string): Promise<boolean> {
    try {
      const registration = await this.registerServiceWorker()
      if (!registration) return false

      // Get VAPID public key from env
      const vapidPublicKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY
      if (!vapidPublicKey) {
        console.warn('VAPID public key not configured')
        return false
      }

      // Subscribe to push
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(vapidPublicKey),
      })

      // Save subscription to server
      const response = await fetch('/api/notifications/subscribe', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          profile_id: userId,
          subscription: subscription.toJSON(),
        }),
      })

      return response.ok
    } catch (error) {
      console.error('Push subscription failed:', error)
      return false
    }
  },

  /**
   * Helper to convert VAPID key to Uint8Array.
   * @param base64String - Base64 encoded string
   * @returns Uint8Array
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
   * @param userId - The user's profile ID
   * @returns Notification preferences
   */
  async getPreferences(userId: string): Promise<Record<string, boolean>> {
    const { data, error } = await supabase
      .from('notification_preferences')
      .select('*')
      .eq('profile_id', userId)
      .single()

    if (error) {
      if (error.code === 'PGRST116') {
        // Return defaults
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
      throw error
    }

    return data.preferences as Record<string, boolean>
  },

  /**
   * Updates notification preferences.
   * @param userId - The user's profile ID
   * @param preferences - New preferences
   */
  async updatePreferences(
    userId: string,
    preferences: Record<string, boolean>
  ): Promise<void> {
    const { error } = await supabase
      .from('notification_preferences')
      .upsert({
        profile_id: userId,
        preferences,
        updated_at: new Date().toISOString(),
      })

    if (error) throw error
  },
}

// Re-export types
export type {
  Notification,
  NotificationType,
  NotificationFilters,
  NotificationCallback,
}
