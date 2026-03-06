/**
 * @fileoverview Premium Header - Minimal design matching dashboard
 * Charcoal + Orange accent theme
 * @module components/layout/header-v2
 */

"use client"

import { useState } from "react"
import { Bell, Search, CheckCheck } from "lucide-react"
import { useRouter } from "next/navigation"

import { Button } from "@/components/ui/button"
import { SidebarTrigger } from "@/components/ui/sidebar"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"
import { apiFetch } from "@/lib/api/client"
import { useNotifications } from "@/hooks/use-notifications"
import { NotificationItem } from "@/components/notifications/notification-item"
import type { Notification as NotifType } from "@/components/notifications/types"

interface HeaderV2Props {
  userName?: string
  notificationCount?: number
  initialAvailability?: boolean
}

export function HeaderV2({
  userName,
  notificationCount = 0,
  initialAvailability = true,
}: HeaderV2Props) {
  const router = useRouter()
  const [isAvailable, setIsAvailable] = useState(initialAvailability)
  const [notifOpen, setNotifOpen] = useState(false)
  const {
    notifications: rawNotifs,
    unreadCount,
    markAsRead,
    markAllAsRead,
  } = useNotifications({ limit: 10 })

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

  const handleAvailabilityToggle = async () => {
    const newValue = !isAvailable
    setIsAvailable(newValue)
    try {
      await apiFetch("/api/supervisors/me", {
        method: "PUT",
        body: JSON.stringify({ is_available: newValue }),
      })
    } catch (err) {
      console.error("Failed to update availability:", err)
      setIsAvailable(!newValue)
    }
  }

  return (
    <header className="sticky top-0 z-40 flex h-16 items-center justify-between border-b border-gray-200 bg-white px-6 md:px-8 shadow-sm">
      <div className="flex items-center gap-6">
        <SidebarTrigger className="-ml-1 md:hidden text-gray-500 hover:text-[#F97316] transition-colors duration-300" />

        {/* Search Bar */}
        <div className="hidden md:flex items-center">
          <button className="group flex items-center gap-3 h-11 w-[280px] lg:w-[340px] px-4 rounded-xl bg-gray-50 border border-gray-200 hover:border-[#F97316]/40 hover:bg-white hover:shadow-md hover:shadow-orange-500/5 transition-all duration-300">
            <Search className="h-4 w-4 text-gray-400 group-hover:text-[#F97316] transition-colors duration-300" />
            <span className="text-sm text-gray-500 group-hover:text-gray-700 transition-colors duration-300">Search projects, doers...</span>
          </button>
        </div>
      </div>

      {/* Right Actions */}
      <div className="flex items-center gap-3">
        {/* Availability Toggle */}
        <button
          onClick={handleAvailabilityToggle}
          className={cn(
            "group flex items-center gap-3 h-10 pl-3.5 pr-2 rounded-xl transition-all duration-300 hover:scale-105",
            isAvailable
              ? "bg-emerald-50 hover:bg-emerald-100 border border-emerald-200"
              : "bg-gray-100 hover:bg-gray-200 border border-gray-200"
          )}
        >
          <div className={cn(
            "w-2 h-2 rounded-full transition-all duration-300",
            isAvailable ? "bg-emerald-500 shadow-lg shadow-emerald-500/50 animate-pulse" : "bg-gray-400"
          )} />
          <span className={cn(
            "text-xs font-medium transition-colors duration-300",
            isAvailable ? "text-emerald-700" : "text-gray-600"
          )}>
            {isAvailable ? "Available" : "Away"}
          </span>

          {/* Toggle Switch */}
          <div className={cn(
            "relative w-10 h-5 rounded-full transition-all duration-300",
            isAvailable ? "bg-emerald-500 shadow-md shadow-emerald-500/20" : "bg-gray-300"
          )}>
            <div className={cn(
              "absolute top-0.5 w-4 h-4 rounded-full bg-white shadow-md transition-all duration-300",
              isAvailable ? "left-[22px]" : "left-0.5"
            )} />
          </div>
        </button>

        {/* Divider */}
        <div className="w-px h-6 bg-gray-200" />

        {/* Notifications */}
        <Popover open={notifOpen} onOpenChange={setNotifOpen}>
          <PopoverTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="h-10 w-10 relative rounded-xl text-gray-500 hover:text-[#F97316] hover:bg-gray-100 transition-all duration-300 hover:scale-110"
            >
              <Bell className="h-5 w-5" />
              {displayCount > 0 && (
                <span className="absolute -top-1 -right-1 flex h-5 min-w-5 items-center justify-center rounded-full bg-gradient-to-br from-[#F97316] to-[#EA580C] px-1 text-[10px] font-bold text-white shadow-lg shadow-orange-500/50">
                  {displayCount > 9 ? "9+" : displayCount}
                </span>
              )}
            </Button>
          </PopoverTrigger>
          <PopoverContent align="end" className="w-96 p-0" sideOffset={8}>
            <div className="flex items-center justify-between px-4 py-3 border-b">
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
            <ScrollArea className="max-h-[400px]">
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
            <div className="border-t px-4 py-2">
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
