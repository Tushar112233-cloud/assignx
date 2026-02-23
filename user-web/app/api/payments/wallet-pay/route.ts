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
interface WalletPayRequest {
  profile_id: string
  project_id: string
  amount: number // Amount in rupees
}

/**
 * POST /api/payments/wallet-pay
 * Pays for a project using wallet balance
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

    const body: WalletPayRequest = await request.json()

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
    if (!body.project_id) {
      return NextResponse.json(
        { error: "Project ID is required" },
        { status: 400 }
      )
    }

    if (!body.amount || body.amount <= 0) {
      return NextResponse.json(
        { error: "Invalid amount" },
        { status: 400 }
      )
    }

    // Process wallet payment atomically using RPC
    // This ensures all operations succeed or fail together
    const { data, error } = await supabase.rpc("process_wallet_project_payment", {
      p_profile_id: body.profile_id,
      p_project_id: body.project_id,
      p_amount: body.amount,
    })

    if (error) {
      console.error("Atomic wallet payment error:", error)

      // Parse specific error messages for better user feedback
      const errorMessage = error.message || "Failed to process payment"

      if (errorMessage.includes("Insufficient balance")) {
        return NextResponse.json(
          { error: "Insufficient wallet balance" },
          { status: 400 }
        )
      }

      if (errorMessage.includes("already paid")) {
        return NextResponse.json(
          { error: "Project is already paid" },
          { status: 400 }
        )
      }

      if (errorMessage.includes("not found")) {
        return NextResponse.json(
          { error: "Wallet or project not found" },
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
      new_balance: data.new_balance,
      project_id: data.project_id,
      message: "Payment successful",
    })
  } catch (error) {
    console.error("Wallet pay error:", error)
    return NextResponse.json(
      { error: "Failed to process payment" },
      { status: 500 }
    )
  }
}
