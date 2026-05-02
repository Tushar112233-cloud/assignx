/**
 * @fileoverview PainPointsSection - Competitor pain points comparison section
 *
 * Displays problems AssignX solves in a "Before vs After" format:
 * - NO competitor names (focuses on industry problems)
 * - Pictographic icons for each pain point
 * - Animated transitions on scroll
 * - Two-column comparison layout
 *
 * Pain points addressed:
 * 1. Inconsistent Quality -> Guaranteed Standards
 * 2. Missed Deadlines -> On-Time Delivery
 * 3. Communication Gaps -> Clear Updates
 * 4. No Accountability -> Supervised Process
 * 5. Privacy Concerns -> Secure Platform
 * 6. Hidden Fees -> Transparent Pricing
 */

"use client";

import { useRef } from "react";
import { motion, useReducedMotion, useInView } from "framer-motion";
import {
  XCircle,
  CheckCircle,
  Clock,
  Timer,
  MessageSquareOff,
  MessageSquare,
  UserX,
  ShieldCheck,
  EyeOff,
  Lock,
  AlertTriangle,
  Receipt,
} from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";
import { PainPointCard, type PainPointItem } from "./pain-point-card";
import "@/app/landing.css";

/**
 * Pain points data with icons and descriptions
 */
const painPoints: PainPointItem[] = [
  {
    problem: {
      icon: XCircle,
      text: "Inconsistent Quality",
      description:
        "Unpredictable results with no quality standards. You never know what you'll get.",
    },
    solution: {
      icon: CheckCircle,
      text: "Guaranteed Standards",
      description:
        "Every project reviewed by experts. 98% satisfaction rate with unlimited revisions.",
    },
  },
  {
    problem: {
      icon: Clock,
      text: "Missed Deadlines",
      description:
        "Late deliveries causing stress and missed submissions. No accountability.",
    },
    solution: {
      icon: Timer,
      text: "On-Time Delivery",
      description:
        "Guaranteed delivery before your deadline. Express options for urgent needs.",
    },
  },
  {
    problem: {
      icon: MessageSquareOff,
      text: "Communication Gaps",
      description:
        "Left in the dark with no updates. Questions go unanswered for days.",
    },
    solution: {
      icon: MessageSquare,
      text: "Clear Updates",
      description:
        "Real-time progress tracking. Instant chat with your assigned expert.",
    },
  },
  {
    problem: {
      icon: UserX,
      text: "No Accountability",
      description:
        "Anonymous workers with no oversight. No one takes responsibility.",
    },
    solution: {
      icon: ShieldCheck,
      text: "Supervised Process",
      description:
        "Verified experts with ratings. Quality assurance at every step.",
    },
  },
  {
    problem: {
      icon: EyeOff,
      text: "Privacy Concerns",
      description:
        "Your data shared or sold. Personal information at risk.",
    },
    solution: {
      icon: Lock,
      text: "Secure Platform",
      description:
        "Enterprise-grade encryption. Your data never shared or sold.",
    },
  },
  {
    problem: {
      icon: AlertTriangle,
      text: "Hidden Fees",
      description:
        "Surprise charges after work begins. Final cost always higher than quoted.",
    },
    solution: {
      icon: Receipt,
      text: "Transparent Pricing",
      description:
        "Upfront pricing with no surprises. Pay only what you see quoted.",
    },
  },
];

/**
 * Section header component with animated badge and title
 */
function SectionHeader() {
  const prefersReducedMotion = useReducedMotion();

  return (
    <div className="text-center max-w-3xl mx-auto mb-12 md:mb-16">
      {/* Badge */}
      <motion.div
        initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6, ease: ASSIGNX_EASE }}
        className="mb-6"
      >
        <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] text-sm font-medium text-[var(--landing-text-secondary)]">
          <span className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--landing-accent-primary)] opacity-75" />
            <span className="relative inline-flex rounded-full h-2 w-2 bg-[var(--landing-accent-primary)]" />
          </span>
          Why Choose AssignX
        </span>
      </motion.div>

      {/* Title */}
      <motion.h2
        initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ delay: 0.1, duration: 0.8, ease: ASSIGNX_EASE }}
        className="landing-heading-lg text-[var(--landing-text-primary)] mb-6"
      >
        Say goodbye to{" "}
        <span className="landing-text-gradient">common frustrations</span>
      </motion.h2>

      {/* Subtitle */}
      <motion.p
        initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ delay: 0.2, duration: 0.8, ease: ASSIGNX_EASE }}
        className="text-lg text-[var(--landing-text-secondary)] leading-relaxed"
      >
        We've solved the problems that plague traditional assignment help services.
        Here's what makes AssignX different.
      </motion.p>
    </div>
  );
}

