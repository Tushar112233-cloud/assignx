'use client'

import { useState, useMemo } from 'react'
import {
  TrendingUp,
  TrendingDown,
  Calendar,
  DollarSign,
  Briefcase,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import type { EarningsData } from '@/types/database'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Area,
  AreaChart,
} from 'recharts'

interface EarningsGraphProps {
  /** Earnings data */
  data?: EarningsData[]
  /** Current period */
  period?: 'week' | 'month' | 'year'
  /** Callback when period changes */
  onPeriodChange?: (period: 'week' | 'month' | 'year') => void
  /** Loading state */
  isLoading?: boolean
  /** Additional class name */
  className?: string
}

/** Generate empty data placeholder when no real data is available */
const generateEmptyData = (period: 'week' | 'month' | 'year'): EarningsData[] => {
  const data: EarningsData[] = []
  const now = new Date()
  const days = period === 'week' ? 7 : period === 'month' ? 30 : 12

  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(now)
    if (period === 'year') {
      date.setMonth(date.getMonth() - i)
    } else {
      date.setDate(date.getDate() - i)
    }

    data.push({
      date: date.toISOString().split('T')[0],
      amount: 0,
      projectCount: 0,
    })
  }

  return data
}

/** Format date for display */
const formatDate = (date: string, period: 'week' | 'month' | 'year') => {
  const d = new Date(date)
  if (period === 'year') {
    return d.toLocaleDateString('en-IN', { month: 'short' })
  }
  return d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })
}

/** Custom tooltip */
const CustomTooltip = ({ active, payload, label, period }: {
  active?: boolean
  payload?: Array<{ value: number; name: string }>
  label?: string
  period: 'week' | 'month' | 'year'
}) => {
  if (!active || !payload?.length || !label) return null

  return (
    <div className="bg-white dark:bg-slate-950 border-2 border-[#5A7CFF]/20 rounded-xl p-4 shadow-xl backdrop-blur-sm">
      <p className="text-sm font-semibold mb-2 text-slate-900 dark:text-slate-100">{formatDate(label, period)}</p>
      <div className="space-y-1">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF]" />
          <span className="text-sm text-slate-600 dark:text-slate-400">Earnings:</span>
          <span className="text-sm font-bold text-[#5A7CFF]">₹{payload[0].value.toLocaleString()}</span>
        </div>
      </div>
    </div>
  )
}

/**
 * Earnings Graph component
 * Displays earnings over time with interactive chart
 */
