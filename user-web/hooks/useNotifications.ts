"use client"

import { useState, useEffect, useCallback, useRef } from "react"
import { toast } from "sonner"
import { notificationService, type Notification } from "@/services"

/**
 * Notification state
 */
interface NotificationState {
  notifications: Notification[]
  unreadCount: number
  isLoading: boolean
  hasMore: boolean
  pushEnabled: boolean
  pushSupported: boolean
}

/**
 * VAPID public key from environment
 */
const VAPID_PUBLIC_KEY = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY

/**
 * Convert base64 to Uint8Array for VAPID key
 */
function urlBase64ToUint8Array(base64String: string): Uint8Array<ArrayBuffer> {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
  const rawData = window.atob(base64)
  const buffer = new ArrayBuffer(rawData.length)
  const outputArray = new Uint8Array(buffer)
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i)
  }
  return outputArray
}

/**
 * useNotifications hook
 * Manages notifications and push subscription
 */
export function useNotifications(userId: string | null) {
  const [state, setState] = useState<NotificationState>({
    notifications: [],
    unreadCount: 0,
    isLoading: true,
    hasMore: true,
    pushEnabled: false,
    pushSupported: false,
  })
  const unsubscribeRef = useRef<(() => void) | null>(null)

  /**
   * Check if push notifications are supported
   */
  useEffect(() => {
    const supported = "serviceWorker" in navigator && "PushManager" in window
    setState((prev) => ({ ...prev, pushSupported: supported }))
  }, [])

  /**
   * Load notifications and subscribe to real-time updates
   */
  useEffect(() => {
    if (!userId) {
      setState((prev) => ({ ...prev, isLoading: false }))
      return
    }

    let isMounted = true

    const loadNotifications = async () => {
      setState((prev) => ({ ...prev, isLoading: true }))

      try {
        const notifications = await notificationService.getNotifications(userId, { limit: 20 })
        if (!isMounted) return

        const unreadCount = notifications.filter((n) => !n.is_read).length

        setState((prev) => ({
          ...prev,
          notifications,
          unreadCount,
          isLoading: false,
          hasMore: notifications.length === 20,
        }))

        // Subscribe to real-time updates
        unsubscribeRef.current = notificationService.subscribe(userId, (notification) => {
          setState((prev) => ({
            ...prev,
            notifications: [notification, ...prev.notifications],
            unreadCount: prev.unreadCount + 1,
          }))

          // Show toast for new notification
          toast(notification.title, {
            description: notification.body,
          })
        })
      } catch (error) {
        console.error("Load notifications error:", error)
        if (isMounted) {
          setState((prev) => ({ ...prev, isLoading: false }))
        }
      }
    }

    loadNotifications()

    return () => {
      isMounted = false
      if (unsubscribeRef.current) {
        unsubscribeRef.current()
        unsubscribeRef.current = null
      }
    }
  }, [userId])

  /**
   * Check push subscription status on mount
   */
  useEffect(() => {
    if (!state.pushSupported || !userId) return

    const checkPushStatus = async () => {
      try {
        const registration = await navigator.serviceWorker.ready
        const subscription = await registration.pushManager.getSubscription()
        setState((prev) => ({ ...prev, pushEnabled: !!subscription }))
      } catch (error) {
        console.error("Check push status error:", error)
      }
    }

    checkPushStatus()
  }, [state.pushSupported, userId])

  /**
   * Register service worker
   */
  const registerServiceWorker = useCallback(async (): Promise<ServiceWorkerRegistration | null> => {
    if (!("serviceWorker" in navigator)) {
      return null
    }

    try {
      const registration = await navigator.serviceWorker.register("/sw.js", {
        scope: "/",
      })
      console.log("Service worker registered:", registration)
      return registration
    } catch (error) {
      console.error("Service worker registration failed:", error)
      return null
    }
  }, [])

  /**
   * Subscribe to push notifications
   */
  const subscribeToPush = useCallback(async (): Promise<boolean> => {
    if (!state.pushSupported || !VAPID_PUBLIC_KEY) {
      toast.error("Push notifications are not supported")
      return false
    }

    try {
      // Request permission
      const permission = await Notification.requestPermission()
      if (permission !== "granted") {
        toast.error("Notification permission denied")
        return false
      }

      // Register service worker
      const registration = await registerServiceWorker()
      if (!registration) {
        toast.error("Failed to register service worker")
        return false
      }

      // Wait for service worker to be ready
      await navigator.serviceWorker.ready

      // Subscribe to push
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY),
      })

      // Send subscription to server
      const response = await fetch("/api/notifications/subscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ subscription: subscription.toJSON() }),
      })

      if (!response.ok) {
        throw new Error("Failed to save subscription")
      }

      setState((prev) => ({ ...prev, pushEnabled: true }))
      toast.success("Push notifications enabled")
      return true
    } catch (error: any) {
      console.error("Subscribe to push error:", error)
      toast.error(error.message || "Failed to enable push notifications")
      return false
    }
  }, [state.pushSupported, registerServiceWorker])

  /**
   * Unsubscribe from push notifications
   */
  const unsubscribeFromPush = useCallback(async (): Promise<boolean> => {
    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()

      if (subscription) {
        // Unsubscribe from push manager
        await subscription.unsubscribe()

        // Remove from server
        await fetch("/api/notifications/subscribe", {
          method: "DELETE",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ endpoint: subscription.endpoint }),
        })
      }

      setState((prev) => ({ ...prev, pushEnabled: false }))
      toast.success("Push notifications disabled")
      return true
    } catch (error: any) {
      console.error("Unsubscribe from push error:", error)
      toast.error(error.message || "Failed to disable push notifications")
      return false
    }
  }, [])

  /**
   * Mark notification as read
   */
  const markAsRead = useCallback(async (notificationId: string) => {
    try {
      await notificationService.markAsRead(notificationId)
      setState((prev) => ({
        ...prev,
        notifications: prev.notifications.map((n) =>
          n.id === notificationId ? { ...n, is_read: true } : n
        ),
        unreadCount: Math.max(0, prev.unreadCount - 1),
      }))
    } catch (error) {
      console.error("Mark as read error:", error)
    }
  }, [])

  /**
   * Mark all notifications as read
   */
  const markAllAsRead = useCallback(async () => {
    if (!userId) return

    try {
      await notificationService.markAllAsRead(userId)
      setState((prev) => ({
        ...prev,
        notifications: prev.notifications.map((n) => ({ ...n, is_read: true })),
        unreadCount: 0,
      }))
    } catch (error) {
      console.error("Mark all as read error:", error)
    }
  }, [userId])

  /**
   * Load more notifications (pagination)
   */
  const loadMore = useCallback(async () => {
    if (!userId || !state.hasMore || state.isLoading) return

    setState((prev) => ({ ...prev, isLoading: true }))

    try {
      const moreNotifications = await notificationService.getNotifications(userId, {
        limit: 20,
        offset: state.notifications.length,
      })

      setState((prev) => ({
        ...prev,
        notifications: [...prev.notifications, ...moreNotifications],
        isLoading: false,
        hasMore: moreNotifications.length === 20,
      }))
    } catch (error) {
      console.error("Load more error:", error)
      setState((prev) => ({ ...prev, isLoading: false }))
    }
  }, [userId, state.notifications, state.hasMore, state.isLoading])

  /**
   * Delete a notification
   */
  const deleteNotification = useCallback(async (notificationId: string) => {
    try {
      await notificationService.deleteNotification(notificationId)
      setState((prev) => ({
        ...prev,
        notifications: prev.notifications.filter((n) => n.id !== notificationId),
      }))
    } catch (error) {
      console.error("Delete notification error:", error)
      toast.error("Failed to delete notification")
    }
  }, [])

  return {
    ...state,
    subscribeToPush,
    unsubscribeFromPush,
    markAsRead,
    markAllAsRead,
    loadMore,
    deleteNotification,
  }
}
