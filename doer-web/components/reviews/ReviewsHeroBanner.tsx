"use client"

import { Star, MessageSquare, TrendingUp } from "lucide-react"
import { motion } from "framer-motion"
import { RatingStarDisplay } from "./RatingStarDisplay"

/**
 * Props for the ReviewsHeroBanner component
 */
interface ReviewsHeroBannerProps {
  /**
   * Overall average rating (0-5)
   */
  overallRating: number
  /**
   * Total number of reviews received
   */
  totalReviews: number
  /**
   * Percentage of 5-star reviews
   */
  fiveStarPercentage: number
  /**
   * Trending percentage change (positive or negative)
   */
  trendingPercent: number
  /**
   * Callback when user clicks "Request Reviews" button
   */
  onRequestReviews?: () => void
  /**
   * Callback when user clicks "View Insights" button
   */
  onViewInsights?: () => void
}

/**
 * Animation variants for fade-in-up effect
 * Consistent timing: 0.4s duration with easeOut
 */
const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.4 },
}

/**
 * Props for stat card component
 */
interface StatCardProps {
  icon: React.ReactNode
  label: string
  value: string
  highlight?: boolean
}

/**
 * StatCard Component
 *
 * Displays a single statistic with an icon, label, and value in a card format.
 * Used in the hero banner's right column for quick insights.
 */
function StatCard({ icon, label, value, highlight }: StatCardProps) {
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-white/85 p-4 shadow-[0_10px_22px_rgba(30,58,138,0.08)] border border-white/70 transition-all duration-300 hover:shadow-[0_16px_35px_rgba(30,58,138,0.12)] hover:-translate-y-0.5 cursor-default">
      <div
        className={`flex h-10 w-10 items-center justify-center rounded-xl transition-transform duration-300 hover:scale-110 ${
          highlight
            ? "bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] text-white"
            : "bg-slate-100 text-slate-600"
        }`}
      >
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-xs font-medium text-slate-500 truncate">{label}</p>
        <p
          className={`text-sm font-semibold truncate ${
            highlight ? "text-slate-900" : "text-slate-700"
          }`}
        >
          {value}
        </p>
      </div>
    </div>
  )
}

/**
 * ReviewsHeroBanner Component
 *
 * Large hero card that displays overall review performance metrics and quick actions.
 * Matches the visual style and layout patterns from the dashboard hero card.
 *
 * Features:
 * - Large rating display with visual stars and gradient number
 * - Performance badge and quick insight text
 * - Two CTA buttons (gradient primary, outline secondary)
 * - Three stacked stat cards showing key metrics
 * - Responsive layout (stacked on mobile, side-by-side on desktop)
 * - Smooth fade-in animations
 *
 * @example
 * ```tsx
 * <ReviewsHeroBanner
 *   overallRating={4.8}
 *   totalReviews={127}
 *   fiveStarPercentage={85}
 *   trendingPercent={12}
 *   onRequestReviews={() => console.log('Request reviews')}
 *   onViewInsights={() => console.log('View insights')}
 * />
 * ```
 */
export function ReviewsHeroBanner({
  overallRating,
  totalReviews,
  fiveStarPercentage,
  trendingPercent,
  onRequestReviews,
  onViewInsights,
}: ReviewsHeroBannerProps) {
  const trendingText =
    trendingPercent >= 0 ? `+${trendingPercent}%` : `${trendingPercent}%`
  const trendingLabel = trendingPercent >= 0 ? "Trending up" : "Trending down"

  return (
    <motion.div
      className="relative overflow-hidden rounded-[28px] bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]"
      {...fadeInUp}
    >
      {/* Background gradient overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(99,102,241,0.18),transparent_55%)]" />

      {/* Main content grid */}
      <div className="relative grid gap-6 lg:grid-cols-[1fr_320px]">
        {/* Left column - Main content */}
        <div className="space-y-4">
          {/* Performance badge */}
          <span className="inline-flex items-center rounded-full bg-[#E6F4FF] px-3 py-1 text-xs font-semibold text-[#4B9BFF]">
            Your Performance
          </span>

          {/* Large rating display */}
          <div className="space-y-2">
            <RatingStarDisplay
              rating={overallRating}
              size="lg"
              variant="gradient"
              showNumber={true}
            />
            <p className="text-sm font-medium text-slate-600">
              Based on {totalReviews.toLocaleString()} review
              {totalReviews !== 1 ? "s" : ""}
            </p>
          </div>

          {/* Quick insight text */}
          <p className="text-sm leading-relaxed text-slate-500 max-w-xl">
            Your reputation is growing! Keep delivering exceptional work to maintain your
            stellar rating and attract more high-value projects.
          </p>

          {/* Action buttons */}
          <div className="flex flex-wrap items-center gap-3 pt-2">
            <button
              onClick={onRequestReviews}
              className="h-11 rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-5 text-sm font-semibold text-white shadow-[0_12px_28px_rgba(90,124,255,0.35)] transition-all duration-300 hover:-translate-y-0.5 hover:shadow-[0_16px_35px_rgba(90,124,255,0.45)] active:translate-y-0 focus:outline-none focus:ring-2 focus:ring-[#5A7CFF] focus:ring-offset-2"
              type="button"
            >
              Request Reviews
            </button>
            <button
              onClick={onViewInsights}
              className="h-11 rounded-full border border-white/80 bg-white/85 px-5 text-sm font-semibold text-slate-600 shadow-[0_10px_22px_rgba(30,58,138,0.1)] transition-all duration-300 hover:text-slate-800 hover:border-white hover:shadow-[0_16px_35px_rgba(30,58,138,0.15)] active:scale-95 focus:outline-none focus:ring-2 focus:ring-slate-400 focus:ring-offset-2"
              type="button"
            >
              View Insights
            </button>
          </div>
        </div>

        {/* Right column - Stat cards */}
        <div className="flex flex-col gap-3">
          <StatCard
            icon={<Star className="w-5 h-5" />}
            label="5-Star Reviews"
            value={`${fiveStarPercentage}% of total`}
            highlight
          />
          <StatCard
            icon={<MessageSquare className="w-5 h-5" />}
            label="Total Reviews"
            value={totalReviews.toLocaleString()}
          />
          <StatCard
            icon={<TrendingUp className="w-5 h-5" />}
            label={trendingLabel}
            value={trendingText}
          />
        </div>
      </div>
    </motion.div>
  )
}
