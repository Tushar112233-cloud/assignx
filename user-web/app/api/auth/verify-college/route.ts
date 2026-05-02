import { NextRequest, NextResponse } from "next/server";
import { extractToken, serverFetch } from "@/lib/api/server";

/**
 * POST /api/auth/verify-college
 *
 * Proxies the college email verification request to the Express API.
 * If the user is adding a college email to an existing account, the
 * Bearer token is forwarded for authentication.
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const token = extractToken(request);

    const { data, error, status } = await serverFetch<{
      success: boolean;
      message?: string;
    }>("/api/auth/verify-college", token, {
      method: "POST",
      body: JSON.stringify(body),
    });

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("[Verify College Proxy] Error:", err);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
