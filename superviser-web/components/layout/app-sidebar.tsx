/**
 * @fileoverview Professional application sidebar navigation component with enhanced visuals.
 * @module components/layout/app-sidebar
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
  Shield,
  Sparkles,
} from "lucide-react"

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
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
import { Badge } from "@/components/ui/badge"
import { APP_NAME } from "@/lib/constants"
import { cn } from "@/lib/utils"
import { useI18n } from "@/lib/i18n/context"

const MAIN_NAV_STATIC = [
  { key: "nav.dashboard" as const, href: "/dashboard", icon: LayoutDashboard, description: "Overview & stats" },
  { key: "nav.projects" as const, href: "/projects", icon: FolderKanban, description: "Manage projects", badge: "3" },
  { key: "nav.doers" as const, href: "/doers", icon: Users, description: "Expert network" },
  { key: "nav.users" as const, href: "/users", icon: UserCircle, description: "Client management" },
  { key: "nav.chat" as const, href: "/chat", icon: MessageSquare, description: "Communications", badge: "2" },
  { key: "nav.earnings" as const, href: "/earnings", icon: Wallet, description: "Income & payouts" },
  { key: "nav.resources" as const, href: "/resources", icon: BookOpen, description: "Tools & training" },
]

const SECONDARY_NAV_STATIC = [
  { key: "nav.profile" as const, href: "/profile", icon: User },
  { key: "nav.settings" as const, href: "/settings", icon: Settings },
  { key: "nav.support" as const, href: "/support", icon: HelpCircle },
]

interface AppSidebarProps {
  user?: {
    name: string
    email: string
    avatarUrl?: string | null
  }
  unreadChats?: number
  pendingProjects?: number
}

export function AppSidebar({ user, unreadChats = 0, pendingProjects = 0 }: AppSidebarProps) {
  const pathname = usePathname()
  const { t } = useI18n()

  const mainNavItems = MAIN_NAV_STATIC.map((item) => ({ ...item, title: t(item.key) }))
  const secondaryNavItems = SECONDARY_NAV_STATIC.map((item) => ({ ...item, title: t(item.key) }))

  const isActive = (href: string) => {
    if (href === "/dashboard") {
      return pathname === "/dashboard"
    }
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
    <Sidebar className="border-r border-sidebar-border">
      {/* Header with Logo */}
      <SidebarHeader className="h-16 border-b border-sidebar-border">
        <Link
          href="/dashboard"
          className="flex items-center gap-3 px-2 py-2 transition-all duration-200 hover:opacity-80 group"
        >
          <div className="relative">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 flex items-center justify-center shadow-lg shadow-indigo-500/20 group-hover:shadow-indigo-500/30 transition-shadow">
              <span className="text-base font-bold text-white">AX</span>
            </div>
            <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-500 rounded-full border-2 border-sidebar" />
          </div>
          <div className="flex flex-col">
            <span className="font-bold text-lg tracking-tight">{APP_NAME}</span>
            <span className="text-[10px] text-muted-foreground font-medium flex items-center gap-1">
              <Shield className="h-2.5 w-2.5" />
              Supervisor Portal
            </span>
          </div>
        </Link>
      </SidebarHeader>

      <SidebarContent className="px-2">
        {/* Main Navigation */}
        <SidebarGroup className="py-4">
          <SidebarGroupLabel className="px-2 text-xs font-semibold text-muted-foreground/70 uppercase tracking-wider mb-2">
            Main Menu
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu className="space-y-1">
              {mainNavItems.map((item) => {
                const active = isActive(item.href)
                const showBadge =
                  (item.href === "/chat" && unreadChats > 0) ||
                  (item.href === "/projects" && pendingProjects > 0)
                const badgeCount =
                  item.href === "/chat" ? unreadChats : pendingProjects

                return (
                  <SidebarMenuItem key={item.href}>
                    <SidebarMenuButton
                      asChild
                      isActive={active}
                      className={cn(
                        "relative py-2.5 px-3 rounded-lg transition-all duration-200 group/item",
                        active
                          ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium shadow-sm"
                          : "hover:bg-sidebar-accent/50 text-sidebar-foreground/80 hover:text-sidebar-foreground"
                      )}
                    >
                      <Link href={item.href}>
                        <item.icon
                          className={cn(
                            "h-4.5 w-4.5 transition-colors",
                            active
                              ? "text-sidebar-accent-foreground"
                              : "text-muted-foreground group-hover/item:text-sidebar-foreground"
                          )}
                        />
                        <span className="flex-1">{item.title}</span>
                        {showBadge && badgeCount > 0 && (
                          <SidebarMenuBadge
                            className={cn(
                              "min-w-5 h-5 text-[10px] font-bold",
                              item.href === "/projects"
                                ? "bg-amber-500 text-white"
                                : "bg-red-500 text-white"
                            )}
                          >
                            {badgeCount > 9 ? "9+" : badgeCount}
                          </SidebarMenuBadge>
                        )}
                        {active && (
                          <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-sidebar-primary rounded-r-full" />
                        )}
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Secondary Navigation */}
        <SidebarGroup className="py-4 mt-auto">
          <SidebarGroupLabel className="px-2 text-xs font-semibold text-muted-foreground/70 uppercase tracking-wider mb-2">
            Account
          </SidebarGroupLabel>
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
                        "relative py-2 px-3 rounded-lg transition-all duration-200",
                        active
                          ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                          : "hover:bg-sidebar-accent/50 text-sidebar-foreground/70 hover:text-sidebar-foreground"
                      )}
                    >
                      <Link href={item.href}>
                        <item.icon className="h-4 w-4" />
                        <span>{item.title}</span>
                        {active && (
                          <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-5 bg-sidebar-primary rounded-r-full" />
                        )}
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      {/* Footer with User Profile */}
      <SidebarFooter className="border-t border-sidebar-border p-3">
        <SidebarMenu>
          <SidebarMenuItem>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <SidebarMenuButton
                  className="w-full py-3 px-2 rounded-xl hover:bg-sidebar-accent/50 transition-all duration-200 group"
                >
                  <div className="relative">
                    <Avatar className="h-9 w-9 ring-2 ring-sidebar-border group-hover:ring-sidebar-primary/30 transition-all">
                      <AvatarImage src={user?.avatarUrl || undefined} />
                      <AvatarFallback className="bg-gradient-to-br from-indigo-500 to-purple-500 text-white text-xs font-semibold">
                        {user?.name ? getInitials(user.name) : "S"}
                      </AvatarFallback>
                    </Avatar>
                    <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-500 rounded-full border-2 border-sidebar" />
                  </div>
                  <div className="flex flex-col items-start text-left flex-1 min-w-0">
                    <span className="text-sm font-semibold truncate max-w-[140px]">
                      {user?.name || "Supervisor"}
                    </span>
                    <span className="text-xs text-muted-foreground truncate max-w-[140px]">
                      {user?.email || "supervisor@assignx.com"}
                    </span>
                  </div>
                  <ChevronUp className="ml-auto h-4 w-4 text-muted-foreground group-hover:text-foreground transition-colors" />
                </SidebarMenuButton>
              </DropdownMenuTrigger>
              <DropdownMenuContent
                side="top"
                align="start"
                className="w-[--radix-dropdown-menu-trigger-width] min-w-56"
              >
                <DropdownMenuLabel className="font-normal">
                  <div className="flex items-center gap-3 py-1">
                    <Avatar className="h-10 w-10">
                      <AvatarImage src={user?.avatarUrl || undefined} />
                      <AvatarFallback className="bg-gradient-to-br from-indigo-500 to-purple-500 text-white font-semibold">
                        {user?.name ? getInitials(user.name) : "S"}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex flex-col">
                      <span className="font-semibold">{user?.name || "Supervisor"}</span>
                      <span className="text-xs text-muted-foreground">
                        {user?.email || "supervisor@assignx.com"}
                      </span>
                    </div>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem asChild className="gap-2 cursor-pointer">
                  <Link href="/profile">
                    <User className="h-4 w-4" />
                    Profile
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild className="gap-2 cursor-pointer">
                  <Link href="/settings">
                    <Settings className="h-4 w-4" />
                    Settings
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild className="gap-2 cursor-pointer">
                  <Link href="/support">
                    <HelpCircle className="h-4 w-4" />
                    Help & Support
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  className="gap-2 text-destructive focus:text-destructive focus:bg-destructive/10 cursor-pointer"
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

        {/* Version Badge */}
        <div className="flex items-center justify-center mt-2">
          <Badge variant="secondary" className="text-[10px] px-2 py-0.5 gap-1">
            <Sparkles className="h-2.5 w-2.5" />
            v2.0.0
          </Badge>
        </div>
      </SidebarFooter>
    </Sidebar>
  )
}
