/**
 * @fileoverview HTTP client wrapper for Express API at localhost:4000.
 * Adds JWT Authorization header from localStorage, auto-refreshes on 401.
 * @module lib/api/client
 */

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"

const TOKEN_KEY = "supervisor_access_token"
const REFRESH_KEY = "supervisor_refresh_token"

// ── Token helpers ──

export function getAccessToken(): string | null {
  if (typeof window === "undefined") return null
  return localStorage.getItem(TOKEN_KEY)
}

export function getRefreshToken(): string | null {
  if (typeof window === "undefined") return null
  return localStorage.getItem(REFRESH_KEY)
}

export function setTokens(access: string, refresh: string): void {
  if (typeof window === "undefined") return
  localStorage.setItem(TOKEN_KEY, access)
  localStorage.setItem(REFRESH_KEY, refresh)
  // Also store in a cookie for SSR middleware to read
  document.cookie = `supervisor_token=${access}; path=/; max-age=${60 * 60 * 24 * 7}; SameSite=Lax`
}

export function clearTokens(): void {
  if (typeof window === "undefined") return
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(REFRESH_KEY)
  document.cookie = "supervisor_token=; path=/; max-age=0"
}

// ── Refresh logic ──

let refreshPromise: Promise<boolean> | null = null

async function refreshAccessToken(): Promise<boolean> {
  // Deduplicate concurrent refresh attempts
  if (refreshPromise) return refreshPromise

  refreshPromise = (async () => {
    const refresh = getRefreshToken()
    if (!refresh) return false

    try {
      const res = await fetch(`${API_BASE}/api/auth/refresh`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refreshToken: refresh }),
      })

      if (!res.ok) return false

      const data = await res.json()
      if (data.accessToken && data.refreshToken) {
        setTokens(data.accessToken, data.refreshToken)
        return true
      }
      return false
    } catch {
      return false
    } finally {
      refreshPromise = null
    }
  })()

  return refreshPromise
}

// ── Main fetch wrapper ──

export interface ApiError extends Error {
  status: number
  data?: unknown
}

function createApiError(message: string, status: number, data?: unknown): ApiError {
  const error = new Error(message) as ApiError
  error.status = status
  error.data = data
  return error
}

/**
 * Authenticated fetch wrapper. Automatically adds the JWT Authorization header
 * and retries once on 401 after refreshing the access token.
 */
export async function apiFetch<T = unknown>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const url = path.startsWith("http") ? path : `${API_BASE}${path}`

  const headers: Record<string, string> = {
    ...(options.headers as Record<string, string> || {}),
  }

  // Don't set Content-Type for FormData (let browser set multipart boundary)
  if (!(options.body instanceof FormData) && !headers["Content-Type"]) {
    headers["Content-Type"] = "application/json"
  }

  const token = getAccessToken()
  if (token) {
    headers["Authorization"] = `Bearer ${token}`
  }

  let res = await fetch(url, { ...options, headers })

  // Auto-refresh on 401
  if (res.status === 401 && token) {
    const refreshed = await refreshAccessToken()
    if (refreshed) {
      // Retry with new token
      const newToken = getAccessToken()
      if (newToken) {
        headers["Authorization"] = `Bearer ${newToken}`
      }
      res = await fetch(url, { ...options, headers })
    } else {
      // Refresh failed -- redirect to login
      clearTokens()
      if (typeof window !== "undefined") {
        window.location.href = "/login"
      }
      throw createApiError("Session expired", 401)
    }
  }

  if (!res.ok) {
    let data: unknown
    try {
      data = await res.json()
    } catch {
      data = undefined
    }
    const message =
      (data as { message?: string })?.message ||
      (data as { error?: string })?.error ||
      `API error ${res.status}`
    throw createApiError(message, res.status, data)
  }

  // Handle 204 No Content
  if (res.status === 204) {
    return undefined as T
  }

  return res.json() as Promise<T>
}
