import { NextRequest, NextResponse } from "next/server";
import { extractToken, serverFetch } from "@/lib/api/server";

/**
 * POST /api/notifications/push
 * Send push notification to user via Express API.
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
      "/api/notifications/push",
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
    console.error("Push notification error:", err);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}

/**
 * PUT /api/notifications/push
 * Subscribe to push notifications via Express API.
 */
export async function PUT(request: NextRequest) {
  try {
    const token = extractToken(request);
    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await request.json();

    const { data, error, status } = await serverFetch(
      "/api/notifications/push",
      token,
      { method: "PUT", body: JSON.stringify(body) }
    );

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("Push subscription error:", err);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}

/**
 * DELETE /api/notifications/push
 * Unsubscribe from push notifications via Express API.
 */
export async function DELETE(request: NextRequest) {
  try {
    const token = extractToken(request);
    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const endpoint = searchParams.get("endpoint");
    const queryString = endpoint ? `?endpoint=${encodeURIComponent(endpoint)}` : "";

    const { data, error, status } = await serverFetch(
      `/api/notifications/push${queryString}`,
      token,
      { method: "DELETE" }
    );

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("Push unsubscribe error:", err);
    return NextResponse.json(
      { success: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}
