/**
 * @fileoverview Professional application header with navigation controls and user menu.
 * @module components/layout/header
 */

"use client"

import { useState } from "react"
import { Bell, Moon, Sun, Search, Command, Sparkles, TrendingUp, Zap } from "lucide-react"
import { useTheme } from "next-themes"
import Link from "next/link"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
  DropdownMenuLabel,
} from "@/components/ui/dropdown-menu"
import { SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Switch } from "@/components/ui/switch"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { LanguageSelector } from "@/components/language-selector"
import { cn } from "@/lib/utils"
import { apiFetch } from "@/lib/api/client"

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
  const { theme, setTheme } = useTheme()
  const [isAvailable, setIsAvailable] = useState(initialAvailability)

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
        {/* Language Selector */}
        <LanguageSelector />

        <Separator orientation="vertical" className="h-6 hidden sm:block" />

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

        {/* Theme Toggle */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="h-9 w-9 rounded-full">
              <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
              <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
              <span className="sr-only">Toggle theme</span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-36">
            <DropdownMenuLabel className="text-xs font-normal text-muted-foreground">
              Appearance
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={() => setTheme("light")}
              className={cn(theme === "light" && "bg-accent")}
            >
              <Sun className="mr-2 h-4 w-4" />
              Light
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={() => setTheme("dark")}
              className={cn(theme === "dark" && "bg-accent")}
            >
              <Moon className="mr-2 h-4 w-4" />
              Dark
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={() => setTheme("system")}
              className={cn(theme === "system" && "bg-accent")}
            >
              <Sparkles className="mr-2 h-4 w-4" />
              System
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>

        {/* Notifications */}
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="h-9 w-9 relative rounded-full"
                asChild
              >
                <Link href="/notifications">
                  <Bell className="h-4 w-4" />
                  {notificationCount > 0 && (
                    <span className="absolute -top-0.5 -right-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-red-500 px-1 text-[10px] font-bold text-white animate-bounce-subtle">
                      {notificationCount > 9 ? "9+" : notificationCount}
                    </span>
                  )}
                  <span className="sr-only">
                    {notificationCount > 0 ? `${notificationCount} notifications` : "No notifications"}
                  </span>
                </Link>
              </Button>
            </TooltipTrigger>
            <TooltipContent>
              <p>{notificationCount > 0 ? `${notificationCount} new notifications` : "No new notifications"}</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>
    </header>
  )
}
