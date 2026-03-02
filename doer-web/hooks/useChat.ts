/**
 * Chat management hook using Zustand
 * Manages real-time chat state and operations via Socket.IO
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

interface ChatState {
  currentRoom: ChatRoom | null
  messages: ChatMessage[]
  participants: ChatParticipant[]
  unreadCount: number
  isLoading: boolean
  isSending: boolean
  error: string | null
  hasMore: boolean

  initializeProjectChat: (projectId: string) => Promise<ChatRoom>
  loadMessages: (roomId: string, loadMore?: boolean) => Promise<void>
  sendTextMessage: (roomId: string, content: string) => Promise<void>
  sendFile: (roomId: string, file: File) => Promise<void>
  addMessage: (message: ChatMessage) => void
  markAsRead: (roomId: string) => Promise<void>
  joinRoom: (
    roomId: string,
    userId: string,
    role: 'user' | 'supervisor' | 'doer' | 'admin'
  ) => Promise<void>
  fetchUnreadCount: (roomId: string) => Promise<void>
  clearRoom: () => void
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
      const message = await sendMessage(roomId, content)

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
      const participant = await joinChatRoom(roomId, userId, role)

      set((state) => {
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

export function useChat(roomId: string | null, userId: string | null) {
  const subscriptionRef = useRef<{ unsubscribe: () => void } | null>(null)
  const store = useChatStore()

  useEffect(() => {
    if (!roomId) return

    store.loadMessages(roomId)

    subscriptionRef.current = subscribeToMessages(roomId, (message) => {
      if (message.sender_id !== userId) {
        store.addMessage(message)
      }
    })

    return () => {
      if (subscriptionRef.current) {
        unsubscribeFromMessages(subscriptionRef.current)
        subscriptionRef.current = null
      }
    }
  }, [roomId, userId])

  useEffect(() => {
    if (roomId && store.messages.length > 0) {
      store.markAsRead(roomId)
    }
  }, [roomId, store.messages.length])

  return store
}
