/**
 * @fileoverview CTA Section — Supervisor Landing
 *
 * Dark command-center background, glowing orbs, dual CTA buttons.
 */
"use client"

import { useRef } from "react"
import Link from "next/link"
import { motion, useReducedMotion, useInView } from "framer-motion"
import { ArrowRight, ShieldCheck, Clock, Target } from "lucide-react"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const trustPoints = [
  { Icon: ShieldCheck, text: "Verified platform, guaranteed payments" },
  { Icon: Clock, text: "Payouts within 48 hours" },
  { Icon: Target, text: "Domain-matched projects only" },
]

export function CTASection() {
  const ref = useRef<HTMLDivElement>(null)
  const isInView = useInView(ref, { once: true, amount: 0.3 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--sv-bg-dark)" }}
    >
      {/* Indigo orb — top-left */}
      <motion.div
        className="absolute top-1/4 left-1/4 w-80 h-80 rounded-full blur-3xl pointer-events-none"
        style={{ background: "hsl(var(--accent) / 0.15)" }}
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1, 1.2, 1], opacity: [0.15, 0.25, 0.15] }
        }
        transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
      />

      {/* Cyan orb — bottom-right */}
      <motion.div
        className="absolute bottom-1/4 right-1/4 w-96 h-96 rounded-full blur-3xl pointer-events-none"
        style={{ background: "rgba(34,211,238,0.08)" }}
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1.2, 1, 1.2], opacity: [0.08, 0.16, 0.08] }
        }
        transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
      />

      {/* Grid overlay */}
      <div className="absolute inset-0 sv-grid-pattern opacity-10" />

      <div
        ref={ref}
        className="relative z-10 max-w-4xl mx-auto px-4 sm:px-6 text-center"
      >
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 40 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: SV_EASE }}
        >
          {/* Badge */}
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 border border-white/20 text-white/80 text-sm font-medium mb-8">
            <motion.span
              className="w-2 h-2 rounded-full bg-[var(--sv-cyan)]"
              animate={prefersReducedMotion ? {} : { scale: [1, 1.5, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            Join 1,200+ Expert Supervisors Earning Today
          </span>

          {/* Headline */}
          <h2 className="sv-heading-lg text-white mb-6">
            Ready to{" "}
            <span className="sv-text-gradient">Lead?</span>
          </h2>

          {/* Subtext */}
          <p className="text-lg text-white/60 mb-10 max-w-2xl mx-auto leading-relaxed">
            Your expertise is in demand. Apply in minutes and start managing
            projects in your domain today.
          </p>

          {/* Dual CTAs */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Link
              href="/register"
              className={cn(
                "flex items-center justify-center gap-2 px-8 py-4 rounded-2xl",
                "bg-[var(--sv-accent)] text-white font-semibold text-base",
                "hover:bg-[var(--sv-accent-hover)] transition-all",
                "hover:-translate-y-1 hover:shadow-[0_8px_32px_hsl(var(--accent)/0.4)]",
                "group"
              )}
            >
              Apply as Supervisor
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
                <Icon className="w-4 h-4 text-[var(--sv-cyan)] flex-shrink-0" />
                {text}
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  )
}
