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

const supabase = createClient()

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
   * Subscribes to new messages in a chat room.
   * @param roomId - The chat room UUID
   * @param callback - Function to call when new message arrives
   * @returns Cleanup function
   */
  subscribeToRoom(roomId: string, callback: MessageCallback): () => void {
    // Unsubscribe from existing subscription if any
    const existingChannel = this.subscriptions.get(roomId)
    if (existingChannel) {
      existingChannel.unsubscribe()
    }

    // Create new subscription
    const channel = supabase
      .channel(`chat:${roomId}`)
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
      .subscribe()

    this.subscriptions.set(roomId, channel)

    // Return cleanup function
    return () => {
      channel.unsubscribe()
      this.subscriptions.delete(roomId)
    }
  },

  /**
   * Subscribes to all chat rooms for unread count updates.
   * @param userId - The user's profile ID
   * @param callback - Function to call when unread count changes
   * @returns Cleanup function
   */
  subscribeToUnreadCounts(
    userId: string,
    callback: (roomId: string, count: number) => void
  ): () => void {
    const channel = supabase
      .channel(`user_chats:${userId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'chat_messages',
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
      .subscribe()

    return () => {
      channel.unsubscribe()
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
   * Cleans up all subscriptions.
   */
  cleanup(): void {
    this.subscriptions.forEach((channel) => {
      channel.unsubscribe()
    })
    this.subscriptions.clear()
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
}
