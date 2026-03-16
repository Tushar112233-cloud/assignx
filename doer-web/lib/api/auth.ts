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

// -- User cache (localStorage) --

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

/** Emails that bypass OTP and login directly */
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

/** Send 6-digit OTP to email */
export async function sendOTP(
  email: string,
  purpose: 'login' | 'signup' = 'login',
  role: string = 'doer'
): Promise<{ success: boolean; message: string }> {
  return apiClient<{ success: boolean; message: string }>('/api/auth/send-otp', {
    method: 'POST',
    body: JSON.stringify({ email, purpose, role }),
    skipAuth: true,
  })
}

/** Verify OTP for login — returns JWT tokens */
export async function verifyOTP(email: string, otp: string): Promise<AuthResponse> {
  const data = await apiClient<AuthResponse>('/api/auth/verify', {
    method: 'POST',
    body: JSON.stringify({ email, otp, purpose: 'login', role: 'doer' }),
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

/** Verify OTP + create doer profile (signup) */
export async function doerSignup(
  email: string,
  otp: string,
  fullName: string,
  metadata: Record<string, unknown>
): Promise<{ success: boolean; message: string }> {
  return apiClient<{ success: boolean; message: string }>('/api/auth/doer-signup', {
    method: 'POST',
    body: JSON.stringify({ email, otp, fullName, metadata }),
    skipAuth: true,
  })
}

/** Check access status for an email */
export async function checkAccessStatus(
  email: string,
  role: string = 'doer'
): Promise<{ status: string; isActivated?: boolean; needsOnboarding?: boolean }> {
  return apiClient<{ status: string; isActivated?: boolean; needsOnboarding?: boolean }>(
    `/api/auth/access-status?email=${encodeURIComponent(email)}&role=${role}`,
    { skipAuth: true }
  )
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
    const data = await apiClient<AuthUser>('/api/auth/me')
    return data || null
  } catch {
    return null
  }
}
