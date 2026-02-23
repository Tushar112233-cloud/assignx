import { NextResponse } from "next/server"
import { env } from "@/lib/env"

/**
 * GET /api/test-razorpay
 * Test endpoint to verify Razorpay credentials are loaded
 */
export async function GET() {
  try {
    // Check if credentials are loaded
    const hasKeyId = Boolean(env.RAZORPAY_KEY_ID)
    const hasKeySecret = Boolean(env.RAZORPAY_KEY_SECRET)
    const hasPublicKey = Boolean(env.NEXT_PUBLIC_RAZORPAY_KEY_ID)

    // Get key format (masked)
    const keyIdPrefix = env.RAZORPAY_KEY_ID?.substring(0, 12) + "..."
    const publicKeyPrefix = env.NEXT_PUBLIC_RAZORPAY_KEY_ID?.substring(0, 12) + "..."

    return NextResponse.json({
      status: "success",
      razorpay: {
        configured: hasKeyId && hasKeySecret && hasPublicKey,
        credentials: {
          RAZORPAY_KEY_ID: hasKeyId ? keyIdPrefix : "NOT SET",
          RAZORPAY_KEY_SECRET: hasKeySecret ? "SET (hidden)" : "NOT SET",
          NEXT_PUBLIC_RAZORPAY_KEY_ID: hasPublicKey ? publicKeyPrefix : "NOT SET",
        },
        isTestMode: env.RAZORPAY_KEY_ID?.startsWith("rzp_test_"),
      },
      timestamp: new Date().toISOString(),
    })
  } catch (error: any) {
    return NextResponse.json(
      {
        status: "error",
        message: error.message,
      },
      { status: 500 }
    )
  }
}
