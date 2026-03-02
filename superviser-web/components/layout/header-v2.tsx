/**
 * @fileoverview Premium Header - Minimal design matching dashboard
 * Charcoal + Orange accent theme
 * @module components/layout/header-v2
 */

"use client"

import { useState } from "react"
import { Bell, Moon, Sun, Search } from "lucide-react"
import { useTheme } from "next-themes"
import Link from "next/link"

import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu"
import { SidebarTrigger } from "@/components/ui/sidebar"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"
import { apiFetch } from "@/lib/api/client"
import { LanguageSelector } from "@/components/language-selector"

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
  const { setTheme } = useTheme()
  const [isAvailable, setIsAvailable] = useState(initialAvailability)

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
        {/* Language Selector */}
        <LanguageSelector />

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

        {/* Theme Toggle */}
        <TooltipProvider delayDuration={300}>
          <Tooltip>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <TooltipTrigger asChild>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-10 w-10 rounded-xl text-gray-500 hover:text-[#F97316] hover:bg-gray-100 transition-all duration-300 hover:scale-110"
                  >
                    <Sun className="h-5 w-5 rotate-0 scale-100 transition-transform duration-300 dark:-rotate-90 dark:scale-0" />
                    <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-transform duration-300 dark:rotate-0 dark:scale-100" />
                    <span className="sr-only">Toggle theme</span>
                  </Button>
                </TooltipTrigger>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="bg-white border-gray-200 rounded-xl shadow-xl p-2 min-w-[150px]">
                <DropdownMenuItem
                  onClick={() => setTheme("light")}
                  className="text-gray-700 hover:text-[#1C1C1C] hover:bg-gray-50 rounded-lg cursor-pointer"
                >
                  <Sun className="mr-2 h-4 w-4 text-[#F97316]" />
                  Light
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={() => setTheme("dark")}
                  className="text-gray-700 hover:text-[#1C1C1C] hover:bg-gray-50 rounded-lg cursor-pointer"
                >
                  <Moon className="mr-2 h-4 w-4 text-[#F97316]" />
                  Dark
                </DropdownMenuItem>
                <DropdownMenuSeparator className="bg-gray-100 my-1" />
                <DropdownMenuItem
                  onClick={() => setTheme("system")}
                  className="text-gray-700 hover:text-[#1C1C1C] hover:bg-gray-50 rounded-lg cursor-pointer"
                >
                  System
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
            <TooltipContent side="bottom" className="bg-[#1C1C1C] text-white border-0 rounded-lg text-xs">
              Theme
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>

        {/* Notifications */}
        <TooltipProvider delayDuration={300}>
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="h-10 w-10 relative rounded-xl text-gray-500 hover:text-[#F97316] hover:bg-gray-100 transition-all duration-300 hover:scale-110"
                asChild
              >
                <Link href="/notifications">
                  <Bell className="h-5 w-5" />
                  {notificationCount > 0 && (
                    <span className="absolute -top-1 -right-1 flex h-5 min-w-5 items-center justify-center rounded-full bg-gradient-to-br from-[#F97316] to-[#EA580C] px-1 text-[10px] font-bold text-white shadow-lg shadow-orange-500/50">
                      {notificationCount > 9 ? "9+" : notificationCount}
                    </span>
                  )}
                </Link>
              </Button>
            </TooltipTrigger>
            <TooltipContent side="bottom" className="bg-[#1C1C1C] text-white border-0 rounded-lg text-xs">
              {notificationCount > 0 ? `${notificationCount} notifications` : "Notifications"}
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>
    </header>
  )
}
