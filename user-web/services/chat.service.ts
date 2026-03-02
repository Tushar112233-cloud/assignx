import { apiClient } from '@/lib/api/client'
import { getSocket } from '@/lib/socket/client'
import type { Socket } from 'socket.io-client'

/**
 * Chat room type
 */
interface ChatRoom {
  id: string
  project_id: string | null
  room_type: string | null
  created_at: string | null
  updated_at: string | null
  [key: string]: any
}

/**
 * Chat message type
 */
interface ChatMessage {
  id: string
  chat_room_id: string
  sender_id: string
  content: string | null
  message_type: string | null
  file_url: string | null
  action_metadata: any
  read_by: string[] | null
  created_at: string | null
  [key: string]: any
}

/**
 * Chat message insert type
 */
type ChatMessageInsert = Partial<ChatMessage>

/**
 * Chat participant type
 */
interface ChatParticipant {
  id: string
  chat_room_id: string
  profile_id: string
  participant_role: string | null
  is_active: boolean | null
  [key: string]: any
}

/**
 * Chat room with last message and unread count
 */
interface ChatRoomWithDetails extends ChatRoom {
  last_message?: ChatMessage | null
  unread_count?: number
  participants?: ChatParticipant[]
}

/**
 * Message with sender info
 */
interface MessageWithSender extends ChatMessage {
  sender?: {
    id: string
    full_name: string
    avatar_url: string | null
    email?: string
  }
  is_read?: boolean
}

/**
 * Callback for new messages
 */
type MessageCallback = (message: ChatMessage) => void

/**
 * Connection state for realtime
 */
type ConnectionState = 'connecting' | 'connected' | 'disconnected' | 'reconnecting'

/**
 * Connection state callback
 */
type ConnectionStateCallback = (state: ConnectionState) => void

/**
 * Chat service for real-time messaging.
 * Uses API client for data operations and Socket.IO for realtime.
 */
