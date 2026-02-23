'use client'

import { useEffect, useCallback, useMemo, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { useAuthStore } from '@/stores/authStore'
import { API_ROUTES, ROUTES } from '@/lib/constants'
import { clearAppStorage } from '@/lib/utils'
import { logger } from '@/lib/logger'
import type { Profile, Doer } from '@/types/database'

/**
 * Module-level flag to prevent duplicate auth initialization.
 * When multiple components call useAuth(), only the first triggers initAuth.
 * Reset on sign-out so the next sign-in properly initializes.
 */
let _authInitStarted = false

/**
 * Module-level flag that tracks whether initAuth has COMPLETED (not just started).
 * The early-return branch only clears isLoading when this is true, preventing
 * premature loading clearance while initAuth is still fetching user/doer data.
 */
let _authInitComplete = false

/**
 * Custom hook for authentication management.
 * Uses a singleton initialization pattern so navigating between pages
 * does NOT re-fetch auth data or flash loading skeletons.
 */
export function useAuth() {
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])

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

  /**
   * Fetch user profile from database
   */
  const fetchProfile = useCallback(async (userId: string) => {
    const { data: profile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single()

    return profile as Profile | null
  }, [supabase])

  /**
   * Fetch doer data from database
   */
  const fetchDoer = useCallback(async (profileId: string) => {
    const { data: doerData } = await supabase
      .from('doers')
      .select('*')
      .eq('profile_id', profileId)
      .single()

    return doerData as Doer | null
  }, [supabase])

  // Stable refs for callbacks used inside effects
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

  /**
   * One-time auth initialization.
   * Runs only once across the entire app lifecycle (until sign-out resets it).
   * Subsequent component mounts that call useAuth() skip re-fetching.
   */
  useEffect(() => {
    if (_authInitStarted) {
      // Auth init was already started by another component (e.g., NavUser).
      if (_authInitComplete) {
        if (isLoading) {
          setLoadingRef.current(false)
        }
        return
      }
      // Init started but NOT complete — poll until done so loading clears ASAP.
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
        // Use getSession() instead of getUser() — getSession() reads from local
        // storage (instant, no network call). getUser() makes an HTTP request to
        // the Supabase Auth server which hangs indefinitely on the browser client.
        // Server-side proxy already validates the JWT, so browser verification
        // via getUser() is redundant.
        const { data: { session }, error: sessionError } = await supabase.auth.getSession()
        const authUser = session?.user ?? null
        logger.debug('Auth', 'Session:', session ? 'Found' : 'None', sessionError ? 'Error occurred' : '')

        if (!authUser || sessionError) {
          logger.debug('Auth', 'No valid session found')
          clearAuthRef.current()
          return
        }
        if (!isMounted) return

        logger.debug('Auth', 'User found, fetching profile')
        const profile = await fetchProfileRef.current(authUser.id)
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

    // Safety timeout: if initAuth hasn't completed after 12s, force-clear loading.
    // The Supabase client has a 10s fetch timeout per call. This safety timeout
    // must be longer so the fetch timeout resolves first under normal conditions.
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
  }, [supabase])

  /**
   * Auth state change listener — always active.
   * Separate from init so it stays alive across the session.
   */
  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event === 'SIGNED_IN' && session?.user) {
          const profile = await fetchProfileRef.current(session.user.id)
          setUserRef.current(profile)

          if (profile) {
            const doerData = await fetchDoerRef.current(profile.id)
            setDoerRef.current(doerData)
            setOnboardedRef.current(!!doerData)
          }
        } else if (event === 'SIGNED_OUT') {
          clearAuthRef.current()
          _authInitStarted = false
          _authInitComplete = false
        }
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [supabase])

  /**
   * Sign up with email and password
   */
  const signUp = async (email: string, password: string, fullName: string, phone: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
          phone,
        },
      },
    })

    if (error) throw error
    return data
  }

  /**
   * Sign in with email and password
   */
  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) throw error
    return data
  }

  /**
   * Sign out
   * Clears all localStorage data and forces full page reload
   */
  const signOut = async () => {
    // Clear auth store and reset init flags immediately
    clearAuth()
    _authInitStarted = false
    _authInitComplete = false

    // Clear all localStorage (auth tokens, cached data)
    clearAppStorage()

    // Server-side signout clears auth cookies — best-effort, don't block navigation on failure
    try {
      await fetch(API_ROUTES.auth.logout, { method: 'POST' })
    } catch {
      // Server logout failed — proceed anyway; client-side signout still clears browser session
    }

    // Client-side signout revokes the token
    try {
      await supabase.auth.signOut()
    } catch {
      // Ignore errors — navigate regardless
    }

    // Force full page reload to clear all cached React/Next.js state
    window.location.href = ROUTES.login
  }

  /**
   * Send OTP to phone number
   */
  const sendPhoneOtp = async (phone: string) => {
    const { data, error } = await supabase.auth.signInWithOtp({
      phone,
    })

    if (error) throw error
    return data
  }

  /**
   * Verify phone OTP
   */
  const verifyPhoneOtp = async (phone: string, token: string) => {
    const { data, error } = await supabase.auth.verifyOtp({
      phone,
      token,
      type: 'sms',
    })

    if (error) throw error
    return data
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
