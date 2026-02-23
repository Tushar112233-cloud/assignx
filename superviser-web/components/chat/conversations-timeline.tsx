"use client"

/**
 * @fileoverview Timeline component for grouping conversations by time periods.
 * Groups conversations into Today, Yesterday, This Week, and Older sections
 * with stagger animations for a smooth visual experience.
 * @module components/chat/conversations-timeline
 */

import * as React from "react"
import { useRouter } from "next/navigation"
import { motion } from "framer-motion"
import { Skeleton } from "@/components/ui/skeleton"
import { ConversationItem } from "./conversation-item"
import type { ChatRoomWithParticipants } from "@/types/database"

interface ConversationsTimelineProps {
  rooms: ChatRoomWithParticipants[]
  unreadCounts: Record<string, number>
  isLoading?: boolean
}

interface GroupedConversations {
  today: ChatRoomWithParticipants[]
  yesterday: ChatRoomWithParticipants[]
  thisWeek: ChatRoomWithParticipants[]
  older: ChatRoomWithParticipants[]
}

/**
 * Groups conversations by time period based on last_message_at or created_at
 */
function groupByTime(rooms: ChatRoomWithParticipants[]): GroupedConversations {
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  const yesterday = new Date(today.getTime() - 86400000)
  const weekAgo = new Date(today.getTime() - 7 * 86400000)

  const groups: GroupedConversations = {
    today: [],
    yesterday: [],
    thisWeek: [],
    older: [],
  }

  rooms.forEach((room) => {
    const dateString = room.last_message_at || room.created_at
    if (!dateString) {
      groups.older.push(room)
      return
    }

    const date = new Date(dateString)
    const dateOnly = new Date(date.getFullYear(), date.getMonth(), date.getDate())

    if (dateOnly.getTime() >= today.getTime()) {
      groups.today.push(room)
    } else if (dateOnly.getTime() >= yesterday.getTime()) {
      groups.yesterday.push(room)
    } else if (dateOnly.getTime() >= weekAgo.getTime()) {
      groups.thisWeek.push(room)
    } else {
      groups.older.push(room)
    }
  })

  return groups
}

/**
 * Animation variants for stagger effect on groups
 */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const groupVariants = {
  hidden: { opacity: 0, y: 10 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      staggerChildren: 0.05,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 10 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.2,
    },
  },
}

/**
 * Skeleton loading state for the timeline
 */
function TimelineSkeleton() {
  return (
    <div className="flex flex-col gap-3">
      {/* Skeleton header */}
      <Skeleton className="h-4 w-16 mb-1" />
      {/* Skeleton items */}
      {[1, 2, 3, 4].map((i) => (
        <div
          key={i}
          className="flex items-center gap-4 p-4 bg-white rounded-2xl border border-gray-200"
        >
          {/* Avatar skeleton */}
          <Skeleton className="h-12 w-12 rounded-full shrink-0" />
          {/* Content skeleton */}
          <div className="flex-1 flex flex-col gap-2">
            <Skeleton className="h-4 w-32" />
            <Skeleton className="h-3 w-48" />
            <Skeleton className="h-3 w-24" />
          </div>
          {/* Meta skeleton */}
          <div className="flex flex-col items-end gap-2">
            <Skeleton className="h-3 w-12" />
            <Skeleton className="h-5 w-5 rounded-full" />
          </div>
        </div>
      ))}
    </div>
  )
}

/**
 * Renders a group of conversations with a header
 */
function ConversationGroup({
  label,
  rooms,
  unreadCounts,
  onRoomClick,
  isFirst,
}: {
  label: string
  rooms: ChatRoomWithParticipants[]
  unreadCounts: Record<string, number>
  onRoomClick?: (roomId: string) => void
  isFirst?: boolean
}) {
  if (rooms.length === 0) return null

  return (
    <motion.div variants={groupVariants}>
      {/* Group Header */}
      <h3
        className={`text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3 ${
          isFirst ? "" : "mt-6"
        }`}
      >
        {label}
      </h3>

      {/* Group Items */}
      <div className="flex flex-col gap-3">
        {rooms.map((room) => (
          <motion.div key={room.id} variants={itemVariants}>
            <ConversationItem
              room={room}
              unreadCount={unreadCounts[room.id] || 0}
              onClick={() => onRoomClick?.(room.id)}
            />
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

export function ConversationsTimeline({
  rooms,
  unreadCounts,
  isLoading = false,
}: ConversationsTimelineProps) {
  const router = useRouter()

  const handleRoomClick = React.useCallback((roomId: string) => {
    router.push(`/chat/${roomId}`)
  }, [router])

  if (isLoading) {
    return <TimelineSkeleton />
  }

  const grouped = groupByTime(rooms)

  // Check if there are any conversations
  const hasConversations =
    grouped.today.length > 0 ||
    grouped.yesterday.length > 0 ||
    grouped.thisWeek.length > 0 ||
    grouped.older.length > 0

  // Empty state is handled by parent, but we return null if no conversations
  if (!hasConversations) {
    return null
  }

  // Determine which group is first for styling
  const firstGroup =
    grouped.today.length > 0
      ? "today"
      : grouped.yesterday.length > 0
        ? "yesterday"
        : grouped.thisWeek.length > 0
          ? "thisWeek"
          : "older"

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className="flex flex-col"
    >
      <ConversationGroup
        label="Today"
        rooms={grouped.today}
        unreadCounts={unreadCounts}
        onRoomClick={handleRoomClick}
        isFirst={firstGroup === "today"}
      />
      <ConversationGroup
        label="Yesterday"
        rooms={grouped.yesterday}
        unreadCounts={unreadCounts}
        onRoomClick={handleRoomClick}
        isFirst={firstGroup === "yesterday"}
      />
      <ConversationGroup
        label="This Week"
        rooms={grouped.thisWeek}
        unreadCounts={unreadCounts}
        onRoomClick={handleRoomClick}
        isFirst={firstGroup === "thisWeek"}
      />
      <ConversationGroup
        label="Older"
        rooms={grouped.older}
        unreadCounts={unreadCounts}
        onRoomClick={handleRoomClick}
        isFirst={firstGroup === "older"}
      />
    </motion.div>
  )
}
