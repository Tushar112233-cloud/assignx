import { createClient } from '@/lib/supabase/client'
import type { Database } from '@/types/database'
import type { RealtimeChannel } from '@supabase/supabase-js'
import { validateBrowserFile, sanitizeFileName } from '@/lib/validations/file-upload'

/**
 * Type aliases for chat-related tables
 */
type ChatRoom = Database['public']['Tables']['chat_rooms']['Row']
type ChatMessage = Database['public']['Tables']['chat_messages']['Row']
type ChatMessageInsert = Database['public']['Tables']['chat_messages']['Insert']
type ChatParticipant = Database['public']['Tables']['chat_participants']['Row']

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

const supabase = createClient()

/**
 * Reconnection configuration
 */
const RECONNECT_CONFIG = {
  maxRetries: 5,
  baseDelay: 1000,
  maxDelay: 30000,
}

/**
 * Chat service for real-time messaging.
 * Handles chat rooms, messages, and real-time subscriptions.
 */
export const chatService = {
  /**
   * Active subscriptions map
   */
  subscriptions: new Map<string, RealtimeChannel>(),

  /**
   * Reconnection retry counts per channel
   */
  _retryCounts: new Map<string, number>(),

  /**
   * Reconnection timeout handles
   */
  _reconnectTimers: new Map<string, ReturnType<typeof setTimeout>>(),

  /**
   * Connection state listeners
   */
  _connectionStateListeners: new Set<ConnectionStateCallback>(),

  /**
   * Current connection state
   */
  _connectionState: 'disconnected' as ConnectionState,

  /**
   * Cached user room IDs for efficient subscription filtering
   */
  _userRoomIds: new Map<string, string[]>(),

  /**
   * Subscribe to connection state changes.
   * @param callback - Called when connection state changes
   * @returns Cleanup function
   */
  onConnectionStateChange(callback: ConnectionStateCallback): () => void {
    this._connectionStateListeners.add(callback)
    // Immediately notify of current state
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
   * Calculate exponential backoff delay with jitter
   */
  _getReconnectDelay(channelKey: string): number {
    const retries = this._retryCounts.get(channelKey) || 0
    const delay = Math.min(
      RECONNECT_CONFIG.baseDelay * Math.pow(2, retries),
      RECONNECT_CONFIG.maxDelay
    )
    // Add jitter (0-25% of delay)
    return delay + Math.random() * delay * 0.25
  },

  /**
   * Gets or creates a chat room for a project.
   * Uses unique constraint on project_id to handle race conditions.
   * @param projectId - The project UUID
   * @param userId - The user's profile ID
   * @returns The chat room
   */
  async getOrCreateProjectChatRoom(
    projectId: string,
    userId: string
  ): Promise<ChatRoom> {
    // First, try to find existing chat room (filter by room_type to avoid returning doer-supervisor room)
    const { data: existingRoom, error: findError } = await supabase
      .from('chat_rooms')
      .select('*')
      .eq('project_id', projectId)
      .eq('room_type', 'project_user_supervisor')
      .single()

    if (existingRoom) {
      // Ensure the current user is a participant (upsert to avoid duplicates)
      await supabase.from('chat_participants').upsert({
        chat_room_id: existingRoom.id,
        profile_id: userId,
        participant_role: 'user',
        is_active: true,
        notifications_enabled: true,
        unread_count: 0,
        has_left: false,
      }, { onConflict: 'chat_room_id,profile_id', ignoreDuplicates: true })

      return existingRoom
    }
    if (findError && findError.code !== 'PGRST116') throw findError

    // Create new chat room
    const { data: newRoom, error: createError } = await supabase
      .from('chat_rooms')
      .insert({
        project_id: projectId,
        room_type: 'project_user_supervisor',
      })
      .select()
      .single()

    // Handle unique constraint violation (race condition)
    // If another request created the room first, fetch it
    if (createError) {
      if (createError.code === '23505') {
        // Unique violation - room was created by another request
        const { data: roomAfterRace, error: refetchError } = await supabase
          .from('chat_rooms')
          .select('*')
          .eq('project_id', projectId)
          .eq('room_type', 'project_user_supervisor')
          .single()

        if (refetchError || !roomAfterRace) throw refetchError || new Error('Failed to fetch chat room')

        // Upsert user as participant
        await supabase.from('chat_participants').upsert({
          chat_room_id: roomAfterRace.id,
          profile_id: userId,
          participant_role: 'user',
          is_active: true,
          notifications_enabled: true,
          unread_count: 0,
          has_left: false,
        }, { onConflict: 'chat_room_id,profile_id', ignoreDuplicates: true })

        return roomAfterRace
      }
      throw createError
    }

    // Add user as participant
    await supabase.from('chat_participants').insert({
      chat_room_id: newRoom.id,
      profile_id: userId,
      participant_role: 'user',
      is_active: true,
      notifications_enabled: true,
      unread_count: 0,
      has_left: false,
    })

    return newRoom
  },

  /**
   * Gets all chat rooms for a user.
   * @param userId - The user's profile ID
   * @returns Array of chat rooms with details
   */
  async getChatRooms(userId: string): Promise<ChatRoomWithDetails[]> {
    // Get rooms where user is a participant
    const { data: participations, error: partError } = await supabase
      .from('chat_participants')
      .select('chat_room_id')
      .eq('profile_id', userId)

    if (partError) throw partError

    const roomIds = participations.map((p: any) => p.chat_room_id)
    if (roomIds.length === 0) return []

    // Cache room IDs for this user
    this._userRoomIds.set(userId, roomIds)

    // Get room details
    const { data: rooms, error: roomError } = await supabase
      .from('chat_rooms')
      .select('*')
      .in('id', roomIds)
      .order('updated_at', { ascending: false })

    if (roomError) throw roomError

    // Get last message and unread count for each room
    const roomsWithDetails: ChatRoomWithDetails[] = await Promise.all(
      rooms.map(async (room: any) => {
        // Get last message
        const { data: lastMessage } = await supabase
          .from('chat_messages')
          .select('*')
          .eq('chat_room_id', room.id)
          .order('created_at', { ascending: false })
          .limit(1)
          .single()

        // Get unread count (messages not yet in read_by for this user)
        const { count } = await supabase
          .from('chat_messages')
          .select('*', { count: 'exact', head: true })
          .eq('chat_room_id', room.id)
          .neq('sender_id', userId)
          .not('read_by', 'cs', `["${userId}"]`)

        return {
          ...room,
          last_message: lastMessage,
          unread_count: count || 0,
        }
      })
    )

    return roomsWithDetails
  },

  /**
   * Gets messages for a chat room.
   * @param roomId - The chat room UUID
   * @param limit - Number of messages to fetch
   * @param before - Fetch messages before this timestamp
   * @returns Array of messages with sender info
   */
  async getMessages(
    roomId: string,
    limit: number = 50,
    before?: string
  ): Promise<MessageWithSender[]> {
    let query = supabase
      .from('chat_messages')
      .select(`
        *,
        sender:profiles!chat_messages_sender_id_fkey(id, full_name, avatar_url)
      `)
      .eq('chat_room_id', roomId)
      .order('created_at', { ascending: false })
      .limit(limit)

    if (before) {
      query = query.lt('created_at', before)
    }

    const { data, error } = await query

    if (error) throw error
    return (data as MessageWithSender[]).reverse()
  },

  /**
   * Sends a message to a chat room.
   * @param roomId - The chat room UUID
   * @param senderId - The sender's profile ID
   * @param content - The message content
   * @param attachmentUrl - Optional attachment URL
   * @returns The sent message
   */
  async sendMessage(
    roomId: string,
    senderId: string,
    content: string,
    attachmentUrl?: string
  ): Promise<ChatMessage> {
    const messageData: ChatMessageInsert = {
      chat_room_id: roomId,
      sender_id: senderId,
      content,
      file_url: attachmentUrl,
      message_type: attachmentUrl ? 'file' : 'text',
      action_metadata: { sender_role: 'user' },
    }

    const { data, error } = await supabase
      .from('chat_messages')
      .insert(messageData)
      .select()
      .single()

    if (error) throw error

    // Update room's updated_at
    await supabase
      .from('chat_rooms')
      .update({ updated_at: new Date().toISOString() })
      .eq('id', roomId)

    return data
  },

  /**
   * Uploads a file attachment for chat with validation.
   * @param roomId - The chat room UUID
   * @param file - The file to upload
   * @returns The file URL
   * @throws Error if file validation fails
   */
  async uploadAttachment(roomId: string, file: File): Promise<string> {
    // Validate file (type, size, extension, magic bytes)
    const validation = await validateBrowserFile(file)
    if (!validation.valid) {
      throw new Error(validation.error || 'File validation failed')
    }

    // Sanitize file name to prevent path traversal
    const safeFileName = sanitizeFileName(file.name)
    const storagePath = `${roomId}/${Date.now()}_${safeFileName}`

    const { error } = await supabase.storage
      .from('chat-attachments')
      .upload(storagePath, file, {
        contentType: file.type,
        upsert: false,
      })

    if (error) throw error

    const { data: urlData } = supabase.storage
      .from('chat-attachments')
      .getPublicUrl(storagePath)

    return urlData.publicUrl
  },

  /**
   * Marks messages as read.
   * @param roomId - The chat room UUID
   * @param userId - The reader's profile ID
   */
  async markAsRead(roomId: string, userId: string): Promise<void> {
    const { error } = await supabase.rpc('mark_messages_as_read', {
      p_room_id: roomId,
      p_user_id: userId,
    })

    if (error) throw error
  },

  /**
   * Alias for markAsRead for backwards compatibility.
   * @param roomId - The chat room UUID
   * @param userId - The reader's profile ID
   */
  async markMessagesAsRead(roomId: string, userId: string): Promise<void> {
    return this.markAsRead(roomId, userId)
  },

  /**
   * Subscribes to new messages in a chat room with error handling and reconnection.
   * @param roomId - The chat room UUID
   * @param callback - Function to call when new message arrives
   * @returns Cleanup function
   */
  subscribeToRoom(roomId: string, callback: MessageCallback): () => void {
    const channelKey = `room:${roomId}`

    // Unsubscribe from existing subscription if any
    const existingChannel = this.subscriptions.get(channelKey)
    if (existingChannel) {
      existingChannel.unsubscribe()
      this.subscriptions.delete(channelKey)
    }

    // Clear any pending reconnect timer
    const existingTimer = this._reconnectTimers.get(channelKey)
    if (existingTimer) {
      clearTimeout(existingTimer)
      this._reconnectTimers.delete(channelKey)
    }

    // Reset retry count
    this._retryCounts.set(channelKey, 0)

    const subscribe = () => {
      const channel = supabase
        .channel(`chat:${roomId}`, {
          config: { presence: { key: roomId } },
        })
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'chat_messages',
            filter: `chat_room_id=eq.${roomId}`,
          },
          (payload: any) => {
            callback(payload.new as ChatMessage)
          }
        )
        .on('system', { event: '*' } as any, (payload: any) => {
          // Handle system events for connection state tracking
          if (payload?.type === 'error' || payload?.event === 'error') {
            console.error(`[Chat] Channel error for room ${roomId}:`, payload)
            this._setConnectionState('disconnected')
            this._attemptReconnect(channelKey, callback, roomId)
          }
        })
        .subscribe((status: string) => {
          if (status === 'SUBSCRIBED') {
            this._setConnectionState('connected')
            this._retryCounts.set(channelKey, 0)
          } else if (status === 'CHANNEL_ERROR') {
            console.error(`[Chat] Subscription error for room ${roomId}`)
            this._setConnectionState('disconnected')
            this._attemptReconnect(channelKey, callback, roomId)
          } else if (status === 'TIMED_OUT') {
            console.warn(`[Chat] Subscription timed out for room ${roomId}`)
            this._setConnectionState('disconnected')
            this._attemptReconnect(channelKey, callback, roomId)
          } else if (status === 'CLOSED') {
            this._setConnectionState('disconnected')
          }
        })

      this.subscriptions.set(channelKey, channel)
    }

    subscribe()

    // Return cleanup function
    return () => {
      const channel = this.subscriptions.get(channelKey)
      if (channel) {
        channel.unsubscribe()
        this.subscriptions.delete(channelKey)
      }
      const timer = this._reconnectTimers.get(channelKey)
      if (timer) {
        clearTimeout(timer)
        this._reconnectTimers.delete(channelKey)
      }
      this._retryCounts.delete(channelKey)
    }
  },

  /**
   * Attempt to reconnect a channel with exponential backoff
   */
  _attemptReconnect(
    channelKey: string,
    callback: MessageCallback,
    roomId: string
  ): void {
    const retries = this._retryCounts.get(channelKey) || 0

    if (retries >= RECONNECT_CONFIG.maxRetries) {
      console.error(`[Chat] Max reconnect attempts reached for ${channelKey}`)
      this._setConnectionState('disconnected')
      return
    }

    this._setConnectionState('reconnecting')
    this._retryCounts.set(channelKey, retries + 1)

    const delay = this._getReconnectDelay(channelKey)
    console.log(`[Chat] Reconnecting ${channelKey} in ${Math.round(delay)}ms (attempt ${retries + 1}/${RECONNECT_CONFIG.maxRetries})`)

    const timer = setTimeout(() => {
      this._reconnectTimers.delete(channelKey)

      // Clean up old channel
      const oldChannel = this.subscriptions.get(channelKey)
      if (oldChannel) {
        oldChannel.unsubscribe()
        this.subscriptions.delete(channelKey)
      }

      // Re-subscribe
      const channel = supabase
        .channel(`chat:${roomId}:${Date.now()}`)
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'chat_messages',
            filter: `chat_room_id=eq.${roomId}`,
          },
          (payload: any) => {
            callback(payload.new as ChatMessage)
          }
        )
        .subscribe((status: string) => {
          if (status === 'SUBSCRIBED') {
            this._setConnectionState('connected')
            this._retryCounts.set(channelKey, 0)
          } else if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
            this._attemptReconnect(channelKey, callback, roomId)
          }
        })

      this.subscriptions.set(channelKey, channel)
    }, delay)

    this._reconnectTimers.set(channelKey, timer)
  },

  /**
   * Subscribes to unread count updates for rooms the user is in.
   * Only subscribes to rooms where the user is a participant.
   * @param userId - The user's profile ID
   * @param callback - Function to call when unread count changes
   * @returns Cleanup function
   */
  subscribeToUnreadCounts(
    userId: string,
    callback: (roomId: string, count: number) => void
  ): () => void {
    const channelKey = `unread:${userId}`

    // First, get the user's room IDs
    const setupSubscription = async () => {
      let roomIds: string[] = this._userRoomIds.get(userId) || []

      if (roomIds.length === 0) {
        const { data: participations } = await supabase
          .from('chat_participants')
          .select('chat_room_id')
          .eq('profile_id', userId)

        roomIds = participations?.map((p: any) => p.chat_room_id) || []
        this._userRoomIds.set(userId, roomIds)
      }

      if (roomIds.length === 0) return

      // Subscribe to each room individually for targeted updates
      // This avoids listening to ALL chat_messages inserts globally
      const channels: RealtimeChannel[] = []

      for (const roomId of roomIds) {
        const channel = supabase
          .channel(`unread:${userId}:${roomId}`)
          .on(
            'postgres_changes',
            {
              event: 'INSERT',
              schema: 'public',
              table: 'chat_messages',
              filter: `chat_room_id=eq.${roomId}`,
            },
            async (payload: any) => {
              const message = payload.new as ChatMessage
              if (message.sender_id !== userId) {
                // Get unread count for the room
                const { count } = await supabase
                  .from('chat_messages')
                  .select('*', { count: 'exact', head: true })
                  .eq('chat_room_id', message.chat_room_id)
                  .neq('sender_id', userId)
                  .not('read_by', 'cs', `["${userId}"]`)

                callback(message.chat_room_id, count || 0)
              }
            }
          )
          .subscribe((status: string) => {
            if (status === 'CHANNEL_ERROR') {
              console.error(`[Chat] Unread count subscription error for room ${roomId}`)
            }
          })

        channels.push(channel)
      }

      // Store a composite cleanup reference
      this.subscriptions.set(channelKey, channels[0])
      // Store additional channels for cleanup
      for (let i = 1; i < channels.length; i++) {
        this.subscriptions.set(`${channelKey}:${i}`, channels[i])
      }
    }

    setupSubscription()

    return () => {
      // Clean up all unread channels for this user
      const keysToDelete: string[] = []
      this.subscriptions.forEach((channel, key) => {
        if (key.startsWith(`unread:${userId}`)) {
          channel.unsubscribe()
          keysToDelete.push(key)
        }
      })
      keysToDelete.forEach((key) => this.subscriptions.delete(key))
      this._userRoomIds.delete(userId)
    }
  },

  /**
   * Gets total unread message count for a user.
   * @param userId - The user's profile ID
   * @returns Total unread count
   */
  async getTotalUnreadCount(userId: string): Promise<number> {
    // Get rooms where user is a participant
    const { data: participations } = await supabase
      .from('chat_participants')
      .select('chat_room_id')
      .eq('profile_id', userId)

    if (!participations || participations.length === 0) return 0

    const roomIds = participations.map((p: any) => p.chat_room_id)

    // Cache for unread subscriptions
    this._userRoomIds.set(userId, roomIds)

    const { count, error } = await supabase
      .from('chat_messages')
      .select('*', { count: 'exact', head: true })
      .in('chat_room_id', roomIds)
      .neq('sender_id', userId)
      .not('read_by', 'cs', `["${userId}"]`)

    if (error) throw error
    return count || 0
  },

  /**
   * Cleans up all subscriptions and timers.
   */
  cleanup(): void {
    // Clear all reconnect timers
    this._reconnectTimers.forEach((timer) => clearTimeout(timer))
    this._reconnectTimers.clear()

    // Unsubscribe all channels
    this.subscriptions.forEach((channel) => {
      channel.unsubscribe()
    })
    this.subscriptions.clear()

    // Clear state
    this._retryCounts.clear()
    this._userRoomIds.clear()
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
