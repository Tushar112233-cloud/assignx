'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import type { Variants } from 'framer-motion'
import {
  Layers,
  TrendingUp,
  Clock,
  IndianRupee,
  Target,
  CheckCircle2,
  ArrowUp,
  ArrowDown,
  LucideIcon,
} from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { cn } from '@/lib/utils'

/**
 * Metric configuration interface
 */
export interface MetricConfig {
  /** Metric label (uppercase with tracking-wide) */
  label: string
  /** Numeric value to display and animate */
  value: number
  /** Subtitle/description text */
  subtitle: string
  /** Lucide icon component */
  icon: LucideIcon
  /** Trend indicator data */
  trend: {
    /** Trend percentage value */
    value: number
    /** Direction indicator */
    direction: 'up' | 'down'
  }
  /** Optional color theme override */
  color?: string
  /** Optional background color override */
  bgColor?: string
  /** Optional accent gradient override */
  accent?: string
}

/**
 * MetricsDashboard component props
 */
interface MetricsDashboardProps {
  /** Array of metrics to display */
  metrics: MetricConfig[]
  /** Loading state */
  isLoading?: boolean
  /** Additional class name */
  className?: string
}

/**
 * Default color configurations for icons
 */
const defaultColors: Record<string, { icon: string; bg: string; accent: string }> = {
  layers: {
    icon: 'text-purple-600 dark:text-purple-400',
    bg: 'bg-purple-500/10 dark:bg-purple-500/20',
    accent: 'from-purple-500/60 to-violet-500/20',
  },
  trending: {
    icon: 'text-emerald-600 dark:text-emerald-400',
    bg: 'bg-emerald-500/10 dark:bg-emerald-500/20',
    accent: 'from-emerald-500/60 to-teal-500/20',
  },
  clock: {
    icon: 'text-cyan-600 dark:text-cyan-400',
    bg: 'bg-cyan-500/10 dark:bg-cyan-500/20',
    accent: 'from-cyan-500/60 to-blue-500/20',
  },
  rupee: {
    icon: 'text-teal-600 dark:text-teal-400',
    bg: 'bg-teal-500/10 dark:bg-teal-500/20',
    accent: 'from-teal-500/60 to-emerald-500/20',
  },
  target: {
    icon: 'text-blue-600 dark:text-blue-400',
    bg: 'bg-blue-500/10 dark:bg-blue-500/20',
    accent: 'from-blue-500/60 to-cyan-500/20',
  },
  check: {
    icon: 'text-green-600 dark:text-green-400',
    bg: 'bg-green-500/10 dark:bg-green-500/20',
    accent: 'from-green-500/60 to-lime-500/20',
  },
}

/**
 * Get color configuration based on icon type
 */
function getColorConfig(icon: LucideIcon): { icon: string; bg: string; accent: string } {
  const iconName = icon.displayName || icon.name || ''
  const lowerName = iconName.toLowerCase()

  if (lowerName.includes('layer')) return defaultColors.layers
  if (lowerName.includes('trend')) return defaultColors.trending
  if (lowerName.includes('clock')) return defaultColors.clock
  if (lowerName.includes('rupee') || lowerName.includes('indian')) return defaultColors.rupee
  if (lowerName.includes('target')) return defaultColors.target
  if (lowerName.includes('check') || lowerName.includes('circle')) return defaultColors.check

  // Default fallback
  return defaultColors.layers
}

/**
 * Animation variants for container
 */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.12,
      delayChildren: 0.1,
    },
  },
}

/**
 * Animation variants for individual metric cards
 */
const cardVariants = {
  hidden: {
    opacity: 0,
    y: 30,
    scale: 0.95,
  },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      type: 'spring' as const,
      stiffness: 120,
      damping: 20,
      mass: 0.8,
    },
  },
}

/**
 * Animated counter hook
 * Animates number from 0 to target value
 */
function useAnimatedCounter(target: number, duration: number = 1500) {
  const [count, setCount] = useState(0)

  useEffect(() => {
    let startTime: number | null = null
    let animationFrame: number

    const animate = (timestamp: number) => {
      if (!startTime) startTime = timestamp
      const progress = Math.min((timestamp - startTime) / duration, 1)

      // Easing function (ease-out cubic)
      const easeOut = 1 - Math.pow(1 - progress, 3)
      setCount(Math.floor(target * easeOut))

      if (progress < 1) {
        animationFrame = requestAnimationFrame(animate)
      } else {
        setCount(target)
      }
    }

    animationFrame = requestAnimationFrame(animate)

    return () => {
      if (animationFrame) {
        cancelAnimationFrame(animationFrame)
      }
    }
  }, [target, duration])

  return count
}

/**
 * Individual Metric Card Component
 */
interface MetricCardProps {
  metric: MetricConfig
  index: number
}

