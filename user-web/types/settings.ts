/**
 * Settings module type definitions
 * Batch 9: Settings & Support
 */

/** App version information */
export interface AppVersion {
  version: string;
  buildNumber: string;
  lastUpdated: string;
}

/** Feedback form data */
export interface FeedbackData {
  type: "bug" | "feature" | "general";
  message: string;
  email?: string;
}

/** Support ticket */
export interface SupportTicket {
  id: string;
  subject: string;
  status: "open" | "in_progress" | "resolved" | "closed";
  createdAt: string;
  updatedAt: string;
  category: string;
}

/** FAQ item */
export interface FAQItem {
  id: string;
  question: string;
  answer: string;
  category: string;
}

/** Contact form data */
export interface ContactFormData {
  name: string;
  email: string;
  subject: string;
  message: string;
  category: "general" | "billing" | "technical" | "account";
}
