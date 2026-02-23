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
 * Hook to manage chat presence with Supabase Realtime.
 * Tracks who's online and emits join/leave events.
 *
 * @param roomId - The chat room ID
 * @param userId - Current user's ID
 * @param userName - Current user's display name
 * @param userRole - Current user's role (e.g., "Supervisor", "Doer")
 * @param supabase - Supabase client instance
 */
export function useChatPresence(
  roomId: string | null,
  userId: string | null,
  userName: string,
  userRole?: string,
  supabase?: ReturnType<typeof import("@/lib/supabase/client").createClient>
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
    if (!roomId || !userId || !supabase) return

    const channel = supabase.channel(`presence:${roomId}`)

    channel
      .on("presence", { event: "sync" }, () => {
        const state = channel.presenceState()
        const users: { id: string; name: string; role?: string; avatarUrl?: string }[] = []

        Object.values(state).forEach((presences) => {
          // Type assertion for Supabase presence state
          const typedPresences = presences as unknown as { id: string; name: string; role?: string; avatarUrl?: string }[]
          typedPresences.forEach((presence) => {
              if (!users.find((u) => u.id === presence.id)) {
                users.push({
                  id: presence.id,
                  name: presence.name,
                  role: presence.role,
                  avatarUrl: presence.avatarUrl,
                })
              }
            })
        })

        setOnlineUsers(users)
      })
      .on("presence", { event: "join" }, ({ newPresences }: any) => {
        const typedPresences = newPresences as unknown as { id: string; name: string; role?: string }[]
        typedPresences.forEach((presence) => {
          if (presence.id !== userId) {
            addPresenceEvent("joined", {
              name: presence.name,
              role: presence.role,
            })
          }
        })
      })
      .on("presence", { event: "leave" }, ({ leftPresences }: any) => {
        const typedPresences = leftPresences as unknown as { id: string; name: string; role?: string }[]
        typedPresences.forEach((presence) => {
          if (presence.id !== userId) {
            addPresenceEvent("left", {
              name: presence.name,
              role: presence.role,
            })
          }
        })
      })
      .subscribe(async (status: any) => {
        if (status === "SUBSCRIBED") {
          await channel.track({
            id: userId,
            name: userName,
            role: userRole,
            online_at: new Date().toISOString(),
          })
        }
      })

    return () => {
      channel.unsubscribe()
    }
  }, [roomId, userId, userName, userRole, supabase, addPresenceEvent])

  return {
    onlineUsers,
    presenceEvents,
    removePresenceEvent,
  }
}
