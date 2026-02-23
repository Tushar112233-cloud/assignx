/**
 * @fileoverview Supervisor Section - Explains the supervisor system
 *
 * Section highlighting the role of supervisors in the platform:
 * - Quality Assurance
 * - Communication Bridge
 * - Deadline Management
 * - Conflict Resolution
 *
 * Features:
 * - Coffee Bean color palette
 * - Glassmorphism card styling
 * - Framer Motion animations
 * - Responsive 2x2 grid (1 column on mobile)
 * - Visual flow diagram
 * - Trust indicators
 */

"use client";

import { useRef } from "react";
import { motion, useReducedMotion, useInView } from "framer-motion";
import {
  Shield,
  MessageSquare,
  Clock,
  Scale,
  CheckCircle2,
  ArrowRight,
} from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE, STAGGER } from "@/lib/animations/constants";
import { SupervisorCard } from "./supervisor-card";

/**
 * Supervisor responsibilities data
 */
const supervisorBenefits = [
  {
    icon: Shield,
    title: "Quality Assurance",
    description:
      "Every deliverable is reviewed by a dedicated supervisor before reaching you, ensuring the highest standards are met.",
  },
  {
    icon: MessageSquare,
    title: "Communication Bridge",
    description:
      "Supervisors facilitate clear, professional communication between you and experts, eliminating misunderstandings.",
  },
  {
    icon: Clock,
    title: "Deadline Management",
    description:
      "Your supervisor actively monitors progress and ensures timely delivery, keeping your projects on track.",
  },
  {
    icon: Scale,
    title: "Conflict Resolution",
    description:
      "Any issues or concerns are handled professionally by your supervisor, ensuring a smooth experience.",
  },
];

/**
 * Trust indicators data
 */
const trustIndicators = [
  { value: "100%", label: "Supervised Projects" },
  { value: "99.5%", label: "Issue Resolution Rate" },
  { value: "<2h", label: "Response Time" },
];

/**
 * Workflow steps for visual flow diagram
 */
const workflowSteps = [
  { label: "You Submit", sublabel: "Project details" },
  { label: "Supervisor Assigned", sublabel: "Quality oversight" },
  { label: "Expert Works", sublabel: "With supervision" },
  { label: "You Receive", sublabel: "Quality assured" },
];

/**
 * SupervisorSection - Main section explaining the supervisor system
 */
