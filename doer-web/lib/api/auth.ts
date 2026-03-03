import { apiClient, clearTokens } from './client'

interface AuthResponse {
  message: string
  accessToken?: string
  refreshToken?: string
  user?: AuthUser
  profile?: AuthUser
}

interface AuthUser {
  id: string
  email: string
  role?: string
  [key: string]: unknown
}

const AUTH_USER_KEY = 'doer_auth_user'

// ── User cache (localStorage) ──

export function getStoredUser(): AuthUser | null {
  if (typeof window === 'undefined') return null
  try {
    const stored = localStorage.getItem(AUTH_USER_KEY)
    if (stored) return JSON.parse(stored)
  } catch {
    // corrupted
  }
  return null
}

export function storeUser(user: AuthUser): void {
  if (typeof window === 'undefined') return
  try {
    localStorage.setItem(AUTH_USER_KEY, JSON.stringify(user))
  } catch {
    // ignore
  }
}

export function clearStoredUser(): void {
  if (typeof window === 'undefined') return
  try {
    localStorage.removeItem(AUTH_USER_KEY)
  } catch {
    // ignore
  }
}

/** Emails that bypass magic link and login directly */
const DEV_BYPASS_EMAILS = ['admin@gmail.com', 'testdoer@gmail.com']

export function isDevBypassEmail(email: string): boolean {
  return DEV_BYPASS_EMAILS.includes(email.toLowerCase().trim())
}

export async function devLogin(email: string): Promise<AuthResponse> {
  const data = await apiClient<AuthResponse>('/api/auth/dev-login', {
    method: 'POST',
    body: JSON.stringify({ email, role: 'doer' }),
    skipAuth: true,
  })

  if (data.accessToken && data.refreshToken) {
    localStorage.setItem('access_token', data.accessToken)
    localStorage.setItem('refresh_token', data.refreshToken)
  }

  const user = data.user || data.profile
  if (user) storeUser(user)

  return data
}

export async function sendMagicLink(email: string, role: string = 'doer'): Promise<{ message: string; sessionId: string }> {
  const callbackUrl = `${window.location.origin}/auth/verify`
  return apiClient<{ message: string; sessionId: string }>('/api/auth/magic-link', {
    method: 'POST',
    body: JSON.stringify({ email, role, callbackUrl }),
    skipAuth: true,
  })
}

export async function checkMagicLinkStatus(email: string, sessionId: string): Promise<{
  status: 'pending' | 'verified'
  accessToken?: string
  refreshToken?: string
  user?: AuthUser
  profile?: AuthUser
}> {
  const data = await apiClient<{
    status: 'pending' | 'verified'
    accessToken?: string
    refreshToken?: string
    user?: AuthUser
    profile?: AuthUser
  }>('/api/auth/magic-link/check', {
    method: 'POST',
    body: JSON.stringify({ email, sessionId }),
    skipAuth: true,
  })

  if (data.status === 'verified' && data.accessToken && data.refreshToken) {
    localStorage.setItem('access_token', data.accessToken)
    localStorage.setItem('refresh_token', data.refreshToken)
    const user = data.user || data.profile
    if (user) storeUser(user)
  }

  return data
}

export async function verifyOTP(email: string, otp: string): Promise<AuthResponse> {
  const data = await apiClient<AuthResponse>('/api/auth/verify', {
    method: 'POST',
    body: JSON.stringify({ email, otp }),
    skipAuth: true,
  })

  if (data.accessToken && data.refreshToken) {
    localStorage.setItem('access_token', data.accessToken)
    localStorage.setItem('refresh_token', data.refreshToken)
  }

  return data
}

export async function logout(): Promise<void> {
  try {
    await apiClient('/api/auth/logout', { method: 'POST' })
  } catch {
    // Best effort
  }
  clearTokens()
  clearStoredUser()
}

export async function getCurrentUser(): Promise<AuthResponse['user'] | null> {
  try {
    const data = await apiClient<{ user: AuthResponse['user'] }>('/api/auth/me')
    return data.user
  } catch {
    return null
  }
}
