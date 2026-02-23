import { createBrowserClient } from "@supabase/ssr";

/**
 * Creates a Supabase client for use in the browser (Client Components).
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
 */

let _client: ReturnType<typeof createBrowserClient> | null = null;

const noOpLock = async <R>(
  _name: string,
  _acquireTimeout: number,
  fn: () => Promise<R>
): Promise<R> => {
  return await fn();
};

export function createClient() {
  if (_client) return _client;

  _client = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      auth: {
        lock: noOpLock as any,
      },
      global: {
        fetch: (input: RequestInfo | URL, init?: RequestInit) => {
          return fetch(input, {
            ...init,
            cache: "no-store",
          });
        },
      },
    }
  );
  return _client;
}
