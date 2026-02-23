'use client'

import { useAuth } from '@/hooks/useAuth'
import { MainShell } from '@/components/layouts/main-shell'

/**
 * Main application layout (Client Component)
 * Authentication and routing protection is handled by middleware.
 * Uses client-side auth store for user data (no server-side getUser() calls).
 * This matches the user-web pattern where middleware handles all auth.
 */
export default function MainLayout({ children }: { children: React.ReactNode }) {
  const { user } = useAuth()

  // Build user data from auth store (cached in localStorage, populated by useAuth)
  const userData = {
    name: user?.full_name || user?.email?.split('@')[0] || 'Doer',
    email: user?.email || '',
    avatar: user?.avatar_url || '',
  }

  return (
    <MainShell userData={userData}>
      {children}
    </MainShell>
  )
}
