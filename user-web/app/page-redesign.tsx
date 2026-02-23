"use client";

/**
 * Home Page REDESIGN - Premium Bento Grid Landing
 *
 * Inspired by:
 * - Dashboard: Warm theme with bento cards
 * - Projects: Glassmorphic premium design
 * - Campus Connect: Vibrant gradients and carousels
 * - Experts: Mesh backgrounds
 * - Wallet: 2-column layouts
 *
 * Sections:
 * 1. Hero - 2-column with greeting + bento grid
 * 2. Features - Bento grid services
 * 3. How It Works - 4-step process
 * 4. CTA - Dark hero conversion
 * 5. Footer - Minimal
 */

import "./landing.css";
import { LenisProvider } from "@/components/providers/lenis-provider";
import {
  Navigation,
  HeroSectionRedesign,
  FeaturesBento,
  HowItWorksRedesign,
  CTASectionRedesign,
  Footer,
} from "@/components/landing";

export default function HomeRedesign() {
  return (
    <LenisProvider>
      <div className="landing-page min-h-screen bg-[var(--landing-bg-primary)]">
        {/* Navigation - Fixed with pill style on scroll */}
        <Navigation />

        {/* Main content */}
        <main>
          {/* Hero Section - Premium 2-column with bento grid */}
          <HeroSectionRedesign />

          {/* Features Bento - Service showcase */}
          <FeaturesBento />

          {/* How It Works - 4-step process */}
          <HowItWorksRedesign />

          {/* CTA Section - Dark hero conversion */}
          <CTASectionRedesign />
        </main>

        {/* Footer - Minimal */}
        <Footer />
      </div>
    </LenisProvider>
  );
}
