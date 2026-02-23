/**
 * Chat service for Supabase operations
 * Handles real-time messaging with supervisors
 */

import { createClient } from '@/lib/supabase/client'
import type {
  ChatRoom,
  ChatMessage,
  ChatParticipant,
  ChatRoomType,
  MessageType,
} from '@/types/database'
import type { RealtimeChannel } from '@supabase/supabase-js'

/**
 * Get or create a chat room for a project
 * Automatically adds supervisor and doer as participants when creating a new room
 */
export async function getOrCreateProjectChatRoom(
  projectId: string
): Promise<ChatRoom> {
  const supabase = createClient()

  // First, try to get existing room
  const { data: existingRoom, error: fetchError } = await supabase
    .from('chat_rooms')
    .select('*')
    .eq('project_id', projectId)
    .eq('room_type', 'project_supervisor_doer')
    .single()

  if (existingRoom) {
    // Ensure current user is a participant
    await ensureUserIsParticipant(existingRoom.id, projectId)
    return existingRoom
  }

  // If not found, create a new room
  if (fetchError?.code === 'PGRST116') {
    const { data: newRoom, error: createError } = await supabase
      .from('chat_rooms')
      .insert({
        project_id: projectId,
        room_type: 'project_supervisor_doer' as ChatRoomType,
        name: null,
      })
      .select()
      .single()

    if (createError) {
      console.error('Error creating chat room:', createError)
      throw createError
    }

    // Add participants to the newly created room
    await addProjectChatParticipants(newRoom.id, projectId)

    return newRoom
  }

  if (fetchError) {
    console.error('Error fetching chat room:', fetchError)
    throw fetchError
  }

  throw new Error('Unexpected state in getOrCreateProjectChatRoom')
}

/**
 * Ensure the current user is a participant in the chat room
 */
async function ensureUserIsParticipant(
  roomId: string,
  projectId: string
): Promise<void> {
  const supabase = createClient()

  // Get current user from session (no network call — avoids getUser() hang)
  const { data: { session } } = await supabase.auth.getSession()
  const user = session?.user
  if (!user) return

  // Check if already a participant
  const { data: existing } = await supabase
    .from('chat_participants')
    .select('id')
    .eq('chat_room_id', roomId)
    .eq('profile_id', user.id)
    .single()

  if (existing) return

  // Get project to determine role
  const { data: project } = await supabase
    .from('projects')
    .select(`
      doer_id,
      doers!projects_doer_id_fkey(profile_id),
      supervisor_id,
      supervisors!projects_supervisor_id_fkey(profile_id)
    `)
    .eq('id', projectId)
    .single()

  if (!project) return

  // Determine user's role
  let role: 'supervisor' | 'doer' | null = null
  // Handle both array and single object responses from Supabase
  const doersData = project.doers as unknown
  const supervisorsData = project.supervisors as unknown
  const doerProfileId = Array.isArray(doersData)
    ? (doersData[0] as { profile_id: string } | undefined)?.profile_id
    : (doersData as { profile_id: string } | null)?.profile_id
  const supervisorProfileId = Array.isArray(supervisorsData)
    ? (supervisorsData[0] as { profile_id: string } | undefined)?.profile_id
    : (supervisorsData as { profile_id: string } | null)?.profile_id

  if (doerProfileId === user.id) {
    role = 'doer'
  } else if (supervisorProfileId === user.id) {
    role = 'supervisor'
  }

  if (role) {
    await supabase
      .from('chat_participants')
      .insert({
        chat_room_id: roomId,
        profile_id: user.id,
        participant_role: role,
        is_active: true,
        notifications_enabled: true,
        unread_count: 0,
        has_left: false,
      })
      .select()
      .single()
  }
}

/**
 * Add supervisor and doer as participants to a project chat room
 */
