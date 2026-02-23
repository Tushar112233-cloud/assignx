/**
 * @fileoverview Statistics dashboard displaying supervisor performance metrics.
 * @module components/profile/stats-dashboard
 */

"use client"

import {
  Briefcase,
  CheckCircle2,
  Clock,
  TrendingUp,
  TrendingDown,
  DollarSign,
  Star,
  Users,
  Target,
  ArrowUpRight,
  ArrowDownRight,
  Minus,
  AlertCircle,
} from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Skeleton } from "@/components/ui/skeleton"
import { cn } from "@/lib/utils"
import { PerformanceMetric } from "./types"
import { useSupervisorStats } from "@/hooks/use-supervisor"

interface StatCardProps {
  title: string
  value: string | number
  subtitle?: string
  icon: React.ReactNode
  iconBgColor: string
  trend?: "up" | "down" | "stable"
  trendValue?: string
  isLoading?: boolean
}

function StatCard({
  title,
  value,
  subtitle,
  icon,
  iconBgColor,
  trend,
  trendValue,
  isLoading,
}: StatCardProps) {
  if (isLoading) {
    return (
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardContent className="pt-6">
          <div className="flex items-start justify-between">
            <div className="space-y-2">
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-8 w-16" />
              <Skeleton className="h-3 w-20" />
            </div>
            <Skeleton className="h-10 w-10 rounded-lg" />
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
      <CardContent className="pt-6">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm text-gray-500">{title}</p>
            <p className="text-2xl font-semibold mt-1 text-[#1C1C1C]">{value}</p>
            {subtitle && (
              <p className="text-xs text-gray-500 mt-1">{subtitle}</p>
            )}
          </div>
          <div
            className={cn(
              "h-10 w-10 rounded-lg flex items-center justify-center",
              iconBgColor
            )}
          >
            {icon}
          </div>
        </div>
        {trend && trendValue && (
          <div className="flex items-center gap-1 mt-3">
            {trend === "up" && (
              <ArrowUpRight className="h-4 w-4 text-green-600" />
            )}
            {trend === "down" && (
              <ArrowDownRight className="h-4 w-4 text-red-600" />
            )}
            {trend === "stable" && (
              <Minus className="h-4 w-4 text-gray-400" />
            )}
            <span
              className={cn(
                "text-xs font-medium",
                trend === "up" && "text-green-600",
                trend === "down" && "text-red-600",
                trend === "stable" && "text-gray-500"
              )}
            >
              {trendValue}
            </span>
            <span className="text-xs text-gray-500">vs last month</span>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

interface MetricCardProps {
  metric: PerformanceMetric
}

function MetricCard({ metric }: MetricCardProps) {
  const progress = Math.min((metric.value / metric.target) * 100, 100)
  const isAboveTarget = metric.value >= metric.target

  return (
    <div className="p-4 bg-gray-50 border border-gray-100 rounded-2xl">
      <div className="flex items-start justify-between mb-2">
        <div>
          <p className="text-sm font-medium">{metric.label}</p>
          <p className="text-2xl font-bold">
            {metric.value}
            <span className="text-sm font-normal text-gray-500">
              {metric.unit}
            </span>
          </p>
        </div>
        <div
            className={cn(
              "flex items-center gap-1 text-xs font-medium",
              metric.trend === "up" && "text-green-600",
              metric.trend === "down" && "text-red-600",
              metric.trend === "stable" && "text-gray-500"
            )}
        >
          {metric.trend === "up" && <TrendingUp className="h-3 w-3" />}
          {metric.trend === "down" && <TrendingDown className="h-3 w-3" />}
          {metric.change_percentage !== undefined && metric.change_percentage !== 0 && (
            <span>
              {metric.change_percentage > 0 ? "+" : ""}
              {metric.change_percentage}%
            </span>
          )}
        </div>
      </div>
      <div className="space-y-1">
        <div className="flex items-center justify-between text-xs">
          <span className="text-gray-500">Target: {metric.target}{metric.unit}</span>
          <span className={cn(isAboveTarget ? "text-green-600" : "text-amber-600")}>
            {isAboveTarget ? "On Track" : "Below Target"}
          </span>
        </div>
        <Progress
          value={progress}
          className={cn("h-2", isAboveTarget ? "[&>div]:bg-green-600" : "[&>div]:bg-amber-500")}
        />
      </div>
    </div>
  )
}

function MetricCardSkeleton() {
  return (
    <div className="p-4 bg-gray-50 border border-gray-100 rounded-2xl">
      <div className="flex items-start justify-between mb-2">
        <div className="space-y-2">
          <Skeleton className="h-4 w-24" />
          <Skeleton className="h-8 w-16" />
        </div>
        <Skeleton className="h-4 w-12" />
      </div>
      <div className="space-y-2 mt-4">
        <div className="flex items-center justify-between">
          <Skeleton className="h-3 w-20" />
          <Skeleton className="h-3 w-16" />
        </div>
        <Skeleton className="h-2 w-full" />
      </div>
    </div>
  )
}

export function StatsDashboard() {
  const { stats, isLoading, error } = useSupervisorStats()

  // Build metrics from real data
  const metrics: PerformanceMetric[] = stats ? [
    {
      label: "Projects Completed",
      value: stats.completedProjects,
      target: Math.max(stats.totalProjects, 10),
      unit: "",
      trend: "up" as const,
    },
    {
      label: "Success Rate",
      value: stats.totalProjects > 0
        ? Math.round((stats.completedProjects / stats.totalProjects) * 100)
        : 0,
      target: 90,
      unit: "%",
      trend: "stable" as const,
    },
    {
      label: "Client Rating",
      value: stats.averageRating,
      target: 4.5,
      unit: "/5",
      trend: stats.averageRating >= 4.5 ? "up" as const : "stable" as const,
    },
    {
      label: "Active Doers",
      value: stats.totalDoers,
      target: 10,
      unit: "",
      trend: "up" as const,
    },
  ] : []

  if (error) {
    return (
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardContent className="pt-6">
          <div className="flex items-center gap-3 text-destructive">
            <AlertCircle className="h-5 w-5" />
            <p>Failed to load statistics. Please try again later.</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      {/* Quick Stats */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Active Projects"
          value={stats?.activeProjects ?? 0}
          subtitle={`${stats?.pendingQuotes ?? 0} pending quotes`}
          icon={<Briefcase className="h-5 w-5 text-blue-600" />}
          iconBgColor="bg-blue-100"
          isLoading={isLoading}
        />
        <StatCard
          title="Projects Completed"
          value={stats?.completedProjects ?? 0}
          subtitle="All time"
          icon={<CheckCircle2 className="h-5 w-5 text-green-600" />}
          iconBgColor="bg-green-100"
          isLoading={isLoading}
        />
        <StatCard
          title="Total Earnings"
          value={stats?.totalEarnings?.toLocaleString("en-IN", {
            style: "currency",
            currency: "INR",
            maximumFractionDigits: 0,
          }) ?? "₹0"}
          subtitle="All time"
          icon={<DollarSign className="h-5 w-5 text-green-600" />}
          iconBgColor="bg-green-100"
          isLoading={isLoading}
        />
        <StatCard
          title="Client Rating"
          value={stats?.averageRating?.toFixed(1) ?? "0.0"}
          subtitle="Average rating"
          icon={<Star className="h-5 w-5 text-amber-600" />}
          iconBgColor="bg-amber-100"
          isLoading={isLoading}
        />
      </div>

      {/* Earnings Overview */}
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Earnings Overview</CardTitle>
          <CardDescription className="text-sm text-gray-500">
            Your total and pending earnings
          </CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="grid gap-6 md:grid-cols-2">
              <Skeleton className="h-32 rounded-lg" />
              <Skeleton className="h-32 rounded-lg" />
            </div>
          ) : (
            <div className="grid gap-6 md:grid-cols-2">
              <div className="p-4 bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-950/30 dark:to-emerald-950/30 rounded-lg border border-green-200 dark:border-green-900">
                <div className="flex items-center gap-2 mb-2">
                  <DollarSign className="h-5 w-5 text-green-600" />
                  <span className="text-sm font-medium text-green-800 dark:text-green-200">
                    Total Earnings
                  </span>
                </div>
                <p className="text-3xl font-bold text-green-700 dark:text-green-300">
                  {(stats?.totalEarnings ?? 0).toLocaleString("en-IN", {
                    style: "currency",
                    currency: "INR",
                    maximumFractionDigits: 0,
                  })}
                </p>
                <p className="text-xs text-green-600 dark:text-green-400 mt-1">
                  Since joining AdminX
                </p>
              </div>
              <div className="p-4 bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-950/30 dark:to-indigo-950/30 rounded-lg border border-blue-200 dark:border-blue-900">
                <div className="flex items-center gap-2 mb-2">
                  <TrendingUp className="h-5 w-5 text-blue-600" />
                  <span className="text-sm font-medium text-blue-800 dark:text-blue-200">
                    Pending Payout
                  </span>
                </div>
                <p className="text-3xl font-bold text-blue-700 dark:text-blue-300">
                  {(stats?.pendingEarnings ?? 0).toLocaleString("en-IN", {
                    style: "currency",
                    currency: "INR",
                    maximumFractionDigits: 0,
                  })}
                </p>
                <p className="text-xs text-blue-600 dark:text-blue-400 mt-1">
                  Available for withdrawal
                </p>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Performance Metrics */}
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Performance Metrics</CardTitle>
          <CardDescription className="text-sm text-gray-500">
            Track your key performance indicators
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            {isLoading ? (
              <>
                <MetricCardSkeleton />
                <MetricCardSkeleton />
                <MetricCardSkeleton />
                <MetricCardSkeleton />
              </>
            ) : (
              metrics.map((metric) => (
                <MetricCard key={metric.label} metric={metric} />
              ))
            )}
          </div>
        </CardContent>
      </Card>

      {/* Quick Facts */}
      <Card className="rounded-2xl border border-gray-200 bg-white shadow-sm">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-[#1C1C1C]">Quick Facts</CardTitle>
          <CardDescription className="text-sm text-gray-500">
            Additional statistics about your work
          </CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="grid gap-4 md:grid-cols-3">
              <Skeleton className="h-20 rounded-lg" />
              <Skeleton className="h-20 rounded-lg" />
              <Skeleton className="h-20 rounded-lg" />
            </div>
          ) : (
            <div className="grid gap-4 md:grid-cols-3">
              <div className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-100 rounded-2xl">
                <Briefcase className="h-8 w-8 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Total Projects</p>
                  <p className="text-lg font-semibold">{stats?.totalProjects ?? 0}</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-100 rounded-2xl">
                <Users className="h-8 w-8 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Doers Managed</p>
                  <p className="text-lg font-semibold">{stats?.totalDoers ?? 0}</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-100 rounded-2xl">
                <Clock className="h-8 w-8 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Pending Quotes</p>
                  <p className="text-lg font-semibold">{stats?.pendingQuotes ?? 0}</p>
                </div>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
