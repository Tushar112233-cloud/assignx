'use client'

import { motion } from 'framer-motion'
import {
  Briefcase,
  CheckCircle2,
  DollarSign,
  Star,
  TrendingUp,
  Clock,
  LucideIcon,
} from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { cn } from '@/lib/utils'
import type { DoerStats } from '@/types/database'

interface ScorecardProps {
  /** Doer stats */
  stats: DoerStats
  /** Loading state */
  isLoading?: boolean
  /** Additional class name */
  className?: string
}

/** Stat card configuration */
interface StatCardConfig {
  key: keyof DoerStats
  label: string
  icon: LucideIcon
  color: string
  bgColor: string
  accent: string
  format: (value: number) => string
}

/** Stat card configurations with premium blue theme */
const statConfigs: StatCardConfig[] = [
  {
    key: 'activeAssignments',
    label: 'Active Assignments',
    icon: Briefcase,
    color: 'text-blue-600',
    bgColor: 'bg-[#E3E9FF]',
    accent: 'from-blue-500/60 to-indigo-500/20',
    format: (v) => v.toString(),
  },
  {
    key: 'completedProjects',
    label: 'Completed Projects',
    icon: CheckCircle2,
    color: 'text-blue-700',
    bgColor: 'bg-[#E6F4FF]',
    accent: 'from-blue-600/60 to-sky-500/20',
    format: (v) => v.toString(),
  },
  {
    key: 'totalEarnings',
    label: 'Total Earnings',
    icon: DollarSign,
    color: 'text-indigo-600',
    bgColor: 'bg-[#E3E9FF]',
    accent: 'from-indigo-500/60 to-blue-500/20',
    format: (v) => `₹${v.toLocaleString()}`,
  },
  {
    key: 'averageRating',
    label: 'Average Rating',
    icon: Star,
    color: 'text-amber-600',
    bgColor: 'bg-amber-50',
    accent: 'from-amber-500/60 to-yellow-500/20',
    format: (v) => v.toFixed(1),
  },
  {
    key: 'successRate',
    label: 'Success Rate',
    icon: TrendingUp,
    color: 'text-blue-600',
    bgColor: 'bg-[#E6F4FF]',
    accent: 'from-blue-500/60 to-cyan-500/20',
    format: (v) => `${v}%`,
  },
  {
    key: 'onTimeDeliveryRate',
    label: 'On-Time Delivery',
    icon: Clock,
    color: 'text-indigo-600',
    bgColor: 'bg-[#E3E9FF]',
    accent: 'from-indigo-500/60 to-blue-500/20',
    format: (v) => `${v}%`,
  },
]

/** Animation variants */
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
  hidden: { opacity: 0, y: 20, scale: 0.98 },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      type: 'spring' as const,
      stiffness: 110,
      damping: 18,
    },
  },
}

/**
 * Scorecard component
 * Displays key stats in a grid of cards
 */
export function Scorecard({ stats, isLoading, className }: ScorecardProps) {
  if (isLoading) {
    return (
      <div className={cn('grid gap-4 grid-cols-2 md:grid-cols-3 xl:grid-cols-6', className)}>
        {[...Array(6)].map((_, i) => (
          <Card key={i} className="animate-pulse overflow-hidden border-none bg-white/85 shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
            <CardContent className="p-5">
              <div className="flex items-start justify-between">
                <div className="space-y-2 flex-1">
                  <div className="h-3 w-20 bg-[hsl(var(--skeleton-base))] rounded" />
                  <div className="h-7 w-16 bg-[hsl(var(--skeleton-base))] rounded" />
                </div>
                <div className="h-11 w-11 rounded-2xl bg-[hsl(var(--skeleton-base))]" />
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className={cn('grid gap-4 grid-cols-2 md:grid-cols-3 xl:grid-cols-6', className)}
    >
      {statConfigs.map((config) => {
        const Icon = config.icon
        const value = stats[config.key]

        return (
          <motion.div key={config.key} variants={itemVariants}>
            <Card className="w-full max-w-full relative overflow-hidden border-none bg-white/85 shadow-[0_12px_28px_rgba(30,58,138,0.08)] transition-all hover:shadow-[0_16px_35px_rgba(30,58,138,0.12)]">
              <CardContent className="p-6">
                <div className="flex items-start justify-between gap-3">
                  <div className="space-y-1 flex-1 min-w-0">
                    <p className="text-xs font-semibold uppercase tracking-wide text-slate-500 truncate">{config.label}</p>
                    <p className="text-2xl font-semibold text-slate-900 truncate">
                      {config.format(value)}
                    </p>
                  </div>
                  <div className={cn('h-11 w-11 flex-shrink-0 rounded-2xl flex items-center justify-center', config.bgColor)}>
                    <Icon className={cn('h-5 w-5', config.color)} />
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )
      })}
    </motion.div>
  )
}

/**
 * Compact Scorecard variant
 * For use in smaller spaces
 */
interface CompactScorecardProps {
  stats: DoerStats
  className?: string
}

export function CompactScorecard({ stats, className }: CompactScorecardProps) {
  const primaryStats = [
    { label: 'Active', value: stats.activeAssignments, color: 'text-blue-600' },
    { label: 'Completed', value: stats.completedProjects, color: 'text-blue-700' },
    { label: 'Rating', value: stats.averageRating.toFixed(1), color: 'text-amber-600' },
    { label: 'Earnings', value: `₹${stats.totalEarnings.toLocaleString()}`, color: 'text-indigo-600' },
  ]

  return (
    <div className={cn('flex items-center gap-4 flex-wrap', className)}>
      {primaryStats.map((stat) => (
        <div key={stat.label} className="text-center">
          <p className={cn('text-lg font-semibold', stat.color)}>{stat.value}</p>
          <p className="text-xs text-slate-500">{stat.label}</p>
        </div>
      ))}
    </div>
  )
}
