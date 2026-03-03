/**
 * @fileoverview Who Qualifies — Supervisor Landing
 *
 * Requirements checklist (left) + Apply card (right).
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import Link from "next/link"
import { CheckCircle2, ArrowRight, GraduationCap, Brain, Clock, MessageSquare } from "lucide-react"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const requirements = [
  {
    Icon: GraduationCap,
    title: "Master's degree or higher",
    description: "Or equivalent professional experience in your domain",
  },
  {
    Icon: Brain,
    title: "Proven domain expertise",
    description: "Demonstrated knowledge in at least one academic subject area",
  },
  {
    Icon: MessageSquare,
    title: "Strong communication skills",
    description: "Able to brief doers clearly and manage client expectations",
  },
  {
    Icon: Clock,
    title: "5+ hours per week available",
    description: "Flexible — manage projects on your own schedule",
  },
]

export function WhoQualifies() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.2 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="qualify"
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--sv-bg-primary)" }}
    >
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--sv-border)] to-transparent" />

      {/* Decorative indigo orb */}
      <div
        className="absolute top-1/2 left-0 -translate-y-1/2 w-96 h-96 rounded-full blur-3xl pointer-events-none"
        style={{ background: "hsl(var(--accent) / 0.06)" }}
      />

      <div className="max-w-5xl mx-auto px-4 sm:px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: SV_EASE }}
          className="text-center mb-14"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--sv-accent-lighter)] border border-[var(--sv-border-accent)] mb-6">
            <span className="text-sm font-medium text-[var(--sv-accent)]">
              Who Can Apply
            </span>
          </span>
          <h2 className="sv-heading-lg text-[var(--sv-text-primary)] mb-4">
            Do You{" "}
            <span className="sv-text-gradient">Qualify?</span>
          </h2>
        </motion.div>

        {/* Two-column layout */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
          {/* Requirements list */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, x: -30 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.7, ease: SV_EASE }}
            className="space-y-4"
          >
            {requirements.map((req, index) => (
              <motion.div
                key={req.title}
                initial={prefersReducedMotion ? false : { opacity: 0, y: 16 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ delay: 0.1 + index * 0.08, duration: 0.5, ease: SV_EASE }}
                className="flex items-start gap-4 p-4 rounded-2xl bg-white dark:bg-[var(--sv-bg-dark-surface)] border border-[var(--sv-border)] hover:border-[var(--sv-border-accent)] transition-colors duration-200"
              >
                <div className="w-10 h-10 rounded-xl bg-[var(--sv-accent-lighter)] flex items-center justify-center flex-shrink-0 mt-0.5">
                  <req.Icon className="w-5 h-5 text-[var(--sv-accent)]" />
                </div>
                <div>
                  <div className="flex items-center gap-2 mb-0.5">
                    <CheckCircle2 className="w-4 h-4 text-emerald-500 flex-shrink-0" />
                    <h4 className="text-sm font-semibold text-[var(--sv-text-primary)]">
                      {req.title}
                    </h4>
                  </div>
                  <p className="text-sm text-[var(--sv-text-muted)]">
                    {req.description}
                  </p>
                </div>
              </motion.div>
            ))}
          </motion.div>

          {/* Apply card */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, x: 30 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ delay: 0.2, duration: 0.7, ease: SV_EASE }}
            className={cn(
              "relative rounded-3xl p-8 overflow-hidden",
              "bg-gradient-to-br from-[var(--sv-accent)] to-[var(--sv-gradient-end)]",
              "text-white shadow-2xl"
            )}
          >
            {/* Orb decoration inside card */}
            <div className="absolute top-0 right-0 w-48 h-48 rounded-full bg-white/10 blur-2xl pointer-events-none" />

            <div className="relative z-10">
              <div className="w-12 h-12 rounded-2xl bg-white/20 flex items-center justify-center mb-6">
                <GraduationCap className="w-6 h-6 text-white" />
              </div>

              <h3 className="text-2xl font-bold mb-3">
                Ready to Apply?
              </h3>
              <p className="text-white/80 mb-6 leading-relaxed">
                If you meet the requirements, the application takes under 5
                minutes. Our team reviews all applications within 24–48 hours.
              </p>

              <ul className="space-y-2 mb-8">
                {[
                  "Free to apply",
                  "No exclusivity required",
                  "Start earning within days of approval",
                ].map((point) => (
                  <li key={point} className="flex items-center gap-2 text-sm text-white/90">
                    <CheckCircle2 className="w-4 h-4 text-white flex-shrink-0" />
                    {point}
                  </li>
                ))}
              </ul>

              <Link
                href="/register"
                className={cn(
                  "inline-flex items-center gap-2 px-6 py-3 rounded-xl",
                  "bg-white text-[var(--sv-accent)] font-semibold",
                  "hover:bg-white/90 transition-all hover:-translate-y-0.5",
                  "shadow-lg"
                )}
              >
                Apply as Supervisor
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}
