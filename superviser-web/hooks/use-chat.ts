/**
 * @fileoverview Custom hooks for chat and messaging functionality.
 * Uses Express API + Socket.IO instead of Supabase.
 * @module hooks/use-chat
 */

"use client"

import { useEffect, useState, useCallback, useRef } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { getSocket } from "@/lib/socket/client"
import type {
  ChatRoomWithParticipants,
  ChatMessageWithSender,
  ChatRoomType,
  MessageType
} from "@/types/database"

interface UseChatRoomsOptions {
  roomType?: ChatRoomType
  projectId?: string
}

interface UseChatRoomsReturn {
  rooms: ChatRoomWithParticipants[]
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
}

export function useChatRooms(options: UseChatRoomsOptions = {}): UseChatRoomsReturn {
  const { roomType, projectId } = options
  const [rooms, setRooms] = useState<ChatRoomWithParticipants[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchRooms = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const params = new URLSearchParams()
      if (roomType) params.set("roomType", roomType)
      if (projectId) params.set("projectId", projectId)

      const data = await apiFetch<{ rooms: ChatRoomWithParticipants[] }>(
        `/api/chat/rooms?${params.toString()}`
      )

      let chatRooms = (data.rooms || []).map((room: Record<string, unknown>) => ({
        ...room,
        id: room._id || room.id,
        room_type: room.roomType || room.room_type,
        last_message_at: room.lastMessageAt || room.last_message_at,
        created_at: room.createdAt || room.created_at,
      })) as ChatRoomWithParticipants[]

      // Sort by last message
      chatRooms.sort((a, b) => {
        const aTime = new Date(a.last_message_at || a.created_at!).getTime()
        const bTime = new Date(b.last_message_at || b.created_at!).getTime()
        return bTime - aTime
      })

      setRooms(chatRooms)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch chat rooms"))
    } finally {
      setIsLoading(false)
    }
  }, [roomType, projectId])

  useEffect(() => {
    fetchRooms()
  }, [fetchRooms])

  // Real-time: new rooms via Socket.IO
  useEffect(() => {
    try {
      const socket = getSocket()
      const handler = () => fetchRooms()
      socket.on("chat:rooms", handler)
      return () => { socket.off("chat:rooms", handler) }
    } catch {
      return undefined
    }
  }, [fetchRooms])

  return {
    rooms,
    isLoading,
    error,
    refetch: fetchRooms,
  }
}

interface UseChatMessagesReturn {
  messages: ChatMessageWithSender[]
  isLoading: boolean
  error: Error | null
  sendMessage: (content: string, messageType?: MessageType) => Promise<void>
  sendFile: (file: File) => Promise<void>
  loadMore: () => Promise<void>
  hasMore: boolean
}

