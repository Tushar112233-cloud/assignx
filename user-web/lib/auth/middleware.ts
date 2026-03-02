import { NextResponse, type NextRequest } from "next/server";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

/**
 * Middleware to handle auth redirects for the user-web app.
 *
 * JWT tokens live in localStorage (client-side), so the middleware
 * cannot validate them on initial page load.  Instead it checks for
 * a lightweight `loggedIn` cookie that the client sets after login.
 *
 * For SSR pages that truly need the user object, individual server
 * components call the API with the token passed from the client.
 */
export async function updateSession(request: NextRequest) {
  const pathname = request.nextUrl.pathname;

  // Dev-mode bypass
  const requireLogin = process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";

  if (!requireLogin) {
    if (pathname === "/login") {
      const url = request.nextUrl.clone();
      url.pathname = "/home";
      return NextResponse.redirect(url);
    }

    const onboardingRoutes = ["/onboarding", "/signup/student", "/signup/professional"];
    if (onboardingRoutes.some((r) => pathname.startsWith(r))) {
      const url = request.nextUrl.clone();
      url.pathname = "/home";
      return NextResponse.redirect(url);
    }

    return NextResponse.next({ request });
  }

  // Read the lightweight cookie set by the client after login
  const loggedIn = request.cookies.get("loggedIn")?.value === "true";

  // Protected routes
  const protectedRoutes = [
    "/home",
    "/projects",
    "/project",
    "/profile",
    "/connect",
    "/settings",
    "/support",
    "/wallet",
    "/payment-methods",
    "/experts",
    "/campus-connect",
    "/marketplace",
    "/dashboard",
    "/business-hub",
    "/pro-network",
  ];

  const isProtectedRoute = protectedRoutes.some((route) =>
    pathname.startsWith(route)
  );

  // Redirect unauthenticated users away from protected routes
  if (isProtectedRoute && !loggedIn) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  // Redirect logged-in users away from login page
  const isLoginPage = pathname === "/login";
  if (isLoginPage && loggedIn) {
    const url = request.nextUrl.clone();
    url.pathname = "/home";
    return NextResponse.redirect(url);
  }

  // Onboarding routes need auth
  const onboardingRoutes = ["/onboarding", "/signup/student", "/signup/professional"];
  const isOnboardingRoute = onboardingRoutes.some((r) => pathname.startsWith(r));

  if (!loggedIn && isOnboardingRoute) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  return NextResponse.next({ request });
}
