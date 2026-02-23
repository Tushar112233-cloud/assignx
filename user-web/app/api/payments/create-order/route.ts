import { NextRequest, NextResponse } from "next/server"
import Razorpay from "razorpay"
import { createClientFromRequest } from "@/lib/supabase/server"
import {
  paymentRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit"
import { validateOriginOnly, csrfError } from "@/lib/csrf"
import { env } from "@/lib/env"

/**
 * Get or create Razorpay instance lazily
 */
let razorpayInstance: Razorpay | null = null

function getRazorpay(): Razorpay {
  if (!razorpayInstance) {
    // Use validated environment variables
    razorpayInstance = new Razorpay({
      key_id: env.RAZORPAY_KEY_ID,
      key_secret: env.RAZORPAY_KEY_SECRET,
    })
  }
  return razorpayInstance
}

/**
 * Request body type
 */
interface CreateOrderRequest {
  amount: number // Amount in paise
  currency: string
  receipt: string
  notes?: {
    type: "wallet_topup" | "project_payment"
    profile_id?: string
    project_id?: string
  }
}

/**
 * POST /api/payments/create-order
 * Creates a Razorpay order for payment
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClientFromRequest(request)

    // Verify user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      console.error("[Create Order] Auth error:", authError?.message || "No user")
      return NextResponse.json(
        { error: "Unauthorized - please login again" },
        { status: 401 }
      )
    }

    // CSRF protection: Validate request origin
    const originCheck = validateOriginOnly(request)
    if (!originCheck.valid) {
      const origin = request.headers.get("origin") || "none"
      const referer = request.headers.get("referer") || "none"
      console.warn(`[Create Order] CSRF rejected - user: ${user.id}, origin: ${origin}, referer: ${referer}`)
      return csrfError(originCheck.error)
    }

    // Apply rate limiting (5 requests per minute for payment endpoints)
    const clientId = getClientIdentifier(user.id, request)
    const rateLimitResult = await paymentRateLimiter.check(5, clientId)

    if (!rateLimitResult.success) {
      return NextResponse.json(
        { error: "Too many payment requests. Please try again later." },
        {
          status: 429,
          headers: rateLimitHeaders(rateLimitResult),
        }
      )
    }

    const body: CreateOrderRequest = await request.json()

    // Validate request
    if (!body.amount || body.amount < 100) {
      return NextResponse.json(
        { error: "Amount must be at least ₹1 (100 paise)" },
        { status: 400 }
      )
    }

    // Ensure amount is an integer (Razorpay requirement)
    const amountInPaise = Math.round(body.amount)

    // Convert notes to string values (Razorpay requirement)
    const notes: Record<string, string> = {}
    if (body.notes) {
      if (body.notes.type) notes.type = String(body.notes.type)
      if (body.notes.profile_id) notes.profile_id = String(body.notes.profile_id)
      if (body.notes.project_id) notes.project_id = String(body.notes.project_id)
    }

    // Validate Razorpay credentials are configured
    if (!env.RAZORPAY_KEY_ID || !env.RAZORPAY_KEY_SECRET) {
      console.error("[Create Order] Razorpay credentials not configured. Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in .env.local")
      return NextResponse.json(
        { error: "Payment gateway not configured. Please contact support." },
        { status: 503 }
      )
    }

    // Build order payload
    const orderPayload = {
      amount: amountInPaise,
      currency: body.currency || "INR",
      receipt: body.receipt || `order_${Date.now()}`,
      notes: Object.keys(notes).length > 0 ? notes : undefined,
    }

    console.log("[Create Order] Creating Razorpay order with payload:", JSON.stringify(orderPayload))
    console.log("[Create Order] Using key_id:", env.RAZORPAY_KEY_ID.substring(0, 15) + "...")

    // Create Razorpay order
    const razorpay = getRazorpay()
    const order = await razorpay.orders.create(orderPayload)

    // Log order creation
    await supabase.from("activity_logs").insert({
      profile_id: user.id,
      action: "payment_order_created",
      action_category: "payment",
      description: `Created payment order: ${order.id}`,
      metadata: {
        order_id: order.id,
        amount: body.amount,
        type: body.notes?.type,
      },
      source_role: "user",
    })

    return NextResponse.json({
      id: order.id,
      amount: order.amount,
      currency: order.currency,
      receipt: order.receipt,
    })
  } catch (error: any) {
    // Log full error details for debugging
    console.error("[Create Order] Error:", JSON.stringify(error, null, 2))
    console.error("[Create Order] Error message:", error?.message)
    console.error("[Create Order] Error description:", error?.error?.description)
    console.error("[Create Order] Stack:", error?.stack)

    // Extract Razorpay-specific error message
    const razorpayError = error?.error?.description || error?.description
    const errorMessage = razorpayError || error?.message || "Failed to create order"

    // Check for common Razorpay errors
    if (error?.statusCode === 400 || error?.error?.code) {
      return NextResponse.json(
        { error: `Razorpay error: ${errorMessage}` },
        { status: 400 }
      )
    }

    return NextResponse.json(
      { error: errorMessage },
      { status: 500 }
    )
  }
}
