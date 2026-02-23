import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { ROUTES } from '@/lib/constants'
import { SupportClient } from './support-client'

/** Prevent Next.js from caching this page — always fetch fresh auth data */
export const dynamic = 'force-dynamic'

/**
 * Help & Support server component
 * Fetches session from server-side httpOnly cookies
 */
export default async function SupportPage() {
  const supabase = await createClient()

  // Validate user server-side (getUser() verifies JWT with Supabase Auth server)
  const { data: { user }, error: userError } = await supabase.auth.getUser()

  // Redirect to login if no valid user
  if (!user || userError) {
    redirect(ROUTES.login)
  }

  // Fetch user profile for display
  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()

  // Pass user data to client component
  return <SupportClient userEmail={user.email || profile?.email || ''} />
}
