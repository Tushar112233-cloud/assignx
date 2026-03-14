/**
 * @fileoverview Benefits Section — Dolancer Landing
 *
 * Bento-grid layout of 8 cards highlighting key Dolancer platform benefits.
 * Two cards span 2 columns (size: "lg") for visual variety.
 * Cards reveal a blue/indigo gradient background on hover.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import {
  Calendar,
  IndianRupee,
  BarChart2,
  Sparkles,
  BanknoteIcon,
  Users2,
  ShieldCheck,
  TrendingUp,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { DOER_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

type BenefitSize = "sm" | "lg"

interface Benefit {
  id: string
  Icon: React.ElementType
  title: string
  description: string
  size: BenefitSize
  gradient: string
  iconBg: string
  iconColor: string
}

const benefits: Benefit[] = [
  {
    id: "flexible",
    Icon: Calendar,
    title: "Flexible Schedule",
    description:
      "Work when you want. Accept tasks that fit your availability — morning, evening, or weekend.",
    size: "sm",
    gradient: "from-blue-500/10 to-blue-500/5",
    iconBg: "bg-blue-100 dark:bg-blue-900/30",
    iconColor: "text-blue-600 dark:text-blue-400",
  },
  {
    id: "pay",
    Icon: IndianRupee,
    title: "Fair Compensation",
    description:
      "Transparent pricing. Know exactly what you'll earn before accepting. No hidden deductions.",
    size: "sm",
    gradient: "from-indigo-500/10 to-indigo-500/5",
    iconBg: "bg-indigo-100 dark:bg-indigo-900/30",
    iconColor: "text-indigo-600 dark:text-indigo-400",
  },
  {
    id: "variety",
    Icon: BarChart2,
    title: "Huge Task Variety",
    description:
      "From research reports to code reviews — hundreds of fresh tasks posted daily across every academic discipline. Match tasks to your strongest subjects.",
    size: "lg",
    gradient: "from-sky-500/10 to-blue-500/5",
    iconBg: "bg-sky-100 dark:bg-sky-900/30",
    iconColor: "text-sky-600 dark:text-sky-400",
  },
  {
    id: "payout",
    Icon: BanknoteIcon,
    title: "48-Hour Payouts",
    description:
      "No waiting weeks. Get paid within 48 hours of task approval.",
    size: "sm",
    gradient: "from-blue-500/10 to-blue-500/5",
    iconBg: "bg-blue-100 dark:bg-blue-900/30",
    iconColor: "text-blue-600 dark:text-blue-400",
  },
  {
    id: "community",
    Icon: Users2,
    title: "Expert Community",
    description:
      "Connect with thousands of skilled Dolancers. Share resources, tips, and grow together.",
    size: "sm",
    gradient: "from-blue-400/10 to-indigo-400/5",
    iconBg: "bg-blue-100 dark:bg-blue-900/30",
    iconColor: "text-blue-600 dark:text-blue-400",
  },
  {
    id: "reputation",
    Icon: TrendingUp,
    title: "Build Your Reputation",
    description:
      "Every successful task boosts your rating. Higher ratings unlock premium tasks with better payouts and exclusive opportunities.",
    size: "lg",
    gradient: "from-indigo-400/10 to-blue-400/5",
    iconBg: "bg-indigo-100 dark:bg-indigo-900/30",
    iconColor: "text-indigo-600 dark:text-indigo-400",
  },
  {
    id: "verified",
    Icon: ShieldCheck,
    title: "Verified Platform",
    description:
      "Every task is legitimate. Every payment is guaranteed.",
    size: "sm",
    gradient: "from-blue-500/10 to-blue-500/5",
    iconBg: "bg-blue-100 dark:bg-blue-900/30",
    iconColor: "text-blue-600 dark:text-blue-400",
  },
  {
    id: "growth",
    Icon: Sparkles,
    title: "Skill Growth",
    description:
      "Each task sharpens your expertise and grows your professional portfolio.",
    size: "sm",
    gradient: "from-blue-500/10 to-indigo-500/5",
    iconBg: "bg-blue-100 dark:bg-blue-900/30",
    iconColor: "text-blue-600 dark:text-blue-400",
  },
]

/** Individual bento card */
function BentoCard({
  benefit,
  index,
  isInView,
}: {
  benefit: Benefit
  index: number
  isInView: boolean
}) {
  const prefersReducedMotion = useReducedMotion()
  const { Icon } = benefit

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, y: 24 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ delay: index * 0.07, duration: 0.6, ease: DOER_EASE }}
      className={cn(
        "group relative rounded-2xl p-6 overflow-hidden",
        "bg-white dark:bg-[var(--landing-bg-elevated)]",
        "border border-[var(--landing-border)]",
        "hover:border-[var(--landing-border-teal)] hover:shadow-lg hover:-translate-y-1",
        "transition-all duration-300",
        benefit.size === "lg" ? "md:col-span-2" : "md:col-span-1"
      )}
    >
      {/* Hover gradient reveal */}
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
          <Icon className={cn("w-5 h-5", benefit.iconColor)} />
        </div>
        <h3 className="text-base font-semibold text-[var(--landing-text-primary)] mb-2">
          {benefit.title}
        </h3>
        <p className="text-sm text-[var(--landing-text-muted)] leading-relaxed">
          {benefit.description}
        </p>
      </div>
    </motion.div>
  )
}

/** Benefits Section */
export function BenefitsSection() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.15 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="benefits"
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--landing-bg-secondary)" }}
    >
      {/* Top separator */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Subtle grid */}
      <div className="absolute inset-0 landing-grid-pattern opacity-20" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 relative z-10">
        {/* Section header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: DOER_EASE }}
          className="text-center mb-14"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border-teal)] mb-6">
            <span className="text-sm font-medium text-[var(--landing-accent-primary)]">
              Why Dolancers Love It
            </span>
          </span>
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-4">
            Everything You Need to{" "}
            <span className="landing-text-gradient">Thrive</span>
          </h2>
          <p className="text-lg text-[var(--landing-text-secondary)] max-w-2xl mx-auto">
            Built for experts who want flexibility, fair pay, and meaningful
            work.
          </p>
        </motion.div>

        {/* Bento grid — 4 columns on md+, 1 column on mobile */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {benefits.map((benefit, index) => (
            <BentoCard
              key={benefit.id}
              benefit={benefit}
              index={index}
              isInView={isInView}
            />
          ))}
        </div>
      </div>
    </section>
  )
}
