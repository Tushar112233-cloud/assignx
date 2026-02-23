/**
 * @fileoverview Tool Category Card Component
 * Reusable card for resource categories with icon, title, description
 * @module components/resources/tool-category-card
 */

"use client"

import { ReactNode } from "react"
import { ChevronRight } from "lucide-react"
import { cn } from "@/lib/utils"

interface ToolCategoryCardProps {
  title: string
  description: string
  icon: ReactNode
  iconBgColor?: string
  onClick: () => void
  badge?: {
    text: string
    variant?: "default" | "success" | "warning" | "info"
  }
  className?: string
}

const badgeVariants = {
  default: "bg-gray-100 text-gray-600",
  success: "bg-emerald-100 text-emerald-600",
  warning: "bg-orange-100 text-orange-600",
  info: "bg-blue-100 text-blue-600",
}

export default function ToolCategoryCard({
  title,
  description,
  icon,
  iconBgColor = "bg-gray-100",
  onClick,
  badge,
  className,
}: ToolCategoryCardProps) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "group flex items-center gap-4 w-full p-4 bg-white rounded-2xl border border-gray-200",
        "hover:border-orange-200 hover:shadow-md hover:-translate-y-0.5 active:translate-y-0 hover:scale-105",
        "transition-all duration-300 ease-out",
        "text-left",
        className
      )}
    >
      {/* Icon */}
      <div className={cn("w-12 h-12 rounded-xl flex items-center justify-center shrink-0", iconBgColor)}>
        <div className="w-5 h-5 flex items-center justify-center">
          {icon}
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-0.5">
          <h3 className="font-semibold text-[#1C1C1C] group-hover:text-orange-600 transition-colors truncate">
            {title}
          </h3>
          {badge && (
            <span
              className={cn(
                "text-xs px-2 py-0.5 rounded-full font-medium shrink-0",
                badgeVariants[badge.variant || "default"]
              )}
            >
              {badge.text}
            </span>
          )}
        </div>
        <p className="text-sm text-gray-500 line-clamp-1">
          {description}
        </p>
      </div>

      {/* Chevron */}
      <ChevronRight className="h-5 w-5 text-gray-400 group-hover:text-orange-500 group-hover:translate-x-0.5 transition-all duration-300 shrink-0" />
    </button>
  )
}
