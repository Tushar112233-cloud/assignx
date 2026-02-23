import { NextRequest, NextResponse } from "next/server"
import { createClient } from "@/lib/supabase/server"
import {
  paymentRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit"
import { validateOriginOnly, csrfError } from "@/lib/csrf"

/**
 * Request body type
 */
interface SendMoneyRequest {
  profile_id: string
  recipient_email: string
  amount: number
  note?: string
}

/**
 * POST /api/payments/send-money
 * Sends money from authenticated user's wallet to another user's wallet
 * Uses atomic database transaction to prevent race conditions
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

    // CSRF protection: Validate request origin
    const originCheck = validateOriginOnly(request)
    if (!originCheck.valid) {
      console.warn(`CSRF attempt detected from user ${user.id}`)
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

    const body: SendMoneyRequest = await request.json()

    // SECURITY: Verify user owns the profile to prevent IDOR attacks
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
    if (!body.recipient_email || !body.recipient_email.includes("@")) {
      return NextResponse.json(
        { error: "Valid recipient email is required" },
        { status: 400 }
      )
    }

    if (!body.amount || body.amount < 1) {
      return NextResponse.json(
        { error: "Minimum transfer amount is ₹1" },
        { status: 400 }
      )
    }

    if (body.amount > 50000) {
      return NextResponse.json(
        { error: "Maximum transfer amount is ₹50,000" },
        { status: 400 }
      )
    }

    // Process wallet transfer atomically using RPC
    const { data, error } = await supabase.rpc("process_wallet_transfer", {
      p_sender_profile_id: body.profile_id,
      p_recipient_email: body.recipient_email.trim().toLowerCase(),
      p_amount: body.amount,
      p_note: body.note || null,
    })

    if (error) {
      console.error("Wallet transfer error:", error)

      const errorMessage = error.message || "Failed to process transfer"

      if (errorMessage.includes("Insufficient balance")) {
        return NextResponse.json(
          { error: "Insufficient wallet balance" },
          { status: 400 }
        )
      }

      if (errorMessage.includes("Recipient not found")) {
        return NextResponse.json(
          { error: "Recipient not found. They may not have an account." },
          { status: 404 }
        )
      }

      if (errorMessage.includes("Cannot send money to yourself")) {
        return NextResponse.json(
          { error: "You cannot send money to yourself" },
          { status: 400 }
        )
      }

      if (errorMessage.includes("wallet not found")) {
        return NextResponse.json(
          { error: "Wallet not found" },
          { status: 404 }
        )
      }

      return NextResponse.json(
        { error: errorMessage },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      transaction_id: data.transaction_id,
      transfer_ref: data.transfer_ref,
      new_balance: data.new_balance,
      recipient_name: data.recipient_name,
      amount: data.amount,
      message: "Transfer successful",
    })
  } catch (error) {
    console.error("Send money error:", error)
    return NextResponse.json(
      { error: "Failed to process transfer" },
      { status: 500 }
    )
  }
}
