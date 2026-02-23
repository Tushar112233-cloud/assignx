/**
 * @fileoverview Custom React hook for authentication state management and session handling.
 * @module hooks/use-auth
 *
 * Auth flow:
 * 1. signIn/signUp → saves user to localStorage immediately
 * 2. onAuthStateChange SIGNED_IN → saves user to localStorage (backup)
 * 3. initAuth on mount → reads user from localStorage (instant)
 * 4. All other hooks call getAuthUser() which reads from localStorage
 * 5. signOut → clears localStorage, cookies, and navigates to login
 */

"use client"

import { useEffect, useCallback, useMemo, useRef } from "react"
import { useRouter } from "next/navigation"
import { createClient, resetClient, getAuthUser, storeAuthUser, clearAuthUser } from "@/lib/supabase/client"
import { useAuthStore } from "@/store/auth-store"
import { ROUTES } from "@/lib/constants"
import { clearAppStorage } from "@/lib/utils"
import type { Profile, Supervisor, SupervisorActivation } from "@/types/database"

/**
 * Module-level flag to prevent duplicate auth initialization.
 * When multiple components call useAuth(), only the first triggers initAuth.
 * Reset on sign-out so the next sign-in properly initializes.
 */
let _authInitStarted = false

/**
 * Custom hook for authentication management
 * @returns Auth state and methods
 */
