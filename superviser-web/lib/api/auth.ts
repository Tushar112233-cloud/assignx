/**
 * @fileoverview Auth helpers for Express API authentication.
 * Handles magic link, OTP verification, token storage, and current user retrieval.
 * @module lib/api/auth
 */

import { apiFetch, setTokens, clearTokens, getAccessToken } from "./client"

const AUTH_USER_KEY = "supervisor_auth_user"

// ── Types ──

interface AuthTokens {
  accessToken: string
  refreshToken: string
  user: AuthUser
}

interface AuthUser {
  id: string
  email: string
  role?: string
  [key: string]: unknown
}

// ── User cache (localStorage) ──

export function getStoredUser(): AuthUser | null {
  if (typeof window === "undefined") return null
  try {
    const stored = localStorage.getItem(AUTH_USER_KEY)
    if (stored) return JSON.parse(stored)
  } catch {
    // corrupted
  }
  return null
}

export function storeUser(user: AuthUser): void {
  if (typeof window === "undefined") return
  try {
    localStorage.setItem(AUTH_USER_KEY, JSON.stringify(user))
  } catch {
    // ignore
  }
}

export function clearStoredUser(): void {
  if (typeof window === "undefined") return
  try {
    localStorage.removeItem(AUTH_USER_KEY)
  } catch {
    // ignore
  }
}

// ── Auth actions ──

/** Emails that bypass magic link and login directly */
const DEV_BYPASS_EMAILS = ['admin@gmail.com', 'testsupervisor@gmail.com']

export function isDevBypassEmail(email: string): boolean {
  return DEV_BYPASS_EMAILS.includes(email.toLowerCase().trim())
}

/**
 * Direct login without OTP for dev bypass emails.
 */
export async function devLogin(email: string): Promise<AuthTokens> {
  const data = await apiFetch<{ accessToken: string; refreshToken: string; user?: AuthUser; profile?: AuthUser }>("/api/auth/dev-login", {
    method: "POST",
    body: JSON.stringify({ email, role: "supervisor" }),
  })

  setTokens(data.accessToken, data.refreshToken)
  const user = data.user || data.profile
  if (user) storeUser(user)

  return { accessToken: data.accessToken, refreshToken: data.refreshToken, user: user! }
}

/**
 * Send a magic link email for passwordless sign-in.
 * Returns sessionId used to poll for verification status.
 */
export async function sendMagicLink(email: string): Promise<{ success: boolean; sessionId: string }> {
  const callbackUrl = typeof window !== 'undefined'
    ? `${window.location.origin}/auth/verify`
    : `${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/auth/verify`
  return apiFetch("/api/auth/magic-link", {
    method: "POST",
    body: JSON.stringify({ email, role: "supervisor", callbackUrl }),
  })
}

/**
 * Poll for magic link verification status.
 * Returns JWT tokens once the user clicks the email link.
 */
export async function checkMagicLinkStatus(
  email: string,
  sessionId: string
): Promise<{ status: 'pending' | 'verified'; accessToken?: string; refreshToken?: string; user?: AuthUser; profile?: AuthUser }> {
  const data = await apiFetch<{ status: 'pending' | 'verified'; accessToken?: string; refreshToken?: string; user?: AuthUser; profile?: AuthUser }>(
    "/api/auth/magic-link/check",
    {
      method: "POST",
      body: JSON.stringify({ email, sessionId }),
    }
  )

  if (data.status === 'verified' && data.accessToken && data.refreshToken) {
    setTokens(data.accessToken, data.refreshToken)
    const user = data.user || data.profile
    if (user) storeUser(user)
  }

  return data
}

/**
 * Verify an OTP code (from magic link email).
 * Stores tokens and user on success.
 */
export async function verifyOTP(
  email: string,
  otp: string
): Promise<AuthTokens> {
  const data = await apiFetch<{ accessToken: string; refreshToken: string; user?: AuthUser; profile?: AuthUser }>("/api/auth/verify", {
    method: "POST",
    body: JSON.stringify({ email, otp }),
  })

  // Store tokens
  setTokens(data.accessToken, data.refreshToken)

  // API returns `profile` not `user` — handle both
  const user = data.user || data.profile
  if (user) storeUser(user)

  return { accessToken: data.accessToken, refreshToken: data.refreshToken, user: user! }
}

/**
 * Sign in with email and password.
 * Stores tokens and user on success.
 */
export async function signInWithPassword(
  email: string,
  password: string
): Promise<AuthTokens> {
  const data = await apiFetch<AuthTokens>("/api/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  })

  setTokens(data.accessToken, data.refreshToken)
  storeUser(data.user)

  return data
}

/**
 * Sign up with email, password, and metadata.
 */
export async function signUp(
  email: string,
  password: string,
  fullName: string,
  phone: string
): Promise<AuthTokens> {
  const data = await apiFetch<AuthTokens>("/api/auth/register", {
    method: "POST",
    body: JSON.stringify({ email, password, fullName, phone, role: "supervisor" }),
  })

  setTokens(data.accessToken, data.refreshToken)
  storeUser(data.user)

  return data
}

/**
 * Get the current authenticated user from the API.
 */
export async function getCurrentUser(): Promise<AuthUser | null> {
  const token = getAccessToken()
  if (!token) return getStoredUser()

  try {
    const user = await apiFetch<AuthUser>("/api/auth/me")
    storeUser(user)
    return user
  } catch {
    // Token expired or invalid -- return cached user or null
    return getStoredUser()
  }
}

/**
 * Logout: clear tokens and stored user.
 */
export async function logout(): Promise<void> {
  try {
    await apiFetch("/api/auth/logout", { method: "POST" })
  } catch {
    // ignore -- clear local state anyway
  }
  clearTokens()
  clearStoredUser()
}

/**
 * Check if there is a stored access token (quick synchronous check).
 */
export function hasSession(): boolean {
  return !!getAccessToken()
}

/**
 * Check email access request status (for login form feedback).
 */
export async function checkAccessRequest(
  email: string,
  role: string = "supervisor"
): Promise<{ status: string } | null> {
  try {
    const data = await apiFetch<{ status: string }>(
      `/api/auth/access-request?email=${encodeURIComponent(email)}&role=${role}`
    )
    return data
  } catch {
    return null
  }
}
