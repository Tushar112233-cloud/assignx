'use client'

import { useEffect, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { apiClient, getAccessToken, clearTokens } from '@/lib/api/client'
import { useAuthStore } from '@/stores/authStore'
import { ROUTES } from '@/lib/constants'
import { clearAppStorage } from '@/lib/utils'
import { logger } from '@/lib/logger'
import type { Profile, Doer } from '@/types/database'

let _authInitStarted = false
let _authInitComplete = false

export function useAuth() {
  const router = useRouter()

  const {
    user,
    doer,
    isLoading,
    isAuthenticated,
    isOnboarded,
    setUser,
    setDoer,
    setLoading,
    setOnboarded,
    clearAuth,
  } = useAuthStore()

  const fetchProfile = useCallback(async (_userId: string) => {
    try {
      const data = await apiClient<Profile>('/api/profiles/me')
      return data
    } catch {
      return null
    }
  }, [])

  const fetchDoer = useCallback(async (profileId: string) => {
    try {
      const data = await apiClient<Doer>(`/api/doers/by-profile/${profileId}`)
      return data
    } catch {
      return null
    }
  }, [])

  const fetchProfileRef = useRef(fetchProfile)
  fetchProfileRef.current = fetchProfile
  const fetchDoerRef = useRef(fetchDoer)
  fetchDoerRef.current = fetchDoer
  const routerRef = useRef(router)
  routerRef.current = router
  const setUserRef = useRef(setUser)
  setUserRef.current = setUser
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
        if (!token) {
          logger.debug('Auth', 'No token found')
          clearAuthRef.current()
          return
        }

        // Decode JWT to get user ID
        let userId: string
        try {
          const payload = JSON.parse(atob(token.split('.')[1]))
          userId = payload.userId || payload.sub || payload.id
        } catch {
          logger.debug('Auth', 'Invalid token')
          clearAuthRef.current()
          return
        }

        if (!isMounted) return

        logger.debug('Auth', 'Token found, fetching profile')
        const profile = await fetchProfileRef.current(userId)
        if (!isMounted) return

        if (!profile) {
          logger.debug('Auth', 'No profile found, redirecting to login')
          routerRef.current.push(ROUTES.login)
          return
        }

        setUserRef.current(profile)

        const doerData = await fetchDoerRef.current(profile.id)
        if (!isMounted) return

        if (!doerData) {
          const pathname = window.location.pathname
          if (pathname !== '/profile-setup') {
            logger.debug('Auth', 'No doer found, redirecting to profile-setup')
            routerRef.current.push('/profile-setup')
          }
          return
        }

        setDoerRef.current(doerData)
        setOnboardedRef.current(true)
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

  const signUp = async (email: string, _password: string, fullName: string, phone: string) => {
    return apiClient('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, fullName, phone, role: 'doer' }),
      skipAuth: true,
    })
  }

  const signIn = async (email: string, _password: string) => {
    const { sendMagicLink } = await import('@/lib/api/auth')
    return sendMagicLink(email, 'doer')
  }

  const signOut = async () => {
    clearAuth()
    _authInitStarted = false
    _authInitComplete = false

    clearAppStorage()

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
    user,
    doer,
    isLoading,
    isAuthenticated,
    isOnboarded,
    signUp,
    signIn,
    signOut,
    sendPhoneOtp,
    verifyPhoneOtp,
    fetchProfile,
    fetchDoer,
  }
}