export function SupervisorSection() {
  const ref = useRef<HTMLElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.2 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <section
      ref={ref}
      id="supervisor"
      className="relative py-20 sm:py-28 lg:py-32 overflow-hidden bg-[var(--landing-bg-secondary)]"
    >
      {/* Background decorative elements */}
      <div className="absolute inset-0 landing-grid-pattern opacity-30" />

      {/* Decorative gradient blobs */}
      <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-gradient-to-bl from-[var(--landing-accent-primary)]/10 to-transparent rounded-full blur-3xl opacity-50" />
      <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-gradient-to-tr from-[var(--landing-accent-light)]/20 to-transparent rounded-full blur-3xl opacity-40" />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: ASSIGNX_EASE }}
          className="text-center max-w-3xl mx-auto mb-16 sm:mb-20"
        >
          {/* Badge */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.9 }}
            animate={isInView ? { opacity: 1, scale: 1 } : {}}
            transition={{ delay: 0.1, duration: 0.5, ease: ASSIGNX_EASE }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] mb-6"
          >
            <Shield className="w-4 h-4 text-[var(--landing-accent-primary)]" />
            <span className="text-sm font-medium text-[var(--landing-text-secondary)]">
              Dedicated Supervision
            </span>
          </motion.div>

          {/* Heading */}
          <h2 className="landing-heading-lg text-[var(--landing-text-primary)] mb-6">
            Your Project,{" "}
            <span className="landing-text-gradient">Supervised by Experts</span>
          </h2>

          {/* Description */}
          <p className="text-lg text-[var(--landing-text-secondary)] leading-relaxed">
            Every project is assigned a dedicated supervisor who ensures quality,
            manages communication, and guarantees your satisfaction from start to finish.
          </p>
        </motion.div>

        {/* Visual Flow Diagram */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ delay: 0.2, duration: 0.6, ease: ASSIGNX_EASE }}
          className="mb-16 sm:mb-20"
        >
          <div className="flex flex-col sm:flex-row items-center justify-center gap-2 sm:gap-0">
            {workflowSteps.map((step, index) => (
              <div key={step.label} className="flex items-center">
                {/* Step */}
                <motion.div
                  initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.9 }}
                  animate={isInView ? { opacity: 1, scale: 1 } : {}}
                  transition={{
                    delay: 0.3 + index * 0.1,
                    duration: 0.5,
                    ease: ASSIGNX_EASE,
                  }}
                  className={cn(
                    "relative flex flex-col items-center px-4 sm:px-6 py-4",
                    "rounded-xl bg-[var(--landing-bg-elevated)]",
                    "border border-[var(--landing-border)]",
                    "shadow-sm"
                  )}
                >
                  {/* Step number */}
                  <div
                    className={cn(
                      "absolute -top-3 left-1/2 -translate-x-1/2",
                      "w-6 h-6 rounded-full",
                      "bg-gradient-to-br from-[var(--landing-accent-primary)] to-[var(--landing-accent-secondary)]",
                      "flex items-center justify-center",
                      "text-xs font-bold text-white"
                    )}
                  >
                    {index + 1}
                  </div>
                  <span className="text-sm font-semibold text-[var(--landing-text-primary)] mt-1">
                    {step.label}
                  </span>
                  <span className="text-xs text-[var(--landing-text-muted)]">
                    {step.sublabel}
                  </span>
                </motion.div>

                {/* Arrow between steps */}
                {index < workflowSteps.length - 1 && (
                  <motion.div
                    initial={prefersReducedMotion ? false : { opacity: 0, x: -10 }}
                    animate={isInView ? { opacity: 1, x: 0 } : {}}
                    transition={{
                      delay: 0.4 + index * 0.1,
                      duration: 0.4,
                      ease: ASSIGNX_EASE,
                    }}
                    className="hidden sm:flex items-center px-3"
                  >
                    <ArrowRight className="w-5 h-5 text-[var(--landing-accent-primary)]" />
                  </motion.div>
                )}
              </div>
            ))}
          </div>
        </motion.div>

        {/* Supervisor responsibility cards - 2x2 grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 lg:gap-8 mb-16 sm:mb-20">
          {supervisorBenefits.map((benefit, index) => (
            <SupervisorCard
              key={benefit.title}
              icon={benefit.icon}
              title={benefit.title}
              description={benefit.description}
              delay={0.4 + index * STAGGER.normal}
              isInView={isInView}
            />
          ))}
        </div>

        {/* Trust indicators */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ delay: 0.8, duration: 0.6, ease: ASSIGNX_EASE }}
          className="relative"
        >
          <div
            className={cn(
              "flex flex-col sm:flex-row items-center justify-center gap-8 sm:gap-16",
              "py-8 px-6 rounded-2xl",
              "bg-gradient-to-r from-[var(--landing-accent-lighter)] via-[var(--landing-bg-elevated)] to-[var(--landing-accent-lighter)]",
              "border border-[var(--landing-border)]"
            )}
          >
            {trustIndicators.map((indicator, index) => (
              <motion.div
                key={indicator.label}
                initial={prefersReducedMotion ? false : { opacity: 0, y: 10 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{
                  delay: 0.9 + index * 0.1,
                  duration: 0.5,
                  ease: ASSIGNX_EASE,
                }}
                className="flex items-center gap-3"
              >
                <div className="flex items-center justify-center w-10 h-10 rounded-full bg-[var(--landing-accent-primary)]/10">
                  <CheckCircle2 className="w-5 h-5 text-[var(--landing-accent-primary)]" />
                </div>
                <div>
                  <div className="text-2xl sm:text-3xl font-bold text-[var(--landing-text-primary)] tabular-nums">
                    {indicator.value}
                  </div>
                  <div className="text-xs sm:text-sm text-[var(--landing-text-muted)]">
                    {indicator.label}
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
