"use client"

import { useEffect, useState, useCallback } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { UserPlus, UserMinus } from "lucide-react"
import { cn } from "@/lib/utils"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

/**
 * Types of presence events
 */
type PresenceEventType = "joined" | "left"

/**
 * Presence event data structure
 */
interface PresenceEvent {
  id: string
  type: PresenceEventType
  userName: string
  userRole?: string
  avatarUrl?: string
  timestamp: number
}

/**
 * Props for the ChatPresenceBanner component
 */
interface ChatPresenceBannerProps {
  /** Current presence events to display */
  events: PresenceEvent[]
  /** Callback to remove an event after display */
  onEventDismiss?: (eventId: string) => void
  /** Additional CSS classes */
  className?: string
}

/**
 * Single presence event banner with animated entrance/exit
 */
function PresenceEventBanner({
  event,
  onDismiss,
}: {
  event: PresenceEvent
  onDismiss?: () => void
}) {
  const isJoin = event.type === "joined"
  const Icon = isJoin ? UserPlus : UserMinus

  useEffect(() => {
    // Auto-dismiss after 3 seconds
    const timer = setTimeout(() => {
      onDismiss?.()
    }, 3000)

    return () => clearTimeout(timer)
  }, [onDismiss])

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: -20, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, y: -20, scale: 0.95 }}
      transition={{ duration: 0.2, ease: "easeOut" }}
      className={cn(
        "flex items-center gap-2 rounded-lg px-3 py-2",
        "bg-gradient-to-r shadow-sm backdrop-blur-sm",
        isJoin
          ? "from-[#765341]/10 to-[#9D7B65]/10 border border-[#765341]/20"
          : "from-muted/80 to-muted/60 border border-border/50"
      )}
    >
      {/* User avatar */}
      <Avatar className="h-6 w-6">
        <AvatarImage src={event.avatarUrl} />
        <AvatarFallback
          className={cn(
            "text-[10px]",
            isJoin ? "bg-[#765341] text-white" : "bg-muted-foreground/20"
          )}
        >
          {event.userName.charAt(0).toUpperCase()}
        </AvatarFallback>
      </Avatar>

      {/* Icon */}
      <Icon
        className={cn(
          "h-3.5 w-3.5",
          isJoin ? "text-[#765341]" : "text-muted-foreground"
        )}
      />

      {/* Message */}
      <span className="text-xs text-muted-foreground">
        <span className="font-medium text-foreground">
          {event.userName}
        </span>
        {event.userRole && (
          <span className="text-[#765341]"> ({event.userRole})</span>
        )}
        {" "}
        {isJoin ? "joined the chat" : "left the chat"}
      </span>
    </motion.div>
  )
}

/**
 * Chat presence banner showing who joined/left the chat.
 * Displays animated notifications that auto-dismiss after 3 seconds.
 *
 * @example
 * ```tsx
 * <ChatPresenceBanner
 *   events={presenceEvents}
 *   onEventDismiss={(id) => removeEvent(id)}
 * />
 * ```
 */
export function ChatPresenceBanner({
  events,
  onEventDismiss,
  className,
}: ChatPresenceBannerProps) {
  return (
    <div className={cn("flex flex-col gap-2", className)}>
      <AnimatePresence mode="popLayout">
        {events.map((event) => (
          <PresenceEventBanner
            key={event.id}
            event={event}
            onDismiss={() => onEventDismiss?.(event.id)}
          />
        ))}
      </AnimatePresence>
    </div>
  )
}

/**
 * Online users indicator showing who's currently in the chat
 */
interface OnlineUsersIndicatorProps {
  /** List of online users */
  users: { id: string; name: string; role?: string; avatarUrl?: string }[]
  /** Maximum number of avatars to show */
  maxAvatars?: number
  /** Additional CSS classes */
  className?: string
}

/**
 * Displays a row of avatars for online users with overflow indicator
 */
