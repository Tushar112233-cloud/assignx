/**
 * @fileoverview Utility functions for class name merging and common helpers.
 * @module lib/utils
 */

import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Keys to clear from localStorage on logout
 * Includes Supabase auth tokens and app-specific cached data
 */
// Extract Supabase project ref from URL for dynamic storage key
const SUPABASE_PROJECT_REF = (
  process.env.NEXT_PUBLIC_SUPABASE_URL?.match(/https:\/\/([^.]+)\.supabase/)?.[1] || ""
)

export const APP_STORAGE_KEYS = [
  // Supabase auth token (project-specific, derived from env)
  ...(SUPABASE_PROJECT_REF ? [`sb-${SUPABASE_PROJECT_REF}-auth-token`] : []),

  // Cached user/supervisor data
  "cachedUser",
  "cachedSupervisor",
  "auth-storage",

  // Any onboarding state
  "onboarding_step",
  "profile_setup_data",
]

/**
 * Clears all app-related data from localStorage
 * Called on logout to prevent cached state issues
 */
export function clearAppStorage(): void {
  if (typeof window === "undefined") return

  // Clear known keys
  APP_STORAGE_KEYS.forEach((key) => {
    localStorage.removeItem(key)
  })

  // Pattern-based removal for any dynamic keys
  const keysToRemove: string[] = []
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    if (
      key &&
      (key.startsWith("sb-") || // All Supabase tokens
        key.startsWith("cached") || // All cached data
        key.startsWith("onboarding_") || // Onboarding state
        key.startsWith("supervisor_")) // Supervisor-specific data
    ) {
      keysToRemove.push(key)
    }
  }

  keysToRemove.forEach((key) => {
    localStorage.removeItem(key)
  })
}
