/**
 * Support and help desk types
 * @module types/support
 */

import type { UserRole } from './common.types'

/**
 * Support ticket status
 * Lifecycle states of support tickets
 */
export type TicketStatus = 'open' | 'in_progress' | 'resolved' | 'closed'

/**
 * Support ticket priority
 * Urgency levels for tickets
 */
export type TicketPriority = 'low' | 'medium' | 'high' | 'urgent'

/**
 * Support ticket interface
 * User support request
 */
export interface SupportTicket {
  /** Unique identifier */
  id: string
  /** Submitting user ID */
  user_id: string
  /** User display name */
  user_name: string | null
  /** Ticket subject */
  subject: string
  /** Detailed description */
  description: string
  /** Issue category */
  category: 'technical' | 'payment' | 'project' | 'account' | 'other'
  /** Priority level */
  priority: TicketPriority
  /** Current status */
  status: TicketStatus
  /** Assigned support agent */
  assigned_to: string | null
  /** Agent display name */
  assigned_name: string | null
  /** Creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string
  /** Resolution timestamp */
  resolved_at: string | null
}

/**
 * Ticket message interface
 * Message in support conversation
 */
export interface TicketMessage {
  /** Unique identifier */
  id: string
  /** Parent ticket */
  ticket_id: string
  /** Sender ID */
  sender_id: string
  /** Sender display name */
  sender_name: string | null
  /** Sender role */
  sender_role: 'user' | 'support' | 'admin'
  /** Message content */
  message: string
  /** Attachment URL */
  attachment_url: string | null
  /** Send timestamp */
  created_at: string
}

/**
 * FAQ interface
 * Frequently asked question
 */
export interface FAQ {
  /** Unique identifier */
  id: string
  /** Question text */
  question: string
  /** Answer text */
  answer: string
  /** Category for grouping */
  category: string
  /** Display order */
  display_order: number
  /** Active status */
  is_active: boolean
  /** Target role for this FAQ */
  target_role: string | null
  /** Helpful votes count */
  helpful_count: number
  /** Not helpful votes count */
  not_helpful_count: number
  /** Creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string
}
