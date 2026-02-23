import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { Profile, Doer } from '@/types/database'

/**
 * Auth state interface
 */
interface AuthState {
  /** Current user profile */
  user: Profile | null
  /** Current doer data */
  doer: Doer | null
  /** Loading state */
  isLoading: boolean
  /** Whether user is authenticated */
  isAuthenticated: boolean
  /** Whether onboarding is complete */
  isOnboarded: boolean
  /** Set user profile */
  setUser: (user: Profile | null) => void
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
      user: null,
      doer: null,
      isLoading: true,
      isAuthenticated: false,
      isOnboarded: false,
      setUser: (user) => set({ user, isAuthenticated: !!user }),
      setDoer: (doer) => set({ doer }),
      setLoading: (isLoading) => set({ isLoading }),
      setOnboarded: (isOnboarded) => set({ isOnboarded }),
      clearAuth: () => set({
        user: null,
        doer: null,
        isLoading: true,
        isAuthenticated: false,
        isOnboarded: false,
      }),
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        isOnboarded: state.isOnboarded,
        user: state.user,
        doer: state.doer,
        isAuthenticated: state.isAuthenticated,
      }),
      onRehydrateStorage: () => (state, error) => {
        if (error) return
        // If we have cached user/doer from localStorage, clear loading immediately.
        // Pages can render with cached data while useAuth refreshes in background.
        // If no cached data, keep loading=true so skeleton shows until useAuth completes.
        if (state && (state.user || state.doer)) {
          state.setLoading(false)
        }
      },
    }
  )
)
