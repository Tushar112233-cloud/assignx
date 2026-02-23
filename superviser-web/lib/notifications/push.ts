/**
 * @fileoverview Web Push notification utilities
 * Handles push notification subscription, permissions, and sending
 */

import { createClient } from "@/lib/supabase/client"

export interface PushSubscriptionData {
  endpoint: string
  keys: {
    p256dh: string
    auth: string
  }
}

/**
 * Check if push notifications are supported in the browser
 */
export function isPushSupported(): boolean {
  return (
    "serviceWorker" in navigator &&
    "PushManager" in window &&
    "Notification" in window
  )
}

/**
 * Check current notification permission status
 */
export function getPermissionStatus(): NotificationPermission {
  if (!("Notification" in window)) {
    return "denied"
  }
  return Notification.permission
}

/**
 * Request notification permission from the user
 */
export async function requestNotificationPermission(): Promise<NotificationPermission> {
  if (!("Notification" in window)) {
    throw new Error("This browser does not support notifications")
  }

  const permission = await Notification.requestPermission()
  return permission
}

/**
 * Register the service worker
 */
export async function registerServiceWorker(): Promise<ServiceWorkerRegistration> {
  if (!("serviceWorker" in navigator)) {
    throw new Error("Service workers are not supported in this browser")
  }

  try {
    const registration = await navigator.serviceWorker.register("/sw.js", {
      scope: "/",
    })

    console.log("[Push] Service worker registered:", registration)

    // Wait for the service worker to be ready
    await navigator.serviceWorker.ready

    return registration
  } catch (error) {
    console.error("[Push] Service worker registration failed:", error)
    throw error
  }
}

/**
 * Subscribe to push notifications
 * Returns the push subscription data to be saved to the database
 */
export async function subscribeToPush(
  vapidPublicKey: string
): Promise<PushSubscriptionData> {
  if (!isPushSupported()) {
    throw new Error("Push notifications are not supported in this browser")
  }

  // Request permission first
  const permission = await requestNotificationPermission()
  if (permission !== "granted") {
    throw new Error("Notification permission denied")
  }

  // Register service worker
  const registration = await registerServiceWorker()

  // Subscribe to push notifications
  try {
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(vapidPublicKey),
    })

    const subscriptionData = subscription.toJSON()

    if (!subscriptionData.endpoint || !subscriptionData.keys) {
      throw new Error("Invalid subscription data")
    }

    return {
      endpoint: subscriptionData.endpoint,
      keys: {
        p256dh: subscriptionData.keys.p256dh,
        auth: subscriptionData.keys.auth,
      },
    }
  } catch (error) {
    console.error("[Push] Subscription failed:", error)
    throw error
  }
}

/**
 * Unsubscribe from push notifications
 */
export async function unsubscribeFromPush(): Promise<void> {
  if (!("serviceWorker" in navigator)) {
    return
  }

  try {
    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.getSubscription()

    if (subscription) {
      await subscription.unsubscribe()
      console.log("[Push] Unsubscribed successfully")
    }
  } catch (error) {
    console.error("[Push] Unsubscribe failed:", error)
    throw error
  }
}

/**
 * Get the current push subscription
 */
export async function getPushSubscription(): Promise<PushSubscription | null> {
  if (!("serviceWorker" in navigator)) {
    return null
  }

  try {
    const registration = await navigator.serviceWorker.ready
    return await registration.pushManager.getSubscription()
  } catch (error) {
    console.error("[Push] Failed to get subscription:", error)
    return null
  }
}

/**
 * Save push subscription to the database
 */
export async function savePushSubscription(
  subscriptionData: PushSubscriptionData
): Promise<void> {
  const supabase = createClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    throw new Error("User not authenticated")
  }

  // Save to supervisor_push_subscriptions table
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { error } = await (supabase as any).from("supervisor_push_subscriptions").upsert(
    {
      supervisor_id: user.id,
      endpoint: subscriptionData.endpoint,
      p256dh_key: subscriptionData.keys.p256dh,
      auth_key: subscriptionData.keys.auth,
      updated_at: new Date().toISOString(),
    },
    {
      onConflict: "supervisor_id",
    }
  )

  if (error) {
    console.error("[Push] Failed to save subscription:", error)
    throw error
  }

  console.log("[Push] Subscription saved to database")
}

/**
 * Remove push subscription from the database
 */
export async function removePushSubscription(): Promise<void> {
  const supabase = createClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    throw new Error("User not authenticated")
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { error } = await (supabase as any)
    .from("supervisor_push_subscriptions")
    .delete()
    .eq("supervisor_id", user.id)

  if (error) {
    console.error("[Push] Failed to remove subscription:", error)
    throw error
  }

  console.log("[Push] Subscription removed from database")
}

/**
 * Convert URL-safe base64 string to Uint8Array
 * Required for VAPID public key conversion
 */
function urlBase64ToUint8Array(base64String: string): ArrayBuffer {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding)
    .replace(/\-/g, "+")
    .replace(/_/g, "/")

  const rawData = window.atob(base64)
  const outputArray = new Uint8Array(rawData.length)

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i)
  }

  return outputArray.buffer as ArrayBuffer
}

/**
 * Show a test notification
 */
export async function showTestNotification(): Promise<void> {
  const permission = await requestNotificationPermission()

  if (permission !== "granted") {
    throw new Error("Notification permission denied")
  }

  const registration = await navigator.serviceWorker.ready

  await registration.showNotification("AssignX Test Notification", {
    body: "Push notifications are working correctly!",
    icon: "/icon-192x192.png",
    badge: "/icon-192x192.png",
    tag: "test-notification",
  })
}
