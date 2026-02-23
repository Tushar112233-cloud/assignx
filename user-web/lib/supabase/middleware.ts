import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/**
 * Updates the Supabase session and handles auth redirects
 * Implements proper flow:
 * - New users (no profile/user_type) -> onboarding
 * - Existing users (has profile/user_type) -> dashboard
 * - Unauthenticated users on protected routes -> login
 *
 * DEV MODE: When NEXT_PUBLIC_REQUIRE_LOGIN=false, authentication is bypassed
 * and all protected routes are accessible without login
 *
 * @param request - The incoming request
 * @returns NextResponse with updated session cookies
 */
export async function updateSession(request: NextRequest) {
  const pathname = request.nextUrl.pathname;

  // Check if login is required (dev mode bypass)
  const requireLogin = process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false";

  // If login is not required, allow access to all routes except explicitly redirect login to home
  if (!requireLogin) {
    // Redirect login page to home in dev mode
    if (pathname === "/login") {
      const url = request.nextUrl.clone();
      url.pathname = "/home";
      return NextResponse.redirect(url);
    }

    // Redirect onboarding routes to home (user is already "onboarded" in dev mode)
    const onboardingRoutes = ["/onboarding", "/signup/student", "/signup/professional"];
    if (onboardingRoutes.some((route) => pathname.startsWith(route))) {
      const url = request.nextUrl.clone();
      url.pathname = "/home";
      return NextResponse.redirect(url);
    }

    // Allow root path (landing page) to be accessible
    // User can navigate to dashboard from there

    // Allow all other routes without authentication
    return NextResponse.next({ request });
  }

  // Normal authentication flow when login is required
  let supabaseResponse = NextResponse.next({
    request,
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({
            request,
          });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  // Do not run code between createServerClient and supabase.auth.getUser()
  // A simple mistake could make it very hard to debug issues with users being randomly logged out.
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Protected routes - redirect to login if not authenticated
  const protectedRoutes = [
    "/home",
    "/projects",
    "/project", // Covers /project/[id]
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
  ];
  const isProtectedRoute = protectedRoutes.some((route) =>
    pathname.startsWith(route)
  );

  if (isProtectedRoute && !user) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  // Verify user has a valid user_type for protected routes
  if (user && isProtectedRoute) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('user_type')
      .eq('id', user.id)
      .single();

    if (!profile || !['student', 'professional', 'business'].includes(profile.user_type)) {
      const url = request.nextUrl.clone();
      url.pathname = '/login';
      url.searchParams.set('error', 'unauthorized');
      return NextResponse.redirect(url);
    }
  }

  // Onboarding routes - need auth but allow incomplete profiles
  const onboardingRoutes = ["/onboarding", "/signup/student", "/signup/professional"];
  const isOnboardingRoute = onboardingRoutes.some((route) =>
    pathname.startsWith(route)
  );

  // Login page - redirect authenticated users based on profile status
  const isLoginPage = pathname === "/login";

  if (user && (isLoginPage || isOnboardingRoute)) {
    // Check if user has FULLY completed their profile (onboarding_completed = true)
    const { data: profile } = await supabase
      .from("profiles")
      .select("user_type, onboarding_completed")
      .eq("id", user.id)
      .single();

    // Only redirect to dashboard if onboarding is fully completed AND user_type is valid
    const hasCompletedOnboarding = profile?.onboarding_completed === true;
    const hasValidUserType = profile && ['student', 'professional', 'business'].includes(profile.user_type);

    if (hasCompletedOnboarding && hasValidUserType) {
      // User has completed onboarding with valid user_type, redirect to dashboard
      if (isLoginPage || isOnboardingRoute) {
        const url = request.nextUrl.clone();
        url.pathname = "/home";
        return NextResponse.redirect(url);
      }
    } else if (!hasCompletedOnboarding) {
      // User needs onboarding - allow access to signup forms
      if (isLoginPage) {
        // Redirect from login to signup flow
        const url = request.nextUrl.clone();
        url.pathname = "/signup";
        return NextResponse.redirect(url);
      }
      // Allow access to onboarding routes (signup/student, signup/professional)
      // for users who haven't completed onboarding yet
    }
  }

  // Unauthenticated users trying to access onboarding
  if (!user && isOnboardingRoute) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  // Root page (landing page) - allow access for all users (authenticated or not)
  // The landing page will show appropriate buttons based on auth state

  return supabaseResponse;
}