export function useChatMessages(roomId: string): UseChatMessagesReturn {
  const [messages, setMessages] = useState<ChatMessageWithSender[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [hasMore, setHasMore] = useState(true)
  const offsetRef = useRef(0)
  const limit = 50

  const fetchMessages = useCallback(async (append = false) => {
    if (!roomId) return

    try {
      if (!append) setIsLoading(true)
      setError(null)

      const params = new URLSearchParams()
      params.set("limit", String(limit))
      params.set("offset", String(offsetRef.current))

      const data = await apiFetch<{ messages: ChatMessageWithSender[] }>(
        `/api/chat/rooms/${roomId}/messages?${params.toString()}`
      )

      const newMessages = (data.messages || []).reverse()

      if (append) {
        setMessages(prev => [...newMessages, ...prev])
      } else {
        setMessages(newMessages)
      }

      setHasMore((data.messages?.length || 0) === limit)
      offsetRef.current += data.messages?.length || 0
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch messages"))
    } finally {
      setIsLoading(false)
    }
  }, [roomId])

  const loadMore = useCallback(async () => {
    await fetchMessages(true)
  }, [fetchMessages])

  const sendMessage = useCallback(async (content: string, messageType: MessageType = "text") => {
    if (!roomId || !content.trim()) return

    await apiFetch(`/api/chat/rooms/${roomId}/messages`, {
      method: "POST",
      body: JSON.stringify({
        content: content.trim(),
        messageType,
        senderRole: "supervisor",
      }),
    })
  }, [roomId])

  const sendFile = useCallback(async (file: File) => {
    if (!roomId) return

    // File validation
    const ALLOWED_FILE_TYPES = [
      "image/jpeg", "image/png", "image/gif", "image/webp",
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "application/vnd.ms-excel",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "application/vnd.ms-powerpoint",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      "text/plain", "text/csv",
      "application/zip", "application/x-rar-compressed",
    ]

    const MAX_FILE_SIZE = 10 * 1024 * 1024

    if (!ALLOWED_FILE_TYPES.includes(file.type)) {
      throw new Error(`File type "${file.type}" is not allowed.`)
    }

    if (file.size > MAX_FILE_SIZE) {
      throw new Error("File size exceeds the maximum limit of 10MB.")
    }

    const formData = new FormData()
    formData.append("file", file)
    formData.append("senderRole", "supervisor")

    await apiFetch(`/api/chat/rooms/${roomId}/files`, {
      method: "POST",
      body: formData,
    })
  }, [roomId])

  useEffect(() => {
    offsetRef.current = 0
    fetchMessages()
  }, [fetchMessages])

  // Real-time: new messages via Socket.IO
  useEffect(() => {
    if (!roomId) return

    try {
      const socket = getSocket()

      // Join the room
      socket.emit("join-room", roomId)

      const handleNewMessage = (message: ChatMessageWithSender) => {
        setMessages(prev => {
          if (prev.some(m => m.id === message.id)) return prev
          return [...prev, message]
        })
      }

      socket.on(`chat:${roomId}`, handleNewMessage)

      return () => {
        socket.off(`chat:${roomId}`, handleNewMessage)
        socket.emit("leave-room", roomId)
      }
    } catch {
      return undefined
    }
  }, [roomId])

  return {
    messages,
    isLoading,
    error,
    sendMessage,
    sendFile,
    loadMore,
    hasMore,
  }
}

interface UseUnreadMessagesReturn {
  unreadCount: number
  unreadByRoom: Record<string, number>
  markAsRead: (roomId: string) => Promise<void>
  markAllAsRead: () => Promise<void>
}

export function useUnreadMessages(): UseUnreadMessagesReturn {
  const [unreadCount, setUnreadCount] = useState(0)
  const [unreadByRoom, setUnreadByRoom] = useState<Record<string, number>>({})

  const fetchUnreadCounts = useCallback(async () => {
    try {
      const data = await apiFetch<{ total: number; byRoom: Record<string, number> }>(
        "/api/chat/unread"
      )
      setUnreadCount(data.total || 0)
      setUnreadByRoom(data.byRoom || {})
    } catch (err) {
      console.error("Failed to fetch unread counts:", err)
    }
  }, [])

  const markAsRead = useCallback(async (roomId: string) => {
    await apiFetch(`/api/chat/rooms/${roomId}/read`, {
      method: "PUT",
    })
    await fetchUnreadCounts()
  }, [fetchUnreadCounts])

  const markAllAsRead = useCallback(async () => {
    await apiFetch("/api/chat/read-all", {
      method: "PUT",
    })
    await fetchUnreadCounts()
  }, [fetchUnreadCounts])

  useEffect(() => {
    fetchUnreadCounts()

    // Real-time: unread count updates via Socket.IO
    try {
      const socket = getSocket()
      const handler = () => fetchUnreadCounts()
      socket.on("chat:unread", handler)
      return () => { socket.off("chat:unread", handler) }
    } catch {
      return undefined
    }
  }, [fetchUnreadCounts])

  return {
    unreadCount,
    unreadByRoom,
    markAsRead,
    markAllAsRead,
  }
}
