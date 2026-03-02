/**
 * Project-related types for task management
 * @module types/project
 */

/**
 * Project status - comprehensive states covering full lifecycle
 * @description Status tracking from creation to completion
 */
export type ProjectStatus =
  | 'draft'              // Not yet published
  | 'submitted'          // Submitted by user
  | 'analyzing'          // Being analyzed
  | 'quoted'             // Quote provided
  | 'payment_pending'    // Awaiting payment
  | 'paid'               // Payment received, in pool
  | 'assigning'          // Being assigned
  | 'assigned'           // Assigned to a doer
  | 'in_progress'        // Doer is actively working
  | 'submitted_for_qc'   // Work submitted for QC
  | 'qc_in_progress'     // QC review in progress
  | 'qc_approved'        // QC approved
  | 'qc_rejected'        // QC rejected
  | 'delivered'          // Delivered to user
  | 'revision_requested' // User requested changes
  | 'in_revision'        // Doer working on revision
  | 'completed'          // Fully completed
  | 'auto_approved'      // Auto-approved after timeout
  | 'cancelled'          // Project cancelled
  | 'refunded'           // Payment refunded

/**
 * Quality control status
 * Status for deliverable review
 */
export type QCStatus = 'pending' | 'in_review' | 'approved' | 'rejected'

/**
 * Service type for projects
 */
export type ServiceType =
  | 'assignment'
  | 'essay'
  | 'research_paper'
  | 'thesis'
  | 'dissertation'
  | 'case_study'
  | 'presentation'
  | 'lab_report'
  | 'other'

/**
 * Project interface
 * Core project/task data matching database schema
 */
export interface Project {
  /** Unique identifier */
  id: string
  /** Human-readable project number */
  project_number: string | null
  /** Client user ID */
  user_id: string
  /** Type of service */
  service_type: ServiceType | null
  /** Project title */
  title: string
  /** Subject category reference */
  subject_id: string | null
  /** Topic of the project */
  topic: string | null
  /** Detailed description */
  description: string | null
  /** Required word count */
  word_count: number | null
  /** Required page count */
  page_count: number | null
  /** Reference style ID */
  reference_style_id: string | null
  /** Additional instructions */
  specific_instructions: string | null
  /** Focus areas */
  focus_areas: string[] | null
  /** Deadline timestamp */
  deadline: string
  /** Original deadline */
  original_deadline: string | null
  /** Whether deadline was extended */
  deadline_extended: boolean
  /** Reason for deadline extension */
  deadline_extension_reason: string | null
  /** Current status */
  status: ProjectStatus
  /** Status updated timestamp */
  status_updated_at: string | null
  /** Assigned supervisor ID */
  supervisor_id: string | null
  /** Supervisor assignment timestamp */
  supervisor_assigned_at: string | null
  /** Assigned doer ID */
  doer_id: string | null
  /** Doer assignment timestamp */
  doer_assigned_at: string | null
  /** Quote for user */
  user_quote: number | null
  /** Payout for doer */
  doer_payout: number | null
  /** Supervisor commission */
  supervisor_commission: number | null
  /** Platform fee */
  platform_fee: number | null
  /** Payment status */
  is_paid: boolean
  /** Payment timestamp */
  paid_at: string | null
  /** Payment reference ID */
  payment_id: string | null
  /** Delivery timestamp */
  delivered_at: string | null
  /** Expected delivery timestamp */
  expected_delivery_at: string | null
  /** Auto-approval timestamp */
  auto_approve_at: string | null
  /** AI report URL */
  ai_report_url: string | null
  /** AI detection score */
  ai_score: number | null
  /** Plagiarism report URL */
  plagiarism_report_url: string | null
  /** Plagiarism score */
  plagiarism_score: number | null
  /** Live document URL */
  live_document_url: string | null
  /** Progress percentage */
  progress_percentage: number | null
  /** Completion timestamp */
  completed_at: string | null
  /** Completion notes */
  completion_notes: string | null
  /** User approval status */
  user_approved: boolean | null
  /** User approval timestamp */
  user_approved_at: string | null
  /** User feedback */
  user_feedback: string | null
  /** User grade received */
  user_grade: string | null
  /** Cancellation timestamp */
  cancelled_at: string | null
  /** Cancelled by user ID */
  cancelled_by: string | null
  /** Cancellation reason */
  cancellation_reason: string | null
  /** Source of project */
  source: string | null
  /** Creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string

  // Computed/joined fields (optional - populated via queries)
  /** Subject name (from subjects table join) */
  subject_name?: string
  /** Supervisor name (from profiles table join) */
  supervisor_name?: string
  /** Doer name (from profiles table join) */
  doer_name?: string
  /** Price - alias for doer_payout for component compatibility */
  price?: number
}

/**
 * Project file interface
 * Files attached to projects
 */
export interface ProjectFile {
  /** Unique identifier */
  id: string
  /** Parent project */
  project_id: string
  /** Original file name */
  file_name: string
  /** Storage URL */
  file_url: string
  /** MIME type */
  file_type: string | null
  /** Size in bytes */
  file_size_bytes: number | null
  /** File category (reference, deliverable, user_upload, etc.) */
  file_category: string
  /** Uploader ID */
  uploaded_by: string
  /** Creation timestamp */
  created_at: string
}

/**
 * Project deliverable interface
 * Submitted work files
 * DB columns: id, project_id, uploaded_by, file_name, file_url, file_type,
 * file_size_bytes, version, qc_status, qc_notes, qc_at, qc_by, created_at
 */
export interface ProjectDeliverable {
  /** Unique identifier */
  id: string
  /** Parent project */
  project_id: string
  /** Submitting doer's profile ID */
  uploaded_by: string
  /** File name */
  file_name: string
  /** Storage URL */
  file_url: string
  /** MIME type */
  file_type: string | null
  /** Size in bytes */
  file_size_bytes: number | null
  /** Version number */
  version: number
  /** QC status */
  qc_status: QCStatus
  /** QC reviewer notes */
  qc_notes: string | null
  /** Submission / creation timestamp */
  created_at: string
  /** QC review timestamp */
  qc_at: string | null
  /** QC reviewer ID */
  qc_by: string | null
}

/**
 * Project revision interface
 * Revision request details
 * DB columns: id, project_id, requested_by, requested_by_type, revision_number,
 * feedback, specific_changes, response_notes, status, created_at, completed_at
 */
export interface ProjectRevision {
  /** Unique identifier */
  id: string
  /** Parent project */
  project_id: string
  /** Requester ID */
  requested_by: string
  /** Type of requester (user, supervisor, etc.) */
  requested_by_type: string | null
  /** Revision sequence number */
  revision_number: number
  /** General feedback from requester */
  feedback: string | null
  /** Specific changes requested */
  specific_changes: string | null
  /** Notes from the doer's response */
  response_notes: string | null
  /** Current status */
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled'
  /** Creation timestamp */
  created_at: string
  /** Completion timestamp */
  completed_at: string | null
}
