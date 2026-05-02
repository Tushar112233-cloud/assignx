import { NextRequest, NextResponse } from "next/server";
import { extractToken, serverFetch } from "@/lib/api/server";
import {
  paymentRateLimiter,
  getClientIdentifier,
  rateLimitHeaders,
} from "@/lib/rate-limit";
import { validateOriginOnly, csrfError } from "@/lib/csrf";

/**
 * POST /api/payments/send-money
 * Proxies wallet-to-wallet transfer to the Express API.
 */
export async function POST(request: NextRequest) {
  try {
    const token = extractToken(request);
    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
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
      "/api/wallets/transfer",
      token,
      { method: "POST", body: JSON.stringify(body) }
    );

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("Send money error:", err);
    return NextResponse.json(
      { error: "Failed to process transfer" },
      { status: 500 }
    );
  }
}
