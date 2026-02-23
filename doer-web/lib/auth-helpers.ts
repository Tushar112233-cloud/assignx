/**
 * Authorization helper functions
 * Provides consistent authorization checks across all services.
 *
 * Includes per-session caching for ownership/access verification
 * to avoid redundant database queries on every service call.
 * Cache is automatically invalidated when the authenticated user changes.
 */

import { createClient } from '@/lib/supabase/client'

/** Error thrown when user is not authenticated */
export class AuthenticationError extends Error {
  constructor(message = 'User not authenticated') {
    super(message)
    this.name = 'AuthenticationError'
  }
}

/** Error thrown when user doesn't have permission */
export class ForbiddenError extends Error {
  constructor(message = 'Access denied to this resource') {
    super(message)
    this.name = 'ForbiddenError'
  }
}

/** Error thrown when resource is not found */
export class NotFoundError extends Error {
  constructor(message = 'Resource not found') {
    super(message)
    this.name = 'NotFoundError'
  }
}

// --- Per-session verification cache ---
// Doer ownership and project access are immutable within a session.
// Caching avoids 2-4 redundant DB queries per service call.
// Cache auto-resets when the authenticated user ID changes or on page reload.
let _cachedUserId: string | null = null
const _verifiedDoerIds = new Set<string>()
const _verifiedProjectIds = new Set<string>()

function _resetCacheIfUserChanged(userId: string) {
  if (_cachedUserId !== userId) {
    _verifiedDoerIds.clear()
    _verifiedProjectIds.clear()
    _cachedUserId = userId
  }
}

/**
 * Get the currently authenticated user.
 * Uses getSession() which reads from local storage (instant, no network call).
 * The server-side proxy already validates JWTs, so browser-side verification
 * via getUser() is unnecessary and causes indefinite hangs.
 * @throws AuthenticationError if user is not authenticated
 */
export async function getAuthenticatedUser() {
  const supabase = createClient()

  const { data: { session }, error } = await supabase.auth.getSession()

  if (error || !session?.user) {
    throw new AuthenticationError()
  }

  return session.user
}

/**
 * Verify that the authenticated user owns the specified doer record.
 * Results are cached per session to avoid redundant DB lookups.
 * @param doerId - The doer ID to check ownership of
 * @throws AuthenticationError if user is not authenticated
 * @throws ForbiddenError if user doesn't own this doer record
 * @throws NotFoundError if doer record doesn't exist
 */
export async function verifyDoerOwnership(doerId: string): Promise<void> {
  const user = await getAuthenticatedUser()
  _resetCacheIfUserChanged(user.id)

  if (_verifiedDoerIds.has(doerId)) return

  const supabase = createClient()

  const { data: doer, error } = await supabase
    .from('doers')
    .select('profile_id')
    .eq('id', doerId)
    .single()

  if (error || !doer) {
    throw new NotFoundError('Doer record not found')
  }

  if (doer.profile_id !== user.id) {
    throw new ForbiddenError('You do not have permission to access this resource')
  }

  _verifiedDoerIds.add(doerId)
}

/**
 * Verify that the authenticated user owns the specified project
 * (either as the assigned doer or has supervisor role).
 * Results are cached per session to avoid redundant DB lookups.
 * @param projectId - The project ID to check access to
 * @throws AuthenticationError if user is not authenticated
 * @throws ForbiddenError if user doesn't have access to this project
 * @throws NotFoundError if project doesn't exist
 */
export async function verifyProjectAccess(projectId: string): Promise<void> {
  const user = await getAuthenticatedUser()
  _resetCacheIfUserChanged(user.id)

  if (_verifiedProjectIds.has(projectId)) return

  const supabase = createClient()

  // Get the user's doer record
  const { data: doer } = await supabase
    .from('doers')
    .select('id')
    .eq('profile_id', user.id)
    .single()

  // Get the project and check if user is the assigned doer
  const { data: project, error } = await supabase
    .from('projects')
    .select('doer_id, supervisor_id')
    .eq('id', projectId)
    .single()

  if (error || !project) {
    throw new NotFoundError('Project not found')
  }

  // Check if user is either the assigned doer or the supervisor
  const isAssignedDoer = doer && project.doer_id === doer.id

  // supervisor_id is a FK to the supervisors table, not profiles.
  // Look up the supervisor's profile_id to compare correctly.
  let isSupervisor = false
  if (project.supervisor_id) {
    const { data: supervisor } = await supabase
      .from('supervisors')
      .select('profile_id')
      .eq('id', project.supervisor_id)
      .single()
    isSupervisor = supervisor?.profile_id === user.id
  }

  if (!isAssignedDoer && !isSupervisor) {
    throw new ForbiddenError('You do not have permission to access this project')
  }

  _verifiedProjectIds.add(projectId)
}

/**
 * Get the authenticated user's doer record
 * @throws AuthenticationError if user is not authenticated
 * @throws NotFoundError if user doesn't have a doer record
 * @returns The doer record
 */
export async function getAuthenticatedDoer() {
  const supabase = createClient()
  const user = await getAuthenticatedUser()

  const { data: doer, error } = await supabase
    .from('doers')
    .select('*')
    .eq('profile_id', user.id)
    .single()

  if (error || !doer) {
    throw new NotFoundError('Doer profile not found')
  }

  return doer
}

/**
 * Verify that the authenticated user owns the specified profile
 * @param profileId - The profile ID to check ownership of
 * @throws AuthenticationError if user is not authenticated
 * @throws ForbiddenError if user doesn't own this profile
 */
export async function verifyProfileOwnership(profileId: string): Promise<void> {
  const user = await getAuthenticatedUser()

  if (user.id !== profileId) {
    throw new ForbiddenError('You do not have permission to access this profile')
  }
}
