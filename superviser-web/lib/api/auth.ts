/**
 * @fileoverview Auth helpers for Express API authentication.
 * Handles OTP verification, token storage, and current user retrieval.
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

/** Emails that bypass OTP and login directly in dev mode */
const DEV_BYPASS_EMAILS: string[] = []

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
 * Verify an OTP code.
 * Stores tokens and user on success.
 */
export async function verifyOTP(
  email: string,
  otp: string
): Promise<AuthTokens> {
  const data = await apiFetch<{ accessToken: string; refreshToken: string; user?: AuthUser; profile?: AuthUser }>("/api/auth/verify", {
    method: "POST",
    body: JSON.stringify({ email, otp, purpose: 'login', role: 'supervisor' }),
  })

  // Store tokens
  setTokens(data.accessToken, data.refreshToken)

  // API returns `profile` not `user` — handle both
  const user = data.user || data.profile
  if (user) storeUser(user)

  return { accessToken: data.accessToken, refreshToken: data.refreshToken, user: user! }
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
 * Check supervisor status by email.
 */
export async function checkSupervisorStatus(
  email: string
): Promise<{ status: 'not_found' | 'pending' | 'rejected' | 'approved'; isActivated?: boolean }> {
  return apiFetch(`/api/auth/supervisor-status?email=${encodeURIComponent(email)}`)
}

/**
 * Send OTP to email for supervisor login or signup.
 */
export async function sendSupervisorOTP(
  email: string,
  purpose: 'login' | 'signup' = 'login'
): Promise<{ success: boolean; message: string }> {
  return apiFetch('/api/auth/send-otp', {
    method: 'POST',
    body: JSON.stringify({ email, role: 'supervisor', purpose }),
  })
}

/**
 * Verify OTP and get tokens (for login).
 */
export async function verifySupervisorOTP(
  email: string,
  otp: string
): Promise<{ accessToken: string; refreshToken: string; user: AuthUser; profile: AuthUser }> {
  const data = await apiFetch<{ accessToken: string; refreshToken: string; user?: AuthUser; profile?: AuthUser }>('/api/auth/verify', {
    method: 'POST',
    body: JSON.stringify({ email, otp, purpose: 'login', role: 'supervisor' }),
  })

  setTokens(data.accessToken, data.refreshToken)
  const user = data.user || data.profile
  if (user) storeUser(user)

  return { ...data, user: user!, profile: user! }
}

/**
 * Supervisor signup: verify OTP + create access request.
 */
export async function supervisorSignup(
  email: string,
  otp: string,
  fullName: string,
  metadata: Record<string, unknown>
): Promise<{ success: boolean; message: string }> {
  return apiFetch('/api/auth/supervisor-signup', {
    method: 'POST',
    body: JSON.stringify({ email, otp, fullName, metadata }),
  })
}
