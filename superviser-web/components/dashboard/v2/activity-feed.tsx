/**
 * @fileoverview Activity Feed - Clean premium timeline.
 * Minimal design with subtle icon colors for activity types.
 * @module components/dashboard/v2/activity-feed
 */

"use client"

import { motion } from "framer-motion"
import {
  CheckCircle2,
  Clock,
  FileText,
  MessageSquare,
  AlertCircle,
  TrendingUp,
  ChevronRight,
  Inbox
} from "lucide-react"
import { cn } from "@/lib/utils"
import Link from "next/link"
import { formatDistanceToNow } from "date-fns"

type ActivityType = "completed" | "assigned" | "submitted" | "message" | "alert" | "payment"

interface ActivityItem {
  id: string
  type: ActivityType
  title: string
  description?: string
  timestamp: string
  projectId?: string
  projectNumber?: string
}

interface ActivityFeedProps {
  activities: ActivityItem[]
  className?: string
}

const activityConfig: Record<ActivityType, { icon: typeof CheckCircle2; color: string; bgColor: string }> = {
  completed: {
    icon: CheckCircle2,
    color: "text-emerald-400",
    bgColor: "bg-emerald-500/10",
  },
  assigned: {
    icon: TrendingUp,
    color: "text-[#F97316]",
    bgColor: "bg-orange-500/10",
  },
  submitted: {
    icon: FileText,
    color: "text-violet-400",
    bgColor: "bg-violet-500/10",
  },
  message: {
    icon: MessageSquare,
    color: "text-amber-400",
    bgColor: "bg-amber-500/10",
  },
  alert: {
    icon: AlertCircle,
    color: "text-rose-400",
    bgColor: "bg-rose-500/10",
  },
  payment: {
    icon: Clock,
    color: "text-blue-600",
    bgColor: "bg-blue-50",
  },
}

function ActivityItemCard({ activity, isLast }: { activity: ActivityItem; isLast: boolean }) {
  const config = activityConfig[activity.type]
  const Icon = config.icon

  const content = (
    <div className="group flex gap-4">
      {/* Timeline Column */}
      <div className="flex flex-col items-center">
        <div className={cn(
          "flex items-center justify-center w-9 h-9 rounded-xl shrink-0 transition-all duration-300",
          config.bgColor,
          "group-hover:scale-110"
        )}>
          <Icon className={cn("h-5 w-5", config.color)} />
        </div>
        {!isLast && (
          <div className="w-px flex-1 bg-[#2D2D2D] mt-3 min-h-[20px]" />
        )}
      </div>

      {/* Content Column */}
      <div className="flex-1 min-w-0 pb-5">
        <div className="flex items-start justify-between gap-3">
          <div className="space-y-1">
            <p className="text-sm font-semibold text-white leading-snug group-hover:text-[#F97316] transition-colors duration-300">
              {activity.title}
            </p>
            {activity.description && (
              <p className="text-xs text-gray-400 leading-relaxed">
                {activity.description}
              </p>
            )}
            {activity.projectNumber && (
              <span className="inline-flex items-center text-[10px] font-mono text-gray-500 mt-1">
                #{activity.projectNumber}
              </span>
            )}
          </div>
          <span className="text-[10px] text-gray-500 shrink-0 tabular-nums pt-0.5">
            {formatDistanceToNow(new Date(activity.timestamp), { addSuffix: true })}
          </span>
        </div>
      </div>
    </div>
  )

  if (activity.projectId) {
    return (
      <Link href={`/projects/${activity.projectId}`} className="block hover:opacity-90 transition-opacity">
        {content}
      </Link>
    )
  }

  return content
}

function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-12 text-center">
      <div className="w-14 h-14 rounded-xl bg-[#2D2D2D] flex items-center justify-center mb-4">
        <Inbox className="h-6 w-6 text-gray-500" />
      </div>
      <p className="text-sm font-semibold text-gray-400">No recent activity</p>
      <p className="text-xs text-gray-500 mt-1">Activity will appear here as things happen</p>
    </div>
  )
}

export function ActivityFeed({ activities, className }: ActivityFeedProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: "easeOut" }}
      className={cn(
        "rounded-2xl overflow-hidden",
        "bg-[#1C1C1C]",
        "border border-[#2D2D2D]",
        "shadow-xl shadow-black/30",
        className
      )}
    >
      {/* Header */}
      <div className="flex items-center justify-between p-6 border-b border-[#2D2D2D]">
        <h3 className="text-base font-bold text-white">
          Recent Activity
        </h3>
        <Link
          href="/notifications"
          className="text-xs text-gray-500 hover:text-[#F97316] flex items-center gap-1 transition-colors duration-300 font-medium"
        >
          View all
          <ChevronRight className="h-3.5 w-3.5" />
        </Link>
      </div>

      {/* Content */}
      <div className="p-6 max-h-[450px] overflow-y-auto scrollbar-thin scrollbar-thumb-[#2D2D2D] scrollbar-track-transparent">
        {activities.length === 0 ? (
          <EmptyState />
        ) : (
          <div>
            {activities.map((activity, index) => (
              <ActivityItemCard
                key={activity.id}
                activity={activity}
                isLast={index === activities.length - 1}
              />
            ))}
          </div>
        )}
      </div>
    </motion.div>
  )
}
