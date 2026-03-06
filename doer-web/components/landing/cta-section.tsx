/**
 * @fileoverview CTA Section — Doer Landing
 *
 * Dark teal full-width section with glowing orbs and final call-to-action.
 * Two buttons: "Apply as Doer" (primary) and "Sign In" (ghost).
 * Three trust points beneath the buttons.
 */
"use client"

import { useRef } from "react"
import Link from "next/link"
import { motion, useReducedMotion, useInView } from "framer-motion"
import { ArrowRight, Zap, ShieldCheck, Clock } from "lucide-react"
import { cn } from "@/lib/utils"
import { DOER_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const trustPoints = [
  { Icon: Zap, text: "Start in under 5 minutes" },
  { Icon: ShieldCheck, text: "Verified platform, guaranteed payments" },
  { Icon: Clock, text: "Payouts within 48 hours" },
]

/** CTA Section */
export function CTASection() {
  const ref = useRef<HTMLDivElement>(null)
  const isInView = useInView(ref, { once: true, amount: 0.3 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--landing-bg-dark)" }}
    >
      {/* Glowing teal orb — top-left quadrant */}
      <motion.div
        className="absolute top-1/4 left-1/4 w-80 h-80 bg-[var(--landing-accent-primary)]/15 rounded-full blur-3xl pointer-events-none"
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1, 1.2, 1], opacity: [0.15, 0.25, 0.15] }
        }
        transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
      />

      {/* Emerald orb — bottom-right quadrant */}
      <motion.div
        className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-[var(--landing-accent-secondary)]/10 rounded-full blur-3xl pointer-events-none"
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1.2, 1, 1.2], opacity: [0.1, 0.2, 0.1] }
        }
        transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
      />

      {/* Subtle grid overlay */}
      <div className="absolute inset-0 landing-grid-pattern opacity-10" />

      <div
        ref={ref}
        className="relative z-10 max-w-4xl mx-auto px-4 sm:px-6 text-center"
      >
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 40 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: DOER_EASE }}
        >
          {/* Badge */}
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 border border-white/20 text-white/80 text-sm font-medium mb-8">
            <motion.span
              className="w-2 h-2 rounded-full bg-[var(--landing-accent-primary)]"
              animate={{ scale: [1, 1.5, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            Join 2,400+ Experts Earning Today
          </span>

          {/* Headline */}
          <h2 className="landing-heading-lg text-white mb-6">
            Ready to Start{" "}
            <span className="landing-text-gradient">Earning?</span>
          </h2>

          {/* Sub-text */}
          <p className="text-lg text-white/60 mb-10 max-w-2xl mx-auto leading-relaxed">
            Your expertise is in demand. Sign up in minutes and start browsing
            tasks that match your skills.
          </p>

          {/* CTA buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Link
              href="/register"
              className={cn(
                "flex items-center justify-center gap-2 px-8 py-4 rounded-2xl",
                "bg-[var(--landing-accent-primary)] text-white font-semibold text-base",
                "hover:bg-[var(--landing-accent-primary-hover)] transition-all",
                "hover:-translate-y-1 hover:shadow-[0_8px_32px_rgba(13,148,136,0.4)]",
                "group"
              )}
            >
              Apply as Dolancer
              <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </Link>
            <Link
              href="/login"
              className={cn(
                "flex items-center justify-center gap-2 px-8 py-4 rounded-2xl",
                "bg-white/10 text-white font-medium text-base",
                "border border-white/20 hover:bg-white/20",
                "transition-all hover:-translate-y-1"
              )}
            >
              Sign In
            </Link>
          </div>

          {/* Trust points */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-6">
            {trustPoints.map(({ Icon, text }) => (
              <div
                key={text}
                className="flex items-center gap-2 text-white/50 text-sm"
              >
                <Icon className="w-4 h-4 text-[var(--landing-accent-primary)] flex-shrink-0" />
                {text}
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  )
}
