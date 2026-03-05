'use client'

import { useEffect } from 'react'
import { useRouter, usePathname } from 'next/navigation'
import { useAuth } from '@/hooks/useAuth'
import { MainShell } from '@/components/layouts/main-shell'

/**
 * Main application layout (Client Component)
 * Redirects to login if not authenticated.
 * Redirects to /training if training not completed.
 */
export default function MainLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const pathname = usePathname()
  const { user, doer, isLoading } = useAuth()

  useEffect(() => {
    if (isLoading) return
    if (!user) {
      router.push('/login')
      return
    }
    // If doer exists and training not completed, redirect to training page
    if (doer && !doer.training_completed && pathname !== '/training') {
      router.push('/training')
    }
  }, [user, doer, isLoading, router, pathname])

  if (isLoading || !user) {
    return null
  }

  // If training not completed, don't render main shell — redirect will happen
  if (doer && !doer.training_completed) {
    return null
  }

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
