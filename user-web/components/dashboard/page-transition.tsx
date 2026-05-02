"use client"

/**
 * PageTransition - Animated page wrapper for smooth route transitions
 * Provides consistent entry/exit animations across the app
 */

import * as React from "react"
import { motion, AnimatePresence, type Variants } from "framer-motion"
import { usePathname } from "next/navigation"

import { cn } from "@/lib/utils"
import { pageTransition, fadeIn, springs } from "@/lib/animations/variants"

interface PageTransitionProps {
  children: React.ReactNode
  className?: string
  /** Animation variant */
  variant?: "fade" | "slide" | "scale" | "none"
}

const scaleVariant: Variants = {
  hidden: { opacity: 0, scale: 0.98 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: { duration: 0.25, ease: [0.25, 0.1, 0.25, 1] as const },
  },
  exit: { opacity: 0, scale: 0.98, transition: { duration: 0.15 } },
}

const noneVariant: Variants = {
  hidden: {},
  visible: {},
  exit: {},
}

const variants: Record<string, Variants> = {
  fade: fadeIn,
  slide: pageTransition,
  scale: scaleVariant,
  none: noneVariant,
}

export function PageTransition({
  children,
  className,
  variant = "slide",
}: PageTransitionProps) {
  const pathname = usePathname()

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={pathname}
        variants={variants[variant]}
        initial="hidden"
        animate="visible"
        exit="exit"
        className={cn("min-h-full", className)}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  )
}

/**
 * Simple fade wrapper for sections
 */
export function FadeInSection({
  children,
  className,
  delay = 0,
}: {
  children: React.ReactNode
  className?: string
  delay?: number
}) {
  return (
    <motion.section
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{
        duration: 0.3,
        delay,
        ease: [0.25, 0.1, 0.25, 1],
      }}
      className={className}
    >
      {children}
    </motion.section>
  )
}

/**
 * Stagger children wrapper
 */
export function StaggerChildren({
  children,
  className,
  staggerDelay = 0.05,
}: {
  children: React.ReactNode
  className?: string
  staggerDelay?: number
}) {
  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={{
        hidden: { opacity: 0 },
        visible: {
          opacity: 1,
          transition: {
            staggerChildren: staggerDelay,
            delayChildren: 0.1,
          },
        },
      }}
      className={className}
    >
      {React.Children.map(children, (child, index) => (
        <motion.div
          key={index}
          variants={{
            hidden: { opacity: 0, y: 20 },
            visible: {
              opacity: 1,
              y: 0,
              transition: springs.gentle,
            },
          }}
        >
          {child}
        </motion.div>
      ))}
    </motion.div>
  )
}

/**
 * Scroll-triggered animation wrapper
 */
export function ScrollReveal({
  children,
  className,
  threshold = 0.1,
}: {
  children: React.ReactNode
  className?: string
  threshold?: number
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, amount: threshold }}
      transition={{ duration: 0.5, ease: [0.25, 0.1, 0.25, 1] }}
      className={className}
    >
      {children}
    </motion.div>
  )
}
