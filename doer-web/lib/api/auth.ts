import { apiClient, clearTokens } from './client'

interface AuthResponse {
  message: string
  accessToken?: string
  refreshToken?: string
  user?: {
    id: string
    email: string
    role: string
    profile: Record<string, unknown>
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

  return data
}

export async function sendMagicLink(email: string, role: string = 'doer'): Promise<{ message: string }> {
  return apiClient<{ message: string }>('/api/auth/magic-link', {
    method: 'POST',
    body: JSON.stringify({ email, role }),
    skipAuth: true,
  })
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
}

export async function getCurrentUser(): Promise<AuthResponse['user'] | null> {
  try {
    const data = await apiClient<{ user: AuthResponse['user'] }>('/api/auth/me')
    return data.user
  } catch {
    return null
  }
}
