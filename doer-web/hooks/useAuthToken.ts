'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { getAccessToken, clearTokens, apiClient } from '@/lib/api/client'
import { ROUTES } from '@/lib/constants'

interface UseAuthTokenOptions {
  redirectOnMissing?: boolean
  redirectPath?: string
  validateWithServer?: boolean
}

interface UseAuthTokenReturn {
  hasToken: boolean
  isReady: boolean
  isValidating: boolean
  getToken: () => string | null
  clearToken: () => void
}

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
      const token = getAccessToken()
      const tokenExists = !!token

      if (!tokenExists) {
        setHasToken(false)
        setIsReady(true)
        if (redirectOnMissing) {
          router.push(redirectPath)
        }
        return
      }

      if (validateWithServer) {
        setIsValidating(true)
        try {
          await apiClient('/api/auth/me')
          setHasToken(true)
        } catch {
          clearTokens()
          setHasToken(false)
          if (redirectOnMissing) {
            router.push(redirectPath)
          }
        } finally {
          setIsValidating(false)
        }
      } else {
        setHasToken(true)
      }

      setIsReady(true)
    }

    validateToken()
  }, [redirectOnMissing, redirectPath, router, validateWithServer])

  const getToken = useCallback(() => {
    return getAccessToken()
  }, [])

  const clearToken = useCallback(() => {
    clearTokens()
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

export function hasAuthToken(): boolean {
  return !!getAccessToken()
}

export function getAuthToken(): string | null {
  return getAccessToken()
}
