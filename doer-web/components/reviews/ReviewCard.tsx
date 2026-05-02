"use client"

import { motion } from "framer-motion"
import { Star } from "lucide-react"
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { RatingStarDisplay } from "./RatingStarDisplay"
import { cn } from "@/lib/utils"

/**
 * Review data structure
 */
export interface Review {
  id: string
  overall_rating: number
  quality_rating: number
  timeliness_rating: number
  communication_rating: number
  review_text?: string
  created_at: string
  project?: {
    title: string
  }
  reviewer?: {
    full_name?: string
    avatar_url?: string
  }
}

/**
 * Display variants for the review card
 */
type ReviewVariant = "full" | "compact" | "featured"

/**
 * Props for the ReviewCard component
 */
interface ReviewCardProps {
  /**
   * The review data to display
   */
  review: Review
  /**
   * Visual variant of the card
   * - full: Complete review with all details, category pills at bottom
   * - compact: Smaller version for lists, horizontal layout
   * - featured: Highlighted style with gradient border, larger text
   * @default "full"
   */
  variant?: ReviewVariant
  /**
   * Optional click handler for the card
   */
  onClick?: () => void
  /**
   * Additional CSS classes
   */
  className?: string
}

/**
 * ReviewCard Component
 *
 * A flexible review display component that supports multiple visual variants.
 * Displays reviewer information, ratings, review text, and project details.
 *
 * Features:
 * - Three display variants (full, compact, featured)
 * - Gradient borders for featured variant
 * - Category rating pills with icons
 * - Hover animations
 * - Responsive layout
 *
 * @example
 * ```tsx
 * <ReviewCard
 *   review={reviewData}
 *   variant="featured"
 *   onClick={() => console.log('Review clicked')}
 * />
 * ```
 */
