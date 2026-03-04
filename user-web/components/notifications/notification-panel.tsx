"use client"

import { useState } from "react"
import {
  Bell,
  Check,
  CheckCheck,
  Trash2,
  Settings,
  Loader2,
  IndianRupee,
  MessageCircle,
  UserCheck,
  Package,
  RefreshCw,
  FileText,
  AlertCircle,
  ShieldCheck,
  ShieldX,
  Wallet,
  UserPlus,
  CheckCircle2,
  Star,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Switch } from "@/components/ui/switch"
import { cn } from "@/lib/utils"
import { useNotifications } from "@/hooks/useNotifications"
import type { Notification } from "@/services"

/**
 * Format relative time — safe against null / Invalid Date
 */
function formatRelativeTime(timestamp: string | null | undefined): string {
  if (!timestamp) return ""
  const date = new Date(timestamp)
  if (isNaN(date.getTime())) return ""

  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return "Just now"
  if (diffMins < 60) return `${diffMins}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`

  return date.toLocaleDateString("en-IN", { day: "numeric", month: "short" })
}

/**
 * Per-type icon + color config
 */
interface NotificationStyle {
  Icon: React.ElementType
  iconBg: string
  iconColor: string
  accent: string
}

function getNotificationStyle(type: string | null | undefined): NotificationStyle {
  switch (type) {
    case "doer_assigned":
    case "task_assigned":
    case "writer_assigned":
      return {
        Icon: UserCheck,
        iconBg: "bg-violet-100 dark:bg-violet-900/40",
        iconColor: "text-violet-600 dark:text-violet-400",
        accent: "bg-violet-500",
      }
    case "project_claimed":
    case "supervisor_assigned":
    case "project_assigned":
      return {
        Icon: UserPlus,
        iconBg: "bg-blue-100 dark:bg-blue-900/40",
        iconColor: "text-blue-600 dark:text-blue-400",
        accent: "bg-blue-500",
      }
    case "project_quoted":
    case "quote_ready":
      return {
        Icon: IndianRupee,
        iconBg: "bg-emerald-100 dark:bg-emerald-900/40",
        iconColor: "text-emerald-600 dark:text-emerald-400",
        accent: "bg-emerald-500",
      }
    case "payment_received":
    case "project_payment":
    case "top_up":
      return {
        Icon: Wallet,
        iconBg: "bg-green-100 dark:bg-green-900/40",
        iconColor: "text-green-600 dark:text-green-400",
        accent: "bg-green-500",
      }
    case "new_message":
      return {
        Icon: MessageCircle,
        iconBg: "bg-purple-100 dark:bg-purple-900/40",
        iconColor: "text-purple-600 dark:text-purple-400",
        accent: "bg-purple-500",
      }
    case "project_completed":
    case "auto_approved":
      return {
        Icon: CheckCircle2,
        iconBg: "bg-teal-100 dark:bg-teal-900/40",
        iconColor: "text-teal-600 dark:text-teal-400",
        accent: "bg-teal-500",
      }
    case "project_delivered":
      return {
        Icon: Package,
        iconBg: "bg-cyan-100 dark:bg-cyan-900/40",
        iconColor: "text-cyan-600 dark:text-cyan-400",
        accent: "bg-cyan-500",
      }
    case "revision_requested":
    case "in_revision":
      return {
        Icon: RefreshCw,
        iconBg: "bg-amber-100 dark:bg-amber-900/40",
        iconColor: "text-amber-600 dark:text-amber-400",
        accent: "bg-amber-500",
      }
    case "qc_approved":
      return {
        Icon: ShieldCheck,
        iconBg: "bg-green-100 dark:bg-green-900/40",
        iconColor: "text-green-600 dark:text-green-400",
        accent: "bg-green-500",
      }
    case "qc_rejected":
      return {
        Icon: ShieldX,
        iconBg: "bg-red-100 dark:bg-red-900/40",
        iconColor: "text-red-600 dark:text-red-400",
        accent: "bg-red-500",
      }
    case "project_submitted":
      return {
        Icon: FileText,
        iconBg: "bg-blue-100 dark:bg-blue-900/40",
        iconColor: "text-blue-600 dark:text-blue-400",
        accent: "bg-blue-500",
      }
    case "payout_processed":
      return {
        Icon: Star,
        iconBg: "bg-yellow-100 dark:bg-yellow-900/40",
        iconColor: "text-yellow-600 dark:text-yellow-400",
        accent: "bg-yellow-500",
      }
    case "system_alert":
      return {
        Icon: AlertCircle,
        iconBg: "bg-orange-100 dark:bg-orange-900/40",
        iconColor: "text-orange-600 dark:text-orange-400",
        accent: "bg-orange-500",
      }
    default:
      return {
        Icon: Bell,
        iconBg: "bg-muted",
        iconColor: "text-muted-foreground",
        accent: "bg-muted-foreground/40",
      }
  }
}

