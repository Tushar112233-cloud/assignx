import { NextRequest, NextResponse } from "next/server";
import { serverFetch } from "@/lib/api/server";

/**
 * POST /api/auth/magic-link
 *
 * Proxies the magic-link request to the Express API.
 * The Express server handles email validation, rate limiting,
 * and sending the magic link email.
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    const { data, error, status } = await serverFetch<{
      success: boolean;
      message?: string;
      expiresIn?: number;
    }>("/api/auth/magic-link", null, {
      method: "POST",
      body: JSON.stringify(body),
    });

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("[Magic Link Proxy] Error:", err);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