async function addProjectChatParticipants(
  roomId: string,
  projectId: string
): Promise<void> {
  const supabase = createClient()

  // Get project with supervisor, doer, and user info
  const { data: project, error: projectError } = await supabase
    .from('projects')
    .select(`
      user_id,
      doer_id,
      doers!projects_doer_id_fkey(profile_id),
      supervisor_id,
      supervisors!projects_supervisor_id_fkey(profile_id)
    `)
    .eq('id', projectId)
    .single()

  if (projectError || !project) {
    console.error('Error fetching project for chat participants:', projectError)
    return
  }

  const participants: Array<{
    chat_room_id: string
    profile_id: string
    participant_role: string
    is_active: boolean
    notifications_enabled: boolean
    unread_count: number
    has_left: boolean
  }> = []

  // Add project owner (user) if exists
  if (project.user_id) {
    participants.push({
      chat_room_id: roomId,
      profile_id: project.user_id,
      participant_role: 'user',
      is_active: true,
      notifications_enabled: true,
      unread_count: 0,
      has_left: false,
    })
  }

  // Add supervisor if assigned
  // Handle both array and single object responses from Supabase
  const supervisorsData = project.supervisors as unknown
  const supervisorProfileId = Array.isArray(supervisorsData)
    ? (supervisorsData[0] as { profile_id: string } | undefined)?.profile_id
    : (supervisorsData as { profile_id: string } | null)?.profile_id
  if (supervisorProfileId) {
    participants.push({
      chat_room_id: roomId,
      profile_id: supervisorProfileId,
      participant_role: 'supervisor',
      is_active: true,
      notifications_enabled: true,
      unread_count: 0,
      has_left: false,
    })
  }

  // Add doer if assigned
  const doersData = project.doers as unknown
  const doerProfileId = Array.isArray(doersData)
    ? (doersData[0] as { profile_id: string } | undefined)?.profile_id
    : (doersData as { profile_id: string } | null)?.profile_id
  if (doerProfileId) {
    participants.push({
      chat_room_id: roomId,
      profile_id: doerProfileId,
      participant_role: 'doer',
      is_active: true,
      notifications_enabled: true,
      unread_count: 0,
      has_left: false,
    })
  }

  if (participants.length > 0) {
    // Deduplicate by profile_id (same user may be supervisor, doer, and user)
    const seen = new Set<string>()
    const uniqueParticipants = participants.filter(p => {
      if (seen.has(p.profile_id)) return false
      seen.add(p.profile_id)
      return true
    })

    const { error: insertError } = await supabase
      .from('chat_participants')
      .upsert(uniqueParticipants, { onConflict: 'chat_room_id,profile_id', ignoreDuplicates: true })

    if (insertError) {
      console.error('Error adding chat participants:', insertError)
    }
  }
}

/**
 * Get messages for a chat room
 */
export async function getChatMessages(
  roomId: string,
  limit = 50,
  before?: string
): Promise<ChatMessage[]> {
  const supabase = createClient()

  let query = supabase
    .from('chat_messages')
    .select('*')
    .eq('chat_room_id', roomId)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (before) {
    query = query.lt('created_at', before)
  }

  const { data, error } = await query

  if (error) {
    console.error('Error fetching chat messages:', error)
    throw error
  }

  // Return in chronological order
  return (data || []).reverse()
}

/**
 * Send a text message
 * @security Uses authenticated user's ID, not client-provided ID
 */
export async function sendMessage(
  roomId: string,
  content: string
): Promise<ChatMessage> {
  const supabase = createClient()

  // Get the authenticated user's ID from the local session (no network call)
  const { data: { session: authSession } } = await supabase.auth.getSession()
  const user = authSession?.user
  if (!user) {
    throw new Error('Authentication required to send messages')
  }

  const senderId = user.id

  const { data, error } = await supabase
    .from('chat_messages')
    .insert({
      chat_room_id: roomId,
      sender_id: senderId,
      message_type: 'text' as MessageType,
      content,
      is_edited: false,
      is_deleted: false,
      is_flagged: false,
      contains_contact_info: false,
      read_by: [senderId],
    })
    .select()
    .single()

  if (error) {
    console.error('Error sending message:', error)
    throw error
  }

  // Update room's last_message_at
  await supabase
    .from('chat_rooms')
    .update({ last_message_at: new Date().toISOString() })
    .eq('id', roomId)

  return data
}

/**
 * Send a file message
 * @security Uses authenticated user's ID, not client-provided ID
 */
export async function sendFileMessage(
  roomId: string,
  file: File
): Promise<ChatMessage> {
  const supabase = createClient()

  // Get the authenticated user's ID from the local session (no network call)
  const { data: { session: authSession } } = await supabase.auth.getSession()
  const user = authSession?.user
  if (!user) {
    throw new Error('Authentication required to send files')
  }

  const senderId = user.id

  // Upload file to storage
  const fileExt = file.name.split('.').pop()
  const fileName = `chat/${roomId}/${Date.now()}.${fileExt}`

  const { data: uploadData, error: uploadError } = await supabase.storage
    .from('chat-files')
    .upload(fileName, file)

  if (uploadError) {
    console.error('Error uploading chat file:', uploadError)
    throw uploadError
  }

  // Get public URL
  const { data: urlData } = supabase.storage
    .from('chat-files')
    .getPublicUrl(uploadData.path)

  // Determine message type based on file
  const isImage = file.type.startsWith('image/')
  const messageType: MessageType = isImage ? 'image' : 'file'

  const { data, error } = await supabase
    .from('chat_messages')
    .insert({
      chat_room_id: roomId,
      sender_id: senderId,
      message_type: messageType,
      content: file.name,
      file_url: urlData.publicUrl,
      file_name: file.name,
      file_type: file.type,
      file_size_bytes: file.size,
      is_edited: false,
      is_deleted: false,
      is_flagged: false,
      contains_contact_info: false,
      read_by: [senderId],
    })
    .select()
    .single()

  if (error) {
    console.error('Error sending file message:', error)
    throw error
  }

  // Update room's last_message_at
  await supabase
    .from('chat_rooms')
    .update({ last_message_at: new Date().toISOString() })
    .eq('id', roomId)

  return data
}

