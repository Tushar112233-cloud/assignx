"use client"

/**
 * @fileoverview Beautiful card component for displaying individual chat conversations
 * with animations, badges, and interactive hover effects.
 * @module components/chat/conversation-card
 */

import * as React from "react"
import { motion } from "framer-motion"
import { MessageCircle, Users, Briefcase, AlertCircle } from "lucide-react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import type { ChatRoomWithParticipants } from "@/types/database"

interface ConversationCardProps {
  room: ChatRoomWithParticipants
  unreadCount?: number
  onClick?: () => void
}

/**
 * Formats a timestamp into a relative or absolute time string
 */
function formatTimestamp(date: string | null): string {
  if (!date) return ""

  const now = new Date()
  const timestamp = new Date(date)
  const diffMs = now.getTime() - timestamp.getTime()
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return "Just now"
  if (diffMins < 60) return `${diffMins}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`

  return timestamp.toLocaleDateString("en-US", {
    month: "short",
    day: "numeric"
  })
}

/**
 * Gets the appropriate icon for the chat room type
 */
function getRoomTypeIcon(roomType: string) {
  switch (roomType) {
    case "project_user_supervisor":
    case "project_supervisor_doer":
      return MessageCircle
    case "project_all":
      return Users
    case "support":
      return AlertCircle
    default:
      return MessageCircle
  }
}

/**
 * Gets participant information from the room
 */
function getParticipantInfo(room: ChatRoomWithParticipants) {
  const participants = room.chat_participants || []

  // Get the first participant (usually the other person in the conversation)
  const participant = participants[0]
  const profile = participant?.profiles

  const name = profile?.full_name || profile?.email?.split("@")[0] || "Unknown"
  const initials = name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)

  return { name, initials, profile }
}

export function ConversationCard({
  room,
  unreadCount = 0,
  onClick,
}: ConversationCardProps) {
  const { name, initials } = getParticipantInfo(room)
  const RoomIcon = getRoomTypeIcon(room.room_type)
  const project = room.projects

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      whileHover={{
        y: -4,
        scale: 1.02,
        transition: { duration: 0.2 }
      }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className={cn(
        "relative cursor-pointer rounded-2xl border border-gray-200 bg-white p-4 shadow-sm",
        "transition-shadow duration-200 hover:shadow-lg",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500",
        room.is_suspended && "opacity-75"
      )}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault()
          onClick?.()
        }
      }}
    >
      {/* Timestamp */}
      <div className="absolute right-4 top-4 text-xs text-gray-400">
        {formatTimestamp(room.last_message_at)}
      </div>

      {/* Unread Badge */}
      {unreadCount > 0 && (
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          className="absolute -right-2 -top-2 z-10"
        >
          <motion.div
            animate={{
              scale: [1, 1.1, 1],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: "easeInOut",
            }}
            className={cn(
              "flex h-6 min-w-[24px] items-center justify-center rounded-full px-1.5",
              "bg-gradient-to-br from-orange-500 to-orange-600 text-xs font-bold text-white shadow-lg"
            )}
          >
            {unreadCount > 99 ? "99+" : unreadCount}
          </motion.div>
        </motion.div>
      )}

      {/* Suspended Badge */}
      {room.is_suspended && (
        <div className="absolute left-4 top-4">
          <Badge variant="destructive" className="text-xs">
            <AlertCircle className="mr-1 h-3 w-3" />
            Suspended
          </Badge>
        </div>
      )}

      <div className="flex gap-4">
        {/* Avatar with Badge */}
        <div className="relative shrink-0">
          <Avatar className="h-16 w-16 border-2 border-gray-100">
            <AvatarImage src={undefined} alt={name} />
            <AvatarFallback className="bg-gradient-to-br from-orange-500 to-orange-600 text-lg font-semibold text-white">
              {initials}
            </AvatarFallback>
          </Avatar>

          {/* Room Type Badge */}
          <div className="absolute -bottom-1 -right-1 rounded-full bg-white p-1 shadow-md">
            <div className="flex h-5 w-5 items-center justify-center rounded-full bg-orange-100">
              <RoomIcon className="h-3 w-3 text-orange-600" />
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="flex min-w-0 flex-1 flex-col gap-1.5">
          {/* Name and Project Badge */}
          <div className="flex items-start gap-2 pr-16">
            <h3 className="truncate text-lg font-semibold text-gray-900">
              {name}
            </h3>
            {project && (
              <Badge
                className="shrink-0 bg-orange-500 text-white hover:bg-orange-600"
              >
                <Briefcase className="mr-1 h-3 w-3" />
                #{project.project_number}
              </Badge>
            )}
          </div>

          {/* Project Title */}
          {project?.title && (
            <p className="truncate text-sm text-gray-500">
              {project.title}
            </p>
          )}

          {/* Last Message Time */}
          {room.last_message_at && (
            <p className="line-clamp-2 text-sm text-gray-600">
              Last message: {formatTimestamp(room.last_message_at)}
            </p>
          )}

          {/* Room Type Label */}
          <div className="mt-1 flex items-center gap-2">
            <Badge variant="outline" className="text-xs">
              {room.room_type.split("_").join(" ").toUpperCase()}
            </Badge>
          </div>
        </div>
      </div>
    </motion.div>
  )
}
