"use client"

import { AnimatePresence, motion } from "framer-motion"
import { MessageSquare } from "lucide-react"
import { ConversationCard } from "./conversation-card"
import { EmptyState } from "@/components/shared/empty-state"
import type { ChatRoomWithParticipants } from "@/types/database"
import { Skeleton } from "@/components/ui/skeleton"

interface ConversationsGridProps {
  rooms: ChatRoomWithParticipants[]
  unreadCounts: Record<string, number>
  isLoading?: boolean
}

// Animation variants for container
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05,
      delayChildren: 0.1
    }
  }
}

// Animation variants for individual items
const itemVariants = {
  hidden: {
    opacity: 0,
    y: 20,
    scale: 0.95
  },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 15
    }
  },
  exit: {
    opacity: 0,
    scale: 0.95,
    transition: {
      duration: 0.2
    }
  }
}

// Skeleton card component
function SkeletonCard() {
  return (
    <div className="rounded-lg border bg-card p-4 space-y-3">
      <div className="flex items-start gap-3">
        <Skeleton className="h-12 w-12 rounded-full" />
        <div className="flex-1 space-y-2">
          <Skeleton className="h-4 w-3/4" />
          <Skeleton className="h-3 w-1/2" />
        </div>
      </div>
      <Skeleton className="h-3 w-full" />
      <div className="flex items-center justify-between">
        <Skeleton className="h-3 w-24" />
        <Skeleton className="h-5 w-5 rounded-full" />
      </div>
    </div>
  )
}

// Loading state component
function LoadingState() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {Array.from({ length: 6 }).map((_, i) => (
        <SkeletonCard key={i} />
      ))}
    </div>
  )
}

// Empty state component
function MessageEmptyState() {
  return (
    <EmptyState
      icon={MessageSquare}
      title="No conversations yet"
      description="Your conversations will appear here once you start chatting with project participants."
    />
  )
}

export function ConversationsGrid({
  rooms,
  unreadCounts,
  isLoading = false
}: ConversationsGridProps) {
  // Show loading state
  if (isLoading) {
    return <LoadingState />
  }

  // Show empty state
  if (rooms.length === 0) {
    return <MessageEmptyState />
  }

  return (
    <motion.div
      className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      <AnimatePresence mode="popLayout">
        {rooms.map((room) => (
          <motion.div
            key={room.id}
            variants={itemVariants}
            layout
            exit="exit"
          >
            <ConversationCard
              room={room}
              unreadCount={unreadCounts[room.id] || 0}
              onClick={() => {
                window.location.href = `/chat/${room.project_id}`
              }}
            />
          </motion.div>
        ))}
      </AnimatePresence>
    </motion.div>
  )
}
