/**
 * @fileoverview Supabase middleware for session refresh and route protection.
 * State machine:
 *   - No user → /login (if on protected route)
 *   - No supervisor record → /training (training page handles auto-creation)
 *   - Supervisor + is_access_granted=false → /pending-approval
 *   - Supervisor + is_access_granted=true + training incomplete → /training
 *   - Supervisor + is_access_granted=true + training complete → dashboard
 * @module lib/supabase/middleware
 */

import { createServerClient } from "@supabase/ssr"
import { NextResponse, type NextRequest } from "next/server"

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Do not run code between createServerClient and
  // supabase.auth.getUser(). A simple mistake could make it very hard to debug
  // issues with users being randomly logged out.

  const {
    data: { user },
  } = await supabase.auth.getUser()

  const pathname = request.nextUrl.pathname

  // Skip middleware state machine for API routes and auth callbacks
  const isApiRoute = pathname.startsWith("/api/") || pathname.startsWith("/auth/")
  if (isApiRoute) return supabaseResponse

  // Route classification
  const isAuthRoute = pathname.startsWith("/login") ||
                      pathname.startsWith("/register") ||
                      pathname.startsWith("/pending")

  const isTrainingRoute = pathname.startsWith("/training")
  const isPendingApprovalRoute = pathname.startsWith("/pending-approval")

  const isDashboardRoute = pathname.startsWith("/dashboard") ||
                           pathname.startsWith("/projects") ||
                           pathname.startsWith("/doers") ||
                           pathname.startsWith("/users") ||
                           pathname.startsWith("/chat") ||
                           pathname.startsWith("/earnings") ||
                           pathname.startsWith("/resources") ||
                           pathname.startsWith("/profile") ||
                           pathname.startsWith("/settings") ||
                           pathname.startsWith("/support") ||
                           pathname.startsWith("/notifications") ||
                           pathname.startsWith("/messages")

  const isActivationRoute = pathname.startsWith("/activation") ||
                            pathname.startsWith("/quiz")

  // ── Unauthenticated users ──
  if (!user) {
    if (isDashboardRoute || isActivationRoute || isTrainingRoute || isPendingApprovalRoute) {
      const url = request.nextUrl.clone()
      url.pathname = "/login"
      return NextResponse.redirect(url)
    }
    return supabaseResponse
  }

  // ── Authenticated users — check supervisor status ──
  const { data: supervisor } = await supabase
    .from("supervisors")
    .select("is_access_granted")
    .eq("profile_id", user.id)
    .maybeSingle()

  if (!supervisor) {
    // No supervisor record — training page handles auto-creation from metadata
    if (isAuthRoute) return supabaseResponse // allow login/register/pending
    if (isTrainingRoute) return supabaseResponse // training page will handle creation
    // Redirect everything else to /training
    const url = request.nextUrl.clone()
    url.pathname = "/training"
    return NextResponse.redirect(url)
  }

  if (!supervisor.is_access_granted) {
    // Supervisor exists but admin hasn't granted access yet
    if (isPendingApprovalRoute) return supabaseResponse
    const url = request.nextUrl.clone()
    url.pathname = "/pending-approval"
    return NextResponse.redirect(url)
  }

  // ── Supervisor has access — check training completion ──
  const { data: modules } = await supabase
    .from("training_modules")
    .select("id")
    .eq("target_role", "supervisor")
    .eq("is_mandatory", true)
    .eq("is_active", true)

  const { data: progress } = await supabase
    .from("training_progress")
    .select("module_id, status")
    .eq("profile_id", user.id)

  const completedIds = new Set(
    (progress || []).filter((p: any) => p.status === "completed").map((p: any) => p.module_id)
  )
  const allTrainingComplete = (modules || []).length === 0 ||
    (modules || []).every((m: any) => completedIds.has(m.id))

  if (!allTrainingComplete) {
    // Training incomplete
    if (isTrainingRoute) return supabaseResponse
    const url = request.nextUrl.clone()
    url.pathname = "/training"
    return NextResponse.redirect(url)
  }

  // ── Fully onboarded — redirect away from auth/training routes ──
  if (isAuthRoute || isTrainingRoute || isPendingApprovalRoute || isActivationRoute) {
    const url = request.nextUrl.clone()
    url.pathname = "/dashboard"
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}
