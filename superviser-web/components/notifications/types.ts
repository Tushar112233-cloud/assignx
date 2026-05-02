/**
 * @fileoverview Type definitions for the notifications module.
 * @module components/notifications/types
 */

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

export interface Notification {
  id: string
  type: NotificationType
  title: string
  message: string
  project_id?: string
  project_number?: string
  action_url?: string
  is_read: boolean
  created_at: string
}

export interface NotificationGroup {
  date: string
  notifications: Notification[]
}

export const NOTIFICATION_TYPE_CONFIG: Record<
  NotificationType,
  { label: string; color: string; icon: string }
> = {
  project_submitted: {
    label: "New Project",
    color: "text-blue-600",
    icon: "FileText",
  },
  quote_ready: {
    label: "Quote Ready",
    color: "text-amber-600",
    icon: "FileCheck",
  },
  payment_received: {
    label: "Payment",
    color: "text-green-600",
    icon: "IndianRupee",
  },
  project_assigned: {
    label: "Assigned",
    color: "text-blue-600",
    icon: "UserPlus",
  },
  task_available: {
    label: "Task Available",
    color: "text-purple-600",
    icon: "Briefcase",
  },
  task_assigned: {
    label: "Task Assigned",
    color: "text-blue-600",
    icon: "CheckCircle",
  },
  work_submitted: {
    label: "Work Submitted",
    color: "text-amber-600",
    icon: "Upload",
  },
  qc_approved: {
    label: "QC Approved",
    color: "text-green-600",
    icon: "CheckCircle2",
  },
  qc_rejected: {
    label: "QC Rejected",
    color: "text-red-600",
    icon: "XCircle",
  },
  revision_requested: {
    label: "Revision",
    color: "text-orange-600",
    icon: "RotateCcw",
  },
  project_delivered: {
    label: "Delivered",
    color: "text-green-600",
    icon: "Send",
  },
  project_completed: {
    label: "Completed",
    color: "text-green-600",
    icon: "CheckCircle2",
  },
  new_message: {
    label: "Message",
    color: "text-blue-600",
    icon: "MessageSquare",
  },
  payout_processed: {
    label: "Payout",
    color: "text-green-600",
    icon: "Wallet",
  },
  system_alert: {
    label: "System",
    color: "text-gray-600",
    icon: "AlertCircle",
  },
  promotional: {
    label: "Promo",
    color: "text-purple-600",
    icon: "Gift",
  },
}
