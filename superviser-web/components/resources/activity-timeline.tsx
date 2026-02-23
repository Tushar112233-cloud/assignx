/**
 * @fileoverview Activity Timeline Component
 * Shows recent resource/tool usage activities with timeline visualization
 * @module components/resources/activity-timeline
 */

"use client"

import { motion } from "framer-motion"
import { Search, Brain, Calculator, BookOpen, FileCheck, Sparkles } from "lucide-react"
import { cn } from "@/lib/utils"

interface Activity {
  id: string
  description: string
  time: string
  icon: "search" | "brain" | "calculator" | "book" | "check" | "sparkles"
  iconColor: string
}

const iconComponents = {
  search: Search,
  brain: Brain,
  calculator: Calculator,
  book: BookOpen,
  check: FileCheck,
  sparkles: Sparkles,
}

const iconColors = {
  blue: "bg-blue-100 text-blue-600",
  purple: "bg-purple-100 text-purple-600",
  emerald: "bg-emerald-100 text-emerald-600",
  indigo: "bg-indigo-100 text-indigo-600",
  orange: "bg-orange-100 text-orange-600",
  amber: "bg-amber-100 text-amber-600",
}

interface ActivityTimelineProps {
  activities?: Activity[]
  className?: string
}

export default function ActivityTimeline({ activities = [], className }: ActivityTimelineProps) {
  return (
    <div className={cn("bg-white rounded-2xl border border-gray-200 p-6", className)}>
      {/* Header */}
      <div className="mb-6">
        <h3 className="text-lg font-semibold text-[#1C1C1C]">Recent Activity</h3>
        <p className="text-sm text-gray-500 mt-1">Your latest tool usage</p>
      </div>

      {/* Timeline */}
      <div className="relative space-y-4">
        {/* Connecting line */}
        <div className="absolute left-5 top-5 bottom-5 w-0.5 bg-orange-200" />

        {/* Activities */}
        {activities.map((activity, index) => {
          const IconComponent = iconComponents[activity.icon]
          const colorClass = iconColors[activity.iconColor as keyof typeof iconColors]

          return (
            <motion.div
              key={activity.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.05, duration: 0.3 }}
              className="relative flex items-start gap-4"
            >
              {/* Icon */}
              <div className={cn("relative z-10 w-10 h-10 rounded-full flex items-center justify-center shrink-0", colorClass)}>
                <IconComponent className="h-5 w-5" />
              </div>

              {/* Content */}
              <div className="flex-1 min-w-0 pt-1.5">
                <p className="text-sm font-medium text-[#1C1C1C] mb-0.5">
                  {activity.description}
                </p>
                <p className="text-xs text-gray-500">
                  {activity.time}
                </p>
              </div>
            </motion.div>
          )
        })}
      </div>

      {/* View All Link */}
      <div className="mt-6 pt-4 border-t border-gray-100">
        <button className="text-sm text-orange-600 hover:text-orange-700 font-medium transition-colors">
          View all activity
        </button>
      </div>
    </div>
  )
}
