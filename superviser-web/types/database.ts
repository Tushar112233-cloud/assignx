/**
 * @fileoverview Type definitions for database entities.
 * Standalone interfaces for all tables used in the supervisor web app.
 * @module types/database
 */

// JSON helper type
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

// Placeholder for legacy Database type references (no longer needed)
export interface Database {
  public: {
    Tables: Record<string, { Row: Record<string, unknown>; Insert: Record<string, unknown>; Update: Record<string, unknown> }>
  }
}

// Enum types
export type ProjectStatus =
  | "draft"
  | "submitted"
  | "analyzing"
  | "quoted"
  | "payment_pending"
  | "paid"
  | "assigning"
  | "assigned"
  | "in_progress"
  | "submitted_for_qc"
  | "qc_in_progress"
  | "qc_approved"
  | "qc_rejected"
  | "delivered"
  | "revision_requested"
  | "in_revision"
  | "completed"
  | "auto_approved"
  | "cancelled"
  | "refunded"

export type ServiceType =
  | "new_project"
  | "proofreading"
  | "plagiarism_check"
  | "ai_detection"
  | "expert_opinion"

export type TransactionType =
  | "credit"
  | "debit"
  | "refund"
  | "withdrawal"
  | "top_up"
  | "project_payment"
  | "project_earning"
  | "commission"
  | "bonus"
  | "penalty"
  | "reversal"

export type PaymentStatus =
  | "initiated"
  | "pending"
  | "processing"
  | "completed"
  | "failed"
  | "cancelled"
  | "refunded"
  | "partially_refunded"

export type PayoutStatus =
  | "pending"
  | "processing"
  | "completed"
  | "failed"
  | "cancelled"

export type ChatRoomType =
  | "project_user_supervisor"
  | "project_supervisor_doer"
  | "project_all"
  | "support"
  | "direct"

export type MessageType = "text" | "file" | "image" | "system" | "action"

export type NotificationType =
  | "project_submitted"
  | "quote_ready"
  | "payment_received"
  | "project_assigned"
  | "task_available"
  | "task_assigned"
  | "work_submitted"
  | "qc_approved"
  | "qc_rejected"
  | "revision_requested"
  | "project_delivered"
  | "project_completed"
  | "new_message"
  | "payout_processed"
  | "system_alert"
  | "promotional"

export type TicketStatus =
  | "open"
  | "in_progress"
  | "waiting_response"
  | "resolved"
  | "closed"
  | "reopened"

export type TicketPriority = "low" | "medium" | "high" | "urgent"

// ─── Table Row Types ─────────────────────────────────────────────

export interface Profile {
  id: string
  full_name: string | null
  email: string | null
  phone: string | null
  avatar_url: string | null
  role: string | null
  /** API alias for role */
  user_type?: string | null
  is_active: boolean
  created_at: string
  updated_at: string | null
  college_id: string | null
  city: string | null
  state: string | null
  country: string | null
  bio: string | null
}

export interface Supervisor {
  id: string
  profile_id: string
  qualification: string | null
  years_of_experience: number | null
  cv_url: string | null
  is_available: boolean
  max_concurrent_projects: number
  is_activated: boolean
  total_earnings: number
  total_projects_managed: number
  average_rating: number
  total_reviews: number
  success_rate: number
  average_response_time_hours: number
  bank_verified: boolean
  cv_verified: boolean
  bank_name: string | null
  bank_account_number: string | null
  bank_account_name: string | null
  bank_ifsc_code: string | null
  upi_id: string | null
  status: string | null
  is_access_granted: boolean
  created_at: string
  updated_at: string | null
}

export interface SupervisorActivation {
  id: string
  supervisor_id: string
  training_completed: boolean
  training_completed_at: string | null
  quiz_passed: boolean
  quiz_passed_at: string | null
  quiz_attempt_id: string | null
  total_quiz_attempts: number
  cv_submitted: boolean
  cv_submitted_at: string | null
  cv_verified: boolean
  cv_verified_at: string | null
  cv_verified_by: string | null
  cv_rejection_reason: string | null
  bank_details_added: boolean
  bank_details_added_at: string | null
  is_fully_activated: boolean
  is_activated: boolean
  activated_at: string | null
  created_at: string
  updated_at: string | null
}

export interface Project {
  id: string
  project_number: string
  title: string
  description: string | null
  service_type: ServiceType
  subject_id: string | null
  status: ProjectStatus
  user_id: string | null
  supervisor_id: string | null
  doer_id: string | null
  user_quote: number | null
  doer_payout: number | null
  supervisor_commission: number | null
  platform_fee: number | null
  deadline: string | null
  word_count: number | null
  page_count: number | null
  instructions: string | null
  specific_instructions?: string | null
  file_urls: string[] | null
  delivery_urls: string[] | null
  priority: string | null
  doer_assigned_at: string | null
  submitted_for_qc_at: string | null
  completed_at: string | null
  delivered_at: string | null
  status_updated_at?: string | null
  created_at: string
  updated_at: string | null
}

export interface Doer {
  id: string
  profile_id: string
  qualification: string | null
  years_of_experience: number | null
  is_available: boolean
  is_activated: boolean
  is_verified: boolean
  is_blacklisted: boolean
  blacklist_reason: string | null
  blacklistReason?: string | null
  total_earnings: number
  total_projects: number
  total_projects_completed?: number
  completed_projects: number
  active_projects: number
  average_rating: number
  total_reviews: number
  success_rate: number
  average_response_time: string | null
  on_time_delivery_rate?: number | null
  max_concurrent_projects: number
  bank_name: string | null
  bank_account_number: string | null
  bank_account_name: string | null
  bank_ifsc_code: string | null
  upi_id: string | null
  created_at: string
  updated_at: string | null
}

