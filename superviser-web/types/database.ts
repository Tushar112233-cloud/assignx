/**
 * @fileoverview Type definitions for Supabase database schema and related types.
 * Re-exports auto-generated types from supabase.ts with custom helper types.
 * @module types/database
 */

// Re-export auto-generated types
export type { Database, Json } from "./supabase"
import type { Database } from "./supabase"

// Table row type helpers
export type Tables<T extends keyof Database["public"]["Tables"]> =
  Database["public"]["Tables"][T]["Row"]

export type InsertTables<T extends keyof Database["public"]["Tables"]> =
  Database["public"]["Tables"][T]["Insert"]

export type UpdateTables<T extends keyof Database["public"]["Tables"]> =
  Database["public"]["Tables"][T]["Update"]

// Enum types from the database
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

// Convenience type aliases for common tables
export type Profile = Tables<"profiles">
export type Supervisor = Tables<"supervisors">
export type SupervisorActivation = Tables<"supervisor_activation">
export type Project = Tables<"projects">
export type Doer = Tables<"doers">
export type Wallet = Tables<"wallets">
export type WalletTransaction = Tables<"wallet_transactions">
export type ChatRoom = Tables<"chat_rooms">
export type ChatMessage = Tables<"chat_messages">
export type ChatParticipant = Tables<"chat_participants">
export type Notification = Tables<"notifications">
export type SupportTicket = Tables<"support_tickets">
export type TicketMessage = Tables<"ticket_messages">
export type Subject = Tables<"subjects">

// Auth user type (from Supabase Auth)
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

// Extended types with relationships
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
