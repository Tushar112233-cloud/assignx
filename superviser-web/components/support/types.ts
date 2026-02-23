/**
 * @fileoverview Type definitions for the support module.
 * @module components/support/types
 */

// Re-export shared types from central database types
export type { TicketStatus, TicketPriority } from "@/types/database"
import type { TicketStatus, TicketPriority } from "@/types/database"

export type TicketCategory =
  | "technical"
  | "payment"
  | "project"
  | "account"
  | "other"

export interface SupportTicket {
  id: string
  ticket_number: string
  subject: string
  description: string
  category: TicketCategory
  priority: TicketPriority
  status: TicketStatus
  project_id?: string
  project_number?: string
  created_at: string
  updated_at: string
  resolved_at?: string
  last_message_at?: string
  unread_count?: number
}

export interface TicketMessage {
  id: string
  ticket_id: string
  sender_type: "user" | "support"
  sender_name: string
  message: string
  attachments?: TicketAttachment[]
  created_at: string
  is_read: boolean
}

export interface TicketAttachment {
  id: string
  filename: string
  file_url: string
  file_type: string
  file_size: number
}

export interface FAQ {
  id: string
  question: string
  answer: string
  category: string
  order: number
}

export const TICKET_STATUS_CONFIG: Record<
  TicketStatus,
  { label: string; color: string }
> = {
  open: { label: "Open", color: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300" },
  in_progress: { label: "In Progress", color: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300" },
  waiting_response: { label: "Waiting Response", color: "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300" },
  resolved: { label: "Resolved", color: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300" },
  closed: { label: "Closed", color: "bg-gray-100 text-gray-700 dark:bg-gray-900/30 dark:text-gray-300" },
  reopened: { label: "Reopened", color: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300" },
}

export const TICKET_PRIORITY_CONFIG: Record<
  TicketPriority,
  { label: string; color: string }
> = {
  low: { label: "Low", color: "bg-gray-100 text-gray-700" },
  medium: { label: "Medium", color: "bg-blue-100 text-blue-700" },
  high: { label: "High", color: "bg-orange-100 text-orange-700" },
  urgent: { label: "Urgent", color: "bg-red-100 text-red-700" },
}

export const TICKET_CATEGORY_CONFIG: Record<
  TicketCategory,
  { label: string; icon: string }
> = {
  technical: { label: "Technical Issue", icon: "Wrench" },
  payment: { label: "Payment Issue", icon: "CreditCard" },
  project: { label: "Project Related", icon: "Briefcase" },
  account: { label: "Account Issue", icon: "User" },
  other: { label: "Other", icon: "HelpCircle" },
}
