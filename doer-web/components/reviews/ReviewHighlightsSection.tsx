"use client"

import { motion } from "framer-motion"
import { ArrowRight, Star } from "lucide-react"
import Link from "next/link"
import { ReviewCard, type Review } from "./ReviewCard"
import { cn } from "@/lib/utils"

/**
 * Props for the ReviewHighlightsSection component
 */
interface ReviewHighlightsSectionProps {
  /**
   * The featured review to highlight
   */
  featuredReview: Review
  /**
   * Array of recent reviews to display
   */
  recentReviews: Review[]
  /**
   * Handler for when a review is clicked
   */
  onReviewClick?: (review: Review) => void
  /**
   * Additional CSS classes
   */
  className?: string
}

/**
 * ReviewHighlightsSection Component
 *
 * A bento-grid layout component that displays featured and recent reviews.
 * Uses a two-column layout with the featured review on the left and
 * a scrollable list of recent reviews on the right.
 *
 * Features:
 * - Bento grid layout (2 columns on large screens)
 * - Featured review with gradient accent border
 * - Scrollable recent reviews list
 * - Smooth animations with Framer Motion
 * - View all link for navigation
 *
 * @example
 * ```tsx
 * <ReviewHighlightsSection
 *   featuredReview={topReview}
 *   recentReviews={latestReviews}
 *   onReviewClick={(review) => console.log(review)}
 * />
 * ```
 */
export function ReviewHighlightsSection({
  featuredReview,
  recentReviews,
  onReviewClick,
  className,
}: ReviewHighlightsSectionProps) {
  // Take only first 3 recent reviews
  const displayedReviews = recentReviews.slice(0, 3)

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 },
  }

  return (
    <motion.div
      className={cn("grid grid-cols-1 lg:grid-cols-2 gap-6", className)}
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {/* Left Card - Featured Review */}
      <motion.div
        variants={itemVariants}
        className="bg-white/85 rounded-2xl p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]"
      >
        {/* Section Header */}
        <div className="flex items-center gap-3 mb-6">
          <div className="p-2 rounded-xl bg-gradient-to-br from-[#5A7CFF]/10 to-[#49C5FF]/10">
            <Star className="w-5 h-5 text-[#5A7CFF]" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-slate-900">Top Rated Work</h3>
            <p className="text-sm text-slate-500">Your highest rated review</p>
          </div>
        </div>

        {/* Featured Review Card */}
        <ReviewCard
          review={featuredReview}
          variant="featured"
          onClick={() => onReviewClick?.(featuredReview)}
        />
      </motion.div>

      {/* Right Card - Recent Feedback */}
      <motion.div
        variants={itemVariants}
        className="bg-white/85 rounded-2xl p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)] flex flex-col"
      >
        {/* Section Header */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-xl bg-gradient-to-br from-[#5A7CFF]/10 to-[#49C5FF]/10">
              <Star className="w-5 h-5 text-[#5A7CFF]" />
            </div>
            <div>
              <h3 className="text-lg font-semibold text-slate-900">Latest Feedback</h3>
              <p className="text-sm text-slate-500">Recent reviews from clients</p>
            </div>
          </div>
        </div>

        {/* Recent Reviews List */}
        <div className="flex-1 space-y-3 overflow-y-auto max-h-[400px] pr-2 scrollbar-thin scrollbar-thumb-slate-200 scrollbar-track-transparent">
          {displayedReviews.length > 0 ? (
            displayedReviews.map((review, index) => (
              <motion.div
                key={review.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                <ReviewCard
                  review={review}
                  variant="compact"
                  onClick={() => onReviewClick?.(review)}
                />
              </motion.div>
            ))
          ) : (
            <div className="flex items-center justify-center h-40 text-center">
              <div className="space-y-2">
                <Star className="w-8 h-8 text-slate-300 mx-auto" />
                <p className="text-sm text-slate-500">No recent reviews yet</p>
              </div>
            </div>
          )}
        </div>

        {/* View All Link */}
        {recentReviews.length > 3 && (
          <motion.div
            className="mt-4 pt-4 border-t border-slate-200"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
          >
            <Link
              href="/reviews"
              className="flex items-center justify-center gap-2 text-sm font-medium text-[#5A7CFF] hover:text-[#4B9BFF] transition-colors group"
            >
              <span>View All Reviews</span>
              <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </Link>
          </motion.div>
        )}
      </motion.div>
    </motion.div>
  )
}
