/**
 * Authorization helper functions
 * With the API migration, authorization is handled server-side.
 * These helpers now use JWT tokens and API calls.
 */

import { getAccessToken } from '@/lib/api/client'

export class AuthenticationError extends Error {
  constructor(message = 'User not authenticated') {
    super(message)
    this.name = 'AuthenticationError'
  }
}

export class ForbiddenError extends Error {
  constructor(message = 'Access denied to this resource') {
    super(message)
    this.name = 'ForbiddenError'
  }
}

export class NotFoundError extends Error {
  constructor(message = 'Resource not found') {
    super(message)
    this.name = 'NotFoundError'
  }
}

/**
 * Check if user is authenticated (has a valid token).
 * The API server handles actual authorization.
 */
export async function getAuthenticatedUser() {
  const token = getAccessToken()
  if (!token) {
    throw new AuthenticationError()
  }
  // Decode the JWT payload (not for verification, just for user info)
  try {
    const payload = JSON.parse(atob(token.split('.')[1]))
    return { id: payload.userId || payload.sub || payload.id, email: payload.email }
  } catch {
    throw new AuthenticationError()
  }
}

/**
 * These verification functions are now no-ops because the API server
 * handles all authorization via JWT middleware.
 */
export async function verifyDoerOwnership(_doerId: string): Promise<void> {
  // Authorization handled server-side
}

export async function verifyProjectAccess(_projectId: string): Promise<void> {
  // Authorization handled server-side
}

export async function getAuthenticatedDoer() {
  const user = await getAuthenticatedUser()
  return { id: user.id }
}
