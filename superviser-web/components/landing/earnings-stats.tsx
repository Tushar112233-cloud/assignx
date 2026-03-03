/**
 * @fileoverview Earnings Stats — Supervisor Landing
 *
 * Four animated counter cards. Counters spring from 0 when scrolled into view.
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
import { Users, IndianRupee, FolderKanban, Clock } from "lucide-react"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

interface Stat {
  id: string
  value: number
  prefix?: string
  suffix: string
  label: string
  description: string
  Icon: React.ElementType
}

const stats: Stat[] = [
  {
    id: "supervisors",
    value: 1200,
    suffix: "+",
    label: "Active Supervisors",
    description: "Verified domain experts earning on the platform",
    Icon: Users,
  },
  {
    id: "paid",
    value: 4,
    prefix: "₹",
    suffix: "Cr+",
    label: "Total Paid Out",
    description: "Real earnings delivered to supervisors",
    Icon: IndianRupee,
  },
  {
    id: "projects",
    value: 8000,
    suffix: "+",
    label: "Projects Supervised",
    description: "Successfully delivered to clients",
    Icon: FolderKanban,
  },
  {
    id: "payout",
    value: 48,
    suffix: "h",
    label: "Avg. Payout Time",
    description: "From task approval to payment in your account",
    Icon: Clock,
  },
]

function useAnimatedCounter(end: number, isInView: boolean) {
  const prefersReducedMotion = useReducedMotion()
  const spring = useSpring(0, { stiffness: 50, damping: 30, restDelta: 0.01 })
  const rounded = useTransform(spring, (v) =>
    Math.round(v).toLocaleString("en-IN")
  )
  const [display, setDisplay] = useState(
    prefersReducedMotion ? end.toLocaleString("en-IN") : "0"
  )

  useEffect(() => {
    const unsub = rounded.on("change", setDisplay)
    return () => unsub()
  }, [rounded])

  useEffect(() => {
    if (isInView) {
      if (prefersReducedMotion) {
        setDisplay(end.toLocaleString("en-IN"))
      } else {
        spring.set(end)
      }
    }
  }, [isInView, end, spring, prefersReducedMotion])

  return display
}

function StatCard({ stat, index }: { stat: Stat; index: number }) {
  const ref = useRef<HTMLDivElement>(null)
  const isInView = useInView(ref, { once: true, amount: 0.5 })
  const prefersReducedMotion = useReducedMotion()
  const animatedValue = useAnimatedCounter(stat.value, isInView)
  const { Icon } = stat

  return (
    <motion.div
      ref={ref}
      initial={prefersReducedMotion ? false : { opacity: 0, y: 30, scale: 0.95 }}
      animate={isInView ? { opacity: 1, y: 0, scale: 1 } : {}}
      transition={{ delay: index * 0.1, duration: 0.6, ease: SV_EASE }}
      className="group relative text-center p-6 sm:p-8 rounded-2xl bg-white dark:bg-[var(--sv-bg-dark-surface)] border border-[var(--sv-border)] hover:border-[var(--sv-border-accent)] hover:shadow-lg hover:-translate-y-1 transition-all duration-300"
    >
      <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-[var(--sv-accent-lighter)] mb-4 transition-transform duration-300 group-hover:scale-110">
        <Icon className="w-6 h-6 text-[var(--sv-accent)]" />
      </div>
      <div className="mb-2">
        {stat.prefix && (
          <span className="text-2xl sm:text-3xl font-bold text-[var(--sv-accent)]">
            {stat.prefix}
          </span>
        )}
        <span className="text-4xl sm:text-5xl font-bold text-[var(--sv-text-primary)] tabular-nums">
          {animatedValue}
        </span>
        <span className="text-2xl sm:text-3xl font-bold text-[var(--sv-accent)]">
          {stat.suffix}
        </span>
      </div>
      <h3 className="text-base font-semibold text-[var(--sv-text-primary)] mb-1">
        {stat.label}
      </h3>
      <p className="text-sm text-[var(--sv-text-muted)]">{stat.description}</p>
    </motion.div>
  )
}

export function EarningsStats() {
  const ref = useRef<HTMLElement>(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={ref}
      id="earnings"
      className="relative py-16 sm:py-24"
      style={{ background: "var(--sv-bg-secondary)" }}
    >
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--sv-border)] to-transparent" />

      {/* Ambient gradient */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, hsl(var(--accent) / 0.04) 0%, transparent 70%)",
        }}
      />

      <div className="relative z-10 max-w-6xl mx-auto px-4 sm:px-6">
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, ease: SV_EASE }}
          className="text-center max-w-2xl mx-auto mb-12 sm:mb-16"
        >
          <h2 className="sv-heading-md text-[var(--sv-text-primary)] mb-3">
            Numbers That Speak
          </h2>
          <p className="text-[var(--sv-text-secondary)]">
            Real metrics from real supervisors on our platform.
          </p>
        </motion.div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {stats.map((stat, index) => (
            <StatCard key={stat.id} stat={stat} index={index} />
          ))}
        </div>
      </div>
    </section>
  )
}
