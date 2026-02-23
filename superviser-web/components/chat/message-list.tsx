/**
 * @fileoverview Component displaying chat message history with date grouping.
 * @module components/chat/message-list
 */

"use client"

import { useEffect, useRef } from "react"
import { format, isToday, isYesterday, isSameDay } from "date-fns"
import {
  FileText,
  Image as ImageIcon,
  Download,
  AlertTriangle,
  CheckCheck,
  Check,
} from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"
import { ChatMessage, ChatParticipant } from "./types"

interface MessageListProps {
  messages: ChatMessage[]
  participants: ChatParticipant[]
  currentUserId: string
  onDownloadFile?: (message: ChatMessage) => void
}

function formatMessageDate(date: Date): string {
  if (isToday(date)) {
    return "Today"
  }
  if (isYesterday(date)) {
    return "Yesterday"
  }
  return format(date, "MMMM d, yyyy")
}

function MessageBubble({
  message,
  participant,
  isOwn,
  showAvatar,
  onDownloadFile,
}: {
  message: ChatMessage
  participant?: ChatParticipant
  isOwn: boolean
  showAvatar: boolean
  onDownloadFile?: (message: ChatMessage) => void
}) {
  const initials = message.sender_name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)

  const getRoleColor = (role: string) => {
    switch (role) {
      case "supervisor":
        return "bg-primary text-primary-foreground"
      case "user":
        return "bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300"
      case "doer":
        return "bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300"
      default:
        return "bg-muted text-muted-foreground"
    }
  }

  // System message
  if (message.type === "system" || message.sender_role === "system") {
    return (
      <div className="flex justify-center my-4">
        <div className="px-3 py-1.5 rounded-full bg-muted text-muted-foreground text-xs">
          {message.content}
        </div>
      </div>
    )
  }

  return (
    <div
      className={cn(
        "flex gap-2 max-w-[85%]",
        isOwn ? "ml-auto flex-row-reverse" : ""
      )}
    >
      {/* Avatar */}
      <div className={cn("shrink-0", !showAvatar && "invisible")}>
        <Avatar className="h-8 w-8">
          <AvatarImage src={participant?.avatar_url} />
          <AvatarFallback className={cn("text-xs", getRoleColor(message.sender_role))}>
            {initials}
          </AvatarFallback>
        </Avatar>
      </div>

      {/* Message Content */}
      <div className={cn("space-y-1", isOwn ? "items-end" : "items-start")}>
        {/* Sender Info */}
        {showAvatar && (
          <div
            className={cn(
              "flex items-center gap-2 text-xs",
              isOwn ? "flex-row-reverse" : ""
            )}
          >
            <span className="font-medium">{message.sender_name}</span>
            <Badge variant="outline" className="text-[10px] px-1.5 py-0">
              {message.sender_role}
            </Badge>
          </div>
        )}

        {/* Message Bubble */}
        <div
          className={cn(
            "rounded-2xl px-4 py-2 max-w-full",
            isOwn
              ? "bg-primary text-primary-foreground rounded-tr-sm"
              : "bg-muted rounded-tl-sm",
            message.is_contact_flagged && "border-2 border-destructive"
          )}
        >
          {/* Contact Warning */}
          {message.is_contact_flagged && (
            <div className="flex items-center gap-1.5 text-destructive text-xs mb-2 pb-2 border-b border-destructive/20">
              <AlertTriangle className="h-3.5 w-3.5" />
              <span>Contact info detected - Message flagged</span>
            </div>
          )}

          {/* Text Content */}
          {(message.type === "text" || message.type === "action") && (
            <p className="text-sm whitespace-pre-wrap break-words">
              {message.content}
            </p>
          )}

          {/* File Attachment */}
          {(message.type === "file" || message.type === "image") && (
            <div className="space-y-2">
              {message.type === "image" && message.file_url && (
                <img
                  src={message.file_url}
                  alt={message.file_name || "Image"}
                  className="max-w-[300px] rounded-lg"
                />
              )}
              {message.file_name && (
                <div
                  className={cn(
                    "flex items-center gap-2 p-2 rounded-lg",
                    isOwn ? "bg-primary-foreground/10" : "bg-background"
                  )}
                >
                  {message.type === "image" ? (
                    <ImageIcon className="h-4 w-4 shrink-0" />
                  ) : (
                    <FileText className="h-4 w-4 shrink-0" />
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">
                      {message.file_name}
                    </p>
                    {message.file_size && (
                      <p className="text-xs opacity-70">
                        {(message.file_size / 1024).toFixed(1)} KB
                      </p>
                    )}
                  </div>
                  <TooltipProvider>
                    <Tooltip>
                      <TooltipTrigger asChild>
                        <Button
                          variant="ghost"
                          size="icon"
                          className="h-8 w-8 shrink-0"
                          onClick={() => onDownloadFile?.(message)}
                        >
                          <Download className="h-4 w-4" />
                        </Button>
                      </TooltipTrigger>
                      <TooltipContent>Download</TooltipContent>
                    </Tooltip>
                  </TooltipProvider>
                </div>
              )}
              {message.content && (
                <p className="text-sm whitespace-pre-wrap break-words">
                  {message.content}
                </p>
              )}
            </div>
          )}
        </div>

        {/* Timestamp and Read Status */}
        <div
          className={cn(
            "flex items-center gap-1.5 text-[10px] text-muted-foreground",
            isOwn ? "flex-row-reverse" : ""
          )}
        >
          <span>{format(new Date(message.created_at), "h:mm a")}</span>
          {isOwn && (
            message.is_read ? (
              <CheckCheck className="h-3 w-3 text-blue-500" />
            ) : (
              <Check className="h-3 w-3" />
            )
          )}
        </div>
      </div>
    </div>
  )
}

export function MessageList({
  messages,
  participants,
  currentUserId,
  onDownloadFile,
}: MessageListProps) {
  const scrollRef = useRef<HTMLDivElement>(null)
  const participantMap = new Map(participants.map((p) => [p.user_id, p]))

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [messages])

  // Group messages by date
  const groupedMessages: { date: Date; messages: ChatMessage[] }[] = []
  let currentDate: Date | null = null
  let currentGroup: ChatMessage[] = []

  messages.forEach((message) => {
    const messageDate = new Date(message.created_at)
    if (!currentDate || !isSameDay(currentDate, messageDate)) {
      if (currentGroup.length > 0) {
        groupedMessages.push({ date: currentDate!, messages: currentGroup })
      }
      currentDate = messageDate
      currentGroup = [message]
    } else {
      currentGroup.push(message)
    }
  })
  if (currentGroup.length > 0 && currentDate) {
    groupedMessages.push({ date: currentDate, messages: currentGroup })
  }

  return (
    <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 space-y-4">
      {groupedMessages.map((group, groupIndex) => (
        <div key={groupIndex} className="space-y-3">
          {/* Date Separator */}
          <div className="flex items-center gap-4 my-4">
            <div className="flex-1 h-px bg-border" />
            <span className="text-xs text-muted-foreground font-medium">
              {formatMessageDate(group.date)}
            </span>
            <div className="flex-1 h-px bg-border" />
          </div>

          {/* Messages */}
          {group.messages.map((message, index) => {
            const isOwn = message.sender_role === "supervisor" || (!message.sender_role && message.sender_id === currentUserId)
            const prevMessage = group.messages[index - 1]
            const showAvatar =
              !prevMessage || prevMessage.sender_id !== message.sender_id

            return (
              <MessageBubble
                key={message.id}
                message={message}
                participant={participantMap.get(message.sender_id)}
                isOwn={isOwn}
                showAvatar={showAvatar}
                onDownloadFile={onDownloadFile}
              />
            )
          })}
        </div>
      ))}

      {messages.length === 0 && (
        <div className="flex flex-col items-center justify-center h-full text-center text-muted-foreground">
          <p className="text-sm">No messages yet</p>
          <p className="text-xs mt-1">Start the conversation!</p>
        </div>
      )}
    </div>
  )
}
