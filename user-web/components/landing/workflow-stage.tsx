/**
 * @fileoverview WorkflowStage - Individual stage component for hero workflow animation
 *
 * Features:
 * - Icon with glow effect
 * - Label text with animation
 * - Animated entrance with stagger
 * - Active state indicator with pulse
 * - Subtle floating animation
 */

"use client";

import { motion, useReducedMotion, type Variants } from "framer-motion";
import { type LucideIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";

/**
 * Props for WorkflowStage component
 */
interface WorkflowStageProps {
  /** Unique identifier for the stage */
  id: string;
  /** Display label for the stage */
  label: string;
  /** Lucide icon component */
  icon: LucideIcon;
  /** Primary color for the stage (hex) */
  color: string;
  /** Animation delay in seconds */
  delay?: number;
  /** Whether this stage is currently active */
  isActive?: boolean;
  /** Index for stagger calculation */
  index?: number;
  /** Whether in horizontal or vertical layout */
  orientation?: "horizontal" | "vertical";
}

/**
 * Animation variants for the stage container
 */
const containerVariants: Variants = {
  hidden: {
    opacity: 0,
    y: 30,
    scale: 0.8,
  },
  visible: (delay: number) => ({
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      delay,
      duration: 0.6,
      ease: ASSIGNX_EASE,
    },
  }),
};

/**
 * Animation variants for the icon glow
 */
const glowVariants: Variants = {
  idle: {
    scale: 1,
    opacity: 0.4,
  },
  pulse: {
    scale: [1, 1.2, 1],
    opacity: [0.4, 0.7, 0.4],
    transition: {
      duration: 2,
      repeat: Infinity,
      ease: "easeInOut",
    },
  },
};

/**
 * Animation variants for floating effect
 */
const floatVariants: Variants = {
  float: {
    y: [0, -6, 0],
    transition: {
      duration: 3,
      repeat: Infinity,
      ease: "easeInOut",
    },
  },
};

/**
 * WorkflowStage - Individual stage in the workflow animation
 *
 * Displays an icon with glow effect, label, and animated entrance.
 * Used within HeroAnimation to show the 4-stage client workflow.
 *
 * @example
 * ```tsx
 * <WorkflowStage
 *   id="client"
 *   label="Submit Request"
 *   icon={User}
 *   color="#765341"
 *   delay={0.2}
 *   isActive={true}
 * />
 * ```
 */
export function WorkflowStage({
  id: _id,
  label,
  icon: Icon,
  color,
  delay = 0,
  isActive = false,
  index = 0,
  orientation = "horizontal",
}: WorkflowStageProps) {
  // _id is used for accessibility and future features
  void _id;
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      className={cn(
        "relative flex flex-col items-center gap-3",
        orientation === "vertical" && "flex-row gap-4"
      )}
      custom={delay}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, amount: 0.5 }}
      variants={containerVariants}
    >
      {/* Icon container with glow */}
      <motion.div
        className="relative"
        variants={prefersReducedMotion ? undefined : floatVariants}
        animate={prefersReducedMotion ? undefined : "float"}
        style={{ animationDelay: `${index * 0.5}s` }}
      >
        {/* Outer glow ring */}
        <motion.div
          className="absolute inset-0 rounded-full blur-xl"
          style={{ backgroundColor: color }}
          variants={glowVariants}
          animate={prefersReducedMotion ? "idle" : "pulse"}
        />

        {/* Secondary glow for depth */}
        <motion.div
          className="absolute -inset-2 rounded-full blur-md opacity-30"
          style={{ backgroundColor: color }}
          animate={
            prefersReducedMotion
              ? {}
              : {
                  scale: [1, 1.1, 1],
                  opacity: [0.3, 0.5, 0.3],
                }
          }
          transition={{
            duration: 2.5,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 0.3,
          }}
        />

        {/* Icon circle */}
        <div
          className={cn(
            "relative z-10 flex items-center justify-center",
            "w-16 h-16 sm:w-20 sm:h-20 rounded-full",
            "bg-white/90 dark:bg-[#1C1916]/90",
            "backdrop-blur-sm",
            "border-2 transition-all duration-300",
            "shadow-lg",
            isActive && "ring-2 ring-offset-2 ring-offset-white dark:ring-offset-[#14110F]"
          )}
          style={{
            borderColor: color,
            boxShadow: `0 4px 24px ${color}30`,
            ...(isActive && { ringColor: color }),
          }}
        >
          <Icon
            className="w-7 h-7 sm:w-8 sm:h-8 transition-transform duration-300"
            style={{ color }}
            strokeWidth={1.5}
          />
        </div>

        {/* Active indicator dot */}
        {isActive && (
          <motion.div
            className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-2 h-2 rounded-full"
            style={{ backgroundColor: color }}
            animate={{
              scale: [1, 1.3, 1],
              opacity: [1, 0.7, 1],
            }}
            transition={{
              duration: 1.5,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
        )}
      </motion.div>

      {/* Label */}
      <motion.span
        className={cn(
          "text-sm sm:text-base font-medium text-center",
          "text-[var(--landing-text-secondary)]",
          "max-w-[100px] sm:max-w-[120px] leading-tight",
          orientation === "vertical" && "text-left max-w-none"
        )}
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        transition={{ delay: delay + 0.2, duration: 0.4 }}
      >
        {label}
      </motion.span>

      {/* Step number indicator */}
      <motion.div
        className={cn(
          "absolute -top-2 -right-2 sm:-top-1 sm:-right-1",
          "w-5 h-5 sm:w-6 sm:h-6 rounded-full",
          "flex items-center justify-center",
          "text-[10px] sm:text-xs font-bold",
          "text-white",
          "shadow-md"
        )}
        style={{ backgroundColor: color }}
        initial={{ scale: 0, opacity: 0 }}
        whileInView={{ scale: 1, opacity: 1 }}
        viewport={{ once: true }}
        transition={{ delay: delay + 0.3, duration: 0.3, type: "spring" }}
      >
        {index + 1}
      </motion.div>
    </motion.div>
  );
}
