"use client"

import { useState } from "react"
import { MessageCircle, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import { ChatWindow } from "@/components/project-detail/chat-window"

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
 * Floating chat button with badge for unread messages
 * Opens chat window when clicked
 */
export function FloatingChatButton({
  projectId,
  userId,
  supervisorName,
  projectNumber,
  unreadCount = 0,
  position = "bottom-right",
  className,
}: FloatingChatButtonProps) {
  const [isOpen, setIsOpen] = useState(false)

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
