import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Keys to clear from localStorage on logout
 * Includes Supabase auth tokens and app-specific cached data
 */
export const APP_STORAGE_KEYS = [
  // Supabase auth token (project-specific)
  'sb-gtryzxeofrvjbfbojuhx-auth-token',

  // Zustand persisted auth store
  'auth-storage',

  // Cached user/doer data
  'cachedUser',
  'cachedDoer',

  // Any onboarding state
  'onboarding_step',
  'profile_setup_data',
]

/**
 * Clears all app-related data from localStorage
 * Called on logout to prevent cached state issues
 */
export function clearAppStorage(): void {
  if (typeof window === 'undefined') return

  // Clear known keys
  APP_STORAGE_KEYS.forEach((key) => {
    localStorage.removeItem(key)
  })

  // Pattern-based removal for any dynamic keys
  const keysToRemove: string[] = []
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    if (key && (
      key.startsWith('sb-') ||           // All Supabase tokens
      key.startsWith('cached') ||         // All cached data
      key.startsWith('onboarding_') ||    // Onboarding state
      key.startsWith('doer_')             // Doer-specific data
    )) {
      keysToRemove.push(key)
    }
  }

  keysToRemove.forEach((key) => {
    localStorage.removeItem(key)
  })
}
