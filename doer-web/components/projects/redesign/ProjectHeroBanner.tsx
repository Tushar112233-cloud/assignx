'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { ArrowUpRight, TrendingUp, Zap, Target, DollarSign } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import type { Project } from '@/types/project.types'

/**
 * Props for the ProjectHeroBanner component
 */
interface ProjectHeroBannerProps {
  /** Total number of active projects */
  activeCount: number
  /** Total number of projects under review */
  reviewCount: number
  /** Total number of completed projects */
  completedCount: number
  /** Total pipeline value across all projects */
  totalPipelineValue: number
  /** This week's earnings */
  weeklyEarnings: number
  /** Weekly completion trend data (last 7 days) */
  weeklyTrend: number[]
  /** Velocity percentage (projects completed vs total) */
  velocityPercent: number
  /** Callback when "New Project" button is clicked */
  onNewProject?: () => void
  /** Callback when "Analytics" button is clicked */
  onViewAnalytics?: () => void
}

/**
 * Mini insight card component for the hero banner
 */
interface InsightCardProps {
  label: string
  value: string
  icon: React.ElementType
  iconBg: string
  iconColor: string
  trend?: string
}

const InsightCard = ({ label, value, icon: Icon, iconBg, iconColor, trend }: InsightCardProps) => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      className="rounded-2xl bg-white/85 p-4 shadow-[0_12px_30px_rgba(30,58,138,0.1)] backdrop-blur-sm"
    >
      <div className="flex items-start justify-between">
        <div className="space-y-1">
          <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">{label}</p>
          <p className="text-2xl font-semibold text-slate-900">{value}</p>
          {trend && (
            <p className="flex items-center gap-1 text-xs text-emerald-600">
              <TrendingUp className="h-3 w-3" />
              {trend}
            </p>
          )}
        </div>
        <div className={cn('flex h-11 w-11 items-center justify-center rounded-2xl', iconBg)}>
          <Icon className={cn('h-5 w-5', iconColor)} />
        </div>
      </div>
    </motion.div>
  )
}

/**
 * Animated circular progress ring component
 */
interface ProgressRingProps {
  percent: number
  size?: number
  strokeWidth?: number
}

