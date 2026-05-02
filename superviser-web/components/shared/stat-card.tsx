"use client"

import { Card, CardContent } from "@/components/ui/card"
import { cn } from "@/lib/utils"
import { TrendingUp, TrendingDown, Minus } from "lucide-react"
import { Skeleton } from "@/components/ui/skeleton"

export interface SparklineDataPoint {
  date: string
  value: number
}

export interface MetricTrend {
  current_value: number
  previous_value: number
  change_value: number
  change_percent: number
  trend: "up" | "down" | "stable"
}

export type IconColorVariant =
  | "sage"
  | "terracotta"
  | "gray"
  | "blue"
  | "purple"
  | "primary"
  | "secondary"
  | "accent"
  | "muted"

export type NumberFormat = "number" | "percentage" | "currency"

export interface StatCardProps {
  label: string
  value: string | number
  icon?: React.ReactNode
  color?: IconColorVariant
  trend?: MetricTrend
  sparklineData?: SparklineDataPoint[]
  format?: NumberFormat
  className?: string
  loading?: boolean
}

const iconColorClasses: Record<IconColorVariant, string> = {
  sage: "bg-[#8FA892]/10 text-[#8FA892]",
  terracotta: "bg-[#C77B4E]/10 text-[#C77B4E]",
  gray: "bg-gray-100 text-gray-600",
  blue: "bg-blue-50 text-blue-600",
  purple: "bg-purple-50 text-purple-600",
  primary: "bg-primary/10 text-primary",
  secondary: "bg-secondary text-secondary-foreground",
  accent: "bg-accent/10 text-accent",
  muted: "bg-muted text-muted-foreground",
}

const sparklineColors: Record<IconColorVariant, string> = {
  sage: "#8FA892",
  terracotta: "#C77B4E",
  gray: "#6B7280",
  blue: "#3B82F6",
  purple: "#A855F7",
  primary: "hsl(var(--primary))",
  secondary: "hsl(var(--muted-foreground))",
  accent: "hsl(var(--accent))",
  muted: "hsl(var(--muted-foreground))",
}

function formatValue(value: number, format: NumberFormat = "number"): string {
  switch (format) {
    case "percentage":
      return `${value.toFixed(1)}%`
    case "currency":
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
      }).format(value)
    case "number":
    default:
      return new Intl.NumberFormat("en-US").format(Math.round(value))
  }
}

interface InlineSparklineProps {
  data: SparklineDataPoint[]
  width?: number
  height?: number
  color?: string
}

function InlineSparkline({
  data,
  width = 80,
  height = 40,
  color = "#8FA892",
}: InlineSparklineProps) {
  if (!data || data.length < 2) return null

  const values = data.map((d) => d.value)
  const min = Math.min(...values)
  const max = Math.max(...values)
  const range = max - min || 1

  const points = data
    .map((d, i) => {
      const x = (i / (data.length - 1)) * width
      const y = height - ((d.value - min) / range) * height * 0.8 - height * 0.1
      return `${x},${y}`
    })
    .join(" ")

  const areaPath = `M0,${height} L${points} L${width},${height} Z`

  return (
    <svg width={width} height={height} className="overflow-visible">
      <defs>
        <linearGradient id={`sparklineGradient-${color.replace(/[^a-zA-Z0-9]/g, '')}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity={0.3} />
          <stop offset="100%" stopColor={color} stopOpacity={0} />
        </linearGradient>
      </defs>
      <path d={areaPath} fill={`url(#sparklineGradient-${color.replace(/[^a-zA-Z0-9]/g, '')})`} />
      <polyline
        points={points}
        fill="none"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

interface TrendBadgeProps {
  trend: MetricTrend
}

function TrendBadge({ trend }: TrendBadgeProps) {
  const Icon = trend.trend === "up" ? TrendingUp : trend.trend === "down" ? TrendingDown : Minus

  const colorClass =
    trend.trend === "up"
      ? "text-emerald-600 bg-emerald-50"
      : trend.trend === "down"
        ? "text-red-600 bg-red-50"
        : "text-amber-600 bg-amber-50"

  return (
    <span
      className={cn(
        "inline-flex items-center gap-0.5 px-2 py-1 rounded-full text-xs font-semibold",
        colorClass
      )}
    >
      <Icon className="w-3.5 h-3.5" strokeWidth={2.5} />
      {trend.trend !== "stable" && (trend.change_percent > 0 ? "+" : "")}
      {Math.abs(trend.change_percent).toFixed(1)}%
    </span>
  )
}

export function StatCard({
  label,
  value,
  icon,
  color = "primary",
  trend,
  sparklineData,
  format = "number",
  className,
  loading = false,
}: StatCardProps) {
  const effectiveColor = color
  const displayValue = typeof value === "number" ? formatValue(value, format) : value

  if (loading) {
    return (
      <Card className={cn("bg-white border-border/50", className)}>
        <CardContent className="p-6">
          <div className="flex items-start justify-between">
            <Skeleton className="h-10 w-10 rounded-lg" />
            <Skeleton className="h-5 w-12 rounded-full" />
          </div>
          <div className="mt-3 space-y-2">
            <Skeleton className="h-4 w-20 rounded" />
            <Skeleton className="h-8 w-16 rounded" />
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card
      className={cn(
        "bg-white border-border/50 rounded-xl hover:shadow-md hover:border-primary/20 transition-all duration-200",
        className
      )}
    >
      <CardContent className="p-6">
        <div className="flex items-start justify-between mb-4">
          {icon && (
            <div
              className={cn(
                "flex h-10 w-10 items-center justify-center rounded-lg",
                iconColorClasses[effectiveColor]
              )}
            >
              {icon}
            </div>
          )}
          {trend && <TrendBadge trend={trend} />}
        </div>

        <div className="flex items-end justify-between gap-3">
          <div className="flex-1">
            <p className="text-sm text-muted-foreground">{label}</p>
            <p className="text-2xl font-semibold tracking-tight">{displayValue}</p>
          </div>
          {sparklineData && sparklineData.length > 1 && (
            <div className="flex-shrink-0">
              <InlineSparkline
                data={sparklineData}
                color={sparklineColors[effectiveColor]}
              />
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}
