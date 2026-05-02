import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { Doer } from '@/types/database'

/**
 * Auth state interface
 * JWT sub = doer collection _id directly; no separate profile needed.
 */
interface AuthState {
  /** Current doer (the primary identity) */
  doer: Doer | null
  /** Loading state */
  isLoading: boolean
  /** Whether user is authenticated */
  isAuthenticated: boolean
  /** Whether onboarding is complete */
  isOnboarded: boolean
  /** Set doer data */
  setDoer: (doer: Doer | null) => void
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
      doer: null,
      isLoading: true,
      isAuthenticated: false,
      isOnboarded: false,
      setDoer: (doer) => set({ doer, isAuthenticated: !!doer }),
      setLoading: (isLoading) => set({ isLoading }),
      setOnboarded: (isOnboarded) => set({ isOnboarded }),
      clearAuth: () => set({
        doer: null,
        isLoading: true,
        isAuthenticated: false,
        isOnboarded: false,
      }),
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        doer: state.doer,
        isOnboarded: state.isOnboarded,
        isAuthenticated: state.isAuthenticated,
      }),
      onRehydrateStorage: () => (state, error) => {
        if (error) return
        // If we have cached doer from localStorage, clear loading immediately.
        // Pages can render with cached data while useAuth refreshes in background.
        // If no cached data, keep loading=true so skeleton shows until useAuth completes.
        if (state && state.doer) {
          state.setLoading(false)
        }
      },
    }
  )
)
