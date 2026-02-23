/**
 * @fileoverview Custom hooks for chat and messaging functionality.
 * @module hooks/use-chat
 */

"use client"

import { useEffect, useState, useCallback, useRef } from "react"
import { createClient, getAuthUser } from "@/lib/supabase/client"
import type {
  ChatRoom,
  ChatRoomWithParticipants,
  ChatMessage,
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
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getAuthUser()
      if (!user) throw new Error("Not authenticated")

      // Get rooms where user is a participant
      const query = supabase
        .from("chat_participants")
        .select(`
          chat_rooms (
            *,
            projects (*),
            chat_participants (
              *,
              profiles (*)
            )
          )
        `)
        .eq("profile_id", user.id)

      const { data: participations, error: queryError } = await query

      if (queryError) throw queryError

      let chatRooms = participations
        ?.map(p => p.chat_rooms)
        .filter(Boolean) as ChatRoomWithParticipants[]

      // Filter by room type
      if (roomType) {
        chatRooms = chatRooms.filter(r => r.room_type === roomType)
      }

      // Filter by project ID
      if (projectId) {
        chatRooms = chatRooms.filter(r => r.project_id === projectId)
      }

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

  // Set up real-time subscription for new rooms
  useEffect(() => {
    const supabase = createClient()

    const channel = supabase
      .channel("chat_rooms_changes")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "chat_rooms" },
        () => {
          fetchRooms()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
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

    const supabase = createClient()

    try {
      if (!append) setIsLoading(true)
      setError(null)

      const { data, error: queryError } = await supabase
        .from("chat_messages")
        .select(`
          *,
          profiles (*)
        `)
        .eq("chat_room_id", roomId)
        .order("created_at", { ascending: false })
        .range(offsetRef.current, offsetRef.current + limit - 1)

      if (queryError) throw queryError

      const newMessages = (data || []).reverse()

      if (append) {
        setMessages(prev => [...newMessages, ...prev])
      } else {
        setMessages(newMessages)
      }

      setHasMore((data?.length || 0) === limit)
      offsetRef.current += data?.length || 0
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

    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) throw new Error("Not authenticated")

    const { error: sendError } = await supabase
      .from("chat_messages")
      .insert({
        chat_room_id: roomId,
        sender_id: user.id,
        content: content.trim(),
        message_type: messageType,
        action_metadata: { sender_role: "supervisor" },
      })

    if (sendError) throw sendError

    // Update last_message_at on room
    await supabase
      .from("chat_rooms")
      .update({ last_message_at: new Date().toISOString() })
      .eq("id", roomId)
  }, [roomId])

  const sendFile = useCallback(async (file: File) => {
    if (!roomId) return

    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) throw new Error("Not authenticated")

    // File validation
    const ALLOWED_FILE_TYPES = [
      // Images
      "image/jpeg",
      "image/png",
      "image/gif",
      "image/webp",
      // Documents
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "application/vnd.ms-excel",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "application/vnd.ms-powerpoint",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      // Text
      "text/plain",
      "text/csv",
      // Archives
      "application/zip",
      "application/x-rar-compressed",
    ]

    const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB

    // Validate file type
    if (!ALLOWED_FILE_TYPES.includes(file.type)) {
      throw new Error(`File type "${file.type}" is not allowed. Allowed types: images, PDF, Office documents, text files, and archives.`)
    }

    // Validate file size
    if (file.size > MAX_FILE_SIZE) {
      throw new Error(`File size exceeds the maximum limit of 10MB.`)
    }

    // Upload file to storage
    const fileExt = file.name.split(".").pop()?.toLowerCase()
    const fileName = `${roomId}/${Date.now()}.${fileExt}`

    const { error: uploadError } = await supabase.storage
      .from("chat-files")
      .upload(fileName, file)

    if (uploadError) throw uploadError

    // Get public URL
    const { data: urlData } = supabase.storage
      .from("chat-files")
      .getPublicUrl(fileName)

    // Determine message type
    const isImage = file.type.startsWith("image/")
    const messageType: MessageType = isImage ? "image" : "file"

    // Send message with file URL
    const { error: sendError } = await supabase
      .from("chat_messages")
      .insert({
        chat_room_id: roomId,
        sender_id: user.id,
        content: file.name,
        message_type: messageType,
        file_url: urlData.publicUrl,
        file_name: file.name,
        file_size: file.size,
        file_type: file.type,
        action_metadata: { sender_role: "supervisor" },
      })

    if (sendError) throw sendError

    // Update last_message_at on room
    await supabase
      .from("chat_rooms")
      .update({ last_message_at: new Date().toISOString() })
      .eq("id", roomId)
  }, [roomId])

  useEffect(() => {
    offsetRef.current = 0
    fetchMessages()
  }, [fetchMessages])

  // Real-time subscription for new messages
  useEffect(() => {
    if (!roomId) return

    const supabase = createClient()

    const channel = supabase
      .channel(`room_${roomId}`)
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "chat_messages",
          filter: `chat_room_id=eq.${roomId}`,
        },
        async (payload) => {
          // Fetch the new message with profile
          const { data } = await supabase
            .from("chat_messages")
            .select(`
              *,
              profiles (*)
            `)
            .eq("id", payload.new.id)
            .single()

          if (data) {
            setMessages(prev => [...prev, data])
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
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
    const supabase = createClient()

    try {
      const user = await getAuthUser()
      if (!user) return

      // Get all rooms the user is part of
      const { data: participants } = await supabase
        .from("chat_participants")
        .select("chat_room_id, last_read_at")
        .eq("profile_id", user.id)

      if (!participants) return

      // Count unread messages for each room
      const counts: Record<string, number> = {}
      let total = 0

      for (const p of participants) {
        const { count } = await supabase
          .from("chat_messages")
          .select("*", { count: "exact", head: true })
          .eq("chat_room_id", p.chat_room_id)
          .neq("sender_id", user.id)
          .gt("created_at", p.last_read_at || "1970-01-01")

        counts[p.chat_room_id] = count || 0
        total += count || 0
      }

      setUnreadByRoom(counts)
      setUnreadCount(total)
    } catch (err) {
      console.error("Failed to fetch unread counts:", err)
    }
  }, [])

  const markAsRead = useCallback(async (roomId: string) => {
    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) return

    await supabase
      .from("chat_participants")
      .update({ last_read_at: new Date().toISOString() })
      .eq("chat_room_id", roomId)
      .eq("profile_id", user.id)

    await fetchUnreadCounts()
  }, [fetchUnreadCounts])

  const markAllAsRead = useCallback(async () => {
    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) return

    await supabase
      .from("chat_participants")
      .update({ last_read_at: new Date().toISOString() })
      .eq("profile_id", user.id)

    await fetchUnreadCounts()
  }, [fetchUnreadCounts])

  useEffect(() => {
    // Initial fetch
    void (async () => {
      await fetchUnreadCounts()
    })()

    // Real-time subscription for new messages — replaces 60s polling
    const supabase = createClient()
    const channel = supabase
      .channel("unread_messages_realtime")
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "chat_messages",
        },
        () => {
          // Re-fetch unread counts when any new message arrives
          fetchUnreadCounts()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [fetchUnreadCounts])

  return {
    unreadCount,
    unreadByRoom,
    markAsRead,
    markAllAsRead,
  }
}