export const chatService = {
  /**
   * Active Socket.IO event listeners (roomId -> cleanup fn)
   */
  _listeners: new Map<string, () => void>(),

  /**
   * Connection state listeners
   */
  _connectionStateListeners: new Set<ConnectionStateCallback>(),

  /**
   * Current connection state
   */
  _connectionState: 'disconnected' as ConnectionState,

  /**
   * Subscribe to connection state changes.
   */
  onConnectionStateChange(callback: ConnectionStateCallback): () => void {
    this._connectionStateListeners.add(callback)
    callback(this._connectionState)
    return () => {
      this._connectionStateListeners.delete(callback)
    }
  },

  /**
   * Updates connection state and notifies listeners
   */
  _setConnectionState(state: ConnectionState): void {
    this._connectionState = state
    this._connectionStateListeners.forEach((cb) => cb(state))
  },

  /**
   * Gets or creates a chat room for a project.
   */
  async getOrCreateProjectChatRoom(
    projectId: string,
    userId: string
  ): Promise<ChatRoom> {
    const result = await apiClient<{ room: ChatRoom }>(`/api/chat/rooms/project/${projectId}`, {
      method: 'POST',
      body: JSON.stringify({ userId }),
    })
    return result.room || result as any
  },

  /**
   * Gets all chat rooms for a user.
   */
  async getChatRooms(userId: string): Promise<ChatRoomWithDetails[]> {
    const result = await apiClient<{ rooms: ChatRoomWithDetails[] }>(`/api/chat/rooms?userId=${userId}`)
    return result.rooms || result as any
  },

  /**
   * Gets messages for a chat room.
   */
  async getMessages(
    roomId: string,
    limit: number = 50,
    before?: string
  ): Promise<MessageWithSender[]> {
    const params = new URLSearchParams({ limit: String(limit) })
    if (before) params.set('before', before)

    const result = await apiClient<{ messages: MessageWithSender[] }>(
      `/api/chat/rooms/${roomId}/messages?${params.toString()}`
    )
    return result.messages || result as any
  },

  /**
   * Sends a message to a chat room.
   */
  async sendMessage(
    roomId: string,
    senderId: string,
    content: string,
    attachmentUrl?: string
  ): Promise<ChatMessage> {
    const result = await apiClient<{ message: ChatMessage }>(`/api/chat/rooms/${roomId}/messages`, {
      method: 'POST',
      body: JSON.stringify({
        senderId,
        content,
        fileUrl: attachmentUrl,
        messageType: attachmentUrl ? 'file' : 'text',
      }),
    })
    return result.message || result as any
  },

  /**
   * Uploads a file attachment for chat via Cloudinary.
   */
  async uploadAttachment(_roomId: string, file: File): Promise<string> {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('folder', 'chat-attachments')

    const result = await apiClient<{ url: string }>('/api/upload', {
      method: 'POST',
      body: formData,
      isFormData: true,
    })
    return result.url
  },

  /**
   * Marks messages as read.
   */
  async markAsRead(roomId: string, userId: string): Promise<void> {
    await apiClient(`/api/chat/rooms/${roomId}/read`, {
      method: 'POST',
      body: JSON.stringify({ userId }),
    })
  },

  /**
   * Alias for markAsRead for backwards compatibility.
   */
  async markMessagesAsRead(roomId: string, userId: string): Promise<void> {
    return this.markAsRead(roomId, userId)
  },

  /**
   * Subscribes to new messages in a chat room via Socket.IO.
   * @returns Cleanup function
   */
  subscribeToRoom(roomId: string, callback: MessageCallback): () => void {
    // Clean up existing listener for this room
    const existing = this._listeners.get(roomId)
    if (existing) existing()

    const socket: Socket = getSocket()

    // Join the room
    socket.emit('join-room', roomId)
    this._setConnectionState('connecting')

    // Listen for new messages
    const eventName = `chat:${roomId}`
    const handler = (message: ChatMessage) => {
      callback(message)
    }

    socket.on(eventName, handler)

    // Track connection state
    const onConnect = () => this._setConnectionState('connected')
    const onDisconnect = () => this._setConnectionState('disconnected')
    const onReconnect = () => this._setConnectionState('reconnecting')

    socket.on('connect', onConnect)
    socket.on('disconnect', onDisconnect)
    socket.on('reconnect_attempt', onReconnect)

    if (socket.connected) {
      this._setConnectionState('connected')
    }

    const cleanup = () => {
      socket.off(eventName, handler)
      socket.off('connect', onConnect)
      socket.off('disconnect', onDisconnect)
      socket.off('reconnect_attempt', onReconnect)
      socket.emit('leave-room', roomId)
      this._listeners.delete(roomId)
    }

    this._listeners.set(roomId, cleanup)
    return cleanup
  },

  /**
   * Subscribes to unread count updates for rooms the user is in.
   * @returns Cleanup function
   */
  subscribeToUnreadCounts(
    userId: string,
    callback: (roomId: string, count: number) => void
  ): () => void {
    const socket: Socket = getSocket()
    const eventName = `unread:${userId}`

    const handler = (data: { roomId: string; count: number }) => {
      callback(data.roomId, data.count)
    }

    socket.on(eventName, handler)

    return () => {
      socket.off(eventName, handler)
    }
  },

  /**
   * Gets total unread message count for a user.
   */
  async getTotalUnreadCount(userId: string): Promise<number> {
    try {
      const result = await apiClient<{ count: number }>(`/api/chat/unread-count?userId=${userId}`)
      return result.count || 0
    } catch {
      return 0
    }
  },

  /**
   * Cleans up all subscriptions and listeners.
   */
  cleanup(): void {
    this._listeners.forEach((cleanup) => cleanup())
    this._listeners.clear()
    this._connectionStateListeners.clear()
    this._setConnectionState('disconnected')
  },
}

// Re-export types
export type {
  ChatRoom,
  ChatMessage,
  ChatMessageInsert,
  ChatParticipant,
  ChatRoomWithDetails,
  MessageWithSender,
  MessageCallback,
  ConnectionState,
  ConnectionStateCallback,
}
