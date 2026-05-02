/**
 * @fileoverview Professional application header with navigation controls and user menu.
 * @module components/layout/header
 */

"use client"

import { useState } from "react"
import { Bell, Search, Command, TrendingUp, Zap, CheckCheck } from "lucide-react"
import Link from "next/link"
import { useRouter } from "next/navigation"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Switch } from "@/components/ui/switch"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { ScrollArea } from "@/components/ui/scroll-area"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"
import { apiFetch } from "@/lib/api/client"
import { useNotifications } from "@/hooks/use-notifications"
import { NotificationItem } from "@/components/notifications/notification-item"
import type { Notification as NotifType } from "@/components/notifications/types"

interface HeaderProps {
  userName?: string
  notificationCount?: number
  userId?: string
  initialAvailability?: boolean
  pendingQCCount?: number
  activeProjectsCount?: number
}

export function Header({
  userName,
  notificationCount = 0,
  initialAvailability = true,
  pendingQCCount = 0,
  activeProjectsCount = 0,
}: HeaderProps) {
  const router = useRouter()
  const [isAvailable, setIsAvailable] = useState(initialAvailability)
  const [notifOpen, setNotifOpen] = useState(false)
  const {
    notifications: rawNotifs,
    unreadCount,
    markAsRead,
    markAllAsRead,
  } = useNotifications({ limit: 10 })

  // Map DB notifications to the component Notification shape
  const recentNotifs: NotifType[] = rawNotifs.slice(0, 8).map((n) => {
    const raw = n as unknown as Record<string, unknown>
    return {
      id: (raw._id as string) || n.id,
      type: (raw.type as NotifType["type"]) || (raw.notification_type as NotifType["type"]) || "system_alert",
      title: (raw.title as string) || "Notification",
      message: (raw.message as string) || (raw.body as string) || "",
      project_id: undefined,
      project_number: undefined,
      action_url: (raw.action_url as string) || undefined,
      is_read: (raw.isRead as boolean) || (raw.is_read as boolean) || false,
      created_at: (raw.createdAt as string) || n.created_at || new Date().toISOString(),
    }
  })

  const displayCount = unreadCount || notificationCount

  const handleAvailabilityToggle = async (checked: boolean) => {
    setIsAvailable(checked)
    try {
      await apiFetch("/api/supervisors/me", {
        method: "PUT",
        body: JSON.stringify({ is_available: checked }),
      })
    } catch (err) {
      console.error("Failed to update availability:", err)
      setIsAvailable(!checked)
    }
  }

  const firstName = userName?.split(" ")[0] || "Supervisor"
  const greeting = getGreeting()

  function getGreeting() {
    const hour = new Date().getHours()
    if (hour < 12) return "Good morning"
    if (hour < 17) return "Good afternoon"
    return "Good evening"
  }

  return (
    <header className="sticky top-0 z-40 flex h-16 items-center gap-4 border-b bg-background/80 backdrop-blur-xl supports-[backdrop-filter]:bg-background/60 px-4 md:px-6">
      <SidebarTrigger className="-ml-1 md:hidden" />
      <Separator orientation="vertical" className="h-6 md:hidden" />

      {/* Left Section - Greeting & Quick Stats */}
      <div className="flex items-center gap-4 flex-1">
        <div className="hidden sm:block">
          <p className="text-sm text-muted-foreground">{greeting},</p>
          <h1 className="text-lg font-semibold tracking-tight leading-none">
            {firstName}
          </h1>
        </div>

        {/* Quick Stats Pills - Hidden on mobile */}
        <div className="hidden lg:flex items-center gap-2 ml-4">
          {activeProjectsCount > 0 && (
            <Link href="/projects?tab=ongoing">
              <Badge
                variant="secondary"
                className="gap-1.5 py-1 px-2.5 hover:bg-secondary/80 transition-colors cursor-pointer"
              >
                <TrendingUp className="h-3 w-3 text-blue-500" />
                <span className="font-medium">{activeProjectsCount}</span>
                <span className="text-muted-foreground">active</span>
              </Badge>
            </Link>
          )}
          {pendingQCCount > 0 && (
            <Link href="/projects?tab=review">
              <Badge
                variant="secondary"
                className="gap-1.5 py-1 px-2.5 hover:bg-secondary/80 transition-colors cursor-pointer bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-400 border-amber-200 dark:border-amber-800"
              >
                <Zap className="h-3 w-3" />
                <span className="font-medium">{pendingQCCount}</span>
                <span>pending QC</span>
              </Badge>
            </Link>
          )}
        </div>
      </div>

      {/* Right Section - Actions */}
      <div className="flex items-center gap-2 md:gap-3">
        {/* Search Button */}
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                variant="ghost"
                size="sm"
                className="hidden md:flex items-center gap-2 text-muted-foreground hover:text-foreground h-9 px-3"
              >
                <Search className="h-4 w-4" />
                <span className="text-sm">Search</span>
                <kbd className="pointer-events-none hidden h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium opacity-100 sm:flex">
                  <Command className="h-3 w-3" />K
                </kbd>
              </Button>
            </TooltipTrigger>
            <TooltipContent>
              <p>Search projects, doers, users...</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>

        <Separator orientation="vertical" className="h-6 hidden md:block" />

        {/* Availability Toggle */}
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <div
                className={cn(
                  "flex items-center gap-2.5 px-3 py-1.5 rounded-full border transition-all duration-300",
                  isAvailable
                    ? "bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800"
                    : "bg-muted border-border"
                )}
              >
                <div className="flex items-center gap-2">
                  <span
                    className={cn(
                      "h-2 w-2 rounded-full transition-all duration-300",
                      isAvailable
                        ? "bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.6)] animate-pulse-subtle"
                        : "bg-gray-400"
                    )}
                  />
                  <span className={cn(
                    "text-sm font-medium hidden sm:inline transition-colors",
                    isAvailable ? "text-green-700 dark:text-green-400" : "text-muted-foreground"
                  )}>
                    {isAvailable ? "Available" : "Busy"}
                  </span>
                </div>
                <Switch
                  checked={isAvailable}
                  onCheckedChange={handleAvailabilityToggle}
                  className="h-5 w-9 data-[state=checked]:bg-green-500"
                />
              </div>
            </TooltipTrigger>
            <TooltipContent side="bottom">
              <p>{isAvailable ? "You're receiving new project requests" : "You're not receiving new requests"}</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>

        <Separator orientation="vertical" className="h-6 hidden sm:block" />

        {/* Notifications */}
        <Popover open={notifOpen} onOpenChange={setNotifOpen}>
          <PopoverTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="h-9 w-9 relative rounded-full"
            >
              <Bell className="h-4 w-4" />
              {displayCount > 0 && (
                <span className="absolute -top-0.5 -right-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-red-500 px-1 text-[10px] font-bold text-white animate-bounce-subtle">
                  {displayCount > 9 ? "9+" : displayCount}
                </span>
              )}
              <span className="sr-only">
                {displayCount > 0 ? `${displayCount} notifications` : "No notifications"}
              </span>
            </Button>
          </PopoverTrigger>
          <PopoverContent align="end" className="w-96 p-0 flex flex-col max-h-[500px]" sideOffset={8}>
            <div className="flex items-center justify-between px-4 py-3 border-b shrink-0">
              <h4 className="text-sm font-semibold">Notifications</h4>
              {unreadCount > 0 && (
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-7 text-xs gap-1"
                  onClick={() => markAllAsRead()}
                >
                  <CheckCheck className="h-3 w-3" />
                  Mark all read
                </Button>
              )}
            </div>
            <ScrollArea className="flex-1 min-h-0">
              {recentNotifs.length === 0 ? (
                <div className="text-center py-8">
                  <Bell className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                  <p className="text-sm text-muted-foreground">No notifications yet</p>
                </div>
              ) : (
                recentNotifs.map((notif) => (
                  <NotificationItem
                    key={notif.id}
                    notification={notif}
                    onMarkAsRead={(id) => markAsRead(id)}
                    onClick={(n) => {
                      if (!n.is_read) markAsRead(n.id)
                      setNotifOpen(false)
                      if (n.action_url) router.push(n.action_url)
                    }}
                  />
                ))
              )}
            </ScrollArea>
            <div className="border-t px-4 py-2 shrink-0 bg-background">
              <Button
                variant="ghost"
                size="sm"
                className="w-full text-xs"
                onClick={() => {
                  setNotifOpen(false)
                  router.push("/notifications")
                }}
              >
                View all notifications
              </Button>
            </div>
          </PopoverContent>
        </Popover>
      </div>
    </header>
  )
}
