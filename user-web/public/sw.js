/**
 * Service Worker for Push Notifications
 * AssignX User Web
 */

const CACHE_NAME = "assignx-v1"

// Install event
self.addEventListener("install", (event) => {
  console.log("[SW] Install")
  self.skipWaiting()
})

// Activate event
self.addEventListener("activate", (event) => {
  console.log("[SW] Activate")
  event.waitUntil(clients.claim())
})

// Push event - Handle incoming push notifications
self.addEventListener("push", (event) => {
  console.log("[SW] Push received")

  let data = {
    title: "AssignX",
    body: "You have a new notification",
    icon: "/icons/icon-192x192.png",
    badge: "/icons/badge-72x72.png",
    data: {},
  }

  try {
    if (event.data) {
      const payload = event.data.json()
      data = {
        title: payload.title || data.title,
        body: payload.body || data.body,
        icon: payload.icon || data.icon,
        badge: payload.badge || data.badge,
        data: payload.data || {},
      }
    }
  } catch (e) {
    console.error("[SW] Error parsing push data:", e)
  }

  const options = {
    body: data.body,
    icon: data.icon,
    badge: data.badge,
    vibrate: [100, 50, 100],
    data: data.data,
    actions: getActionsForType(data.data?.type),
    tag: data.data?.id || "default",
    renotify: true,
  }

  event.waitUntil(self.registration.showNotification(data.title, options))
})

/**
 * Get notification actions based on type
 */
function getActionsForType(type) {
  switch (type) {
    case "message":
      return [
        { action: "reply", title: "Reply" },
        { action: "view", title: "View" },
      ]
    case "project_update":
      return [
        { action: "view", title: "View Project" },
      ]
    case "payment":
      return [
        { action: "view", title: "View Details" },
      ]
    default:
      return [
        { action: "view", title: "View" },
        { action: "dismiss", title: "Dismiss" },
      ]
  }
}

// Notification click event
self.addEventListener("notificationclick", (event) => {
  console.log("[SW] Notification clicked:", event.action)

  event.notification.close()

  const data = event.notification.data || {}
  let url = "/"

  // Determine URL based on notification type and action
  if (event.action === "dismiss") {
    return
  }

  switch (data.type) {
    case "message":
      url = data.projectId ? `/projects/${data.projectId}?chat=open` : "/projects"
      break
    case "project_update":
      url = data.projectId ? `/projects/${data.projectId}` : "/projects"
      break
    case "payment":
      url = "/wallet"
      break
    case "marketplace":
      url = data.listingId ? `/marketplace/${data.listingId}` : "/marketplace"
      break
    default:
      url = data.url || "/notifications"
  }

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      // Check if a window is already open
      for (const client of clientList) {
        if (client.url.includes(self.location.origin) && "focus" in client) {
          client.navigate(url)
          return client.focus()
        }
      }
      // Open new window
      if (clients.openWindow) {
        return clients.openWindow(url)
      }
    })
  )
})

// Notification close event
self.addEventListener("notificationclose", (event) => {
  console.log("[SW] Notification closed")
})

// Message event - Handle messages from the main app
self.addEventListener("message", (event) => {
  console.log("[SW] Message received:", event.data)

  if (event.data?.type === "SKIP_WAITING") {
    self.skipWaiting()
  }
})
