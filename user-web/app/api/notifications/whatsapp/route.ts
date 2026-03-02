import { NextRequest, NextResponse } from "next/server";
import { extractToken, serverFetch } from "@/lib/api/server";

/**
 * POST /api/notifications/whatsapp
 * Send WhatsApp notification to user via Express API.
 */
export async function POST(request: NextRequest) {
  try {
    const token = extractToken(request);
    const apiKey = request.headers.get("x-api-key");

    // Allow either user token or server-to-server API key
    const headers: Record<string, string> = {};
    if (apiKey) {
      headers["x-api-key"] = apiKey;
    }

    const body = await request.json();

    const { data, error, status } = await serverFetch(
      "/api/notifications/whatsapp",
      token,
      {
        method: "POST",
        body: JSON.stringify(body),
        headers,
      }
    );

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("WhatsApp notification error:", err);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}
