import { NextRequest, NextResponse } from "next/server";
import crypto from "crypto";
import { createClient } from "@/lib/supabase/server";
import { env, features } from "@/lib/env";

/**
 * Constant-time string comparison to prevent timing attacks
 * @param a First string to compare
 * @param b Second string to compare
 * @returns true if strings are equal, false otherwise
 */
function secureCompare(a: string, b: string): boolean {
  if (!a || !b) return false;
  if (a.length !== b.length) return false;
  try {
    return crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b));
  } catch {
    return false;
  }
}

/**
 * WhatsApp Business API configuration
 * Uses Meta's Cloud API for sending template messages
 * Environment variables are validated via env.ts
 */
const WHATSAPP_API_URL = "https://graph.facebook.com/v18.0";
const WHATSAPP_PHONE_NUMBER_ID = env.WHATSAPP_PHONE_NUMBER_ID;
const WHATSAPP_ACCESS_TOKEN = env.WHATSAPP_ACCESS_TOKEN;

/**
 * WhatsApp template names mapping
 */
const templateConfig: Record<string, { name: string; language: string }> = {
  quote_ready: { name: "quote_ready_notification", language: "en" },
  payment_received: { name: "payment_confirmed", language: "en" },
  project_started: { name: "project_started", language: "en" },
  project_delivered: { name: "project_delivered", language: "en" },
  revision_requested: { name: "revision_in_progress", language: "en" },
  project_completed: { name: "project_completed", language: "en" },
  auto_approval_reminder: { name: "review_reminder", language: "en" },
  new_message: { name: "new_message", language: "en" },
};

/**
 * POST /api/notifications/whatsapp
 * Send WhatsApp notification to user
 * Implements U40 from feature spec
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    // Verify authentication for user-initiated requests
    // Allow server-to-server calls with API key (using constant-time comparison)
    const apiKey = request.headers.get("x-api-key") || "";
    const internalKey = env.INTERNAL_API_KEY || "";
    const isServerCall = internalKey ? secureCompare(apiKey, internalKey) : false;

    if (!user && !isServerCall) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await request.json();
    const { phone, templateName, templateParams, userId } = body;

    // Validate required fields
    if (!phone || !templateName) {
      return NextResponse.json(
        { error: "Phone and templateName are required" },
        { status: 400 }
      );
    }

    // Get template config
    const template = templateConfig[templateName];
    if (!template) {
      return NextResponse.json(
        { error: "Invalid template name" },
        { status: 400 }
      );
    }

    // Check if WhatsApp feature is enabled
    if (!features.whatsApp || !WHATSAPP_PHONE_NUMBER_ID || !WHATSAPP_ACCESS_TOKEN) {
      console.warn("WhatsApp API not configured, skipping notification");
      return NextResponse.json({
        success: true,
        message: "WhatsApp not configured, notification skipped",
        mock: true,
      });
    }

    // Format phone number (ensure it has country code)
    const formattedPhone = formatPhoneNumber(phone);

    // Build message payload
    const messagePayload = {
      messaging_product: "whatsapp",
      recipient_type: "individual",
      to: formattedPhone,
      type: "template",
      template: {
        name: template.name,
        language: { code: template.language },
        components: buildTemplateComponents(templateName, templateParams),
      },
    };

    // Send message via WhatsApp Cloud API
    const response = await fetch(
      `${WHATSAPP_API_URL}/${WHATSAPP_PHONE_NUMBER_ID}/messages`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${WHATSAPP_ACCESS_TOKEN}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(messagePayload),
      }
    );

    const result = await response.json();

    if (!response.ok) {
      console.error("WhatsApp API error:", result);
      return NextResponse.json(
        { success: false, error: result.error?.message || "Failed to send" },
        { status: response.status }
      );
    }

    // Log notification to database
    await supabase.from("notification_logs").insert({
      profile_id: userId || user?.id,
      channel: "whatsapp",
      template_name: templateName,
      phone_number: formattedPhone,
      status: "sent",
      message_id: result.messages?.[0]?.id,
      metadata: templateParams,
    });

    return NextResponse.json({
      success: true,
      messageId: result.messages?.[0]?.id,
    });
  } catch (error) {
    console.error("WhatsApp notification error:", error);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}

/**
 * Format phone number to international format
 */
function formatPhoneNumber(phone: string): string {
  // Remove all non-numeric characters
  let cleaned = phone.replace(/\D/g, "");

  // If starts with 0, assume India and replace with 91
  if (cleaned.startsWith("0")) {
    cleaned = "91" + cleaned.substring(1);
  }

  // If doesn't start with country code, assume India (91)
  if (cleaned.length === 10) {
    cleaned = "91" + cleaned;
  }

  return cleaned;
}

/**
 * Build template components based on template type
 */
function buildTemplateComponents(
  templateName: string,
  params: Record<string, string>
): Array<{
  type: string;
  parameters?: Array<{ type: string; text?: string }>;
  sub_type?: string;
  index?: string;
}> {
  const components: Array<{
    type: string;
    parameters?: Array<{ type: string; text?: string }>;
    sub_type?: string;
    index?: string;
  }> = [];

  // Body parameters
  const bodyParams: Array<{ type: string; text: string }> = [];

  switch (templateName) {
    case "quote_ready":
      if (params.projectNumber) bodyParams.push({ type: "text", text: params.projectNumber });
      if (params.amount) bodyParams.push({ type: "text", text: `₹${params.amount}` });
      break;

    case "payment_received":
    case "project_started":
    case "project_delivered":
    case "project_completed":
    case "new_message":
      if (params.projectNumber) bodyParams.push({ type: "text", text: params.projectNumber });
      break;

    case "auto_approval_reminder":
      if (params.projectNumber) bodyParams.push({ type: "text", text: params.projectNumber });
      if (params.timeLeft) bodyParams.push({ type: "text", text: params.timeLeft });
      break;

    case "revision_requested":
      if (params.projectNumber) bodyParams.push({ type: "text", text: params.projectNumber });
      break;
  }

  if (bodyParams.length > 0) {
    components.push({ type: "body", parameters: bodyParams });
  }

  // Add CTA button if project link is available
  if (params.projectId) {
    components.push({
      type: "button",
      sub_type: "url",
      index: "0",
      parameters: [{ type: "text", text: params.projectId }],
    });
  }

  return components;
}
