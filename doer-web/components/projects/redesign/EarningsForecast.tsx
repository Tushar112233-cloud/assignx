'use client'

import { TrendingUp, DollarSign } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { LineChart, Line, ResponsiveContainer, Tooltip, XAxis } from 'recharts'
import type { Project } from '@/types/database'
import { motion } from 'framer-motion'

/**
 * Props for EarningsForecast component
 */
export interface EarningsForecastProps {
  /** Completed projects for historical data */
  completedProjects: Project[]
  /** Active projects for pending earnings */
  activeProjects: Project[]
  /** Projects under review */
  reviewProjects: Project[]
}

/**
 * Data point for earnings chart
 */
interface EarningsDataPoint {
  label: string
  value: number
}

/**
 * Calculate weekly earnings trend from completed projects
 */
function calculateWeeklyTrend(completedProjects: Project[]): EarningsDataPoint[] {
  const now = new Date()
  const weeksData: EarningsDataPoint[] = []

  // Generate last 6 weeks of data
  for (let i = 5; i >= 0; i--) {
    const weekStart = new Date(now)
    weekStart.setDate(weekStart.getDate() - (i * 7 + 7))
    const weekEnd = new Date(now)
    weekEnd.setDate(weekEnd.getDate() - i * 7)

    const weekEarnings = completedProjects
      .filter((p) => {
        if (!p.completed_at) return false
        const completedDate = new Date(p.completed_at)
        return completedDate >= weekStart && completedDate < weekEnd
      })
      .reduce((sum, p) => sum + (p.doer_payout || 0), 0)

    // Format label
    const label = i === 0 ? 'This Week' : `${i}w ago`
    weeksData.push({ label, value: weekEarnings })
  }

  return weeksData
}

/**
 * Custom tooltip for chart
 */
function CustomTooltip({ active, payload }: any) {
  if (active && payload && payload.length) {
    return (
      <div className="rounded-xl border border-white/70 bg-white/95 p-2 shadow-[0_8px_16px_rgba(30,58,138,0.12)]">
        <p className="text-xs font-semibold text-slate-900">
          ₹{payload[0].value.toLocaleString('en-IN')}
        </p>
        <p className="text-xs text-slate-500">{payload[0].payload.label}</p>
      </div>
    )
  }
  return null
}

/**
 * Earnings Forecast Component
 *
 * Displays a line chart showing earnings trend over the past 6 weeks.
 * Includes total earnings, pending earnings, and growth percentage.
 * Uses Recharts for responsive data visualization.
 *
 * @component
 * @example
 * ```tsx
 * <EarningsForecast
 *   completedProjects={completedProjects}
 *   activeProjects={activeProjects}
 *   reviewProjects={reviewProjects}
 * />
 * ```
 */
export function EarningsForecast({
  completedProjects,
  activeProjects,
  reviewProjects,
}: EarningsForecastProps) {
  const weeklyData = calculateWeeklyTrend(completedProjects)

  const totalEarnings = completedProjects.reduce(
    (sum, p) => sum + (p.doer_payout || 0),
    0
  )

  const pendingEarnings = [...activeProjects, ...reviewProjects].reduce(
    (sum, p) => sum + (p.doer_payout || 0),
    0
  )

  // Calculate growth from previous week
  const thisWeek = weeklyData[weeklyData.length - 1]?.value || 0
  const lastWeek = weeklyData[weeklyData.length - 2]?.value || 0
  const growthPercent = lastWeek > 0 ? ((thisWeek - lastWeek) / lastWeek) * 100 : 0
  const isPositiveGrowth = growthPercent >= 0

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
    >
      <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
        <CardContent className="space-y-4 p-5">
          {/* Header */}
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-2">
              <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#E6F4FF]">
                <DollarSign className="h-5 w-5 text-[#4B9BFF]" />
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">
                  Earnings
                </p>
                <p className="text-sm text-slate-500">6-week trend</p>
              </div>
            </div>

            {growthPercent !== 0 && (
              <Badge
                variant="secondary"
                className={
                  isPositiveGrowth
                    ? 'bg-[#E6F4FF] text-[#4B9BFF]'
                    : 'bg-[#FFE7E1] text-[#FF8B6A]'
                }
              >
                <TrendingUp
                  className={`mr-1 h-3 w-3 ${!isPositiveGrowth && 'rotate-180'}`}
                />
                {Math.abs(growthPercent).toFixed(0)}%
              </Badge>
            )}
          </div>

          {/* Chart */}
          <div className="h-24 w-full">
            <ResponsiveContainer width="100%" height="100%" minWidth={0} debounce={50}>
              <LineChart data={weeklyData}>
                <XAxis
                  dataKey="label"
                  tick={{ fontSize: 10, fill: '#94a3b8' }}
                  tickLine={false}
                  axisLine={false}
                  hide
                />
                <Tooltip content={<CustomTooltip />} />
                <Line
                  type="monotone"
                  dataKey="value"
                  stroke="#4B9BFF"
                  strokeWidth={2}
                  dot={{
                    fill: '#4B9BFF',
                    strokeWidth: 2,
                    r: 3,
                  }}
                  activeDot={{
                    r: 5,
                    fill: '#4B9BFF',
                    strokeWidth: 0,
                  }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-2xl bg-slate-50/80 p-3">
              <p className="text-xs text-slate-500">Total Earned</p>
              <p className="mt-1 text-base font-semibold text-slate-900">
                ₹{totalEarnings.toLocaleString('en-IN')}
              </p>
            </div>
            <div className="rounded-2xl bg-slate-50/80 p-3">
              <p className="text-xs text-slate-500">Pending</p>
              <p className="mt-1 text-base font-semibold text-slate-900">
                ₹{pendingEarnings.toLocaleString('en-IN')}
              </p>
            </div>
          </div>

          {/* This Week Highlight */}
          <div className="rounded-2xl bg-gradient-to-r from-[#E6F4FF] to-[#E3E9FF] p-3">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs text-slate-600">This Week</p>
                <p className="text-lg font-semibold text-slate-900">
                  ₹{thisWeek.toLocaleString('en-IN')}
                </p>
              </div>
              {growthPercent !== 0 && (
                <div
                  className={`text-right text-xs font-semibold ${
                    isPositiveGrowth ? 'text-[#4B9BFF]' : 'text-[#FF8B6A]'
                  }`}
                >
                  {isPositiveGrowth ? '+' : ''}
                  {growthPercent.toFixed(1)}%
                  <br />
                  <span className="text-slate-500">vs last week</span>
                </div>
              )}
            </div>
          </div>

          {/* Projected Earnings */}
          {pendingEarnings > 0 && (
            <div className="border-t border-slate-100 pt-3">
              <p className="text-xs text-slate-500">
                Projected if all pending projects complete
              </p>
              <p className="mt-1 text-sm font-semibold text-slate-900">
                ₹{(totalEarnings + pendingEarnings).toLocaleString('en-IN')}
              </p>
            </div>
          )}
        </CardContent>
      </Card>
    </motion.div>
  )
}