function MetricCard({ metric, index }: MetricCardProps) {
  const colorConfig = getColorConfig(metric.icon)
  const Icon = metric.icon
  const animatedValue = useAnimatedCounter(metric.value, 1500 + index * 100)

  const iconColor = metric.color || colorConfig.icon
  const bgColor = metric.bgColor || colorConfig.bg
  const accentGradient = metric.accent || colorConfig.accent

  const TrendIcon = metric.trend.direction === 'up' ? ArrowUp : ArrowDown
  const trendColor = metric.trend.direction === 'up'
    ? 'text-emerald-600 dark:text-emerald-400'
    : 'text-red-600 dark:text-red-400'
  const trendBg = metric.trend.direction === 'up'
    ? 'bg-emerald-50 dark:bg-emerald-950/30'
    : 'bg-red-50 dark:bg-red-950/30'

  return (
    <motion.div
      variants={cardVariants}
      whileHover={{
        y: -4,
        transition: { type: 'spring' as const, stiffness: 300, damping: 25 }
      }}
      className="h-full"
    >
      <Card className="relative h-full overflow-hidden border-muted/60 bg-gradient-to-br from-background/95 via-background to-background/90 backdrop-blur-sm transition-all duration-300 hover:shadow-xl hover:border-primary/30">
        {/* Top accent gradient bar */}
        <div className={cn('absolute inset-x-0 top-0 h-1 bg-gradient-to-r', accentGradient)} />

        {/* Subtle background pattern */}
        <div className="absolute inset-0 bg-grid-slate-100/[0.04] dark:bg-grid-slate-800/[0.04] pointer-events-none" />

        <CardContent className="relative p-6 flex flex-col h-full">
          {/* Icon in colored circle */}
          <motion.div
            initial={{ scale: 0, rotate: -180 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{
              type: 'spring' as const,
              stiffness: 200,
              damping: 15,
              delay: 0.2 + index * 0.1,
            }}
            className={cn(
              'w-12 h-12 rounded-2xl flex items-center justify-center mb-4 ring-1 ring-black/5 dark:ring-white/5',
              bgColor
            )}
          >
            <Icon className={cn('h-6 w-6', iconColor)} />
          </motion.div>

          {/* Metric label */}
          <p className="text-[10px] uppercase tracking-[0.15em] font-semibold text-muted-foreground/80 mb-2 line-clamp-1">
            {metric.label}
          </p>

          {/* Animated counter value */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 + index * 0.1 }}
            className="mb-3"
          >
            <p className={cn('text-3xl font-bold tracking-tight', iconColor)}>
              {animatedValue.toLocaleString()}
            </p>
          </motion.div>

          {/* Subtitle/description */}
          <p className="text-sm text-muted-foreground mb-4 flex-1 line-clamp-2">
            {metric.subtitle}
          </p>

          {/* Trend indicator */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.6 + index * 0.1 }}
            className={cn(
              'flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg w-fit',
              trendBg
            )}
          >
            <TrendIcon className={cn('h-3.5 w-3.5', trendColor)} />
            <span className={cn('text-xs font-semibold', trendColor)}>
              {Math.abs(metric.trend.value)}%
            </span>
          </motion.div>
        </CardContent>
      </Card>
    </motion.div>
  )
}

/**
 * MetricsDashboard Component
 *
 * Premium animated dashboard displaying key metrics in a grid layout.
 * Features:
 * - Staggered entrance animations
 * - Number counting animation
 * - Trend indicators with up/down arrows
 * - Gradient backgrounds matching dashboard style
 * - Responsive grid layout (2 cols mobile, 3 cols tablet, 4-6 cols desktop)
 *
 * @example
 * ```tsx
 * const metrics = [
 *   {
 *     label: 'Total Projects',
 *     value: 42,
 *     subtitle: 'Active assignments',
 *     icon: Layers,
 *     trend: { value: 12, direction: 'up' }
 *   },
 *   // ... more metrics
 * ]
 *
 * <MetricsDashboard metrics={metrics} />
 * ```
 */
export function MetricsDashboard({ metrics, isLoading, className }: MetricsDashboardProps) {
  // Loading skeleton
  if (isLoading) {
    return (
      <div className={cn(
        'grid gap-4 sm:gap-5 grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6',
        className
      )}>
        {[...Array(6)].map((_, i) => (
          <Card key={i} className="animate-pulse overflow-hidden">
            <CardContent className="p-6">
              <div className="h-1 w-full bg-muted/50 mb-4" />
              <div className="h-12 w-12 rounded-2xl bg-muted/50 mb-4" />
              <div className="h-3 w-20 bg-muted/50 rounded mb-3" />
              <div className="h-8 w-24 bg-muted/50 rounded mb-3" />
              <div className="h-4 w-full bg-muted/50 rounded mb-4" />
              <div className="h-6 w-16 bg-muted/50 rounded" />
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  // Empty state
  if (!metrics || metrics.length === 0) {
    return (
      <div className={cn('flex items-center justify-center p-12 border border-dashed rounded-xl', className)}>
        <p className="text-muted-foreground">No metrics to display</p>
      </div>
    )
  }

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className={cn(
        'grid gap-4 sm:gap-5 grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6',
        className
      )}
    >
      {metrics.map((metric, index) => (
        <MetricCard key={metric.label} metric={metric} index={index} />
      ))}
    </motion.div>
  )
}

/**
 * Example metrics for reference/testing
 */
export const exampleMetrics: MetricConfig[] = [
  {
    label: 'Total Projects',
    value: 48,
    subtitle: 'All-time assignments',
    icon: Layers,
    trend: { value: 12, direction: 'up' },
  },
  {
    label: 'Revenue Growth',
    value: 34,
    subtitle: 'Monthly increase',
    icon: TrendingUp,
    trend: { value: 8, direction: 'up' },
  },
  {
    label: 'Avg Completion',
    value: 72,
    subtitle: 'Hours per project',
    icon: Clock,
    trend: { value: 5, direction: 'down' },
  },
  {
    label: 'Total Earnings',
    value: 45600,
    subtitle: 'This quarter',
    icon: IndianRupee,
    trend: { value: 15, direction: 'up' },
  },
  {
    label: 'Success Rate',
    value: 96,
    subtitle: 'Project completion',
    icon: Target,
    trend: { value: 3, direction: 'up' },
  },
  {
    label: 'Completed',
    value: 42,
    subtitle: 'Delivered on time',
    icon: CheckCircle2,
    trend: { value: 10, direction: 'up' },
  },
]
