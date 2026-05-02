'use client'

import { useMemo } from 'react'
import { motion } from 'framer-motion'
import {
  TrendingUp,
  TrendingDown,
  Target,
  Clock,
  DollarSign,
  CheckCircle2,
  Layers,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { Card, CardContent } from '@/components/ui/card'
import type { Project } from '@/types/project.types'

/**
 * Props for the AdvancedStatsGrid component
 */
interface AdvancedStatsGridProps {
  /** All projects (active, review, completed) */
  projects: Project[]
  /** Previous period projects for trend calculation */
  previousPeriodProjects?: Project[]
  /** Custom class name */
  className?: string
}

/**
 * Individual stat card props
 */
interface StatCardProps {
  title: string
  value: string | number
  trend?: {
    value: number
    isPositive: boolean
  }
  icon: React.ElementType
  iconBg: string
  iconColor: string
  chart?: React.ReactNode
  delay?: number
}

/**
 * Glassmorphism stat card with hover animation
 */
const StatCard = ({
  title,
  value,
  trend,
  icon: Icon,
  iconBg,
  iconColor,
  chart,
  delay = 0,
}: StatCardProps) => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay }}
      whileHover={{ y: -4, transition: { duration: 0.2 } }}
    >
      <Card className="group relative overflow-hidden border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] backdrop-blur-sm transition-shadow hover:shadow-[0_20px_45px_rgba(30,58,138,0.12)]">
        <CardContent className="p-5">
          <div className="flex items-start justify-between">
            <div className="flex-1 space-y-1">
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
                {title}
              </p>
              <p className="text-3xl font-bold text-slate-900">{value}</p>
              {trend && (
                <div className="flex items-center gap-1">
                  {trend.isPositive ? (
                    <TrendingUp className="h-3.5 w-3.5 text-emerald-500" />
                  ) : (
                    <TrendingDown className="h-3.5 w-3.5 text-rose-500" />
                  )}
                  <span
                    className={cn(
                      'text-xs font-semibold',
                      trend.isPositive ? 'text-emerald-600' : 'text-rose-600'
                    )}
                  >
                    {trend.isPositive ? '+' : ''}
                    {trend.value}% from last week
                  </span>
                </div>
              )}
            </div>
            <div
              className={cn(
                'flex h-12 w-12 items-center justify-center rounded-2xl transition-transform group-hover:scale-110',
                iconBg
              )}
            >
              <Icon className={cn('h-6 w-6', iconColor)} />
            </div>
          </div>
          {chart && <div className="mt-4">{chart}</div>}
        </CardContent>
      </Card>
    </motion.div>
  )
}

/**
 * Circular progress indicator (donut chart)
 */
interface CircularProgressProps {
  percent: number
  size?: number
  strokeWidth?: number
  color: string
  bgColor?: string
}

const CircularProgress = ({
  percent,
  size = 60,
  strokeWidth = 6,
  color,
  bgColor = '#E3E9FF',
}: CircularProgressProps) => {
  const radius = (size - strokeWidth) / 2
  const circumference = radius * 2 * Math.PI
  const offset = circumference - (percent / 100) * circumference

  return (
    <div className="flex items-center gap-3">
      <div className="relative" style={{ width: size, height: size }}>
        <svg className="rotate-[-90deg]" width={size} height={size}>
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            stroke={bgColor}
            strokeWidth={strokeWidth}
            fill="none"
          />
          <motion.circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            stroke={color}
            strokeWidth={strokeWidth}
            fill="none"
            strokeLinecap="round"
            initial={{ strokeDashoffset: circumference }}
            animate={{ strokeDashoffset: offset }}
            transition={{ duration: 1, ease: 'easeInOut' }}
            style={{
              strokeDasharray: circumference,
            }}
          />
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <span className="text-sm font-bold text-slate-900">{Math.round(percent)}%</span>
        </div>
      </div>
      <div className="text-xs text-slate-500">Success rate</div>
    </div>
  )
}

/**
 * Mini bar chart for average completion time
 */
interface MiniBarChartProps {
  data: number[]
}

const MiniBarChart = ({ data }: MiniBarChartProps) => {
  const max = Math.max(...data, 1)

  return (
    <div className="flex items-end gap-1.5" style={{ height: 40 }}>
      {data.map((value, index) => {
        const height = (value / max) * 100
        return (
          <motion.div
            key={index}
            initial={{ height: 0 }}
            animate={{ height: `${height}%` }}
            transition={{ duration: 0.5, delay: index * 0.1 }}
            className="flex-1 rounded-t bg-gradient-to-t from-[#5A7CFF] to-[#49C5FF]"
            style={{ minHeight: '4px' }}
          />
        )
      })}
    </div>
  )
}

/**
 * Advanced Stats Grid Component
 *
 * Displays a responsive 5-column grid of glassmorphism stat cards with animations.
 * Shows key metrics: pipeline value, active projects, avg completion time,
 * weekly earnings, and success rate.
 *
 * @example
 * ```tsx
 * <AdvancedStatsGrid
 *   projects={allProjects}
 *   previousPeriodProjects={lastWeekProjects}
 * />
 * ```
 */
