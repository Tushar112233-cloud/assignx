/**
 * @fileoverview Supervisor Landing Page
 *
 * Shown to unauthenticated visitors. Recruits new supervisors and provides
 * login for existing ones. Authenticated users are redirected to dashboard.
 */
"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { getAccessToken } from "@/lib/api/client"
import { ROUTES } from "@/lib/constants"
import {
  Navigation,
  HeroSection,
  HowItWorks,
  WhatYouDo,
  BenefitsSection,
  WhoQualifies,
  EarningsStats,
  Testimonials,
  CTASection,
  Footer,
} from "@/components/landing"

export default function HomePage() {
  const router = useRouter()

  useEffect(() => {
    const token = getAccessToken()
    if (token) {
      router.replace(ROUTES.dashboard)
    }
  }, [router])

  return (
    <main className="sv-landing">
      <Navigation />
      <HeroSection />
      <HowItWorks />
      <WhatYouDo />
      <BenefitsSection />
      <WhoQualifies />
      <EarningsStats />
      <Testimonials />
      <CTASection />
      <Footer />
    </main>
  )
}
