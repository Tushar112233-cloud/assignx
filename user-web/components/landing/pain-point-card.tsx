/**
 * @fileoverview PainPointCard - Individual pain point comparison card
 *
 * Displays a before/after comparison for a specific pain point:
 * - Left side: Problem with red tint and X icon
 * - Arrow transition in the middle
 * - Right side: Solution with green/coffee bean tint and check icon
 * - Hover reveals more details with smooth animations
 */

"use client";

import { useState } from "react";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import { ArrowRight, type LucideIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";

/**
 * Props for a single pain point item
 */
export interface PainPointItem {
  /** The problem being addressed */
  problem: {
    icon: LucideIcon;
    text: string;
    description: string;
  };
  /** The solution AssignX provides */
  solution: {
    icon: LucideIcon;
    text: string;
    description: string;
  };
}

interface PainPointCardProps {
  /** The pain point data to display */
  item: PainPointItem;
  /** Animation delay for stagger effect */
  index?: number;
}

/**
 * Individual pain point comparison card
 * Shows problem vs solution with animated transitions
 */
export function PainPointCard({ item, index = 0 }: PainPointCardProps) {
  const [isHovered, setIsHovered] = useState(false);
  const prefersReducedMotion = useReducedMotion();

  const ProblemIcon = item.problem.icon;
  const SolutionIcon = item.solution.icon;

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{
        duration: 0.6,
        delay: index * 0.1,
        ease: ASSIGNX_EASE,
      }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      className={cn(
        "group relative rounded-2xl overflow-hidden",
        "border border-[var(--landing-border)]",
        "bg-[var(--landing-bg-elevated)]",
        "transition-all duration-500 ease-out",
        "hover:border-[var(--landing-accent-light)]",
        "hover:shadow-xl hover:shadow-[var(--landing-accent-primary)]/5"
      )}
    >
      {/* Main card content */}
      <div className="relative p-6 sm:p-8">
        {/* Two-column layout */}
        <div className="flex items-stretch gap-4 sm:gap-6">
          {/* Problem Side - Left */}
          <div
            className={cn(
              "flex-1 relative rounded-xl p-4 sm:p-5",
              "bg-red-50/80 dark:bg-red-950/20",
              "border border-red-200/50 dark:border-red-800/30",
              "transition-all duration-300"
            )}
          >
            {/* Problem icon */}
            <div
              className={cn(
                "w-12 h-12 sm:w-14 sm:h-14 rounded-xl",
                "bg-red-100 dark:bg-red-900/30",
                "flex items-center justify-center mb-4",
                "transition-transform duration-300",
                "group-hover:scale-95"
              )}
            >
              <ProblemIcon className="w-6 h-6 sm:w-7 sm:h-7 text-red-500 dark:text-red-400" />
            </div>

            {/* Problem text */}
            <h4 className="font-semibold text-red-700 dark:text-red-300 mb-2 text-sm sm:text-base">
              {item.problem.text}
            </h4>

            {/* Problem description - shows on hover */}
            <AnimatePresence>
              {isHovered && !prefersReducedMotion && (
                <motion.p
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: "auto" }}
                  exit={{ opacity: 0, height: 0 }}
                  transition={{ duration: 0.3, ease: ASSIGNX_EASE }}
                  className="text-xs sm:text-sm text-red-600/70 dark:text-red-400/70 leading-relaxed"
                >
                  {item.problem.description}
                </motion.p>
              )}
            </AnimatePresence>

            {/* Static description for reduced motion */}
            {prefersReducedMotion && (
              <p className="text-xs sm:text-sm text-red-600/70 dark:text-red-400/70 leading-relaxed">
                {item.problem.description}
              </p>
            )}
          </div>

          {/* Arrow Transition - Center */}
          <div className="flex items-center justify-center px-2">
            <motion.div
              animate={
                prefersReducedMotion
                  ? {}
                  : {
                      x: isHovered ? [0, 8, 0] : 0,
                    }
              }
              transition={{
                duration: 1,
                repeat: isHovered ? Infinity : 0,
                ease: "easeInOut",
              }}
              className={cn(
                "w-10 h-10 sm:w-12 sm:h-12 rounded-full",
                "bg-gradient-to-r from-[var(--landing-accent-primary)] to-[var(--landing-accent-secondary)]",
                "flex items-center justify-center",
                "shadow-lg shadow-[var(--landing-accent-primary)]/20",
                "transition-all duration-300",
                "group-hover:scale-110 group-hover:shadow-xl"
              )}
            >
              <ArrowRight className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
            </motion.div>
          </div>

          {/* Solution Side - Right */}
          <div
            className={cn(
              "flex-1 relative rounded-xl p-4 sm:p-5",
              "bg-emerald-50/80 dark:bg-emerald-950/20",
              "border border-emerald-200/50 dark:border-emerald-800/30",
              "transition-all duration-300",
              "group-hover:bg-emerald-50 dark:group-hover:bg-emerald-950/30"
            )}
          >
            {/* Solution icon */}
            <div
              className={cn(
                "w-12 h-12 sm:w-14 sm:h-14 rounded-xl",
                "bg-emerald-100 dark:bg-emerald-900/30",
                "flex items-center justify-center mb-4",
                "transition-all duration-300",
                "group-hover:scale-105 group-hover:bg-[var(--landing-accent-primary)]"
              )}
            >
              <SolutionIcon
                className={cn(
                  "w-6 h-6 sm:w-7 sm:h-7",
                  "text-emerald-500 dark:text-emerald-400",
                  "transition-colors duration-300",
                  "group-hover:text-white"
                )}
              />
            </div>

            {/* Solution text */}
            <h4
              className={cn(
                "font-semibold mb-2 text-sm sm:text-base",
                "text-emerald-700 dark:text-emerald-300",
                "transition-colors duration-300",
                "group-hover:text-[var(--landing-accent-primary)]"
              )}
            >
              {item.solution.text}
            </h4>

            {/* Solution description - shows on hover */}
            <AnimatePresence>
              {isHovered && !prefersReducedMotion && (
                <motion.p
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: "auto" }}
                  exit={{ opacity: 0, height: 0 }}
                  transition={{ duration: 0.3, ease: ASSIGNX_EASE }}
                  className="text-xs sm:text-sm text-emerald-600/70 dark:text-emerald-400/70 leading-relaxed"
                >
                  {item.solution.description}
                </motion.p>
              )}
            </AnimatePresence>

            {/* Static description for reduced motion */}
            {prefersReducedMotion && (
              <p className="text-xs sm:text-sm text-emerald-600/70 dark:text-emerald-400/70 leading-relaxed">
                {item.solution.description}
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Hover glow effect */}
      <motion.div
        className="absolute inset-0 pointer-events-none"
        initial={{ opacity: 0 }}
        animate={{ opacity: isHovered ? 1 : 0 }}
        transition={{ duration: 0.3 }}
      >
        <div className="absolute inset-0 bg-gradient-to-r from-red-500/5 via-transparent to-emerald-500/5" />
      </motion.div>
    </motion.div>
  );
}
