"use client"

import * as React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  LayoutDashboard,
  FolderOpen,
  BookOpen,
  User,
  Star,
  BarChart3,
  HelpCircle,
  Settings,
  TrendingUp,
  Zap,
  PanelLeftClose,
  PanelLeftOpen,
} from "lucide-react"

import { NavUser } from "@/components/nav-user"

import { useI18n } from "@/lib/i18n/context"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuBadge,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from "@/components/ui/sidebar"
import { cn } from "@/lib/utils"

/**
 * Static nav data (icons, urls) - titles resolved via i18n inside the component
 */
const NAV_MAIN_STATIC = [
  { key: "nav.dashboard" as const, url: "/dashboard", icon: LayoutDashboard, description: "Overview & tasks" },
  { key: "nav.my_projects" as const, url: "/projects", icon: FolderOpen, description: "Active work" },
  { key: "nav.resources" as const, url: "/resources", icon: BookOpen, description: "Tools & guides" },
]

const NAV_PROFILE_STATIC = [
  { key: "nav.my_profile" as const, url: "/profile", icon: User, description: "Your info" },
  { key: "nav.reviews" as const, url: "/reviews", icon: Star, description: "Feedback" },
  { key: "nav.statistics" as const, url: "/statistics", icon: BarChart3, description: "Performance" },
]

const NAV_SUPPORT_STATIC = [
  { key: "nav.help_support" as const, url: "/support", icon: HelpCircle, description: "Get help" },
  { key: "nav.settings" as const, url: "/settings", icon: Settings, description: "Preferences" },
]

type UserData = {
  name: string
  email: string
  avatar: string
}

type AppSidebarProps = React.ComponentProps<typeof Sidebar> & {
  userData: UserData
  stats?: {
    activeProjects?: number
    pendingEarnings?: number
  }
}

/**
 * AppSidebar component for doer-web
 * Professional sidebar with gradient logo and active indicators
 */
