"use client"

/**
 * QuickActionsGrid - Animated grid of primary actions for the dashboard
 * Features staggered entry, hover effects, and icon animations
 */

import * as React from "react"
import Link from "next/link"
import { motion } from "framer-motion"
import {
  FileText,
  PenTool,
  BookOpen,
  MessageSquare,
  type LucideIcon,
} from "lucide-react"

import { cn } from "@/lib/utils"
import { staggerContainer, staggerItem, cardHover, iconBounce, springs } from "@/lib/animations/variants"

interface QuickAction {
  id: string
  title: string
  description: string
  icon: LucideIcon
  href: string
  color: string
  bgColor: string
}

const defaultActions: QuickAction[] = [
  {
    id: "report",
    title: "Report Writing",
    description: "Get help with your academic reports",
    icon: FileText,
    href: "/home?service=report",
    color: "text-blue-600 dark:text-blue-400",
    bgColor: "bg-blue-100 dark:bg-blue-900/30",
  },
  {
    id: "proofreading",
    title: "Proofreading",
    description: "Polish your documents to perfection",
    icon: PenTool,
    href: "/home?service=proofreading",
    color: "text-green-600 dark:text-green-400",
    bgColor: "bg-green-100 dark:bg-green-900/30",
  },
  {
    id: "consultation",
    title: "Consultation",
    description: "1-on-1 expert guidance sessions",
    icon: MessageSquare,
    href: "/home?service=consultation",
    color: "text-purple-600 dark:text-purple-400",
    bgColor: "bg-purple-100 dark:bg-purple-900/30",
  },
  {
    id: "tutoring",
    title: "Tutoring",
    description: "Connect with subject matter experts",
    icon: BookOpen,
    href: "/connect",
    color: "text-orange-600 dark:text-orange-400",
    bgColor: "bg-orange-100 dark:bg-orange-900/30",
  },
]

interface QuickActionsGridProps {
  /** Custom actions (uses defaults if not provided) */
  actions?: QuickAction[]
  /** Number of columns on desktop */
  columns?: 2 | 3 | 4
  /** Custom className */
  className?: string
  /** Callback when action is clicked */
  onActionClick?: (actionId: string) => void
}

export function QuickActionsGrid({
  actions = defaultActions,
  columns = 4,
  className,
  onActionClick,
}: QuickActionsGridProps) {
  const gridCols = {
    2: "md:grid-cols-2",
    3: "md:grid-cols-3",
    4: "md:grid-cols-2 lg:grid-cols-4",
  }

  return (
    <motion.div
      variants={staggerContainer}
      initial="hidden"
      animate="visible"
      className={cn(
        "grid grid-cols-2 gap-3 md:gap-4",
        gridCols[columns],
        className
      )}
    >
      {actions.map((action, index) => (
        <QuickActionCard
          key={action.id}
          action={action}
          index={index}
          onClick={() => onActionClick?.(action.id)}
        />
      ))}
    </motion.div>
  )
}

/**
 * Individual action card with hover effects
 */
function QuickActionCard({
  action,
  index,
  onClick,
}: {
  action: QuickAction
  index: number
  onClick?: () => void
}) {
  const Icon = action.icon

  return (
    <motion.div
      variants={staggerItem}
      custom={index}
    >
      <Link href={action.href} onClick={onClick}>
        <motion.div
          className={cn(
            "group relative flex flex-col gap-3 p-4 md:p-5",
            "bg-card rounded-2xl border",
            "cursor-pointer transition-colors"
          )}
          variants={cardHover}
          initial="rest"
          whileHover="hover"
          whileTap="tap"
        >
          {/* Icon */}
          <motion.div
            className={cn(
              "flex items-center justify-center",
              "size-10 md:size-12 rounded-xl",
              action.bgColor
            )}
            variants={iconBounce}
            initial="rest"
            whileHover="hover"
          >
            <Icon className={cn("size-5 md:size-6", action.color)} />
          </motion.div>

          {/* Content */}
          <div className="space-y-1">
            <h3 className="font-semibold text-sm md:text-base text-foreground group-hover:text-primary transition-colors">
              {action.title}
            </h3>
            <p className="text-xs md:text-sm text-muted-foreground line-clamp-2">
              {action.description}
            </p>
          </div>

          {/* Hover arrow indicator */}
          <motion.div
            className="absolute top-4 right-4 opacity-0 group-hover:opacity-100"
            initial={{ x: -5, opacity: 0 }}
            whileHover={{ x: 0, opacity: 1 }}
            transition={springs.snappy}
          >
            <svg
              className="size-4 text-muted-foreground"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9 5l7 7-7 7"
              />
            </svg>
          </motion.div>
        </motion.div>
      </Link>
    </motion.div>
  )
}

/**
 * Compact horizontal action buttons for mobile
 */
export function QuickActionsRow({
  actions = defaultActions.slice(0, 3),
  className,
}: {
  actions?: QuickAction[]
  className?: string
}) {
  return (
    <motion.div
      className={cn("flex gap-2 overflow-x-auto pb-2 -mx-4 px-4", className)}
      variants={staggerContainer}
      initial="hidden"
      animate="visible"
    >
      {actions.map((action, index) => {
        const Icon = action.icon
        return (
          <motion.div key={action.id} variants={staggerItem} custom={index}>
            <Link href={action.href}>
              <motion.div
                className={cn(
                  "flex items-center gap-2 px-4 py-2.5",
                  "bg-card rounded-full border whitespace-nowrap",
                  "hover:bg-accent transition-colors"
                )}
                whileTap={{ scale: 0.95 }}
              >
                <span className={cn("size-4", action.color)}>
                  <Icon className="size-4" />
                </span>
                <span className="text-sm font-medium">{action.title}</span>
              </motion.div>
            </Link>
          </motion.div>
        )
      })}
    </motion.div>
  )
}
