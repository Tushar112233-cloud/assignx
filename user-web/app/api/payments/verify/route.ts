import { NextRequest, NextResponse } from "next/server";
import { extractToken, serverFetch } from "@/lib/api/server";
import {
  paymentRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit";
import { validateOriginOnly, csrfError } from "@/lib/csrf";

/**
 * POST /api/payments/verify
 * Proxies Razorpay payment verification to the Express API.
 */
export async function POST(request: NextRequest) {
  try {
    const token = extractToken(request);
    if (!token) {
      return NextResponse.json(
        { error: "Unauthorized - please login again" },
        { status: 401 }
      );
    }

    // CSRF protection
    const originCheck = validateOriginOnly(request);
    if (!originCheck.valid) {
      return csrfError(originCheck.error);
    }

    // Rate limiting
    const clientId = getClientIdentifier("user", request);
    const rateLimitResult = await paymentRateLimiter.check(5, clientId);
    if (!rateLimitResult.success) {
      return NextResponse.json(
        { error: "Too many payment requests. Please try again later." },
        { status: 429, headers: rateLimitHeaders(rateLimitResult) }
      );
    }

    const body = await request.json();

    const { data, error, status } = await serverFetch(
      "/api/payments/verify",
      token,
      { method: "POST", body: JSON.stringify(body) }
    );

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Failed to verify payment";
    console.error("[Verify Payment] Error:", message);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
