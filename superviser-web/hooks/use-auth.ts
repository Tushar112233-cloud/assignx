/**
 * @fileoverview Custom React hook for authentication state management.
 * Uses Express API + JWT instead of Supabase.
 * @module hooks/use-auth
 *
 * Auth flow:
 * 1. signIn/signUp -> stores JWT tokens + user in localStorage
 * 2. initAuth on mount -> reads user from localStorage, fetches profile from API
 * 3. signOut -> clears tokens, navigates to login
 */

"use client"

import { useEffect, useCallback, useRef } from "react"
import { useRouter } from "next/navigation"
import { useAuthStore } from "@/store/auth-store"
import { ROUTES } from "@/lib/constants"
import { clearAppStorage } from "@/lib/utils"
import { apiFetch } from "@/lib/api/client"
import { clearTokens, getAccessToken } from "@/lib/api/client"
import {
  getStoredUser,
  storeUser,
  clearStoredUser,
  signUp as apiSignUp,
  signInWithPassword as apiSignIn,
  logout as apiLogout,
  sendMagicLink,
  verifyOTP as apiVerifyOTP,
} from "@/lib/api/auth"
import { disconnectSocket } from "@/lib/socket/client"
import type { Profile, Supervisor, SupervisorActivation } from "@/types/database"

/**
 * Module-level flag to prevent duplicate auth initialization.
 */
let _authInitStarted = false

/**
 * Custom hook for authentication management
 */
export function useAuth() {
  const router = useRouter()

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
   * Fetch user profile from API
   */
  const fetchProfile = useCallback(async (userId: string) => {
    try {
      const profile = await apiFetch<Profile>(`/api/profiles/${userId}`)
      return profile
    } catch {
      return null
    }
  }, [])

  /**
   * Fetch supervisor data from API
   */
  const fetchSupervisor = useCallback(async (_profileId: string) => {
    try {
      const supervisorData = await apiFetch<Supervisor>("/api/supervisors/me")
      return supervisorData
    } catch {
      return null
    }
  }, [])

  /**
   * Fetch supervisor activation data from API
   */
  const fetchActivation = useCallback(async (_supervisorId: string) => {
    try {
      const activationData = await apiFetch<SupervisorActivation>("/api/supervisors/me/activation")
      return activationData
    } catch {
      return null
    }
  }, [])

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
   * Reads user from localStorage then fetches profile/supervisor data from API.
   */
  useEffect(() => {
    if (_authInitStarted) {
      // If store was rehydrated with cached user, ensure loading is cleared
      if (isLoading && user) {
        setLoadingRef.current(false)
      }
      return
    }
    _authInitStarted = true

    let isMounted = true

    const initAuth = async () => {
      // Only set loading=true if we don't already have cached user data from rehydration.
      // If the Zustand store was rehydrated with a cached user, onRehydrateStorage already
      // set loading=false — re-setting it to true causes a blank flash.
      const currentState = useAuthStore.getState()
      if (!currentState.user) {
        setLoadingRef.current(true)
      }

      try {
        const token = getAccessToken()
        const authUser = getStoredUser()

        if (!isMounted) return

        if (token && authUser) {
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
          // No token -- redirect if on protected route
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
  }, [])

  /**
   * Sign up with email and password
   */
  const signUp = async (email: string, password: string, fullName: string, phone: string) => {
    const data = await apiSignUp(email, password, fullName, phone)
    return data
  }

  /**
   * Sign in with email and password
   */
  const signIn = async (email: string, password: string) => {
    const data = await apiSignIn(email, password)
    return data
  }

  /**
   * Sign out
   */
  const signOut = async () => {
    clearAuth()
    _authInitStarted = false
    clearAppStorage()
    disconnectSocket()

    try {
      await apiLogout()
    } catch {
      // ignore -- navigate anyway
    }

    clearTokens()
    clearStoredUser()

    window.location.href = ROUTES.login
  }

  /**
   * Send OTP to phone number
   */
  const sendPhoneOtp = async (phone: string) => {
    const data = await apiFetch("/api/auth/send-otp", {
      method: "POST",
      body: JSON.stringify({ phone }),
    })
    return data
  }

  /**
   * Verify phone OTP
   */
  const verifyPhoneOtp = async (phone: string, token: string) => {
    const data = await apiVerifyOTP(phone, token)
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
