"use client"

import { useState, useEffect, useRef } from "react"
import { MessageCircle, X, Wifi, WifiOff } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import { ChatWindow } from "@/components/project-detail/chat-window"
import { chatService, type ConnectionState } from "@/services"

/**
 * Props for FloatingChatButton component
 */
interface FloatingChatButtonProps {
  projectId: string
  userId: string
  supervisorName?: string
  projectNumber?: string
  unreadCount?: number
  position?: "bottom-right" | "bottom-left"
  className?: string
}

/**
 * Floating chat button with badge for unread messages.
 * Subscribes to realtime unread count updates and shows connection state.
 */
export function FloatingChatButton({
  projectId,
  userId,
  supervisorName,
  projectNumber,
  unreadCount: initialUnreadCount = 0,
  position = "bottom-right",
  className,
}: FloatingChatButtonProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [unreadCount, setUnreadCount] = useState(initialUnreadCount)
  const [connectionState, setConnectionState] = useState<ConnectionState>("disconnected")
  const unsubscribeUnreadRef = useRef<(() => void) | null>(null)
  const unsubscribeConnectionRef = useRef<(() => void) | null>(null)

  // Subscribe to unread count updates and connection state
  useEffect(() => {
    if (!userId) return

    // Subscribe to connection state
    unsubscribeConnectionRef.current = chatService.onConnectionStateChange(
      (state) => setConnectionState(state)
    )

    // Subscribe to unread counts
    unsubscribeUnreadRef.current = chatService.subscribeToUnreadCounts(
      userId,
      (_roomId, count) => {
        setUnreadCount(count)
      }
    )

    // Fetch initial unread count
    chatService.getTotalUnreadCount(userId).then((count) => {
      setUnreadCount(count)
    }).catch((err) => {
      console.error("[FloatingChat] Failed to fetch unread count:", err)
    })

    return () => {
      if (unsubscribeUnreadRef.current) {
        unsubscribeUnreadRef.current()
        unsubscribeUnreadRef.current = null
      }
      if (unsubscribeConnectionRef.current) {
        unsubscribeConnectionRef.current()
        unsubscribeConnectionRef.current = null
      }
    }
  }, [userId])

  // Sync external unread count prop
  useEffect(() => {
    if (initialUnreadCount > 0) {
      setUnreadCount(initialUnreadCount)
    }
  }, [initialUnreadCount])

  // Reset unread when chat opens
  useEffect(() => {
    if (isOpen) {
      setUnreadCount(0)
    }
  }, [isOpen])

  const showConnectionWarning =
    connectionState === "disconnected" || connectionState === "reconnecting"

  return (
    <>
      {/* Floating Button */}
      <Button
        size="icon"
        className={cn(
          "fixed z-50 h-14 w-14 rounded-full shadow-lg transition-transform hover:scale-105",
          position === "bottom-right" ? "right-4 bottom-4" : "left-4 bottom-4",
          isOpen && "scale-0 opacity-0",
          className
        )}
        onClick={() => setIsOpen(true)}
      >
        <MessageCircle className="h-6 w-6" />
        <span className="sr-only">Open chat</span>

        {/* Unread badge */}
        {unreadCount > 0 && (
          <Badge
            variant="destructive"
            className="absolute -right-1 -top-1 flex h-5 min-w-5 items-center justify-center rounded-full p-0 text-xs"
          >
            {unreadCount > 99 ? "99+" : unreadCount}
          </Badge>
        )}

        {/* Connection state indicator */}
        {showConnectionWarning && (
          <span className="absolute -left-1 -bottom-1 flex h-4 w-4 items-center justify-center rounded-full bg-amber-500 border-2 border-background">
            <WifiOff className="h-2.5 w-2.5 text-white" />
          </span>
        )}
      </Button>

      {/* Chat Window */}
      <ChatWindow
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        projectId={projectId}
        userId={userId}
        supervisorName={supervisorName}
        projectNumber={projectNumber}
      />
    </>
  )
}
