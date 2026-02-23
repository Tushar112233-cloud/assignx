import { type NextRequest, NextResponse } from 'next/server'
import { updateSession } from './lib/supabase/middleware'

/**
 * Next.js middleware — runs on every matched request.
 * Refreshes Supabase auth cookies so that server components and
 * browser clients always have fresh JWT tokens.
 *
 * CRITICAL: This file MUST be named middleware.ts and export a function
 * named middleware() for Next.js to recognize it.
 *
 * Includes a 10-second timeout so that slow Supabase Auth responses
 * don't hang the entire page load.
 */
export async function middleware(request: NextRequest) {
  try {
    // Race the session update against a 10s timeout.
    // If Supabase Auth is slow, let the request through so pages can handle it.
    const result = await Promise.race([
      updateSession(request),
      new Promise<'timeout'>((resolve) => setTimeout(() => resolve('timeout'), 10000)),
    ])

    if (result === 'timeout') {
      console.warn('[Middleware] updateSession timed out after 10s — letting request through')
      return NextResponse.next({ request })
    }

    return result
  } catch {
    // If session update fails, let the request through anyway.
    // Individual pages will handle auth failures with redirects.
    return NextResponse.next({
      request,
    })
  }
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|api/|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
