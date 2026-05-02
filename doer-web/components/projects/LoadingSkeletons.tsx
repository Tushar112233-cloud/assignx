/**
 * Loading skeleton components for projects page
 * Shimmer effect skeletons for smooth loading states
 * @module components/projects/LoadingSkeletons
 */

'use client'

import { motion, type Variants } from 'framer-motion'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'

/**
 * Shimmer animation variant
 */
const shimmer: Variants = {
  initial: { x: '-100%' },
  animate: {
    x: '100%',
    transition: {
      duration: 2,
      ease: 'linear' as const,
      repeat: Infinity,
    },
  },
}

/**
 * Stagger container for skeleton items
 */
const staggerContainer: Variants = {
  animate: {
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const itemVariant: Variants = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
}

/**
 * Stats card skeleton with shimmer effect
 */
export function StatCardSkeleton() {
  return (
    <motion.div
      initial="initial"
      animate="animate"
      variants={itemVariant}
      className="relative overflow-hidden rounded-2xl"
    >
      <Card className="border border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
        <CardContent className="flex items-center gap-4 p-5">
          <Skeleton className="h-12 w-12 rounded-2xl" />
          <div className="flex-1 space-y-2">
            <Skeleton className="h-3 w-20" />
            <Skeleton className="h-7 w-16" />
            <Skeleton className="h-3 w-24" />
          </div>
        </CardContent>
      </Card>
      {/* Shimmer overlay */}
      <motion.div
        variants={shimmer}
        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/40 to-transparent"
      />
    </motion.div>
  )
}

/**
 * Project card skeleton with shimmer
 */
export function ProjectCardSkeleton() {
  return (
    <motion.div
      initial="initial"
      animate="animate"
      variants={itemVariant}
      className="relative overflow-hidden rounded-2xl"
    >
      <div className="space-y-3 rounded-2xl border border-border/70 bg-background/80 p-4">
        <div className="flex items-start justify-between gap-3">
          <div className="flex-1 space-y-2">
            <div className="flex items-center gap-2">
              <Skeleton className="h-2.5 w-2.5 rounded-full" />
              <Skeleton className="h-5 w-48" />
            </div>
            <Skeleton className="h-4 w-32" />
          </div>
          <div className="space-y-1 text-right">
            <Skeleton className="h-3 w-12" />
            <Skeleton className="h-6 w-20" />
          </div>
        </div>
        <div className="flex items-center justify-between gap-3">
          <Skeleton className="h-4 w-28" />
          <Skeleton className="h-9 w-24 rounded-full" />
        </div>
        <Skeleton className="h-2 w-full rounded-full" />
      </div>
      {/* Shimmer overlay */}
      <motion.div
        variants={shimmer}
        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 to-transparent"
      />
    </motion.div>
  )
}

/**
 * Hero card skeleton
 */
export function HeroCardSkeleton() {
  return (
    <motion.div
      initial="initial"
      animate="animate"
      variants={itemVariant}
      className="relative overflow-hidden rounded-[28px]"
    >
      <Card className="border border-white/70 bg-gradient-to-br from-[#E6F5F3] via-[#EBF7F5] to-[#E9FAFA] shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
        <CardContent className="space-y-5 p-6">
          <div className="space-y-3">
            <Skeleton className="h-4 w-24" />
            <Skeleton className="h-8 w-full max-w-md" />
            <Skeleton className="h-4 w-full max-w-lg" />
          </div>
          <div className="grid gap-3 sm:grid-cols-3">
            <Skeleton className="h-20 rounded-2xl" />
            <Skeleton className="h-20 rounded-2xl" />
            <Skeleton className="h-20 rounded-2xl" />
          </div>
        </CardContent>
      </Card>
      {/* Shimmer overlay */}
      <motion.div
        variants={shimmer}
        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
      />
    </motion.div>
  )
}

/**
 * Page loading skeleton with all components
 */
export function ProjectsPageSkeleton() {
  return (
    <motion.div
      variants={staggerContainer}
      initial="initial"
      animate="animate"
      className="space-y-8"
    >
      {/* Header section */}
      <motion.div variants={itemVariant} className="space-y-4">
        <div className="flex items-start justify-between gap-4">
          <div className="space-y-2">
            <Skeleton className="h-10 w-48" />
            <Skeleton className="h-4 w-64" />
          </div>
          <Skeleton className="h-10 w-28 rounded-full" />
        </div>
        <div className="flex items-center gap-3">
          <Skeleton className="h-11 w-full max-w-md rounded-full" />
          <Skeleton className="h-8 w-20 rounded-full" />
          <Skeleton className="h-8 w-20 rounded-full" />
          <Skeleton className="h-8 w-24 rounded-full" />
        </div>
      </motion.div>

      {/* Hero and stats grid */}
      <div className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
        <motion.div variants={itemVariant} className="space-y-5">
          <div className="grid gap-4 sm:grid-cols-3">
            <Skeleton className="h-24 rounded-3xl" />
            <Skeleton className="h-24 rounded-3xl" />
            <Skeleton className="h-24 rounded-3xl" />
          </div>
        </motion.div>
        <motion.div variants={itemVariant}>
          <HeroCardSkeleton />
        </motion.div>
      </div>

      {/* Stats cards grid */}
      <motion.div
        variants={staggerContainer}
        className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4"
      >
        {[1, 2, 3, 4].map((i) => (
          <StatCardSkeleton key={i} />
        ))}
      </motion.div>

      {/* Main content area */}
      <div className="grid gap-6 xl:grid-cols-[1.4fr_0.6fr]">
        <div className="space-y-6">
          {/* Active projects skeleton */}
          <motion.div variants={itemVariant} className="relative overflow-hidden rounded-[28px]">
            <Card className="border border-white/70 bg-white/85 shadow-[0_18px_40px_rgba(30,58,138,0.08)]">
              <CardHeader className="space-y-2">
                <Skeleton className="h-6 w-32" />
                <Skeleton className="h-4 w-48" />
              </CardHeader>
              <CardContent className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <ProjectCardSkeleton key={i} />
                ))}
              </CardContent>
            </Card>
            <motion.div
              variants={shimmer}
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent pointer-events-none"
            />
          </motion.div>
        </div>

        {/* Sidebar skeleton */}
        <div className="space-y-6">
          <motion.div variants={itemVariant}>
            <Card className="border border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
              <CardContent className="space-y-4 p-5">
                <Skeleton className="h-6 w-32" />
                <div className="space-y-3">
                  <Skeleton className="h-16 rounded-2xl" />
                  <Skeleton className="h-16 rounded-2xl" />
                  <Skeleton className="h-16 rounded-2xl" />
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>
    </motion.div>
  )
}

