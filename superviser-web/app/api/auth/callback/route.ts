/**
 * @fileoverview API route handler for auth callback.
 * Handles token_hash and code flows by redirecting to the client-side confirm page.
 * @module app/api/auth/callback/route
 */

import { NextResponse } from "next/server"

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get("code")
  const token = searchParams.get("token") || searchParams.get("token_hash")

  // Redirect to client-side confirm page with the token/code
  if (token) {
    return NextResponse.redirect(`${origin}/auth/confirm?token=${encodeURIComponent(token)}`)
  }

  if (code) {
    return NextResponse.redirect(`${origin}/auth/confirm?code=${encodeURIComponent(code)}`)
  }

  return NextResponse.redirect(`${origin}/login?error=auth`)
}
