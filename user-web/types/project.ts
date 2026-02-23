/**
 * Project status types for the My Projects module
 * @see database.md for full enum definition
 */
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
  | "refunded";

/**
 * Tab types for project filtering
 */
export type ProjectTab = "in_review" | "in_progress" | "for_review" | "history";

/**
 * Status to tab mapping
 */
export const STATUS_TO_TAB: Record<ProjectStatus, ProjectTab> = {
  draft: "in_review",
  submitted: "in_review",
  analyzing: "in_review",
  quoted: "in_review",
  payment_pending: "in_review",
  paid: "in_progress",
  assigning: "in_progress",
  assigned: "in_progress",
  in_progress: "in_progress",
  qc_rejected: "in_progress",
  in_revision: "in_progress",
  submitted_for_qc: "for_review",
  qc_in_progress: "for_review",
  qc_approved: "for_review",
  delivered: "for_review",
  revision_requested: "for_review",
  auto_approved: "for_review",
  completed: "history",
  cancelled: "history",
  refunded: "history",
};

/**
 * Tab to status list mapping
 */
export const TAB_STATUSES: Record<ProjectTab, ProjectStatus[]> = {
  in_review: ["draft", "submitted", "analyzing", "quoted", "payment_pending"],
  in_progress: [
    "paid",
    "assigning",
    "assigned",
    "in_progress",
    "qc_rejected",
    "in_revision",
  ],
  for_review: [
    "submitted_for_qc",
    "qc_in_progress",
    "qc_approved",
    "delivered",
    "revision_requested",
    "auto_approved",
  ],
  history: ["completed", "cancelled", "refunded"],
};

/**
 * Status configuration for display
 */
export interface StatusConfig {
  label: string;
  color: "yellow" | "orange" | "blue" | "green" | "gray" | "red";
  bgClass: string;
  textClass: string;
  borderClass: string;
}

/**
 * Status display configuration
 */
export const STATUS_CONFIG: Record<ProjectStatus, StatusConfig> = {
  draft: {
    label: "Draft",
    color: "gray",
    bgClass: "bg-muted",
    textClass: "text-muted-foreground",
    borderClass: "border-border",
  },
  submitted: {
    label: "Submitted",
    color: "yellow",
    bgClass: "bg-yellow-100 dark:bg-yellow-900/30",
    textClass: "text-yellow-700 dark:text-yellow-400",
    borderClass: "border-yellow-200 dark:border-yellow-800",
  },
  analyzing: {
    label: "Analyzing Requirements...",
    color: "yellow",
    bgClass: "bg-yellow-100 dark:bg-yellow-900/30",
    textClass: "text-yellow-700 dark:text-yellow-400",
    borderClass: "border-yellow-200 dark:border-yellow-800",
  },
  quoted: {
    label: "Quote Ready",
    color: "yellow",
    bgClass: "bg-yellow-100 dark:bg-yellow-900/30",
    textClass: "text-yellow-700 dark:text-yellow-400",
    borderClass: "border-yellow-200 dark:border-yellow-800",
  },
  payment_pending: {
    label: "Payment Pending",
    color: "orange",
    bgClass: "bg-orange-100 dark:bg-orange-900/30",
    textClass: "text-orange-700 dark:text-orange-400",
    borderClass: "border-orange-200 dark:border-orange-800",
  },
  paid: {
    label: "Payment Confirmed",
    color: "blue",
    bgClass: "bg-blue-100 dark:bg-blue-900/30",
    textClass: "text-blue-700 dark:text-blue-400",
    borderClass: "border-blue-200 dark:border-blue-800",
  },
  assigning: {
    label: "Finding Expert...",
    color: "blue",
    bgClass: "bg-blue-100 dark:bg-blue-900/30",
    textClass: "text-blue-700 dark:text-blue-400",
    borderClass: "border-blue-200 dark:border-blue-800",
  },
  assigned: {
    label: "Expert Assigned",
    color: "blue",
    bgClass: "bg-blue-100 dark:bg-blue-900/30",
    textClass: "text-blue-700 dark:text-blue-400",
    borderClass: "border-blue-200 dark:border-blue-800",
  },
  in_progress: {
    label: "In Progress",
    color: "blue",
    bgClass: "bg-blue-100 dark:bg-blue-900/30",
    textClass: "text-blue-700 dark:text-blue-400",
    borderClass: "border-blue-200 dark:border-blue-800",
  },
  submitted_for_qc: {
    label: "Submitted for QC",
    color: "yellow",
    bgClass: "bg-yellow-100 dark:bg-yellow-900/30",
    textClass: "text-yellow-700 dark:text-yellow-400",
    borderClass: "border-yellow-200 dark:border-yellow-800",
  },
  qc_in_progress: {
    label: "QC In Progress",
    color: "yellow",
    bgClass: "bg-yellow-100 dark:bg-yellow-900/30",
    textClass: "text-yellow-700 dark:text-yellow-400",
    borderClass: "border-yellow-200 dark:border-yellow-800",
  },
  qc_approved: {
    label: "QC Approved",
    color: "green",
    bgClass: "bg-green-100 dark:bg-green-900/30",
    textClass: "text-green-700 dark:text-green-400",
    borderClass: "border-green-200 dark:border-green-800",
  },
  qc_rejected: {
    label: "QC Rejected - Revising",
    color: "red",
    bgClass: "bg-red-100 dark:bg-red-900/30",
    textClass: "text-red-700 dark:text-red-400",
    borderClass: "border-red-200 dark:border-red-800",
  },
  delivered: {
    label: "Files Ready - Review",
    color: "green",
    bgClass: "bg-green-100 dark:bg-green-900/30",
    textClass: "text-green-700 dark:text-green-400",
    borderClass: "border-green-200 dark:border-green-800",
  },
  revision_requested: {
    label: "Revision Requested",
    color: "orange",
    bgClass: "bg-orange-100 dark:bg-orange-900/30",
    textClass: "text-orange-700 dark:text-orange-400",
    borderClass: "border-orange-200 dark:border-orange-800",
  },
  in_revision: {
    label: "In Revision",
    color: "blue",
    bgClass: "bg-blue-100 dark:bg-blue-900/30",
    textClass: "text-blue-700 dark:text-blue-400",
    borderClass: "border-blue-200 dark:border-blue-800",
  },
  completed: {
    label: "Completed",
    color: "gray",
    bgClass: "bg-muted",
    textClass: "text-muted-foreground",
    borderClass: "border-border",
  },
  auto_approved: {
    label: "Auto Approved",
    color: "green",
    bgClass: "bg-green-100 dark:bg-green-900/30",
    textClass: "text-green-700 dark:text-green-400",
    borderClass: "border-green-200 dark:border-green-800",
  },
  cancelled: {
    label: "Cancelled",
    color: "red",
    bgClass: "bg-red-100 dark:bg-red-900/30",
    textClass: "text-red-700 dark:text-red-400",
    borderClass: "border-red-200 dark:border-red-800",
  },
  refunded: {
    label: "Refunded",
    color: "gray",
    bgClass: "bg-muted",
    textClass: "text-muted-foreground",
    borderClass: "border-border",
  },
};

