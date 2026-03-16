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

/**
 * Normalize a raw MongoDB message (Mongoose camelCase) to the snake_case
 * shape the ChatPanel component expects. Without this, fields like
 * `message_type`, `sender_role`, `created_at` are undefined and nothing renders.
 */
function normalizeMessage(raw: any): ChatMessage {
  const senderObj =
    raw.senderId && typeof raw.senderId === 'object' ? raw.senderId : null
  const senderId = senderObj
    ? String(senderObj._id || senderObj.id || '')
    : String(raw.senderId || raw.sender_id || '')

  const fileObj =
    raw.file && typeof raw.file === 'object' ? raw.file : null

  return {
    id: String(raw._id || raw.id || ''),
    chat_room_id: String(raw.chatRoomId || raw.chat_room_id || ''),
    sender_id: senderId,
    message_type: (raw.messageType || raw.message_type || 'text') as MessageType,
    content: raw.content || null,
    file_url: fileObj?.url || raw.file_url || null,
    file_name: fileObj?.name || raw.file_name || null,
    file_type: fileObj?.type || raw.file_type || null,
    file_size_bytes: fileObj?.sizeBytes || raw.file_size_bytes || null,
    action_type: raw.actionType || raw.action_type || null,
    action_metadata: raw.actionMetadata || raw.action_metadata || null,
    reply_to_id: raw.replyToId || raw.reply_to_id || null,
    is_edited: Boolean(raw.isEdited ?? raw.is_edited ?? false),
    edited_at: raw.editedAt || raw.edited_at || null,
    is_deleted: Boolean(raw.isDeleted ?? raw.is_deleted ?? false),
    deleted_at: raw.deletedAt || raw.deleted_at || null,
    is_flagged: Boolean(raw.isFlagged ?? raw.is_flagged ?? false),
    flagged_reason: raw.flaggedReason || raw.flagged_reason || null,
    contains_contact_info: Boolean(
      raw.containsContactInfo ?? raw.contains_contact_info ?? false
    ),
    read_by: raw.readBy || raw.read_by || [],
    delivered_at: raw.deliveredAt || raw.delivered_at || null,
    created_at: raw.createdAt
      ? new Date(raw.createdAt).toISOString()
      : raw.created_at || new Date().toISOString(),
    // Display fields populated from sender join
    sender_name: senderObj
      ? senderObj.fullName || null
      : raw.sender_name || null,
    sender_avatar: senderObj
      ? senderObj.avatarUrl || null
      : raw.sender_avatar || null,
    sender_role: (raw.senderRole || raw.sender_role || null) as ChatMessage['sender_role'],
  }
}

export async function getOrCreateProjectChatRoom(
  projectId: string
): Promise<ChatRoom> {
  const data = await apiClient<{ room: ChatRoom }>(`/api/chat/rooms/project/${projectId}`, {
    method: 'POST',
  })
  return data.room
}

export async function getChatMessages(
  roomId: string,
  limit = 50,
  before?: string
): Promise<ChatMessage[]> {
  const params = new URLSearchParams()
  params.set('limit', limit.toString())
  if (before) params.set('before', before)

  const data = await apiClient<{ messages: any[] }>(
    `/api/chat/rooms/${roomId}/messages?${params}`
  )
  const raw = data.messages || []
  return raw.map(normalizeMessage)
}

export async function sendMessage(
  roomId: string,
  content: string
): Promise<ChatMessage> {
  const raw = await apiClient<any>(`/api/chat/rooms/${roomId}/messages`, {
    method: 'POST',
    body: JSON.stringify({ content, messageType: 'text', senderRole: 'doer' }),
  })
  // API returns { message: {...} } or the message directly
  return normalizeMessage(raw.message || raw)
}

export async function sendFileMessage(
  roomId: string,
  file: File
): Promise<ChatMessage> {
  const raw = await apiUpload<any>(
    `/api/chat/rooms/${roomId}/files`,
    file,
    'chat-files'
  )
  return normalizeMessage(raw.message || raw)
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
    // Use the global unread endpoint and extract the count for this specific room
    const data = await apiClient<{ total: number; byRoom: Record<string, number> }>(
      `/api/chat/unread`
    )
    return data.byRoom?.[roomId] || 0
  } catch {
    return 0
  }
}

export async function getChatParticipants(
  roomId: string
): Promise<ChatParticipant[]> {
  // Participants are embedded in the room document
  const data = await apiClient<{ room: { participants: ChatParticipant[] } }>(
    `/api/chat/rooms/${roomId}`
  )
  return data.room?.participants || []
}

/**
 * Subscribe to real-time messages via Socket.IO.
 * Server expects 'chat:join' to enter the room and emits 'chat:message' for new messages.
 */
export function subscribeToMessages(
  roomId: string,
  onMessage: (message: ChatMessage) => void
): { unsubscribe: () => void } {
  const socket = getSocket()

  // Join the chat room (server listens for "chat:join")
  socket.emit('chat:join', roomId)

  const handler = (raw: any) => {
    // Filter to only this room's messages
    const msgRoomId = raw.chatRoomId || raw.chat_room_id || raw.room_id
    if (msgRoomId && String(msgRoomId) !== roomId) return
    onMessage(normalizeMessage(raw))
  }

  // Server emits "chat:message" (not "chat:{roomId}")
  socket.on('chat:message', handler)

  return {
    unsubscribe: () => {
      socket.off('chat:message', handler)
      socket.emit('chat:leave', roomId)
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
