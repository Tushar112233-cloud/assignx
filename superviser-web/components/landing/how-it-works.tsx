/**
 * @fileoverview How It Works — Supervisor Landing
 *
 * 4-step numbered timeline: Apply → Receive Projects → Manage & QC → Get Paid
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import {
  UserCheck,
  FolderOpen,
  ClipboardCheck,
  BanknoteIcon,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const steps = [
  {
    number: "01",
    Icon: UserCheck,
    title: "Apply & Get Verified",
    description:
      "Submit your credentials and domain expertise. Our team reviews your application and verifies you as an expert supervisor.",
    iconBg: "bg-indigo-100 dark:bg-indigo-900/30",
    iconColor: "text-indigo-600 dark:text-indigo-400",
    numColor: "text-indigo-200 dark:text-indigo-900",
  },
  {
    number: "02",
    Icon: FolderOpen,
    title: "Receive Matched Projects",
    description:
      "Projects in your domain appear in your dashboard automatically. Accept the ones that fit your schedule.",
    iconBg: "bg-violet-100 dark:bg-violet-900/30",
    iconColor: "text-violet-600 dark:text-violet-400",
    numColor: "text-violet-200 dark:text-violet-900",
  },
  {
    number: "03",
    Icon: ClipboardCheck,
    title: "Manage, Assign & QC",
    description:
      "Brief DoLancers, oversee work in progress, review every submission for quality before it reaches the client.",
    iconBg: "bg-cyan-100 dark:bg-cyan-900/30",
    iconColor: "text-cyan-600 dark:text-cyan-400",
    numColor: "text-cyan-200 dark:text-cyan-900",
  },
  {
    number: "04",
    Icon: BanknoteIcon,
    title: "Get Paid in 48 Hours",
    description:
      "Your 15% commission is released within 48 hours of task completion. No waiting, no paperwork.",
    iconBg: "bg-emerald-100 dark:bg-emerald-900/30",
    iconColor: "text-emerald-600 dark:text-emerald-400",
    numColor: "text-emerald-200 dark:text-emerald-900",
  },
]

export function HowItWorks() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.2 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="how-it-works"
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--sv-bg-secondary)" }}
    >
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--sv-border)] to-transparent" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: SV_EASE }}
          className="text-center mb-16"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--sv-accent-lighter)] border border-[var(--sv-border-accent)] mb-6">
            <span className="text-sm font-medium text-[var(--sv-accent)]">
              Simple 4-Step Process
            </span>
          </span>
          <h2 className="sv-heading-lg text-[var(--sv-text-primary)] mb-4">
            How Supervisors{" "}
            <span className="sv-text-gradient">Earn</span>
          </h2>
          <p className="text-lg text-[var(--sv-text-secondary)] max-w-2xl mx-auto">
            From application to your first payout — here&apos;s exactly how
            it works.
          </p>
        </motion.div>

        {/* Steps grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 relative">
          {/* Connector line (desktop) */}
          <div className="hidden lg:block absolute top-10 left-[12.5%] right-[12.5%] h-px bg-gradient-to-r from-transparent via-[var(--sv-border-accent)] to-transparent z-0" />

          {steps.map((step, index) => (
            <motion.div
              key={step.number}
              initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{
                delay: index * 0.1,
                duration: 0.6,
                ease: SV_EASE,
              }}
              className="relative z-10 flex flex-col items-center text-center p-6 rounded-2xl bg-white dark:bg-[var(--sv-bg-dark-surface)] border border-[var(--sv-border)] hover:border-[var(--sv-border-accent)] hover:shadow-lg hover:-translate-y-1 transition-all duration-300"
            >
              {/* Watermark number */}
              <span
                className={cn(
                  "absolute top-4 right-4 text-6xl font-black select-none",
                  step.numColor
                )}
              >
                {step.number}
              </span>

              {/* Icon */}
              <div
                className={cn(
                  "w-14 h-14 rounded-2xl flex items-center justify-center mb-4",
                  step.iconBg
                )}
              >
                <step.Icon className={cn("w-7 h-7", step.iconColor)} />
              </div>

              <h3 className="text-base font-semibold text-[var(--sv-text-primary)] mb-2">
                {step.title}
              </h3>
              <p className="text-sm text-[var(--sv-text-muted)] leading-relaxed">
                {step.description}
              </p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
