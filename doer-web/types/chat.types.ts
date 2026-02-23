/**
 * Chat and messaging types
 * @module types/chat
 */

/**
 * Chat room type
 * Different contexts for chat rooms - matches database enum
 */
export type ChatRoomType =
  | 'project_user_supervisor'  // Chat between user and supervisor for a project
  | 'project_supervisor_doer'  // Chat between supervisor and doer for a project
  | 'project_all'              // Chat with all parties for a project
  | 'support'                  // Support chat
  | 'direct'                   // Direct message

/**
 * Message type
 * Types of messages in chat
 */
export type MessageType =
  | 'text'     // Text message
  | 'file'     // File attachment
  | 'image'    // Image attachment
  | 'system'   // System message
  | 'revision' // Revision request
  | 'action'   // Action message (e.g., revision request, status change)

/**
 * Notification type
 * Types of system notifications
 */
export type NotificationType =
  | 'task_assigned'
  | 'task_available'
  | 'deadline_reminder'
  | 'revision_requested'
  | 'payment_received'
  | 'review_received'
  | 'message_received'
  | 'system_alert'
  | 'quiz_passed'
  | 'quiz_failed'
  | 'activation_complete'
  | 'payout_processed'
  | 'profile_updated'
  | 'skill_verified'
  | 'training_reminder'
  | 'general'

/**
 * Chat room interface
 * Conversation container
 */
export interface ChatRoom {
  /** Unique identifier */
  id: string
  /** Related project (if any) */
  project_id: string | null
  /** Room type */
  room_type: ChatRoomType
  /** Room name/title */
  name: string | null
  /** Creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string
  /** Last message timestamp */
  last_message_at: string | null
}

/**
 * Chat message interface
 * Individual message in a room - matches database schema
 */
export interface ChatMessage {
  /** Unique identifier */
  id: string
  /** Parent room - uses chat_room_id in database */
  chat_room_id: string
  /** Sender user ID */
  sender_id: string
  /** Message type */
  message_type: MessageType
  /** Message content */
  content: string | null
  /** Attached file URL */
  file_url: string | null
  /** Attached file name */
  file_name: string | null
  /** Attached file type (MIME) */
  file_type: string | null
  /** Attached file size in bytes */
  file_size_bytes: number | null
  /** Action type for action messages */
  action_type: string | null
  /** Action metadata */
  action_metadata: Record<string, unknown> | null
  /** Reply to message ID */
  reply_to_id: string | null
  /** Whether message was edited */
  is_edited: boolean
  /** Edit timestamp */
  edited_at: string | null
  /** Whether message was deleted */
  is_deleted: boolean
  /** Deletion timestamp */
  deleted_at: string | null
  /** Whether message is flagged */
  is_flagged: boolean
  /** Flag reason */
  flagged_reason: string | null
  /** Whether message contains contact info */
  contains_contact_info: boolean
  /** Read by users - JSONB array of profile IDs */
  read_by: string[]
  /** Delivery timestamp */
  delivered_at: string | null
  /** Send timestamp */
  created_at: string

  // Display fields (populated from joins, not in database)
  /** Sender display name (from profile join) */
  sender_name?: string | null
  /** Sender avatar URL (from profile join) */
  sender_avatar?: string | null
}

/**
 * Chat participant interface
 * User in a chat room - matches database schema
 */
export interface ChatParticipant {
  /** Unique identifier */
  id: string
  /** Parent room - uses chat_room_id in database */
  chat_room_id: string
  /** User profile ID */
  profile_id: string
  /** User role in chat */
  role: 'user' | 'supervisor' | 'doer' | 'admin'
  /** Join timestamp */
  joined_at: string
  /** Last seen timestamp */
  last_seen_at: string | null
  /** Last read message ID */
  last_read_message_id: string | null
  /** Whether participant has muted chat */
  is_muted: boolean
  /** Whether participant has left chat */
  has_left: boolean
  /** Left timestamp */
  left_at: string | null
  /** Active status */
  is_active: boolean
}

/**
 * Notification interface
 * System notification
 */
export interface Notification {
  /** Unique identifier */
  id: string
  /** Target user */
  user_id: string
  /** Notification type */
  type: NotificationType
  /** Notification title */
  title: string
  /** Notification message */
  message: string
  /** Additional data */
  data: Record<string, unknown> | null
  /** Read status */
  is_read: boolean
  /** Creation timestamp */
  created_at: string
  /** Read timestamp */
  read_at: string | null
}
