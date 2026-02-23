"use client"

import React, { useState } from "react"
import { format, subMonths, startOfMonth } from "date-fns"

/**
 * Props for the MonthlyPerformanceHeatmap component
 */
interface MonthlyPerformanceHeatmapProps {
  /**
   * Array of monthly performance data for the last 12 months
   */
  monthlyData: Array<{
    /** Month identifier (e.g., "2024-01") */
    month: string
    /** Number of projects completed in the month */
    projects: number
    /** Total earnings for the month */
    earnings: number
    /** Average rating for the month */
    rating: number
  }>
}

/**
 * MonthlyPerformanceHeatmap Component
 *
 * Displays a GitHub-style contribution heatmap showing monthly activity
 * for the last 12 months. Color intensity is based on project count or earnings.
 *
 * Features:
 * - Grid layout: 3 rows x 4 columns (12 months)
 * - Color scale: light teal to dark teal based on activity
 * - Hover tooltips with detailed metrics
 * - Responsive design
 *
 * @param {MonthlyPerformanceHeatmapProps} props - Component props
 * @returns {JSX.Element} Rendered heatmap component
 */
export function MonthlyPerformanceHeatmap({ monthlyData }: MonthlyPerformanceHeatmapProps) {
  const [hoveredCell, setHoveredCell] = useState<string | null>(null)

  /**
   * Generate last 12 months data with defaults for missing months
   */
  const generateLast12Months = () => {
    const months: Array<{
      month: string
      monthLabel: string
      projects: number
      earnings: number
      rating: number
    }> = []

    for (let i = 11; i >= 0; i--) {
      const date = startOfMonth(subMonths(new Date(), i))
      const monthKey = format(date, "yyyy-MM")
      const monthLabel = format(date, "MMM")

      const existingData = monthlyData.find((d) => d.month === monthKey)

      months.push({
        month: monthKey,
        monthLabel,
        projects: existingData?.projects || 0,
        earnings: existingData?.earnings || 0,
        rating: existingData?.rating || 0,
      })
    }

    return months
  }

  const last12Months = generateLast12Months()

  /**
   * Calculate maximum values for normalization
   */
  const maxProjects = Math.max(...last12Months.map((m) => m.projects), 1)
  const maxEarnings = Math.max(...last12Months.map((m) => m.earnings), 1)

  /**
   * Get color intensity class based on project count
   * Uses a 5-level scale from light to dark teal
   */
  const getColorIntensity = (projects: number): string => {
    if (projects === 0) return "bg-gray-100 border border-gray-200"

    const intensity = projects / maxProjects

    if (intensity >= 0.8) return "bg-teal-600"
    if (intensity >= 0.6) return "bg-teal-500"
    if (intensity >= 0.4) return "bg-teal-400"
    if (intensity >= 0.2) return "bg-teal-300"
    return "bg-teal-100"
  }

  /**
   * Format currency for display
   */
  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: "INR",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount)
  }

  return (
    <div className="rounded-[24px] bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)] backdrop-blur-sm transition-all hover:shadow-[0_20px_40px_rgba(30,58,138,0.12)]">
      {/* Header */}
      <div className="mb-6 flex items-start justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">
            Monthly Performance Heatmap
          </h3>
          <p className="mt-1 text-sm text-gray-600">
            Activity levels over the last 12 months
          </p>
        </div>

        {/* Legend */}
        <div className="flex items-center gap-2">
          <span className="text-xs text-gray-600">Less</span>
          <div className="flex gap-1">
            <div className="h-4 w-4 rounded bg-gray-100 border border-gray-200" />
            <div className="h-4 w-4 rounded bg-teal-100" />
            <div className="h-4 w-4 rounded bg-teal-300" />
            <div className="h-4 w-4 rounded bg-teal-500" />
            <div className="h-4 w-4 rounded bg-teal-600" />
          </div>
          <span className="text-xs text-gray-600">More</span>
        </div>
      </div>

      {/* Heatmap Grid */}
      <div className="grid grid-cols-4 gap-2 sm:gap-3">
        {last12Months.map((data) => {
          const isHovered = hoveredCell === data.month

          return (
            <div
              key={data.month}
              className="relative"
              onMouseEnter={() => setHoveredCell(data.month)}
              onMouseLeave={() => setHoveredCell(null)}
            >
              {/* Cell */}
              <div
                className={`
                  aspect-square rounded-lg transition-all duration-200
                  ${getColorIntensity(data.projects)}
                  ${isHovered ? "scale-105 shadow-lg" : "hover:scale-105"}
                  flex items-center justify-center cursor-pointer
                `}
              >
                <span
                  className={`
                    text-xs font-medium
                    ${data.projects > maxProjects * 0.5 ? "text-white" : "text-gray-700"}
                  `}
                >
                  {data.monthLabel}
                </span>
              </div>

              {/* Tooltip */}
              {isHovered && (
                <div className="absolute bottom-full left-1/2 z-50 mb-2 -translate-x-1/2 transform">
                  <div className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-2 text-xs text-white shadow-xl">
                    <div className="whitespace-nowrap font-semibold">
                      {format(new Date(data.month + "-01"), "MMMM yyyy")}
                    </div>
                    <div className="mt-1 space-y-0.5 text-gray-300">
                      <div>
                        <span className="font-medium">{data.projects}</span> projects
                      </div>
                      <div>
                        <span className="font-medium">{formatCurrency(data.earnings)}</span> earned
                      </div>
                      {data.rating > 0 && (
                        <div>
                          <span className="font-medium">{data.rating.toFixed(1)}</span> avg rating
                        </div>
                      )}
                    </div>
                    {/* Tooltip arrow */}
                    <div className="absolute left-1/2 top-full -translate-x-1/2 transform">
                      <div className="border-4 border-transparent border-t-gray-900" />
                    </div>
                  </div>
                </div>
              )}
            </div>
          )
        })}
      </div>

      {/* Summary Stats */}
      <div className="mt-6 grid grid-cols-3 gap-4 border-t border-gray-200 pt-4">
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">
            {last12Months.reduce((sum, m) => sum + m.projects, 0)}
          </div>
          <div className="text-xs text-gray-600">Total Projects</div>
        </div>
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">
            {formatCurrency(last12Months.reduce((sum, m) => sum + m.earnings, 0))}
          </div>
          <div className="text-xs text-gray-600">Total Earnings</div>
        </div>
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">
            {(
              last12Months.reduce((sum, m) => sum + m.rating, 0) /
              last12Months.filter((m) => m.rating > 0).length || 0
            ).toFixed(1)}
          </div>
          <div className="text-xs text-gray-600">Avg Rating</div>
        </div>
      </div>
    </div>
  )
}
