'use client'

import { useState, useEffect, useMemo } from 'react'
import { motion } from 'framer-motion'
import { toast } from 'sonner'
import { createClient } from '@/lib/supabase/client'
import { useAuth } from '@/hooks/useAuth'
import {
  ReviewsHeroBanner,
  RatingAnalyticsDashboard,
  ReviewHighlightsSection,
  ReviewsListSection,
  AchievementCards,
  type Review,
  type RatingDistributionItem,
  type CategoryAverages,
} from '@/components/reviews'

/**
 * Animation variants for page elements
 */
const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -20 },
}

const staggerContainer = {
  animate: {
    transition: {
      staggerChildren: 0.1,
    },
  },
}

/**
 * Reviews Page Component
 *
 * Complete redesign with modular component architecture.
 * Features hero banner, analytics dashboard, highlights section,
 * full reviews list, and achievement cards.
 *
 * Layout Structure:
 * 1. Hero Banner (full width) - Overall performance metrics
 * 2. Analytics Dashboard - Rating distribution + category performance
 * 3. Review Highlights (Bento Grid) - Featured + recent reviews
 * 4. Reviews List (Tabbed) - All reviews with filtering
 * 5. Achievements - Milestone cards
 *
 * Data Management:
 * - Fetches reviews from Supabase doer_reviews table
 * - Calculates all derived metrics (averages, distributions)
 * - Handles loading, empty, and error states
 * - Real-time filtering and sorting
 *
 * @example
 * Access at: /reviews
 */
