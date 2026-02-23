import { NextRequest, NextResponse } from "next/server"
import { createClient } from "@/lib/supabase/server"

/**
 * Push subscription data
 */
interface PushSubscription {
  endpoint: string
  expirationTime: number | null
  keys: {
    p256dh: string
    auth: string
  }
}

/**
 * Request body
 */
interface SubscribeRequest {
  subscription: PushSubscription
}

/**
 * POST /api/notifications/subscribe
 * Subscribe a device to push notifications
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient()

    // Verify user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      )
    }

    const body: SubscribeRequest = await request.json()
    const { subscription } = body

    if (!subscription?.endpoint || !subscription?.keys) {
      return NextResponse.json(
        { error: "Invalid subscription data" },
        { status: 400 }
      )
    }

    // Check if subscription already exists
    const { data: existing } = await supabase
      .from("push_subscriptions")
      .select("id")
      .eq("profile_id", user.id)
      .eq("endpoint", subscription.endpoint)
      .single()

    if (existing) {
      // Update existing subscription
      const { error: updateError } = await supabase
        .from("push_subscriptions")
        .update({
          p256dh_key: subscription.keys.p256dh,
          auth_key: subscription.keys.auth,
          expiration_time: subscription.expirationTime,
          updated_at: new Date().toISOString(),
        })
        .eq("id", existing.id)

      if (updateError) {
        console.error("Subscription update error:", updateError)
        return NextResponse.json(
          { error: "Failed to update subscription" },
          { status: 500 }
        )
      }

      return NextResponse.json({
        success: true,
        message: "Subscription updated",
      })
    }

    // Create new subscription
    const { error: insertError } = await supabase
      .from("push_subscriptions")
      .insert({
        profile_id: user.id,
        endpoint: subscription.endpoint,
        p256dh_key: subscription.keys.p256dh,
        auth_key: subscription.keys.auth,
        expiration_time: subscription.expirationTime,
        user_agent: request.headers.get("user-agent"),
      })

    if (insertError) {
      console.error("Subscription insert error:", insertError)
      return NextResponse.json(
        { error: "Failed to save subscription" },
        { status: 500 }
      )
    }

    // Log activity
    await supabase.from("activity_logs").insert({
      profile_id: user.id,
      action: "push_subscribed",
      action_category: "notification",
      description: "Subscribed to push notifications",
      metadata: {
        endpoint: subscription.endpoint.substring(0, 50),
      },
      source_role: "user",
    })

    return NextResponse.json({
      success: true,
      message: "Subscription saved",
    })
  } catch (error) {
    console.error("Subscribe error:", error)
    return NextResponse.json(
      { error: "Failed to subscribe" },
      { status: 500 }
    )
  }
}

/**
 * DELETE /api/notifications/subscribe
 * Unsubscribe a device from push notifications
 */
export async function DELETE(request: NextRequest) {
  try {
    const supabase = await createClient()

    // Verify user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      )
    }

    const { endpoint } = await request.json()

    if (!endpoint) {
      return NextResponse.json(
        { error: "Endpoint required" },
        { status: 400 }
      )
    }

    // Delete subscription
    const { error: deleteError } = await supabase
      .from("push_subscriptions")
      .delete()
      .eq("profile_id", user.id)
      .eq("endpoint", endpoint)

    if (deleteError) {
      console.error("Subscription delete error:", deleteError)
      return NextResponse.json(
        { error: "Failed to unsubscribe" },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      message: "Unsubscribed successfully",
    })
  } catch (error) {
    console.error("Unsubscribe error:", error)
    return NextResponse.json(
      { error: "Failed to unsubscribe" },
      { status: 500 }
    )
  }
}
