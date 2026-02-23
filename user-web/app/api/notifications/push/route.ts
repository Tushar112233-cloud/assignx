import { NextRequest, NextResponse } from "next/server";
import crypto from "crypto";
import { createClient } from "@/lib/supabase/server";
import webpush from "web-push";
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
 * Web Push VAPID configuration
 * Uses validated environment variables from env.ts
 */
const VAPID_PUBLIC_KEY = env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
const VAPID_PRIVATE_KEY = env.VAPID_PRIVATE_KEY;
const VAPID_EMAIL = env.VAPID_EMAIL || "mailto:support@assignx.com";

// Configure web-push if feature is enabled
if (features.pushNotifications && VAPID_PUBLIC_KEY && VAPID_PRIVATE_KEY) {
  webpush.setVapidDetails(VAPID_EMAIL, VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY);
}

/**
 * POST /api/notifications/push
 * Send push notification to user
 * Implements U39 from feature spec
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    // Verify authentication (using constant-time comparison to prevent timing attacks)
    const apiKey = request.headers.get("x-api-key") || "";
    const internalKey = env.INTERNAL_API_KEY || "";
    const isServerCall = internalKey ? secureCompare(apiKey, internalKey) : false;

    if (!user && !isServerCall) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await request.json();
    const { userId, title, body: messageBody, data, icon, badge, tag } = body;

    const targetUserId = userId || user?.id;
    if (!targetUserId) {
      return NextResponse.json({ error: "User ID required" }, { status: 400 });
    }

    // Get user's push subscriptions
    const { data: subscriptions, error } = await supabase
      .from("push_subscriptions")
      .select("*")
      .eq("profile_id", targetUserId)
      .eq("is_active", true);

    if (error) {
      console.error("Error fetching subscriptions:", error);
      return NextResponse.json(
        { success: false, error: "Failed to fetch subscriptions" },
        { status: 500 }
      );
    }

    if (!subscriptions || subscriptions.length === 0) {
      return NextResponse.json({
        success: true,
        message: "No active subscriptions",
        sent: 0,
      });
    }

    // Check if web-push is configured
    if (!VAPID_PUBLIC_KEY || !VAPID_PRIVATE_KEY) {
      console.warn("Web Push not configured");
      return NextResponse.json({
        success: true,
        message: "Push not configured",
        mock: true,
      });
    }

    // Build notification payload
    const notificationPayload = JSON.stringify({
      title: title || "AssignX",
      body: messageBody,
      icon: icon || "/icons/icon-192.png",
      badge: badge || "/icons/badge-72.png",
      tag: tag || "default",
      data: data || {},
      timestamp: Date.now(),
    });

    // Send to all subscriptions
    const results = await Promise.allSettled(
      subscriptions.map(async (sub) => {
        const pushSubscription = {
          endpoint: sub.endpoint,
          keys: {
            p256dh: sub.p256dh,
            auth: sub.auth,
          },
        };

        try {
          await webpush.sendNotification(pushSubscription, notificationPayload);
          return { success: true, id: sub.id };
        } catch (err: unknown) {
          const error = err as { statusCode?: number };
          // If subscription is invalid, mark it as inactive
          if (error.statusCode === 404 || error.statusCode === 410) {
            await supabase
              .from("push_subscriptions")
              .update({ is_active: false })
              .eq("id", sub.id);
          }
          return { success: false, id: sub.id, error: error.statusCode };
        }
      })
    );

    const successCount = results.filter(
      (r) => r.status === "fulfilled" && (r.value as { success: boolean }).success
    ).length;

    // Log notification
    await supabase.from("notification_logs").insert({
      profile_id: targetUserId,
      channel: "push",
      title,
      body: messageBody,
      status: successCount > 0 ? "sent" : "failed",
      metadata: { data, sent: successCount, total: subscriptions.length },
    });

    return NextResponse.json({
      success: true,
      sent: successCount,
      total: subscriptions.length,
    });
  } catch (error) {
    console.error("Push notification error:", error);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}

/**
 * PUT /api/notifications/push
 * Subscribe to push notifications
 */
export async function PUT(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await request.json();
    const { subscription } = body;

    if (!subscription || !subscription.endpoint) {
      return NextResponse.json(
        { error: "Valid subscription required" },
        { status: 400 }
      );
    }

    // Check if subscription already exists
    const { data: existing } = await supabase
      .from("push_subscriptions")
      .select("id")
      .eq("endpoint", subscription.endpoint)
      .single();

    if (existing) {
      // Update existing subscription
      await supabase
        .from("push_subscriptions")
        .update({
          is_active: true,
          updated_at: new Date().toISOString(),
        })
        .eq("id", existing.id);
    } else {
      // Create new subscription
      await supabase.from("push_subscriptions").insert({
        profile_id: user.id,
        endpoint: subscription.endpoint,
        p256dh: subscription.keys.p256dh,
        auth: subscription.keys.auth,
        user_agent: request.headers.get("user-agent") || null,
        is_active: true,
      });
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Push subscription error:", error);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}

/**
 * DELETE /api/notifications/push
 * Unsubscribe from push notifications
 */
export async function DELETE(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const endpoint = searchParams.get("endpoint");

    if (endpoint) {
      // Deactivate specific subscription
      await supabase
        .from("push_subscriptions")
        .update({ is_active: false })
        .eq("endpoint", endpoint)
        .eq("profile_id", user.id);
    } else {
      // Deactivate all subscriptions for user
      await supabase
        .from("push_subscriptions")
        .update({ is_active: false })
        .eq("profile_id", user.id);
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Push unsubscribe error:", error);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}
