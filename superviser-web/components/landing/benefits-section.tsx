/**
 * @fileoverview Benefits Section — Supervisor Landing
 *
 * 6-card bento grid of platform benefits for supervisors.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import {
  Calendar,
  IndianRupee,
  Target,
  TrendingUp,
  ShieldCheck,
  Sparkles,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const benefits = [
  {
    id: "commission",
    Icon: IndianRupee,
    title: "15% Commission",
    description:
      "Earn 15% of every project value you supervise. Transparent, guaranteed, and paid within 48 hours of completion.",
    size: "lg" as const,
    gradient: "from-orange-500/10 to-orange-500/5",
    iconBg: "bg-orange-100 dark:bg-orange-900/30",
    iconColor: "text-orange-600 dark:text-orange-400",
  },
  {
    id: "flexible",
    Icon: Calendar,
    title: "Flexible Schedule",
    description:
      "Accept projects around your existing commitments. No minimum hours required.",
    size: "sm" as const,
    gradient: "from-amber-500/10 to-amber-500/5",
    iconBg: "bg-amber-100 dark:bg-amber-900/30",
    iconColor: "text-amber-600 dark:text-amber-400",
  },
  {
    id: "domain",
    Icon: Target,
    title: "Domain-Matched Only",
    description:
      "You only see projects in your expertise area — no irrelevant tasks, no out-of-domain work.",
    size: "sm" as const,
    gradient: "from-cyan-500/10 to-cyan-500/5",
    iconBg: "bg-cyan-100 dark:bg-cyan-900/30",
    iconColor: "text-cyan-600 dark:text-cyan-400",
  },
  {
    id: "portfolio",
    Icon: TrendingUp,
    title: "Build Your Portfolio",
    description:
      "Every supervised project adds to your verifiable expert record. Higher ratings unlock premium, high-value tasks.",
    size: "lg" as const,
    gradient: "from-emerald-500/10 to-cyan-500/5",
    iconBg: "bg-emerald-100 dark:bg-emerald-900/30",
    iconColor: "text-emerald-600 dark:text-emerald-400",
  },
  {
    id: "verified",
    Icon: ShieldCheck,
    title: "Verified Platform",
    description:
      "Every task is legitimate. Every payment guaranteed by AssignX.",
    size: "sm" as const,
    gradient: "from-orange-500/10 to-orange-500/5",
    iconBg: "bg-orange-100 dark:bg-orange-900/30",
    iconColor: "text-orange-600 dark:text-orange-400",
  },
  {
    id: "growth",
    Icon: Sparkles,
    title: "Grow Your Expertise",
    description:
      "Exposure to diverse academic problems sharpens your domain knowledge every month.",
    size: "sm" as const,
    gradient: "from-amber-500/10 to-orange-500/5",
    iconBg: "bg-amber-100 dark:bg-amber-900/30",
    iconColor: "text-amber-600 dark:text-amber-400",
  },
]

export function BenefitsSection() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.15 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="benefits"
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--sv-bg-secondary)" }}
    >
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--sv-border)] to-transparent" />
      <div className="absolute inset-0 sv-grid-pattern opacity-20" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 relative z-10">
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: SV_EASE }}
          className="text-center mb-14"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--sv-accent-lighter)] border border-[var(--sv-border-accent)] mb-6">
            <span className="text-sm font-medium text-[var(--sv-accent)]">
              Why Supervisors Love It
            </span>
          </span>
          <h2 className="sv-heading-lg text-[var(--sv-text-primary)] mb-4">
            Everything You Need to{" "}
            <span className="sv-text-gradient">Thrive</span>
          </h2>
          <p className="text-lg text-[var(--sv-text-secondary)] max-w-2xl mx-auto">
            Built for domain experts who want meaningful work, fair pay, and
            complete flexibility.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {benefits.map((benefit, index) => (
            <motion.div
              key={benefit.id}
              initial={prefersReducedMotion ? false : { opacity: 0, y: 24 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ delay: index * 0.07, duration: 0.6, ease: SV_EASE }}
              className={cn(
                "group relative rounded-2xl p-6 overflow-hidden",
                "bg-white dark:bg-[var(--sv-bg-dark-surface)]",
                "border border-[var(--sv-border)]",
                "hover:border-[var(--sv-border-accent)] hover:shadow-lg hover:-translate-y-1",
                "transition-all duration-300",
                benefit.size === "lg" ? "md:col-span-2" : "md:col-span-1"
              )}
            >
              <div
                className={cn(
                  "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-300",
                  benefit.gradient
                )}
              />
              <div className="relative z-10">
                <div
                  className={cn(
                    "w-11 h-11 rounded-xl flex items-center justify-center mb-4",
                    benefit.iconBg
                  )}
                >
                  <benefit.Icon className={cn("w-5 h-5", benefit.iconColor)} />
                </div>
                <h3 className="text-base font-semibold text-[var(--sv-text-primary)] mb-2">
                  {benefit.title}
                </h3>
                <p className="text-sm text-[var(--sv-text-muted)] leading-relaxed">
                  {benefit.description}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
