'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { SplashScreen } from '@/components/onboarding/SplashScreen'
import { ROUTES } from '@/lib/constants'

/**
 * Home page - Entry point for the application
 * Shows splash screen and redirects based on auth state
 */
export default function HomePage() {
  const router = useRouter()
  const [showSplash, setShowSplash] = useState(true)

  useEffect(() => {
    if (showSplash) return

    const checkAuthAndRedirect = async () => {
      const hasSeenOnboarding = localStorage.getItem('hasSeenOnboarding')

      if (hasSeenOnboarding) {
        // Check if user is authenticated via Supabase
        try {
          const { createClient } = await import('@/lib/supabase/client')
          const supabase = createClient()
          const { data: { session } } = await supabase.auth.getSession()

          if (session?.user) {
            router.push(ROUTES.dashboard)
          } else {
            router.push(ROUTES.login)
          }
        } catch {
          router.push(ROUTES.login)
        }
      } else {
        // First time user - show onboarding
        router.push(ROUTES.welcome)
      }
    }

    checkAuthAndRedirect()
  }, [showSplash, router])

  /** Handle splash screen completion */
  const handleSplashComplete = () => {
    setShowSplash(false)
  }

  if (showSplash) {
    return <SplashScreen onComplete={handleSplashComplete} duration={2500} />
  }

  // Return null while redirecting
  return null
}
