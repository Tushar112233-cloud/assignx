"use client"

import { Star } from "lucide-react"

/**
 * Size variants for the star rating display component
 */
type RatingSize = "sm" | "md" | "lg"

/**
 * Visual variants for the rating display
 */
type RatingVariant = "default" | "gradient"

/**
 * Props for the RatingStarDisplay component
 */
interface RatingStarDisplayProps {
  /**
   * The rating value (0-5)
   */
  rating: number
  /**
   * Size variant of the star display
   * @default "md"
   */
  size?: RatingSize
  /**
   * Whether to show the numerical rating next to stars
   * @default true
   */
  showNumber?: boolean
  /**
   * Visual style variant
   * @default "default"
   */
  variant?: RatingVariant
}

/**
 * Configuration for different size variants
 */
const sizeConfig = {
  sm: {
    starSize: "w-4 h-4",
    textSize: "text-sm",
    gap: "gap-1",
  },
  md: {
    starSize: "w-5 h-5",
    textSize: "text-base",
    gap: "gap-1.5",
  },
  lg: {
    starSize: "w-7 h-7",
    textSize: "text-2xl",
    gap: "gap-2",
  },
} as const

/**
 * RatingStarDisplay Component
 *
 * A reusable star rating display component that shows a visual representation
 * of a rating value using filled and empty stars, with optional numerical display.
 *
 * Features:
 * - Multiple size variants (sm, md, lg)
 * - Visual variants (default, gradient)
 * - Partial star support for decimal ratings
 * - Optional numerical rating display
 *
 * @example
 * ```tsx
 * <RatingStarDisplay rating={4.5} size="lg" variant="gradient" />
 * ```
 */
export function RatingStarDisplay({
  rating,
  size = "md",
  showNumber = true,
  variant = "default",
}: RatingStarDisplayProps) {
  const config = sizeConfig[size]
  const clampedRating = Math.max(0, Math.min(5, rating))
  const fullStars = Math.floor(clampedRating)
  const hasPartialStar = clampedRating % 1 !== 0
  const emptyStars = 5 - Math.ceil(clampedRating)

  /**
   * Renders a single star with specified fill state
   */
  const renderStar = (index: number, filled: boolean, partial?: number) => {
    const key = `star-${index}`

    if (partial) {
      return (
        <div key={key} className="relative">
          <Star className={`${config.starSize} text-slate-300`} />
          <div
            className="absolute inset-0 overflow-hidden"
            style={{ width: `${partial * 100}%` }}
          >
            <Star className={`${config.starSize} fill-amber-400 text-amber-400`} />
          </div>
        </div>
      )
    }

    return (
      <Star
        key={key}
        className={`${config.starSize} ${
          filled ? "fill-amber-400 text-amber-400" : "text-slate-300"
        }`}
      />
    )
  }

  const ratingNumberClass =
    variant === "gradient"
      ? "bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] bg-clip-text text-transparent font-bold"
      : "text-slate-900 font-semibold"

  return (
    <div className={`flex items-center ${config.gap}`}>
      {/* Render filled stars */}
      {Array.from({ length: fullStars }, (_, i) => renderStar(i, true))}

      {/* Render partial star if applicable */}
      {hasPartialStar && renderStar(fullStars, false, clampedRating % 1)}

      {/* Render empty stars */}
      {Array.from({ length: emptyStars }, (_, i) =>
        renderStar(fullStars + (hasPartialStar ? 1 : 0) + i, false)
      )}

      {/* Numerical rating display */}
      {showNumber && (
        <span className={`${config.textSize} ${ratingNumberClass}`}>
          {clampedRating.toFixed(1)}
        </span>
      )}
    </div>
  )
}
