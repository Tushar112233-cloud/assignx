const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000'

function getTokens() {
  if (typeof window === 'undefined') return { accessToken: null, refreshToken: null }
  return {
    accessToken: localStorage.getItem('access_token'),
    refreshToken: localStorage.getItem('refresh_token'),
  }
}

function setTokens(access: string, refresh: string) {
  localStorage.setItem('access_token', access)
  localStorage.setItem('refresh_token', refresh)
}

export function clearTokens() {
  localStorage.removeItem('access_token')
  localStorage.removeItem('refresh_token')
}

export function getAccessToken(): string | null {
  if (typeof window === 'undefined') return null
  return localStorage.getItem('access_token')
}

let isRefreshing = false
let refreshPromise: Promise<boolean> | null = null

async function refreshAccessToken(): Promise<boolean> {
  if (isRefreshing && refreshPromise) return refreshPromise

  isRefreshing = true
  refreshPromise = (async () => {
    try {
      const { refreshToken } = getTokens()
      if (!refreshToken) return false

      const res = await fetch(`${API_URL}/api/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      })

      if (!res.ok) return false

      const data = await res.json()
      setTokens(data.accessToken, data.refreshToken)
      return true
    } catch {
      return false
    } finally {
      isRefreshing = false
      refreshPromise = null
    }
  })()

  return refreshPromise
}

interface ApiOptions extends RequestInit {
  skipAuth?: boolean
}

export async function apiClient<T = unknown>(
  endpoint: string,
  options: ApiOptions = {}
): Promise<T> {
  const { skipAuth, ...fetchOptions } = options
  const url = `${API_URL}${endpoint}`

  const headers: Record<string, string> = {
    ...(fetchOptions.headers as Record<string, string> || {}),
  }

  if (!skipAuth) {
    const { accessToken } = getTokens()
    if (accessToken) {
      headers['Authorization'] = `Bearer ${accessToken}`
    }
  }

  // Only set Content-Type for non-FormData bodies
  if (!(fetchOptions.body instanceof FormData)) {
    headers['Content-Type'] = headers['Content-Type'] || 'application/json'
  }

  let res = await fetch(url, {
    ...fetchOptions,
    headers,
  })

  // Auto-refresh on 401
  if (res.status === 401 && !skipAuth) {
    const refreshed = await refreshAccessToken()
    if (refreshed) {
      const { accessToken } = getTokens()
      headers['Authorization'] = `Bearer ${accessToken}`
      res = await fetch(url, { ...fetchOptions, headers })
    } else {
      clearTokens()
      if (typeof window !== 'undefined') {
        window.location.href = '/login'
      }
      throw new Error('Session expired')
    }
  }

  if (!res.ok) {
    const errorData = await res.json().catch(() => ({ message: res.statusText }))
    throw new Error(errorData.message || errorData.error || `API Error: ${res.status}`)
  }

  // Handle 204 No Content
  if (res.status === 204) return undefined as T

  return res.json()
}

export async function apiUpload<T = unknown>(
  endpoint: string,
  file: File,
  folder?: string
): Promise<T> {
  const formData = new FormData()
  formData.append('file', file)
  if (folder) formData.append('folder', folder)

  return apiClient<T>(endpoint, {
    method: 'POST',
    body: formData,
  })
}
