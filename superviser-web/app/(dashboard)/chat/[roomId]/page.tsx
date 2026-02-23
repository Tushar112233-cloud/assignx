/**
 * @fileoverview Individual chat room page with messaging interface for client, expert, and group communications.
 * Uses real Supabase data via useChatRooms and useChatMessages hooks.
 * @module app/(dashboard)/chat/[roomId]/page
 */

"use client"

import { useParams } from "next/navigation"
import { useState, useEffect, useCallback } from "react"
import { Loader2, AlertCircle, RefreshCw } from "lucide-react"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"
import {
  ChatWindow,
  type ChatRoom,
  type ChatMessage,
} from "@/components/chat"
import { useChatRooms, useChatMessages, useUnreadMessages, useSupervisor } from "@/hooks"
import { createClient } from "@/lib/supabase/client"

export default function ChatRoomPage() {
  const params = useParams()
  const roomId = params.roomId as string

  const { supervisor } = useSupervisor()
  // Fetch all rooms and then find the specific one - roomId from URL could be either a room ID or project ID
  const { rooms: allRooms, isLoading: roomsLoading, error: roomsError, refetch: refetchRooms } = useChatRooms()
  const { markAsRead } = useUnreadMessages()

  // Filter to find the room - first try direct room ID match, then project ID match
  const rooms = allRooms.filter(room =>
    room.id === roomId || room.project_id === roomId
  )

  const [activeRoomId, setActiveRoomId] = useState<string | null>(null)
  const [messagesMap, setMessagesMap] = useState<Record<string, ChatMessage[]>>({})

  // Set active room when rooms are loaded
  useEffect(() => {
    if (rooms.length > 0 && !activeRoomId) {
      setActiveRoomId(rooms[0].id)
    }
  }, [rooms, activeRoomId])

  // Hook for active room messages
  const {
    messages: activeMessages,
    isLoading: messagesLoading,
    sendMessage,
    sendFile,
  } = useChatMessages(activeRoomId || "")

  // Update messages map when active room messages change
  useEffect(() => {
    if (activeRoomId && activeMessages.length > 0) {
      setMessagesMap(prev => ({
        ...prev,
        [activeRoomId]: activeMessages.map(msg => ({
          id: msg.id,
          room_id: msg.chat_room_id,
          sender_id: msg.sender_id,
          sender_name: msg.profiles?.full_name || "Unknown",
          sender_role: ((msg.action_metadata as Record<string, unknown>)?.sender_role as "user" | "supervisor" | "doer" | "support" | "system") || (msg.profiles?.user_type as "user" | "supervisor" | "doer" | "support" | "system") || "user",
          type: msg.message_type || "text",
          content: msg.content || "",
          file_url: msg.file_url || undefined,
          file_name: msg.file_name || undefined,
          file_size: msg.file_size_bytes || undefined,
          is_read: msg.is_deleted === false,
          created_at: msg.created_at || new Date().toISOString(),
        }))
      }))
    }
  }, [activeRoomId, activeMessages])

  // Mark messages as read when viewing a room
  useEffect(() => {
    if (activeRoomId) {
      markAsRead(activeRoomId)
    }
  }, [activeRoomId, markAsRead])

  const handleSendMessage = useCallback(async (
    roomId: string,
    content: string,
    file?: File
  ) => {
    try {
      if (file) {
        await sendFile(file)
      } else {
        await sendMessage(content)
      }
    } catch (error) {
      console.error("Failed to send message:", error)
      toast.error("Failed to send message. Please try again.")
    }
  }, [sendMessage, sendFile])

  const handleSuspendChat = useCallback(async (roomId: string, reason: string) => {
    if (!supervisor?.profile_id) {
      toast.error("Unable to suspend chat: Supervisor not found")
      return
    }

    const supabase = createClient()

    try {
      const { error } = await supabase
        .from("chat_rooms")
        .update({
          is_suspended: true,
          suspension_reason: reason,
          suspended_at: new Date().toISOString(),
          suspended_by: supervisor.profile_id
        })
        .eq("id", roomId)

      if (error) throw error

      // Add system message
      await supabase
        .from("chat_messages")
        .insert({
          chat_room_id: roomId,
          sender_id: supervisor.profile_id,
          content: `Chat suspended by supervisor. Reason: ${reason}`,
          message_type: "system",
          action_metadata: { sender_role: "supervisor" },
        })

      toast.success("Chat suspended successfully")
      await refetchRooms()
    } catch (error) {
      console.error("Failed to suspend chat:", error)
      toast.error("Failed to suspend chat. Please try again.")
    }
  }, [supervisor, refetchRooms])

  const handleResumeChat = useCallback(async (roomId: string) => {
    if (!supervisor?.profile_id) {
      toast.error("Unable to resume chat: Supervisor not found")
      return
    }

    const supabase = createClient()

    try {
      const { error } = await supabase
        .from("chat_rooms")
        .update({
          is_suspended: false,
          suspension_reason: null,
          suspended_at: null,
          suspended_by: null
        })
        .eq("id", roomId)

      if (error) throw error

      // Add system message
      await supabase
        .from("chat_messages")
        .insert({
          chat_room_id: roomId,
          sender_id: supervisor.profile_id,
          content: "Chat resumed by supervisor",
          message_type: "system",
          action_metadata: { sender_role: "supervisor" },
        })

      toast.success("Chat resumed successfully")
      await refetchRooms()
    } catch (error) {
      console.error("Failed to resume chat:", error)
      toast.error("Failed to resume chat. Please try again.")
    }
  }, [supervisor, refetchRooms])

  const handleDownloadFile = useCallback(async (message: ChatMessage) => {
    if (!message.file_url) {
      toast.error("No file URL available")
      return
    }

    try {
      const response = await fetch(message.file_url)
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = message.file_name || "download"
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (error) {
      console.error("Failed to download file:", error)
      toast.error("Failed to download file. Please try again.")
    }
  }, [])

  if (roomsLoading) {
    return (
      <div className="flex items-center justify-center h-[calc(100vh-8rem)]">
        <div className="flex flex-col items-center gap-2">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
          <p className="text-sm text-muted-foreground">Loading chat...</p>
        </div>
      </div>
    )
  }

  if (roomsError) {
    return (
      <div className="flex flex-col items-center justify-center h-[calc(100vh-8rem)] gap-4">
        <AlertCircle className="h-12 w-12 text-destructive" />
        <h3 className="text-lg font-medium">Failed to load chat</h3>
        <p className="text-sm text-muted-foreground">{roomsError.message}</p>
        <Button onClick={() => refetchRooms()} variant="outline">
          <RefreshCw className="h-4 w-4 mr-2" />
          Try Again
        </Button>
      </div>
    )
  }

  if (rooms.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-[calc(100vh-8rem)] gap-4">
        <AlertCircle className="h-12 w-12 text-muted-foreground" />
        <h3 className="text-lg font-medium">No chat rooms found</h3>
        <p className="text-sm text-muted-foreground">
          This project doesn&apos;t have any chat rooms yet.
        </p>
      </div>
    )
  }

  // Transform rooms to ChatWindow format
  const chatRooms: ChatRoom[] = rooms.map(room => ({
    id: room.id,
    project_id: room.project_id || undefined,
    project_number: room.projects?.project_number || "Unknown",
    type: room.room_type as ChatRoom["type"],
    name: room.room_type === "project_user_supervisor"
      ? "Client Chat"
      : room.room_type === "project_supervisor_doer"
        ? "Expert Chat"
        : "Group Chat",
    participants: (room.chat_participants || []).map(p => ({
      id: p.id,
      user_id: p.profile_id,
      name: p.profiles?.full_name || "Unknown",
      role: p.participant_role as "user" | "supervisor" | "doer",
      avatar_url: p.profiles?.avatar_url || undefined,
      is_online: false, // Would need presence tracking
      joined_at: p.joined_at || new Date().toISOString(),
    })),
    is_suspended: room.is_suspended || false,
    suspension_reason: room.suspension_reason || undefined,
    last_message: messagesMap[room.id]?.[messagesMap[room.id].length - 1],
    unread_count: 0,
    created_at: room.created_at || new Date().toISOString(),
    updated_at: room.updated_at || room.created_at || new Date().toISOString(),
  }))

  return (
    <div className="h-[calc(100vh-8rem)]">
      <ChatWindow
        projectId={rooms[0]?.project_id || roomId}
        projectNumber={rooms[0]?.projects?.project_number || "Unknown"}
        rooms={chatRooms}
        currentUserId={supervisor?.profile_id || ""}
        onSendMessage={handleSendMessage}
        onSuspendChat={handleSuspendChat}
        onResumeChat={handleResumeChat}
        onDownloadFile={handleDownloadFile}
      />
    </div>
  )
}
