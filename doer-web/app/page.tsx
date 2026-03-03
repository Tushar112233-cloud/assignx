"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { getAccessToken } from "@/lib/api/client"
import { ROUTES } from "@/lib/constants"
import {
  Navigation,
  HeroSection,
  HowItWorks,
  TaskCategories,
  BenefitsSection,
  EarningsStats,
  Testimonials,
  CTASection,
  Footer,
} from "@/components/landing"

/**
 * Home page — shows Doer landing page for unauthenticated visitors.
 * Authenticated users are redirected to their dashboard immediately.
 */
export default function HomePage() {
  const router = useRouter()

  useEffect(() => {
    const token = getAccessToken()
    if (token) {
      router.replace(ROUTES.dashboard)
    }
  }, [router])

  return (
    <main className="landing-page">
      <Navigation />
      <HeroSection />
      <HowItWorks />
      <TaskCategories />
      <BenefitsSection />
      <EarningsStats />
      <Testimonials />
      <CTASection />
      <Footer />
    </main>
  )
}
