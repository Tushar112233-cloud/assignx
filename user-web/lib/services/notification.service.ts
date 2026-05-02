/**
 * Notification Service
 * Handles push notifications and WhatsApp message integration
 * Implements U39 (Push) and U40 (WhatsApp) from feature spec
 */

/**
 * Notification types
 */
export type NotificationType =
  | "quote_ready"
  | "payment_received"
  | "project_started"
  | "project_delivered"
  | "revision_requested"
  | "project_completed"
  | "auto_approval_reminder"
  | "new_message";

/**
 * Notification payload
 */
export interface NotificationPayload {
  type: NotificationType;
  title: string;
  body: string;
  projectId?: string;
  projectNumber?: string;
  data?: Record<string, string>;
}

/**
 * Check if push notifications are supported
 */
export function isPushSupported(): boolean {
  return typeof window !== "undefined" && "Notification" in window && "serviceWorker" in navigator;
}

/**
 * Request push notification permission
 * @returns Permission status
 */
export async function requestPushPermission(): Promise<NotificationPermission> {
  if (!isPushSupported()) {
    console.warn("Push notifications not supported");
    return "denied";
  }

  const permission = await Notification.requestPermission();
  return permission;
}

/**
 * Get current push permission status
 */
export function getPushPermission(): NotificationPermission | null {
  if (!isPushSupported()) return null;
  return Notification.permission;
}

/**
 * Subscribe to push notifications
 * @param vapidPublicKey - VAPID public key for web push
 * @returns Push subscription or null
 */
export async function subscribeToPush(
  vapidPublicKey: string
): Promise<PushSubscription | null> {
  if (!isPushSupported()) return null;

  try {
    const registration = await navigator.serviceWorker.ready;

    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(vapidPublicKey),
    });

    return subscription;
  } catch (error) {
    console.error("Failed to subscribe to push:", error);
    return null;
  }
}

/**
 * Show local notification
 * @param payload - Notification content
 */
export async function showLocalNotification(payload: NotificationPayload): Promise<void> {
  if (!isPushSupported()) return;

  const permission = await requestPushPermission();
  if (permission !== "granted") return;

  const registration = await navigator.serviceWorker.ready;

  await registration.showNotification(payload.title, {
    body: payload.body,
    icon: "/icons/icon-192.png",
    badge: "/icons/badge-72.png",
    tag: payload.projectId || payload.type,
    data: {
      type: payload.type,
      projectId: payload.projectId,
      ...payload.data,
    },
  } as NotificationOptions);
}

/**
 * Send WhatsApp message via server API
 * @param phone - Phone number with country code
 * @param templateName - WhatsApp template name
 * @param templateParams - Template parameters
 */
export async function sendWhatsAppNotification(
  phone: string,
  templateName: string,
  templateParams: Record<string, string>
): Promise<{ success: boolean; error?: string }> {
  try {
    const response = await fetch("/api/notifications/whatsapp", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        phone,
        templateName,
        templateParams,
      }),
    });

    const data = await response.json();
    return data;
  } catch (error) {
    console.error("WhatsApp notification error:", error);
    return { success: false, error: "Failed to send WhatsApp message" };
  }
}

/**
 * Get notification templates for different events
 */
export function getNotificationTemplate(
  type: NotificationType,
  data: Record<string, string>
): NotificationPayload {
  const templates: Record<NotificationType, NotificationPayload> = {
    quote_ready: {
      type: "quote_ready",
      title: "Quote Ready! 💰",
      body: `Your project ${data.projectNumber} has been quoted at ₹${data.amount}. Pay now to start work.`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
    payment_received: {
      type: "payment_received",
      title: "Payment Confirmed ✅",
      body: `Payment received for ${data.projectNumber}. Our expert will start working immediately.`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
    project_started: {
      type: "project_started",
      title: "Work Started 🚀",
      body: `An expert has started working on ${data.projectNumber}. Track progress in the app.`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
    project_delivered: {
      type: "project_delivered",
      title: "Project Delivered! 📦",
      body: `${data.projectNumber} is ready for review. Please check and approve within 48 hours.`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
    revision_requested: {
      type: "revision_requested",
      title: "Revision in Progress 🔄",
      body: `Your revision request for ${data.projectNumber} has been received. We're working on it.`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
    project_completed: {
      type: "project_completed",
      title: "Project Completed! 🎉",
      body: `${data.projectNumber} has been marked as complete. Thank you for using AssignX!`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
    auto_approval_reminder: {
      type: "auto_approval_reminder",
      title: "Review Reminder ⏰",
      body: `${data.projectNumber} will auto-approve in ${data.timeLeft}. Review it now!`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
    new_message: {
      type: "new_message",
      title: "New Message 💬",
      body: `You have a new message regarding ${data.projectNumber}.`,
      projectId: data.projectId,
      projectNumber: data.projectNumber,
    },
  };

  return templates[type];
}

/**
 * Helper: Convert VAPID key to Uint8Array
 */
function urlBase64ToUint8Array(base64String: string): Uint8Array<ArrayBuffer> {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");

  const rawData = window.atob(base64);
  const buffer = new ArrayBuffer(rawData.length);
  const outputArray = new Uint8Array(buffer);

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }

  return outputArray;
}