/**
 * Inline shimmer skeleton for small elements
 */
export function InlineShimmer({ className }: { className?: string }) {
  return (
    <div className={cn('relative overflow-hidden rounded bg-[hsl(var(--skeleton-base))]', className)}>
      <motion.div
        animate={{
          x: ['-100%', '100%'],
        }}
        transition={{
          duration: 2,
          ease: 'linear' as const,
          repeat: Infinity,
        }}
        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/60 to-transparent"
      />
    </div>
  )
}

/**
 * Pulsing skeleton with different animation
 */
export function PulsingSkeleton({ className }: { className?: string }) {
  return (
    <motion.div
      animate={{
        opacity: [0.5, 1, 0.5],
      }}
      transition={{
        duration: 1.5,
        ease: 'easeInOut' as const,
        repeat: Infinity,
      }}
      className={cn('rounded bg-[hsl(var(--skeleton-base))]', className)}
    />
  )
}

/**
 * Progress bar skeleton with animated fill
 */
export function ProgressBarSkeleton() {
  return (
    <div className="h-2 overflow-hidden rounded-full bg-[hsl(var(--skeleton-base))]">
      <motion.div
        animate={{
          x: ['-100%', '100%'],
        }}
        transition={{
          duration: 1.5,
          ease: 'easeInOut' as const,
          repeat: Infinity,
        }}
        className="h-full w-1/2 bg-gradient-to-r from-teal-200/50 via-teal-300/50 to-teal-200/50"
      />
    </div>
  )
}
