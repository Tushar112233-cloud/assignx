/**
 * @fileoverview Zustand store for authentication state and supervisor session management.
 * @module store/auth-store
 */

import { create } from "zustand"
import { persist } from "zustand/middleware"
import type { Supervisor, SupervisorActivation } from "@/types/database"

/**
 * Auth state interface
 */
interface AuthState {
  /** Current supervisor (primary identity) */
  supervisor: Supervisor | null
  /** Supervisor activation data */
  activation: SupervisorActivation | null
  /** Loading state */
  isLoading: boolean
  /** Whether supervisor is authenticated */
  isAuthenticated: boolean
  /** Whether onboarding is complete */
  isOnboarded: boolean
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
      supervisor: null,
      activation: null,
      isLoading: true,
      isAuthenticated: false,
      isOnboarded: false,
      setSupervisor: (supervisor) => set({ supervisor, isAuthenticated: !!supervisor }),
      setActivation: (activation) => set({ activation }),
      setLoading: (isLoading) => set({ isLoading }),
      setOnboarded: (isOnboarded) => set({ isOnboarded }),
      clearAuth: () => set({
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
        supervisor: state.supervisor,
        isAuthenticated: state.isAuthenticated,
      }),
      onRehydrateStorage: () => (state, error) => {
        if (error) return
        // If cached supervisor data exists, stop loading immediately so pages can render
        if (state && state.supervisor) {
          state.setLoading(false)
        }
      },
    }
  )
)
