import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()
  const pathname = request.nextUrl.pathname

  // Route classification
  const isAuthRoute = pathname.startsWith('/login') || pathname.startsWith('/register') || pathname.startsWith('/pending')
  const isTrainingRoute = pathname.startsWith('/training')
  const isPendingApprovalRoute = pathname.startsWith('/pending-approval')
  const isPublicRoute = pathname === '/' || pathname.startsWith('/auth/') || pathname.startsWith('/api/')
  const isDashboardRoute = pathname.startsWith('/dashboard') || pathname.startsWith('/projects') || pathname.startsWith('/statistics') || pathname.startsWith('/resources') || pathname.startsWith('/profile') || pathname.startsWith('/settings') || pathname.startsWith('/support') || pathname.startsWith('/messages') || pathname.startsWith('/notifications') || pathname.startsWith('/reviews')
  const isActivationRoute = pathname.startsWith('/quiz') || pathname.startsWith('/bank-details') || pathname.startsWith('/welcome') || pathname.startsWith('/profile-setup')

  // Unauthenticated users
  if (!user) {
    if (isDashboardRoute || isTrainingRoute || isPendingApprovalRoute || isActivationRoute) {
      const url = request.nextUrl.clone()
      url.pathname = '/login'
      return NextResponse.redirect(url)
    }
    return supabaseResponse
  }

  // Authenticated — check doer record
  const { data: doer } = await supabase
    .from('doers')
    .select('is_access_granted')
    .eq('profile_id', user.id)
    .maybeSingle()

  if (!doer) {
    // No doer record — redirect to training (which handles auto-creation)
    if (isAuthRoute) {
      const url = request.nextUrl.clone()
      url.pathname = '/training'
      return NextResponse.redirect(url)
    }
    if (isTrainingRoute || isPublicRoute || isActivationRoute) return supabaseResponse
    const url = request.nextUrl.clone()
    url.pathname = '/training'
    return NextResponse.redirect(url)
  }

  if (!doer.is_access_granted) {
    // Doer exists but not approved
    if (isPendingApprovalRoute || isPublicRoute) return supabaseResponse
    const url = request.nextUrl.clone()
    url.pathname = '/pending-approval'
    return NextResponse.redirect(url)
  }

  // Doer has access — check training
  const { data: modules } = await supabase
    .from('training_modules')
    .select('id')
    .eq('target_role', 'doer')
    .eq('is_mandatory', true)
    .eq('is_active', true)

  const { data: progress } = await supabase
    .from('training_progress')
    .select('module_id, status')
    .eq('profile_id', user.id)

  const completedIds = new Set(
    (progress || []).filter(p => p.status === 'completed').map(p => p.module_id)
  )
  const allTrainingComplete = (modules || []).every(m => completedIds.has(m.id))

  if (!allTrainingComplete) {
    if (!isTrainingRoute && !isPublicRoute) {
      const url = request.nextUrl.clone()
      url.pathname = '/training'
      return NextResponse.redirect(url)
    }
    return supabaseResponse
  }

  // Fully approved + trained — redirect away from auth/training routes
  if (isAuthRoute || isTrainingRoute || isPendingApprovalRoute || isActivationRoute) {
    const url = request.nextUrl.clone()
    url.pathname = '/dashboard'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}
