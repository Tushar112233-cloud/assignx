import { NextRequest, NextResponse } from "next/server"
import crypto from "crypto"
import { createClientFromRequest } from "@/lib/supabase/server"
import {
  paymentRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit"
import { validateOriginOnly, csrfError } from "@/lib/csrf"
import { env } from "@/lib/env"

/**
 * Request body type
 */
interface PartialPaymentRequest {
  razorpay_order_id: string
  razorpay_payment_id: string
  razorpay_signature: string
  profile_id: string
  project_id: string
  total_amount: number // Total project amount in rupees
  wallet_amount: number // Amount to deduct from wallet in rupees
  razorpay_amount: number // Amount charged via Razorpay in rupees
}

/**
 * Constant-time string comparison to prevent timing attacks
 */
function secureCompare(a: string, b: string): boolean {
  if (!a || !b) return false
  if (a.length !== b.length) return false
  try {
    return crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b))
  } catch {
    return false
  }
}

/**
 * POST /api/payments/partial-pay
 * Processes partial payment: wallet balance + Razorpay
 * Uses atomic database transaction to ensure both payments succeed together
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
      console.error("[Partial Pay] Auth error:", authError?.message || "No user")
      return NextResponse.json(
        { error: "Unauthorized - please login again" },
        { status: 401 }
      )
    }

    // CSRF protection
    const originCheck = validateOriginOnly(request)
    if (!originCheck.valid) {
      const origin = request.headers.get("origin") || "none"
      const referer = request.headers.get("referer") || "none"
      console.warn(`[Partial Pay] CSRF rejected - user: ${user.id}, origin: ${origin}, referer: ${referer}`)
      return csrfError(originCheck.error)
    }

    // Apply rate limiting
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

    const body: PartialPaymentRequest = await request.json()

    // SECURITY: Verify profile ownership
    if (user.id !== body.profile_id) {
      console.warn(
        `IDOR attempt detected: User ${user.id} tried to access profile ${body.profile_id}`
      )
      return NextResponse.json(
        { error: "Unauthorized: Profile ID mismatch" },
        { status: 403 }
      )
    }

    // Validate required fields
    if (!body.razorpay_order_id || !body.razorpay_payment_id || !body.razorpay_signature) {
      return NextResponse.json(
        { error: "Missing required payment fields" },
        { status: 400 }
      )
    }

    if (!body.project_id) {
      return NextResponse.json(
        { error: "Project ID is required" },
        { status: 400 }
      )
    }

    // Validate amounts
    if (body.total_amount <= 0 || body.wallet_amount < 0 || body.razorpay_amount < 0) {
      return NextResponse.json(
        { error: "Invalid payment amounts" },
        { status: 400 }
      )
    }

    const expectedTotal = body.wallet_amount + body.razorpay_amount
    if (Math.abs(expectedTotal - body.total_amount) > 0.01) {
      return NextResponse.json(
        { error: "Payment amounts do not match total" },
        { status: 400 }
      )
    }

    // Validate Razorpay credentials are configured
    if (!env.RAZORPAY_KEY_SECRET) {
      console.error("[Partial Pay] RAZORPAY_KEY_SECRET not configured")
      return NextResponse.json(
        { error: "Payment gateway not configured. Please contact support." },
        { status: 503 }
      )
    }

    // Verify Razorpay signature
    const expectedSignature = crypto
      .createHmac("sha256", env.RAZORPAY_KEY_SECRET)
      .update(`${body.razorpay_order_id}|${body.razorpay_payment_id}`)
      .digest("hex")

    if (!secureCompare(expectedSignature, body.razorpay_signature)) {
      return NextResponse.json(
        { error: "Invalid payment signature" },
        { status: 400 }
      )
    }

    // Process partial payment atomically
    const { data, error } = await supabase.rpc("process_partial_project_payment", {
      p_profile_id: body.profile_id,
      p_project_id: body.project_id,
      p_total_amount: body.total_amount,
      p_wallet_amount: body.wallet_amount,
      p_razorpay_amount: body.razorpay_amount,
      p_razorpay_order_id: body.razorpay_order_id,
      p_razorpay_payment_id: body.razorpay_payment_id,
    })

    if (error) {
      console.error("Partial payment error:", error)
      return NextResponse.json(
        { error: error.message || "Failed to process partial payment" },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      project_id: data.project_id,
      wallet_amount: data.wallet_amount,
      razorpay_amount: data.razorpay_amount,
      total_amount: data.total_amount,
      new_balance: data.new_balance,
      payment_method: "partial",
      message: "Payment successful",
    })
  } catch (error: any) {
    console.error("[Partial Pay] Error:", error?.message || error)
    console.error("[Partial Pay] Stack:", error?.stack)
    return NextResponse.json(
      { error: error?.message || "Failed to process payment. Please contact support." },
      { status: 500 }
    )
  }
}
