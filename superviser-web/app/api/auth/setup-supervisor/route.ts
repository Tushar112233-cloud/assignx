/**
 * @fileoverview Deprecated setup-supervisor route.
 * Supervisor records are now created automatically on admin approval.
 * Returns 410 Gone for any remaining callers.
 * @module app/api/auth/setup-supervisor/route
 */

import { NextResponse } from "next/server"

export async function POST() {
  return NextResponse.json(
    { error: "This endpoint has been deprecated. Supervisor records are created on admin approval." },
    { status: 410 }
  )
}
