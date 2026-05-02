/**
 * @fileoverview Supervisor Card Component
 *
 * Individual responsibility card for the supervisor section.
 * Features glassmorphism design with subtle hover animations.
 */

"use client";

import { motion, useReducedMotion } from "framer-motion";
import { LucideIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";

/**
 * Props for the SupervisorCard component
 */
interface SupervisorCardProps {
  /** Lucide icon component */
  icon: LucideIcon;
  /** Card title */
  title: string;
  /** Card description */
  description: string;
  /** Animation delay in seconds */
  delay?: number;
  /** Whether the card is in view */
  isInView?: boolean;
}

/**
 * SupervisorCard - Individual responsibility card
 *
 * Displays a single supervisor responsibility with:
 * - Icon with gradient background
 * - Title and description
 * - Glassmorphism styling
 * - Subtle hover animations
 */
export function SupervisorCard({
  icon: Icon,
  title,
  description,
  delay = 0,
  isInView = true,
}: SupervisorCardProps) {
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{
        delay,
        duration: 0.6,
        ease: ASSIGNX_EASE,
      }}
      className="group"
    >
      <div
        className={cn(
          "relative h-full p-6 sm:p-8 rounded-2xl",
          "bg-[var(--landing-bg-glass)]",
          "backdrop-blur-xl",
          "border border-[var(--landing-border)]",
          "transition-all duration-400",
          "hover:border-[var(--landing-accent-light)]",
          "hover:shadow-lg hover:shadow-[var(--landing-accent-primary)]/5",
          "hover:-translate-y-1"
        )}
      >
        {/* Gradient overlay on hover */}
        <div
          className={cn(
            "absolute inset-0 rounded-2xl opacity-0 transition-opacity duration-400",
            "bg-gradient-to-br from-[var(--landing-accent-primary)]/5 to-transparent",
            "group-hover:opacity-100"
          )}
        />

        {/* Icon container */}
        <motion.div
          whileHover={prefersReducedMotion ? {} : { scale: 1.05 }}
          transition={{ duration: 0.3, ease: ASSIGNX_EASE }}
          className={cn(
            "relative inline-flex items-center justify-center",
            "w-14 h-14 rounded-xl mb-5",
            "bg-gradient-to-br from-[var(--landing-accent-primary)] to-[var(--landing-accent-secondary)]",
            "shadow-md shadow-[var(--landing-accent-primary)]/20"
          )}
        >
          <Icon className="w-7 h-7 text-white" />
        </motion.div>

        {/* Content */}
        <div className="relative">
          <h3
            className={cn(
              "text-lg sm:text-xl font-semibold mb-2",
              "text-[var(--landing-text-primary)]",
              "transition-colors duration-300",
              "group-hover:text-[var(--landing-accent-primary)]"
            )}
          >
            {title}
          </h3>
          <p className="text-sm sm:text-base text-[var(--landing-text-secondary)] leading-relaxed">
            {description}
          </p>
        </div>

        {/* Decorative corner accent */}
        <div
          className={cn(
            "absolute bottom-0 right-0 w-24 h-24 rounded-tl-[100px]",
            "bg-gradient-to-tl from-[var(--landing-accent-lighter)] to-transparent",
            "opacity-0 transition-opacity duration-400",
            "group-hover:opacity-50"
          )}
        />
      </div>
    </motion.div>
  );
}
