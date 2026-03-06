"use client"

import { useState, useRef, useEffect, useCallback, useMemo, type KeyboardEvent } from "react"
import { X, Send, Paperclip, Loader2, ChevronUp, User, AlertTriangle, Shield } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet"
import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import { useChat } from "@/hooks/useChat"
import { validateChatContent, getValidationErrorMessage } from "@/lib/validations/chat-content"
import { flagUserForViolation, type FlagReason } from "@/lib/actions/user-flagging"
import type { MessageWithSender } from "@/services"
import {
  MessageApprovalBadge,
  MessageApprovalBadgeInline,
  type MessageApprovalStatus,
} from "./message-approval-badge"
import {
  SupervisorMessageActionsCompact,
} from "./supervisor-message-actions"
import { TypingIndicator, useTypingIndicator } from "./typing-indicator"
import { ChatPresenceBanner, OnlineUsersIndicator, useChatPresence } from "./chat-presence"

/**
 * Extended message type with approval fields
 */
interface MessageWithApproval extends MessageWithSender {
  approval_status?: MessageApprovalStatus
  approved_by?: string
  approved_at?: string
  rejection_reason?: string
  approver?: {
    id: string
    full_name: string
  }
}

/**
 * User role type for permission checks
 */
type UserRole = "client" | "doer" | "supervisor"

/**
 * Props for ChatWindow component
 */
interface ChatWindowProps {
  isOpen: boolean
  onClose: () => void
  projectId: string
  userId: string
  /** Current user's display name for presence */
  userName?: string
  supervisorName?: string
  projectNumber?: string
  /** The current user's role in the project */
  userRole?: UserRole
  /** Whether the current user is a supervisor */
  isSupervisor?: boolean
}

/**
 * Format timestamp for display
 */
