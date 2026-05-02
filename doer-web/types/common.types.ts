/**
 * Common types and enums used across the application
 * @module types/common
 */

/**
 * Generic JSON type for flexible data storage
 * Supports primitives, objects, and arrays
 */
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

/**
 * User role types in the system
 * - user: Basic user with limited access
 * - doer: Worker who completes tasks
 * - supervisor: Oversees projects and doers
 * - admin: Full system access
 */
export type UserRole = 'user' | 'doer' | 'supervisor' | 'admin'

/**
 * Educational qualification levels
 * Used for doer profile and skill matching
 */
export type Qualification = 'high_school' | 'undergraduate' | 'postgraduate' | 'phd'

/**
 * Experience level for skills and matching
 * Determines task complexity assignment
 */
export type ExperienceLevel = 'beginner' | 'intermediate' | 'pro'

/**
 * Activation flow status
 * Tracks doer onboarding progress
 */
export type ActivationStatus = 'pending' | 'in_progress' | 'completed'
