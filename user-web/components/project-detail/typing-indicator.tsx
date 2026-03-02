"use client"

import { useEffect, useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { cn } from "@/lib/utils"
import { getSocket } from "@/lib/socket/client"

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
          <div className="flex items-center gap-1 rounded-full bg-muted px-3 py-2">
            <TypingDot delay={0} />
            <TypingDot delay={0.15} />
            <TypingDot delay={0.3} />
          </div>
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
 * Hook to manage typing indicator state with Socket.IO.
 * Returns the current typing users and a function to broadcast typing status.
 */
export function useTypingIndicator(
  roomId: string | null,
  userId: string | null,
) {
  const [typingUsers, setTypingUsers] = useState<
    { userId: string; name: string; timestamp: number }[]
  >([])

  useEffect(() => {
    if (!roomId || !userId) return

    const socket = getSocket()
    const eventName = `typing:${roomId}`

    const handler = (data: { userId: string; name: string; isTyping: boolean }) => {
      if (data.userId === userId) return

      if (data.isTyping) {
        setTypingUsers((prev) => {
          const existing = prev.find((t) => t.userId === data.userId)
          if (existing) {
            return prev.map((t) =>
              t.userId === data.userId ? { ...t, timestamp: Date.now() } : t
            )
          }
          return [...prev, { userId: data.userId, name: data.name, timestamp: Date.now() }]
        })
      } else {
        setTypingUsers((prev) => prev.filter((t) => t.userId !== data.userId))
      }
    }

    socket.on(eventName, handler)

    // Clean up stale typing entries every 5 seconds
    const interval = setInterval(() => {
      const now = Date.now()
      setTypingUsers((prev) => prev.filter((t) => now - t.timestamp < 5000))
    }, 5000)

    return () => {
      socket.off(eventName, handler)
      clearInterval(interval)
    }
  }, [roomId, userId])

  /**
   * Broadcast typing status to other users in the room
   */
  const broadcastTyping = (isTyping: boolean, userName: string) => {
    if (!roomId) return
    const socket = getSocket()
    socket.emit('typing', { roomId, userId, name: userName, isTyping })
  }

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
