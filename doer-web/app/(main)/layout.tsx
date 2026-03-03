'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/hooks/useAuth'
import { MainShell } from '@/components/layouts/main-shell'

/**
 * Main application layout (Client Component)
 * Redirects to login if not authenticated (like supervisor dashboard layout).
 * Uses client-side auth store for user data (cached in localStorage, populated by useAuth).
 */
export default function MainLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const { user, isLoading } = useAuth()

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login')
    }
  }, [user, isLoading, router])

  if (isLoading || !user) {
    return null
  }

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
