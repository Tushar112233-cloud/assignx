/**
 * @fileoverview Individual notification item component with action handling.
 * @module components/notifications/notification-item
 */

"use client"

import {
  FileText,
  FileCheck,
  IndianRupee,
  UserPlus,
  Briefcase,
  CheckCircle,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Send,
  MessageSquare,
  Wallet,
  AlertCircle,
  Gift,
  Upload,
} from "lucide-react"

import { cn } from "@/lib/utils"
import { Badge } from "@/components/ui/badge"
import { Notification, NOTIFICATION_TYPE_CONFIG } from "./types"

const ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  FileText,
  FileCheck,
  IndianRupee,
  UserPlus,
  Briefcase,
  CheckCircle,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Send,
  MessageSquare,
  Wallet,
  AlertCircle,
  Gift,
  Upload,
}

interface NotificationItemProps {
  notification: Notification
  onMarkAsRead?: (id: string) => void
  onClick?: (notification: Notification) => void
}

export function NotificationItem({
  notification,
  onMarkAsRead,
  onClick,
}: NotificationItemProps) {
  const config = NOTIFICATION_TYPE_CONFIG[notification.type] || { label: "Notification", color: "text-gray-600", icon: "AlertCircle" }
  const IconComponent = ICONS[config.icon] || AlertCircle

  const formatTime = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diff = now.getTime() - date.getTime()

    const minutes = Math.floor(diff / (1000 * 60))
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))

    if (minutes < 1) return "Just now"
    if (minutes < 60) return `${minutes}m ago`
    if (hours < 24) return `${hours}h ago`
    if (days < 7) return `${days}d ago`

    return date.toLocaleDateString("en-IN", {
      day: "numeric",
      month: "short",
    })
  }

  return (
    <div
      className={cn(
        "flex items-start gap-3 px-4 py-3 border-b last:border-b-0 transition-colors",
        !notification.is_read && "bg-muted/30",
        onClick && "cursor-pointer hover:bg-muted/50"
      )}
      onClick={() => onClick?.(notification)}
    >
      {/* Icon */}
      <div
        className={cn(
          "h-9 w-9 rounded-full flex items-center justify-center shrink-0",
          notification.type === "payment_received" && "bg-green-100 dark:bg-green-900/30",
          notification.type === "project_submitted" && "bg-blue-100 dark:bg-blue-900/30",
          notification.type === "work_submitted" && "bg-amber-100 dark:bg-amber-900/30",
          notification.type === "qc_approved" && "bg-green-100 dark:bg-green-900/30",
          notification.type === "qc_rejected" && "bg-red-100 dark:bg-red-900/30",
          notification.type === "revision_requested" && "bg-orange-100 dark:bg-orange-900/30",
          notification.type === "new_message" && "bg-blue-100 dark:bg-blue-900/30",
          notification.type === "payout_processed" && "bg-green-100 dark:bg-green-900/30",
          notification.type === "system_alert" && "bg-gray-100 dark:bg-gray-900/30",
          notification.type === "promotional" && "bg-purple-100 dark:bg-purple-900/30"
        )}
      >
        <IconComponent className={cn("h-5 w-5", config.color)} />
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <p className={cn("text-sm font-medium truncate", !notification.is_read && "text-foreground")}>
            {notification.title}
          </p>
          {!notification.is_read && (
            <span className="h-2 w-2 rounded-full bg-primary shrink-0" />
          )}
        </div>
        <p className="text-sm text-muted-foreground line-clamp-2 mt-0.5">
          {notification.message}
        </p>
        <div className="flex items-center gap-2 mt-1">
          {notification.project_number && (
            <Badge variant="outline" className="text-xs">
              {notification.project_number}
            </Badge>
          )}
          <span className="text-xs text-muted-foreground">
            {formatTime(notification.created_at)}
          </span>
        </div>
      </div>
    </div>
  )
}
