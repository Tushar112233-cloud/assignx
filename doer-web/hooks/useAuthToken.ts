'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { ROUTES } from '@/lib/constants'

/**
 * Extract project reference from Supabase URL
 * Avoids hardcoding project identifiers
 */
function getSupabaseProjectRef(): string {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL || ''
  // URL format: https://<project-ref>.supabase.co
  const match = url.match(/https:\/\/([^.]+)\.supabase\.co/)
  return match?.[1] || 'default'
}

/** Auth token key in localStorage - dynamically generated from project URL */
const AUTH_TOKEN_KEY = `sb-${getSupabaseProjectRef()}-auth-token`

interface UseAuthTokenOptions {
  /** Whether to redirect to login if no token */
  redirectOnMissing?: boolean
  /** Custom redirect path */
  redirectPath?: string
  /** Validate token with server (recommended for protected routes) */
  validateWithServer?: boolean
}

interface UseAuthTokenReturn {
  /** Whether auth token exists and is valid */
  hasToken: boolean
  /** Whether check is complete */
  isReady: boolean
  /** Whether token validation is in progress */
  isValidating: boolean
  /** Get the raw token value */
  getToken: () => string | null
  /** Clear the token */
  clearToken: () => void
}

/**
 * Hook for checking auth token with optional server validation
 * Use validateWithServer: true for protected routes to prevent client-side bypasses
 *
 * @example
 * ```tsx
 * // Quick check (localStorage only)
 * const { hasToken, isReady } = useAuthToken({ redirectOnMissing: true })
 *
 * // Secure check (validates with server)
 * const { hasToken, isReady } = useAuthToken({
 *   redirectOnMissing: true,
 *   validateWithServer: true // Recommended for protected routes
 * })
 *
 * if (!isReady) return <Loading />
 * if (!hasToken) return null // Will redirect
 * ```
 */
export function useAuthToken(options: UseAuthTokenOptions = {}): UseAuthTokenReturn {
  const {
    redirectOnMissing = false,
    redirectPath = ROUTES.login,
    validateWithServer = false
  } = options
  const router = useRouter()
  const [hasToken, setHasToken] = useState(false)
  const [isReady, setIsReady] = useState(false)
  const [isValidating, setIsValidating] = useState(false)

  useEffect(() => {
    const validateToken = async () => {
      const token = localStorage.getItem(AUTH_TOKEN_KEY)
      const tokenExists = !!token

      if (!tokenExists) {
        setHasToken(false)
        setIsReady(true)
        if (redirectOnMissing) {
          router.push(redirectPath)
        }
        return
      }

      // If server validation is requested, verify with Supabase
      if (validateWithServer) {
        setIsValidating(true)
        try {
          const supabase = createClient()
          const { data: { session } } = await supabase.auth.getSession()
          const user = session?.user ?? null
          const error = !user ? new Error('No session') : null

          if (error || !user) {
            // Token is invalid or expired - clear it
            localStorage.removeItem(AUTH_TOKEN_KEY)
            setHasToken(false)
            if (redirectOnMissing) {
              router.push(redirectPath)
            }
          } else {
            setHasToken(true)
          }
        } catch {
          // On error, assume token is invalid
          localStorage.removeItem(AUTH_TOKEN_KEY)
          setHasToken(false)
          if (redirectOnMissing) {
            router.push(redirectPath)
          }
        } finally {
          setIsValidating(false)
        }
      } else {
        // Quick check - only verify token exists
        setHasToken(true)
      }

      setIsReady(true)
    }

    validateToken()
  }, [redirectOnMissing, redirectPath, router, validateWithServer])

  const getToken = useCallback(() => {
    return localStorage.getItem(AUTH_TOKEN_KEY)
  }, [])

  const clearToken = useCallback(() => {
    localStorage.removeItem(AUTH_TOKEN_KEY)
    setHasToken(false)
  }, [])

  return {
    hasToken,
    isReady,
    isValidating,
    getToken,
    clearToken,
  }
}

/**
 * Check if auth token exists (non-hook version)
 * Use in event handlers or non-component code
 */
export function hasAuthToken(): boolean {
  if (typeof window === 'undefined') return false
  return !!localStorage.getItem(AUTH_TOKEN_KEY)
}

/**
 * Get auth token value (non-hook version)
 */
export function getAuthToken(): string | null {
  if (typeof window === 'undefined') return null
  return localStorage.getItem(AUTH_TOKEN_KEY)
}
