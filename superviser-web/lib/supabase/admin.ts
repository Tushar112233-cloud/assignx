/**
 * @fileoverview Supabase admin client using service role key for bypassing RLS.
 * Use only in server actions where RLS bypass is necessary.
 * @module lib/supabase/admin
 */

import { createClient } from "@supabase/supabase-js"
import type { Database } from "@/types/database"

/**
 * Creates an admin Supabase client that bypasses RLS.
 * Only use in server actions where elevated permissions are required.
 */
export function createAdminClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Missing Supabase admin credentials")
  }

  return createClient<Database>(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  })
}
