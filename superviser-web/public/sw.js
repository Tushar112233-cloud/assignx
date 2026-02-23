/**
 * @fileoverview Service Worker for push notifications
 * Handles background push notifications and notification clicks
 */

// Service Worker version for cache busting
const SW_VERSION = "v1.0.0"
const CACHE_NAME = `superviser-web-${SW_VERSION}`

// Install event - cache static assets
self.addEventListener("install", (event) => {
  console.log("[Service Worker] Installing...")
  self.skipWaiting()
})

// Activate event - clean up old caches
self.addEventListener("activate", (event) => {
  console.log("[Service Worker] Activating...")
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      )
    })
  )
  return self.clients.claim()
})

// Push event - display notification
self.addEventListener("push", (event) => {
  console.log("[Service Worker] Push received:", event)

  if (!event.data) {
    console.log("[Service Worker] No data in push event")
    return
  }

  const data = event.data.json()
  const {
    title = "AssignX Notification",
    body = "",
    icon = "/icon-192x192.png",
    badge = "/icon-192x192.png",
    image,
    data: notificationData = {},
    tag,
    requireInteraction = false,
  } = data

  const options = {
    body,
    icon,
    badge,
    image,
    data: notificationData,
    tag: tag || `notification-${Date.now()}`,
    requireInteraction,
    vibrate: [200, 100, 200],
    actions: [
      {
        action: "view",
        title: "View",
        icon: "/icon-192x192.png",
      },
      {
        action: "dismiss",
        title: "Dismiss",
      },
    ],
  }

  event.waitUntil(self.registration.showNotification(title, options))
})

// Notification click event
self.addEventListener("notificationclick", (event) => {
  console.log("[Service Worker] Notification clicked:", event.notification.tag)
  event.notification.close()

  const { action, data } = event
  const url = data?.url || "/dashboard"

  if (action === "dismiss") {
    return
  }

  // Open or focus the app window
  event.waitUntil(
    clients
      .matchAll({
        type: "window",
        includeUncontrolled: true,
      })
      .then((clientList) => {
        // Check if there's already a window open
        for (const client of clientList) {
          if (client.url.includes(url) && "focus" in client) {
            return client.focus()
          }
        }

        // Open new window if none exists
        if (clients.openWindow) {
          return clients.openWindow(url)
        }
      })
  )
})

// Handle notification close event
self.addEventListener("notificationclose", (event) => {
  console.log("[Service Worker] Notification closed:", event.notification.tag)
})

// Handle messages from the main thread
self.addEventListener("message", (event) => {
  console.log("[Service Worker] Message received:", event.data)

  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting()
  }
})
