"use client"

/**
 * AnimatedSidebar - Enhanced sidebar with Framer Motion animations
 * Wraps shadcn sidebar components with micro-interactions
 */

import * as React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { motion, AnimatePresence } from "framer-motion"
import {
  Home,
  FolderKanban,
  Users,
  User,
  Settings,
  HelpCircle,
  type LucideIcon,
} from "lucide-react"

import { NavUser } from "@/components/nav-user"
import { useUserStore } from "@/stores/user-store"
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
  SidebarRail,
  useSidebar,
} from "@/components/ui/sidebar"
import { staggerContainer, staggerItem, springs, iconBounce } from "@/lib/animations/variants"

interface NavItem {
  title: string
  url: string
  icon: LucideIcon
  badge?: number
}

const mainNavItems: NavItem[] = [
  { title: "Home", url: "/home", icon: Home },
  { title: "My Projects", url: "/projects", icon: FolderKanban },
  { title: "Connect", url: "/connect", icon: Users },
  { title: "Profile", url: "/profile", icon: User },
]

const bottomNavItems: NavItem[] = [
  { title: "Settings", url: "/settings", icon: Settings },
  { title: "Help & Support", url: "/support", icon: HelpCircle },
]

/**
 * Animated menu item with hover effects and active indicator
 */
function AnimatedNavItem({
  item,
  isActive,
  index,
}: {
  item: NavItem
  isActive: boolean
  index: number
}) {
  const Icon = item.icon

  return (
    <motion.div
      variants={staggerItem}
      custom={index}
      className="relative"
    >
      {/* Active indicator bar */}
      <AnimatePresence>
        {isActive && (
          <motion.div
            layoutId="activeIndicator"
            className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-primary rounded-r-full"
            initial={{ opacity: 0, x: -4 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -4 }}
            transition={springs.snappy}
          />
        )}
      </AnimatePresence>

      <SidebarMenuItem>
        <SidebarMenuButton
          asChild
          isActive={isActive}
          tooltip={item.title}
          className="group relative"
        >
          <Link href={item.url}>
            <motion.span
              className="inline-flex"
              variants={iconBounce}
              initial="rest"
              whileHover="hover"
            >
              <Icon className="transition-colors duration-200" />
            </motion.span>
            <motion.span
              initial={{ opacity: 0.8 }}
              whileHover={{ opacity: 1 }}
            >
              {item.title}
            </motion.span>

            {/* Badge */}
            {item.badge && item.badge > 0 && (
              <motion.span
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                className="ml-auto flex h-5 w-5 items-center justify-center rounded-full bg-primary text-[10px] font-medium text-primary-foreground"
                transition={springs.bouncy}
              >
                {item.badge > 99 ? "99+" : item.badge}
              </motion.span>
            )}
          </Link>
        </SidebarMenuButton>
      </SidebarMenuItem>
    </motion.div>
  )
}

/**
 * Animated logo with hover effect
 */
function AnimatedLogo() {
  return (
    <SidebarMenuButton size="lg" asChild>
      <Link href="/home">
        <motion.div
          className="bg-primary text-primary-foreground flex aspect-square size-8 items-center justify-center rounded-xl font-bold"
          whileHover={{ scale: 1.05, rotate: 5 }}
          whileTap={{ scale: 0.95 }}
          transition={springs.bouncy}
        >
          A
        </motion.div>
        <div className="grid flex-1 text-left text-sm leading-tight">
          <span className="truncate font-semibold">AssignX</span>
          <span className="truncate text-xs text-muted-foreground">Beta</span>
        </div>
      </Link>
    </SidebarMenuButton>
  )
}

/**
 * Main animated sidebar component
 */
export function AnimatedSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const pathname = usePathname()
  const user = useUserStore((state) => state.user)
  const { state } = useSidebar()

  const userData = {
    name: user?.full_name || user?.fullName || "User",
    email: user?.email || "",
    avatar: user?.avatar_url || user?.avatarUrl || "",
  }

  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <AnimatedLogo />
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      <SidebarContent>
        {/* Main Navigation */}
        <SidebarGroup>
          <SidebarGroupContent>
            <motion.div
              variants={staggerContainer}
              initial="hidden"
              animate="visible"
            >
              <SidebarMenu>
                {mainNavItems.map((item, index) => (
                  <AnimatedNavItem
                    key={item.url}
                    item={item}
                    isActive={pathname === item.url}
                    index={index}
                  />
                ))}
              </SidebarMenu>
            </motion.div>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Bottom Navigation */}
        <SidebarGroup className="mt-auto">
          <SidebarGroupContent>
            <motion.div
              variants={staggerContainer}
              initial="hidden"
              animate="visible"
            >
              <SidebarMenu>
                {bottomNavItems.map((item, index) => (
                  <AnimatedNavItem
                    key={item.url}
                    item={item}
                    isActive={pathname === item.url}
                    index={index + mainNavItems.length}
                  />
                ))}
              </SidebarMenu>
            </motion.div>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter>
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <NavUser user={userData} />
        </motion.div>
      </SidebarFooter>

      <SidebarRail />
    </Sidebar>
  )
}