/**
 * Single notification item — rich, detailed, beautiful
 */
function NotificationItem({
  notification,
  onRead,
  onDelete,
}: {
  notification: Notification
  onRead: (id: string) => void
  onDelete: (id: string) => void
}) {
  const type = notification.type || notification.notification_type
  const style = getNotificationStyle(type)
  const { Icon } = style
  const isUnread = !notification.is_read
  const body = notification.message || notification.body
  const time = formatRelativeTime(notification.created_at)

  return (
    <div
      className={cn(
        "group relative flex items-start gap-3 px-4 py-3.5 transition-all hover:bg-muted/40",
        isUnread && "bg-primary/[0.03]"
      )}
    >
      {/* Unread accent bar */}
      {isUnread && (
        <span className={cn("absolute left-0 top-3 h-8 w-[3px] rounded-r-full", style.accent)} />
      )}

      {/* Icon */}
      <div className={cn("mt-0.5 flex-shrink-0 rounded-xl p-2.5", style.iconBg)}>
        <Icon className={cn("h-4 w-4", style.iconColor)} />
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <div className="flex items-start justify-between gap-2 mb-0.5">
          <p className={cn(
            "text-sm leading-snug",
            isUnread ? "font-semibold text-foreground" : "font-medium text-foreground/80"
          )}>
            {notification.title}
          </p>
          <div className="flex items-center gap-1.5 shrink-0">
            {isUnread && (
              <span className="h-1.5 w-1.5 rounded-full bg-primary mt-1" />
            )}
            {time && (
              <span className="text-[11px] text-muted-foreground whitespace-nowrap">{time}</span>
            )}
          </div>
        </div>

        {body && (
          <p className="text-xs text-muted-foreground leading-relaxed line-clamp-2 mt-0.5">
            {body}
          </p>
        )}
      </div>

      {/* Hover actions */}
      <div className="absolute right-3 top-3 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity bg-background/80 backdrop-blur-sm rounded-lg p-0.5 shadow-sm border border-border/50">
        {isUnread && (
          <Button
            variant="ghost"
            size="icon"
            className="h-7 w-7 text-muted-foreground hover:text-primary"
            onClick={() => onRead(notification.id)}
            title="Mark as read"
          >
            <Check className="h-3.5 w-3.5" />
          </Button>
        )}
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7 text-muted-foreground hover:text-destructive"
          onClick={() => onDelete(notification.id)}
          title="Delete"
        >
          <Trash2 className="h-3.5 w-3.5" />
        </Button>
      </div>
    </div>
  )
}

/**
 * Notification panel with popover
 */
interface NotificationPanelProps {
  userId: string
}

