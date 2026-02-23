/**
 * WhatsApp integration for consultation notifications
 * Sends booking confirmations, reminders, and completion prompts
 */

import type { WhatsAppNotificationPayload, WhatsAppNotificationType } from "@/types/expert";

/**
 * WhatsApp API configuration
 */
const WHATSAPP_CONFIG = {
  API_URL: process.env.WHATSAPP_API_URL || "",
  API_KEY: process.env.WHATSAPP_API_KEY || "",
  ENABLED: process.env.WHATSAPP_ENABLED === "true",
} as const;

/**
 * Message templates for different notification types
 */
const MESSAGE_TEMPLATES: Record<WhatsAppNotificationType, (payload: WhatsAppNotificationPayload) => string> = {
  booking_confirmation: (payload) => `
*Booking Confirmed!*

Hi ${payload.clientName},

Your consultation with *${payload.expertName}* has been confirmed.

*Date:* ${payload.sessionDate}
*Time:* ${payload.sessionTime}

${payload.meetLink ? `*Google Meet Link:* ${payload.meetLink}` : ""}

Please be ready 5 minutes before your scheduled time.

If you need to reschedule or cancel, please do so at least 24 hours in advance.

Thank you for choosing AssignX!
  `.trim(),

  booking_reminder: (payload) => `
*Reminder: Consultation in 30 minutes*

Hi ${payload.clientName},

Your consultation with *${payload.expertName}* starts in 30 minutes.

*Date:* ${payload.sessionDate}
*Time:* ${payload.sessionTime}

${payload.meetLink ? `*Join Now:* ${payload.meetLink}` : ""}

Please ensure you have a stable internet connection and a quiet environment.

See you soon!
  `.trim(),

  session_completed: (payload) => `
*Session Completed*

Hi ${payload.clientName},

Thank you for your consultation with *${payload.expertName}*.

We hope your session was helpful! If you have any questions, feel free to reach out.

*Your feedback matters!* Please take a moment to rate your experience.

Thank you for using AssignX!
  `.trim(),

  review_request: (payload) => `
*How was your consultation?*

Hi ${payload.clientName},

We'd love to hear about your experience with *${payload.expertName}*.

Your feedback helps other students find the right expert and helps our experts improve.

Please take a minute to leave a review. It means a lot to us!

Thank you,
The AssignX Team
  `.trim(),
};

/**
 * Sends a WhatsApp notification
 * @param payload - Notification payload
 * @returns Success status and message ID
 */
export async function sendWhatsAppNotification(
  payload: WhatsAppNotificationPayload
): Promise<{ success: boolean; messageId?: string; error?: string }> {
  // Check if WhatsApp is enabled
  if (!WHATSAPP_CONFIG.ENABLED) {
    console.log("[WhatsApp] Notifications disabled, skipping:", payload.type);
    return { success: true, messageId: "disabled" };
  }

  // Validate phone number
  if (!isValidPhoneNumber(payload.phoneNumber)) {
    return { success: false, error: "Invalid phone number format" };
  }

  // Get message template
  const message = MESSAGE_TEMPLATES[payload.type](payload);

  try {
    // In production, this would call the actual WhatsApp Business API
    // For now, we'll log the message and return success
    console.log(`[WhatsApp] Sending ${payload.type} to ${payload.phoneNumber}`);
    console.log(`[WhatsApp] Message: ${message}`);

    // Simulate API call
    const response = await fetch(WHATSAPP_CONFIG.API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${WHATSAPP_CONFIG.API_KEY}`,
      },
      body: JSON.stringify({
        messaging_product: "whatsapp",
        to: formatPhoneNumber(payload.phoneNumber),
        type: "text",
        text: { body: message },
      }),
    });

    if (!response.ok) {
      throw new Error(`WhatsApp API error: ${response.statusText}`);
    }

    const data = await response.json();
    return { success: true, messageId: data.messages?.[0]?.id };
  } catch (error) {
    console.error("[WhatsApp] Failed to send notification:", error);
    return {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

/**
 * Sends booking confirmation notification
 */
export async function sendBookingConfirmation(
  phoneNumber: string,
  expertName: string,
  clientName: string,
  sessionDate: string,
  sessionTime: string,
  meetLink?: string
) {
  return sendWhatsAppNotification({
    type: "booking_confirmation",
    phoneNumber,
    expertName,
    clientName,
    sessionDate,
    sessionTime,
    meetLink,
  });
}

/**
 * Sends booking reminder notification (30 min before)
 */
export async function sendBookingReminder(
  phoneNumber: string,
  expertName: string,
  clientName: string,
  sessionDate: string,
  sessionTime: string,
  meetLink?: string
) {
  return sendWhatsAppNotification({
    type: "booking_reminder",
    phoneNumber,
    expertName,
    clientName,
    sessionDate,
    sessionTime,
    meetLink,
  });
}

/**
 * Sends session completion notification
 */
export async function sendSessionCompleted(
  phoneNumber: string,
  expertName: string,
  clientName: string,
  sessionDate: string,
  sessionTime: string
) {
  return sendWhatsAppNotification({
    type: "session_completed",
    phoneNumber,
    expertName,
    clientName,
    sessionDate,
    sessionTime,
  });
}

/**
 * Sends review request notification
 */
export async function sendReviewRequest(
  phoneNumber: string,
  expertName: string,
  clientName: string,
  sessionDate: string,
  sessionTime: string,
  bookingId: string
) {
  return sendWhatsAppNotification({
    type: "review_request",
    phoneNumber,
    expertName,
    clientName,
    sessionDate,
    sessionTime,
    bookingId,
  });
}

/**
 * Validates phone number format
 */
export function isValidPhoneNumber(phone: string): boolean {
  // Remove all non-digit characters
  const digits = phone.replace(/\D/g, "");
  // Valid if 10-15 digits (international format)
  return digits.length >= 10 && digits.length <= 15;
}

/**
 * Formats phone number for WhatsApp API (E.164 format)
 */
export function formatPhoneNumber(phone: string): string {
  // Remove all non-digit characters
  let digits = phone.replace(/\D/g, "");

  // Add country code if not present (assuming India)
  if (digits.length === 10) {
    digits = "91" + digits;
  }

  return digits;
}

/**
 * Schedules a reminder notification
 * @param bookingId - Booking ID for reference
 * @param reminderTime - Time to send reminder
 * @param payload - Notification payload
 */
export async function scheduleReminder(
  bookingId: string,
  reminderTime: Date,
  payload: Omit<WhatsAppNotificationPayload, "type">
): Promise<{ success: boolean; scheduledId?: string; error?: string }> {
  // In production, this would use a job queue like Bull or AWS SQS
  // For now, we'll log and return success
  console.log(`[WhatsApp] Scheduling reminder for booking ${bookingId} at ${reminderTime.toISOString()}`);

  return {
    success: true,
    scheduledId: `scheduled_${bookingId}_${Date.now()}`,
  };
}
