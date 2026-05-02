/**
 * @fileoverview Server-side logout route.
 * Clears auth cookies and invalidates the session via API.
 * @module app/api/auth/logout/route
 */

import { NextRequest, NextResponse } from "next/server"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

export async function POST(request: NextRequest) {
  const token = request.cookies.get("supervisor_token")?.value

  // Notify the API to invalidate the session (best effort)
  if (token) {
    await fetch(`${API_BASE}/api/auth/logout`, {
      method: "POST",
      headers: { Authorization: `Bearer ${token}` },
    }).catch(() => {})
  }

  // Clear the server-side cookie
  const response = NextResponse.json({ success: true })
  response.cookies.set("supervisor_token", "", { maxAge: 0, path: "/" })

  return response
}