export function useAuth() {
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])

  const {
    user,
    supervisor,
    activation,
    isLoading,
    isAuthenticated,
    isOnboarded,
    setUser,
    setSupervisor,
    setActivation,
    setLoading,
    setOnboarded,
    clearAuth,
  } = useAuthStore()

  /**
   * Fetch user profile from database
   */
  const fetchProfile = useCallback(async (userId: string) => {
    const { data: profile } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", userId)
      .single()

    return profile as Profile | null
  }, [supabase])

  /**
   * Fetch supervisor data from database
   */
  const fetchSupervisor = useCallback(async (profileId: string) => {
    const { data: supervisorData } = await supabase
      .from("supervisors")
      .select("*")
      .eq("profile_id", profileId)
      .single()

    return supervisorData as Supervisor | null
  }, [supabase])

  /**
   * Fetch supervisor activation data from database
   */
  const fetchActivation = useCallback(async (supervisorId: string) => {
    const { data: activationData } = await supabase
      .from("supervisor_activation")
      .select("*")
      .eq("supervisor_id", supervisorId)
      .maybeSingle()

    return activationData as SupervisorActivation | null
  }, [supabase])

  // Stable refs for callbacks used inside effects
  const fetchProfileRef = useRef(fetchProfile)
  fetchProfileRef.current = fetchProfile
  const fetchSupervisorRef = useRef(fetchSupervisor)
  fetchSupervisorRef.current = fetchSupervisor
  const fetchActivationRef = useRef(fetchActivation)
  fetchActivationRef.current = fetchActivation
  const setUserRef = useRef(setUser)
  setUserRef.current = setUser
  const setSupervisorRef = useRef(setSupervisor)
  setSupervisorRef.current = setSupervisor
  const setActivationRef = useRef(setActivation)
  setActivationRef.current = setActivation
  const setLoadingRef = useRef(setLoading)
  setLoadingRef.current = setLoading
  const setOnboardedRef = useRef(setOnboarded)
  setOnboardedRef.current = setOnboarded
  const clearAuthRef = useRef(clearAuth)
  clearAuthRef.current = clearAuth

  /**
   * One-time auth initialization.
   * Reads user from localStorage (instant, synchronous).
   * Then fetches profile/supervisor data from Supabase.
   */
  useEffect(() => {
    if (_authInitStarted) {
      if (isLoading && user) {
        setLoadingRef.current(false)
      }
      return
    }
    _authInitStarted = true

    let isMounted = true

    const initAuth = async () => {
      setLoadingRef.current(true)

      try {
        // Reads from localStorage — instant, never hangs
        const authUser = await getAuthUser()

        if (!isMounted) return

        if (authUser) {
          let profile: Profile | null = null
          try {
            profile = await fetchProfileRef.current(authUser.id)
          } catch {
            // Profile fetch failed
          }

          if (!isMounted) return

          if (!profile) {
            setLoadingRef.current(false)
            return
          }

          setUserRef.current(profile)

          let supervisorData: Supervisor | null = null
          try {
            supervisorData = await fetchSupervisorRef.current(profile.id)
          } catch {
            // Supervisor fetch failed
          }

          if (!isMounted) return

          setSupervisorRef.current(supervisorData)

          if (supervisorData) {
            try {
              const activationData = await fetchActivationRef.current(supervisorData.id)
              if (activationData) setActivationRef.current(activationData)
            } catch {
              // Activation fetch failed
            }
          }

          setOnboardedRef.current(true)
        } else {
          // No user in localStorage — redirect if on protected route
          const pathname = window.location.pathname
          const isProtectedRoute = pathname.startsWith("/dashboard") ||
                                   pathname.startsWith("/projects") ||
                                   pathname.startsWith("/profile") ||
                                   pathname.startsWith("/doers") ||
                                   pathname.startsWith("/users") ||
                                   pathname.startsWith("/chat") ||
                                   pathname.startsWith("/earnings") ||
                                   pathname.startsWith("/resources") ||
                                   pathname.startsWith("/settings")

          if (isProtectedRoute) {
            window.location.href = ROUTES.login
            return
          }
        }
      } catch (err) {
        console.error("[useAuth] Auth initialization failed:", err)
        _authInitStarted = false
      }

      if (isMounted) {
        setLoadingRef.current(false)
      }
    }

    initAuth()

    return () => {
      isMounted = false
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [supabase])

  /**
   * Auth state change listener — always active.
   * Saves user to localStorage on SIGNED_IN so future page loads are instant.
   * Clears on SIGNED_OUT.
   */
  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event === "SIGNED_IN" && session?.user) {
          // Persist to localStorage for future page loads
          storeAuthUser(session.user)

          const profile = await fetchProfileRef.current(session.user.id)
          setUserRef.current(profile)

          if (profile) {
            const supervisorData = await fetchSupervisorRef.current(profile.id)
            setSupervisorRef.current(supervisorData)

            if (supervisorData) {
              const activationData = await fetchActivationRef.current(supervisorData.id)
              setActivationRef.current(activationData)
            }

            setOnboardedRef.current(!!supervisorData)
          }
        } else if (event === "SIGNED_OUT") {
          clearAuthUser()
          clearAuthRef.current()
          _authInitStarted = false
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

    // Persist to localStorage immediately so dashboard loads on redirect
    if (data.user) storeAuthUser(data.user)

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

    // Persist to localStorage immediately so dashboard loads on redirect
    if (data.user) storeAuthUser(data.user)

    return data
  }

  /**
   * Sign out
   * Clears all localStorage data and forces full page reload.
   * Resilient — always navigates to login even if signout API calls fail.
   */
  const signOut = async () => {
    clearAuth()
    _authInitStarted = false
    clearAppStorage()
    resetClient()

    try {
      await fetch('/api/auth/logout', { method: 'POST' })
    } catch {
      // ignore — navigate anyway
    }

    try {
      await supabase.auth.signOut()
    } catch {
      // ignore — navigate anyway
    }

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
      type: "sms",
    })

    if (error) throw error

    // Persist to localStorage immediately
    if (data.user) storeAuthUser(data.user)

    return data
  }

  return {
    user,
    supervisor,
    activation,
    isLoading,
    isAuthenticated,
    isOnboarded,
    signUp,
    signIn,
    signOut,
    sendPhoneOtp,
    verifyPhoneOtp,
    fetchProfile,
    fetchSupervisor,
    fetchActivation,
  }
}
