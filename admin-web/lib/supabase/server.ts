import { createServerClient } from "@supabase/ssr";
import { createClient as createJsClient } from "@supabase/supabase-js";
import { cookies } from "next/headers";
import { NextRequest } from "next/server";

/**
 * Creates an admin Supabase client that bypasses Row Level Security
 * Uses the service role key - ONLY use for server-side operations
 * where RLS bypass is necessary (e.g., dev mode without auth)
 * @returns Supabase admin client instance or null if service role key is not configured
 */
export function createAdminClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!serviceRoleKey) {
    console.error("[createAdminClient] SUPABASE_SERVICE_ROLE_KEY is not configured");
    return null;
  }

  return createJsClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    serviceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
}

/**
 * Creates a Supabase client for use in Server Components, Server Actions, and Route Handlers
 * Uses cookie-based authentication (for web app)
 * @returns Supabase server client instance
 */
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing user sessions.
          }
        },
      },
    }
  );
}

/**
 * Creates a Supabase client from a request's Authorization header
 * Used for API routes that receive requests from mobile apps
 * Falls back to cookie-based auth if no Authorization header is present
 * @param request - NextRequest object
 * @returns Supabase client instance with auth context
 */
export async function createClientFromRequest(request: NextRequest) {
  const authHeader = request.headers.get("authorization");

  // If Authorization header is present, use token-based auth
  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.substring(7);

    // Create a client with the access token
    const supabase = createJsClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        global: {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        },
      }
    );

    return supabase;
  }

  // Fall back to cookie-based auth for web requests
  return createClient();
}
