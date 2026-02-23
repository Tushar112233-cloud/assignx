/**
 * @fileoverview Type definitions for the projects module.
 * @module components/projects/types
 */

// Re-export shared types from central database types
export type { ProjectStatus } from "@/types/database"
import type { ProjectStatus } from "@/types/database"

export interface ActiveProject {
  id: string
  project_number: string
  title: string
  subject: string
  service_type: string
  status: ProjectStatus
  user_name: string
  user_id: string
  doer_name?: string
  doer_id?: string
  deadline: string
  word_count?: number
  page_count?: number
  quoted_amount: number
  doer_payout: number
  supervisor_commission: number
  assigned_at?: string
  submitted_for_qc_at?: string
  delivered_at?: string
  completed_at?: string
  created_at: string
  has_unread_messages?: boolean
  revision_count?: number
}

export interface ProjectFile {
  id: string
  name: string
  size: number
  type: string
  url: string
  uploaded_at: string
  uploaded_by: "user" | "doer" | "supervisor"
}

export interface QCReport {
  plagiarism_score?: number
  ai_score?: number
  grammar_score?: number
  formatting_score?: number
  overall_quality?: "excellent" | "good" | "acceptable" | "needs_revision"
  notes?: string
  checked_at?: string
}

export interface ProjectRevision {
  id: string
  requested_at: string
  requested_by: "supervisor" | "user"
  feedback: string
  status: "pending" | "in_progress" | "completed"
  completed_at?: string
}

export const STATUS_CONFIG: Record<
  ProjectStatus,
  { label: string; color: string; bgColor: string }
> = {
  draft: { label: "Draft", color: "text-gray-600", bgColor: "bg-gray-100" },
  submitted: {
    label: "Submitted",
    color: "text-blue-600",
    bgColor: "bg-blue-100",
  },
  analyzing: {
    label: "Analyzing",
    color: "text-yellow-600",
    bgColor: "bg-yellow-100",
  },
  quoted: {
    label: "Quoted",
    color: "text-purple-600",
    bgColor: "bg-purple-100",
  },
  payment_pending: {
    label: "Payment Pending",
    color: "text-orange-600",
    bgColor: "bg-orange-100",
  },
  paid: { label: "Paid", color: "text-green-600", bgColor: "bg-green-100" },
  assigning: {
    label: "Assigning",
    color: "text-cyan-600",
    bgColor: "bg-cyan-100",
  },
  assigned: {
    label: "Assigned",
    color: "text-blue-600",
    bgColor: "bg-blue-100",
  },
  in_progress: {
    label: "In Progress",
    color: "text-blue-600",
    bgColor: "bg-blue-100",
  },
  submitted_for_qc: {
    label: "For Review",
    color: "text-amber-600",
    bgColor: "bg-amber-100",
  },
  qc_in_progress: {
    label: "QC In Progress",
    color: "text-amber-600",
    bgColor: "bg-amber-100",
  },
  qc_approved: {
    label: "QC Approved",
    color: "text-green-600",
    bgColor: "bg-green-100",
  },
  qc_rejected: {
    label: "QC Rejected",
    color: "text-red-600",
    bgColor: "bg-red-100",
  },
  delivered: {
    label: "Delivered",
    color: "text-green-600",
    bgColor: "bg-green-100",
  },
  revision_requested: {
    label: "Revision Requested",
    color: "text-red-600",
    bgColor: "bg-red-100",
  },
  in_revision: {
    label: "In Revision",
    color: "text-orange-600",
    bgColor: "bg-orange-100",
  },
  completed: {
    label: "Completed",
    color: "text-gray-600",
    bgColor: "bg-gray-100",
  },
  auto_approved: {
    label: "Auto Approved",
    color: "text-green-600",
    bgColor: "bg-green-100",
  },
  cancelled: {
    label: "Cancelled",
    color: "text-gray-600",
    bgColor: "bg-gray-100",
  },
  refunded: {
    label: "Refunded",
    color: "text-gray-600",
    bgColor: "bg-gray-100",
  },
}
