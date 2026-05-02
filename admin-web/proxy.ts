import { type NextRequest, NextResponse } from "next/server";

const publicPaths = ["/login", "/api/auth"];

/**
 * Proxy that runs on every request to check auth cookie presence.
 * Only checks cookie — actual token validation happens in verifyAdmin().
 * This prevents session loss during HMR/API restarts by avoiding
 * API calls in the proxy layer.
 */
export async function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Allow public paths
  if (publicPaths.some((p) => pathname.startsWith(p))) {
    // If on login page with a valid token, redirect to dashboard
    const token = request.cookies.get("admin-token")?.value;
    if (pathname === "/login" && token) {
      return NextResponse.redirect(new URL("/", request.url));
    }
    return NextResponse.next();
  }

  // Check for admin-token cookie (presence only, no API validation)
  const token = request.cookies.get("admin-token")?.value;

  if (!token) {
    const loginUrl = new URL("/login", request.url);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
