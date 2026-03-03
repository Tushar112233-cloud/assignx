/**
 * @fileoverview Earnings Stats — Doer Landing
 *
 * Four animated counter stat cards showing platform metrics.
 * Counters animate from 0 using framer-motion springs when scrolled into view.
 */
"use client"

import { useRef, useEffect, useState } from "react"
import {
  motion,
  useReducedMotion,
  useInView,
  useSpring,
  useTransform,
} from "framer-motion"
import { Users, IndianRupee, TrendingUp, Clock } from "lucide-react"
import { cn } from "@/lib/utils"
import { DOER_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

interface Stat {
  id: string
  value: number
  prefix?: string
  suffix: string
  label: string
  description: string
  Icon: React.ElementType
  isDecimal?: boolean
}

const stats: Stat[] = [
  {
    id: "doers",
    value: 2400,
    suffix: "+",
    label: "Active Doers",
    description: "Skilled experts earning on the platform",
    Icon: Users,
  },
  {
    id: "paid",
    value: 8,
    prefix: "₹",
    suffix: "Cr+",
    label: "Total Paid Out",
    description: "Real earnings delivered to Doers",
    Icon: IndianRupee,
  },
  {
    id: "tasks",
    value: 12000,
    suffix: "+",
    label: "Tasks Completed",
    description: "Successfully delivered projects",
    Icon: TrendingUp,
  },
  {
    id: "payout",
    value: 48,
    suffix: "h",
    label: "Avg. Payout Time",
    description: "Average time from approval to payment",
    Icon: Clock,
  },
]

/** Animated counter hook using framer-motion spring */
function useAnimatedCounter(
  end: number,
  isInView: boolean,
  isDecimal = false
) {
  const prefersReducedMotion = useReducedMotion()

  const spring = useSpring(0, {
    stiffness: 50,
    damping: 30,
    restDelta: 0.01,
  })

  const rounded = useTransform(spring, (val) =>
    isDecimal
      ? val.toFixed(1)
      : Math.round(val).toLocaleString("en-IN")
  )

  const [displayValue, setDisplayValue] = useState<string>(
    prefersReducedMotion
      ? isDecimal
        ? end.toFixed(1)
        : end.toLocaleString("en-IN")
      : "0"
  )

  useEffect(() => {
    const unsubscribe = rounded.on("change", setDisplayValue)
    return () => unsubscribe()
  }, [rounded])

  useEffect(() => {
    if (isInView) {
      if (prefersReducedMotion) {
        setDisplayValue(
          isDecimal ? end.toFixed(1) : end.toLocaleString("en-IN")
        )
      } else {
        spring.set(end)
      }
    }
  }, [isInView, end, spring, prefersReducedMotion, isDecimal])

  return displayValue
}

/** Individual stat card */
function StatCard({ stat, index }: { stat: Stat; index: number }) {
  const ref = useRef<HTMLDivElement>(null)
  const isInView = useInView(ref, { once: true, amount: 0.5 })
  const prefersReducedMotion = useReducedMotion()
  const animatedValue = useAnimatedCounter(
    stat.value,
    isInView,
    stat.isDecimal
  )
  const { Icon } = stat

  return (
    <motion.div
      ref={ref}
      initial={
        prefersReducedMotion ? false : { opacity: 0, y: 30, scale: 0.95 }
      }
      animate={isInView ? { opacity: 1, y: 0, scale: 1 } : {}}
      transition={{ delay: index * 0.1, duration: 0.6, ease: DOER_EASE }}
      className="group relative text-center p-6 sm:p-8 rounded-2xl bg-white/60 dark:bg-[var(--landing-bg-elevated)]/60 backdrop-blur-lg border border-[var(--landing-border)] hover:border-[var(--landing-border-teal)] hover:shadow-lg hover:-translate-y-1 transition-all duration-300"
    >
      {/* Icon */}
      <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-[var(--landing-accent-lighter)] mb-4 transition-transform duration-300 group-hover:scale-110">
        <Icon className="w-6 h-6 text-[var(--landing-accent-primary)]" />
      </div>

      {/* Value */}
      <div className="mb-2">
        {stat.prefix && (
          <span className="text-2xl sm:text-3xl font-bold text-[var(--landing-accent-primary)]">
            {stat.prefix}
          </span>
        )}
        <span className="text-4xl sm:text-5xl font-bold text-[var(--landing-text-primary)] tabular-nums">
          {animatedValue}
        </span>
        <span className="text-2xl sm:text-3xl font-bold text-[var(--landing-accent-primary)]">
          {stat.suffix}
        </span>
      </div>

      {/* Label */}
      <h3 className="text-base font-semibold text-[var(--landing-text-primary)] mb-1">
        {stat.label}
      </h3>

      {/* Description */}
      <p className="text-sm text-[var(--landing-text-muted)]">
        {stat.description}
      </p>
    </motion.div>
  )
}

/** Earnings Stats Section */
export function EarningsStats() {
  const ref = useRef<HTMLElement>(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={ref}
      id="earnings"
      className="relative py-16 sm:py-24"
      style={{ background: "var(--landing-bg-primary)" }}
    >
      {/* Top separator */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Ambient mesh */}
      <div className="absolute inset-0 landing-mesh-gradient opacity-50" />

      <div className="relative z-10 max-w-6xl mx-auto px-4 sm:px-6">
        {/* Header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, ease: DOER_EASE }}
          className="text-center max-w-2xl mx-auto mb-12 sm:mb-16"
        >
          <h2 className="landing-heading-md text-[var(--landing-text-primary)] mb-3">
            Numbers That Speak
          </h2>
          <p className="text-[var(--landing-text-secondary)]">
            Real metrics from real Doers on our platform.
          </p>
        </motion.div>

        {/* Stats grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {stats.map((stat, index) => (
            <StatCard key={stat.id} stat={stat} index={index} />
          ))}
        </div>
      </div>
    </section>
  )
}
