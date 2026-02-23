/**
 * @fileoverview Server-side logout route.
 * Clears Supabase auth cookies using the server client.
 * Must be called on logout so the server-side session is invalidated,
 * not just the browser-side cookies.
 * @module app/api/auth/logout/route
 */

import { NextResponse } from "next/server"
import { createClient } from "@/lib/supabase/server"

export async function POST() {
  const supabase = await createClient()
  await supabase.auth.signOut()
  return NextResponse.json({ success: true })
}
