"use client"

/**
 * @fileoverview Messages Quick Actions - Clean premium action sidebar.
 * Minimal white cards with subtle hover effects matching dashboard style.
 * @module components/chat/messages-quick-actions
 */

import { motion } from "framer-motion"
import {
  CheckCheck,
  RefreshCw,
  Filter,
  ChevronRight
} from "lucide-react"
import { cn } from "@/lib/utils"

interface ActionItem {
  id: string
  icon: typeof CheckCheck
  label: string
  description: string
  iconBg: string
  iconColor: string
  onClick: () => void
  show?: boolean
}

interface MessagesQuickActionsProps {
  unreadCount: number
  onMarkAllRead: () => void
  onRefresh: () => void
  onFilterUnread: () => void
  className?: string
}

function ActionCard({
  item,
  index
}: {
  item: ActionItem
  index: number
}) {
  const Icon = item.icon

  return (
    <motion.button
      initial={{ opacity: 0, y: 6 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.25, delay: index * 0.04 }}
      whileHover={{ y: -2, scale: 1.01 }}
      whileTap={{ y: 0, scale: 0.99 }}
      onClick={item.onClick}
      className={cn(
        "group flex items-center gap-4 p-4 w-full",
        "bg-white rounded-2xl border border-gray-200",
        "hover:border-orange-200 hover:shadow-md",
        "active:translate-y-0",
        "transition-all duration-200 cursor-pointer"
      )}
    >
      <div className={cn(
        "w-12 h-12 rounded-xl flex items-center justify-center shrink-0",
        "transition-all duration-200",
        item.iconBg
      )}>
        <Icon className={cn("h-5 w-5", item.iconColor)} />
      </div>

      <div className="flex-1 min-w-0 text-left">
        <p className="font-semibold text-[#1C1C1C] group-hover:text-orange-600 transition-colors">
          {item.label}
        </p>
        <p className="text-sm text-gray-500">
          {item.description}
        </p>
      </div>

      <ChevronRight className="h-5 w-5 text-gray-400 group-hover:text-orange-500 group-hover:translate-x-0.5 shrink-0 transition-all" />
    </motion.button>
  )
}

export function MessagesQuickActions({
  unreadCount,
  onMarkAllRead,
  onRefresh,
  onFilterUnread,
  className
}: MessagesQuickActionsProps) {
  const actions: ActionItem[] = [
    {
      id: "mark-all-read",
      icon: CheckCheck,
      label: "Mark All Read",
      description: `Clear ${unreadCount} unread message${unreadCount !== 1 ? "s" : ""}`,
      iconBg: "bg-orange-50",
      iconColor: "text-[#F97316]",
      onClick: onMarkAllRead,
      show: unreadCount > 0
    },
    {
      id: "refresh",
      icon: RefreshCw,
      label: "Refresh",
      description: "Check for new messages",
      iconBg: "bg-emerald-50",
      iconColor: "text-emerald-600",
      onClick: onRefresh,
      show: true
    },
    {
      id: "filter-unread",
      icon: Filter,
      label: "Filter Unread",
      description: "Show only unread messages",
      iconBg: "bg-purple-50",
      iconColor: "text-purple-600",
      onClick: onFilterUnread,
      show: true
    }
  ]

  const visibleActions = actions.filter(action => action.show)

  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay: 0.1, ease: "easeOut" }}
      className={cn("space-y-3", className)}
    >
      {visibleActions.map((action, index) => (
        <ActionCard
          key={action.id}
          item={action}
          index={index}
        />
      ))}
    </motion.div>
  )
}
