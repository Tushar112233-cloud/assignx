'use client'

import { useEffect, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { apiClient, getAccessToken, clearTokens } from '@/lib/api/client'
import { useAuthStore } from '@/stores/authStore'
import { ROUTES } from '@/lib/constants'
import { clearAppStorage } from '@/lib/utils'
import { logger } from '@/lib/logger'
import { getStoredUser, clearStoredUser } from '@/lib/api/auth'
import type { Doer } from '@/types/database'

let _authInitStarted = false
let _authInitComplete = false

export function useAuth() {
  const router = useRouter()

  const {
    doer,
    isLoading,
    isAuthenticated,
    isOnboarded,
    setDoer,
    setLoading,
    setOnboarded,
    clearAuth,
  } = useAuthStore()

  const fetchDoer = useCallback(async () => {
    try {
      const data = await apiClient<Doer>('/api/doers/me')
      return data
    } catch {
      return null
    }
  }, [])

  const fetchDoerRef = useRef(fetchDoer)
  fetchDoerRef.current = fetchDoer
  const routerRef = useRef(router)
  routerRef.current = router
  const setDoerRef = useRef(setDoer)
  setDoerRef.current = setDoer
  const setLoadingRef = useRef(setLoading)
  setLoadingRef.current = setLoading
  const setOnboardedRef = useRef(setOnboarded)
  setOnboardedRef.current = setOnboarded
  const clearAuthRef = useRef(clearAuth)
  clearAuthRef.current = clearAuth

  useEffect(() => {
    if (_authInitStarted) {
      if (_authInitComplete) {
        if (isLoading) {
          setLoadingRef.current(false)
        }
        return
      }
      const poll = setInterval(() => {
        if (_authInitComplete) {
          clearInterval(poll)
          setLoadingRef.current(false)
        }
      }, 200)
      return () => clearInterval(poll)
    }
    _authInitStarted = true

    let isMounted = true

    const initAuth = async () => {
      logger.debug('Auth', 'Initializing auth...')

      try {
        const token = getAccessToken()
        const storedUser = getStoredUser()

        if (!token) {
          logger.debug('Auth', 'No token found')
          clearAuthRef.current()

          // Redirect to login if on a protected route
          const pathname = window.location.pathname
          const isProtectedRoute = pathname.startsWith('/dashboard') ||
                                   pathname.startsWith('/projects') ||
                                   pathname.startsWith('/profile') ||
                                   pathname.startsWith('/resources') ||
                                   pathname.startsWith('/reviews') ||
                                   pathname.startsWith('/settings') ||
                                   pathname.startsWith('/statistics') ||
                                   pathname.startsWith('/support')

          if (isProtectedRoute) {
            window.location.href = ROUTES.login
          }
          return
        }

        // Decode JWT to get doer ID (sub = doer collection _id)
        let userId: string
        try {
          const payload = JSON.parse(atob(token.split('.')[1]))
          userId = payload.sub || payload.userId || payload.id
        } catch {
          logger.debug('Auth', 'Invalid token')
          clearAuthRef.current()
          return
        }

        // If we have a stored doer, set it immediately for fast render
        if (storedUser && !useAuthStore.getState().doer) {
          setDoerRef.current(storedUser as unknown as Doer)
        }

        if (!isMounted) return

        logger.debug('Auth', 'Token found, fetching doer', { userId })
        const doerData = await fetchDoerRef.current()
        if (!isMounted) return

        if (!doerData) {
          // No doer record — registration may not have completed properly.
          // Redirect to login so the user can re-authenticate.
          logger.debug('Auth', 'No doer found, redirecting to login')
          clearAuthRef.current()
          window.location.href = ROUTES.login
          return
        }

        setDoerRef.current(doerData)
        setOnboardedRef.current(doerData.onboardingCompleted ?? true)
      } catch (error) {
        logger.error('Auth', 'Error during init:', error)
      } finally {
        setLoadingRef.current(false)
        _authInitComplete = true
        logger.debug('Auth', 'Init complete')
      }
    }

    const safetyTimeout = setTimeout(() => {
      if (!_authInitComplete) {
        setLoadingRef.current(false)
        _authInitComplete = true
      }
    }, 12000)

    initAuth().finally(() => clearTimeout(safetyTimeout))

    return () => {
      isMounted = false
      clearTimeout(safetyTimeout)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  // Listen for storage events (token changes from other tabs)
  useEffect(() => {
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === 'access_token') {
        if (!e.newValue) {
          clearAuthRef.current()
          _authInitStarted = false
          _authInitComplete = false
        }
      }
    }

    window.addEventListener('storage', handleStorageChange)
    return () => window.removeEventListener('storage', handleStorageChange)
  }, [])

  const signUp = async (email: string, _password: string, _fullName: string, _phone: string) => {
    // Registration is handled via send-otp -> doer-signup flow
    const { sendOTP: sendOTPFn } = await import('@/lib/api/auth')
    return sendOTPFn(email, 'signup', 'doer')
  }

  const signIn = async (email: string, _password: string) => {
    const { sendOTP } = await import('@/lib/api/auth')
    return sendOTP(email, 'login', 'doer')
  }

  const signOut = async () => {
    clearAuth()
    _authInitStarted = false
    _authInitComplete = false

    clearAppStorage()
    clearStoredUser()

    try {
      await apiClient('/api/auth/logout', { method: 'POST' })
    } catch {
      // Best effort
    }

    clearTokens()
    window.location.href = ROUTES.login
  }

  const sendPhoneOtp = async (_phone: string) => {
    throw new Error('Phone OTP not supported')
  }

  const verifyPhoneOtp = async (_phone: string, _token: string) => {
    throw new Error('Phone OTP not supported')
  }

  return {
    user: doer,
    doer,
    isLoading,
    isAuthenticated,
    isOnboarded,
    signUp,
    signIn,
    signOut,
    sendPhoneOtp,
    verifyPhoneOtp,
    fetchDoer,
  }
}
