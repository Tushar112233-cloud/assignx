/**
 * @fileoverview Zod validation schemas for authentication and registration forms.
 * @module lib/validations/auth
 */

import { z } from "zod"

export const loginSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
})

export type LoginFormData = z.infer<typeof loginSchema>

export const registerCredentialsSchema = z.object({
  fullName: z.string().min(2, "Full name must be at least 2 characters"),
  email: z.string().email("Please enter a valid email address"),
  phone: z.string().regex(/^\+?[1-9]\d{9,14}$/, "Please enter a valid phone number"),
  password: z.string().min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
    .regex(/[a-z]/, "Password must contain at least one lowercase letter")
    .regex(/[0-9]/, "Password must contain at least one number"),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords do not match",
  path: ["confirmPassword"],
})

export type RegisterCredentialsFormData = z.infer<typeof registerCredentialsSchema>

export const professionalProfileSchema = z.object({
  qualification: z.string().min(2, "Please enter your qualification"),
  yearsOfExperience: z.number().min(0).max(50),
  expertiseAreas: z.array(z.string()).min(1, "Please select at least one area of expertise"),
  bio: z.string().max(500, "Bio must be less than 500 characters").optional(),
  cvFile: z.any().optional(),
})

export type ProfessionalProfileFormData = z.infer<typeof professionalProfileSchema>

export const bankingSchema = z.object({
  bankName: z.string().min(2, "Please enter your bank name"),
  accountNumber: z.string().min(9, "Please enter a valid account number").max(18),
  ifscCode: z.string().regex(/^[A-Z]{4}0[A-Z0-9]{6}$/, "Please enter a valid IFSC code"),
  upiId: z.string().regex(/^[\w.-]+@[\w]+$/, "Please enter a valid UPI ID").optional().or(z.literal("")),
})

export type BankingFormData = z.infer<typeof bankingSchema>
