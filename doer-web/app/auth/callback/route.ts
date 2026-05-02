import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000'

/**
 * Auth callback route handler.
 * Receives code or token_hash from the magic link / PKCE flow,
 * exchanges it for JWT tokens via the Express API, sets httpOnly
 * cookies for SSR middleware, then redirects based on doer status.
 */
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const token_hash = searchParams.get('token_hash')
  const type = searchParams.get('type')

  if (!code && !token_hash) {
    return NextResponse.redirect(`${origin}/login?error=auth_callback_error`)
  }

  try {
    // Exchange code/token_hash for JWT tokens via Express API
    const verifyPayload: Record<string, string> = {}
    if (code) {
      verifyPayload.code = code
    } else if (token_hash && type) {
      verifyPayload.token_hash = token_hash
      verifyPayload.type = type
    }

    const verifyRes = await fetch(`${API_URL}/api/auth/verify-callback`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(verifyPayload),
    })

    if (!verifyRes.ok) {
      console.error('[Auth Callback] Verification failed:', verifyRes.status)
      return NextResponse.redirect(`${origin}/login?error=auth_callback_error`)
    }

    const authData = await verifyRes.json()
    const { accessToken, refreshToken } = authData

    if (!accessToken) {
      return NextResponse.redirect(`${origin}/login?error=auth_callback_error`)
    }

    // Check doer status via the Express API
    const statusRes = await fetch(`${API_URL}/api/auth/callback-status`, {
      headers: { 'Authorization': `Bearer ${accessToken}` },
    })

    let redirectPath = '/training'

    if (statusRes.ok) {
      const status = await statusRes.json()
      // The Express API callback-status endpoint returns the appropriate redirect path
      // based on: doer existence, access grant, training completion
      redirectPath = status.redirectPath || '/training'
    }

    // Build the redirect response
    const redirectUrl = new URL(redirectPath, origin)
    const response = NextResponse.redirect(redirectUrl)

    // Set httpOnly cookies for SSR middleware access
    const cookieStore = await cookies()
    const cookieOptions = {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax' as const,
      path: '/',
      maxAge: 60 * 60 * 24 * 7, // 7 days
    }

    cookieStore.set('access_token', accessToken, cookieOptions)
    if (refreshToken) {
      cookieStore.set('refresh_token', refreshToken, {
        ...cookieOptions,
        maxAge: 60 * 60 * 24 * 30, // 30 days
      })
    }

    // Also pass tokens to client via redirect URL so the session page can store them
    // in localStorage for client-side API calls
    const sessionUrl = new URL('/auth/session', origin)
    sessionUrl.searchParams.set('next', redirectPath)
    sessionUrl.searchParams.set('access_token', accessToken)
    if (refreshToken) {
      sessionUrl.searchParams.set('refresh_token', refreshToken)
    }

    const sessionResponse = NextResponse.redirect(sessionUrl)

    // Set cookies on the response as well
    sessionResponse.cookies.set('access_token', accessToken, cookieOptions)
    if (refreshToken) {
      sessionResponse.cookies.set('refresh_token', refreshToken, {
        ...cookieOptions,
        maxAge: 60 * 60 * 24 * 30,
      })
    }

    return sessionResponse
  } catch (error) {
    console.error('[Auth Callback] Error:', error)
    return NextResponse.redirect(`${origin}/login?error=auth_callback_error`)
  }
}
