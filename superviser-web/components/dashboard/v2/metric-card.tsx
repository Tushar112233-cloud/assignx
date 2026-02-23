/**
 * @fileoverview Metric Card - Premium minimal stat card.
 * Clean design with subtle color accents through icons and shadows.
 * @module components/dashboard/v2/metric-card
 */

"use client"

import { motion } from "framer-motion"
import { LucideIcon, TrendingUp, TrendingDown } from "lucide-react"
import { cn } from "@/lib/utils"
import Link from "next/link"

export interface MetricCardProps {
  icon: LucideIcon
  label: string
  value: number | string
  trend?: {
    value: number
    direction: "up" | "down"
  }
  accent: "cyan" | "teal" | "amber" | "emerald" | "violet" | "rose"
  href?: string
  format?: "number" | "currency" | "percentage"
  subtitle?: string
}

const accentStyles = {
  cyan: {
    icon: "text-blue-600",
    iconBg: "bg-blue-50 group-hover:bg-blue-100",
    ring: "ring-blue-500/30",
    glow: "group-hover:shadow-blue-500/20",
  },
  teal: {
    icon: "text-[#F97316]",
    iconBg: "bg-orange-50 group-hover:bg-orange-100",
    ring: "ring-orange-500/30",
    glow: "group-hover:shadow-orange-500/20",
  },
  amber: {
    icon: "text-[#F97316]",
    iconBg: "bg-orange-500/10 group-hover:bg-orange-500/20",
    ring: "ring-orange-500/30",
    glow: "group-hover:shadow-orange-500/30",
  },
  emerald: {
    icon: "text-emerald-400",
    iconBg: "bg-emerald-500/10 group-hover:bg-emerald-500/20",
    ring: "ring-emerald-500/30",
    glow: "group-hover:shadow-emerald-500/20",
  },
  violet: {
    icon: "text-violet-400",
    iconBg: "bg-violet-500/10 group-hover:bg-violet-500/20",
    ring: "ring-violet-500/30",
    glow: "group-hover:shadow-violet-500/20",
  },
  rose: {
    icon: "text-rose-400",
    iconBg: "bg-rose-500/10 group-hover:bg-rose-500/20",
    ring: "ring-rose-500/30",
    glow: "group-hover:shadow-rose-500/20",
  },
}

function formatValue(value: number | string, format?: string): string {
  if (typeof value === "string") return value

  switch (format) {
    case "currency":
      return `₹${value.toLocaleString("en-IN")}`
    case "percentage":
      return `${value}%`
    default:
      return value.toLocaleString()
  }
}

export function MetricCard({
  icon: Icon,
  label,
  value,
  trend,
  accent,
  href,
  format,
  subtitle,
}: MetricCardProps) {
  const styles = accentStyles[accent]

  const cardContent = (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: "easeOut" }}
      className={cn(
        "group relative",
        "rounded-2xl p-6",
        "bg-[#1C1C1C]",
        "border border-[#2D2D2D]",
        "shadow-lg shadow-black/20",
        href && "cursor-pointer",
        "transition-all duration-300 ease-out",
        href && "hover:scale-105 hover:shadow-2xl hover:border-[#F97316]/30",
        href && styles.glow
      )}
    >
      <div className="space-y-5">
        {/* Icon & Trend Row */}
        <div className="flex items-center justify-between">
          <div className={cn(
            "flex items-center justify-center w-12 h-12 rounded-xl transition-all duration-300",
            styles.iconBg,
            "group-hover:scale-110"
          )}>
            <Icon className={cn("h-6 w-6", styles.icon)} />
          </div>

          {trend && (
            <div className={cn(
              "flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold",
              trend.direction === "up"
                ? "text-emerald-400 bg-emerald-500/10 border border-emerald-500/20"
                : "text-rose-400 bg-rose-500/10 border border-rose-500/20"
            )}>
              {trend.direction === "up" ? (
                <TrendingUp className="h-3.5 w-3.5" />
              ) : (
                <TrendingDown className="h-3.5 w-3.5" />
              )}
              {trend.value}%
            </div>
          )}
        </div>

        {/* Value & Label */}
        <div className="space-y-2">
          <p className="text-3xl font-bold tracking-tight text-white tabular-nums">
            {formatValue(value, format)}
          </p>
          <div className="flex items-center justify-between">
            <p className="text-[11px] font-bold tracking-wider uppercase text-gray-500">
              {label}
            </p>
            {subtitle && (
              <p className="text-[11px] text-gray-500">{subtitle}</p>
            )}
          </div>
        </div>
      </div>
    </motion.div>
  )

  if (href) {
    return <Link href={href}>{cardContent}</Link>
  }

  return cardContent
}

export function MetricsGrid({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={cn(
      "grid gap-4",
      "grid-cols-2 lg:grid-cols-4",
      className
    )}>
      {children}
    </div>
  )
}
