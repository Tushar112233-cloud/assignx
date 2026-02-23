"use client"

import { useEffect, useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { cn } from "@/lib/utils"

/**
 * Props for the TypingIndicator component
 */
interface TypingIndicatorProps {
  /** Name of the person typing */
  typerName?: string
  /** Whether someone is currently typing */
  isTyping: boolean
  /** Additional CSS classes */
  className?: string
}

/**
 * Animated dot component for typing indicator
 */
function TypingDot({ delay }: { delay: number }) {
  return (
    <motion.span
      className="inline-block h-2 w-2 rounded-full bg-[#765341]"
      animate={{
        y: [0, -6, 0],
        opacity: [0.5, 1, 0.5],
      }}
      transition={{
        duration: 0.8,
        repeat: Infinity,
        delay,
        ease: "easeInOut",
      }}
    />
  )
}

/**
 * Typing indicator component showing animated dots with typer name.
 * Displays "[Name] is typing..." with smooth fade in/out animations.
 *
 * @example
 * ```tsx
 * <TypingIndicator
 *   typerName="Supervisor"
 *   isTyping={isSupervisorTyping}
 * />
 * ```
 */
export function TypingIndicator({
  typerName = "Someone",
  isTyping,
  className,
}: TypingIndicatorProps) {
  return (
    <AnimatePresence mode="wait">
      {isTyping && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 10 }}
          transition={{ duration: 0.2, ease: "easeOut" }}
          className={cn(
            "flex items-center gap-2 px-4 py-2",
            className
          )}
        >
          {/* Typing dots container */}
          <div className="flex items-center gap-1 rounded-full bg-muted px-3 py-2">
            <TypingDot delay={0} />
            <TypingDot delay={0.15} />
            <TypingDot delay={0.3} />
          </div>

          {/* Typer name */}
          <motion.span
            initial={{ opacity: 0, x: -5 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.1 }}
            className="text-xs text-muted-foreground"
          >
            {typerName} is typing...
          </motion.span>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

/**
 * Hook to manage typing indicator state with Supabase Realtime.
 * Returns the current typing users and a function to broadcast typing status.
 *
 * @param roomId - The chat room ID to subscribe to
 * @param userId - Current user's ID
 * @param supabase - Supabase client instance
 * @returns Object containing typing users and broadcast function
 */
export function useTypingIndicator(
  roomId: string | null,
  userId: string | null,
  supabase: ReturnType<typeof import("@/lib/supabase/client").createClient>
) {
  const [typingUsers, setTypingUsers] = useState<
    { userId: string; name: string; timestamp: number }[]
  >([])

  useEffect(() => {
    if (!roomId || !userId) return

    const channel = supabase.channel(`typing:${roomId}`)

    // Subscribe to presence for typing status
    channel
      .on("presence", { event: "sync" }, () => {
        const state = channel.presenceState()
        const typingList: { userId: string; name: string; timestamp: number }[] = []

        Object.values(state).forEach((presences) => {
          // Type assertion for Supabase presence state
          const typedPresences = presences as unknown as { userId: string; name: string; isTyping: boolean; timestamp: number }[]
          typedPresences.forEach((presence) => {
              if (presence.isTyping && presence.userId !== userId) {
                typingList.push({
                  userId: presence.userId,
                  name: presence.name,
                  timestamp: presence.timestamp,
                })
              }
            })
        })

        // Sort by timestamp and remove stale entries (older than 5 seconds)
        const now = Date.now()
        const activeTypers = typingList
          .filter((t) => now - t.timestamp < 5000)
          .sort((a, b) => a.timestamp - b.timestamp)

        setTypingUsers(activeTypers)
      })
      .subscribe()

    return () => {
      channel.unsubscribe()
    }
  }, [roomId, userId, supabase])

  /**
   * Broadcast typing status to other users in the room
   */
  const broadcastTyping = async (isTyping: boolean, userName: string) => {
    if (!roomId) return

    const channel = supabase.channel(`typing:${roomId}`)
    await channel.track({
      userId,
      name: userName,
      isTyping,
      timestamp: Date.now(),
    })
  }

  // Get the first typing user's name for display
  const activeTyper = typingUsers.length > 0 ? typingUsers[0] : null
  const isAnyoneTyping = typingUsers.length > 0
  const typingDisplayName =
    typingUsers.length === 1
      ? typingUsers[0].name
      : typingUsers.length === 2
        ? `${typingUsers[0].name} and ${typingUsers[1].name}`
        : typingUsers.length > 2
          ? `${typingUsers[0].name} and ${typingUsers.length - 1} others`
          : undefined

  return {
    typingUsers,
    isAnyoneTyping,
    typingDisplayName,
    broadcastTyping,
  }
}
