'use client'

import { motion } from 'framer-motion'
import { TrendingUp, TrendingDown, Star, Zap, IndianRupee } from 'lucide-react'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'

/**
 * Props interface for PerformanceHeroBanner component
 */
interface PerformanceHeroBannerProps {
  /** Total earnings amount in INR */
  totalEarnings: number
  /** Earnings trend percentage (positive = growth, negative = decline) */
  earningsTrend: number
  /** Average rating out of 5 */
  averageRating: number
  /** Rating trend percentage */
  ratingTrend: number
  /** Projects completed per week */
  projectVelocity: number
  /** Velocity trend percentage */
  velocityTrend: number
  /** Currently selected time period */
  selectedPeriod: 'week' | 'month' | 'year' | 'all'
  /** Callback when period selection changes */
  onPeriodChange: (period: 'week' | 'month' | 'year' | 'all') => void
}

/**
 * Props for individual metric cards
 */
interface MetricCardProps {
  /** Card title */
  title: string
  /** Main value to display */
  value: React.ReactNode
  /** Icon component */
  icon: React.ElementType
  /** Icon background color class */
  iconBg: string
  /** Icon text color class */
  iconColor: string
  /** Trend percentage (positive or negative) */
  trend?: number
  /** Whether trend should be considered positive when increasing */
  trendPositive?: boolean
}

/**
 * Animation variants for staggered entrance
 */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: [0.4, 0, 0.2, 1] as [number, number, number, number],
    },
  },
}

/**
 * Format number as Indian currency
 */
function formatCurrency(amount: number): string {
  return `₹${amount.toLocaleString('en-IN')}`
}

/**
 * Format rating with one decimal place
 */
function formatRating(rating: number): string {
  return rating.toFixed(1)
}

/**
 * Individual metric card component with trend indicator
 */
function MetricCard({
  title,
  value,
  icon: Icon,
  iconBg,
  iconColor,
  trend,
  trendPositive = true,
}: MetricCardProps) {
  const showTrend = trend !== undefined
  const isPositiveTrend = trendPositive ? trend! > 0 : trend! < 0
  const trendValue = Math.abs(trend || 0)

  return (
    <motion.div
      variants={itemVariants}
      className="group relative overflow-hidden rounded-2xl bg-white/85 p-5 shadow-[0_12px_30px_rgba(30,58,138,0.1)] backdrop-blur transition-all hover:-translate-y-0.5 hover:shadow-[0_16px_40px_rgba(30,58,138,0.15)]"
    >
      <div className="flex items-start justify-between">
        <div className="flex-1 space-y-3">
          <div className="flex items-center gap-2">
            <div className={cn('flex h-10 w-10 items-center justify-center rounded-xl', iconBg)}>
              <Icon className={cn('h-5 w-5', iconColor)} />
            </div>
            {showTrend && (
              <Badge
                variant="secondary"
                className={cn(
                  'gap-1 border-0',
                  isPositiveTrend
                    ? 'bg-emerald-50 text-emerald-600'
                    : 'bg-rose-50 text-rose-600'
                )}
              >
                {isPositiveTrend ? (
                  <TrendingUp className="h-3 w-3" />
                ) : (
                  <TrendingDown className="h-3 w-3" />
                )}
                {trendValue}%
              </Badge>
            )}
          </div>
          <div>
            <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
              {title}
            </p>
            <div className="mt-1 text-2xl font-semibold text-slate-900">{value}</div>
          </div>
        </div>
      </div>
    </motion.div>
  )
}

/**
 * Performance Hero Banner Component
 *
 * Displays key performance metrics in an elegant hero banner with:
 * - Gradient background with radial overlay for depth
 * - Period selector dropdown for time range filtering
 * - Three metric cards showing earnings, rating, and velocity
 * - Animated entrance with stagger effect
 * - Trend indicators for each metric
 *
 * @example
 * ```tsx
 * <PerformanceHeroBanner
 *   totalEarnings={45000}
 *   earningsTrend={12.5}
 *   averageRating={4.8}
 *   ratingTrend={2.1}
 *   projectVelocity={8}
 *   velocityTrend={15.0}
 *   selectedPeriod="month"
 *   onPeriodChange={(period) => console.log(period)}
 * />
 * ```
 */
export function PerformanceHeroBanner({
  totalEarnings,
  earningsTrend,
  averageRating,
  ratingTrend,
  projectVelocity,
  velocityTrend,
  selectedPeriod,
  onPeriodChange,
}: PerformanceHeroBannerProps) {
  return (
    <div className="relative overflow-hidden rounded-[32px] bg-gradient-to-br from-[#F7F9FF] via-[#F2F6FF] to-[#EEF2FF] p-8">
      {/* Radial gradient overlay for depth */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(99,102,241,0.18),transparent_55%)]" />

      {/* Content */}
      <div className="relative space-y-6">
        {/* Header with title and period selector */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="space-y-1">
            <h1 className="text-3xl font-semibold tracking-tight text-slate-900">
              Performance Analytics
            </h1>
            <p className="text-sm text-slate-500">
              Track your earnings, ratings, and project velocity
            </p>
          </div>

          {/* Period Selector */}
          <Select value={selectedPeriod} onValueChange={onPeriodChange}>
            <SelectTrigger className="w-[180px] h-11 rounded-full border-white/80 bg-white/85 shadow-[0_10px_22px_rgba(30,58,138,0.1)] hover:border-[#5A7CFF] focus:ring-[#E7ECFF]">
              <SelectValue placeholder="Select period" />
            </SelectTrigger>
            <SelectContent className="rounded-2xl">
              <SelectItem value="week" className="rounded-xl">
                This Week
              </SelectItem>
              <SelectItem value="month" className="rounded-xl">
                This Month
              </SelectItem>
              <SelectItem value="year" className="rounded-xl">
                This Year
              </SelectItem>
              <SelectItem value="all" className="rounded-xl">
                All Time
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Metrics Grid - 3 columns on desktop */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
          className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3"
        >
          {/* Total Earnings Card */}
          <MetricCard
            title="Total Earnings"
            value={formatCurrency(totalEarnings)}
            icon={IndianRupee}
            iconBg="bg-[#E6F4FF]"
            iconColor="text-[#4B9BFF]"
            trend={earningsTrend}
            trendPositive={true}
          />

          {/* Average Rating Card */}
          <MetricCard
            title="Average Rating"
            value={
              <span className="flex items-center gap-1.5">
                <span>{formatRating(averageRating)}</span>
                <Star className="h-5 w-5 fill-amber-400 text-amber-400" />
              </span>
            }
            icon={Star}
            iconBg="bg-[#FFF4E6]"
            iconColor="text-[#FFB547]"
            trend={ratingTrend}
            trendPositive={true}
          />

          {/* Project Velocity Card */}
          <MetricCard
            title="Project Velocity"
            value={
              <div className="flex items-baseline gap-1.5">
                <span>{projectVelocity}</span>
                <span className="text-sm font-medium text-slate-500">/ week</span>
              </div>
            }
            icon={Zap}
            iconBg="bg-[#ECE9FF]"
            iconColor="text-[#6B5BFF]"
            trend={velocityTrend}
            trendPositive={true}
          />
        </motion.div>
      </div>
    </div>
  )
}
