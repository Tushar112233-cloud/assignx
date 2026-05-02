import { z } from "zod";

/**
 * Professional signup form validation schema
 */
export const professionalFormSchema = z.object({
  fullName: z
    .string()
    .min(2, "Name must be at least 2 characters")
    .max(100, "Name must be less than 100 characters"),
  industryId: z.string().min(1, "Please select your industry"),
  phone: z
    .string()
    .min(7, "Phone number is too short")
    .max(20, "Phone number is too long")
    .regex(/^\+[0-9]{1,4}\s?[0-9\s\-]{4,14}$/, "Please enter a valid phone number with country code"),
  acceptTerms: z.boolean().refine((val) => val === true, {
    message: "You must accept the terms and conditions",
  }),
});

export type ProfessionalFormData = z.infer<typeof professionalFormSchema>;
