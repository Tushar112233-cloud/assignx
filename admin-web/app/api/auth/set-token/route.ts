import { NextRequest, NextResponse } from "next/server";

/**
 * POST /api/auth/set-token
 * Sets the admin-token cookie from the client-side login.
 * This bridges client-side localStorage tokens to server-side cookie-based auth.
 */
export async function POST(request: NextRequest) {
  try {
    const { accessToken, refreshToken } = await request.json();

    if (!accessToken) {
      return NextResponse.json({ error: "No token provided" }, { status: 400 });
    }

    const response = NextResponse.json({ success: true });

    // Set httpOnly cookie for server-side auth
    response.cookies.set("admin-token", accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: 60 * 60 * 24 * 7, // 7 days
    });

    if (refreshToken) {
      response.cookies.set("admin-refresh-token", refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "lax",
        path: "/",
        maxAge: 60 * 60 * 24 * 30, // 30 days
      });
    }

    return response;
  } catch {
    return NextResponse.json({ error: "Invalid request" }, { status: 400 });
  }
}

/**
 * DELETE /api/auth/set-token
 * Clears the admin-token cookie on logout.
 */
export async function DELETE() {
  const response = NextResponse.json({ success: true });
  response.cookies.delete("admin-token");
  response.cookies.delete("admin-refresh-token");
  return response;
}
