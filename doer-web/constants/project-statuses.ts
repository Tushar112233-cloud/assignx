/**
 * @fileoverview Project status constants and groupings to prevent hard-coded strings throughout the application.
 * @module constants/project-statuses
 */

export const PROJECT_STATUS = {
  DRAFT: "draft",
  SUBMITTED: "submitted",
  ANALYZING: "analyzing",
  QUOTED: "quoted",
  PAYMENT_PENDING: "payment_pending",
  PAID: "paid",
  AVAILABLE: "available",
  ASSIGNING: "assigning",
  ASSIGNED: "assigned",
  IN_PROGRESS: "in_progress",
  SUBMITTED_FOR_QC: "submitted_for_qc",
  QC_IN_PROGRESS: "qc_in_progress",
  QC_APPROVED: "qc_approved",
  QC_REJECTED: "qc_rejected",
  DELIVERED: "delivered",
  REVISION_REQUESTED: "revision_requested",
  IN_REVISION: "in_revision",
  COMPLETED: "completed",
  AUTO_APPROVED: "auto_approved",
  CANCELLED: "cancelled",
  REFUNDED: "refunded",
} as const

export type ProjectStatus = typeof PROJECT_STATUS[keyof typeof PROJECT_STATUS]

/**
 * Status groups for filtering and organizing projects from doer's perspective
 */
export const STATUS_GROUPS = {
  /**
   * Projects that are in the open pool and can be accepted
   */
  AVAILABLE: [PROJECT_STATUS.PAID, PROJECT_STATUS.AVAILABLE],

  /**
   * Projects currently being worked on by the doer
   */
  ACTIVE: [
    PROJECT_STATUS.ASSIGNED,
    PROJECT_STATUS.IN_PROGRESS,
    PROJECT_STATUS.IN_REVISION,
    PROJECT_STATUS.REVISION_REQUESTED,
  ],

  /**
   * Projects submitted for review or quality control
   */
  IN_REVIEW: [
    PROJECT_STATUS.SUBMITTED_FOR_QC,
    PROJECT_STATUS.QC_IN_PROGRESS,
    PROJECT_STATUS.QC_APPROVED,
    PROJECT_STATUS.DELIVERED,
  ],

  /**
   * Successfully completed projects
   */
  COMPLETED: [PROJECT_STATUS.COMPLETED, PROJECT_STATUS.AUTO_APPROVED],

  /**
   * Projects that need revision or have been rejected
   */
  NEEDS_REVISION: [PROJECT_STATUS.REVISION_REQUESTED, PROJECT_STATUS.IN_REVISION],

  /**
   * Projects that are no longer active
   */
  INACTIVE: [PROJECT_STATUS.CANCELLED, PROJECT_STATUS.REFUNDED],
} as const

/**
 * Human-readable status labels
 */
export const STATUS_LABELS: Record<string, string> = {
  [PROJECT_STATUS.DRAFT]: "Draft",
  [PROJECT_STATUS.SUBMITTED]: "Submitted",
  [PROJECT_STATUS.ANALYZING]: "Analyzing",
  [PROJECT_STATUS.QUOTED]: "Quoted",
  [PROJECT_STATUS.PAYMENT_PENDING]: "Payment Pending",
  [PROJECT_STATUS.PAID]: "Paid",
  [PROJECT_STATUS.AVAILABLE]: "Available",
  [PROJECT_STATUS.ASSIGNING]: "Assigning",
  [PROJECT_STATUS.ASSIGNED]: "Assigned",
  [PROJECT_STATUS.IN_PROGRESS]: "In Progress",
  [PROJECT_STATUS.SUBMITTED_FOR_QC]: "Submitted for QC",
  [PROJECT_STATUS.QC_IN_PROGRESS]: "QC in Progress",
  [PROJECT_STATUS.QC_APPROVED]: "QC Approved",
  [PROJECT_STATUS.QC_REJECTED]: "QC Rejected",
  [PROJECT_STATUS.DELIVERED]: "Delivered",
  [PROJECT_STATUS.REVISION_REQUESTED]: "Revision Requested",
  [PROJECT_STATUS.IN_REVISION]: "In Revision",
  [PROJECT_STATUS.COMPLETED]: "Completed",
  [PROJECT_STATUS.AUTO_APPROVED]: "Auto Approved",
  [PROJECT_STATUS.CANCELLED]: "Cancelled",
  [PROJECT_STATUS.REFUNDED]: "Refunded",
}

/**
 * Status colors for UI badges
 */
export const STATUS_COLORS: Record<string, string> = {
  [PROJECT_STATUS.DRAFT]: "bg-gray-100 text-gray-700",
  [PROJECT_STATUS.SUBMITTED]: "bg-blue-100 text-blue-700",
  [PROJECT_STATUS.ANALYZING]: "bg-purple-100 text-purple-700",
  [PROJECT_STATUS.QUOTED]: "bg-indigo-100 text-indigo-700",
  [PROJECT_STATUS.PAYMENT_PENDING]: "bg-amber-100 text-amber-700",
  [PROJECT_STATUS.PAID]: "bg-green-100 text-green-700",
  [PROJECT_STATUS.AVAILABLE]: "bg-green-100 text-green-700",
  [PROJECT_STATUS.ASSIGNING]: "bg-cyan-100 text-cyan-700",
  [PROJECT_STATUS.ASSIGNED]: "bg-cyan-100 text-cyan-700",
  [PROJECT_STATUS.IN_PROGRESS]: "bg-yellow-100 text-yellow-700",
  [PROJECT_STATUS.SUBMITTED_FOR_QC]: "bg-orange-100 text-orange-700",
  [PROJECT_STATUS.QC_IN_PROGRESS]: "bg-orange-100 text-orange-700",
  [PROJECT_STATUS.QC_APPROVED]: "bg-emerald-100 text-emerald-700",
  [PROJECT_STATUS.QC_REJECTED]: "bg-red-100 text-red-700",
  [PROJECT_STATUS.DELIVERED]: "bg-green-100 text-green-700",
  [PROJECT_STATUS.REVISION_REQUESTED]: "bg-red-100 text-red-700",
  [PROJECT_STATUS.IN_REVISION]: "bg-yellow-100 text-yellow-700",
  [PROJECT_STATUS.COMPLETED]: "bg-green-100 text-green-700",
  [PROJECT_STATUS.AUTO_APPROVED]: "bg-green-100 text-green-700",
  [PROJECT_STATUS.CANCELLED]: "bg-gray-100 text-gray-700",
  [PROJECT_STATUS.REFUNDED]: "bg-gray-100 text-gray-700",
}

/**
 * Helper function to check if a status is in a specific group
 */
export function isStatusInGroup(
  status: string,
  group: keyof typeof STATUS_GROUPS
): boolean {
  return (STATUS_GROUPS[group] as readonly string[]).includes(status)
}

/**
 * Helper function to get human-readable label for a status
 */
export function getStatusLabel(status: string): string {
  return STATUS_LABELS[status] || status.replace(/_/g, " ")
}

/**
 * Helper function to get color class for a status
 */
export function getStatusColor(status: string): string {
  return STATUS_COLORS[status] || "bg-gray-100 text-gray-700"
}
