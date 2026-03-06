/**
 * @fileoverview Hero Section — Doer Landing
 *
 * Large headline with floating task cards showing earning potential.
 * Two CTA buttons, stat strip at bottom.
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
  Briefcase,
  Clock,
  IndianRupee,
  Star,
  Zap,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { DOER_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

/** Floating task card data */
const taskCards = [
  {
    id: 1,
    title: "Research Report",
    subject: "Biology",
    price: "2,400",
    deadline: "48 hrs",
    urgency: "urgent" as const,
    icon: "📊",
  },
  {
    id: 2,
    title: "Essay Proofreading",
    subject: "English Literature",
    price: "800",
    deadline: "24 hrs",
    urgency: "normal" as const,
    icon: "✍️",
  },
  {
    id: 3,
    title: "Data Analysis",
    subject: "Statistics",
    price: "3,200",
    deadline: "72 hrs",
    urgency: "normal" as const,
    icon: "📈",
  },
]

/** Stats shown beneath CTAs */
const heroStats = [
  { value: "2,400+", label: "Active Doers" },
  { value: "₹8Cr+", label: "Total Paid Out" },
  { value: "12K+", label: "Tasks Completed" },
  { value: "4.9★", label: "Avg. Rating" },
]

/** Card positioning offsets for the 3D stacked effect */
const cardOffsets = [
  { x: 0, y: 0, rotate: -3 },
  { x: 28, y: -22, rotate: 2 },
  { x: 56, y: -6, rotate: -1 },
]

type TaskCard = (typeof taskCards)[0]

/** Individual floating task card */
function FloatingTaskCard({
  task,
  index,
  isVisible,
}: {
  task: TaskCard
  index: number
  isVisible: boolean
}) {
  const prefersReducedMotion = useReducedMotion()
  const offset = cardOffsets[index]

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, x: 40, y: 20 }}
      animate={
        isVisible
          ? { opacity: 1, x: offset.x, y: offset.y }
          : {}
      }
      transition={{
        delay: 0.4 + index * 0.15,
        duration: 0.7,
        ease: DOER_EASE,
      }}
      whileHover={{ scale: 1.03, rotate: 0 }}
      className={cn(
        "absolute w-60 bg-white dark:bg-[var(--landing-bg-elevated)]",
        "backdrop-blur-xl border border-[var(--landing-border)]",
        "rounded-2xl p-4 shadow-xl cursor-pointer",
        "hover:shadow-2xl hover:-translate-y-1 transition-shadow duration-300",
        index === 0 && "left-0 top-10",
        index === 1 && "left-7 top-0",
        index === 2 && "left-14 -top-5"
      )}
      style={{ zIndex: 3 - index, rotate: `${offset.rotate}deg` }}
    >
      {/* Card header */}
      <div className="flex items-start justify-between mb-3">
        <span className="text-2xl">{task.icon}</span>
        {task.urgency === "urgent" && (
          <span className="flex items-center gap-1 text-xs font-semibold text-orange-600 bg-orange-50 px-2 py-0.5 rounded-full">
            <Zap className="w-3 h-3" />
            Urgent
          </span>
        )}
      </div>

      {/* Task info */}
      <h4 className="text-sm font-semibold text-[var(--landing-text-primary)] mb-0.5 truncate">
        {task.title}
      </h4>
      <p className="text-xs text-[var(--landing-text-muted)] mb-3">
        {task.subject}
      </p>

      {/* Price + deadline */}
      <div className="flex items-center justify-between">
        <span className="flex items-center gap-0.5 text-base font-bold text-[var(--landing-accent-primary)]">
          <IndianRupee className="w-3.5 h-3.5" />
          {task.price}
        </span>
        <span className="flex items-center gap-1 text-xs text-[var(--landing-text-muted)]">
          <Clock className="w-3 h-3" />
          {task.deadline}
        </span>
      </div>
    </motion.div>
  )
}

