import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/**
 * Updates the Supabase session and handles admin auth redirects.
 * This is the admin-only middleware - every route is an admin route.
 *
 * @param request - The incoming request
 * @returns NextResponse with updated session cookies
 */
export async function updateSession(request: NextRequest) {
  const pathname = request.nextUrl.pathname;

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
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const isLoginPage = pathname === "/login";

  // Allow /login for unauthenticated users
  if (isLoginPage && !user) {
    return supabaseResponse;
  }

  // Unauthenticated users on any route -> redirect to /login
  if (!user) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  // Authenticated user - check if they are an admin
  const { data: admin } = await supabase
    .from("admins")
    .select("id, is_active")
    .eq("profile_id", user.id)
    .single();

  const isAdmin = admin && admin.is_active !== false;

  // Authenticated admin on /login -> redirect to /
  if (isLoginPage && isAdmin) {
    const url = request.nextUrl.clone();
    url.pathname = "/";
    return NextResponse.redirect(url);
  }

  // Authenticated but not admin -> redirect to /login
  if (!isAdmin) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  // Authenticated admin on valid route -> allow through
  return supabaseResponse;
}