export interface Wallet {
  id: string
  user_id: string
  balance: number
  pending_balance: number
  total_earned: number
  total_credited?: number
  total_withdrawn: number
  currency: string
  is_active: boolean
  created_at: string
  updated_at: string | null
}

export interface WalletTransaction {
  id: string
  wallet_id: string
  type: TransactionType
  /** API alias for type */
  transaction_type?: TransactionType
  amount: number
  balance_after: number
  description: string | null
  reference_id: string | null
  reference_type: string | null
  status: PaymentStatus
  metadata: Json | null
  created_at: string
  updated_at: string | null
}

export interface PayoutRequest {
  id: string
  supervisor_id?: string | null
  doer_id?: string | null
  amount: number
  requested_amount?: number
  approved_amount?: number
  status: PayoutStatus
  bank_name?: string | null
  bank_account_number?: string | null
  bank_ifsc_code?: string | null
  upi_id?: string | null
  processed_at?: string | null
  created_at: string
}

export interface ChatRoom {
  id: string
  project_id: string | null
  type: ChatRoomType
  /** API alias for type */
  room_type?: ChatRoomType
  name: string | null
  is_suspended: boolean
  suspension_reason: string | null
  last_message_at?: string | null
  created_at: string
  updated_at: string | null
}

export interface ChatMessage {
  id: string
  room_id: string
  /** API alias for room_id */
  chat_room_id?: string
  sender_id: string | null
  /** Platform role of the sender: user-web → 'user', supervisor-web → 'supervisor', doer-web → 'doer' */
  sender_role?: 'user' | 'supervisor' | 'doer' | 'system' | null
  type: MessageType
  /** API alias for type */
  message_type?: string
  content: string | null
  file_url: string | null
  file_name: string | null
  /** API alias for file size */
  file_size_bytes?: number | null
  is_read: boolean
  is_flagged: boolean
  is_deleted?: boolean
  flag_reason: string | null
  metadata: Json | null
  /** API alias for metadata */
  action_metadata?: Json | null
  created_at: string
  updated_at: string | null
}

export interface ChatParticipant {
  id: string
  room_id: string
  user_id: string
  /** API alias for user_id */
  profile_id?: string
  role: string | null
  /** API alias for role */
  participant_role?: string | null
  joined_at: string
  last_read_at: string | null
}

export interface Notification {
  id: string
  user_id: string
  type: NotificationType
  /** API alias for type */
  notification_type?: NotificationType
  title: string
  message: string | null
  /** API alias for message */
  body?: string | null
  target_role?: string | null
  reference_id: string | null
  reference_type: string | null
  read: boolean
  /** API alias for read */
  is_read?: boolean
  read_at: string | null
  metadata: Json | null
  created_at: string
}

export interface SupportTicket {
  id: string
  user_id: string
  ticket_number?: string
  subject: string
  description: string | null
  status: TicketStatus
  priority: TicketPriority
  category: string | null
  project_id?: string | null
  assigned_to: string | null
  resolved_at: string | null
  created_at: string
  updated_at: string | null
}

export interface TicketMessage {
  id: string
  ticket_id: string
  sender_id: string | null
  /** API alias - staff vs user */
  sender_type?: string
  content: string
  /** API alias for content */
  message?: string
  is_internal: boolean
  /** API alias for is_internal */
  is_staff?: boolean
  attachments: string[] | null
  created_at: string
}

export interface Subject {
  id: string
  name: string
  slug: string | null
  description: string | null
  is_active: boolean
  created_at: string
}

// Auth user type
export interface User {
  id: string
  email?: string
  phone?: string
  created_at: string
  updated_at?: string
  app_metadata: Record<string, unknown>
  user_metadata: Record<string, unknown>
  aud: string
  role?: string
}

// ─── Extended Types with Relationships ───────────────────────────

export interface SupervisorWithProfile extends Supervisor {
  profiles?: Profile
}

export interface ProjectWithRelations extends Project {
  profiles?: Profile // user
  supervisors?: SupervisorWithProfile
  doers?: DoerWithProfile
  subjects?: Subject
}

export interface DoerWithProfile extends Doer {
  profiles?: Profile
  // Extended fields from relations/computed
  skills?: string[]
  subjects?: string[]
  active_projects_count?: number
  // Fields commonly flattened from profiles or computed by API
  full_name?: string
  email?: string
  phone?: string | null
  avatar_url?: string | null
  bio?: string | null
  rating?: number
  joined_at?: string
  last_active_at?: string | null
  is_online?: boolean
}

export interface ChatRoomWithParticipants extends ChatRoom {
  chat_participants?: (ChatParticipant & { profiles?: Profile })[]
  projects?: Project
}

export interface ChatMessageWithSender extends ChatMessage {
  profiles?: Profile
}

export interface NotificationWithProfile extends Notification {
  profiles?: Profile
}

export interface SupportTicketWithMessages extends SupportTicket {
  ticket_messages?: TicketMessage[]
  profiles?: Profile
}

export interface WalletWithTransactions extends Wallet {
  wallet_transactions?: WalletTransaction[]
}