function formatTime(timestamp: string): string {
  const date = new Date(timestamp)
  const now = new Date()
  const diffDays = Math.floor(
    (now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24)
  )

  if (diffDays === 0) {
    return date.toLocaleTimeString("en-IN", {
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  if (diffDays === 1) {
    return `Yesterday ${date.toLocaleTimeString("en-IN", {
      hour: "2-digit",
      minute: "2-digit",
    })}`
  }

  return date.toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  })
}

/**
 * Check if a message requires approval routing
 * Client-to-Doer messages require supervisor approval
 */
function requiresApproval(
  message: MessageWithApproval,
  userRole: UserRole
): boolean {
  // Messages from client or doer (not supervisor) require approval
  // This is simplified - in production, you'd check the sender's role
  return userRole !== "supervisor" && !message.approval_status
}

/**
 * Check if a message should be visible to the user
 */
function isMessageVisible(
  message: MessageWithApproval,
  userId: string,
  userRole: UserRole
): boolean {
  // Supervisors see all messages
  if (userRole === "supervisor") {
    return true
  }

  // Users always see their own messages
  if (message.sender_id === userId) {
    return true
  }

  // For non-supervisor users, only show approved messages or pending messages from themselves
  const status = message.approval_status || "pending"

  // If no approval status set (legacy messages), show them
  if (!message.approval_status) {
    return true
  }

  return status === "approved"
}

/**
 * Single chat message bubble with approval status
 */
function MessageBubble({
  message,
  isCurrentUser,
  userRole,
  userId,
  onApprove,
  onReject,
}: {
  message: MessageWithApproval
  isCurrentUser: boolean
  userRole: UserRole
  userId: string
  onApprove?: (messageId: string) => void
  onReject?: (messageId: string, reason: string) => void
}) {
  const senderName = message.sender?.full_name || message.sender?.email || "Unknown"
  const senderInitial = senderName.charAt(0).toUpperCase()

  const approvalStatus = message.approval_status as MessageApprovalStatus | undefined
  const showApprovalBadge = approvalStatus && approvalStatus !== "approved"
  const showSupervisorActions =
    userRole === "supervisor" &&
    approvalStatus === "pending"
  const showRejectionReason =
    isCurrentUser &&
    approvalStatus === "rejected" &&
    message.rejection_reason

  return (
    <div
      className={cn(
        "flex gap-2",
        isCurrentUser ? "flex-row-reverse" : "flex-row"
      )}
    >
      <Avatar className="h-8 w-8 shrink-0">
        <AvatarImage src={message.sender?.avatar_url || undefined} />
        <AvatarFallback
          className={cn(
            "text-xs",
            isCurrentUser
              ? "bg-primary text-primary-foreground"
              : "bg-muted text-muted-foreground"
          )}
        >
          {isCurrentUser ? <User className="h-4 w-4" /> : senderInitial}
        </AvatarFallback>
      </Avatar>

      <div
        className={cn(
          "flex max-w-[75%] flex-col",
          isCurrentUser ? "items-end" : "items-start"
        )}
      >
        <span className="mb-1 flex items-center gap-1.5 text-xs text-muted-foreground">
          {senderName}
          {(message as any).sender_role && (
            <Badge
              variant="outline"
              className="px-1 py-0 text-[9px] h-4 capitalize"
            >
              {(message as any).sender_role}
            </Badge>
          )}
        </span>

        <div className="relative">
          <div
            className={cn(
              "rounded-2xl px-4 py-2",
              isCurrentUser
                ? "rounded-tr-sm bg-primary text-primary-foreground"
                : "rounded-tl-sm bg-muted",
              // Dim pending messages slightly for visual distinction
              approvalStatus === "pending" && "opacity-80"
            )}
          >
            <p className="text-sm whitespace-pre-wrap break-words">{message.content}</p>
            {message.file_url && (
              <a
                href={message.file_url}
                target="_blank"
                rel="noopener noreferrer"
                className={cn(
                  "mt-2 flex items-center gap-1 text-xs underline",
                  isCurrentUser ? "text-primary-foreground/80" : "text-muted-foreground"
                )}
              >
                <Paperclip className="h-3 w-3" />
                View attachment
              </a>
            )}
          </div>

          {/* Approval badge positioned at bottom-right of message bubble */}
          {showApprovalBadge && (
            <div className="absolute -bottom-1 -right-1">
              <MessageApprovalBadge
                status={approvalStatus}
                approvedBy={message.approver?.full_name}
                approvedAt={message.approved_at}
                rejectionReason={message.rejection_reason}
                size="sm"
              />
            </div>
          )}
        </div>

        {/* Supervisor action buttons */}
        {showSupervisorActions && (
          <div className="mt-1">
            <SupervisorMessageActionsCompact
              messageId={message.id}
              supervisorId={userId}
              onApprove={onApprove}
              onReject={onReject}
            />
          </div>
        )}

        {/* Rejection reason shown to sender */}
        {showRejectionReason && (
          <div className="mt-1">
            <MessageApprovalBadgeInline
              status="rejected"
              rejectionReason={message.rejection_reason}
            />
          </div>
        )}

        <span className="mt-1 text-[10px] text-muted-foreground">
          {message.created_at && formatTime(message.created_at)}
          {message.is_read && isCurrentUser && (
            <span className="ml-1">✓</span>
          )}
          {approvalStatus === "pending" && isCurrentUser && (
            <span className="ml-1 text-amber-600 dark:text-amber-400">
              • Pending approval
            </span>
          )}
        </span>
      </div>
    </div>
  )
}

/**
 * Date separator between messages
 */
function DateSeparator({ date }: { date: string }) {
  return (
    <div className="flex items-center gap-4 py-2">
      <div className="h-px flex-1 bg-border" />
      <span className="text-xs text-muted-foreground">{date}</span>
      <div className="h-px flex-1 bg-border" />
    </div>
  )
}

/**
 * Pending messages banner for supervisors
 */
function PendingMessagesBanner({
  count,
  onScrollToPending,
}: {
  count: number
  onScrollToPending?: () => void
}) {
  if (count === 0) return null

  return (
    <div
      className={cn(
        "flex items-center justify-between gap-2 rounded-lg border px-3 py-2",
        "bg-amber-50 border-amber-200 dark:bg-amber-900/20 dark:border-amber-700"
      )}
    >
      <div className="flex items-center gap-2">
        <Shield className="h-4 w-4 text-amber-600 dark:text-amber-400" />
        <span className="text-xs font-medium text-amber-700 dark:text-amber-300">
          {count} message{count !== 1 ? "s" : ""} pending approval
        </span>
      </div>
      {onScrollToPending && (
        <Button
          variant="ghost"
          size="sm"
          className="h-6 px-2 text-xs text-amber-700 hover:text-amber-800 dark:text-amber-300"
          onClick={onScrollToPending}
        >
          Review
        </Button>
      )}
    </div>
  )
}

/**
 * Chat window overlay/sheet with real-time messaging and approval workflow
 */
export function ChatWindow({
  isOpen,
  onClose,
  projectId,
  userId,
  userName = "You",
  supervisorName,
  projectNumber,
  userRole = "client",
  isSupervisor = false,
}: ChatWindowProps) {
  const [inputValue, setInputValue] = useState("")
  const [showViolationAlert, setShowViolationAlert] = useState(false)
  const [violationMessage, setViolationMessage] = useState("")
  const scrollRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null)

  // Determine effective role
  const effectiveRole: UserRole = isSupervisor ? "supervisor" : userRole

  const {
    messages,
    isLoading,
    isSending,
    hasMore,
    sendMessage,
    loadMore,
  } = useChat(isOpen ? projectId : null, isOpen ? userId : null)

  // Typing indicator hook
  const { isAnyoneTyping, typingDisplayName, broadcastTyping } = useTypingIndicator(
    isOpen ? projectId : null,
    isOpen ? userId : null,
  )

  // Presence hook
  const { onlineUsers, presenceEvents, removePresenceEvent } = useChatPresence(
    isOpen ? projectId : null,
    isOpen ? userId : null,
    userName,
    effectiveRole,
  )

  // Cast messages to include approval fields
  const messagesWithApproval = messages as MessageWithApproval[]

  // Filter messages based on user role and approval status
  const visibleMessages = useMemo(() => {
    return messagesWithApproval.filter((msg) =>
      isMessageVisible(msg, userId, effectiveRole)
    )
  }, [messagesWithApproval, userId, effectiveRole])

  // Count pending messages for supervisor banner
  const pendingCount = useMemo(() => {
    if (effectiveRole !== "supervisor") return 0
    return messagesWithApproval.filter(
      (msg) => msg.approval_status === "pending"
    ).length
  }, [messagesWithApproval, effectiveRole])

  /**
   * Handle typing status broadcast with debounce
   */
  const handleTypingStart = useCallback(() => {
    broadcastTyping(true, userName)

    // Clear existing timeout
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current)
    }

    // Stop typing after 3 seconds of inactivity
    typingTimeoutRef.current = setTimeout(() => {
      broadcastTyping(false, userName)
    }, 3000)
  }, [broadcastTyping, userName])

  /**
   * Stop typing broadcast
   */
  const handleTypingStop = useCallback(() => {
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current)
    }
    broadcastTyping(false, userName)
  }, [broadcastTyping, userName])

  /**
   * Auto-scroll to bottom when new messages arrive
   */
  useEffect(() => {
    if (scrollRef.current && visibleMessages.length > 0) {
      // Small delay to allow render
      setTimeout(() => {
        if (scrollRef.current) {
          scrollRef.current.scrollTop = scrollRef.current.scrollHeight
        }
      }, 100)
    }
  }, [visibleMessages])

  /**
   * Focus input when opened
   */
  useEffect(() => {
    if (isOpen && inputRef.current) {
      setTimeout(() => inputRef.current?.focus(), 200)
    }
  }, [isOpen])

  /**
   * Cleanup typing timeout on unmount
   */
  useEffect(() => {
    return () => {
      if (typingTimeoutRef.current) {
        clearTimeout(typingTimeoutRef.current)
      }
    }
  }, [])

  /**
   * Handle content violation - flag user and close chat
   */
  const handleViolation = useCallback(
    async (reason: FlagReason, message: string) => {
      // Flag user in database
      if (userId) {
        await flagUserForViolation(userId, reason)
      }

      // Show violation alert
      setViolationMessage(message)
      setShowViolationAlert(true)
      setInputValue("")
    },
    [userId]
  )

  /**
   * Close chat after violation acknowledged
   */
  const handleViolationClose = useCallback(() => {
    setShowViolationAlert(false)
    setViolationMessage("")
    onClose()
  }, [onClose])

  /**
   * Handle send message with content validation
   */
  const handleSend = useCallback(async () => {
    if (!inputValue.trim() || isSending) return

    // Stop typing broadcast
    handleTypingStop()

    // Validate content before sending
    const validation = validateChatContent(inputValue)
    if (!validation.isValid) {
      const reasonMap: Record<string, FlagReason> = {
        phone: "phone_sharing",
        email: "email_sharing",
        link: "link_sharing",
        address: "address_sharing",
      }
      const flagReason = reasonMap[validation.reason || ""] || "link_sharing"
      await handleViolation(flagReason, getValidationErrorMessage(validation))
      return
    }

    const success = await sendMessage(inputValue)
    if (success) {
      setInputValue("")
    }
  }, [inputValue, isSending, sendMessage, handleViolation, handleTypingStop])

  /**
   * Handle input change with typing broadcast
   */
  const handleInputChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setInputValue(e.target.value)
      if (e.target.value.trim()) {
        handleTypingStart()
      } else {
        handleTypingStop()
      }
    },
    [handleTypingStart, handleTypingStop]
  )

  /**
   * Handle keyboard shortcuts
   */
  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }


  /**
   * Handle message approval (refresh messages)
   */
  const handleMessageApprove = useCallback((messageId: string) => {
    // The message list will auto-update via realtime subscription
    // or we can force a refresh here if needed
  }, [])

  /**
   * Handle message rejection (refresh messages)
   */
  const handleMessageReject = useCallback((messageId: string, reason: string) => {
    // The message list will auto-update via realtime subscription
  }, [])

  /**
   * Group messages by date
   */
  const groupedMessages = visibleMessages.reduce<
    { date: string; messages: MessageWithApproval[] }[]
  >((groups, message) => {
    const dateStr = message.created_at
      ? new Date(message.created_at).toLocaleDateString("en-IN", {
          day: "numeric",
          month: "long",
          year: "numeric",
        })
      : "Unknown Date"

    const existingGroup = groups.find((g) => g.date === dateStr)
    if (existingGroup) {
      existingGroup.messages.push(message)
    } else {
      groups.push({ date: dateStr, messages: [message] })
    }

    return groups
  }, [])

  return (
    <Sheet open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <SheetContent
        side="right"
        className="flex w-full flex-col p-0 sm:max-w-md"
      >
        {/* Header */}
        <SheetHeader className="border-b px-4 py-3">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <SheetTitle className="text-left text-base">
                Chat with {supervisorName || "Supervisor"}
              </SheetTitle>
              <div className="mt-1 flex items-center gap-2">
                {projectNumber && (
                  <p className="text-xs text-muted-foreground">{projectNumber}</p>
                )}
                {effectiveRole === "supervisor" && (
                  <Badge variant="secondary" className="text-[10px] px-1.5 py-0">
                    <Shield className="mr-1 h-2.5 w-2.5" />
                    Supervisor
                  </Badge>
                )}
                {/* Online users indicator */}
                {onlineUsers.length > 0 && (
                  <OnlineUsersIndicator users={onlineUsers} maxAvatars={3} />
                )}
              </div>
            </div>
            <Button variant="ghost" size="icon" onClick={onClose}>
              <X className="h-5 w-5" />
              <span className="sr-only">Close chat</span>
            </Button>
          </div>
        </SheetHeader>

        {/* Presence events banner */}
        <div className="absolute top-20 left-0 right-0 z-10 px-4">
          <ChatPresenceBanner
            events={presenceEvents}
            onEventDismiss={removePresenceEvent}
          />
        </div>

        {/* Pending messages banner for supervisors */}
        {effectiveRole === "supervisor" && pendingCount > 0 && (
          <div className="border-b px-4 py-2">
            <PendingMessagesBanner count={pendingCount} />
          </div>
        )}

        {/* Messages */}
        <ScrollArea className="flex-1 p-4" ref={scrollRef}>
          {/* Load more button */}
          {hasMore && !isLoading && visibleMessages.length > 0 && (
            <div className="mb-4 flex justify-center">
              <Button
                variant="ghost"
                size="sm"
                onClick={loadMore}
                className="gap-1"
              >
                <ChevronUp className="h-4 w-4" />
                Load earlier messages
              </Button>
            </div>
          )}

          {/* Loading state */}
          {isLoading && visibleMessages.length === 0 && (
            <div className="flex h-full items-center justify-center">
              <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
            </div>
          )}

          {/* Empty state */}
          {!isLoading && visibleMessages.length === 0 && (
            <div className="flex h-full items-center justify-center">
              <p className="text-center text-sm text-muted-foreground">
                No messages yet. Start a conversation!
              </p>
            </div>
          )}

          {/* Messages grouped by date */}
          {groupedMessages.map((group) => (
            <div key={group.date}>
              <DateSeparator date={group.date} />
              <div className="space-y-4">
                {group.messages.map((message) => (
                  <MessageBubble
                    key={message.id}
                    message={message}
                    isCurrentUser={
                      // For new messages: only own if sender_role is "user" (not supervisor/doer)
                      // For legacy messages (no sender_role): fall back to sender_id match
                      (message as any).sender_role === "user"
                        ? message.sender_id === userId
                        : !(message as any).sender_role && message.sender_id === userId
                    }
                    userRole={effectiveRole}
                    userId={userId}
                    onApprove={handleMessageApprove}
                    onReject={handleMessageReject}
                  />
                ))}
              </div>
            </div>
          ))}
        </ScrollArea>

        {/* Typing indicator */}
        <TypingIndicator
          typerName={typingDisplayName}
          isTyping={isAnyoneTyping}
          className="border-t border-border/50 bg-muted/30"
        />

        {/* Input */}
        <div className="border-t p-4">
          {/* Note for non-supervisor users about message routing */}
          {effectiveRole !== "supervisor" && (
            <p className="mb-2 text-[10px] text-muted-foreground text-center">
              Messages are reviewed by supervisor before delivery
            </p>
          )}

          <div className="flex gap-2">
            {/* Text input */}
            <Input
              ref={inputRef}
              placeholder="Type a message..."
              value={inputValue}
              onChange={handleInputChange}
              onKeyDown={handleKeyDown}
              onBlur={handleTypingStop}
              disabled={isSending}
              className="flex-1"
            />

            {/* Send button */}
            <Button
              size="icon"
              onClick={handleSend}
              disabled={!inputValue.trim() || isSending}
            >
              {isSending ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Send className="h-4 w-4" />
              )}
              <span className="sr-only">Send message</span>
            </Button>
          </div>
        </div>
      </SheetContent>

      {/* Policy Violation Alert */}
      <AlertDialog open={showViolationAlert} onOpenChange={setShowViolationAlert}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-destructive">
              <AlertTriangle className="h-5 w-5" />
              Policy Violation Detected
            </AlertDialogTitle>
            <AlertDialogDescription className="text-base">
              {violationMessage}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <Button onClick={handleViolationClose} variant="destructive">
              I Understand
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </Sheet>
  )
}
