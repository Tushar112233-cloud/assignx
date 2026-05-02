/**
 * @fileoverview StatsGrid - Grid layout for dashboard statistics.
 * Displays key metrics for supervisor dashboard.
 */

import { motion } from "framer-motion"
import { FolderKanban, Clock, CheckCircle, Wallet } from "lucide-react"
import { StatCard, type SparklineDataPoint, type MetricTrend } from "@/components/shared/stat-card"
import { Skeleton } from "@/components/ui/skeleton"

/**
 * Props for the StatsGrid component.
 * @interface StatsGridProps
 */
export interface StatsGridProps {
  activeProjects: number
  pendingReview: number
  completedThisMonth: number
  earningsThisMonth: number
  sparklines?: {
    activeProjects?: SparklineDataPoint[]
    pendingReview?: SparklineDataPoint[]
    completedThisMonth?: SparklineDataPoint[]
    earningsThisMonth?: SparklineDataPoint[]
  }
  trends?: {
    activeProjects?: MetricTrend
    pendingReview?: MetricTrend
    completedThisMonth?: MetricTrend
    earningsThisMonth?: MetricTrend
  }
  isLoading?: boolean
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
}

/**
 * Dashboard statistics grid displaying key supervisor metrics.
 * Shows counts for active projects, pending review, completed this month, and earnings.
 * @param props - Stats grid props
 * @returns A responsive grid of stat cards
 */
export function StatsGrid({
  activeProjects,
  pendingReview,
  completedThisMonth,
  earningsThisMonth,
  sparklines,
  trends,
  isLoading = false,
}: StatsGridProps) {
  if (isLoading) {
    return (
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, index) => (
          <Skeleton key={index} className="h-32 rounded-xl" />
        ))}
      </div>
    )
  }

  return (
    <motion.div variants={itemVariants} className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <StatCard
        icon={<FolderKanban className="h-5 w-5" />}
        label="Active Projects"
        value={activeProjects}
        color="sage"
        sparklineData={sparklines?.activeProjects}
        trend={trends?.activeProjects}
      />
      <StatCard
        icon={<Clock className="h-5 w-5" />}
        label="Pending Review"
        value={pendingReview}
        color="terracotta"
        sparklineData={sparklines?.pendingReview}
        trend={trends?.pendingReview}
      />
      <StatCard
        icon={<CheckCircle className="h-5 w-5" />}
        label="Completed This Month"
        value={completedThisMonth}
        color="primary"
        sparklineData={sparklines?.completedThisMonth}
        trend={trends?.completedThisMonth}
      />
      <StatCard
        icon={<Wallet className="h-5 w-5" />}
        label="Earnings"
        value={earningsThisMonth}
        color="accent"
        format="currency"
        sparklineData={sparklines?.earningsThisMonth}
        trend={trends?.earningsThisMonth}
      />
    </motion.div>
  )
}
