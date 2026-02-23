/**
 * @fileoverview Supabase client factory for browser-side authentication and data access.
 * @module lib/supabase/client
 *
 * CRITICAL FIX: navigator.locks deadlock
 * ----------------------------------------
 * Every .from('table').select() call chains through:
 *   fetchWithAuth → _getAccessToken() → auth.getSession() → _acquireLock(-1) → navigator.locks.request()
 *
 * The -1 timeout = INFINITE wait. When navigator.locks gets stuck (HMR, bfcache,
 * lock contention), ALL data queries hang forever — not just auth calls.
 *
 * Fix: pass a no-op lock function to bypass navigator.locks entirely.
 * Trade-off: multiple tabs may do redundant token refreshes (harmless).
 *
 * References:
 * - https://github.com/supabase/supabase-js/issues/1594
 * - https://github.com/supabase/supabase-js/issues/2013
 * - https://github.com/supabase/gotrue-js/issues/762
 */

import { createBrowserClient } from '@supabase/ssr'
import type { SupabaseClient } from '@supabase/supabase-js'

let _client: SupabaseClient | null = null

/**
 * No-op lock that bypasses navigator.locks entirely.
 * Prevents the deadlock caused by GoTrueClient's infinite-timeout
 * lock acquisition via navigator.locks.request().
 */
const noOpLock = async <R>(
  _name: string,
  _acquireTimeout: number,
  fn: () => Promise<R>
): Promise<R> => {
  return await fn()
}

/**
 * Returns a singleton Supabase browser client.
 * Includes navigator.locks bypass and cache-busting to prevent
 * Chrome from caching PostgREST responses.
 */
export function createClient(): SupabaseClient {
  if (_client) return _client

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error('Missing Supabase environment variables: NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY must be set')
  }

  _client = createBrowserClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      lock: noOpLock as any,
    },
    global: {
      fetch: (input: RequestInfo | URL, init?: RequestInit) => {
        return fetch(input, {
          ...init,
          cache: 'no-store',
        })
      },
    },
  })

  return _client
}
