import { NextRequest, NextResponse } from "next/server";
import { extractToken, serverFetch } from "@/lib/api/server";

/**
 * POST /api/notifications/subscribe
 * Subscribe a device to push notifications via Express API.
 */
export async function POST(request: NextRequest) {
  try {
    const token = extractToken(request);
    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await request.json();

    const { data, error, status } = await serverFetch(
      "/api/notifications/subscribe",
      token,
      { method: "POST", body: JSON.stringify(body) }
    );

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("Subscribe error:", err);
    return NextResponse.json(
      { error: "Failed to subscribe" },
      { status: 500 }
    );
  }
}

/**
 * DELETE /api/notifications/subscribe
 * Unsubscribe a device from push notifications.
 */
export async function DELETE(request: NextRequest) {
  try {
    const token = extractToken(request);
    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await request.json();

    const { data, error, status } = await serverFetch(
      "/api/notifications/subscribe",
      token,
      { method: "DELETE", body: JSON.stringify(body) }
    );

    if (error) {
      return NextResponse.json({ error }, { status });
    }

    return NextResponse.json(data);
  } catch (err) {
    console.error("Unsubscribe error:", err);
    return NextResponse.json(
      { error: "Failed to unsubscribe" },
      { status: 500 }
    );
  }
}
