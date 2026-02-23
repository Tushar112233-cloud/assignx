"use client"

/**
 * @fileoverview Project Stat Card - Mini stat card for projects page stats row.
 * Clean design with color variants and optional trend indicator.
 * @module components/projects/v2/project-stat-card
 */

import { motion } from "framer-motion"
import { LucideIcon, ArrowUp, ArrowDown } from "lucide-react"
import { cn } from "@/lib/utils"

export interface ProjectStatCardProps {
  icon: LucideIcon
  value: number | string
  label: string
  trend?: {
    value: number
    isPositive: boolean
  }
  color?: "default" | "orange" | "blue" | "green" | "amber"
  delay?: number
}

const colorStyles = {
  default: {
    iconBg: "bg-white",
    iconColor: "text-gray-600",
    accent: "border-gray-200",
    bar: "bg-gray-300",
    label: "text-gray-500",
    glow: "bg-gray-200/60",
    edge: "bg-gray-200",
    card: "bg-gradient-to-br from-gray-50 to-white"
  },
  orange: {
    iconBg: "bg-white",
    iconColor: "text-orange-600",
    accent: "border-orange-200/70",
    bar: "bg-orange-400",
    label: "text-orange-700/70",
    glow: "bg-orange-200/60",
    edge: "bg-orange-300",
    card: "bg-gradient-to-br from-orange-50 to-white"
  },
  blue: {
    iconBg: "bg-white",
    iconColor: "text-blue-600",
    accent: "border-blue-200/70",
    bar: "bg-blue-400",
    label: "text-blue-700/70",
    glow: "bg-blue-200/60",
    edge: "bg-blue-300",
    card: "bg-gradient-to-br from-blue-50 to-white"
  },
  green: {
    iconBg: "bg-white",
    iconColor: "text-emerald-600",
    accent: "border-emerald-200/70",
    bar: "bg-emerald-400",
    label: "text-emerald-700/70",
    glow: "bg-emerald-200/60",
    edge: "bg-emerald-300",
    card: "bg-gradient-to-br from-emerald-50 to-white"
  },
  amber: {
    iconBg: "bg-white",
    iconColor: "text-amber-600",
    accent: "border-amber-200/70",
    bar: "bg-amber-400",
    label: "text-amber-700/70",
    glow: "bg-amber-200/60",
    edge: "bg-amber-300",
    card: "bg-gradient-to-br from-amber-50 to-white"
  }
}

export function ProjectStatCard({
  icon: Icon,
  value,
  label,
  trend,
  color = "default",
  delay = 0
}: ProjectStatCardProps) {
  const styles = colorStyles[color]

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay: delay / 1000 }}
      className={cn(
        "relative overflow-hidden rounded-2xl border p-4",
        "hover:shadow-md transition-shadow",
        styles.accent,
        styles.card
      )}
    >
      <div className={cn("absolute -right-6 -top-6 h-20 w-20 rounded-full blur-2xl", styles.glow)} />
      <div className={cn("absolute left-0 top-0 h-full w-1", styles.edge)} />
      <div className="flex items-start justify-between gap-4">
        <div className="space-y-2">
          <p className={cn("text-[11px] uppercase tracking-wide", styles.label)}>{label}</p>
          <p className="text-2xl font-bold text-[#1C1C1C] tabular-nums">
            {typeof value === "number" ? value.toLocaleString() : value}
          </p>
        </div>

        <div className="flex flex-col items-end gap-2">
          <div
            className={cn(
              "w-10 h-10 rounded-xl flex items-center justify-center ring-1 ring-black/5",
              styles.iconBg
            )}
          >
            <Icon className={cn("h-5 w-5", styles.iconColor)} />
          </div>

          {trend && (
            <div
              className={cn(
                "flex items-center gap-1 text-xs font-medium",
                trend.isPositive ? "text-emerald-600" : "text-rose-600"
              )}
            >
              {trend.isPositive ? (
                <ArrowUp className="h-3 w-3" />
              ) : (
                <ArrowDown className="h-3 w-3" />
              )}
              <span>{Math.abs(trend.value)}%</span>
            </div>
          )}
        </div>
      </div>

      <div className="mt-4 h-1.5 rounded-full bg-gray-100 overflow-hidden">
        <div
          className={cn("h-full rounded-full", styles.bar)}
          style={{ width: `${trend ? Math.min(100, Math.max(12, Math.abs(trend.value))) : 40}%` }}
        />
      </div>
    </motion.div>
  )
}
