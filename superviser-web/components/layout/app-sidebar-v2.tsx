/**
 * @fileoverview Premium Sidebar V2 - Light theme command center navigation.
 * Clean whites with refined typography and subtle accents.
 * @module components/layout/app-sidebar-v2
 */

"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  LayoutDashboard,
  FolderKanban,
  Users,
  UserCircle,
  MessageSquare,
  Wallet,
  BookOpen,
  User,
  Settings,
  HelpCircle,
  LogOut,
  ChevronUp,
  Command,
} from "lucide-react"

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarMenuBadge,
} from "@/components/ui/sidebar"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
  DropdownMenuLabel,
} from "@/components/ui/dropdown-menu"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { APP_NAME } from "@/lib/constants"
import { cn } from "@/lib/utils"
import { createClient } from "@/lib/supabase/client"

const mainNavItems = [
  {
    title: "Dashboard",
    href: "/dashboard",
    icon: LayoutDashboard,
  },
  {
    title: "Projects",
    href: "/projects",
    icon: FolderKanban,
  },
  {
    title: "Doers",
    href: "/doers",
    icon: Users,
  },
  {
    title: "Users",
    href: "/users",
    icon: UserCircle,
  },
  {
    title: "Messages",
    href: "/chat",
    icon: MessageSquare,
  },
  {
    title: "Earnings",
    href: "/earnings",
    icon: Wallet,
  },
  {
    title: "Resources",
    href: "/resources",
    icon: BookOpen,
  },
]

const secondaryNavItems = [
  { title: "Profile", href: "/profile", icon: User },
  { title: "Settings", href: "/settings", icon: Settings },
  { title: "Support", href: "/support", icon: HelpCircle },
]

interface AppSidebarV2Props {
  user?: {
    name: string
    email: string
    avatarUrl?: string | null
  }
  unreadChats?: number
  pendingProjects?: number
}

