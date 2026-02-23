"use client"

/**
 * MobileBottomNav - iOS-style bottom navigation for mobile devices
 * Features smooth animations, haptic feedback patterns, and gesture support
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
  Plus,
  type LucideIcon,
} from "lucide-react"

import { cn } from "@/lib/utils"
import { springs, iconBounce } from "@/lib/animations/variants"

interface NavItem {
  title: string
  href: string
  icon: LucideIcon
}

const navItems: NavItem[] = [
  { title: "Home", href: "/home", icon: Home },
  { title: "Projects", href: "/projects", icon: FolderKanban },
  // Center FAB placeholder
  { title: "Create", href: "#create", icon: Plus },
  { title: "Connect", href: "/connect", icon: Users },
  { title: "Profile", href: "/profile", icon: User },
]

interface MobileBottomNavProps {
  /** Callback when FAB (center button) is pressed */
  onCreatePress?: () => void
  /** Hide the nav (e.g., when keyboard is open) */
  hidden?: boolean
  /** Custom className */
  className?: string
}

export function MobileBottomNav({
  onCreatePress,
  hidden = false,
  className,
}: MobileBottomNavProps) {
  const pathname = usePathname()

  return (
    <AnimatePresence>
      {!hidden && (
        <motion.nav
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 100, opacity: 0 }}
          transition={springs.snappy}
          className={cn(
            "fixed bottom-0 left-0 right-0 z-50 md:hidden",
            "bg-background/80 backdrop-blur-xl border-t",
            "pb-safe", // iOS safe area
            className
          )}
        >
          <div className="flex items-end justify-around px-2 h-16">
            {navItems.map((item, index) => {
              const isCenter = index === 2
              const isActive = pathname === item.href

              if (isCenter) {
                return (
                  <FABButton
                    key={item.href}
                    onClick={onCreatePress}
                    icon={item.icon}
                  />
                )
              }

              return (
                <NavButton
                  key={item.href}
                  item={item}
                  isActive={isActive}
                  index={index}
                />
              )
            })}
          </div>
        </motion.nav>
      )}
    </AnimatePresence>
  )
}

/**
 * Individual nav button with active state
 */
function NavButton({
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
    <Link
      href={item.href}
      className={cn(
        "relative flex flex-col items-center justify-center",
        "w-16 h-12 transition-colors",
        isActive ? "text-primary" : "text-muted-foreground"
      )}
    >
      {/* Active indicator dot */}
      <AnimatePresence>
        {isActive && (
          <motion.div
            layoutId="mobileNavIndicator"
            className="absolute -top-1 w-1 h-1 rounded-full bg-primary"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            exit={{ scale: 0 }}
            transition={springs.bouncy}
          />
        )}
      </AnimatePresence>

      <motion.div
        variants={iconBounce}
        initial="rest"
        whileTap={{ scale: 0.9 }}
        className="relative"
      >
        <Icon className="size-5" strokeWidth={isActive ? 2.5 : 2} />
      </motion.div>

      <motion.span
        className={cn(
          "text-[10px] mt-0.5 font-medium transition-opacity",
          isActive ? "opacity-100" : "opacity-70"
        )}
        animate={{ y: isActive ? 0 : 2 }}
        transition={{ type: "spring", stiffness: 300, damping: 20 }}
      >
        {item.title}
      </motion.span>
    </Link>
  )
}

/**
 * Floating Action Button (center button)
 */
function FABButton({
  onClick,
  icon: Icon,
}: {
  onClick?: () => void
  icon: LucideIcon
}) {
  return (
    <motion.button
      onClick={onClick}
      className={cn(
        "relative -mt-4 flex items-center justify-center",
        "size-14 rounded-2xl bg-primary text-primary-foreground",
        "shadow-lg shadow-primary/30",
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
      )}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95, rotate: 90 }}
      transition={springs.bouncy}
    >
      <Icon className="size-6" />

      {/* Ripple effect on press */}
      <motion.div
        className="absolute inset-0 rounded-2xl bg-white/20"
        initial={{ scale: 0, opacity: 1 }}
        whileTap={{ scale: 1.5, opacity: 0 }}
        transition={{ duration: 0.4 }}
      />
    </motion.button>
  )
}

/**
 * Hook to detect if keyboard is open (for hiding nav)
 */
export function useKeyboardVisible() {
  const [isKeyboardVisible, setKeyboardVisible] = React.useState(false)

  React.useEffect(() => {
    // Detect keyboard on mobile by checking for viewport height changes
    const handleResize = () => {
      if (typeof window !== "undefined" && window.visualViewport) {
        const viewportHeight = window.visualViewport.height
        const windowHeight = window.innerHeight
        setKeyboardVisible(viewportHeight < windowHeight * 0.75)
      }
    }

    if (typeof window !== "undefined" && window.visualViewport) {
      window.visualViewport.addEventListener("resize", handleResize)
      return () => window.visualViewport?.removeEventListener("resize", handleResize)
    }
  }, [])

  return isKeyboardVisible
}
