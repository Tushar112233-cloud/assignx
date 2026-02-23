"use client"

import { useState } from "react"
import { Bell, Check, CheckCheck, Trash2, Settings, Loader2 } from "lucide-react"
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
 * Format relative time
 */
function formatRelativeTime(timestamp: string): string {
  const date = new Date(timestamp)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return "Just now"
  if (diffMins < 60) return `${diffMins}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`

  return date.toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
  })
}

/**
 * Get notification icon based on type
 */
function getNotificationStyle(type: string): { bg: string; text: string } {
  switch (type) {
    case "project_update":
      return { bg: "bg-blue-100 dark:bg-blue-900/30", text: "text-blue-600 dark:text-blue-400" }
    case "payment":
      return { bg: "bg-green-100 dark:bg-green-900/30", text: "text-green-600 dark:text-green-400" }
    case "message":
      return { bg: "bg-purple-100 dark:bg-purple-900/30", text: "text-purple-600 dark:text-purple-400" }
    case "system":
      return { bg: "bg-gray-100 dark:bg-gray-900/30", text: "text-gray-600 dark:text-gray-400" }
    default:
      return { bg: "bg-primary/10", text: "text-primary" }
  }
}

/**
 * Single notification item
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
  const style = getNotificationStyle(notification.notification_type)

  return (
    <div
      className={cn(
        "group flex items-start gap-3 px-4 py-3 transition-colors hover:bg-muted/50",
        !notification.is_read && "bg-primary/5"
      )}
    >
      {/* Icon */}
      <div className={cn("mt-0.5 rounded-full p-2", style.bg)}>
        <Bell className={cn("h-4 w-4", style.text)} />
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <div className="flex items-start justify-between gap-2">
          <p className={cn("text-sm font-medium", !notification.is_read && "text-foreground")}>
            {notification.title}
          </p>
          <span className="shrink-0 text-xs text-muted-foreground">
            {notification.created_at && formatRelativeTime(notification.created_at)}
          </span>
        </div>
        <p className="mt-0.5 text-sm text-muted-foreground line-clamp-2">
          {notification.body}
        </p>
      </div>

      {/* Actions */}
      <div className="flex shrink-0 gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        {!notification.is_read && (
          <Button
            variant="ghost"
            size="icon"
            className="h-7 w-7"
            onClick={() => onRead(notification.id)}
          >
            <Check className="h-4 w-4" />
            <span className="sr-only">Mark as read</span>
          </Button>
        )}
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7 text-destructive hover:text-destructive"
          onClick={() => onDelete(notification.id)}
        >
          <Trash2 className="h-4 w-4" />
          <span className="sr-only">Delete</span>
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

  /**
   * Handle push toggle
   */
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

      <PopoverContent className="w-96 p-0" align="end">
        {/* Header */}
        <div className="flex items-center justify-between border-b px-4 py-3">
          <h3 className="font-semibold">Notifications</h3>
          <div className="flex items-center gap-2">
            {unreadCount > 0 && (
              <Button
                variant="ghost"
                size="sm"
                className="h-8 gap-1 text-xs"
                onClick={markAllAsRead}
              >
                <CheckCheck className="h-4 w-4" />
                Mark all read
              </Button>
            )}
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8"
              onClick={() => setShowSettings(!showSettings)}
            >
              <Settings className="h-4 w-4" />
              <span className="sr-only">Settings</span>
            </Button>
          </div>
        </div>

        {/* Settings panel */}
        {showSettings && (
          <div className="border-b px-4 py-3">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">Push Notifications</p>
                <p className="text-xs text-muted-foreground">
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
        <ScrollArea className="h-[400px]">
          {isLoading && notifications.length === 0 ? (
            <div className="flex h-32 items-center justify-center">
              <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
            </div>
          ) : notifications.length === 0 ? (
            <div className="flex h-32 flex-col items-center justify-center text-center">
              <Bell className="h-8 w-8 text-muted-foreground/50" />
              <p className="mt-2 text-sm text-muted-foreground">No notifications yet</p>
            </div>
          ) : (
            <>
              <div className="divide-y">
                {notifications.map((notification) => (
                  <NotificationItem
                    key={notification.id}
                    notification={notification}
                    onRead={markAsRead}
                    onDelete={deleteNotification}
                  />
                ))}
              </div>

              {/* Load more */}
              {hasMore && (
                <div className="p-4">
                  <Button
                    variant="outline"
                    size="sm"
                    className="w-full"
                    onClick={loadMore}
                    disabled={isLoading}
                  >
                    {isLoading ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      "Load more"
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