export function AppSidebarV2({ user, unreadChats = 0, pendingProjects = 0 }: AppSidebarV2Props) {
  const pathname = usePathname()

  const isActive = (href: string) => {
    if (href === "/dashboard") return pathname === "/dashboard"
    return pathname.startsWith(href)
  }

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  return (
    <Sidebar className="border-r border-gray-200 bg-white shadow-xl">
      {/* Header */}
      <SidebarHeader className="h-16 border-b border-gray-100 px-4 bg-white">
        <Link
          href="/dashboard"
          className="flex items-center gap-3 py-2 transition-all duration-300 hover:scale-105"
        >
          <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-gradient-to-br from-[#F97316] to-[#EA580C]">
            <Command className="h-5 w-5 text-white" />
          </div>
          <div className="flex flex-col">
            <span className="font-semibold text-sm text-[#1C1C1C] tracking-tight">
              {APP_NAME}
            </span>
            <span className="text-[10px] text-[#F97316] font-bold tracking-wide uppercase">
              Supervisor
            </span>
          </div>
        </Link>
      </SidebarHeader>

      <SidebarContent className="px-3 bg-white overflow-hidden">
        {/* Main Navigation */}
        <SidebarGroup className="py-3">
          <SidebarGroupContent>
            <SidebarMenu className="space-y-1">
              {mainNavItems.map((item) => {
                const active = isActive(item.href)
                const showBadge =
                  (item.href === "/chat" && unreadChats > 0) ||
                  (item.href === "/projects" && pendingProjects > 0)
                const badgeCount = item.href === "/chat" ? unreadChats : pendingProjects

                return (
                  <SidebarMenuItem key={item.href}>
                    <SidebarMenuButton
                      asChild
                      isActive={active}
                      className={cn(
                        "relative py-2.5 px-3.5 rounded-xl transition-all duration-300",
                        active
                          ? "bg-[#1C1C1C] text-white shadow-lg hover:bg-[#2D2D2D]"
                          : "text-gray-600 hover:text-[#1C1C1C] hover:bg-gray-50 hover:scale-105"
                      )}
                    >
                      <Link href={item.href}>
                        <item.icon className={cn(
                          "h-5 w-5 transition-all duration-300",
                          active ? "text-[#F97316]" : "text-[#F97316]"
                        )} />
                        <span className="font-medium text-[13px]">{item.title}</span>
                        {showBadge && badgeCount > 0 && (
                          <SidebarMenuBadge
                            className={cn(
                              "min-w-5 h-5 text-[10px] font-bold rounded-lg",
                              item.href === "/projects"
                                ? "bg-[#F97316] text-white"
                                : "bg-rose-500 text-white shadow-lg shadow-rose-500/40"
                            )}
                          >
                            {badgeCount > 9 ? "9+" : badgeCount}
                          </SidebarMenuBadge>
                        )}
                        {active && (
                          <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-8 bg-[#F97316] rounded-r-full" />
                        )}
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Divider */}
        <div className="mx-3 h-px bg-gradient-to-r from-transparent via-gray-200 to-transparent" />

        {/* Secondary Navigation */}
        <SidebarGroup className="py-3">
          <SidebarGroupContent>
            <SidebarMenu className="space-y-1">
              {secondaryNavItems.map((item) => {
                const active = isActive(item.href)
                return (
                  <SidebarMenuItem key={item.href}>
                    <SidebarMenuButton
                      asChild
                      isActive={active}
                      className={cn(
                        "relative py-2 px-3.5 rounded-xl transition-all duration-300",
                        active
                          ? "bg-gray-100 text-[#1C1C1C]"
                          : "text-gray-500 hover:text-[#1C1C1C] hover:bg-gray-50 hover:scale-105"
                      )}
                    >
                      <Link href={item.href}>
                        <item.icon className={cn(
                          "h-4 w-4 transition-all duration-300",
                          active ? "text-[#F97316]" : "text-[#F97316]"
                        )} />
                        <span className="text-[13px]">{item.title}</span>
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      {/* Footer */}
      <SidebarFooter className="border-t border-gray-100 p-3 bg-white">
        <SidebarMenu>
          <SidebarMenuItem>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <SidebarMenuButton className="w-full py-2.5 px-2.5 rounded-xl hover:bg-gray-50 transition-all duration-300 hover:scale-[1.02] overflow-visible">
                  <Avatar className="h-9 w-9 ring-2 ring-[#F97316]/20 hover:ring-[#F97316]/40 transition-all duration-300">
                    <AvatarImage src={user?.avatarUrl || undefined} />
                    <AvatarFallback className="bg-gradient-to-br from-[#F97316] to-[#EA580C] text-white text-xs font-semibold">
                      {user?.name ? getInitials(user.name) : "S"}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex flex-col items-start text-left flex-1 min-w-0">
                    <span className="text-sm font-medium text-[#1C1C1C] truncate max-w-[120px]">
                      {user?.name || "Supervisor"}
                    </span>
                    <span className="text-[11px] text-gray-500 truncate max-w-[120px]">
                      {user?.email || "supervisor@assignx.com"}
                    </span>
                  </div>
                  <ChevronUp className="h-4 w-4 text-gray-400 group-hover:text-[#F97316] transition-colors duration-300" />
                </SidebarMenuButton>
              </DropdownMenuTrigger>
              <DropdownMenuContent
                side="top"
                align="start"
                className="w-[--radix-dropdown-menu-trigger-width] min-w-56 bg-white border-gray-200"
              >
                <DropdownMenuLabel className="font-normal">
                  <div className="flex items-center gap-3 py-1">
                    <Avatar className="h-9 w-9 ring-2 ring-[#F97316]/30">
                      <AvatarImage src={user?.avatarUrl || undefined} />
                      <AvatarFallback className="bg-gradient-to-br from-[#F97316] to-[#EA580C] text-white font-semibold">
                        {user?.name ? getInitials(user.name) : "S"}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex flex-col">
                      <span className="font-semibold text-[#1C1C1C]">{user?.name || "Supervisor"}</span>
                      <span className="text-xs text-gray-500">
                        {user?.email || "supervisor@assignx.com"}
                      </span>
                    </div>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator className="bg-gray-100" />
                <DropdownMenuItem asChild className="gap-2 cursor-pointer text-gray-700 hover:text-[#1C1C1C] hover:bg-gray-50 focus:bg-gray-50">
                  <Link href="/profile">
                    <User className="h-4 w-4 text-[#F97316]" />
                    Profile
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild className="gap-2 cursor-pointer text-gray-700 hover:text-[#1C1C1C] hover:bg-gray-50 focus:bg-gray-50">
                  <Link href="/settings">
                    <Settings className="h-4 w-4 text-[#F97316]" />
                    Settings
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild className="gap-2 cursor-pointer text-gray-700 hover:text-[#1C1C1C] hover:bg-gray-50 focus:bg-gray-50">
                  <Link href="/support">
                    <HelpCircle className="h-4 w-4 text-[#F97316]" />
                    Help & Support
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator className="bg-gray-100" />
                <DropdownMenuItem
                  className="gap-2 text-rose-600 hover:text-rose-700 focus:text-rose-700 focus:bg-rose-50 cursor-pointer"
                  onClick={async () => {
                    try {
                      await fetch('/api/auth/logout', { method: 'POST' })
                    } catch {
                      // ignore — navigate anyway
                    }
                    window.location.href = '/login'
                  }}
                >
                  <LogOut className="h-4 w-4" />
                  Log out
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </SidebarMenuItem>
        </SidebarMenu>

        {/* Version */}
        <div className="flex items-center justify-center mt-3">
          <span className="text-[10px] text-gray-400 font-medium tracking-wider">
            v2.0 Command Center
          </span>
        </div>
      </SidebarFooter>
    </Sidebar>
  )
}
