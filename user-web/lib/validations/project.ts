import { z } from "zod";

/**
 * Reference styles enum
 */
export const referenceStyles = [
  { value: "apa7", label: "APA 7th Edition" },
  { value: "harvard", label: "Harvard" },
  { value: "mla", label: "MLA" },
  { value: "chicago", label: "Chicago" },
  { value: "ieee", label: "IEEE" },
  { value: "vancouver", label: "Vancouver" },
  { value: "none", label: "No References" },
] as const;

/**
 * Urgency levels
 */
export const urgencyLevels = [
  { value: "standard", label: "Standard (5-7 days)", multiplier: 1 },
  { value: "express", label: "Express (3-4 days)", multiplier: 1.5 },
  { value: "urgent", label: "Urgent (1-2 days)", multiplier: 2 },
] as const;

/**
 * Step 1: Basic project info
 */
export const projectStep1Schema = z.object({
  subject: z.string().min(1, "Please select a subject"),
  topic: z.string().min(5, "Topic must be at least 5 characters"),
});

/**
 * Step 2: Requirements
 */
export const projectStep2Schema = z.object({
  wordCount: z
    .number()
    .min(250, "Minimum word count is 250")
    .max(50000, "Maximum word count is 50,000"),
  referenceStyle: z.enum([
    "apa7",
    "harvard",
    "mla",
    "chicago",
    "ieee",
    "vancouver",
    "none",
  ]),
  referenceCount: z.number().min(0).max(100).optional(),
});

/**
 * Step 3: Deadline and urgency (form validation)
 * Note: deadline can be undefined in form state but validated before submit
 */
export const projectStep3Schema = z.object({
  deadline: z.date().optional().refine((val) => val !== undefined, {
    message: "Please select a deadline",
  }),
  urgency: z.enum(["standard", "express", "urgent"]),
});

/**
 * Step 4: Additional details and files
 */
export const projectStep4Schema = z.object({
  instructions: z.string().max(2000).optional(),
});

/**
 * Complete project form schema
 */
export const projectFormSchema = projectStep1Schema
  .merge(projectStep2Schema)
  .merge(projectStep3Schema)
  .merge(projectStep4Schema);

export type ProjectFormSchema = z.infer<typeof projectFormSchema>;
export type ProjectStep1Schema = z.infer<typeof projectStep1Schema>;
export type ProjectStep2Schema = z.infer<typeof projectStep2Schema>;
export type ProjectStep3Schema = z.infer<typeof projectStep3Schema>;
export type ProjectStep4Schema = z.infer<typeof projectStep4Schema>;

/**
 * Proofreading form schema
 */
export const proofreadingFormSchema = z.object({
  documentType: z.string().min(1, "Please select document type"),
  wordCount: z
    .number()
    .min(100, "Minimum 100 words")
    .max(100000, "Maximum 100,000 words"),
  turnaroundTime: z.enum(["24h", "48h", "72h"]),
  additionalNotes: z.string().max(500).optional(),
});

export type ProofreadingFormSchema = z.infer<typeof proofreadingFormSchema>;

/**
 * Report form schema
 */
export const reportFormSchema = z.object({
  reportType: z.enum(["ai", "plagiarism", "both"]),
  documentCount: z.number().min(1).max(10),
  wordCountApprox: z.number().min(100).max(100000),
});

export type ReportFormSchema = z.infer<typeof reportFormSchema>;

/**
 * Consultation form schema
 */
export const consultationFormSchema = z.object({
  subject: z.string().min(1, "Please select a subject"),
  topic: z.string().min(5, "Topic must be at least 5 characters"),
  questionSummary: z
    .string()
    .min(20, "Please provide more details (at least 20 characters)")
    .max(1000, "Summary too long (max 1000 characters)"),
  preferredDate: z.date().optional(),
  preferredTime: z.string().optional(),
});

export type ConsultationFormSchema = z.infer<typeof consultationFormSchema>;
