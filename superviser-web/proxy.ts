import { type NextRequest, NextResponse } from "next/server"

/**
 * JWT-based middleware proxy.
 * Validates the supervisor_token cookie on protected routes.
 * Redirects unauthenticated requests to /login.
 */
export async function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Public routes that don't require authentication
  const publicRoutes = ["/login", "/register", "/auth", "/api/auth"]
  const isPublicRoute = pathname === "/" || publicRoutes.some((route) => pathname.startsWith(route))

  if (isPublicRoute) {
    return NextResponse.next()
  }

  // Check for JWT token in cookies
  const token = request.cookies.get("supervisor_token")?.value

  if (!token && !pathname.startsWith("/_next") && !pathname.startsWith("/favicon")) {
    const loginUrl = new URL("/login", request.url)
    loginUrl.searchParams.set("redirect", pathname)
    return NextResponse.redirect(loginUrl)
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
}
