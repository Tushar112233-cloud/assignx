'use client'

import { useMemo } from 'react'
import { motion } from 'framer-motion'
import { TrendingUp, Calendar } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Card, CardContent } from '@/components/ui/card'
import type { Project } from '@/types/project.types'

/**
 * Props for the VelocityChart component
 */
interface VelocityChartProps {
  /** All projects to analyze velocity */
  projects: Project[]
  /** Number of days to show in the chart (default: 7) */
  days?: number
  /** Custom class name */
  className?: string
}

/**
 * Data point for velocity tracking
 */
interface VelocityDataPoint {
  date: string
  completed: number
  inProgress: number
  label: string
}

/**
 * Chart bar component with gradient fill
 */
interface ChartBarProps {
  completed: number
  inProgress: number
  maxValue: number
  label: string
  index: number
  isToday?: boolean
}

const ChartBar = ({ completed, inProgress, maxValue, label, index, isToday }: ChartBarProps) => {
  const total = completed + inProgress
  const completedHeight = maxValue > 0 ? (completed / maxValue) * 100 : 0
  const inProgressHeight = maxValue > 0 ? (inProgress / maxValue) * 100 : 0

  return (
    <div className="flex flex-1 flex-col items-center gap-2">
      <div className="relative flex h-48 w-full flex-col items-center justify-end gap-0.5">
        {/* Completed bar */}
        {completed > 0 && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: `${completedHeight}%`, opacity: 1 }}
            transition={{ duration: 0.6, delay: index * 0.1 }}
            className="relative w-full rounded-t-lg bg-gradient-to-t from-[#5A7CFF] to-[#49C5FF] shadow-[0_4px_12px_rgba(90,124,255,0.3)]"
            style={{ minHeight: completed > 0 ? '8px' : '0' }}
          >
            <div className="absolute -top-6 left-1/2 -translate-x-1/2 whitespace-nowrap rounded bg-slate-900 px-2 py-1 text-xs font-semibold text-white opacity-0 transition-opacity group-hover:opacity-100">
              {completed}
            </div>
          </motion.div>
        )}

        {/* In Progress bar */}
        {inProgress > 0 && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: `${inProgressHeight}%`, opacity: 1 }}
            transition={{ duration: 0.6, delay: index * 0.1 + 0.1 }}
            className="relative w-full rounded-t-lg bg-gradient-to-t from-[#FF9B7A]/60 to-[#FF8B6A]/60 shadow-[0_4px_12px_rgba(255,155,122,0.2)]"
            style={{ minHeight: inProgress > 0 ? '8px' : '0' }}
          >
            <div className="absolute -top-6 left-1/2 -translate-x-1/2 whitespace-nowrap rounded bg-slate-900 px-2 py-1 text-xs font-semibold text-white opacity-0 transition-opacity group-hover:opacity-100">
              {inProgress}
            </div>
          </motion.div>
        )}

        {/* Empty state indicator */}
        {total === 0 && (
          <div
            className="w-full rounded-t-lg bg-slate-100"
            style={{ height: '4px', minHeight: '4px' }}
          />
        )}
      </div>

      {/* Date label */}
      <div className="flex flex-col items-center">
        <span
          className={cn(
            'text-xs font-semibold',
            isToday ? 'text-[#4F6CF7]' : 'text-slate-600'
          )}
        >
          {label}
        </span>
        {isToday && (
          <span className="mt-0.5 rounded-full bg-[#E3E9FF] px-2 py-0.5 text-[10px] font-semibold text-[#4F6CF7]">
            Today
          </span>
        )}
      </div>
    </div>
  )
}

/**
 * Legend item component
 */
interface LegendItemProps {
  color: string
  label: string
  value: number
}

const LegendItem = ({ color, label, value }: LegendItemProps) => {
  return (
    <div className="flex items-center gap-2">
      <div className={cn('h-3 w-3 rounded', color)} />
      <span className="text-sm text-slate-600">{label}</span>
      <span className="ml-auto text-sm font-semibold text-slate-900">{value}</span>
    </div>
  )
}

/**
 * Velocity Chart Component
 *
 * Displays a stacked bar chart showing project completion velocity
 * over the specified time period. Shows completed projects and
 * projects in progress for each day.
 *
 * @example
 * ```tsx
 * <VelocityChart
 *   projects={allProjects}
 *   days={7}
 * />
 * ```
 */