export const AdvancedStatsGrid = ({
  projects,
  previousPeriodProjects = [],
  className,
}: AdvancedStatsGridProps) => {
  /**
   * Calculate total pipeline value
   */
  const totalPipelineValue = useMemo(() => {
    return projects.reduce((sum, p) => sum + (p.doer_payout || p.price || 0), 0)
  }, [projects])

  /**
   * Calculate active projects count
   */
  const activeCount = useMemo(() => {
    return projects.filter(
      (p) => p.status === 'assigned' || p.status === 'in_progress'
    ).length
  }, [projects])

  /**
   * Calculate average completion time in days
   */
  const avgCompletionTime = useMemo(() => {
    const completedProjects = projects.filter((p) => p.completed_at && p.doer_assigned_at)

    if (completedProjects.length === 0) return 0

    const totalDays = completedProjects.reduce((sum, p) => {
      const start = new Date(p.doer_assigned_at!).getTime()
      const end = new Date(p.completed_at!).getTime()
      const days = Math.max(1, Math.ceil((end - start) / (1000 * 60 * 60 * 24)))
      return sum + days
    }, 0)

    return Math.round(totalDays / completedProjects.length)
  }, [projects])

  /**
   * Calculate this week's earnings
   */
  const weeklyEarnings = useMemo(() => {
    const oneWeekAgo = new Date()
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)

    return projects
      .filter((p) => {
        if (!p.completed_at) return false
        const completedDate = new Date(p.completed_at)
        return completedDate >= oneWeekAgo
      })
      .reduce((sum, p) => sum + (p.doer_payout || 0), 0)
  }, [projects])

  /**
   * Calculate success rate (completed vs total assigned)
   */
  const successRate = useMemo(() => {
    const assignedProjects = projects.filter(
      (p) =>
        p.status === 'assigned' ||
        p.status === 'in_progress' ||
        p.status === 'completed' ||
        p.status === 'delivered'
    )

    if (assignedProjects.length === 0) return 0

    const completedProjects = projects.filter(
      (p) => p.status === 'completed' || p.status === 'delivered'
    )

    return (completedProjects.length / assignedProjects.length) * 100
  }, [projects])

  /**
   * Calculate trend percentages
   */
  const calculateTrend = (current: number, previous: number) => {
    if (previous === 0) return { value: 0, isPositive: true }
    const change = ((current - previous) / previous) * 100
    return {
      value: Math.abs(Math.round(change)),
      isPositive: change >= 0,
    }
  }

  // Previous period metrics (simplified for demo)
  const prevPipelineValue = useMemo(() => {
    return previousPeriodProjects.reduce((sum, p) => sum + (p.doer_payout || p.price || 0), 0)
  }, [previousPeriodProjects])

  const prevActiveCount = useMemo(() => {
    return previousPeriodProjects.filter(
      (p) => p.status === 'assigned' || p.status === 'in_progress'
    ).length
  }, [previousPeriodProjects])

  // Format currency
  const formatCurrency = (value: number) => `₹${value.toLocaleString('en-IN')}`

  // Mock data for completion time chart (last 7 days)
  const completionTimeData = [5, 4, 6, 3, 5, 4, avgCompletionTime]

  return (
    <div className={cn('grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5', className)}>
      <StatCard
        title="Total Pipeline Value"
        value={formatCurrency(totalPipelineValue)}
        trend={calculateTrend(totalPipelineValue, prevPipelineValue)}
        icon={Layers}
        iconBg="bg-[#E3E9FF]"
        iconColor="text-[#4F6CF7]"
        delay={0}
      />

      <StatCard
        title="Active Projects"
        value={activeCount}
        trend={calculateTrend(activeCount, prevActiveCount)}
        icon={Target}
        iconBg="bg-[#FFE7E1]"
        iconColor="text-[#FF8B6A]"
        chart={
          <CircularProgress
            percent={activeCount > 0 ? Math.min(100, (activeCount / 10) * 100) : 0}
            color="#FF8B6A"
          />
        }
        delay={0.1}
      />

      <StatCard
        title="Avg Completion Time"
        value={`${avgCompletionTime} days`}
        icon={Clock}
        iconBg="bg-[#E6F4FF]"
        iconColor="text-[#4B9BFF]"
        chart={<MiniBarChart data={completionTimeData} />}
        delay={0.2}
      />

      <StatCard
        title="This Week's Earnings"
        value={formatCurrency(weeklyEarnings)}
        trend={{ value: 12, isPositive: true }}
        icon={DollarSign}
        iconBg="bg-[#E9FAFA]"
        iconColor="text-[#43D1C5]"
        delay={0.3}
      />

      <StatCard
        title="Success Rate"
        value={`${Math.round(successRate)}%`}
        icon={CheckCircle2}
        iconBg="bg-[#EEF2FF]"
        iconColor="text-[#5B7CFF]"
        chart={<CircularProgress percent={successRate} color="#5B7CFF" />}
        delay={0.4}
      />
    </div>
  )
}
