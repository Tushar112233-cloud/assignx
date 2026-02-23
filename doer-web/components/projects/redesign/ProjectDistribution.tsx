'use client'

import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts'
import { Card, CardContent } from '@/components/ui/card'
import { Layers } from 'lucide-react'
import { motion } from 'framer-motion'

/**
 * Props for ProjectDistribution component
 */
export interface ProjectDistributionProps {
  /** Number of active projects */
  activeCount: number
  /** Number of projects under review */
  reviewCount: number
  /** Number of completed projects */
  completedCount: number
}

/**
 * Chart data point
 */
interface ChartDataPoint {
  name: string
  value: number
  color: string
  percentage?: number
  [key: string]: any
}

/**
 * Color palette matching dashboard design
 */
const COLORS = {
  active: '#4F6CF7',
  review: '#49C5FF',
  completed: '#43D1C5',
}

/**
 * Custom label for pie chart - removed to avoid readability issues
 */
function renderCustomLabel({
  cx,
  cy,
  midAngle,
  innerRadius,
  outerRadius,
  percent,
}: any) {
  // Return null to hide percentage labels inside the chart
  // Percentages are shown in the legend instead for better readability
  return null
}

/**
 * Custom tooltip for pie chart
 */
function CustomTooltip({ active, payload }: any) {
  if (active && payload && payload.length) {
    const data = payload[0].payload
    return (
      <div className="rounded-xl border border-white/70 bg-white/95 p-3 shadow-[0_8px_16px_rgba(30,58,138,0.12)]">
        <p className="text-sm font-semibold text-slate-900">{data.name}</p>
        <p className="text-xs text-slate-600">
          {data.value} projects ({data.percentage}%)
        </p>
      </div>
    )
  }
  return null
}

/**
 * Project Distribution Component
 *
 * Displays a donut chart showing the distribution of projects across
 * different statuses (Active, Review, Completed).
 * Includes interactive legend and percentage breakdown.
 *
 * @component
 * @example
 * ```tsx
 * <ProjectDistribution
 *   activeCount={5}
 *   reviewCount={3}
 *   completedCount={12}
 * />
 * ```
 */
export function ProjectDistribution({
  activeCount,
  reviewCount,
  completedCount,
}: ProjectDistributionProps) {
  const total = activeCount + reviewCount + completedCount

  // Prepare chart data
  const chartData: ChartDataPoint[] = [
    {
      name: 'Active',
      value: activeCount,
      color: COLORS.active,
      percentage: total > 0 ? Math.round((activeCount / total) * 100) : 0,
    },
    {
      name: 'Under Review',
      value: reviewCount,
      color: COLORS.review,
      percentage: total > 0 ? Math.round((reviewCount / total) * 100) : 0,
    },
    {
      name: 'Completed',
      value: completedCount,
      color: COLORS.completed,
      percentage: total > 0 ? Math.round((completedCount / total) * 100) : 0,
    },
  ].filter((item) => item.value > 0) // Only show categories with data

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3, delay: 0.1 }}
    >
      <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] h-full">
        <CardContent className="space-y-4 p-6">
          {/* Header */}
          <div className="flex items-center gap-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#E3E9FF]">
              <Layers className="h-5 w-5 text-[#4F6CF7]" />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">
                Distribution
              </p>
              <p className="text-sm text-slate-500">Project breakdown</p>
            </div>
          </div>

          {total === 0 ? (
            <div className="flex h-40 items-center justify-center">
              <p className="text-sm text-slate-400">No projects yet</p>
            </div>
          ) : (
            <>
              {/* Donut Chart */}
              <div className="h-40 w-full">
                <ResponsiveContainer width="100%" height="100%" minWidth={0} debounce={50}>
                  <PieChart>
                    <Pie
                      data={chartData}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={renderCustomLabel}
                      outerRadius={60}
                      innerRadius={40}
                      fill="#8884d8"
                      dataKey="value"
                      animationBegin={0}
                      animationDuration={800}
                    >
                      {chartData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip content={<CustomTooltip />} />
                  </PieChart>
                </ResponsiveContainer>
              </div>

              {/* Legend with Stats */}
              <div className="space-y-2">
                {chartData.map((item, index) => (
                  <motion.div
                    key={item.name}
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.3, delay: index * 0.1 }}
                    className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2"
                  >
                    <div className="flex items-center gap-2">
                      <div
                        className="h-3 w-3 rounded-full"
                        style={{ backgroundColor: item.color }}
                      />
                      <span className="text-sm font-medium text-slate-700">
                        {item.name}
                      </span>
                    </div>
                    <div className="flex items-center gap-3">
                      <span className="text-xs text-slate-500">
                        {item.percentage}%
                      </span>
                      <span className="text-sm font-semibold text-slate-900">
                        {item.value}
                      </span>
                    </div>
                  </motion.div>
                ))}
              </div>

              {/* Total Count */}
              <div className="rounded-2xl bg-gradient-to-r from-[#E3E9FF] to-[#E6F4FF] p-3">
                <div className="flex items-center justify-between">
                  <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-600">
                    Total Projects
                  </p>
                  <p className="text-xl font-bold text-slate-900">{total}</p>
                </div>
              </div>
            </>
          )}

          {/* Insights */}
          {total > 0 && (
            <div className="border-t border-slate-100 pt-3 text-xs text-slate-500">
              {activeCount > reviewCount + completedCount ? (
                <p>🚀 You have many active projects. Keep the momentum!</p>
              ) : completedCount > activeCount + reviewCount ? (
                <p>✨ Great completion rate! Consider taking on more work.</p>
              ) : (
                <p>📊 Balanced portfolio across all stages.</p>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </motion.div>
  )
}
