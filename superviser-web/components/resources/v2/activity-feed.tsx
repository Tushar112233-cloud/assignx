"use client"

import { motion } from "framer-motion"
import {
  Search,
  Bot,
  SpellCheck,
  DollarSign,
  BookOpen,
  Clock,
  ArrowRight,
  type LucideIcon,
} from "lucide-react"
import { cn } from "@/lib/utils"

interface ActivityItem {
  id: string
  tool: string
  action: string
  timestamp: string
  icon: LucideIcon
  color: string
}

interface ActivityFeedProps {
  className?: string
}

// Mock activity data
const activities: ActivityItem[] = [
  {
    id: "1",
    tool: "Plagiarism Checker",
    action: "Checked 2,450 words",
    timestamp: "2 min ago",
    icon: Search,
    color: "text-[#F97316]",
  },
  {
    id: "2",
    tool: "AI Detector",
    action: "Analyzed content",
    timestamp: "15 min ago",
    icon: Bot,
    color: "text-purple-600",
  },
  {
    id: "3",
    tool: "Pricing Calculator",
    action: "Generated quote",
    timestamp: "1 hour ago",
    icon: DollarSign,
    color: "text-emerald-600",
  },
  {
    id: "4",
    tool: "Grammar Checker",
    action: "Fixed 12 issues",
    timestamp: "2 hours ago",
    icon: SpellCheck,
    color: "text-emerald-600",
  },
  {
    id: "5",
    tool: "Training Video",
    action: "Completed module",
    timestamp: "Yesterday",
    icon: BookOpen,
    color: "text-indigo-600",
  },
]

function ActivityItemComponent({
  activity,
  index,
}: {
  activity: ActivityItem
  index: number
}) {
  const Icon = activity.icon

  return (
    <motion.div
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.1 * index }}
      className="relative flex items-start gap-4 pl-12"
    >
      {/* Timeline dot */}
      <div className="absolute left-0 top-1">
        <div
          className={cn(
            "w-10 h-10 rounded-xl flex items-center justify-center",
            "bg-white border-2 border-gray-100 shadow-sm"
          )}
        >
          <Icon className={cn("h-5 w-5", activity.color)} />
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 pt-1.5">
        <div className="flex items-center justify-between">
          <span className="font-medium text-[#1C1C1C]">{activity.tool}</span>
          <span className="text-xs text-gray-400">{activity.timestamp}</span>
        </div>
        <p className="text-sm text-gray-500 leading-relaxed">{activity.action}</p>
      </div>
    </motion.div>
  )
}

export function ActivityFeed({ className }: ActivityFeedProps) {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.4 }}
      className={cn(
        "bg-white rounded-2xl border border-gray-200 p-8",
        className
      )}
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-2">
          <Clock className="h-5 w-5 text-[#F97316]" />
          <h3 className="font-semibold text-[#1C1C1C]">Recent Activity</h3>
        </div>
        <button
          className="flex items-center gap-1 text-sm text-gray-500
            hover:text-[#F97316] transition-colors"
        >
          View All
          <ArrowRight className="h-4 w-4" />
        </button>
      </div>

      {/* Timeline */}
      <div className="relative">
        {/* Timeline line */}
        <div
          className="absolute left-[19px] top-0 bottom-0 w-0.5
            bg-gradient-to-b from-[#F97316] via-orange-200 to-transparent"
        />

        {/* Activity items */}
        <div className="space-y-6">
          {activities.map((activity, index) => (
            <ActivityItemComponent
              key={activity.id}
              activity={activity}
              index={index}
            />
          ))}
        </div>
      </div>
    </motion.section>
  )
}

export default ActivityFeed
