'use client'

import { motion } from 'framer-motion'
import {
  Briefcase,
  ArrowRight,
  AlertTriangle,
  IndianRupee,
  Clock,
  Activity as ActivityIcon,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { cn } from '@/lib/utils'
import { formatDistanceToNow } from 'date-fns'

/**
 * Activity type enum
 * Defines possible activity types in the system
 */
export type ActivityType = 'project_assigned' | 'status_changed' | 'revision_requested' | 'payment_received'

/**
 * Activity interface
 * Represents a single activity event
 */
export interface Activity {
  /** Unique identifier */
  id: string
  /** Type of activity */
  type: ActivityType
  /** Activity description */
  description: string
  /** Related project title */
  projectTitle: string
  /** Activity timestamp */
  timestamp: string
  /** Optional additional metadata */
  metadata?: {
    /** Old status for status changes */
    oldStatus?: string
    /** New status for status changes */
    newStatus?: string
    /** Payment amount */
    amount?: number
    /** Revision reason */
    reason?: string
  }
}

/**
 * Props for ActivityFeed component
 */
interface ActivityFeedProps {
  /** List of activities to display */
  activities: Activity[]
  /** Loading state */
  isLoading?: boolean
}

/**
 * Get icon and styling for activity type
 */
function getActivityConfig(type: ActivityType): {
  icon: React.ReactNode
  bgColor: string
  iconColor: string
  gradient: string
} {
  switch (type) {
    case 'project_assigned':
      return {
        icon: <Briefcase className="h-4 w-4" />,
        bgColor: 'bg-[#5B86FF]/10',
        iconColor: 'text-[#4F6CF7]',
        gradient: 'from-[#5B86FF]/5 to-transparent',
      }
    case 'status_changed':
      return {
        icon: <ArrowRight className="h-4 w-4" />,
        bgColor: 'bg-emerald-500/10',
        iconColor: 'text-emerald-600',
        gradient: 'from-emerald-500/5 to-transparent',
      }
    case 'revision_requested':
      return {
        icon: <AlertTriangle className="h-4 w-4" />,
        bgColor: 'bg-[#FF8B6A]/10',
        iconColor: 'text-[#FF8B6A]',
        gradient: 'from-[#FF8B6A]/5 to-transparent',
      }
    case 'payment_received':
      return {
        icon: <IndianRupee className="h-4 w-4" />,
        bgColor: 'bg-teal-500/10',
        iconColor: 'text-teal-600',
        gradient: 'from-teal-500/5 to-transparent',
      }
    default:
      return {
        icon: <ActivityIcon className="h-4 w-4" />,
        bgColor: 'bg-muted',
        iconColor: 'text-muted-foreground',
        gradient: 'from-muted/5 to-transparent',
      }
  }
}

/**
 * Group activities by time period
 */
function groupActivitiesByTime(activities: Activity[]): Map<string, Activity[]> {
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  const yesterday = new Date(today)
  yesterday.setDate(yesterday.getDate() - 1)
  const thisWeek = new Date(today)
  thisWeek.setDate(thisWeek.getDate() - 7)

  const groups = new Map<string, Activity[]>([
    ['Today', []],
    ['Yesterday', []],
    ['This Week', []],
    ['Older', []],
  ])

  activities.forEach((activity) => {
    const activityDate = new Date(activity.timestamp)

    if (activityDate >= today) {
      groups.get('Today')?.push(activity)
    } else if (activityDate >= yesterday) {
      groups.get('Yesterday')?.push(activity)
    } else if (activityDate >= thisWeek) {
      groups.get('This Week')?.push(activity)
    } else {
      groups.get('Older')?.push(activity)
    }
  })

  // Remove empty groups
  groups.forEach((value, key) => {
    if (value.length === 0) {
      groups.delete(key)
    }
  })

  return groups
}

/**
 * Format timestamp to relative time
 */
function formatTimestamp(timestamp: string): string {
  try {
    return formatDistanceToNow(new Date(timestamp), { addSuffix: true })
  } catch {
    return 'Unknown'
  }
}

/**
 * ActivityFeed component
 * Displays a vertical scrollable list of recent activities with time-based grouping
 *
 * @component
 * @example
 * ```tsx
 * <ActivityFeed
 *   activities={activities}
 *   isLoading={false}
 * />
 * ```
 */
export function ActivityFeed({ activities, isLoading = false }: ActivityFeedProps) {
  // Sort activities by timestamp (newest first)
  const sortedActivities = [...activities].sort(
    (a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
  )

  // Group activities by time period
  const groupedActivities = groupActivitiesByTime(sortedActivities)

  if (isLoading) {
    return (
      <Card className="rounded-2xl">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <ActivityIcon className="h-5 w-5 text-primary" />
            Recent Activity
          </CardTitle>
          <CardDescription>Loading activity feed...</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="flex gap-3 animate-pulse">
              <div className="h-10 w-10 rounded-xl bg-muted" />
              <div className="flex-1 space-y-2">
                <div className="h-4 w-3/4 rounded bg-muted" />
                <div className="h-3 w-1/2 rounded bg-muted" />
              </div>
            </div>
          ))}
        </CardContent>
      </Card>
    )
  }

  if (activities.length === 0) {
    return (
      <Card className="rounded-2xl">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <ActivityIcon className="h-5 w-5 text-primary" />
            Recent Activity
          </CardTitle>
          <CardDescription>Your recent project activities</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center py-12 text-center">
          <div className="rounded-full bg-muted p-6 mb-4">
            <ActivityIcon className="h-8 w-8 text-muted-foreground" />
          </div>
          <p className="text-sm text-muted-foreground mb-1">No recent activity</p>
          <p className="text-xs text-muted-foreground">
            Your project updates will appear here
          </p>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="rounded-2xl">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <ActivityIcon className="h-5 w-5 text-primary" />
          Recent Activity
        </CardTitle>
        <CardDescription>Your recent project activities</CardDescription>
      </CardHeader>
      <CardContent className="max-h-[600px] overflow-y-auto scrollbar-thin scrollbar-thumb-muted scrollbar-track-transparent">
        <div className="space-y-6">
          {Array.from(groupedActivities.entries()).map(([timeGroup, groupActivities]) => (
            <div key={timeGroup} className="space-y-3">
              {/* Time group header */}
              <div className="flex items-center gap-2 px-1">
                <Clock className="h-3.5 w-3.5 text-muted-foreground" />
                <h3 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                  {timeGroup}
                </h3>
              </div>

              {/* Activities in this time group */}
              <div className="space-y-2">
                {groupActivities.map((activity, index) => {
                  const config = getActivityConfig(activity.type)
                  return (
                    <motion.div
                      key={activity.id}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                    >
                      <div
                        className={cn(
                          'group relative rounded-2xl border p-4 transition-all',
                          'hover:border-primary/30 hover:shadow-sm',
                          'bg-gradient-to-br',
                          config.gradient
                        )}
                      >
                        <div className="flex gap-3">
                          {/* Activity icon */}
                          <div
                            className={cn(
                              'flex h-10 w-10 shrink-0 items-center justify-center rounded-xl transition-transform group-hover:scale-105',
                              config.bgColor
                            )}
                          >
                            <div className={config.iconColor}>{config.icon}</div>
                          </div>

                          {/* Activity details */}
                          <div className="flex-1 min-w-0 space-y-1">
                            <p className="text-sm font-medium leading-tight">
                              {activity.description}
                            </p>
                            <p className="text-xs text-muted-foreground truncate">
                              {activity.projectTitle}
                            </p>
                            <p className="text-xs text-muted-foreground">
                              {formatTimestamp(activity.timestamp)}
                            </p>
                          </div>
                        </div>

                        {/* Optional metadata display */}
                        {activity.metadata?.amount && (
                          <div className="mt-3 flex items-center gap-1.5 rounded-lg bg-background/60 px-3 py-1.5 text-xs w-fit">
                            <IndianRupee className="h-3 w-3 text-teal-600" />
                            <span className="font-semibold text-teal-700">
                              ₹{activity.metadata.amount.toLocaleString('en-IN')}
                            </span>
                          </div>
                        )}

                        {activity.metadata?.newStatus && (
                          <div className="mt-3 flex items-center gap-2 text-xs text-muted-foreground">
                            {activity.metadata.oldStatus && (
                              <>
                                <span className="capitalize">{activity.metadata.oldStatus.replace('_', ' ')}</span>
                                <ArrowRight className="h-3 w-3" />
                              </>
                            )}
                            <span className="capitalize font-medium text-foreground">
                              {activity.metadata.newStatus.replace('_', ' ')}
                            </span>
                          </div>
                        )}
                      </div>
                    </motion.div>
                  )
                })}
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
