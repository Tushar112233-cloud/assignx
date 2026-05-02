'use client'

/**
 * CategoryRatingCard Component
 * Displays a single category rating with icon, rating number, stars, and description.
 * Features color-coded backgrounds and smooth animations.
 * @module components/reviews/CategoryRatingCard
 */

import { motion } from 'framer-motion'
import { Star, LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'

/**
 * Color variant type for category cards
 */
export type CategoryColor = 'blue' | 'cyan' | 'orange'

/**
 * CategoryRatingCard component props
 */
export interface CategoryRatingCardProps {
  /** Category name (e.g., "Quality", "Timeliness", "Communication") */
  category: string
  /** Rating value (0-5) */
  rating: number
  /** Description text for the category */
  description: string
  /** Lucide icon component */
  icon: LucideIcon
  /** Color variant for the card */
  color: CategoryColor
  /** Optional additional class name */
  className?: string
}

/**
 * Get color classes based on the color variant
 * @param color - Color variant
 * @returns Object with background and text color classes
 */
const getColorClasses = (color: CategoryColor) => {
  const colorMap = {
    blue: {
      iconBg: 'bg-[#E3E9FF]',
      iconText: 'text-[#4F6CF7]',
      ratingText: 'text-[#4F6CF7]',
    },
    cyan: {
      iconBg: 'bg-[#E6F4FF]',
      iconText: 'text-[#4B9BFF]',
      ratingText: 'text-[#4B9BFF]',
    },
    orange: {
      iconBg: 'bg-[#FFE7E1]',
      iconText: 'text-[#FF8B6A]',
      ratingText: 'text-[#FF8B6A]',
    },
  }
  return colorMap[color]
}

/**
 * Render rating stars with fill based on rating value
 * @param rating - Rating value (0-5)
 * @param color - Color variant
 */
const renderStars = (rating: number, color: CategoryColor) => {
  const colorClasses = getColorClasses(color)
  return (
    <div className="flex items-center justify-center gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={cn(
            'h-4 w-4 transition-colors',
            star <= Math.round(rating)
              ? `fill-current ${colorClasses.iconText}`
              : 'text-slate-300'
          )}
        />
      ))}
    </div>
  )
}

/** Animation variants for the card */
const cardVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
}

/**
 * CategoryRatingCard Component
 *
 * A card displaying a single category rating with:
 * - Icon at the top with color-coded background
 * - Large rating number
 * - Star display showing rating visually
 * - Descriptive text below
 *
 * @example
 * ```tsx
 * <CategoryRatingCard
 *   category="Quality"
 *   rating={4.8}
 *   description="Consistent high-quality deliverables"
 *   icon={Target}
 *   color="blue"
 * />
 * ```
 */
export function CategoryRatingCard({
  category,
  rating,
  description,
  icon: Icon,
  color,
  className,
}: CategoryRatingCardProps) {
  const colorClasses = getColorClasses(color)

  return (
    <motion.div
      variants={cardVariants}
      initial="hidden"
      animate="visible"
      className={cn(
        'flex flex-col items-center justify-start p-6',
        'rounded-2xl bg-white/85 border border-white/70',
        'shadow-[0_16px_35px_rgba(30,58,138,0.08)]',
        'hover:shadow-[0_20px_40px_rgba(30,58,138,0.12)] transition-all duration-300',
        className
      )}
    >
      {/* Icon */}
      <div
        className={cn(
          'flex h-14 w-14 items-center justify-center rounded-2xl mb-4',
          colorClasses.iconBg,
          colorClasses.iconText
        )}
      >
        <Icon className="h-7 w-7" />
      </div>

      {/* Category Name */}
      <h3 className="text-sm font-semibold text-slate-600 mb-2">{category}</h3>

      {/* Rating Number */}
      <div className="mb-3">
        <span
          className={cn(
            'text-4xl font-bold',
            colorClasses.ratingText
          )}
        >
          {rating.toFixed(1)}
        </span>
        <span className="text-lg text-slate-400 font-medium ml-1">/5</span>
      </div>

      {/* Star Display */}
      <div className="mb-4">{renderStars(rating, color)}</div>

      {/* Description */}
      <p className="text-xs text-slate-500 text-center leading-relaxed">
        {description}
      </p>
    </motion.div>
  )
}