/**
 * Mark messages as read
 * @security Uses authenticated user's ID, not client-provided ID
 */
export async function markMessagesAsRead(
  roomId: string
): Promise<void> {
  const supabase = createClient()

  // Get the authenticated user's ID from the local session (no network call)
  const { data: { session: authSession } } = await supabase.auth.getSession()
  const user = authSession?.user
  if (!user) {
    throw new Error('Authentication required')
  }

  const userId = user.id

  // Get unread messages not sent by the user
  const { data: unreadMessages } = await supabase
    .from('chat_messages')
    .select('id, read_by')
    .eq('chat_room_id', roomId)
    .neq('sender_id', userId)

  if (unreadMessages && unreadMessages.length > 0) {
    // Collect IDs of messages that need updating (avoid N+1 query pattern)
    const unreadIds = unreadMessages
      .filter(msg => {
        const readBy = msg.read_by || []
        return !readBy.includes(userId)
      })
      .map(msg => msg.id)

    if (unreadIds.length > 0) {
      // Update each message's read_by array using targeted updates
      // (upsert with partial columns can corrupt other fields)
      const updatePromises = unreadIds.map(id => {
        const msg = unreadMessages.find(m => m.id === id)
        const readBy = msg?.read_by || []
        return supabase
          .from('chat_messages')
          .update({ read_by: [...new Set([...readBy, userId])] })
          .eq('id', id)
      })

      const results = await Promise.all(updatePromises)
      const firstError = results.find(r => r.error)?.error
      if (firstError) {
        console.error('Error marking messages as read:', firstError)
        throw firstError
      }
    }
  }

  // Update participant's last_read_at
  await supabase
    .from('chat_participants')
    .update({ last_read_at: new Date().toISOString() })
    .eq('chat_room_id', roomId)
    .eq('profile_id', userId)
}

/**
 * Get unread message count for a room
 * @security Uses authenticated user's ID, not client-provided ID
 */
export async function getUnreadCount(
  roomId: string
): Promise<number> {
  const supabase = createClient()

  // Get the authenticated user's ID from the local session (no network call)
  const { data: { session: authSession } } = await supabase.auth.getSession()
  const user = authSession?.user
  if (!user) {
    return 0
  }

  const userId = user.id

  const { data, error } = await supabase
    .from('chat_messages')
    .select('id, read_by')
    .eq('chat_room_id', roomId)
    .neq('sender_id', userId)

  if (error) {
    console.error('Error getting unread count:', error)
    return 0
  }

  // Count messages where userId is not in read_by array
  const unreadCount = (data || []).filter(msg => {
    const readBy = msg.read_by || []
    return !readBy.includes(userId)
  }).length

  return unreadCount
}

/**
 * Get chat participants for a room
 */
export async function getChatParticipants(
  roomId: string
): Promise<ChatParticipant[]> {
  const supabase = createClient()

  const { data, error } = await supabase
    .from('chat_participants')
    .select('*')
    .eq('chat_room_id', roomId)
    .eq('is_active', true)

  if (error) {
    console.error('Error fetching participants:', error)
    throw error
  }

  return data || []
}

/**
 * Subscribe to real-time messages
 */
export function subscribeToMessages(
  roomId: string,
  onMessage: (message: ChatMessage) => void
): RealtimeChannel {
  const supabase = createClient()

  const channel = supabase
    .channel(`room:${roomId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'chat_messages',
        filter: `chat_room_id=eq.${roomId}`,
      },
      (payload) => {
        onMessage(payload.new as ChatMessage)
      }
    )
    .subscribe()

  return channel
}

/**
 * Unsubscribe from real-time messages
 */
export async function unsubscribeFromMessages(
  channel: RealtimeChannel
): Promise<void> {
  const supabase = createClient()
  await supabase.removeChannel(channel)
}

/**
 * Join a user to a chat room as participant
 */
export async function joinChatRoom(
  roomId: string,
  userId: string,
  role: 'user' | 'supervisor' | 'doer' | 'admin'
): Promise<ChatParticipant> {
  const supabase = createClient()

  // Upsert participant — handles both new joins and re-joins cleanly
  const { data, error } = await supabase
    .from('chat_participants')
    .upsert(
      {
        chat_room_id: roomId,
        profile_id: userId,
        participant_role: role,
        is_active: true,
        notifications_enabled: true,
        unread_count: 0,
        has_left: false,
      },
      { onConflict: 'chat_room_id,profile_id' }
    )
    .select()
    .single()

  if (error) {
    console.error('Error joining chat room:', error)
    throw error
  }

  return data
}