export const VelocityChart = ({ projects, days = 7, className }: VelocityChartProps) => {
  /**
   * Generate velocity data for the last N days
   */
  const velocityData = useMemo<VelocityDataPoint[]>(() => {
    const data: VelocityDataPoint[] = []
    const today = new Date()

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(today)
      date.setDate(date.getDate() - i)
      date.setHours(0, 0, 0, 0)

      const nextDate = new Date(date)
      nextDate.setDate(nextDate.getDate() + 1)

      // Count completed projects on this day
      const completed = projects.filter((p) => {
        if (!p.completed_at) return false
        const completedDate = new Date(p.completed_at)
        return completedDate >= date && completedDate < nextDate
      }).length

      // Count projects in progress on this day
      const inProgress = projects.filter((p) => {
        if (p.status !== 'in_progress' && p.status !== 'assigned') return false
        const assignedDate = p.doer_assigned_at ? new Date(p.doer_assigned_at) : null
        if (!assignedDate) return false
        return assignedDate <= date
      }).length

      // Format label
      const label =
        i === 0
          ? 'Today'
          : i === 1
          ? 'Yesterday'
          : date.toLocaleDateString('en-US', { weekday: 'short' })

      data.push({
        date: date.toISOString(),
        completed,
        inProgress,
        label,
      })
    }

    return data
  }, [projects, days])

  /**
   * Calculate max value for scaling
   */
  const maxValue = useMemo(() => {
    const max = Math.max(...velocityData.map((d) => d.completed + d.inProgress), 1)
    return Math.ceil(max * 1.1) // Add 10% padding
  }, [velocityData])

  /**
   * Calculate total completed and in-progress
   */
  const totalCompleted = useMemo(() => {
    return velocityData.reduce((sum, d) => sum + d.completed, 0)
  }, [velocityData])

  const totalInProgress = useMemo(() => {
    return velocityData.reduce((sum, d) => sum + d.inProgress, 0)
  }, [velocityData])

  /**
   * Calculate velocity trend (comparing first half vs second half)
   */
  const velocityTrend = useMemo(() => {
    const midpoint = Math.floor(velocityData.length / 2)
    const firstHalf = velocityData.slice(0, midpoint)
    const secondHalf = velocityData.slice(midpoint)

    const firstHalfAvg =
      firstHalf.reduce((sum, d) => sum + d.completed, 0) / firstHalf.length || 0
    const secondHalfAvg =
      secondHalf.reduce((sum, d) => sum + d.completed, 0) / secondHalf.length || 0

    if (firstHalfAvg === 0) return 0
    return Math.round(((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100)
  }, [velocityData])

  return (
    <Card className={cn('border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]', className)}>
      <CardContent className="p-6">
        {/* Header */}
        <div className="mb-6 flex items-start justify-between">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#E3E9FF]">
                <TrendingUp className="h-5 w-5 text-[#4F6CF7]" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-slate-900">Project Velocity</h3>
                <p className="text-xs text-slate-500">Last {days} days completion trend</p>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-1.5 rounded-full bg-gradient-to-r from-[#EEF2FF] to-[#E9FAFA] px-3 py-1.5">
            <Calendar className="h-3.5 w-3.5 text-[#4F6CF7]" />
            <span className="text-xs font-semibold text-[#4F6CF7]">
              {velocityTrend >= 0 ? '+' : ''}
              {velocityTrend}%
            </span>
          </div>
        </div>

        {/* Chart */}
        <div className="group mb-6 flex items-end gap-2">
          {velocityData.map((dataPoint, index) => (
            <ChartBar
              key={dataPoint.date}
              completed={dataPoint.completed}
              inProgress={dataPoint.inProgress}
              maxValue={maxValue}
              label={dataPoint.label}
              index={index}
              isToday={index === velocityData.length - 1}
            />
          ))}
        </div>

        {/* Legend */}
        <div className="space-y-2 rounded-2xl bg-slate-50/80 p-4">
          <LegendItem
            color="bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF]"
            label="Completed"
            value={totalCompleted}
          />
          <LegendItem
            color="bg-gradient-to-r from-[#FF9B7A]/60 to-[#FF8B6A]/60"
            label="In Progress"
            value={totalInProgress}
          />
        </div>

        {/* Insights */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="mt-4 rounded-2xl border border-[#E3E9FF] bg-[#F3F5FF] p-3"
        >
          <p className="text-xs text-slate-600">
            {velocityTrend >= 0 ? (
              <>
                <span className="font-semibold text-emerald-600">Great momentum!</span> Your
                completion rate is up {velocityTrend}% compared to the previous period.
              </>
            ) : (
              <>
                <span className="font-semibold text-amber-600">Keep pushing!</span> Your velocity
                is down {Math.abs(velocityTrend)}%. Consider reviewing your workload.
              </>
            )}
          </p>
        </motion.div>
      </CardContent>
    </Card>
  )
}
