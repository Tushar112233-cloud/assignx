import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

/**
 * Custom fetch with 10-second timeout.
 * Prevents server-side Supabase calls (auth, queries) from hanging indefinitely
 * when the Supabase Auth server is slow or unreachable.
 */
function fetchWithTimeout(url: RequestInfo | URL, options?: RequestInit): Promise<Response> {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 10000)

  // Combine caller's signal with timeout signal so both are respected
  const signal = options?.signal && typeof AbortSignal.any === 'function'
    ? AbortSignal.any([options.signal, controller.signal])
    : options?.signal || controller.signal

  return fetch(url, {
    ...options,
    signal,
  }).finally(() => clearTimeout(timeout))
}

/**
 * Creates a Supabase client for server-side usage
 * @returns Supabase server client instance
 */
export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing
            // user sessions.
          }
        },
      },
      global: {
        fetch: fetchWithTimeout,
      },
    }
  )
}
