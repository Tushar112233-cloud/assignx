/**
 * Chat management hook using Zustand
 * Manages real-time chat state and operations
 */

import { create } from 'zustand'
import { useEffect, useRef } from 'react'
import type {
  ChatRoom,
  ChatMessage,
  ChatParticipant,
} from '@/types/database'
import {
  getOrCreateProjectChatRoom,
  getChatMessages,
  sendMessage,
  sendFileMessage,
  markMessagesAsRead,
  getUnreadCount,
  getChatParticipants,
  subscribeToMessages,
  unsubscribeFromMessages,
  joinChatRoom,
} from '@/services/chat.service'
import type { RealtimeChannel } from '@supabase/supabase-js'

interface ChatState {
  /** Current chat room */
  currentRoom: ChatRoom | null
  /** Messages in current room */
  messages: ChatMessage[]
  /** Participants in current room */
  participants: ChatParticipant[]
  /** Unread count */
  unreadCount: number
  /** Loading state */
  isLoading: boolean
  /** Sending state */
  isSending: boolean
  /** Error state */
  error: string | null
  /** Has more messages to load */
  hasMore: boolean

  /** Initialize chat room for a project */
  initializeProjectChat: (projectId: string) => Promise<ChatRoom>
  /** Load messages */
  loadMessages: (roomId: string, loadMore?: boolean) => Promise<void>
  /** Send a text message (uses authenticated user) */
  sendTextMessage: (roomId: string, content: string) => Promise<void>
  /** Send a file message (uses authenticated user) */
  sendFile: (roomId: string, file: File) => Promise<void>
  /** Add a new message (from subscription) */
  addMessage: (message: ChatMessage) => void
  /** Mark messages as read (uses authenticated user) */
  markAsRead: (roomId: string) => Promise<void>
  /** Join a room as participant */
  joinRoom: (
    roomId: string,
    userId: string,
    role: 'user' | 'supervisor' | 'doer' | 'admin'
  ) => Promise<void>
  /** Get unread count (uses authenticated user) */
  fetchUnreadCount: (roomId: string) => Promise<void>
  /** Clear current room */
  clearRoom: () => void
  /** Clear error */
  clearError: () => void
}

export const useChatStore = create<ChatState>((set, get) => ({
  currentRoom: null,
  messages: [],
  participants: [],
  unreadCount: 0,
  isLoading: false,
  isSending: false,
  error: null,
  hasMore: true,

  initializeProjectChat: async (projectId: string) => {
    set({ isLoading: true, error: null })
    try {
      const room = await getOrCreateProjectChatRoom(projectId)
      const participants = await getChatParticipants(room.id)

      set({
        currentRoom: room,
        participants,
        isLoading: false,
      })

      return room
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to initialize chat',
        isLoading: false,
      })
      throw error
    }
  },

  loadMessages: async (roomId: string, loadMore = false) => {
    const state = get()
    if (state.isLoading) return

    set({ isLoading: true, error: null })
    try {
      const before = loadMore && state.messages.length > 0
        ? state.messages[0].created_at
        : undefined

      const newMessages = await getChatMessages(roomId, 50, before)

      set((state) => ({
        messages: loadMore
          ? [...newMessages, ...state.messages]
          : newMessages,
        hasMore: newMessages.length === 50,
        isLoading: false,
      }))
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to load messages',
        isLoading: false,
      })
    }
  },

  sendTextMessage: async (roomId: string, content: string) => {
    set({ isSending: true, error: null })
    try {
      // sendMessage now uses authenticated user's ID internally
      const message = await sendMessage(roomId, content)

      // Message will be added via subscription, but add locally for immediate feedback
      set((state) => ({
        messages: [...state.messages, message],
        isSending: false,
      }))
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to send message',
        isSending: false,
      })
      throw error
    }
  },

  sendFile: async (roomId: string, file: File) => {
    set({ isSending: true, error: null })
    try {
      // sendFileMessage now uses authenticated user's ID internally
      const message = await sendFileMessage(roomId, file)

      set((state) => ({
        messages: [...state.messages, message],
        isSending: false,
      }))
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to send file',
        isSending: false,
      })
      throw error
    }
  },

  addMessage: (message: ChatMessage) => {
    set((state) => {
      // Avoid duplicates
      if (state.messages.some((m) => m.id === message.id)) {
        return state
      }
      return {
        messages: [...state.messages, message],
      }
    })
  },

  markAsRead: async (roomId: string) => {
    try {
      // markMessagesAsRead now uses authenticated user's ID internally
      await markMessagesAsRead(roomId)
      set({ unreadCount: 0 })
    } catch (error) {
      console.error('Failed to mark messages as read:', error)
    }
  },

  joinRoom: async (
    roomId: string,
    userId: string,
    role: 'user' | 'supervisor' | 'doer' | 'admin'
  ) => {
    try {
      const participant = await joinChatRoom(
        roomId,
        userId,
        role
      )

      set((state) => {
        // Avoid duplicates
        if (state.participants.some((p) => p.profile_id === userId)) {
          return state
        }
        return {
          participants: [...state.participants, participant],
        }
      })
    } catch (error) {
      console.error('Failed to join room:', error)
    }
  },

  fetchUnreadCount: async (roomId: string) => {
    try {
      // getUnreadCount now uses authenticated user's ID internally
      const count = await getUnreadCount(roomId)
      set({ unreadCount: count })
    } catch (error) {
      console.error('Failed to fetch unread count:', error)
    }
  },

  clearRoom: () => {
    set({
      currentRoom: null,
      messages: [],
      participants: [],
      unreadCount: 0,
      hasMore: true,
    })
  },

  clearError: () => {
    set({ error: null })
  },
}))

/**
 * Hook to manage chat subscription
 * Handles real-time message updates
 */
export function useChat(roomId: string | null, userId: string | null) {
  const channelRef = useRef<RealtimeChannel | null>(null)
  const store = useChatStore()

  useEffect(() => {
    if (!roomId) return

    // Load initial messages
    store.loadMessages(roomId)

    // Subscribe to new messages
    channelRef.current = subscribeToMessages(roomId, (message) => {
      // Only add if not from current user (to avoid duplicates)
      if (message.sender_id !== userId) {
        store.addMessage(message)
      }
    })

    // Cleanup subscription
    return () => {
      if (channelRef.current) {
        unsubscribeFromMessages(channelRef.current)
        channelRef.current = null
      }
    }
  }, [roomId, userId])

  // Mark as read when messages change
  useEffect(() => {
    if (roomId && store.messages.length > 0) {
      store.markAsRead(roomId)
    }
  }, [roomId, store.messages.length])

  return store
}
