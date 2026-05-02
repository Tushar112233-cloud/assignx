import { NextResponse } from 'next/server'

/**
 * POST /api/auth/logout
 * Clears auth session. With JWT-based auth, the client clears tokens from localStorage.
 */
export async function POST() {
  return NextResponse.json({ success: true })
}
