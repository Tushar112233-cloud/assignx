/**
 * Chat service using API client and Socket.IO
 */

import { apiClient, apiUpload } from '@/lib/api/client'
import { getSocket } from '@/lib/socket/client'
import type {
  ChatRoom,
  ChatMessage,
  ChatParticipant,
  MessageType,
} from '@/types/database'

export async function getOrCreateProjectChatRoom(
  projectId: string
): Promise<ChatRoom> {
  return apiClient<ChatRoom>(`/api/chat/rooms/project/${projectId}`, {
    method: 'POST',
  })
}

export async function getChatMessages(
  roomId: string,
  limit = 50,
  before?: string
): Promise<ChatMessage[]> {
  const params = new URLSearchParams()
  params.set('limit', limit.toString())
  if (before) params.set('before', before)

  const data = await apiClient<{ messages: ChatMessage[] }>(
    `/api/chat/rooms/${roomId}/messages?${params}`
  )
  return data.messages || []
}

export async function sendMessage(
  roomId: string,
  content: string
): Promise<ChatMessage> {
  return apiClient<ChatMessage>(`/api/chat/rooms/${roomId}/messages`, {
    method: 'POST',
    body: JSON.stringify({ content, message_type: 'text' }),
  })
}

export async function sendFileMessage(
  roomId: string,
  file: File
): Promise<ChatMessage> {
  return apiUpload<ChatMessage>(
    `/api/chat/rooms/${roomId}/messages/file`,
    file,
    'chat-files'
  )
}

export async function markMessagesAsRead(
  roomId: string
): Promise<void> {
  await apiClient(`/api/chat/rooms/${roomId}/read`, {
    method: 'PUT',
  })
}

export async function getUnreadCount(
  roomId: string
): Promise<number> {
  try {
    const data = await apiClient<{ count: number }>(
      `/api/chat/rooms/${roomId}/unread`
    )
    return data.count || 0
  } catch {
    return 0
  }
}

export async function getChatParticipants(
  roomId: string
): Promise<ChatParticipant[]> {
  const data = await apiClient<{ participants: ChatParticipant[] }>(
    `/api/chat/rooms/${roomId}/participants`
  )
  return data.participants || []
}

/**
 * Subscribe to real-time messages via Socket.IO
 */
export function subscribeToMessages(
  roomId: string,
  onMessage: (message: ChatMessage) => void
): { unsubscribe: () => void } {
  const socket = getSocket()

  socket.emit('join_room', roomId)
  socket.on(`chat:${roomId}`, onMessage)

  return {
    unsubscribe: () => {
      socket.off(`chat:${roomId}`, onMessage)
      socket.emit('leave_room', roomId)
    },
  }
}

/**
 * Unsubscribe from real-time messages
 */
export async function unsubscribeFromMessages(
  subscription: { unsubscribe: () => void }
): Promise<void> {
  subscription.unsubscribe()
}

export async function joinChatRoom(
  roomId: string,
  userId: string,
  role: 'user' | 'supervisor' | 'doer' | 'admin'
): Promise<ChatParticipant> {
  return apiClient<ChatParticipant>(`/api/chat/rooms/${roomId}/join`, {
    method: 'POST',
    body: JSON.stringify({ role }),
  })
}
