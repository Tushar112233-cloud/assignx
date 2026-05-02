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
  MessageType,
  Json
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

      let chatRooms = (data.rooms || []).map((room: ChatRoomWithParticipants) => {
        const r = room as unknown as Record<string, unknown>
        return {
          ...r,
          id: r._id || r.id,
          room_type: r.roomType || r.room_type,
          type: r.roomType || r.room_type || r.type,
          last_message_at: r.lastMessageAt || r.last_message_at,
          created_at: r.createdAt || r.created_at,
          is_suspended: r.isSuspended ?? r.is_suspended ?? false,
          // Map flat project fields into nested projects object for components
          projects: (r.project_title || r.project_number)
            ? { title: r.project_title as string, project_number: r.project_number as string }
            : r.projects || null,
          // Components expect chat_participants with full_name, map from participants
          chat_participants: ((r.participants || r.chat_participants || []) as any[]).map((p: any) => ({
            id: p.id || p._id,
            user_id: p.id || p._id,
            full_name: p.full_name || p.fullName || null,
            avatar_url: p.avatar_url || p.avatarUrl || null,
            email: p.email || null,
            role: p.role || p.participant_role || null,
            joined_at: p.joinedAt || p.joined_at || null,
          })),
        }
      }) as ChatRoomWithParticipants[]

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
    const socket = getSocket()
    if (!socket) return
    const handler = () => fetchRooms()
    socket.on("chat:rooms", handler)
    return () => { socket.off("chat:rooms", handler) }
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

/**
 * Normalize a raw API/socket message (Mongoose camelCase) into the
 * snake_case shape the frontend components expect.
 */
function normalizeMessage(raw: Record<string, unknown>): ChatMessageWithSender {
  // senderId may be a populated object { _id, fullName, avatarUrl } or a plain string
  const senderObj =
    raw.senderId && typeof raw.senderId === "object"
      ? (raw.senderId as Record<string, unknown>)
      : null

  const senderId = senderObj
    ? String(senderObj._id || senderObj.id || "")
    : String(raw.senderId || raw.sender_id || "")

  const sender = senderObj
    ? {
        id: senderId,
        full_name: (senderObj.fullName as string) || null,
        avatar_url: (senderObj.avatarUrl as string) || null,
      }
    : raw.sender && typeof raw.sender === "object"
      ? raw.sender
      : raw.sender_name
        ? { id: senderId, full_name: raw.sender_name as string, avatar_url: null }
        : null

  const fileObj = raw.file as Record<string, unknown> | null | undefined

  return {
    id: String(raw._id || raw.id || ""),
    room_id: String(raw.chatRoomId || raw.chat_room_id || raw.room_id || ""),
    sender_id: senderId,
    sender_role: ((raw.senderRole || raw.sender_role || null) as 'user' | 'supervisor' | 'doer' | 'system' | null),
    type: (raw.messageType || raw.message_type || raw.type || "text") as MessageType,
    message_type: String(raw.messageType || raw.message_type || raw.type || "text"),
    content: (raw.content as string) || null,
    file_url: (fileObj?.url as string) || (raw.file_url as string) || null,
    file_name: (fileObj?.name as string) || (raw.file_name as string) || null,
    is_read: Boolean(raw.isRead ?? raw.is_read ?? false),
    is_flagged: Boolean(raw.isFlagged ?? raw.is_flagged ?? false),
    is_deleted: Boolean(raw.isDeleted ?? raw.is_deleted ?? false),
    flag_reason: (raw.flagReason as string) || (raw.flag_reason as string) || null,
    metadata: (raw.metadata as Json) || null,
    approval_status: ((raw.approvalStatus || raw.approval_status || "approved") as 'pending' | 'approved' | 'rejected'),
    created_at: String(raw.createdAt || raw.created_at || ""),
    updated_at: (raw.updatedAt || raw.updated_at || null) as string | null,
    sender: sender as ChatMessageWithSender["sender"],
  } as ChatMessageWithSender
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

      const rawMessages = (data.messages || []) as unknown as Record<string, unknown>[]
      const newMessages = rawMessages.map(normalizeMessage).reverse()

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

    const data = await apiFetch<{ message: ChatMessageWithSender }>(`/api/chat/rooms/${roomId}/messages`, {
      method: "POST",
      body: JSON.stringify({
        content: content.trim(),
        messageType,
        senderRole: "supervisor",
      }),
    })

    // Optimistically add sent message so it shows immediately without waiting for socket
    if (data?.message) {
      const normalized = normalizeMessage(data.message as unknown as Record<string, unknown>)
      setMessages(prev => {
        if (prev.some(m => m.id === normalized.id)) return prev
        return [...prev, normalized]
      })
    }
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

    const socket = getSocket()
    if (!socket) return

    // Join the chat room (server listens for "chat:join")
    socket.emit("chat:join", roomId)

    const handleNewMessage = (message: ChatMessageWithSender & { chatRoomId?: string }) => {
      // Filter to only this room's messages
      const raw = message as unknown as Record<string, unknown>
      const msgRoomId = raw.chatRoomId || raw.chat_room_id || raw.room_id
      if (msgRoomId && String(msgRoomId) !== roomId) return

      const normalized = normalizeMessage(raw)
      setMessages(prev => {
        if (prev.some(m => m.id === normalized.id)) return prev
        return [...prev, normalized]
      })
    }

    // Server emits "chat:message" (not "chat:{roomId}")
    socket.on("chat:message", handleNewMessage)

    // Handle approval/rejection status updates
    const handleApproved = (data: { messageId: string }) => {
      setMessages(prev => prev.map(m =>
        m.id === data.messageId ? { ...m, approval_status: 'approved' as const } : m
      ))
    }
    const handleRejected = (data: { messageId: string }) => {
      setMessages(prev => prev.map(m =>
        m.id === data.messageId ? { ...m, approval_status: 'rejected' as const } : m
      ))
    }
    socket.on("chat:messageApproved", handleApproved)
    socket.on("chat:messageRejected", handleRejected)

    return () => {
      socket.off("chat:message", handleNewMessage)
      socket.off("chat:messageApproved", handleApproved)
      socket.off("chat:messageRejected", handleRejected)
      socket.emit("chat:leave", roomId)
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
    const socket = getSocket()
    if (!socket) return
    const handler = () => fetchUnreadCounts()
    socket.on("chat:unread", handler)
    return () => { socket.off("chat:unread", handler) }
  }, [fetchUnreadCounts])

  return {
    unreadCount,
    unreadByRoom,
    markAsRead,
    markAllAsRead,
  }
}
