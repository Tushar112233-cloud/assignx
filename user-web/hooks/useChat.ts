"use client"

import { useState, useEffect, useCallback, useRef } from "react"
import { toast } from "sonner"
import { chatService, type MessageWithSender } from "@/services"

/**
 * Chat state
 */
interface ChatState {
  messages: MessageWithSender[]
  isLoading: boolean
  isSending: boolean
  hasMore: boolean
  error: string | null
}

/**
 * useChat hook
 * Manages real-time chat state and operations for a project
 */
export function useChat(projectId: string | null, userId: string | null) {
  const [roomId, setRoomId] = useState<string | null>(null)
  const [state, setState] = useState<ChatState>({
    messages: [],
    isLoading: true,
    isSending: false,
    hasMore: true,
    error: null,
  })
  const unsubscribeRef = useRef<(() => void) | null>(null)

  /**
   * Initialize chat room and load messages
   */
  useEffect(() => {
    if (!projectId || !userId) {
      setState((prev) => ({ ...prev, isLoading: false }))
      return
    }

    let isMounted = true

    const initChat = async () => {
      setState((prev) => ({ ...prev, isLoading: true, error: null }))

      try {
        // Get or create chat room
        const room = await chatService.getOrCreateProjectChatRoom(projectId, userId)
        if (!isMounted) return

        setRoomId(room.id)

        // Load initial messages
        const messages = await chatService.getMessages(room.id, 50)
        if (!isMounted) return

        setState((prev) => ({
          ...prev,
          messages,
          isLoading: false,
          hasMore: messages.length === 50,
        }))

        // Mark messages as read
        chatService.markMessagesAsRead(room.id, userId)

        // Subscribe to real-time updates
        unsubscribeRef.current = chatService.subscribeToRoom(room.id, async (newMessage) => {
          // Only show messages that are approved or from current user.
          // Doer messages start as 'pending' and need supervisor approval.
          const msgApproval = (newMessage as any).approvalStatus || (newMessage as any).approval_status
          const isSenderCurrentUser = newMessage.sender_id === userId || (newMessage as any).senderId === userId
          if (msgApproval === 'pending' && !isSenderCurrentUser) {
            // Pending message from someone else — skip (user shouldn't see it)
            return
          }
          if (msgApproval === 'rejected' && !isSenderCurrentUser) {
            return
          }

          // Fetch the complete message with sender info
          try {
            const messagesWithSender = await chatService.getMessages(room.id, 1)
            const fullMessage = messagesWithSender.find(m => m.id === newMessage.id)

            // If API didn't return the message (filtered out), skip it
            if (!fullMessage) return

            setState((prev) => {
              if (prev.messages.some(m => m.id === newMessage.id)) {
                return prev
              }
              return {
                ...prev,
                messages: [...prev.messages, fullMessage],
              }
            })

            // Mark as read if from other user
            if (newMessage.sender_id !== userId) {
              chatService.markMessagesAsRead(room.id, userId)
            }
          } catch (error) {
            console.error("Error fetching new message:", error)
            // Only add the raw message if it's from the current user (safe to show)
            if (isSenderCurrentUser) {
              setState((prev) => {
                if (prev.messages.some(m => m.id === newMessage.id)) {
                  return prev
                }
                return {
                  ...prev,
                  messages: [...prev.messages, newMessage],
                }
              })
            }
          }
        })
      } catch (error: any) {
        if (!isMounted) return
        console.error("Chat init error:", error)
        setState((prev) => ({
          ...prev,
          isLoading: false,
          error: error.message || "Failed to load chat",
        }))
      }
    }

    initChat()

    return () => {
      isMounted = false
      if (unsubscribeRef.current) {
        unsubscribeRef.current()
        unsubscribeRef.current = null
      }
    }
  }, [projectId, userId])

  /**
   * Load more messages (pagination)
   */
  const loadMore = useCallback(async () => {
    if (!roomId || !state.hasMore || state.isLoading) return

    const oldestMessage = state.messages[0]
    if (!oldestMessage) return

    setState((prev) => ({ ...prev, isLoading: true }))

    try {
      const olderMessages = await chatService.getMessages(roomId, 50, oldestMessage.created_at ?? undefined)
      setState((prev) => ({
        ...prev,
        messages: [...olderMessages, ...prev.messages],
        isLoading: false,
        hasMore: olderMessages.length === 50,
      }))
    } catch (error: any) {
      console.error("Load more error:", error)
      setState((prev) => ({ ...prev, isLoading: false }))
      toast.error("Failed to load older messages")
    }
  }, [roomId, state.messages, state.hasMore, state.isLoading])

  /**
   * Send a message
   */
  const sendMessage = useCallback(
    async (content: string, attachmentUrl?: string): Promise<boolean> => {
      if (!roomId || !userId || !content.trim()) return false

      setState((prev) => ({ ...prev, isSending: true }))

      try {
        const newMessage = await chatService.sendMessage(roomId, userId, content.trim(), attachmentUrl)
        setState((prev) => ({
          ...prev,
          isSending: false,
          messages: prev.messages.some((m) => m.id === newMessage.id)
            ? prev.messages
            : [...prev.messages, newMessage],
        }))
        return true
      } catch (error: any) {
        console.error("Send message error:", error)
        setState((prev) => ({ ...prev, isSending: false }))
        toast.error(error.message || "Failed to send message")
        return false
      }
    },
    [roomId, userId]
  )

  /**
   * Upload attachment and send message
   */
  const sendMessageWithAttachment = useCallback(
    async (content: string, file: File): Promise<boolean> => {
      if (!roomId || !userId) return false

      setState((prev) => ({ ...prev, isSending: true }))

      try {
        const attachmentUrl = await chatService.uploadAttachment(roomId, file)
        const newMessage = await chatService.sendMessage(roomId, userId, content || `Sent ${file.name}`, attachmentUrl)
        setState((prev) => ({
          ...prev,
          isSending: false,
          messages: prev.messages.some((m) => m.id === newMessage.id)
            ? prev.messages
            : [...prev.messages, newMessage],
        }))
        return true
      } catch (error: any) {
        console.error("Send attachment error:", error)
        setState((prev) => ({ ...prev, isSending: false }))
        toast.error(error.message || "Failed to send attachment")
        return false
      }
    },
    [roomId, userId]
  )

  /**
   * Get typing indicator (placeholder for future)
   */
  const setTyping = useCallback(
    async (isTyping: boolean) => {
      if (!roomId || !userId) return
      // Typing indicators can be implemented using API presence
      // For now, this is a placeholder
    },
    [roomId, userId]
  )

  return {
    ...state,
    roomId,
    sendMessage,
    sendMessageWithAttachment,
    loadMore,
    setTyping,
  }
}