export function NotificationPanel({ userId }: NotificationPanelProps) {
  const [showSettings, setShowSettings] = useState(false)
  const {
    notifications,
    unreadCount,
    isLoading,
    hasMore,
    pushEnabled,
    pushSupported,
    subscribeToPush,
    unsubscribeFromPush,
    markAsRead,
    markAllAsRead,
    loadMore,
    deleteNotification,
  } = useNotifications(userId)

  const handlePushToggle = async (enabled: boolean) => {
    if (enabled) {
      await subscribeToPush()
    } else {
      await unsubscribeFromPush()
    }
  }

  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button variant="ghost" size="icon" className="relative">
          <Bell className="h-5 w-5" />
          {unreadCount > 0 && (
            <Badge
              variant="destructive"
              className="absolute -right-1 -top-1 flex h-5 min-w-5 items-center justify-center rounded-full p-0 text-xs"
            >
              {unreadCount > 99 ? "99+" : unreadCount}
            </Badge>
          )}
          <span className="sr-only">Notifications</span>
        </Button>
      </PopoverTrigger>

      <PopoverContent className="w-[400px] p-0" align="end">
        {/* Header */}
        <div className="flex items-center justify-between border-b px-4 py-3">
          <div className="flex items-center gap-2">
            <h3 className="font-semibold text-sm">Notifications</h3>
            {unreadCount > 0 && (
              <span className="inline-flex items-center justify-center h-5 min-w-5 rounded-full bg-primary text-primary-foreground text-[10px] font-bold px-1.5">
                {unreadCount}
              </span>
            )}
          </div>
          <div className="flex items-center gap-1">
            {unreadCount > 0 && (
              <Button
                variant="ghost"
                size="sm"
                className="h-7 gap-1.5 text-xs text-muted-foreground hover:text-foreground"
                onClick={markAllAsRead}
              >
                <CheckCheck className="h-3.5 w-3.5" />
                Mark all read
              </Button>
            )}
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7 text-muted-foreground hover:text-foreground"
              onClick={() => setShowSettings(!showSettings)}
            >
              <Settings className="h-3.5 w-3.5" />
              <span className="sr-only">Settings</span>
            </Button>
          </div>
        </div>

        {/* Settings panel */}
        {showSettings && (
          <div className="border-b px-4 py-3 bg-muted/30">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">Push Notifications</p>
                <p className="text-xs text-muted-foreground mt-0.5">
                  {pushSupported
                    ? "Get notified even when the app is closed"
                    : "Not supported in this browser"}
                </p>
              </div>
              <Switch
                checked={pushEnabled}
                onCheckedChange={handlePushToggle}
                disabled={!pushSupported}
              />
            </div>
          </div>
        )}

        {/* Notifications list */}
        <ScrollArea className="h-[420px]">
          {isLoading && notifications.length === 0 ? (
            <div className="flex h-32 items-center justify-center">
              <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />
            </div>
          ) : notifications.length === 0 ? (
            <div className="flex h-48 flex-col items-center justify-center text-center px-8">
              <div className="h-14 w-14 rounded-2xl bg-muted flex items-center justify-center mb-3">
                <Bell className="h-6 w-6 text-muted-foreground/60" />
              </div>
              <p className="text-sm font-medium mb-1">You're all caught up!</p>
              <p className="text-xs text-muted-foreground">
                New notifications about your projects will appear here.
              </p>
            </div>
          ) : (
            <>
              <div className="divide-y divide-border/60">
                {notifications.map((notification) => (
                  <NotificationItem
                    key={notification.id}
                    notification={notification}
                    onRead={markAsRead}
                    onDelete={deleteNotification}
                  />
                ))}
              </div>

              {hasMore && (
                <div className="p-4 border-t">
                  <Button
                    variant="ghost"
                    size="sm"
                    className="w-full text-xs text-muted-foreground hover:text-foreground"
                    onClick={loadMore}
                    disabled={isLoading}
                  >
                    {isLoading ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      "Load older notifications"
                    )}
                  </Button>
                </div>
              )}
            </>
          )}
        </ScrollArea>
      </PopoverContent>
    </Popover>
  )
}