/**
 * Visual legend showing the before/after format
 */
function ComparisonLegend() {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ delay: 0.3, duration: 0.6, ease: ASSIGNX_EASE }}
      className="flex flex-wrap items-center justify-center gap-6 sm:gap-8 mb-10 md:mb-12"
    >
      {/* Problem indicator */}
      <div className="flex items-center gap-2">
        <div className="w-4 h-4 rounded-full bg-red-100 dark:bg-red-900/30 border border-red-200 dark:border-red-800/50 flex items-center justify-center">
          <XCircle className="w-3 h-3 text-red-500" />
        </div>
        <span className="text-sm text-[var(--landing-text-muted)]">
          Industry Problem
        </span>
      </div>

      {/* Arrow */}
      <div className="hidden sm:block text-[var(--landing-text-muted)]">
        <svg
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          className="opacity-50"
        >
          <path
            d="M5 12H19M19 12L12 5M19 12L12 19"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>

      {/* Solution indicator */}
      <div className="flex items-center gap-2">
        <div className="w-4 h-4 rounded-full bg-emerald-100 dark:bg-emerald-900/30 border border-emerald-200 dark:border-emerald-800/50 flex items-center justify-center">
          <CheckCircle className="w-3 h-3 text-emerald-500" />
        </div>
        <span className="text-sm text-[var(--landing-text-muted)]">
          AssignX Solution
        </span>
      </div>
    </motion.div>
  );
}

/**
 * Bottom CTA with summary stats
 */
function BottomCTA() {
  const prefersReducedMotion = useReducedMotion();

  const stats = [
    { value: "98%", label: "Satisfaction Rate" },
    { value: "0", label: "Hidden Fees" },
    { value: "24/7", label: "Support Available" },
  ];

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ delay: 0.4, duration: 0.8, ease: ASSIGNX_EASE }}
      className="mt-12 md:mt-16 text-center"
    >
      {/* Stats row */}
      <div className="flex items-center justify-center gap-8 sm:gap-12 mb-8">
        {stats.map((stat, index) => (
          <motion.div
            key={stat.label}
            initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.8 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{
              delay: 0.5 + index * 0.1,
              duration: 0.5,
              ease: ASSIGNX_EASE,
            }}
            className="text-center"
          >
            <div className="text-2xl sm:text-3xl font-bold text-[var(--landing-accent-primary)] tabular-nums">
              {stat.value}
            </div>
            <div className="text-xs sm:text-sm text-[var(--landing-text-muted)]">
              {stat.label}
            </div>
          </motion.div>
        ))}
      </div>

      {/* CTA text */}
      <p className="text-[var(--landing-text-secondary)] mb-6">
        Ready to experience the difference?
      </p>

      {/* CTA button */}
      <motion.a
        href="/signup"
        whileHover={prefersReducedMotion ? {} : { scale: 1.02, y: -2 }}
        whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
        className="landing-btn-primary inline-flex items-center gap-2"
      >
        Get Started Today
        <CheckCircle className="w-4 h-4" />
      </motion.a>
    </motion.div>
  );
}

/**
 * Main PainPointsSection component
 * Displays all pain points in an animated grid
 */
export function PainPointsSection() {
  const containerRef = useRef<HTMLElement>(null);
  const isInView = useInView(containerRef, { once: true, margin: "-100px" });

  return (
    <section
      ref={containerRef}
      id="pain-points"
      className={cn(
        "relative py-20 md:py-28 lg:py-32",
        "bg-[var(--landing-bg-secondary)]",
        "overflow-hidden"
      )}
    >
      {/* Subtle background pattern */}
      <div className="absolute inset-0 landing-grid-pattern opacity-30 pointer-events-none" />

      {/* Decorative gradient blobs */}
      <div
        className={cn(
          "absolute top-0 left-0 w-[500px] h-[500px]",
          "bg-red-500/5 rounded-full blur-[120px]",
          "pointer-events-none -translate-x-1/2 -translate-y-1/2"
        )}
      />
      <div
        className={cn(
          "absolute bottom-0 right-0 w-[500px] h-[500px]",
          "bg-emerald-500/5 rounded-full blur-[120px]",
          "pointer-events-none translate-x-1/2 translate-y-1/2"
        )}
      />

      <div className="container relative z-10 px-4 sm:px-6 lg:px-8 max-w-6xl mx-auto">
        {/* Section header */}
        <SectionHeader />

        {/* Comparison legend */}
        <ComparisonLegend />

        {/* Pain points grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 md:gap-8">
          {painPoints.map((item, index) => (
            <PainPointCard key={item.problem.text} item={item} index={index} />
          ))}
        </div>

        {/* Bottom CTA */}
        <BottomCTA />
      </div>
    </section>
  );
}
