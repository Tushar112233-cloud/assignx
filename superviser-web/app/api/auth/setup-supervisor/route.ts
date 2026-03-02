/**
 * @fileoverview Server API route to auto-create supervisor record from approved
 * email_access_requests metadata. Called after auth when no supervisor record exists.
 * Now proxies to the Express API.
 * @module app/api/auth/setup-supervisor/route
 */

import { NextRequest, NextResponse } from "next/server"

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

export async function POST(request: NextRequest) {
  try {
    // Get JWT from Authorization header or cookie
    const authHeader = request.headers.get("Authorization")
    const token = authHeader?.replace("Bearer ", "") || request.cookies.get("supervisor_token")?.value

    if (!token) {
      return NextResponse.json({ error: "Not authenticated" }, { status: 401 })
    }

    // Proxy to Express API
    const res = await fetch(`${API_BASE}/api/auth/setup-supervisor`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
    })

    const data = await res.json().catch(() => ({}))

    if (!res.ok) {
      return NextResponse.json(
        { error: data.error || "Failed to setup supervisor" },
        { status: res.status }
      )
    }

    return NextResponse.json(data)
  } catch (err) {
    console.error("Setup supervisor error:", err)
    return NextResponse.json(
      { error: "Internal server error", details: String(err) },
      { status: 500 }
    )
  }
}