export function EarningsGraph({
  data: propData,
  period: initialPeriod = 'month',
  onPeriodChange,
  isLoading,
  className,
}: EarningsGraphProps) {
  const [period, setPeriod] = useState<'week' | 'month' | 'year'>(initialPeriod)

  /** Get data for current period */
  const data = useMemo(() => {
    return propData || generateEmptyData(period)
  }, [propData, period])

  /** Calculate statistics */
  const stats = useMemo(() => {
    if (!data.length) return { total: 0, average: 0, projects: 0, change: 0 }

    const total = data.reduce((sum, d) => sum + d.amount, 0)
    const projects = data.reduce((sum, d) => sum + d.projectCount, 0)
    const average = total / data.length

    // Calculate change compared to previous period
    const midPoint = Math.floor(data.length / 2)
    const firstHalf = data.slice(0, midPoint).reduce((sum, d) => sum + d.amount, 0)
    const secondHalf = data.slice(midPoint).reduce((sum, d) => sum + d.amount, 0)
    const change = firstHalf > 0 ? ((secondHalf - firstHalf) / firstHalf) * 100 : 0

    return { total, average, projects, change }
  }, [data])

  /** Handle period change */
  const handlePeriodChange = (newPeriod: 'week' | 'month' | 'year') => {
    setPeriod(newPeriod)
    onPeriodChange?.(newPeriod)
  }

  /** Period options */
  const periodOptions = [
    { value: 'week' as const, label: '7 Days' },
    { value: 'month' as const, label: '30 Days' },
    { value: 'year' as const, label: '12 Months' },
  ]

  return (
    <Card className={cn("w-full max-w-full overflow-hidden bg-gradient-to-br from-white to-slate-50 dark:from-slate-950 dark:to-slate-900 border-2 shadow-xl", className)}>
      <CardHeader className="p-6">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex-1 min-w-0">
            <CardTitle className="flex items-center gap-2">
              <div className="p-2 flex-shrink-0 bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] rounded-lg">
                <TrendingUp className="h-5 w-5 text-white" />
              </div>
              <span className="bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] bg-clip-text text-transparent truncate">
                Earnings Overview
              </span>
            </CardTitle>
            <CardDescription className="mt-1 line-clamp-2">
              Your earnings performance over time
            </CardDescription>
          </div>
          <div className="flex items-center gap-1 p-1 bg-gradient-to-r from-[#5A7CFF]/10 to-[#49C5FF]/10 rounded-xl border border-[#5A7CFF]/20">
            {periodOptions.map((option) => (
              <Button
                key={option.value}
                variant={period === option.value ? 'default' : 'ghost'}
                size="sm"
                onClick={() => handlePeriodChange(option.value)}
                className={cn(
                  "text-xs transition-all",
                  period === option.value && "bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] text-white hover:from-[#4A6CFF] hover:to-[#39B5FF]"
                )}
              >
                {option.label}
              </Button>
            ))}
          </div>
        </div>
      </CardHeader>
      <CardContent className="p-6 space-y-6">
        {/* Stats cards */}
        <div className="w-full grid gap-4 grid-cols-2 xl:grid-cols-4">
          <div className="p-4 rounded-xl border-2 border-[#5A7CFF]/20 bg-gradient-to-br from-[#5A7CFF]/5 to-[#49C5FF]/5 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all">
            <div className="flex items-center gap-2 mb-1">
              <DollarSign className="h-4 w-4 text-[#5A7CFF]" />
              <span className="text-sm text-slate-600 dark:text-slate-400">Total Earnings</span>
            </div>
            <p className="text-2xl font-bold bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] bg-clip-text text-transparent">
              ₹{stats.total.toLocaleString()}
            </p>
          </div>

          <div className="p-4 rounded-xl border-2 border-[#5A7CFF]/20 bg-gradient-to-br from-[#5A7CFF]/5 to-[#49C5FF]/5 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all">
            <div className="flex items-center gap-2 mb-1">
              <Calendar className="h-4 w-4 text-[#49C5FF]" />
              <span className="text-sm text-slate-600 dark:text-slate-400">Daily Average</span>
            </div>
            <p className="text-2xl font-bold bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] bg-clip-text text-transparent">
              ₹{Math.round(stats.average).toLocaleString()}
            </p>
          </div>

          <div className="p-4 rounded-xl border-2 border-[#5A7CFF]/20 bg-gradient-to-br from-[#5A7CFF]/5 to-[#49C5FF]/5 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all">
            <div className="flex items-center gap-2 mb-1">
              <Briefcase className="h-4 w-4 text-[#5A7CFF]" />
              <span className="text-sm text-slate-600 dark:text-slate-400">Projects</span>
            </div>
            <p className="text-2xl font-bold bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] bg-clip-text text-transparent">
              {stats.projects}
            </p>
          </div>

          <div className="p-4 rounded-xl border-2 border-[#5A7CFF]/20 bg-gradient-to-br from-[#5A7CFF]/5 to-[#49C5FF]/5 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all">
            <div className="flex items-center gap-2 mb-1">
              {stats.change >= 0 ? (
                <TrendingUp className="h-4 w-4 text-green-600" />
              ) : (
                <TrendingDown className="h-4 w-4 text-red-600" />
              )}
              <span className="text-sm text-slate-600 dark:text-slate-400">Change</span>
            </div>
            <p
              className={cn(
                'text-2xl font-bold',
                stats.change >= 0 ? 'text-green-600' : 'text-red-600'
              )}
            >
              {stats.change >= 0 ? '+' : ''}{stats.change.toFixed(1)}%
            </p>
          </div>
        </div>

        {/* Chart */}
        <div className="h-[300px] w-full rounded-xl border-2 border-[#5A7CFF]/20 bg-gradient-to-br from-white to-[#5A7CFF]/5 dark:from-slate-950 dark:to-[#5A7CFF]/5 p-4 shadow-inner">
          {isLoading ? (
            <div className="h-full w-full flex items-center justify-center">
              <div className="animate-pulse bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] bg-clip-text text-transparent font-semibold">
                Loading chart...
              </div>
            </div>
          ) : (
            <ResponsiveContainer width="100%" height="100%" minWidth={0} debounce={50}>
              <AreaChart data={data} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorEarningsBlue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#5A7CFF" stopOpacity={0.4} />
                    <stop offset="50%" stopColor="#49C5FF" stopOpacity={0.2} />
                    <stop offset="95%" stopColor="#49C5FF" stopOpacity={0} />
                  </linearGradient>
                  <linearGradient id="strokeGradient" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#5A7CFF" />
                    <stop offset="100%" stopColor="#49C5FF" />
                  </linearGradient>
                </defs>
                <CartesianGrid
                  strokeDasharray="3 3"
                  stroke="#5A7CFF"
                  strokeOpacity={0.1}
                  vertical={false}
                />
                <XAxis
                  dataKey="date"
                  tickFormatter={(date) => formatDate(date, period)}
                  stroke="#5A7CFF"
                  strokeOpacity={0.5}
                  fontSize={12}
                  tickLine={false}
                  axisLine={false}
                />
                <YAxis
                  tickFormatter={(value) => `₹${(value / 1000).toFixed(0)}k`}
                  stroke="#5A7CFF"
                  strokeOpacity={0.5}
                  fontSize={12}
                  tickLine={false}
                  axisLine={false}
                  width={50}
                />
                <Tooltip content={<CustomTooltip period={period} />} />
                <Area
                  type="monotone"
                  dataKey="amount"
                  stroke="url(#strokeGradient)"
                  strokeWidth={3}
                  fill="url(#colorEarningsBlue)"
                  fillOpacity={1}
                />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Legend */}
        <div className="flex items-center justify-center gap-6 text-sm">
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-gradient-to-r from-[#5A7CFF]/10 to-[#49C5FF]/10 border border-[#5A7CFF]/20">
            <div className="w-3 h-3 rounded-full bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF]" />
            <span className="text-slate-700 dark:text-slate-300 font-medium">Earnings</span>
          </div>
          <Badge
            variant="outline"
            className="text-xs border-[#5A7CFF]/30 bg-gradient-to-r from-[#5A7CFF]/5 to-[#49C5FF]/5 text-[#5A7CFF] font-semibold px-3 py-1"
          >
            {period === 'week'
              ? 'Last 7 days'
              : period === 'month'
              ? 'Last 30 days'
              : 'Last 12 months'}
          </Badge>
        </div>
      </CardContent>
    </Card>
  )
}
