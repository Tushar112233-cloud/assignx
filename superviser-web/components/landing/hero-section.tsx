/**
 * @fileoverview Hero Section — Supervisor Landing
 *
 * Two-column: headline + twin CTAs left, cycling stacked metric cards right.
 * Cards auto-cycle every 3s using framer-motion spring stack animation.
 */
"use client"

import { useRef, useState, useEffect } from "react"
import Link from "next/link"
import {
  motion,
  useReducedMotion,
  useScroll,
  useTransform,
  useSpring,
} from "framer-motion"
import {
  ArrowRight,
  ShieldCheck,
  IndianRupee,
  Star,
  FolderKanban,
  CheckCircle2,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const heroStats = [
  { value: "1,200+", label: "Active Supervisors" },
  { value: "₹4Cr+", label: "Total Paid Out" },
  { value: "8K+", label: "Projects Supervised" },
  { value: "₹22K", label: "Avg. Monthly Earning" },
]

/** Cycling metric cards — same spring stack mechanic as doer-web */
const metricCards = [
  {
    id: 1,
    icon: FolderKanban,
    label: "Active Projects",
    value: "12",
    sub: "this month",
    iconBg: "bg-orange-100 dark:bg-orange-900/30",
    iconColor: "text-orange-600 dark:text-orange-400",
  },
  {
    id: 2,
    icon: CheckCircle2,
    label: "QC Reviews Done",
    value: "48",
    sub: "this month",
    iconBg: "bg-emerald-100 dark:bg-emerald-900/30",
    iconColor: "text-emerald-600 dark:text-emerald-400",
  },
  {
    id: 3,
    icon: IndianRupee,
    label: "Commission Earned",
    value: "₹24,000",
    sub: "this month",
    iconBg: "bg-amber-100 dark:bg-amber-900/30",
    iconColor: "text-amber-600 dark:text-amber-400",
  },
]

const stackPositions = [
  { x: 0, y: 0, scale: 1, opacity: 1, rotate: -2, zIndex: 3 },
  { x: 18, y: -18, scale: 0.92, opacity: 0.75, rotate: 2, zIndex: 2 },
  { x: 36, y: -36, scale: 0.84, opacity: 0.5, rotate: -1, zIndex: 1 },
]

function StackedMetricCards() {
  const [activeIndex, setActiveIndex] = useState(0)
  const prefersReducedMotion = useReducedMotion()

  useEffect(() => {
    if (prefersReducedMotion) return
    const interval = setInterval(
      () => setActiveIndex((p) => (p + 1) % metricCards.length),
      3000
    )
    return () => clearInterval(interval)
  }, [prefersReducedMotion])

  return (
    <div className="flex flex-col items-center gap-5">
      <div className="relative" style={{ width: 256, height: 140 }}>
        {metricCards.map((card, cardIndex) => {
          const position =
            (cardIndex - activeIndex + metricCards.length) % metricCards.length
          const { zIndex, ...animProps } = stackPositions[position]
          const { icon: Icon } = card
          return (
            <motion.div
              key={card.id}
              animate={animProps}
              transition={{ type: "spring", stiffness: 220, damping: 26 }}
              onClick={() =>
                setActiveIndex((p) => (p + 1) % metricCards.length)
              }
              className={cn(
                "absolute inset-0 rounded-2xl p-4 shadow-xl cursor-pointer select-none",
                "bg-white dark:bg-[var(--sv-bg-dark-surface)]",
                "border border-[var(--sv-border)]",
                "hover:shadow-2xl transition-shadow duration-300"
              )}
              style={{ zIndex }}
            >
              <div className="flex items-center gap-3 mb-2">
                <div
                  className={cn(
                    "w-9 h-9 rounded-xl flex items-center justify-center",
                    card.iconBg
                  )}
                >
                  <Icon className={cn("w-5 h-5", card.iconColor)} />
                </div>
                <span className="text-sm font-medium text-[var(--sv-text-muted)]">
                  {card.label}
                </span>
              </div>
              <div className="flex items-baseline gap-1.5">
                <span className="text-2xl font-bold text-[var(--sv-text-primary)]">
                  {card.value}
                </span>
                <span className="text-xs text-[var(--sv-text-muted)]">{card.sub}</span>
              </div>
            </motion.div>
          )
        })}
      </div>

      {/* Dot indicators */}
      <div className="flex gap-2 relative z-10">
        {metricCards.map((_, i) => (
          <button
            key={i}
            onClick={() => setActiveIndex(i)}
            aria-label={`Show metric ${i + 1}`}
            className={cn(
              "rounded-full transition-all duration-300",
              i === activeIndex
                ? "w-6 h-2 bg-[var(--sv-accent)]"
                : "w-2 h-2 bg-[var(--sv-border-accent)] hover:bg-[var(--sv-accent)]/50"
            )}
          />
        ))}
      </div>
    </div>
  )
}

export function HeroSection() {
  const ref = useRef<HTMLDivElement>(null)
  const prefersReducedMotion = useReducedMotion()

  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  })
  const springScroll = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001,
  })
  const y = useTransform(springScroll, [0, 1], [0, -50])

  return (
    <section
      ref={ref}
      id="hero"
      className={cn(
        "relative min-h-[90vh] flex items-center overflow-hidden",
        "pt-24 pb-16 sm:pt-28 sm:pb-20 md:pt-32 md:pb-24"
      )}
      style={{ background: "var(--sv-bg-primary)" }}
    >
      {/* Grid overlay */}
      <div className="absolute inset-0 sv-grid-pattern opacity-30" />

      {/* Orange orb — top right */}
      <motion.div
        className="absolute top-20 right-16 w-96 h-96 rounded-full blur-3xl pointer-events-none"
        style={{ background: "hsl(var(--accent) / 0.08)" }}
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1, 1.15, 1], opacity: [0.08, 0.16, 0.08] }
        }
        transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
      />

      {/* Cyan orb — bottom left */}
      <motion.div
        className="absolute bottom-20 left-10 w-72 h-72 rounded-full blur-3xl pointer-events-none"
        style={{ background: "rgba(34,211,238,0.07)" }}
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1.1, 1, 1.1], opacity: [0.07, 0.13, 0.07] }
        }
        transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
      />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
        {/* Left: text */}
        <motion.div style={prefersReducedMotion ? {} : { y }}>
          {/* Badge */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, ease: SV_EASE }}
            className="mb-6"
          >
            <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--sv-accent-lighter)] border border-[var(--sv-border-accent)] text-sm font-medium text-[var(--sv-accent)]">
              <motion.span
                className="w-2 h-2 rounded-full bg-[var(--sv-accent)]"
                animate={prefersReducedMotion ? {} : { scale: [1, 1.5, 1] }}
                transition={{ duration: 2, repeat: Infinity }}
              />
              Verified Expert Network
            </span>
          </motion.div>

          {/* Headline */}
          <motion.h1
            initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.7, ease: SV_EASE }}
            className="sv-heading-xl text-[var(--sv-text-primary)] mb-6"
          >
            Lead Projects.{" "}
            <span className="sv-text-gradient">Ensure Quality.</span>
            {" "}Earn as an Expert.
          </motion.h1>

          {/* Sub-headline */}
          <motion.p
            initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.6, ease: SV_EASE }}
            className="text-lg text-[var(--sv-text-secondary)] mb-8 max-w-xl leading-relaxed"
          >
            Manage academic tasks in your domain. Review work. Brief
            DoLancers. Earn{" "}
            <span className="font-semibold text-[var(--sv-text-primary)]">
              15% commission
            </span>{" "}
            on every completed project — paid within 48 hours.
          </motion.p>

          {/* CTAs */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.6, ease: SV_EASE }}
            className="flex flex-col sm:flex-row gap-3 mb-10"
          >
            <Link href="/register" className="sv-btn-primary group">
              Apply as Supervisor
              <ArrowRight className="ml-2 w-4 h-4 transition-transform group-hover:translate-x-1" />
            </Link>
            <Link href="/login" className="sv-btn-secondary">
              <ShieldCheck className="mr-2 w-4 h-4" />
              Sign In
            </Link>
          </motion.div>

          {/* Stats strip */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5, duration: 0.6, ease: SV_EASE }}
            className="flex flex-wrap gap-6 pt-6 border-t border-[var(--sv-border)]"
          >
            {heroStats.map((stat, i) => (
              <motion.div
                key={stat.label}
                initial={prefersReducedMotion ? false : { opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.55 + i * 0.08 }}
              >
                <div className="text-xl font-bold text-[var(--sv-text-primary)]">
                  {stat.value}
                </div>
                <div className="text-xs text-[var(--sv-text-muted)]">
                  {stat.label}
                </div>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* Right: cycling metric card stack */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4, duration: 0.6 }}
          className="relative hidden lg:flex flex-col items-center justify-center gap-8 h-80"
        >
          {/* Rotating dashed ring */}
          <motion.div
            className="absolute w-52 h-52 rounded-full border-2 border-dashed border-[var(--sv-border-accent)] pointer-events-none"
            animate={prefersReducedMotion ? {} : { rotate: 360 }}
            transition={{ duration: 30, repeat: Infinity, ease: "linear" }}
          />

          <StackedMetricCards />

          {/* Earnings badge */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.9, type: "spring", stiffness: 200 }}
            className="absolute -bottom-4 right-4 bg-white dark:bg-[var(--sv-bg-dark-surface)] border border-[var(--sv-border)] rounded-2xl px-4 py-3 shadow-lg flex items-center gap-3 z-20"
          >
            <div className="w-9 h-9 rounded-full bg-green-100 flex items-center justify-center flex-shrink-0">
              <IndianRupee className="w-4 h-4 text-green-600" />
            </div>
            <div>
              <div className="text-xs text-[var(--sv-text-muted)]">
                Avg. monthly earning
              </div>
              <div className="text-base font-bold text-[var(--sv-text-primary)]">
                ₹22,000
              </div>
            </div>
          </motion.div>

          {/* Verified badge */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 1.1, type: "spring", stiffness: 200 }}
            className="absolute -top-2 left-4 bg-white dark:bg-[var(--sv-bg-dark-surface)] border border-[var(--sv-border)] rounded-2xl px-3 py-2 shadow-lg flex items-center gap-2 z-20"
          >
            <Star className="w-4 h-4 text-yellow-400 fill-yellow-400" />
            <span className="text-sm font-semibold text-[var(--sv-text-primary)]">
              Verified Expert
            </span>
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}
