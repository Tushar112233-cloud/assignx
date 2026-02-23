import { z } from "zod";

/**
 * Server-side validation schemas
 * These schemas are used for validating data in server actions
 * They provide stricter validation than client-side schemas
 */

/**
 * Valid user types
 */
export const userTypeSchema = z.enum(["student", "professional", "business"]);

/**
 * Valid service types for projects
 */
export const serviceTypeSchema = z.enum([
  "new_project",
  "proofreading",
  "plagiarism_check",
  "ai_detection",
  "expert_opinion",
]);

/**
 * Profile creation schema
 */
export const createProfileSchema = z.object({
  fullName: z
    .string()
    .min(2, "Name must be at least 2 characters")
    .max(100, "Name must be less than 100 characters")
    .regex(/^[a-zA-Z\s'-]+$/, "Name can only contain letters, spaces, hyphens, and apostrophes"),
  phone: z
    .string()
    .min(7, "Phone must be at least 7 characters")
    .max(20, "Phone must be less than 20 characters")
    .regex(/^\+[0-9]{1,4}[\s\-]?[0-9\s\-()]{4,14}$/, "Invalid phone format")
    .optional(),
  userType: userTypeSchema,
});

export type CreateProfileInput = z.infer<typeof createProfileSchema>;

/**
 * Student profile creation schema
 */
export const createStudentProfileSchema = z.object({
  fullName: z
    .string()
    .min(2, "Name must be at least 2 characters")
    .max(100, "Name must be less than 100 characters"),
  dateOfBirth: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Invalid date format")
    .optional(),
  universityId: z.string().uuid("Invalid university ID"),
  courseId: z.string().uuid("Invalid course ID"),
  semester: z
    .number()
    .int()
    .min(1, "Semester must be at least 1")
    .max(12, "Semester must be at most 12"),
  yearOfStudy: z
    .number()
    .int()
    .min(1)
    .max(6)
    .optional(),
  collegeEmail: z
    .string()
    .email("Invalid email format")
    .optional()
    .or(z.literal("")),
  phone: z
    .string()
    .min(7, "Phone must be at least 7 characters")
    .max(20, "Phone must be less than 20 characters")
    .regex(/^\+[0-9]{1,4}[\s\-]?[0-9\s\-()]{4,14}$/, "Invalid phone format"),
});

export type CreateStudentProfileInput = z.infer<typeof createStudentProfileSchema>;

/**
 * Professional profile creation schema
 */
export const createProfessionalProfileSchema = z.object({
  fullName: z
    .string()
    .min(2, "Name must be at least 2 characters")
    .max(100, "Name must be less than 100 characters"),
  industryId: z.string().uuid("Invalid industry ID"),
  phone: z
    .string()
    .min(7, "Phone must be at least 7 characters")
    .max(20, "Phone must be less than 20 characters")
    .regex(/^\+[0-9]{1,4}[\s\-]?[0-9\s\-()]{4,14}$/, "Invalid phone format"),
});

export type CreateProfessionalProfileInput = z.infer<typeof createProfessionalProfileSchema>;

/**
 * Helper to validate optional string that can be UUID, slug, or empty
 * Accepts: UUID, non-empty string (slug), null, undefined, or empty string
 * Empty strings are converted to null
 */
const optionalIdOrSlug = z
  .string()
  .optional()
  .nullable()
  .transform((val) => (val === "" ? null : val));

/**
 * Project creation schema
 * Note: subjectId and referenceStyleId accept both UUIDs and slugs
 * The createProject function handles the lookup
 */
export const createProjectSchema = z.object({
  serviceType: serviceTypeSchema,
  title: z
    .string()
    .min(5, "Title must be at least 5 characters")
    .max(200, "Title must be less than 200 characters"),
  subjectId: optionalIdOrSlug,
  topic: z.string().max(500, "Topic must be less than 500 characters").optional().nullable(),
  wordCount: z
    .number()
    .int()
    .min(100, "Minimum word count is 100")
    .max(100000, "Maximum word count is 100,000")
    .optional()
    .nullable(),
  referenceStyleId: optionalIdOrSlug,
  deadline: z
    .string()
    .refine((date) => {
      const deadlineDate = new Date(date);
      const now = new Date();
      return deadlineDate > now;
    }, "Deadline must be in the future"),
  urgencyLevel: z.enum(["standard", "express", "urgent"]).optional().nullable(),
  instructions: z
    .string()
    .max(2000, "Instructions must be less than 2000 characters")
    .optional()
    .nullable(),
});

export type CreateProjectInput = z.infer<typeof createProjectSchema>;

/**
 * File upload validation
 */
export const fileUploadSchema = z.object({
  name: z.string().min(1, "File name is required").max(255, "File name too long"),
  type: z.string().refine(
    (type) => {
      const allowedTypes = [
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "image/jpeg",
        "image/png",
        "image/gif",
        "text/plain",
      ];
      return allowedTypes.includes(type);
    },
    "File type not allowed"
  ),
  size: z
    .number()
    .max(10 * 1024 * 1024, "File size must be less than 10MB"),
  base64Data: z.string().min(1, "File data is required"),
});

export type FileUploadInput = z.infer<typeof fileUploadSchema>;

/**
 * Support ticket creation schema
 */
export const createSupportTicketSchema = z.object({
  subject: z
    .string()
    .min(5, "Subject must be at least 5 characters")
    .max(200, "Subject must be less than 200 characters"),
  description: z
    .string()
    .min(20, "Description must be at least 20 characters")
    .max(2000, "Description must be less than 2000 characters"),
  category: z.string().max(50).optional(),
  projectId: z.string().uuid("Invalid project ID").optional(),
});

export type CreateSupportTicketInput = z.infer<typeof createSupportTicketSchema>;
