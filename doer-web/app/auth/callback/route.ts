import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const token_hash = searchParams.get('token_hash')
  const type = searchParams.get('type') as any

  const cookieStore = await cookies()
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // Ignore - middleware handles session refresh
          }
        },
      },
    }
  )

  let authError = false

  // Handle PKCE code exchange
  if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (error) authError = true
  }
  // Handle token_hash verification (magic link)
  else if (token_hash && type) {
    const { error } = await supabase.auth.verifyOtp({ token_hash, type })
    if (error) authError = true
  }
  else {
    authError = true
  }

  if (authError) {
    return NextResponse.redirect(`${origin}/login?error=auth_callback_error`)
  }

  // Get authenticated user
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    return NextResponse.redirect(`${origin}/login?error=auth_callback_error`)
  }

  // Create profile if not exists
  const { data: profile } = await supabase
    .from('profiles')
    .select('id')
    .eq('id', user.id)
    .maybeSingle()

  if (!profile) {
    await supabase
      .from('profiles')
      .insert({
        id: user.id,
        email: user.email!,
        full_name: user.user_metadata?.full_name || user.email?.split('@')[0] || 'User',
        phone: user.phone || null,
        phone_verified: false,
        avatar_url: user.user_metadata?.avatar_url || null,
        user_type: 'doer',
      })
  }

  // Check for doer record
  const { data: doer } = await supabase
    .from('doers')
    .select('id, is_access_granted')
    .eq('profile_id', user.id)
    .maybeSingle()

  if (!doer) {
    // Check for approved email_access_request with metadata
    const { data: accessRequest } = await supabase
      .from('email_access_requests')
      .select('full_name, metadata, status')
      .eq('email', (user.email || '').toLowerCase())
      .eq('role', 'doer')
      .eq('status', 'approved')
      .maybeSingle()

    if (accessRequest?.metadata) {
      const meta = accessRequest.metadata as any

      // Update profile full_name if available from the access request
      if (accessRequest.full_name) {
        await supabase
          .from('profiles')
          .update({ full_name: accessRequest.full_name })
          .eq('id', user.id)
      }

      // Create doer record from metadata
      await supabase
        .from('doers')
        .insert({
          profile_id: user.id,
          qualification: meta.qualification || 'undergraduate',
          experience_level: meta.experienceLevel || 'beginner',
          bio: meta.bio || null,
          bank_name: meta.bankName || null,
          bank_account_number: meta.accountNumber || null,
          bank_ifsc_code: meta.ifscCode || null,
          upi_id: meta.upiId || null,
          is_access_granted: true,
          is_activated: false,
        })

      // Create training_progress records for all active mandatory doer modules
      const { data: modules } = await supabase
        .from('training_modules')
        .select('id')
        .eq('target_role', 'doer')
        .eq('is_mandatory', true)
        .eq('is_active', true)

      if (modules && modules.length > 0) {
        const progressRecords = modules.map(m => ({
          profile_id: user.id,
          module_id: m.id,
          status: 'not_started',
          progress_percentage: 0,
        }))

        await supabase
          .from('training_progress')
          .upsert(progressRecords, { onConflict: 'profile_id,module_id' })
      }

      return NextResponse.redirect(`${origin}/training`)
    }

    // No approved request with metadata — send to training anyway
    return NextResponse.redirect(`${origin}/training`)
  }

  // Doer exists but not approved
  if (!doer.is_access_granted) {
    return NextResponse.redirect(`${origin}/pending-approval`)
  }

  // Doer approved — check training completion
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
  const allComplete = (modules || []).every(m => completedIds.has(m.id))

  if (!allComplete) {
    return NextResponse.redirect(`${origin}/training`)
  }

  return NextResponse.redirect(`${origin}/dashboard`)
}
