"use client"

/**
 * @fileoverview Clean horizontal conversation item component with modern design
 * matching the dashboard card styling.
 * @module components/chat/conversation-item
 */

import * as React from "react"
import { motion } from "framer-motion"
import { MessageCircle, Users, AlertCircle } from "lucide-react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { cn } from "@/lib/utils"
import type { ChatRoomWithParticipants } from "@/types/database"

interface ConversationItemProps {
  room: ChatRoomWithParticipants
  unreadCount?: number
  onClick?: () => void
}

/**
 * Formats a timestamp into a relative time string
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
  if (diffDays === 1) return "Yesterday"
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
 * Gets a short label for the room type
 */
function getRoomTypeLabel(roomType: string): string {
  switch (roomType) {
    case "project_user_supervisor":
      return "Client"
    case "project_supervisor_doer":
      return "Doer"
    case "project_all":
      return "All"
    case "support":
      return "Support"
    default:
      return "Chat"
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

export function ConversationItem({
  room,
  unreadCount = 0,
  onClick,
}: ConversationItemProps) {
  const { name, initials, profile } = getParticipantInfo(room)
  const RoomIcon = getRoomTypeIcon(room.room_type)
  const roomLabel = getRoomTypeLabel(room.room_type)
  const project = room.projects

  return (
    <motion.div
      whileHover={{
        y: -2,
        transition: { duration: 0.2 }
      }}
      whileTap={{ scale: 0.99 }}
      onClick={onClick}
      className={cn(
        "flex items-center gap-4 p-4 bg-white rounded-2xl border border-gray-200",
        "hover:border-gray-300 hover:shadow-md",
        "active:translate-y-0 transition-all duration-200 cursor-pointer",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-orange-500",
        room.is_suspended && "opacity-60"
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
      {/* Avatar Section (left) */}
      <div className="relative shrink-0">
        <Avatar className="h-12 w-12 border border-gray-100">
          <AvatarImage src={profile?.avatar_url || undefined} alt={name} />
          <AvatarFallback className="bg-gradient-to-br from-orange-500 to-orange-600 text-sm font-semibold text-white">
            {initials}
          </AvatarFallback>
        </Avatar>

        {/* Room Type Badge (bottom-right) */}
        <div className="absolute -bottom-0.5 -right-0.5 rounded-full bg-white p-0.5 shadow-sm">
          <div className="flex h-4 w-4 items-center justify-center rounded-full bg-orange-100">
            <RoomIcon className="h-2.5 w-2.5 text-orange-600" />
          </div>
        </div>
      </div>

      {/* Content Section (middle) */}
      <div className="flex-1 min-w-0 flex flex-col gap-0.5">
        {/* Name Row */}
        <div className="flex items-center gap-2">
          <h3 className="font-semibold text-[#1C1C1C] truncate">
            {name}
          </h3>
          {project && (
            <span className="shrink-0 text-xs px-2 py-0.5 rounded-full bg-orange-100 text-orange-600 font-medium">
              #{project.project_number}
            </span>
          )}
          {room.is_suspended && (
            <span className="shrink-0 text-xs px-2 py-0.5 rounded-full bg-red-100 text-red-600 font-medium">
              Suspended
            </span>
          )}
        </div>

        {/* Project Title or Room Label */}
        {project?.title ? (
          <p className="text-sm text-gray-500 truncate">
            {project.title}
          </p>
        ) : (
          <p className="text-sm text-gray-400 truncate">
            {roomLabel} chat
          </p>
        )}

        {/* Last Message Time - using last_message_at since last_message_text doesn't exist */}
        {room.last_message_at && (
          <p className="text-sm text-gray-500 truncate mt-0.5">
            Active {formatTimestamp(room.last_message_at)}
          </p>
        )}
      </div>

      {/* Meta Section (right) */}
      <div className="flex flex-col items-end gap-1 shrink-0">
        {/* Timestamp */}
        <span className="text-xs text-gray-400">
          {formatTimestamp(room.last_message_at)}
        </span>

        {/* Unread Badge */}
        {unreadCount > 0 && (
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            className="h-5 min-w-[20px] px-1.5 rounded-full bg-[#F97316] text-white text-xs font-bold flex items-center justify-center"
          >
            {unreadCount > 99 ? "99+" : unreadCount}
          </motion.div>
        )}
      </div>
    </motion.div>
  )
}
