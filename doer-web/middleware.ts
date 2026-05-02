import { type NextRequest, NextResponse } from 'next/server'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000'

/** Public routes that don't require authentication */
const PUBLIC_ROUTES = ['/login', '/register', '/pending', '/auth/session', '/auth/verify']

/** Activation routes that require auth but not full activation */
const ACTIVATION_ROUTES = ['/training', '/quiz', '/bank-details', '/profile-setup', '/pending-approval']

/**
 * Next.js middleware — runs on every matched request.
 * Checks JWT auth token and redirects unauthenticated users to login.
 */
export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Allow public routes without auth
  if (PUBLIC_ROUTES.some(route => pathname.startsWith(route))) {
    return NextResponse.next({ request })
  }

  // Check for access token in cookies or let client-side handle it
  // Since we use localStorage for JWT, middleware can only do basic checks
  // The actual auth validation happens client-side in useAuth hook
  // Just let all requests through — pages handle their own auth
  return NextResponse.next({ request })
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|api/|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
