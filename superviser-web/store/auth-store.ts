/**
 * @fileoverview Zustand store for authentication state and user session management.
 * @module store/auth-store
 */

import { create } from "zustand"
import { persist } from "zustand/middleware"
import type { Profile, Supervisor, SupervisorActivation } from "@/types/database"

/**
 * Auth state interface
 */
interface AuthState {
  /** Current user profile */
  user: Profile | null
  /** Current supervisor data */
  supervisor: Supervisor | null
  /** Supervisor activation data */
  activation: SupervisorActivation | null
  /** Loading state */
  isLoading: boolean
  /** Whether user is authenticated */
  isAuthenticated: boolean
  /** Whether onboarding is complete */
  isOnboarded: boolean
  /** Set user profile */
  setUser: (user: Profile | null) => void
  /** Set supervisor data */
  setSupervisor: (supervisor: Supervisor | null) => void
  /** Set activation data */
  setActivation: (activation: SupervisorActivation | null) => void
  /** Set loading state */
  setLoading: (isLoading: boolean) => void
  /** Set onboarding status */
  setOnboarded: (isOnboarded: boolean) => void
  /** Clear all auth data */
  clearAuth: () => void
}

/**
 * Auth store for managing authentication state
 */
export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      supervisor: null,
      activation: null,
      isLoading: true,
      isAuthenticated: false,
      isOnboarded: false,
      setUser: (user) => set({ user, isAuthenticated: !!user }),
      setSupervisor: (supervisor) => set({ supervisor }),
      setActivation: (activation) => set({ activation }),
      setLoading: (isLoading) => set({ isLoading }),
      setOnboarded: (isOnboarded) => set({ isOnboarded }),
      clearAuth: () => set({
        user: null,
        supervisor: null,
        activation: null,
        isAuthenticated: false,
        isOnboarded: false,
      }),
    }),
    {
      name: "auth-storage",
      partialize: (state) => ({
        isOnboarded: state.isOnboarded,
      }),
    }
  )
)
