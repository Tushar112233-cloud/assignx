import { createClient } from '@supabase/supabase-js'
import { sendEmail } from '@/lib/email/resend'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  const { email } = await request.json()

  if (!email) {
    return NextResponse.json({ error: 'Email is required' }, { status: 400 })
  }

  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  // Check email_access_requests status
  const { data: accessRequest } = await supabase
    .from('email_access_requests')
    .select('status')
    .eq('email', email.toLowerCase())
    .eq('role', 'doer')
    .maybeSingle()

  if (!accessRequest) {
    return NextResponse.json({ error: 'no_account', message: 'No account found' }, { status: 404 })
  }
  if (accessRequest.status === 'pending') {
    return NextResponse.json({ error: 'pending', message: 'Application pending' }, { status: 403 })
  }
  if (accessRequest.status === 'rejected') {
    return NextResponse.json({ error: 'rejected', message: 'Application rejected' }, { status: 403 })
  }

  // Generate magic link
  const { data: linkData, error: linkError } = await supabase.auth.admin.generateLink({
    type: 'magiclink',
    email: email.toLowerCase(),
    options: {
      redirectTo: `${process.env.NEXT_PUBLIC_APP_URL || request.headers.get('origin')}/auth/callback`,
    },
  })

  if (linkError) {
    console.error('Generate link error:', linkError)
    return NextResponse.json({ error: 'Failed to generate link' }, { status: 500 })
  }

  // Extract the hashed token from the link
  const url = new URL(linkData.properties.action_link)
  const token_hash = url.searchParams.get('token_hash') || url.searchParams.get('token')
  const type = url.searchParams.get('type') || 'magiclink'

  // Build our custom redirect URL
  const callbackUrl = `${process.env.NEXT_PUBLIC_APP_URL || request.headers.get('origin')}/auth/callback?token_hash=${token_hash}&type=${type}`

  // Send email via Resend
  await sendEmail({
    to: email.toLowerCase(),
    subject: 'Sign in to AssignX',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 20px;">
        <div style="text-align: center; margin-bottom: 32px;">
          <div style="display: inline-block; background: linear-gradient(135deg, #5A7CFF, #49C5FF); padding: 12px 16px; border-radius: 12px;">
            <span style="color: white; font-size: 18px; font-weight: bold;">AX</span>
          </div>
          <p style="color: #64748B; font-size: 12px; margin-top: 8px;">AssignX Doer Portal</p>
        </div>
        <h1 style="color: #1E293B; font-size: 24px; font-weight: 600; text-align: center; margin-bottom: 8px;">Sign in to AssignX</h1>
        <p style="color: #64748B; font-size: 14px; text-align: center; margin-bottom: 32px;">Click the button below to sign in to your account.</p>
        <div style="text-align: center; margin-bottom: 32px;">
          <a href="${callbackUrl}" style="display: inline-block; background: linear-gradient(135deg, #5A7CFF, #49C5FF); color: white; padding: 12px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px;">Sign in</a>
        </div>
        <p style="color: #94A3B8; font-size: 12px; text-align: center;">This link expires in 1 hour. If you didn't request this, you can safely ignore this email.</p>
      </div>
    `,
  })

  return NextResponse.json({ success: true })
}
