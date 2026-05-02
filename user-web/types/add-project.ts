/**
 * Service types for add project flow
 */
export type ServiceType =
  | "project"
  | "proofreading"
  | "report"
  | "consultation";

/**
 * Project types for project creation
 */
export type ProjectType =
  | "assignment"
  | "document"
  | "website"
  | "app"
  | "consultancy";

/**
 * Reference/citation styles
 */
export type ReferenceStyle =
  | "apa7"
  | "harvard"
  | "mla"
  | "chicago"
  | "ieee"
  | "vancouver"
  | "none";

/**
 * Urgency levels for projects
 */
export type UrgencyLevel = "standard" | "express" | "urgent";

/**
 * Report types for AI/Plagiarism check
 */
export type ReportType = "ai" | "plagiarism" | "both";

/**
 * Base form data shared across forms
 */
export interface BaseFormData {
  files?: File[];
}

/**
 * New project form data
 */
export interface ProjectFormData extends BaseFormData {
  projectType: ProjectType;
  subject: string;
  customSubject?: string;
  topic: string;
  deadline: Date;
  urgency: UrgencyLevel;
  instructions?: string;

  // Assignment & Document fields
  wordCount?: number;
  referenceStyle?: ReferenceStyle;
  referenceCount?: number;

  // Document-specific
  documentType?: string;

  // Website-specific
  pageCount?: number;
  techStack?: string;
  websiteFeatures?: string[];
  designReferenceUrl?: string;

  // App-specific
  platform?: string;
  appFeatures?: string;
  appDesignUrl?: string;
  backendRequirements?: string;

  // Consultancy-specific
  consultationDuration?: string;
  questionSummary?: string;
  preferredDate?: string;
  preferredTime?: string;
}

/**
 * Proofreading form data
 */
export interface ProofreadingFormData extends BaseFormData {
  documentType: string;
  wordCount: number;
  turnaroundTime: "24h" | "48h" | "72h";
  additionalNotes?: string;
}

/**
 * Report form data (AI/Plagiarism check)
 */
export interface ReportFormData extends BaseFormData {
  reportType: ReportType;
  documentCount: number;
  wordCountApprox: number;
}

/**
 * Expert consultation form data
 */
export interface ConsultationFormData {
  subject: string;
  topic: string;
  questionSummary: string;
  preferredDate?: Date;
  preferredTime?: string;
}

/**
 * Subject option for dropdowns
 */
export interface SubjectOption {
  id: string;
  name: string;
  icon: string;
}

/**
 * File upload state
 */
export interface UploadedFile {
  id: string;
  file: File;
  name: string;
  size: number;
  type: string;
  progress: number;
  status: "uploading" | "complete" | "error";
  errorMessage?: string;
}

/**
 * Form step for multi-step forms
 */
export interface FormStep {
  id: string;
  title: string;
  description: string;
}

/**
 * Project submission result
 */
export interface SubmissionResult {
  success: boolean;
  projectId?: string;
  projectNumber?: string;
  estimatedPrice?: number;
  message?: string;
  error?: string;
}
