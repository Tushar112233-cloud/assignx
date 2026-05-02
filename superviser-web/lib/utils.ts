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
 * Keys to clear from localStorage on logout.
 * Includes JWT tokens and app-specific cached data.
 */
export const APP_STORAGE_KEYS = [
  // JWT tokens
  "supervisor_access_token",
  "supervisor_refresh_token",

  // Cached user data
  "supervisor_auth_user",
  "cachedUser",
  "cachedSupervisor",
  "auth-storage",

  // Any onboarding state
  "onboarding_step",
  "profile_setup_data",
]

/**
 * Clears all app-related data from localStorage.
 * Called on logout to prevent cached state issues.
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
      (key.startsWith("sb-") || // Legacy Supabase tokens (cleanup)
        key.startsWith("cached") ||
        key.startsWith("onboarding_") ||
        key.startsWith("supervisor_"))
    ) {
      keysToRemove.push(key)
    }
  }

  keysToRemove.forEach((key) => {
    localStorage.removeItem(key)
  })
}
