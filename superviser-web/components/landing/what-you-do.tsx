/**
 * @fileoverview What You Do — Supervisor Landing
 *
 * 5-card bento grid describing the supervisor's role on the platform.
 */
"use client"

import { useRef } from "react"
import { motion, useReducedMotion, useInView } from "framer-motion"
import {
  Calculator,
  Users,
  SearchCheck,
  MessageCircle,
  BarChart3,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { SV_EASE } from "@/lib/animations/constants"
import "@/app/landing.css"

interface Role {
  id: string
  Icon: React.ElementType
  title: string
  description: string
  size: "sm" | "lg"
  gradient: string
  iconBg: string
  iconColor: string
}

const roles: Role[] = [
  {
    id: "quote",
    Icon: Calculator,
    title: "Analyze & Quote",
    description:
      "Review incoming task requests, assess complexity, set the right price, and confirm feasibility before the client pays.",
    size: "lg",
    gradient: "from-orange-500/10 to-orange-500/5",
    iconBg: "bg-orange-100 dark:bg-orange-900/30",
    iconColor: "text-orange-600 dark:text-orange-400",
  },
  {
    id: "brief",
    Icon: Users,
    title: "Brief DoLancers",
    description:
      "Assign the right expert, share full requirements, set deadlines, and keep them on track.",
    size: "sm",
    gradient: "from-amber-500/10 to-amber-500/5",
    iconBg: "bg-amber-100 dark:bg-amber-900/30",
    iconColor: "text-amber-600 dark:text-amber-400",
  },
  {
    id: "qc",
    Icon: SearchCheck,
    title: "Quality Control",
    description:
      "Review every submission before it reaches the client. Approve, reject, or request revisions to ensure top-tier output.",
    size: "sm",
    gradient: "from-cyan-500/10 to-cyan-500/5",
    iconBg: "bg-cyan-100 dark:bg-cyan-900/30",
    iconColor: "text-cyan-600 dark:text-cyan-400",
  },
  {
    id: "comms",
    Icon: MessageCircle,
    title: "Client Communication",
    description:
      "Keep clients informed on progress, handle questions, and manage expectations throughout the project lifecycle.",
    size: "sm",
    gradient: "from-orange-500/10 to-amber-500/5",
    iconBg: "bg-orange-100 dark:bg-orange-900/30",
    iconColor: "text-orange-600 dark:text-orange-400",
  },
  {
    id: "track",
    Icon: BarChart3,
    title: "Track & Report",
    description:
      "Monitor deadlines, flag blockers early, and ensure every project lands on time with full documentation.",
    size: "lg",
    gradient: "from-emerald-500/10 to-cyan-500/5",
    iconBg: "bg-emerald-100 dark:bg-emerald-900/30",
    iconColor: "text-emerald-600 dark:text-emerald-400",
  },
]

export function WhatYouDo() {
  const sectionRef = useRef<HTMLElement>(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.15 })
  const prefersReducedMotion = useReducedMotion()

  return (
    <section
      ref={sectionRef}
      id="role"
      className="relative py-24 md:py-32 overflow-hidden"
      style={{ background: "var(--sv-bg-primary)" }}
    >
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--sv-border)] to-transparent" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: SV_EASE }}
          className="text-center mb-14"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--sv-accent-lighter)] border border-[var(--sv-border-accent)] mb-6">
            <span className="text-sm font-medium text-[var(--sv-accent)]">
              Your Role
            </span>
          </span>
          <h2 className="sv-heading-lg text-[var(--sv-text-primary)] mb-4">
            What{" "}
            <span className="sv-text-gradient">Supervisors Do</span>
          </h2>
          <p className="text-lg text-[var(--sv-text-secondary)] max-w-2xl mx-auto">
            From intake to delivery — you own the project lifecycle.
          </p>
        </motion.div>

        {/* Bento grid — 4 columns */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {roles.map((role, index) => (
            <motion.div
              key={role.id}
              initial={prefersReducedMotion ? false : { opacity: 0, y: 24 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{
                delay: index * 0.07,
                duration: 0.6,
                ease: SV_EASE,
              }}
              className={cn(
                "group relative rounded-2xl p-6 overflow-hidden",
                "bg-white dark:bg-[var(--sv-bg-dark-surface)]",
                "border border-[var(--sv-border)]",
                "hover:border-[var(--sv-border-accent)] hover:shadow-lg hover:-translate-y-1",
                "transition-all duration-300",
                role.size === "lg" ? "md:col-span-2" : "md:col-span-1"
              )}
            >
              {/* Hover gradient */}
              <div
                className={cn(
                  "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-300",
                  role.gradient
                )}
              />
              <div className="relative z-10">
                <div
                  className={cn(
                    "w-11 h-11 rounded-xl flex items-center justify-center mb-4",
                    role.iconBg
                  )}
                >
                  <role.Icon className={cn("w-5 h-5", role.iconColor)} />
                </div>
                <h3 className="text-base font-semibold text-[var(--sv-text-primary)] mb-2">
                  {role.title}
                </h3>
                <p className="text-sm text-[var(--sv-text-muted)] leading-relaxed">
                  {role.description}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
