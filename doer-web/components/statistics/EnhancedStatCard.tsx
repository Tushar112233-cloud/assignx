'use client'

import { motion } from 'framer-motion'
import { TrendingUp, TrendingDown } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'

/**
 * Props for the EnhancedStatCard component.
 *
 * @interface EnhancedStatCardProps
 * @property {string} title - The title/label for the stat card
 * @property {string | number} value - The main value to display (large font)
 * @property {string} [subtitle] - Optional subtitle text below the value
 * @property {React.ElementType} icon - Icon component to display (from lucide-react)
 * @property {'teal' | 'blue' | 'purple' | 'orange'} variant - Color theme variant
 * @property {object} [trend] - Optional trend indicator
 * @property {number} trend.value - Numeric value of the trend (e.g., 12.5 for 12.5%)
 * @property {boolean} trend.isPositive - Whether the trend is positive (green up) or negative (red down)
 */
export interface EnhancedStatCardProps {
  title: string
  value: string | number
  subtitle?: string
  icon: React.ElementType
  variant: 'teal' | 'blue' | 'purple' | 'orange'
  trend?: {
    value: number
    isPositive: boolean
  }
}

/**
 * Gradient background and icon styling configurations for each color variant.
 * Matches the QuickStatCard pattern from dashboard-client.tsx
 */
const variantStyles = {
  teal: {
    gradient: 'bg-gradient-to-br from-[#F2F5FF] to-[#EAF6FF]',
    iconBg: 'bg-teal-100 dark:bg-teal-900/30',
    iconColor: 'text-teal-600 dark:text-teal-400',
  },
  blue: {
    gradient: 'bg-gradient-to-br from-[#F1F7FF] to-[#E8F9FF]',
    iconBg: 'bg-[#E6F4FF]',
    iconColor: 'text-[#4B9BFF]',
  },
  purple: {
    gradient: 'bg-gradient-to-br from-[#F5F3FF] to-[#EEEDFF]',
    iconBg: 'bg-[#ECE9FF]',
    iconColor: 'text-[#6B5BFF]',
  },
  orange: {
    gradient: 'bg-gradient-to-br from-[#FFF4F0] to-[#FFEFE9]',
    iconBg: 'bg-[#FFE7E1]',
    iconColor: 'text-[#FF8B6A]',
  },
}

/**
 * Enhanced statistic card component with gradient backgrounds, icons, and trend indicators.
 *
 * Features:
 * - 4 color variants with gradient backgrounds (teal, blue, purple, orange)
 * - Icon with colored circular background (11x11, rounded-2xl)
 * - Large value display (text-2xl font-semibold)
 * - Optional subtitle text
 * - Optional trend badge with up/down indicator
 * - Smooth hover animation (translate-y and shadow increase)
 * - Matches QuickStatCard styling from dashboard
 *
 * @component
 * @example
 * ```tsx
 * <EnhancedStatCard
 *   title="Total Earnings"
 *   value="₹12,450"
 *   subtitle="This month"
 *   icon={IndianRupee}
 *   variant="teal"
 *   trend={{ value: 12.5, isPositive: true }}
 * />
 * ```
 */
export function EnhancedStatCard({
  title,
  value,
  subtitle,
  icon: Icon,
  variant,
  trend,
}: EnhancedStatCardProps) {
  const styles = variantStyles[variant]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      whileHover={{ y: -2 }}
      className="h-full"
    >
      <Card
        className={cn(
          'group relative overflow-hidden border-0',
          'rounded-2xl bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]',
          'transition-all duration-300',
          'hover:shadow-[0_20px_40px_rgba(30,58,138,0.12)]',
          styles.gradient
        )}
      >
        <CardContent className="p-5 sm:p-6">
          <div className="flex items-start justify-between">
            <div className="space-y-3 flex-1">
              {/* Title */}
              <p className="text-sm font-medium text-slate-600">
                {title}
              </p>

              {/* Main Value */}
              <div className="flex items-baseline gap-2 flex-wrap">
                <p className="text-2xl font-semibold text-slate-900">
                  {value}
                </p>

                {/* Trend Badge */}
                {trend && (
                  <Badge
                    variant="secondary"
                    className={cn(
                      'rounded-full border-0 text-xs font-medium px-2 py-0.5',
                      trend.isPositive
                        ? 'bg-emerald-100 text-emerald-700'
                        : 'bg-red-100 text-red-700'
                    )}
                  >
                    {trend.isPositive ? (
                      <TrendingUp className="mr-1 inline h-3 w-3" />
                    ) : (
                      <TrendingDown className="mr-1 inline h-3 w-3" />
                    )}
                    {Math.abs(trend.value)}%
                  </Badge>
                )}
              </div>

              {/* Subtitle */}
              {subtitle && (
                <p className="text-xs text-slate-500">
                  {subtitle}
                </p>
              )}
            </div>

            {/* Icon */}
            <div
              className={cn(
                'flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl',
                'transition-transform duration-300 group-hover:scale-110',
                styles.iconBg
              )}
            >
              <Icon className={cn('h-5 w-5', styles.iconColor)} />
            </div>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  )
}