export function AppSidebar({ userData, stats, className, ...props }: AppSidebarProps) {
  const pathname = usePathname()
  const { open, toggleSidebar } = useSidebar()
  const { t } = useI18n()

  const navMain = NAV_MAIN_STATIC.map((item) => ({ ...item, title: t(item.key) }))
  const navProfile = NAV_PROFILE_STATIC.map((item) => ({ ...item, title: t(item.key) }))
  const navSupport = NAV_SUPPORT_STATIC.map((item) => ({ ...item, title: t(item.key) }))

  return (
    <Sidebar
      collapsible="icon"
      className={cn(
        "bg-[#F8FAFF] text-slate-700 border-r border-[#EEF2FF] shadow-[0_20px_50px_rgba(148,163,184,0.12)] transition-all duration-300 ease-in-out",
        "[&_[data-slot=sidebar-inner]]:bg-[linear-gradient(180deg,#F8FAFF_0%,#F4F7FF_55%,#EEF4FF_100%)]",
        "[&_[data-slot=sidebar]]:bg-[linear-gradient(180deg,#F8FAFF_0%,#F4F7FF_55%,#EEF4FF_100%)]",
        className
      )}
      {...props}
    >
      <SidebarHeader className="border-b border-[#E5EDFF]/40 bg-transparent relative">
        {/* Toggle Button */}
        <Button
          variant="ghost"
          size="icon"
          onClick={toggleSidebar}
          className="absolute right-2 top-2 h-8 w-8 rounded-lg hover:bg-[#E8EDFF] text-slate-600 hover:text-slate-900 transition-all duration-200 z-10"
          title={open ? "Collapse sidebar" : "Expand sidebar"}
        >
          {open ? (
            <PanelLeftClose className="h-4 w-4" />
          ) : (
            <PanelLeftOpen className="h-4 w-4" />
          )}
        </Button>

        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild className="hover:bg-[#F3F6FF] hover:text-slate-700">
              <Link href="/dashboard">
                {/* Gradient Logo */}
                <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] flex items-center justify-center shadow-[0_14px_28px_rgba(91,124,255,0.25)] transition-transform hover:scale-105">
                  <span className="text-base font-bold text-white">AX</span>
                </div>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-semibold text-slate-800">AssignX Doer</span>
                  <span className="truncate text-xs text-slate-500">Freelancer Portal</span>
                </div>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      <SidebarContent>
        {/* Quick Stats (when sidebar is expanded) */}
        <SidebarGroup className="group-data-[collapsible=icon]:hidden">
          <div className="px-2 py-3">
            <div className="p-3 rounded-2xl bg-gradient-to-br from-[#F4F6FF] via-[#F7F9FF] to-[#EEF4FF] border border-[#E9EEFF] shadow-[0_12px_28px_rgba(148,163,184,0.12)]">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-white flex items-center justify-center text-[#4F6CF7] shadow-[0_8px_18px_rgba(148,163,184,0.18)]">
                  <Zap className="h-5 w-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-xs text-slate-500">Ready to work</p>
                  <p className="text-sm font-semibold text-slate-800">
                    {stats?.activeProjects || 0} Active Projects
                  </p>
                </div>
              </div>
            </div>
          </div>
        </SidebarGroup>

        {/* Main Navigation */}
        <SidebarGroup>
          <SidebarGroupLabel className="text-slate-400 uppercase text-[10px] tracking-wider font-semibold">
            {t("nav.main_menu")}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {navMain.map((item) => {
                const isActive = pathname === item.url || pathname?.startsWith(item.url + '/')
                return (
                  <SidebarMenuItem key={item.title}>
                    <SidebarMenuButton
                      asChild
                      tooltip={item.title}
                      className={cn(
                        "relative transition-all rounded-full text-slate-600",
                        "hover:bg-[#F3F6FF] hover:text-slate-700",
                        "active:bg-[#E8EDFF] active:text-slate-800",
                        isActive && "bg-gradient-to-r from-[#EEF2FF] to-[#E5F7FF] text-slate-900 shadow-[0_10px_24px_rgba(148,163,184,0.16)]"
                      )}
                    >
                      <Link href={item.url}>
                        <item.icon className={cn(
                          "transition-colors",
                          isActive ? "text-[#4F6CF7]" : "text-slate-400"
                        )} />
                        <span>{item.title}</span>
                      </Link>
                    </SidebarMenuButton>
                    {/* Badge for projects */}
                    {item.url === '/projects' && stats?.activeProjects && stats.activeProjects > 0 && (
                      <SidebarMenuBadge className="bg-[#5A7CFF] text-white shadow-[0_8px_18px_rgba(91,124,255,0.2)]">
                        {stats.activeProjects}
                      </SidebarMenuBadge>
                    )}
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Profile Section */}
        <SidebarGroup>
          <SidebarGroupLabel className="text-slate-400 uppercase text-[10px] tracking-wider font-semibold">
            {t("nav.profile_stats")}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {navProfile.map((item) => {
                const isActive = pathname === item.url
                return (
                  <SidebarMenuItem key={item.title}>
                    <SidebarMenuButton
                      asChild
                      tooltip={item.title}
                      className={cn(
                        "relative transition-all rounded-full text-slate-600",
                        "hover:bg-[#F3F6FF] hover:text-slate-700",
                        "active:bg-[#E8EDFF] active:text-slate-800",
                        isActive && "bg-gradient-to-r from-[#EEF2FF] to-[#E5F7FF] text-slate-900 shadow-[0_10px_24px_rgba(148,163,184,0.16)]"
                      )}
                    >
                      <Link href={item.url}>
                        <item.icon className={cn(
                          "transition-colors",
                          isActive ? "text-[#4F6CF7]" : "text-slate-400"
                        )} />
                        <span>{item.title}</span>
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Support Section */}
        <SidebarGroup>
          <SidebarGroupLabel className="text-slate-400 uppercase text-[10px] tracking-wider font-semibold">
            {t("nav.support_section")}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {navSupport.map((item) => {
                const isActive = pathname === item.url
                return (
                  <SidebarMenuItem key={item.title}>
                    <SidebarMenuButton
                      asChild
                      tooltip={item.title}
                      className={cn(
                        "relative transition-all rounded-full text-slate-600",
                        "hover:bg-[#F3F6FF] hover:text-slate-700",
                        "active:bg-[#E8EDFF] active:text-slate-800",
                        isActive && "bg-gradient-to-r from-[#EEF2FF] to-[#E5F7FF] text-slate-900 shadow-[0_10px_24px_rgba(148,163,184,0.16)]"
                      )}
                    >
                      <Link href={item.url}>
                        <item.icon className={cn(
                          "transition-colors",
                          isActive ? "text-[#4F6CF7]" : "text-slate-400"
                        )} />
                        <span>{item.title}</span>
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                )
              })}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Earnings Card (when sidebar is expanded) */}
        <SidebarGroup className="group-data-[collapsible=icon]:hidden mt-auto">
          <div className="px-2 py-3">
            <div className="p-3 rounded-2xl bg-gradient-to-br from-[#F4F6FF] via-[#F7F9FF] to-[#EEF4FF] border border-[#E9EEFF] shadow-[0_12px_28px_rgba(148,163,184,0.12)]">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-white flex items-center justify-center text-[#4B9BFF] shadow-[0_8px_18px_rgba(148,163,184,0.18)]">
                  <TrendingUp className="h-5 w-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-xs text-slate-500">Pending</p>
                  <p className="text-sm font-semibold text-slate-800">
                    ₹{(stats?.pendingEarnings || 0).toLocaleString('en-IN')}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter className="border-t border-[#E5EDFF]/40 bg-transparent">
        <NavUser user={userData} />
      </SidebarFooter>
    </Sidebar>
  )
}
