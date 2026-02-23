'use client'

/**
 * Rating Breakdown component
 * Displays detailed rating breakdown and recent reviews
 * @module components/profile/RatingBreakdown
 */

import { motion } from 'framer-motion'
import { Star, ThumbsUp, Clock, MessageSquare, Award, TrendingUp } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { cn } from '@/lib/utils'
import { mockReviews, defaultRatingDistribution } from './constants'
import type { DoerReview } from '@/types/database'

/**
 * RatingBreakdown component props
 */
interface RatingBreakdownProps {
  /** Overall rating */
  overall: number
  /** Quality rating */
  quality: number
  /** Timeliness rating */
  timeliness: number
  /** Communication rating */
  communication: number
  /** Total number of reviews */
  totalReviews: number
  /** Rating distribution (star count) */
  ratingDistribution?: Record<number, number>
  /** Recent reviews */
  recentReviews?: DoerReview[]
  /** Loading state */
  isLoading?: boolean
  /** Additional class name */
  className?: string
}

/** Animation variants for progress bars */
const barVariants = {
  hidden: { width: 0 },
  visible: (percentage: number) => ({
    width: `${percentage}%`,
    transition: { duration: 0.5, ease: 'easeOut' as const },
  }),
}

/**
 * Get rating color based on value
 * @param rating - Rating value (1-5)
 * @returns Tailwind color class
 */
const getRatingColor = (rating: number): string => {
  if (rating >= 4.5) return 'text-blue-600'
  if (rating >= 4.0) return 'text-blue-500'
  if (rating >= 3.0) return 'text-blue-400'
  return 'text-blue-300'
}

/**
 * Get rating label based on value
 * @param rating - Rating value (1-5)
 * @returns Human-readable label
 */
const getRatingLabel = (rating: number): string => {
  if (rating >= 4.5) return 'Excellent'
  if (rating >= 4.0) return 'Very Good'
  if (rating >= 3.0) return 'Good'
  return 'Needs Improvement'
}

/**
 * Format date for display
 * @param date - ISO date string
 * @returns Formatted date string
 */
const formatDate = (date: string): string => {
  return new Date(date).toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

/**
 * Render star icons
 * @param rating - Rating value
 * @param size - Icon size variant
 */
const renderStars = (rating: number, size: 'sm' | 'md' = 'sm') => {
  const sizeClass = size === 'sm' ? 'h-4 w-4' : 'h-5 w-5'
  return (
    <div className="flex items-center gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={cn(
            sizeClass,
            star <= Math.round(rating) ? 'fill-blue-500 text-blue-500' : 'text-muted-foreground/30'
          )}
        />
      ))}
    </div>
  )
}

/** Rating categories configuration */
const categories = [
  { key: 'quality', label: 'Quality', icon: ThumbsUp, color: 'bg-blue-600' },
  { key: 'timeliness', label: 'Timeliness', icon: Clock, color: 'bg-green-600' },
  { key: 'communication', label: 'Communication', icon: MessageSquare, color: 'bg-purple-600' },
] as const

/**
 * Rating Breakdown component
 * Displays detailed rating breakdown and recent reviews
 */
