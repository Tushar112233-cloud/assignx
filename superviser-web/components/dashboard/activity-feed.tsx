"use client"

import { useMemo } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { 
  FolderPlus, 
  CheckCircle2, 
  Wallet, 
  MessageSquare, 
  UserPlus,
  AlertCircle,
  Clock
} from "lucide-react"
import { cn } from "@/lib/utils"
import { formatDistanceToNow } from "date-fns"

type ActivityType = 
  | "request" 
  | "completion" 
  | "payment" 
  | "message" 
  | "assignment" 
  | "urgent"

interface ActivityItem {
  id: string
  type: ActivityType
  title: string
  description: string
  timestamp: Date
  metadata?: {
    projectId?: string
    amount?: number
    userName?: string
  }
}

interface ActivityFeedProps {
  items: ActivityItem[]
  isLoading?: boolean
  maxItems?: number
}

const activityConfig: Record<ActivityType, {
  icon: React.ElementType
  color: string
  bgColor: string
}> = {
  request: {
    icon: FolderPlus,
    color: "text-blue-400",
    bgColor: "bg-blue-500/10",
  },
  completion: {
    icon: CheckCircle2,
    color: "text-emerald-400",
    bgColor: "bg-emerald-500/10",
  },
  payment: {
    icon: Wallet,
    color: "text-[var(--dash-highlight)]",
    bgColor: "bg-[var(--dash-highlight)]/10",
  },
  message: {
    icon: MessageSquare,
    color: "text-[var(--dash-accent)]",
    bgColor: "bg-[var(--dash-accent)]/10",
  },
  assignment: {
    icon: UserPlus,
    color: "text-purple-400",
    bgColor: "bg-purple-500/10",
  },
  urgent: {
    icon: AlertCircle,
    color: "text-rose-400",
    bgColor: "bg-rose-500/10",
  },
}

function ActivityItemCard({ item, index }: { item: ActivityItem; index: number }) {
  const config = activityConfig[item.type]
  const Icon = config.icon

  return (
    <div 
      className={cn(
        "flex gap-3 p-3 rounded-lg transition-colors hover:bg-[var(--dash-surface-hover)] cursor-pointer group",
        "animate-enter"
      )}
      style={{ animationDelay: `${index * 50}ms` }}
    >
      {/* Icon */}
      <div className={cn(
        "h-8 w-8 rounded-lg flex items-center justify-center flex-shrink-0",
        config.bgColor
      )}>
        <Icon className={cn("h-4 w-4", config.color)} />
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <div className="flex items-start justify-between gap-2">
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-white group-hover:text-[var(--dash-accent)] transition-colors truncate">
              {item.title}
            </p>
            <p className="text-xs text-[var(--dash-text-muted)] mt-0.5 line-clamp-2">
              {item.description}
            </p>
          </div>
          <span className="text-[10px] text-[var(--dash-text-muted)] flex-shrink-0">
            {formatDistanceToNow(item.timestamp, { addSuffix: true })}
          </span>
        </div>

        {/* Metadata */}
        {item.metadata?.amount && (
          <div className="mt-1.5 inline-flex items-center px-2 py-0.5 rounded text-[10px] font-medium bg-[var(--dash-highlight)]/10 text-[var(--dash-highlight)]">
            +₹{item.metadata.amount.toLocaleString()}
          </div>
        )}
      </div>
    </div>
  )
}

function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-8 text-center">
      <div className="h-12 w-12 rounded-full bg-[var(--dash-surface)] border border-[var(--dash-border)] flex items-center justify-center mb-3">
        <Clock className="h-5 w-5 text-[var(--dash-text-muted)]" />
      </div>
      <p className="text-sm text-[var(--dash-text-secondary)]">No recent activity</p>
      <p className="text-xs text-[var(--dash-text-muted)] mt-1">
        Activity will appear here as projects progress
      </p>
    </div>
  )
}

export function ActivityFeed({ items, isLoading, maxItems = 6 }: ActivityFeedProps) {
  const displayItems = useMemo(() => {
    return items.slice(0, maxItems)
  }, [items, maxItems])

  if (isLoading) {
    return (
      <Card className="dash-card">
        <CardHeader className="pb-3">
          <CardTitle className="text-base text-white flex items-center gap-2">
            Activity Feed
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--dash-accent)] opacity-75" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-[var(--dash-accent)]" />
            </span>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="flex gap-3">
              <Skeleton className="h-8 w-8 rounded-lg flex-shrink-0" />
              <div className="flex-1 space-y-2">
                <Skeleton className="h-4 w-3/4" />
                <Skeleton className="h-3 w-1/2" />
              </div>
            </div>
          ))}
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="dash-card overflow-hidden">
      <CardHeader className="pb-3 border-b border-[var(--dash-border)]">
        <div className="flex items-center justify-between">
          <CardTitle className="text-base text-white flex items-center gap-2">
            Activity Feed
            {items.length > 0 && (
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--dash-accent)] opacity-75" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[var(--dash-accent)]" />
              </span>
            )}
          </CardTitle>
          <span className="text-xs text-[var(--dash-text-muted)]">
            Live
          </span>
        </div>
      </CardHeader>
      <CardContent className="p-0">
        {displayItems.length === 0 ? (
          <EmptyState />
        ) : (
          <div className="divide-y divide-[var(--dash-border)]/50">
            {displayItems.map((item, index) => (
              <ActivityItemCard key={item.id} item={item} index={index} />
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

// Helper function to generate sample activity data
export function generateSampleActivities(
  newRequests: Array<{ id: string; title: string; user_name: string }>,
  completedProjects: Array<{ id: string; title: string }>,
  payments: Array<{ id: string; amount: number }>
): ActivityItem[] {
  const activities: ActivityItem[] = []

  // Add new requests
  newRequests.forEach((req, i) => {
    activities.push({
      id: `req-${req.id}`,
      type: i === 0 ? "urgent" : "request",
      title: i === 0 ? "Urgent: New request received" : "New request received",
      description: `${req.title} - ${req.user_name}`,
      timestamp: new Date(Date.now() - i * 1000 * 60 * 30),
      metadata: { projectId: req.id },
    })
  })

  // Add completed projects
  completedProjects.forEach((proj, i) => {
    activities.push({
      id: `comp-${proj.id}`,
      type: "completion",
      title: "Project completed",
      description: proj.title,
      timestamp: new Date(Date.now() - (i + 2) * 1000 * 60 * 60),
      metadata: { projectId: proj.id },
    })
  })

  // Add payments
  payments.forEach((payment, i) => {
    activities.push({
      id: `pay-${payment.id}`,
      type: "payment",
      title: "Payment received",
      description: "Project payment processed",
      timestamp: new Date(Date.now() - (i + 1) * 1000 * 60 * 60 * 2),
      metadata: { amount: payment.amount },
    })
  })

  // Sort by timestamp (newest first)
  return activities.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
}
