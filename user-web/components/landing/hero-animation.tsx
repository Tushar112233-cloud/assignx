/**
 * @fileoverview HeroAnimation - Animated workflow illustration for landing page
 *
 * Shows the 4-stage AssignX workflow:
 * 1. Client submits request
 * 2. Supervisor reviews
 * 3. Expert works on task
 * 4. Delivery to client
 *
 * Features:
 * - Framer Motion smooth animations
 * - Animated connecting lines with pulse effect (Gemini-style)
 * - Subtle floating animations on icons
 * - Staggered reveal on scroll
 * - Responsive: horizontal on desktop, vertical on mobile
 */

"use client";

import { useRef } from "react";
import {
  motion,
  useReducedMotion,
  useInView,
} from "framer-motion";
import { User, ShieldCheck, GraduationCap, CheckCircle } from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";
import { WorkflowStage } from "./workflow-stage";
import { AnimatedConnector } from "./animated-connector";

/**
 * Workflow stage configuration
 */
const stages = [
  {
    id: "client",
    label: "Submit Request",
    icon: User,
    color: "#765341", // Coffee Bean
  },
  {
    id: "supervisor",
    label: "Quality Review",
    icon: ShieldCheck,
    color: "#8D6A58", // Lighter Coffee
  },
  {
    id: "expert",
    label: "Expert Work",
    icon: GraduationCap,
    color: "#9D7B65", // Even Lighter Coffee
  },
  {
    id: "delivery",
    label: "Delivered",
    icon: CheckCircle,
    color: "#5F4334", // Darker Coffee
  },
] as const;

/**
 * Container animation variants
 */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      duration: 0.6,
      ease: ASSIGNX_EASE,
      staggerChildren: 0.15,
    },
  },
};

/**
 * Title animation variants
 */
const titleVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.6,
      ease: ASSIGNX_EASE,
    },
  },
};

/**
 * HeroAnimation - Main workflow animation component
 *
 * Displays a visual representation of the AssignX workflow with
 * animated stages and connecting lines. Responsive layout switches
 * from horizontal (desktop) to vertical (mobile).
 *
 * @example
 * ```tsx
 * <HeroAnimation className="mt-16" />
 * ```
 */
export function HeroAnimation({ className }: { className?: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <motion.div
      ref={ref}
      className={cn(
        "relative w-full max-w-4xl mx-auto",
        "py-8 sm:py-12 px-4",
        className
      )}
      initial="hidden"
      animate={isInView ? "visible" : "hidden"}
      variants={containerVariants}
    >
      {/* Section title */}
      <motion.div
        className="text-center mb-8 sm:mb-12"
        variants={titleVariants}
      >
        <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] text-sm font-medium text-[var(--landing-text-secondary)] mb-4">
          <span className="w-2 h-2 rounded-full bg-[var(--landing-accent-primary)] animate-pulse" />
          How It Works
        </span>
        <h3 className="landing-heading-md text-[var(--landing-text-primary)]">
          From request to delivery
        </h3>
        <p className="mt-2 text-[var(--landing-text-muted)] max-w-md mx-auto">
          A seamless process managed by our quality team
        </p>
      </motion.div>

      {/* Desktop Layout - Horizontal */}
      <div className="hidden sm:flex items-center justify-center gap-0">
        {stages.map((stage, index) => (
          <div key={stage.id} className="flex items-center">
            <WorkflowStage
              id={stage.id}
              label={stage.label}
              icon={stage.icon}
              color={stage.color}
              delay={0.2 + index * 0.15}
              isActive={index === 0}
              index={index}
              orientation="horizontal"
            />
            {index < stages.length - 1 && (
              <AnimatedConnector
                startColor={stage.color}
                endColor={stages[index + 1].color}
                delay={0.4 + index * 0.15}
                orientation="horizontal"
                id={`connector-h-${index}`}
                index={index}
              />
            )}
          </div>
        ))}
      </div>

      {/* Mobile Layout - Vertical */}
      <div className="flex sm:hidden flex-col items-center gap-0">
        {stages.map((stage, index) => (
          <div key={stage.id} className="flex flex-col items-center">
            <WorkflowStage
              id={stage.id}
              label={stage.label}
              icon={stage.icon}
              color={stage.color}
              delay={0.2 + index * 0.15}
              isActive={index === 0}
              index={index}
              orientation="horizontal"
            />
            {index < stages.length - 1 && (
              <AnimatedConnector
                startColor={stage.color}
                endColor={stages[index + 1].color}
                delay={0.4 + index * 0.15}
                orientation="vertical"
                id={`connector-v-${index}`}
                index={index}
              />
            )}
          </div>
        ))}
      </div>

      {/* Background decorative elements */}
      {!prefersReducedMotion && (
        <>
          {/* Subtle gradient orb */}
          <motion.div
            className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] rounded-full opacity-20 pointer-events-none -z-10"
            style={{
              background:
                "radial-gradient(circle, rgba(118,83,65,0.15) 0%, transparent 70%)",
            }}
            animate={{
              scale: [1, 1.1, 1],
              opacity: [0.2, 0.3, 0.2],
            }}
            transition={{
              duration: 4,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />

          {/* Animated particles in background */}
          {[...Array(6)].map((_, i) => (
            <motion.div
              key={i}
              className="absolute w-1 h-1 rounded-full bg-[var(--landing-accent-primary)] opacity-30 pointer-events-none"
              style={{
                left: `${20 + i * 12}%`,
                top: `${30 + (i % 3) * 20}%`,
              }}
              animate={{
                y: [0, -20, 0],
                opacity: [0.3, 0.6, 0.3],
              }}
              transition={{
                duration: 3 + i * 0.5,
                repeat: Infinity,
                ease: "easeInOut",
                delay: i * 0.3,
              }}
            />
          ))}
        </>
      )}

      {/* Progress indicator line (subtle) */}
      <motion.div
        className="absolute bottom-0 left-1/2 -translate-x-1/2 h-0.5 bg-gradient-to-r from-transparent via-[var(--landing-accent-primary)] to-transparent opacity-20"
        initial={{ width: 0 }}
        animate={isInView ? { width: "80%" } : { width: 0 }}
        transition={{ delay: 1, duration: 1.5, ease: ASSIGNX_EASE }}
      />
    </motion.div>
  );
}

export default HeroAnimation;
