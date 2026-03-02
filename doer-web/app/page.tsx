'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { SplashScreen } from '@/components/onboarding/SplashScreen'
import { ROUTES } from '@/lib/constants'
import { getAccessToken } from '@/lib/api/client'

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
        // Check if user is authenticated via JWT token
        const token = getAccessToken()
        if (token) {
          router.push(ROUTES.dashboard)
        } else {
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
