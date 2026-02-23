'use client'

/**
 * RatingAnalyticsDashboard Component
 * Two-section analytics dashboard showing rating distribution and category performance.
 * Features responsive layout with progress bars and category cards.
 * @module components/reviews/RatingAnalyticsDashboard
 */

import { motion } from 'framer-motion'
import { Target, Clock, MessageSquare, Star } from 'lucide-react'
import { Progress } from '@/components/ui/progress'
import { CategoryRatingCard } from './CategoryRatingCard'
import { cn } from '@/lib/utils'

/**
 * Rating distribution data structure
 */
export interface RatingDistributionItem {
  /** Star rating (1-5) */
  stars: number
  /** Number of reviews with this rating */
  count: number
}

/**
 * Category averages data structure
 */
export interface CategoryAverages {
  /** Quality rating average */
  quality: number
  /** Timeliness rating average */
  timeliness: number
  /** Communication rating average */
  communication: number
}

/**
 * RatingAnalyticsDashboard component props
 */
export interface RatingAnalyticsDashboardProps {
  /** Rating distribution data (5 to 1 stars) */
  ratingDistribution: RatingDistributionItem[]
  /** Category average ratings */
  categoryAverages: CategoryAverages
  /** Optional additional class name */
  className?: string
}

/**
 * Get progress bar color based on star rating
 * @param stars - Star rating (1-5)
 * @returns Tailwind color class
 */
const getProgressColor = (stars: number): string => {
  const colorMap: Record<number, string> = {
    5: 'bg-gradient-to-r from-green-500 to-green-600',
    4: 'bg-gradient-to-r from-blue-500 to-blue-600',
    3: 'bg-gradient-to-r from-yellow-500 to-yellow-600',
    2: 'bg-gradient-to-r from-orange-500 to-orange-600',
    1: 'bg-gradient-to-r from-red-500 to-red-600',
  }
  return colorMap[stars] || 'bg-gradient-to-r from-slate-400 to-slate-500'
}

/** Animation variants for container */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
}

/** Animation variants for child items */
const itemVariants = {
  hidden: { opacity: 0, x: -20 },
  visible: { opacity: 1, x: 0 },
}

/**
 * RatingAnalyticsDashboard Component
 *
 * A comprehensive analytics dashboard with two main sections:
 *
 * **Section 1 (35% width):** Rating Distribution
 * - Shows breakdown from 5 to 1 stars
 * - Progress bars with color gradients
 * - Count badges on the right
 *
 * **Section 2 (65% width):** Category Performance
 * - Three category rating cards (Quality, Timeliness, Communication)
 * - Color-coded icons and ratings
 * - Responsive grid layout
 *
 * Responsive: Stacks vertically on mobile devices
 *
 * @example
 * ```tsx
 * <RatingAnalyticsDashboard
 *   ratingDistribution={[
 *     { stars: 5, count: 28 },
 *     { stars: 4, count: 12 },
 *     { stars: 3, count: 3 },
 *     { stars: 2, count: 1 },
 *     { stars: 1, count: 1 },
 *   ]}
 *   categoryAverages={{
 *     quality: 4.8,
 *     timeliness: 4.6,
 *     communication: 4.7,
 *   }}
 * />
 * ```
 */
export function RatingAnalyticsDashboard({
  ratingDistribution,
  categoryAverages,
  className,
}: RatingAnalyticsDashboardProps) {
  // Calculate total reviews for percentage
  const totalReviews = ratingDistribution.reduce((sum, item) => sum + item.count, 0)

  return (
    <div
      className={cn(
        'rounded-2xl bg-white/85 border border-white/70',
        'shadow-[0_16px_35px_rgba(30,58,138,0.08)] p-6',
        'flex flex-col lg:flex-row gap-6',
        className
      )}
    >
      {/* Section 1: Rating Distribution (35% width on desktop) */}
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="flex-shrink-0 lg:w-[35%] space-y-4"
      >
        {/* Section Header */}
        <div className="mb-4">
          <h3 className="text-lg font-bold text-slate-900 mb-1">Rating Distribution</h3>
          <p className="text-xs text-slate-500">Breakdown of all ratings received</p>
        </div>

        {/* Rating Breakdown */}
        <div className="space-y-3">
          {ratingDistribution.map((item) => {
            const percentage = totalReviews > 0 ? (item.count / totalReviews) * 100 : 0

            return (
              <motion.div
                key={item.stars}
                variants={itemVariants}
                className="flex items-center gap-3"
              >
                {/* Star Label */}
                <div className="flex items-center gap-1 w-14 flex-shrink-0">
                  <span className="text-sm font-semibold text-slate-700">{item.stars}</span>
                  <Star className="h-4 w-4 fill-current text-amber-400" />
                </div>

                {/* Progress Bar */}
                <div className="flex-1">
                  <Progress
                    value={percentage}
                    className="h-2.5 bg-slate-100"
                    indicatorClassName={getProgressColor(item.stars)}
                  />
                </div>

                {/* Count Badge */}
                <div
                  className={cn(
                    'flex items-center justify-center min-w-[2.5rem] h-7',
                    'rounded-lg px-2.5',
                    'bg-slate-50 border border-slate-200'
                  )}
                >
                  <span className="text-xs font-semibold text-slate-700">{item.count}</span>
                </div>
              </motion.div>
            )
          })}
        </div>

        {/* Total Reviews Summary */}
        <div className="mt-4 pt-4 border-t border-slate-200">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-slate-600">Total Reviews</span>
            <span className="text-lg font-bold text-slate-900">{totalReviews}</span>
          </div>
        </div>
      </motion.div>

      {/* Section 2: Category Performance (65% width on desktop) */}
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="flex-1 space-y-4"
      >
        {/* Section Header */}
        <div className="mb-4">
          <h3 className="text-lg font-bold text-slate-900 mb-1">Category Performance</h3>
          <p className="text-xs text-slate-500">Average ratings across key categories</p>
        </div>

        {/* Category Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <CategoryRatingCard
            category="Quality"
            rating={categoryAverages.quality}
            description="Consistent high-quality deliverables"
            icon={Target}
            color="blue"
          />
          <CategoryRatingCard
            category="Timeliness"
            rating={categoryAverages.timeliness}
            description="Meets deadlines reliably"
            icon={Clock}
            color="cyan"
          />
          <CategoryRatingCard
            category="Communication"
            rating={categoryAverages.communication}
            description="Clear and responsive communication"
            icon={MessageSquare}
            color="orange"
          />
        </div>
      </motion.div>
    </div>
  )
}
