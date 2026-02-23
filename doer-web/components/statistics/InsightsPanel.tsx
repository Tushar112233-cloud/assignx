'use client'

import { Lightbulb, AlertTriangle, Info } from 'lucide-react'
import { motion } from 'framer-motion'

/**
 * Props for individual insight item
 */
interface Insight {
  type: 'success' | 'warning' | 'info'
  message: string
}

/**
 * Props for individual goal item
 */
interface Goal {
  title: string
  current: number
  target: number
  unit: string // e.g., "₹", "projects", "%"
}

/**
 * Props for the InsightsPanel component
 */
interface InsightsPanelProps {
  insights: Insight[]
  goals: Goal[]
}

/**
 * InsightsPanel Component
 *
 * Displays AI-generated insights and goal progress tracking in a two-column layout.
 * Features animated insight cards with color-coded icons and progress bars for goals.
 *
 * @component
 * @example
 * ```tsx
 * <InsightsPanel
 *   insights={[
 *     { type: 'success', message: 'Great job! Your completion rate is above average.' },
 *     { type: 'warning', message: 'Response time could be improved by 20%.' }
 *   ]}
 *   goals={[
 *     { title: 'Earn ₹50,000 this month', current: 35000, target: 50000, unit: '₹' }
 *   ]}
 * />
 * ```
 */
export function InsightsPanel({ insights, goals }: InsightsPanelProps) {
  /**
   * Get icon and color configuration based on insight type
   */
  const getInsightConfig = (type: Insight['type']) => {
    switch (type) {
      case 'success':
        return {
          icon: Lightbulb,
          iconColor: 'text-emerald-600',
          bgColor: 'bg-emerald-50/50'
        }
      case 'warning':
        return {
          icon: AlertTriangle,
          iconColor: 'text-amber-600',
          bgColor: 'bg-amber-50/50'
        }
      case 'info':
        return {
          icon: Info,
          iconColor: 'text-blue-600',
          bgColor: 'bg-blue-50/50'
        }
    }
  }

  /**
   * Calculate percentage completion for a goal
   */
  const calculatePercentage = (current: number, target: number): number => {
    return Math.min(Math.round((current / target) * 100), 100)
  }

  /**
   * Get gradient color based on completion percentage
   */
  const getProgressGradient = (percentage: number): string => {
    if (percentage >= 80) {
      return 'bg-gradient-to-r from-emerald-500 to-emerald-600'
    } else if (percentage >= 50) {
      return 'bg-gradient-to-r from-blue-500 to-blue-600'
    } else {
      return 'bg-gradient-to-r from-amber-500 to-amber-600'
    }
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {/* Left Section - Insights */}
      <div className="rounded-[24px] bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
        <h3 className="text-lg font-semibold text-slate-900 mb-4">
          AI Insights
        </h3>
        <div className="space-y-3">
          {insights.map((insight, index) => {
            const config = getInsightConfig(insight.type)
            const Icon = config.icon

            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{
                  duration: 0.4,
                  delay: index * 0.1,
                  ease: [0.22, 1, 0.36, 1]
                }}
                className={`rounded-2xl bg-slate-50/80 px-4 py-3 flex items-start gap-3 ${config.bgColor}`}
              >
                <div className={`flex-shrink-0 mt-0.5 ${config.iconColor}`}>
                  <Icon className="w-5 h-5" />
                </div>
                <p className="text-sm text-slate-700 leading-relaxed">
                  {insight.message}
                </p>
              </motion.div>
            )
          })}
        </div>
      </div>

      {/* Right Section - Goals */}
      <div className="rounded-[24px] bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
        <h3 className="text-lg font-semibold text-slate-900 mb-4">
          Your Goals
        </h3>
        <div className="space-y-4">
          {goals.map((goal, index) => {
            const percentage = calculatePercentage(goal.current, goal.target)
            const progressGradient = getProgressGradient(percentage)

            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{
                  duration: 0.4,
                  delay: index * 0.1,
                  ease: [0.22, 1, 0.36, 1]
                }}
                className="space-y-2"
              >
                {/* Goal Title and Percentage */}
                <div className="flex items-center justify-between">
                  <h4 className="text-sm font-medium text-slate-900">
                    {goal.title}
                  </h4>
                  <span className="text-xs font-semibold text-slate-600 bg-slate-100 px-2 py-1 rounded-full">
                    {percentage}%
                  </span>
                </div>

                {/* Progress Bar */}
                <div className="relative h-3 rounded-full bg-slate-100 overflow-hidden">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${percentage}%` }}
                    transition={{
                      duration: 1,
                      delay: index * 0.1 + 0.2,
                      ease: [0.22, 1, 0.36, 1]
                    }}
                    className={`h-full ${progressGradient} rounded-full`}
                  />
                </div>

                {/* Current/Target Values */}
                <div className="flex items-center justify-between text-xs text-slate-600">
                  <span>
                    {goal.unit === '₹' ? goal.unit : ''}
                    {goal.current.toLocaleString('en-IN')}
                    {goal.unit !== '₹' ? ` ${goal.unit}` : ''}
                  </span>
                  <span className="text-slate-400">
                    / {goal.unit === '₹' ? goal.unit : ''}
                    {goal.target.toLocaleString('en-IN')}
                    {goal.unit !== '₹' ? ` ${goal.unit}` : ''}
                  </span>
                </div>
              </motion.div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
