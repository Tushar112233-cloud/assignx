'use client'

import { useRouter } from 'next/navigation'
import { OnboardingCarousel } from '@/components/onboarding/OnboardingCarousel'
import { ROUTES } from '@/lib/constants'

/**
 * Welcome page with onboarding carousel
 * First screen after splash for new users
 */
export default function WelcomePage() {
  const router = useRouter()

  /** Handle carousel completion */
  const handleComplete = () => {
    router.push(ROUTES.register)
  }

  /** Handle skip button */
  const handleSkip = () => {
    router.push(ROUTES.register)
  }

  return (
    <OnboardingCarousel
      onComplete={handleComplete}
      onSkip={handleSkip}
    />
  )
}
