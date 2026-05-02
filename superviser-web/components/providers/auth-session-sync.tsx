"use client"

/**
 * @fileoverview Auth session sync component.
 * No longer needed with JWT-based auth - kept as a no-op for backward compatibility.
 */

interface AuthSessionSyncProps {
  accessToken: string | null
  refreshToken: string | null
}

export function AuthSessionSync({ accessToken, refreshToken }: AuthSessionSyncProps) {
  // No-op: JWT tokens are managed by lib/api/client.ts
  // This component is kept for backward compatibility with any layouts that render it.
  return null
}