/**
 * Project timeline milestone
 */
export interface TimelineMilestone {
  id: string;
  label: string;
  status: "completed" | "current" | "pending";
  date?: string;
}

/**
 * Project data structure
 * Compatible with both camelCase (legacy) and snake_case (database) fields
 */
export interface Project {
  id: string;
  // Primary fields (either camelCase or snake_case)
  projectNumber?: string;
  project_number?: string;
  title: string;
  subjectId?: string;
  subject_id?: string | null;
  subjectName?: string;
  subjectIcon?: string;
  status: ProjectStatus;
  progress?: number;
  progress_percentage?: number;
  deadline?: string | null;
  createdAt?: string;
  created_at?: string;
  wordCount?: number;
  word_count?: number | null;
  referenceStyle?: string;
  quoteAmount?: number;
  final_quote?: number | null;
  user_quote?: number | null;
  deliveredAt?: string;
  delivered_at?: string | null;
  autoApprovalDeadline?: string;
  completedAt?: string;
  completed_at?: string | null;
  cancelledAt?: string;
  cancelled_at?: string | null;
  refundedAt?: string;
  // Joined relations
  subject?: {
    id: string;
    name: string;
    icon: string;
    slug?: string;
  } | null;
  reference_style?: {
    id: string;
    name: string;
    version?: string;
  } | null;
}

/**
 * Attached file uploaded by user
 */
export interface AttachedFile {
  id: string;
  name: string;
  size: string;
  type: "pdf" | "doc" | "docx" | "image";
  uploadedAt: string;
  url?: string;
}

/**
 * Deliverable file from expert
 */
export interface Deliverable {
  id: string;
  name: string;
  size: string;
  version: number;
  uploadedAt: string;
  isFinal: boolean;
  url?: string;
}

/**
 * Quality report (AI detection or plagiarism)
 */
export interface QualityReport {
  type: "ai" | "plagiarism";
  status: "locked" | "passed" | "available";
  score?: number;
  reportUrl?: string;
}

/**
 * Chat message in project conversation
 */
export interface ChatMessage {
  id: string;
  sender: "user" | "supervisor";
  senderName: string;
  message: string;
  timestamp: string;
}

/**
 * Extended project detail with all related data
 */
export interface ProjectDetail extends Project {
  instructions: string;
  budget?: string;
  attachedFiles: AttachedFile[];
  deliverables: Deliverable[];
  qualityReports: QualityReport[];
  chatMessages: ChatMessage[];
  liveDocUrl?: string;
  supervisorName?: string;
  unreadMessages?: number;
  paidAt?: string;
  paid_at?: string | null;
}
