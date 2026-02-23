"use client"

import { motion } from "framer-motion"
import { Award, Star, TrendingUp, Target, MessageSquare, Trophy } from "lucide-react"
import { cn } from "@/lib/utils"

/**
 * Achievement milestone data structure
 */
export interface Achievement {
  /** Unique identifier */
  id: string
  /** Achievement title */
  title: string
  /** Achievement description */
  description: string
  /** Icon component type */
  icon: "star" | "trophy" | "target" | "trending" | "message" | "award"
  /** Progress percentage (0-100) */
  progress: number
  /** Is achievement completed */
  isCompleted: boolean
  /** Color theme */
  color: "blue" | "amber" | "emerald" | "purple" | "teal"
}

/**
 * Props for AchievementCards component
 */
interface AchievementCardsProps {
  /**
   * Total number of reviews received
   */
  totalReviews: number
  /**
   * Average overall rating (0-5)
   */
  averageRating: number
  /**
   * Number of 5-star reviews
   */
  fiveStarCount: number
  /**
   * Additional CSS classes
   */
  className?: string
}

/**
 * Get icon component based on icon type
 */
const getIconComponent = (iconType: Achievement["icon"]) => {
  const iconMap = {
    star: Star,
    trophy: Trophy,
    target: Target,
    trending: TrendingUp,
    message: MessageSquare,
    award: Award,
  }
  return iconMap[iconType] || Award
}

/**
 * Get color classes based on color theme
 */
const getColorClasses = (color: Achievement["color"]) => {
  const colorMap = {
    blue: {
      bg: "bg-[#E6F4FF]",
      icon: "text-[#4B9BFF]",
      progress: "bg-[#4B9BFF]",
      badge: "bg-[#4B9BFF] text-white",
    },
    amber: {
      bg: "bg-amber-50",
      icon: "text-amber-600",
      progress: "bg-amber-500",
      badge: "bg-amber-500 text-white",
    },
    emerald: {
      bg: "bg-emerald-50",
      icon: "text-emerald-600",
      progress: "bg-emerald-500",
      badge: "bg-emerald-500 text-white",
    },
    purple: {
      bg: "bg-purple-50",
      icon: "text-purple-600",
      progress: "bg-purple-500",
      badge: "bg-purple-500 text-white",
    },
    teal: {
      bg: "bg-teal-50",
      icon: "text-teal-600",
      progress: "bg-teal-500",
      badge: "bg-teal-500 text-white",
    },
  }
  return colorMap[color]
}

/**
 * Calculate achievements based on review metrics
 */
const calculateAchievements = (
  totalReviews: number,
  averageRating: number,
  fiveStarCount: number
): Achievement[] => {
  const fiveStarPercentage = totalReviews > 0 ? (fiveStarCount / totalReviews) * 100 : 0

  return [
    {
      id: "first-review",
      title: "First Review",
      description: "Received your first review",
      icon: "star",
      progress: totalReviews >= 1 ? 100 : 0,
      isCompleted: totalReviews >= 1,
      color: "amber",
    },
    {
      id: "ten-reviews",
      title: "10 Reviews",
      description: "Collected 10 reviews",
      icon: "message",
      progress: Math.min((totalReviews / 10) * 100, 100),
      isCompleted: totalReviews >= 10,
      color: "blue",
    },
    {
      id: "fifty-reviews",
      title: "50 Reviews",
      description: "Reached 50 reviews milestone",
      icon: "trophy",
      progress: Math.min((totalReviews / 50) * 100, 100),
      isCompleted: totalReviews >= 50,
      color: "purple",
    },
    {
      id: "high-performer",
      title: "High Performer",
      description: "Maintain 4.5+ average rating",
      icon: "trending",
      progress: Math.min((averageRating / 4.5) * 100, 100),
      isCompleted: averageRating >= 4.5,
      color: "emerald",
    },
    {
      id: "excellence-master",
      title: "Excellence Master",
      description: "80% of reviews are 5 stars",
      icon: "target",
      progress: Math.min((fiveStarPercentage / 80) * 100, 100),
      isCompleted: fiveStarPercentage >= 80,
      color: "teal",
    },
    {
      id: "perfect-rating",
      title: "Perfect Rating",
      description: "Achieve 5.0 average rating",
      icon: "award",
      progress: Math.min((averageRating / 5.0) * 100, 100),
      isCompleted: averageRating === 5.0,
      color: "amber",
    },
  ]
}