export function ReviewCard({
  review,
  variant = "full",
  onClick,
  className,
}: ReviewCardProps) {
  const formattedDate = new Date(review.created_at).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  })

  const getInitials = () => {
    if (!review.reviewer?.full_name) return "S"
    return review.reviewer.full_name
      .split(" ")
      .map((n) => n[0])
      .join("")
  }

  const getRatingBadgeColor = (rating: number) => {
    if (rating >= 4) return "bg-emerald-100 text-emerald-700"
    if (rating === 3) return "bg-amber-100 text-amber-700"
    return "bg-red-100 text-red-700"
  }

  // Compact variant - horizontal layout
  if (variant === "compact") {
    return (
      <motion.div
        className={cn(
          "flex items-start gap-3 p-3 rounded-xl bg-slate-50/80 cursor-pointer transition-all duration-200",
          "hover:bg-slate-100/80",
          onClick && "cursor-pointer",
          className
        )}
        onClick={onClick}
        whileHover={{ scale: 1.01 }}
      >
        <Avatar className="h-9 w-9 border-2 border-white shadow-sm shrink-0">
          <AvatarImage src={review.reviewer?.avatar_url || undefined} />
          <AvatarFallback className="bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] text-white text-xs">
            {getInitials()}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2 mb-1">
            <p className="font-medium text-sm truncate">
              {review.reviewer?.full_name || "Supervisor"}
            </p>
            <div className="flex items-center gap-1 shrink-0">
              <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
              <span className="text-sm font-semibold">{review.overall_rating.toFixed(1)}</span>
            </div>
          </div>
          {review.review_text && (
            <p className="text-xs text-slate-600 line-clamp-2 mb-1">
              &quot;{review.review_text}&quot;
            </p>
          )}
          <p className="text-xs text-slate-500">{formattedDate}</p>
        </div>
      </motion.div>
    )
  }

  // Featured variant - gradient border and larger styling
  if (variant === "featured") {
    return (
      <motion.div
        className={cn(
          "relative bg-white/85 rounded-2xl p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]",
          "transition-all duration-300",
          "hover:-translate-y-0.5 hover:shadow-[0_20px_50px_rgba(30,58,138,0.12)]",
          "before:absolute before:inset-0 before:rounded-2xl before:p-[2px]",
          "before:bg-gradient-to-br before:from-[#5A7CFF] before:via-[#5B86FF] before:to-[#49C5FF]",
          "before:-z-10 before:opacity-40",
          onClick && "cursor-pointer",
          className
        )}
        onClick={onClick}
        whileHover={{ y: -2 }}
      >
        {/* Large star rating at top */}
        <div className="flex items-center justify-center mb-4">
          <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-amber-50 to-amber-100/50">
            <Star className="w-6 h-6 fill-amber-400 text-amber-400" />
            <span className="text-2xl font-bold text-slate-900">
              {review.overall_rating.toFixed(1)}
            </span>
          </div>
        </div>

        {/* Review content */}
        <div className="space-y-4">
          {/* Reviewer info */}
          <div className="flex items-center justify-center gap-3">
            <Avatar className="h-12 w-12 border-2 border-white shadow-md">
              <AvatarImage src={review.reviewer?.avatar_url || undefined} />
              <AvatarFallback className="bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] text-white">
                {getInitials()}
              </AvatarFallback>
            </Avatar>
            <div className="text-center">
              <p className="font-semibold text-slate-900">
                {review.reviewer?.full_name || "Supervisor"}
              </p>
              <p className="text-sm text-slate-500">{formattedDate}</p>
            </div>
          </div>

          {/* Project badge */}
          {review.project?.title && (
            <div className="flex justify-center">
              <Badge className="bg-[#E6F4FF] text-[#4B9BFF] border-0 font-normal">
                {review.project.title}
              </Badge>
            </div>
          )}

          {/* Review text */}
          {review.review_text && (
            <div className="bg-slate-50/80 rounded-2xl p-4">
              <p className="text-sm text-slate-700 leading-relaxed text-center italic">
                &quot;{review.review_text}&quot;
              </p>
            </div>
          )}

          {/* Category ratings */}
          <div className="flex flex-wrap justify-center gap-2">
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-teal-50">
              <span className="text-xs text-teal-700 font-medium">Quality</span>
              <div className="flex items-center gap-0.5">
                {Array.from({ length: 5 }, (_, i) => (
                  <Star
                    key={i}
                    className={cn(
                      "w-3 h-3",
                      i < review.quality_rating
                        ? "fill-teal-500 text-teal-500"
                        : "text-slate-300"
                    )}
                  />
                ))}
              </div>
            </div>
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-50">
              <span className="text-xs text-emerald-700 font-medium">Timeliness</span>
              <div className="flex items-center gap-0.5">
                {Array.from({ length: 5 }, (_, i) => (
                  <Star
                    key={i}
                    className={cn(
                      "w-3 h-3",
                      i < review.timeliness_rating
                        ? "fill-emerald-500 text-emerald-500"
                        : "text-slate-300"
                    )}
                  />
                ))}
              </div>
            </div>
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-amber-50">
              <span className="text-xs text-amber-700 font-medium">Communication</span>
              <div className="flex items-center gap-0.5">
                {Array.from({ length: 5 }, (_, i) => (
                  <Star
                    key={i}
                    className={cn(
                      "w-3 h-3",
                      i < review.communication_rating
                        ? "fill-amber-500 text-amber-500"
                        : "text-slate-300"
                    )}
                  />
                ))}
              </div>
            </div>
          </div>
        </div>
      </motion.div>
    )
  }

  // Full variant - complete review display
  return (
    <motion.div
      className={cn(
        "bg-white/85 rounded-2xl p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]",
        "transition-all duration-300",
        "hover:-translate-y-0.5 hover:shadow-[0_20px_50px_rgba(30,58,138,0.12)]",
        onClick && "cursor-pointer",
        className
      )}
      onClick={onClick}
      whileHover={{ y: -2 }}
    >
      <div className="space-y-4">
        {/* Review header */}
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10 border-2 border-white shadow-sm">
              <AvatarImage src={review.reviewer?.avatar_url || undefined} />
              <AvatarFallback className="bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] text-white">
                {getInitials()}
              </AvatarFallback>
            </Avatar>
            <div>
              <p className="font-medium text-slate-900">
                {review.reviewer?.full_name || "Supervisor"}
              </p>
              <p className="text-sm text-slate-500">{formattedDate}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <RatingStarDisplay rating={review.overall_rating} size="sm" showNumber={false} />
            <Badge className={cn("ml-2", getRatingBadgeColor(review.overall_rating))}>
              {review.overall_rating.toFixed(1)}
            </Badge>
          </div>
        </div>

        {/* Project reference */}
        {review.project?.title && (
          <Badge variant="outline" className="bg-[#E6F4FF] text-[#4B9BFF] border-[#4B9BFF]/20 font-normal">
            Project: {review.project.title}
          </Badge>
        )}

        {/* Review text */}
        {review.review_text && (
          <div className="bg-slate-50/80 rounded-2xl p-4">
            <p className="text-sm leading-relaxed text-slate-700">
              &quot;{review.review_text}&quot;
            </p>
          </div>
        )}

        {/* Category ratings */}
        <div className="flex flex-wrap gap-3 pt-2">
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-teal-50">
            <span className="text-teal-700 font-medium text-sm">Quality</span>
            <div className="flex items-center gap-0.5">
              {Array.from({ length: 5 }, (_, i) => (
                <Star
                  key={i}
                  className={cn(
                    "w-3.5 h-3.5",
                    i < review.quality_rating
                      ? "fill-teal-500 text-teal-500"
                      : "text-slate-300"
                  )}
                />
              ))}
            </div>
          </div>
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-50">
            <span className="text-emerald-700 font-medium text-sm">Timeliness</span>
            <div className="flex items-center gap-0.5">
              {Array.from({ length: 5 }, (_, i) => (
                <Star
                  key={i}
                  className={cn(
                    "w-3.5 h-3.5",
                    i < review.timeliness_rating
                      ? "fill-emerald-500 text-emerald-500"
                      : "text-slate-300"
                  )}
                />
              ))}
            </div>
          </div>
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-amber-50">
            <span className="text-amber-700 font-medium text-sm">Communication</span>
            <div className="flex items-center gap-0.5">
              {Array.from({ length: 5 }, (_, i) => (
                <Star
                  key={i}
                  className={cn(
                    "w-3.5 h-3.5",
                    i < review.communication_rating
                      ? "fill-amber-500 text-amber-500"
                      : "text-slate-300"
                  )}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  )
}