/** Hero Section */
export function HeroSection() {
  const ref = useRef<HTMLDivElement>(null)
  const prefersReducedMotion = useReducedMotion()
  const [isVisible, setIsVisible] = useState(false)

  // Trigger card animations once mounted
  useEffect(() => {
    setIsVisible(true)
  }, [])

  // Parallax scroll for text column
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
    >
      {/* Subtle grid overlay */}
      <div className="absolute inset-0 landing-grid-pattern opacity-30" />

      {/* Teal gradient orb — top right */}
      <motion.div
        className="absolute top-20 right-20 w-96 h-96 bg-[var(--landing-accent-primary)]/10 rounded-full blur-3xl pointer-events-none"
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1, 1.15, 1], opacity: [0.1, 0.18, 0.1] }
        }
        transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
      />

      {/* Emerald orb — bottom left */}
      <motion.div
        className="absolute bottom-20 left-10 w-72 h-72 bg-[var(--landing-accent-secondary)]/8 rounded-full blur-3xl pointer-events-none"
        animate={
          prefersReducedMotion
            ? {}
            : { scale: [1.1, 1, 1.1], opacity: [0.08, 0.15, 0.08] }
        }
        transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
      />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
        {/* ── Left column: text ── */}
        <motion.div style={prefersReducedMotion ? {} : { y }}>
          {/* Badge */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, ease: DOER_EASE }}
            className="mb-6"
          >
            <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border-teal)] text-sm font-medium text-[var(--landing-accent-primary)]">
              <motion.span
                className="w-2 h-2 rounded-full bg-[var(--landing-accent-primary)]"
                animate={{ scale: [1, 1.5, 1] }}
                transition={{ duration: 2, repeat: Infinity }}
              />
              India&apos;s Fastest Growing Expert Network
            </span>
          </motion.div>

          {/* Headline */}
          <motion.h1
            initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.7, ease: DOER_EASE }}
            className="landing-heading-xl text-[var(--landing-text-primary)] mb-6"
          >
            Turn Your Skills Into{" "}
            <span className="landing-text-gradient">Real Earnings</span>
          </motion.h1>

          {/* Sub-text */}
          <motion.p
            initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.6, ease: DOER_EASE }}
            className="text-lg text-[var(--landing-text-secondary)] mb-8 max-w-xl leading-relaxed"
          >
            Accept academic tasks that match your expertise. Deliver quality
            work on your schedule. Get paid fast — no middlemen, no delays.
          </motion.p>

          {/* CTA buttons */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.6, ease: DOER_EASE }}
            className="flex flex-col sm:flex-row gap-3 mb-10"
          >
            <Link
              href="/register"
              className="landing-btn-primary group"
            >
              Start Earning Today
              <ArrowRight className="ml-2 w-4 h-4 transition-transform group-hover:translate-x-1" />
            </Link>
            <a href="#how-it-works" className="landing-btn-secondary">
              <Briefcase className="mr-2 w-4 h-4" />
              Browse Tasks
            </a>
          </motion.div>

          {/* Stats strip */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5, duration: 0.6, ease: DOER_EASE }}
            className="flex flex-wrap gap-6 pt-6 border-t border-[var(--landing-border)]"
          >
            {heroStats.map((stat, i) => (
              <motion.div
                key={stat.label}
                initial={prefersReducedMotion ? false : { opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.55 + i * 0.08 }}
              >
                <div className="text-xl font-bold text-[var(--landing-text-primary)]">
                  {stat.value}
                </div>
                <div className="text-xs text-[var(--landing-text-muted)]">
                  {stat.label}
                </div>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* ── Right column: floating task cards ── */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.6 }}
          className="relative hidden lg:flex items-center justify-center h-80"
        >
          {taskCards.map((task, index) => (
            <FloatingTaskCard
              key={task.id}
              task={task}
              index={index}
              isVisible={isVisible}
            />
          ))}

          {/* Decorative rotating dashed ring */}
          <motion.div
            className="absolute inset-0 m-auto w-48 h-48 rounded-full border-2 border-dashed border-[var(--landing-accent-primary)]/20 pointer-events-none"
            animate={prefersReducedMotion ? {} : { rotate: 360 }}
            transition={{ duration: 30, repeat: Infinity, ease: "linear" }}
          />

          {/* Earnings badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.8, type: "spring", stiffness: 200 }}
            className="absolute -bottom-8 right-8 bg-white dark:bg-[var(--landing-bg-elevated)] border border-[var(--landing-border)] rounded-2xl px-4 py-3 shadow-lg flex items-center gap-3 z-10"
          >
            <div className="w-9 h-9 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0">
              <IndianRupee className="w-4 h-4 text-blue-600" />
            </div>
            <div>
              <div className="text-xs text-[var(--landing-text-muted)]">
                Avg. monthly earning
              </div>
              <div className="text-base font-bold text-[var(--landing-text-primary)]">
                ₹18,400
              </div>
            </div>
          </motion.div>

          {/* Rating badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 1.0, type: "spring", stiffness: 200 }}
            className="absolute -top-4 -left-4 bg-white dark:bg-[var(--landing-bg-elevated)] border border-[var(--landing-border)] rounded-2xl px-3 py-2 shadow-lg flex items-center gap-2 z-10"
          >
            <Star className="w-4 h-4 text-yellow-400 fill-yellow-400" />
            <span className="text-sm font-semibold text-[var(--landing-text-primary)]">
              4.9 Rated
            </span>
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}