export function RatingBreakdown({
  overall = 4.8,
  quality = 4.9,
  timeliness = 4.7,
  communication = 4.8,
  totalReviews = 45,
  ratingDistribution = defaultRatingDistribution,
  recentReviews = mockReviews,
  isLoading,
  className,
}: RatingBreakdownProps) {
  const categoryValues = { quality, timeliness, communication }
  const totalDistribution = Object.values(ratingDistribution).reduce((a, b) => a + b, 0)

  return (
    <div className={cn('space-y-6', className)}>
      {/* Overall rating card */}
      <Card className="w-full max-w-full overflow-hidden shadow-lg border-blue-100">
        <CardContent className="p-6 space-y-6">
          <div className="w-full grid gap-8 md:grid-cols-[minmax(240px,280px)_1fr]">
            {/* Rating summary section */}
            <div className="flex items-center justify-center md:justify-start min-w-0">
              <div className="relative w-full">
                {/* Gradient background decoration */}
                <div className="absolute inset-0 bg-gradient-to-br from-blue-500/20 via-blue-400/10 to-transparent rounded-3xl blur-xl" />

                <div className="relative flex items-center gap-5 rounded-3xl border-2 border-blue-100 bg-gradient-to-br from-blue-50 via-white to-blue-50/30 p-6 shadow-md">
                  {/* Rating number */}
                  <div className="flex flex-col items-center flex-shrink-0">
                    <div className="relative">
                      <div className="absolute inset-0 bg-blue-500/10 rounded-2xl blur-md" />
                      <div className="relative w-24 h-24 rounded-2xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-lg">
                        <div className="text-center">
                          <p className="text-4xl font-bold text-white drop-shadow-sm">{overall.toFixed(1)}</p>
                          <p className="text-xs text-blue-100 font-medium whitespace-nowrap">out of 5</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Rating details */}
                  <div className="space-y-2 min-w-0">
                    <Badge className="bg-gradient-to-r from-blue-600 to-blue-500 text-white shadow-md px-3 py-1 whitespace-nowrap">
                      {getRatingLabel(overall)}
                    </Badge>
                    <div className="mt-3">{renderStars(overall, 'md')}</div>
                    <p className="text-sm text-muted-foreground font-medium truncate">
                      <span className="text-blue-600 font-bold">{totalReviews}</span> reviews
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Category ratings */}
            <div className="space-y-5 min-w-0">
              {categories.map((cat) => {
                const Icon = cat.icon
                const value = categoryValues[cat.key]
                const percentage = (value / 5) * 100

                return (
                  <div key={cat.key} className="space-y-2.5">
                    <div className="flex items-center justify-between gap-3">
                      <div className="flex items-center gap-3 min-w-0 flex-1">
                        <div className="w-9 h-9 flex-shrink-0 rounded-xl bg-blue-50 flex items-center justify-center">
                          <Icon className="h-4.5 w-4.5 text-blue-600" />
                        </div>
                        <span className="text-sm font-semibold text-foreground truncate">{cat.label}</span>
                      </div>
                      <div className="flex items-center gap-2 flex-shrink-0">
                        <span className={cn('text-base font-bold min-w-[2.5rem] text-right', getRatingColor(value))}>{value.toFixed(1)}</span>
                        <span className="text-xs text-muted-foreground font-medium whitespace-nowrap">/ 5.0</span>
                      </div>
                    </div>
                    <div className="relative h-2.5 bg-blue-50 rounded-full overflow-hidden shadow-inner">
                      <motion.div
                        initial="hidden"
                        animate="visible"
                        custom={percentage}
                        variants={barVariants}
                        className="h-full bg-gradient-to-r from-blue-500 to-blue-600 rounded-full shadow-sm"
                      />
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Rating distribution */}
      <Card className="w-full max-w-full overflow-hidden shadow-lg border-blue-100">
        <CardHeader className="p-6 pb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 flex-shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md">
              <TrendingUp className="h-5 w-5 text-white" />
            </div>
            <div className="flex-1 min-w-0">
              <CardTitle className="text-lg font-bold truncate">Rating Distribution</CardTitle>
              <CardDescription className="text-xs truncate">Breakdown of ratings received</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-6 space-y-3.5">
          {[5, 4, 3, 2, 1].map((stars) => {
            const count = ratingDistribution[stars] || 0
            const percentage = totalDistribution > 0 ? (count / totalDistribution) * 100 : 0

            return (
              <div key={stars} className="flex items-center gap-4">
                <div className="flex items-center gap-1.5 w-20">
                  <span className="text-sm font-semibold text-foreground w-3">{stars}</span>
                  <Star className="h-4 w-4 fill-blue-500 text-blue-500" />
                </div>
                <div className="flex-1 h-3 bg-blue-50 rounded-full overflow-hidden shadow-inner">
                  <motion.div
                    initial="hidden"
                    animate="visible"
                    custom={percentage}
                    variants={barVariants}
                    className="h-full bg-gradient-to-r from-blue-500 to-blue-600 rounded-full shadow-sm"
                  />
                </div>
                <span className="text-sm font-semibold text-blue-600 w-14 text-right">{count}</span>
                <span className="text-xs text-muted-foreground w-12 text-right">
                  {percentage > 0 ? `${percentage.toFixed(0)}%` : '0%'}
                </span>
              </div>
            )
          })}
        </CardContent>
      </Card>

      {/* Recent reviews */}
      <Card className="w-full max-w-full overflow-hidden shadow-lg border-blue-100">
        <CardHeader className="p-6 pb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 flex-shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md">
              <Award className="h-5 w-5 text-white" />
            </div>
            <div className="flex-1 min-w-0">
              <CardTitle className="text-lg font-bold truncate">Recent Reviews</CardTitle>
              <CardDescription className="text-xs truncate">What supervisors are saying</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-6 space-y-4">
          {recentReviews.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-16 h-16 mx-auto rounded-2xl bg-blue-50 flex items-center justify-center mb-4">
                <Star className="h-8 w-8 text-blue-300" />
              </div>
              <p className="text-muted-foreground font-medium">No reviews yet</p>
              <p className="text-sm text-muted-foreground/70 mt-1">Complete your first task to receive reviews</p>
            </div>
          ) : (
            recentReviews.map((review, index) => (
              <motion.div
                key={review.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                className="p-5 rounded-2xl border border-blue-100 bg-gradient-to-br from-blue-50/30 via-white to-transparent shadow-sm hover:shadow-md transition-shadow"
              >
                <div className="flex items-start gap-4">
                  <Avatar className="h-12 w-12 border-2 border-blue-100 shadow-sm">
                    <AvatarFallback className="bg-gradient-to-br from-blue-500 to-blue-600 text-white font-semibold">
                      {review.reviewer_name?.split(' ').map((n) => n[0]).join('') || 'R'}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-2 mb-2">
                      <p className="font-semibold text-foreground truncate">{review.reviewer_name || 'Anonymous'}</p>
                      <span className="text-xs text-muted-foreground whitespace-nowrap font-medium">
                        {formatDate(review.created_at)}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 mb-3">
                      {renderStars(review.overall_rating)}
                      <Badge variant="outline" className="text-xs border-blue-200 text-blue-700 bg-blue-50">
                        {review.project_title}
                      </Badge>
                    </div>
                    {review.feedback && (
                      <div className="p-3 rounded-xl bg-blue-50/50 border border-blue-100 mb-3">
                        <p className="text-sm text-foreground/80 italic">"{review.feedback}"</p>
                      </div>
                    )}
                    <div className="flex flex-wrap gap-2">
                      <Badge className="text-xs bg-blue-100 text-blue-700 hover:bg-blue-200 border-0">
                        Quality: {review.quality_rating}/5
                      </Badge>
                      <Badge className="text-xs bg-blue-100 text-blue-700 hover:bg-blue-200 border-0">
                        Timeliness: {review.timeliness_rating}/5
                      </Badge>
                      <Badge className="text-xs bg-blue-100 text-blue-700 hover:bg-blue-200 border-0">
                        Communication: {review.communication_rating}/5
                      </Badge>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))
          )}
        </CardContent>
      </Card>
    </div>
  )
}
