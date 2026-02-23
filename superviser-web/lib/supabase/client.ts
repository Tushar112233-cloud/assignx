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
 * DevTools masks this because it disables bfcache and "Disable cache" bypasses
 * HTTP cache. Without DevTools, the lock deadlocks and nothing loads.
 *
 * Fix: pass a no-op lock function to bypass navigator.locks entirely.
 * Trade-off: multiple tabs may do redundant token refreshes (harmless).
 *
 * References:
 * - https://github.com/supabase/supabase-js/issues/1594
 * - https://github.com/supabase/supabase-js/issues/2013
 * - https://github.com/supabase/gotrue-js/issues/762
 * - https://supabase.com/docs/guides/troubleshooting/why-is-my-supabase-api-call-not-returning-PGzXw0
 *
 * Auth strategy: localStorage-first.
 * - On login: user object is saved to localStorage immediately.
 * - On page reload: getAuthUser() reads from localStorage (synchronous, instant).
 * - On logout: localStorage is cleared via clearAppStorage() and resetClient().
 */

import { createBrowserClient } from "@supabase/ssr"
import type { Database } from "@/types/database"
import type { User } from "@supabase/supabase-js"

let clientInstance: ReturnType<typeof createBrowserClient<Database>> | null = null

const AUTH_USER_KEY = "supervisor_auth_user"

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

export function createClient() {
  if (clientInstance) {
    return clientInstance
  }

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!url || !key) {
    throw new Error("Missing Supabase environment variables")
  }

  clientInstance = createBrowserClient<Database>(url, key, {
    auth: {
      lock: noOpLock as any,
    },
    global: {
      fetch: (input: RequestInfo | URL, init?: RequestInit) => {
        return fetch(input, {
          ...init,
          cache: 'no-store', // Prevent Chrome from caching PostgREST responses
        })
      },
    },
  })
  return clientInstance
}

/**
 * Get the authenticated user — synchronous read from localStorage.
 * Returns instantly, never hangs, no locks.
 */
export async function getAuthUser(): Promise<User | null> {
  try {
    const stored = localStorage.getItem(AUTH_USER_KEY)
    if (stored) return JSON.parse(stored) as User
  } catch {
    // localStorage unavailable or corrupted
  }
  return null
}

/**
 * Save user to localStorage. Called on sign-in and auth state changes.
 */
export function storeAuthUser(user: User): void {
  try {
    localStorage.setItem(AUTH_USER_KEY, JSON.stringify(user))
  } catch {
    // localStorage might be full or disabled
  }
}

/**
 * Remove user from localStorage. Called on sign-out.
 */
export function clearAuthUser(): void {
  try {
    localStorage.removeItem(AUTH_USER_KEY)
  } catch {
    // ignore
  }
}

/**
 * Reset the singleton client instance and user cache.
 * Must be called on logout to prevent stale auth state.
 */
export function resetClient(): void {
  clientInstance = null
  clearAuthUser()
}

/**
 * Get the authenticated user from the Supabase session, falling back to localStorage.
 * The Supabase session (cookies) is the source of truth — localStorage is a fast cache.
 * With the noOpLock hack in place, getSession() won't deadlock.
 *
 * This should be used by all data-fetching hooks instead of getAuthUser() directly,
 * because getAuthUser() can return stale data when the session has expired.
 */
export async function getSessionUser(): Promise<User | null> {
  const supabase = createClient()

  // Try the Supabase session first (validates token, refreshes if needed)
  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user) {
      // Keep localStorage in sync
      storeAuthUser(session.user)
      return session.user
    }
  } catch {
    // Session fetch failed — fall back to localStorage
  }

  // Fall back to localStorage cache
  return getAuthUser()
}
