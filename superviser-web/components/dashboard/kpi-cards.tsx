"use client"

import { useEffect, useState, useRef } from "react"
import { Card } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { TrendingUp, TrendingDown, FolderKanban, CheckCircle, Clock, Wallet } from "lucide-react"
import { cn } from "@/lib/utils"

interface KPICardProps {
  title: string
  value: number | string
  trend?: {
    direction: "up" | "down"
    percentage: number
  }
  sparklineData?: number[]
  icon: React.ElementType
  color: "teal" | "amber" | "coral" | "green"
  isLoading?: boolean
  delay?: number
}

const colorMap = {
  teal: {
    bg: "bg-[var(--dash-accent)]/10",
    border: "border-[var(--dash-accent)]/30",
    text: "text-[var(--dash-accent)]",
    icon: "text-[var(--dash-accent)]",
    sparkline: "#72B7AD",
  },
  amber: {
    bg: "bg-[var(--dash-highlight)]/10",
    border: "border-[var(--dash-highlight)]/30",
    text: "text-[var(--dash-highlight)]",
    icon: "text-[var(--dash-highlight)]",
    sparkline: "#C77B4E",
  },
  coral: {
    bg: "bg-rose-500/10",
    border: "border-rose-500/30",
    text: "text-rose-400",
    icon: "text-rose-400",
    sparkline: "#FB7185",
  },
  green: {
    bg: "bg-emerald-500/10",
    border: "border-emerald-500/30",
    text: "text-emerald-400",
    icon: "text-emerald-400",
    sparkline: "#34D399",
  },
}

function Sparkline({ data, color }: { data: number[]; color: string }) {
  if (!data || data.length === 0) return null

  const min = Math.min(...data)
  const max = Math.max(...data)
  const range = max - min || 1
  const width = 100
  const height = 30
  const padding = 2

  const points = data.map((value, index) => {
    const x = (index / (data.length - 1)) * (width - padding * 2) + padding
    const y = height - ((value - min) / range) * (height - padding * 2) - padding
    return `${x},${y}`
  })

  const pathD = `M ${points.join(" L ")}`

  return (
    <svg
      viewBox={`0 0 ${width} ${height}`}
      className="w-full h-8"
      preserveAspectRatio="none"
    >
      <path
        d={pathD}
        fill="none"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function AnimatedNumber({ value, delay = 0 }: { value: number; delay?: number }) {
  const [displayValue, setDisplayValue] = useState(0)
  const hasAnimated = useRef(false)

  useEffect(() => {
    if (hasAnimated.current) return
    
    const timeout = setTimeout(() => {
      hasAnimated.current = true
      const duration = 800
      const startTime = Date.now()
      const startValue = 0

      const animate = () => {
        const elapsed = Date.now() - startTime
        const progress = Math.min(elapsed / duration, 1)
        const easeOut = 1 - Math.pow(1 - progress, 3)
        const current = Math.floor(startValue + (value - startValue) * easeOut)
        
        setDisplayValue(current)
        
        if (progress < 1) {
          requestAnimationFrame(animate)
        }
      }

      requestAnimationFrame(animate)
    }, delay)

    return () => clearTimeout(timeout)
  }, [value, delay])

  return <span>{displayValue}</span>
}

function KPICard({
  title,
  value,
  trend,
  sparklineData = [],
  icon: Icon,
  color,
  isLoading,
  delay = 0,
}: KPICardProps) {
  const colors = colorMap[color]
  const numericValue = typeof value === "string" ? parseInt(value) || 0 : value

  if (isLoading) {
    return (
      <Card className={cn(
        "p-4 bg-[var(--dash-surface)] border-[var(--dash-border)]",
        "dash-card"
      )}>
        <Skeleton className="h-8 w-8 rounded-lg mb-3" />
        <Skeleton className="h-6 w-16 mb-2" />
        <Skeleton className="h-4 w-24" />
      </Card>
    )
  }

  return (
    <Card
      className={cn(
        "p-4 dash-card-hover cursor-pointer group",
        "animate-enter"
      )}
      style={{ animationDelay: `${delay}ms` }}
    >
      <div className="flex items-start justify-between mb-3">
        <div className={cn(
          "h-10 w-10 rounded-lg flex items-center justify-center",
          colors.bg,
          "border",
          colors.border
        )}>
          <Icon className={cn("h-5 w-5", colors.icon)} />
        </div>
        
        {trend && (
          <div className={cn(
            "flex items-center gap-1 text-xs font-medium",
            trend.direction === "up" ? "text-emerald-400" : "text-rose-400"
          )}>
            {trend.direction === "up" ? (
              <TrendingUp className="h-3.5 w-3.5" />
            ) : (
              <TrendingDown className="h-3.5 w-3.5" />
            )}
            <span>{trend.percentage}%</span>
          </div>
        )}
      </div>

      <div className="mb-1">
        <span className="text-2xl lg:text-3xl font-bold text-white">
          {typeof value === "string" && value.includes("$") ? (
            value
          ) : (
            <AnimatedNumber value={numericValue} delay={delay} />
          )}
        </span>
      </div>

      <p className="text-xs text-[var(--dash-text-muted)] mb-3">{title}</p>

      {/* Sparkline */}
      {sparklineData.length > 0 && (
        <div className="opacity-50 group-hover:opacity-100 transition-opacity">
          <Sparkline data={sparklineData} color={colors.sparkline} />
        </div>
      )}
    </Card>
  )
}

interface KPICardsProps {
  activeProjects: number
  pendingQC: number
  completedThisMonth: number
  earningsThisMonth: number
  isLoading?: boolean
}

export function KPICards({
  activeProjects,
  pendingQC,
  completedThisMonth,
  earningsThisMonth,
  isLoading,
}: KPICardsProps) {
  // Generate sample sparkline data (in production, this would come from API)
  const generateSparkline = (baseValue: number) => {
    return Array.from({ length: 7 }, (_, i) => {
      const variance = Math.random() * 0.4 - 0.2
      return Math.max(0, Math.floor(baseValue * (1 + variance * (i / 6))))
    })
  }

  const cards = [
    {
      title: "Active Projects",
      value: activeProjects,
      icon: FolderKanban,
      color: "teal" as const,
      trend: { direction: "up" as const, percentage: 12 },
      sparklineData: generateSparkline(activeProjects),
    },
    {
      title: "Pending Review",
      value: pendingQC,
      icon: Clock,
      color: "amber" as const,
      trend: { direction: "down" as const, percentage: 5 },
      sparklineData: generateSparkline(pendingQC),
    },
    {
      title: "Completed",
      value: completedThisMonth,
      icon: CheckCircle,
      color: "green" as const,
      trend: { direction: "up" as const, percentage: 23 },
      sparklineData: generateSparkline(completedThisMonth),
    },
    {
      title: "Earnings",
      value: `₹${(earningsThisMonth / 1000).toFixed(0)}K`,
      icon: Wallet,
      color: "coral" as const,
      trend: { direction: "up" as const, percentage: 18 },
      sparklineData: generateSparkline(earningsThisMonth / 10000),
    },
  ]

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 lg:gap-4">
      {cards.map((card, index) => (
        <KPICard
          key={card.title}
          {...card}
          isLoading={isLoading}
          delay={index * 100}
        />
      ))}
    </div>
  )
}
