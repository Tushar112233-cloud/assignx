/**
 * @fileoverview Small stat display component for resources page
 * @module components/resources/stats-card
 */

import { ReactNode } from "react"

interface StatsCardProps {
  icon: ReactNode
  value: string | number
  label: string
  iconColor?: string
}

export function StatsCard({ icon, value, label, iconColor = "bg-orange-100" }: StatsCardProps) {
  return (
    <div className="flex items-center gap-3 bg-white rounded-xl border border-gray-200 p-3">
      {/* Icon container with colored background */}
      <div className={`flex items-center justify-center h-10 w-10 rounded-xl ${iconColor}`}>
        {icon}
      </div>

      {/* Stats content */}
      <div className="flex flex-col">
        <span className="text-2xl font-bold text-[#1C1C1C] leading-none">
          {value}
        </span>
        <span className="text-xs text-gray-500 mt-0.5">
          {label}
        </span>
      </div>
    </div>
  )
}