export default function ReviewsPage() {
  const { doer, isLoading: authLoading } = useAuth()
  const [reviews, setReviews] = useState<Review[]>([])
  const [isLoading, setIsLoading] = useState(true)

  /**
   * Fetch reviews from Supabase
   * Waits for auth to complete before deciding whether to fetch or show empty state.
   * Without the authLoading gate, doer is null during auth init which immediately
   * sets isLoading=false and flashes empty content before doer is available.
   */
  useEffect(() => {
    if (doer?.id) {
      const fetchReviews = async () => {
        try {
          const supabase = createClient()

          // Fetch reviews for this doer
          const { data: reviewsData, error } = await supabase
            .from('doer_reviews')
            .select(
              `
              id,
              overall_rating,
              quality_rating,
              timeliness_rating,
              communication_rating,
              review_text,
              created_at,
              project:projects(title),
              reviewer:profiles!reviewer_id(full_name, avatar_url)
            `
            )
            .eq('doer_id', doer.id)
            .eq('is_public', true)
            .order('created_at', { ascending: false })

          if (error) {
            console.error('Error fetching reviews:', error)
            toast.error('Failed to load reviews')
          } else {
            // Transform data to match Review type (Supabase returns arrays for single relations)
            const transformedReviews: Review[] = (reviewsData || []).map((r) => ({
              id: r.id,
              overall_rating: r.overall_rating,
              quality_rating: r.quality_rating,
              timeliness_rating: r.timeliness_rating,
              communication_rating: r.communication_rating,
              review_text: r.review_text,
              created_at: r.created_at,
              project: Array.isArray(r.project) ? r.project[0] || undefined : r.project || undefined,
              reviewer: Array.isArray(r.reviewer)
                ? r.reviewer[0] || undefined
                : r.reviewer || undefined,
            }))
            setReviews(transformedReviews)
          }
        } catch (err) {
          console.error('Error:', err)
          toast.error('An error occurred while loading reviews')
        } finally {
          setIsLoading(false)
        }
      }

      fetchReviews()
    } else if (!authLoading) {
      // Auth finished but no doer — show empty state instead of infinite skeleton
      setIsLoading(false)
    }
  }, [doer?.id, authLoading])

  /**
   * Calculate derived metrics from reviews
   * OPTIMIZED: Single-pass algorithm for O(n) complexity instead of O(n*9)
   *
   * Performance improvement: 9x faster for large review lists
   * - Before: 100 reviews = 9 iterations = ~900 operations
   * - After: 100 reviews = 1 iteration = ~100 operations
   */
  const metrics = useMemo(() => {
    const totalReviews = reviews.length

    if (totalReviews === 0) {
      return {
        averageRating: 0,
        totalReviews: 0,
        fiveStarPercentage: 0,
        fiveStarCount: 0,
        trendingPercent: 0,
        ratingDistribution: [
          { stars: 5, count: 0 },
          { stars: 4, count: 0 },
          { stars: 3, count: 0 },
          { stars: 2, count: 0 },
          { stars: 1, count: 0 },
        ] as RatingDistributionItem[],
        categoryAverages: {
          quality: 0,
          timeliness: 0,
          communication: 0,
        } as CategoryAverages,
        featuredReview: null,
        recentReviews: [],
      }
    }

    // SINGLE PASS: Accumulate all metrics in one loop
    let totalRating = 0
    let qualitySum = 0
    let timelinessSum = 0
    let communicationSum = 0
    const starCounts: Record<number, number> = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 }

    // Track highest rated review for featured section
    let highestRated: Review | null = null
    let highestRating = 0

    // Calculate trend (compare recent vs older reviews)
    const recentCount = Math.max(1, Math.min(10, Math.floor(totalReviews / 2)))
    let recentSum = 0
    let olderSum = 0

    // Single loop through all reviews
    for (let i = 0; i < totalReviews; i++) {
      const review = reviews[i]

      // Accumulate all rating sums
      totalRating += review.overall_rating
      qualitySum += review.quality_rating
      timelinessSum += review.timeliness_rating
      communicationSum += review.communication_rating

      // Count star distribution
      const roundedStars = Math.round(review.overall_rating)
      if (roundedStars >= 1 && roundedStars <= 5) {
        starCounts[roundedStars]++
      }

      // Track highest rated review
      if (review.overall_rating > highestRating) {
        highestRating = review.overall_rating
        highestRated = review
      }

      // Trend calculation (recent vs older)
      if (i < recentCount) {
        recentSum += review.overall_rating
      } else {
        olderSum += review.overall_rating
      }
    }

    // Calculate all averages
    const averageRating = totalRating / totalReviews
    const categoryAverages: CategoryAverages = {
      quality: qualitySum / totalReviews,
      timeliness: timelinessSum / totalReviews,
      communication: communicationSum / totalReviews,
    }

    // Build rating distribution array
    const distribution: RatingDistributionItem[] = [5, 4, 3, 2, 1].map((stars) => ({
      stars,
      count: starCounts[stars] || 0,
    }))

    // Calculate 5-star metrics
    const fiveStarCount = starCounts[5] || 0
    const fiveStarPercentage = Math.round((fiveStarCount / totalReviews) * 100)

    // Calculate trend percentage
    const recentAvg = recentSum / recentCount
    const olderAvg = olderSum / Math.max(1, totalReviews - recentCount)
    const trendDiff = recentAvg - olderAvg
    const trendingPercent = Math.abs(trendDiff) > 0.1
      ? Math.round((trendDiff / Math.max(olderAvg, 0.1)) * 100)
      : 0

    // Get recent reviews (last 3)
    const recentReviews = reviews.slice(0, 3)

    return {
      averageRating,
      totalReviews,
      fiveStarPercentage,
      fiveStarCount,
      trendingPercent,
      ratingDistribution: distribution,
      categoryAverages,
      featuredReview: highestRated,
      recentReviews,
    }
  }, [reviews])

  /**
   * Handle review click (optional navigation or modal)
   */
  const handleReviewClick = (_review: Review) => {
    // TODO: Navigate to review detail or open modal
  }

  /**
   * Handle Request Reviews action
   * TODO: Implement a request review flow (e.g., send review request to recent supervisors)
   */
  const handleRequestReviews = () => {
    toast.info('Review request feature is not yet available.')
  }

  /**
   * Handle View Insights action
   */
  const handleViewInsights = () => {
    // Scroll to analytics section
    const analyticsSection = document.getElementById('analytics-section')
    analyticsSection?.scrollIntoView({ behavior: 'smooth' })
  }

  // Skeleton gate removed — show page content immediately while loading


  return (
    <motion.div
      className="relative space-y-8"
      initial="initial"
      animate="animate"
      variants={staggerContainer}
    >
      {/* Radial gradient background overlay - design system pattern */}
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%)]" />

      {/* ================================================================
          1. HERO BANNER SECTION
          Component: ReviewsHeroBanner
          Displays overall performance metrics and CTAs
          ================================================================ */}
      <motion.div variants={fadeInUp}>
        <ReviewsHeroBanner
          overallRating={metrics.averageRating}
          totalReviews={metrics.totalReviews}
          fiveStarPercentage={metrics.fiveStarPercentage}
          trendingPercent={metrics.trendingPercent}
          onRequestReviews={handleRequestReviews}
          onViewInsights={handleViewInsights}
        />
      </motion.div>

      {/* ================================================================
          2. ANALYTICS DASHBOARD
          Component: RatingAnalyticsDashboard
          Two-column layout: Rating distribution (35%) + Category performance (65%)
          ================================================================ */}
      <motion.div id="analytics-section" variants={fadeInUp}>
        <RatingAnalyticsDashboard
          ratingDistribution={metrics.ratingDistribution}
          categoryAverages={metrics.categoryAverages}
        />
      </motion.div>

      {/* ================================================================
          3. REVIEW HIGHLIGHTS (Bento Grid)
          Component: ReviewHighlightsSection
          Two-column layout: Featured review (left) + Recent reviews (right)
          ================================================================ */}
      {metrics.featuredReview && (
        <motion.div variants={fadeInUp}>
          <ReviewHighlightsSection
            featuredReview={metrics.featuredReview}
            recentReviews={metrics.recentReviews}
            onReviewClick={handleReviewClick}
          />
        </motion.div>
      )}

      {/* ================================================================
          4. REVIEWS LIST (Tabbed)
          Component: ReviewsListSection
          Full reviews list with search, filter, and tabs
          ================================================================ */}
      <motion.div variants={fadeInUp}>
        <ReviewsListSection reviews={reviews} onReviewClick={handleReviewClick} />
      </motion.div>

      {/* ================================================================
          5. ACHIEVEMENTS
          Component: AchievementCards
          Grid of achievement milestone cards with progress tracking
          ================================================================ */}
      <motion.div variants={fadeInUp}>
        <AchievementCards
          totalReviews={metrics.totalReviews}
          averageRating={metrics.averageRating}
          fiveStarCount={metrics.fiveStarCount}
        />
      </motion.div>
    </motion.div>
  )
}