/**
 * AchievementCards Component
 *
 * Displays a grid of achievement cards showing milestones and progress
 * based on review performance metrics.
 *
 * Features:
 * - Auto-calculated achievements from review data
 * - Progress bars for incomplete achievements
 * - Completion badges for achieved milestones
 * - Color-coded icon themes
 * - Smooth animations on mount
 * - Responsive grid layout (1-3 columns)
 * - Hover effects
 *
 * @example
 * ```tsx
 * <AchievementCards
 *   totalReviews={127}
 *   averageRating={4.8}
 *   fiveStarCount={98}
 * />
 * ```
 */
export function AchievementCards({
  totalReviews,
  averageRating,
  fiveStarCount,
  className,
}: AchievementCardsProps) {
  const achievements = calculateAchievements(totalReviews, averageRating, fiveStarCount)

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.08,
      },
    },
  }

  const cardVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 },
  }

  return (
    <div className={cn("space-y-4", className)}>
      {/* Section Header */}
      <div>
        <h2 className="text-2xl font-bold text-slate-900 mb-2">Achievements</h2>
        <p className="text-sm text-slate-500">
          Unlock milestones by delivering exceptional work
        </p>
      </div>

      {/* Achievement Grid */}
      <motion.div
        className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {achievements.map((achievement) => {
          const Icon = getIconComponent(achievement.icon)
          const colors = getColorClasses(achievement.color)

          return (
            <motion.div
              key={achievement.id}
              variants={cardVariants}
              className={cn(
                "relative overflow-hidden rounded-2xl bg-white/85 border border-white/70",
                "shadow-[0_10px_22px_rgba(30,58,138,0.08)] p-5",
                "transition-all duration-300",
                "hover:-translate-y-0.5 hover:shadow-[0_16px_35px_rgba(30,58,138,0.12)]",
                achievement.isCompleted && "ring-2 ring-offset-2 ring-offset-white/50",
                achievement.isCompleted &&
                  achievement.color === "blue" &&
                  "ring-[#4B9BFF]/50",
                achievement.isCompleted &&
                  achievement.color === "amber" &&
                  "ring-amber-400/50",
                achievement.isCompleted &&
                  achievement.color === "emerald" &&
                  "ring-emerald-400/50",
                achievement.isCompleted &&
                  achievement.color === "purple" &&
                  "ring-purple-400/50",
                achievement.isCompleted && achievement.color === "teal" && "ring-teal-400/50"
              )}
            >
              {/* Completion Badge */}
              {achievement.isCompleted && (
                <div className="absolute top-3 right-3">
                  <div
                    className={cn(
                      "flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold",
                      colors.badge
                    )}
                  >
                    <Trophy className="w-3 h-3" />
                    <span>Unlocked</span>
                  </div>
                </div>
              )}

              {/* Icon */}
              <div className={cn("w-12 h-12 rounded-xl flex items-center justify-center mb-4", colors.bg)}>
                <Icon className={cn("w-6 h-6", colors.icon)} />
              </div>

              {/* Content */}
              <div className="space-y-2">
                <h3 className="text-base font-semibold text-slate-900">{achievement.title}</h3>
                <p className="text-sm text-slate-500 leading-relaxed">
                  {achievement.description}
                </p>

                {/* Progress Bar */}
                {!achievement.isCompleted && (
                  <div className="space-y-1 pt-2">
                    <div className="flex items-center justify-between text-xs">
                      <span className="font-medium text-slate-600">Progress</span>
                      <span className={cn("font-bold", colors.icon)}>
                        {Math.round(achievement.progress)}%
                      </span>
                    </div>
                    <div className="h-2 rounded-full bg-slate-100 overflow-hidden">
                      <motion.div
                        className={cn("h-full rounded-full", colors.progress)}
                        initial={{ width: 0 }}
                        animate={{ width: `${achievement.progress}%` }}
                        transition={{ duration: 1, ease: "easeOut", delay: 0.2 }}
                      />
                    </div>
                  </div>
                )}
              </div>
            </motion.div>
          )
        })}
      </motion.div>
    </div>
  )
}