const ProgressRing = ({ percent, size = 120, strokeWidth = 8 }: ProgressRingProps) => {
  const radius = (size - strokeWidth) / 2
  const circumference = radius * 2 * Math.PI
  const offset = circumference - (percent / 100) * circumference

  return (
    <div className="relative" style={{ width: size, height: size }}>
      <svg className="rotate-[-90deg]" width={size} height={size}>
        {/* Background circle */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke="#E3E9FF"
          strokeWidth={strokeWidth}
          fill="none"
        />
        {/* Progress circle */}
        <motion.circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke="url(#gradient)"
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
        <defs>
          <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#5A7CFF" />
            <stop offset="50%" stopColor="#5B86FF" />
            <stop offset="100%" stopColor="#49C5FF" />
          </linearGradient>
        </defs>
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <motion.p
          className="text-3xl font-bold text-slate-900"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
        >
          {Math.round(percent)}%
        </motion.p>
        <p className="text-xs font-medium text-slate-500">Velocity</p>
      </div>
    </div>
  )
}

/**
 * Mini sparkline chart for weekly trend
 */
interface SparklineProps {
  data: number[]
  width?: number
  height?: number
}

const Sparkline = ({ data, width = 100, height = 40 }: SparklineProps) => {
  if (!data || data.length === 0) {
    return <div style={{ width, height }} className="rounded bg-slate-100" />
  }

  const max = Math.max(...data, 1)
  const min = Math.min(...data, 0)
  const range = max - min || 1

  const points = data
    .map((value, index) => {
      const x = (index / (data.length - 1 || 1)) * width
      const y = height - ((value - min) / range) * height
      return `${x},${y}`
    })
    .join(' ')

  return (
    <svg width={width} height={height} className="overflow-visible">
      <motion.polyline
        points={points}
        fill="none"
        stroke="url(#sparkline-gradient)"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        initial={{ pathLength: 0 }}
        animate={{ pathLength: 1 }}
        transition={{ duration: 1, ease: 'easeInOut' }}
      />
      <defs>
        <linearGradient id="sparkline-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="#5A7CFF" />
          <stop offset="100%" stopColor="#49C5FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}

/**
 * Hero Banner Component for Projects Page
 *
 * Displays a prominent gradient banner with project velocity, insights,
 * and call-to-action buttons at the top of the projects page.
 *
 * @example
 * ```tsx
 * <ProjectHeroBanner
 *   activeCount={5}
 *   reviewCount={2}
 *   completedCount={12}
 *   totalPipelineValue={125000}
 *   weeklyEarnings={15000}
 *   weeklyTrend={[3, 5, 4, 6, 5, 7, 8]}
 *   velocityPercent={75}
 *   onNewProject={() => router.push('/projects/new')}
 *   onViewAnalytics={() => router.push('/analytics')}
 * />
 * ```
 */
export const ProjectHeroBanner = ({
  activeCount,
  reviewCount,
  completedCount,
  totalPipelineValue,
  weeklyEarnings,
  weeklyTrend,
  velocityPercent,
  onNewProject,
  onViewAnalytics,
}: ProjectHeroBannerProps) => {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const formatCurrency = (value: number) => `₹${value.toLocaleString('en-IN')}`

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6 }}
      className="relative overflow-hidden rounded-[28px] bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] p-8 shadow-[0_24px_60px_rgba(30,58,138,0.12)]"
    >
      {/* Radial overlay effects */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(255,255,255,0.2),transparent_50%)]" />
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_bottom_left,rgba(67,209,197,0.3),transparent_60%)]" />

      <div className="relative grid gap-6 lg:grid-cols-[1fr_auto_1fr]">
        {/* Left Section: Title & CTA */}
        <div className="space-y-4">
          <div className="space-y-2">
            <motion.h1
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.2 }}
              className="text-4xl font-bold tracking-tight text-white"
            >
              Project Velocity Dashboard
            </motion.h1>
            <motion.p
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 }}
              className="text-lg text-white/90"
            >
              Track your momentum and earnings in real-time
            </motion.p>
          </div>

          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="flex flex-wrap items-center gap-3"
          >
            <Button
              onClick={onViewAnalytics}
              className="h-11 gap-2 rounded-full border-2 border-white/30 bg-white/20 px-6 text-sm font-semibold text-white shadow-[0_12px_28px_rgba(0,0,0,0.15)] backdrop-blur-sm transition hover:bg-white/30"
            >
              View Analytics
              <ArrowUpRight className="h-4 w-4" />
            </Button>
            <Button
              onClick={onNewProject}
              className="h-11 rounded-full bg-white px-6 text-sm font-semibold text-[#5A7CFF] shadow-[0_12px_28px_rgba(0,0,0,0.15)] transition hover:bg-white/90"
            >
              + New Project
            </Button>
          </motion.div>
        </div>

        {/* Center Section: Velocity Ring */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="flex items-center justify-center"
        >
          <ProgressRing percent={velocityPercent} />
        </motion.div>

        {/* Right Section: Quick Stats */}
        <div className="grid grid-cols-2 gap-3 lg:grid-cols-1">
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
            className="rounded-2xl bg-white/20 p-4 backdrop-blur-sm"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-white/80">
                  This Week
                </p>
                <p className="text-xl font-bold text-white">{formatCurrency(weeklyEarnings)}</p>
              </div>
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white/20">
                <DollarSign className="h-5 w-5 text-white" />
              </div>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.5 }}
            className="rounded-2xl bg-white/20 p-4 backdrop-blur-sm"
          >
            <p className="text-xs font-semibold uppercase tracking-wide text-white/80">
              Weekly Trend
            </p>
            <div className="mt-2">
              {mounted && <Sparkline data={weeklyTrend} width={100} height={30} />}
            </div>
          </motion.div>
        </div>
      </div>

      {/* Bottom Section: Floating Insight Cards */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4"
      >
        <InsightCard
          label="Pipeline Value"
          value={formatCurrency(totalPipelineValue)}
          icon={Target}
          iconBg="bg-[#E3E9FF]"
          iconColor="text-[#4F6CF7]"
          trend="+12% from last week"
        />
        <InsightCard
          label="Active Projects"
          value={activeCount.toString()}
          icon={Zap}
          iconBg="bg-[#FFE7E1]"
          iconColor="text-[#FF8B6A]"
        />
        <InsightCard
          label="Under Review"
          value={reviewCount.toString()}
          icon={TrendingUp}
          iconBg="bg-[#E6F4FF]"
          iconColor="text-[#4B9BFF]"
        />
        <InsightCard
          label="Completed"
          value={completedCount.toString()}
          icon={Target}
          iconBg="bg-[#E9FAFA]"
          iconColor="text-[#43D1C5]"
        />
      </motion.div>
    </motion.div>
  )
}
