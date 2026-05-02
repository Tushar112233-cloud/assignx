'use client'

import { useAuth } from '@/hooks/useAuth'
import { Skeleton } from '@/components/ui/skeleton'
import { SettingsClient } from './settings-client'

/**
 * Settings page
 * Authentication and routing protection is handled by middleware.
 * Uses client-side auth to avoid server-side getUser() hangs.
 */
export default function SettingsPage() {
  const { user, doer, isLoading: authLoading } = useAuth()

  if (authLoading) {
    return (
      <div className="space-y-6 py-8">
        <Skeleton className="h-32 w-full rounded-2xl" />
        <Skeleton className="h-12 w-full max-w-3xl rounded-full" />
        <Skeleton className="h-64 w-full rounded-2xl" />
      </div>
    )
  }

  return (
    <SettingsClient
      userEmail={user?.email || ''}
      profile={user}
      doer={doer}
    />
  )
}
