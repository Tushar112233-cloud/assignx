/**
 * @fileoverview Task Categories Marquee — Dolancer Landing
 *
 * Two-row scrolling strip showing all task types available on the platform.
 * Row 1 scrolls left, Row 2 scrolls right.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import { Marquee } from "@/components/ui/marquee"
import { cn } from "@/lib/utils"
import { DOER_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

const row1 = [
  { label: "Research Reports", emoji: "📋" },
  { label: "Essay Writing", emoji: "✍️" },
  { label: "Data Analysis", emoji: "📊" },
  { label: "Proofreading", emoji: "🔍" },
  { label: "Case Studies", emoji: "📌" },
  { label: "Literature Review", emoji: "📚" },
  { label: "Presentations", emoji: "🎯" },
  { label: "Thesis Assistance", emoji: "🎓" },
]

const row2 = [
  { label: "1-on-1 Tutoring", emoji: "🧑‍🏫" },
  { label: "Code Review", emoji: "💻" },
  { label: "Translation", emoji: "🌐" },
  { label: "Business Reports", emoji: "📈" },
  { label: "Lab Reports", emoji: "🧪" },
  { label: "Statistics", emoji: "📐" },
  { label: "Proposal Writing", emoji: "📝" },
  { label: "Consulting", emoji: "💼" },
]

/** Pill badge for a single task category */
function CategoryPill({ label, emoji }: { label: string; emoji: string }) {
  return (
    <div
      className={cn(
        "flex items-center gap-2 px-4 py-2.5 rounded-full select-none whitespace-nowrap",
        "bg-white dark:bg-[var(--landing-bg-elevated)]",
        "border border-[var(--landing-border)]",
        "hover:border-[var(--landing-border-teal)] hover:shadow-sm",
        "transition-all duration-200 cursor-default"
      )}
    >
      <span aria-hidden="true">{emoji}</span>
      <span className="text-sm font-medium text-[var(--landing-text-secondary)]">
        {label}
      </span>
    </div>
  )
}

/** Task Categories Section */
export function TaskCategories() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.3 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      className="relative py-16 overflow-hidden"
      style={{ background: "var(--landing-bg-primary)" }}
    >
      {/* Top separator */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Section label + headline */}
      <div className="max-w-4xl mx-auto px-4 text-center mb-10">
        <motion.p
          initial={prefersReducedMotion ? false : { opacity: 0, y: 15 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, ease: DOER_EASE }}
          className="text-sm font-medium text-[var(--landing-text-muted)] uppercase tracking-widest mb-2"
        >
          Tasks Available Now
        </motion.p>
        <motion.h3
          initial={prefersReducedMotion ? false : { opacity: 0, y: 15 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ delay: 0.1, duration: 0.5, ease: DOER_EASE }}
          className="landing-heading-md text-[var(--landing-text-primary)]"
        >
          Every Subject.{" "}
          <span className="landing-text-gradient">Your Expertise.</span>
        </motion.h3>
      </div>

      {/* Two-row marquee */}
      <motion.div
        initial={prefersReducedMotion ? false : { opacity: 0 }}
        animate={isInView ? { opacity: 1 } : {}}
        transition={{ delay: 0.2, duration: 0.6, ease: DOER_EASE }}
        className="relative"
      >
        {/* Row 1 — left scroll */}
        <Marquee pauseOnHover className="[--duration:28s] mb-3">
          {row1.map((item) => (
            <CategoryPill key={item.label} {...item} />
          ))}
        </Marquee>

        {/* Row 2 — right scroll */}
        <Marquee reverse pauseOnHover className="[--duration:32s]">
          {row2.map((item) => (
            <CategoryPill key={item.label} {...item} />
          ))}
        </Marquee>

        {/* Fade edges */}
        <div className="pointer-events-none absolute inset-y-0 left-0 w-1/5 bg-gradient-to-r from-[var(--landing-bg-primary)] to-transparent" />
        <div className="pointer-events-none absolute inset-y-0 right-0 w-1/5 bg-gradient-to-l from-[var(--landing-bg-primary)] to-transparent" />
      </motion.div>
    </section>
  )
}
