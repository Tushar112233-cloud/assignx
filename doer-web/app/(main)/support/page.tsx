'use client'

import { useAuth } from '@/hooks/useAuth'
import { SupportClient } from './support-client'

/**
 * Help & Support page
 * Uses client-side auth via useAuth hook
 */
export default function SupportPage() {
  const { user } = useAuth()

  return <SupportClient userEmail={user?.email || ''} />
}
