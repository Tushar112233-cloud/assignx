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
 * Project types
 */
export const projectTypes = [
  { value: "assignment", label: "Assignment" },
  { value: "document", label: "Document" },
  { value: "website", label: "Website" },
  { value: "app", label: "App" },
  { value: "consultancy", label: "Consultancy" },
] as const;

/**
 * Step 1: Base object schema (used for merge in full form schema)
 */
export const projectStep1BaseSchema = z.object({
  projectType: z.enum(
    ["assignment", "document", "website", "app", "consultancy"],
    { message: "Please select a project type" }
  ),
  subject: z.string().min(1, "Please select a subject"),
  customSubject: z.string().optional(),
  topic: z.string().min(5, "Topic must be at least 5 characters"),
});

/**
 * Step 1: Basic project info with custom subject refinement
 */
export const projectStep1Schema = projectStep1BaseSchema.refine(
  (data) => {
    if (data.subject === "other") {
      return !!data.customSubject && data.customSubject.trim().length >= 2;
    }
    return true;
  },
  {
    message: "Please enter your subject name (at least 2 characters)",
    path: ["customSubject"],
  }
);

/**
 * Document types for document project type
 */
export const documentTypes = [
  { value: "essay", label: "Essay" },
  { value: "report", label: "Report" },
  { value: "thesis", label: "Thesis / Dissertation" },
  { value: "case-study", label: "Case Study" },
  { value: "research-paper", label: "Research Paper" },
  { value: "literature-review", label: "Literature Review" },
  { value: "other", label: "Other" },
] as const;

/**
 * Tech stack options for website projects
 */
export const techStackOptions = [
  { value: "react", label: "React / Next.js" },
  { value: "wordpress", label: "WordPress" },
  { value: "html-css", label: "HTML / CSS / JS" },
  { value: "vue", label: "Vue / Nuxt" },
  { value: "custom", label: "Custom / Other" },
] as const;

/**
 * Website feature options
 */
export const websiteFeatureOptions = [
  { value: "responsive", label: "Responsive Design" },
  { value: "seo", label: "SEO Optimization" },
  { value: "contact-form", label: "Contact Form" },
  { value: "blog", label: "Blog Section" },
  { value: "ecommerce", label: "E-commerce" },
  { value: "auth", label: "User Authentication" },
  { value: "cms", label: "Content Management" },
  { value: "analytics", label: "Analytics Integration" },
] as const;

/**
 * Platform options for app projects
 */
export const platformOptions = [
  { value: "ios", label: "iOS" },
  { value: "android", label: "Android" },
  { value: "both", label: "iOS & Android" },
  { value: "web-app", label: "Web App" },
] as const;

/**
 * Consultation duration options
 */
export const consultationDurations = [
  { value: "30min", label: "30 Minutes" },
  { value: "1hr", label: "1 Hour" },
  { value: "2hr", label: "2 Hours" },
] as const;

/**
 * Step 2: Requirements base schema (all fields present, most optional)
 * Validation is conditional based on projectType passed at runtime
 */
export const projectStep2BaseSchema = z.object({
  // Assignment & Document fields
  wordCount: z.number().min(250).max(50000).optional(),
  referenceStyle: z
    .enum(["apa7", "harvard", "mla", "chicago", "ieee", "vancouver", "none"])
    .optional(),
  referenceCount: z.number().min(0).max(100).optional(),

  // Document-specific
  documentType: z.string().optional(),

  // Website-specific
  pageCount: z.number().min(1).max(50).optional(),
  techStack: z.string().optional(),
  websiteFeatures: z.array(z.string()).optional(),
  designReferenceUrl: z.string().url("Please enter a valid URL").or(z.literal("")).optional(),

  // App-specific
  platform: z.string().optional(),
  appFeatures: z.string().max(2000).optional(),
  appDesignUrl: z.string().url("Please enter a valid URL").or(z.literal("")).optional(),
  backendRequirements: z.string().max(1000).optional(),

  // Consultancy-specific
  consultationDuration: z.string().optional(),
  questionSummary: z.string().max(1000).optional(),
  preferredDate: z.string().optional(),
  preferredTime: z.string().optional(),
});

/**
 * Creates a step 2 schema with conditional validation based on project type.
 * Used at runtime by the form's zodResolver.
 */
export function createStep2Schema(projectType: string) {
  return projectStep2BaseSchema.superRefine((data, ctx) => {
    switch (projectType) {
      case "assignment":
        if (!data.wordCount || data.wordCount < 250) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Word count is required (minimum 250)",
            path: ["wordCount"],
          });
        }
        if (!data.referenceStyle) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Please select a reference style",
            path: ["referenceStyle"],
          });
        }
        break;

      case "document":
        if (!data.documentType) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Please select a document type",
            path: ["documentType"],
          });
        }
        if (!data.wordCount || data.wordCount < 250) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Word count is required (minimum 250)",
            path: ["wordCount"],
          });
        }
        if (!data.referenceStyle) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Please select a reference style",
            path: ["referenceStyle"],
          });
        }
        break;

      case "website":
        if (!data.pageCount || data.pageCount < 1) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Number of pages is required (minimum 1)",
            path: ["pageCount"],
          });
        }
        break;

      case "app":
        if (!data.platform) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Please select a platform",
            path: ["platform"],
          });
        }
        if (!data.appFeatures || data.appFeatures.trim().length < 10) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Please describe key features (at least 10 characters)",
            path: ["appFeatures"],
          });
        }
        break;

      case "consultancy":
        if (!data.consultationDuration) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Please select a consultation duration",
            path: ["consultationDuration"],
          });
        }
        if (!data.questionSummary || data.questionSummary.trim().length < 20) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Please describe your question (at least 20 characters)",
            path: ["questionSummary"],
          });
        }
        break;
    }
  });
}

/**
 * Step 2: Requirements (backward-compatible default for assignment type)
 */
export const projectStep2Schema = projectStep2BaseSchema;

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
 * Expert qualification options for consultancy projects
 */
export const expertQualifications = [
  { value: "phd", label: "PhD" },
  { value: "professor", label: "Professor" },
  { value: "industry-expert", label: "Industry Expert" },
  { value: "any", label: "Any" },
] as const;

/**
 * Step 4: Additional details and files
 * Includes optional type-specific fields from the instructions step
 */
export const projectStep4Schema = z.object({
  instructions: z.string().max(2000).optional(),
  colorScheme: z.string().max(200).optional(),
  targetAudience: z.string().max(500).optional(),
  expertQualification: z.enum(["phd", "professor", "industry-expert", "any"]).optional(),
});

/**
 * Complete project form schema
 */
export const projectFormSchema = projectStep1BaseSchema
  .merge(projectStep2BaseSchema)
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