export function OnlineUsersIndicator({
  users,
  maxAvatars = 3,
  className,
}: OnlineUsersIndicatorProps) {
  const displayUsers = users.slice(0, maxAvatars)
  const remainingCount = Math.max(0, users.length - maxAvatars)

  if (users.length === 0) return null

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      className={cn(
        "flex items-center gap-2 rounded-full bg-muted/50 px-2 py-1",
        className
      )}
    >
      {/* Online dot */}
      <span className="relative flex h-2 w-2">
        <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-green-400 opacity-75" />
        <span className="relative inline-flex h-2 w-2 rounded-full bg-green-500" />
      </span>

      {/* Stacked avatars */}
      <div className="flex -space-x-2">
        {displayUsers.map((user, index) => (
          <motion.div
            key={user.id}
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: index * 0.05 }}
          >
            <Avatar className="h-5 w-5 border-2 border-background">
              <AvatarImage src={user.avatarUrl} />
              <AvatarFallback className="bg-[#765341] text-[8px] text-white">
                {user.name.charAt(0).toUpperCase()}
              </AvatarFallback>
            </Avatar>
          </motion.div>
        ))}
        {remainingCount > 0 && (
          <div className="flex h-5 w-5 items-center justify-center rounded-full border-2 border-background bg-muted text-[8px] font-medium">
            +{remainingCount}
          </div>
        )}
      </div>

      {/* Label */}
      <span className="text-[10px] text-muted-foreground">
        {users.length === 1
          ? "1 online"
          : `${users.length} online`}
      </span>
    </motion.div>
  )
}

/**
 * Hook to manage chat presence with Socket.IO.
 * Tracks who's online and emits join/leave events.
 *
 * @param roomId - The chat room ID
 * @param userId - Current user's ID
 * @param userName - Current user's display name
 * @param userRole - Current user's role (e.g., "Supervisor", "Doer")
 */
export function useChatPresence(
  roomId: string | null,
  userId: string | null,
  userName: string,
  userRole?: string,
) {
  const [onlineUsers, setOnlineUsers] = useState<
    { id: string; name: string; role?: string; avatarUrl?: string }[]
  >([])
  const [presenceEvents, setPresenceEvents] = useState<PresenceEvent[]>([])

  // Add a new presence event
  const addPresenceEvent = useCallback(
    (type: PresenceEventType, user: { name: string; role?: string; avatarUrl?: string }) => {
      const event: PresenceEvent = {
        id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        type,
        userName: user.name,
        userRole: user.role,
        avatarUrl: user.avatarUrl,
        timestamp: Date.now(),
      }
      setPresenceEvents((prev) => [...prev, event])
    },
    []
  )

  // Remove a presence event by ID
  const removePresenceEvent = useCallback((eventId: string) => {
    setPresenceEvents((prev) => prev.filter((e) => e.id !== eventId))
  }, [])

  useEffect(() => {
    if (!roomId || !userId) return

    // Dynamic import to avoid SSR issues
    let cleanup: (() => void) | undefined

    const setup = async () => {
      const { getSocket } = await import("@/lib/socket/client")
      const socket = getSocket()

      // Join the presence room
      socket.emit("presence:join", {
        roomId,
        userId,
        userName,
        userRole,
      })

      // Listen for presence sync
      const syncHandler = (users: { id: string; name: string; role?: string; avatarUrl?: string }[]) => {
        setOnlineUsers(users)
      }

      // Listen for user join
      const joinHandler = (user: { id: string; name: string; role?: string; avatarUrl?: string }) => {
        if (user.id !== userId) {
          addPresenceEvent("joined", { name: user.name, role: user.role, avatarUrl: user.avatarUrl })
        }
      }

      // Listen for user leave
      const leaveHandler = (user: { id: string; name: string; role?: string }) => {
        if (user.id !== userId) {
          addPresenceEvent("left", { name: user.name, role: user.role })
        }
      }

      socket.on(`presence:${roomId}:sync`, syncHandler)
      socket.on(`presence:${roomId}:join`, joinHandler)
      socket.on(`presence:${roomId}:leave`, leaveHandler)

      cleanup = () => {
        socket.emit("presence:leave", { roomId, userId })
        socket.off(`presence:${roomId}:sync`, syncHandler)
        socket.off(`presence:${roomId}:join`, joinHandler)
        socket.off(`presence:${roomId}:leave`, leaveHandler)
      }
    }

    setup()

    return () => {
      cleanup?.()
    }
  }, [roomId, userId, userName, userRole, addPresenceEvent])

  return {
    onlineUsers,
    presenceEvents,
    removePresenceEvent,
  }
}
