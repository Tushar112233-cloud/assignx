import { z } from 'zod'

export const doerEmailNameSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  fullName: z.string().min(2, 'Full name must be at least 2 characters'),
})

export const doerProfileSchema = z.object({
  qualification: z.string().min(1, 'Please select your qualification'),
  experienceLevel: z.string().min(1, 'Please select your experience level'),
  skills: z.array(z.string()).min(1, 'Please select at least one skill area'),
  bio: z.string().max(500, 'Bio must be less than 500 characters').optional(),
})

export const doerBankingSchema = z.object({
  bankName: z.string().min(2, 'Please select your bank'),
  accountNumber: z.string().min(9, 'Please enter a valid account number').max(18),
  ifscCode: z.string().regex(/^[A-Z]{4}0[A-Z0-9]{6}$/, 'Please enter a valid IFSC code'),
  upiId: z.string().regex(/^[\w.-]+@[\w]+$/, 'Please enter a valid UPI ID').optional().or(z.literal('')),
})

export type DoerEmailNameData = z.infer<typeof doerEmailNameSchema>
export type DoerProfileData = z.infer<typeof doerProfileSchema>
export type DoerBankingData = z.infer<typeof doerBankingSchema>

export const INDIAN_BANKS = [
  { value: 'sbi', label: 'State Bank of India' },
  { value: 'hdfc', label: 'HDFC Bank' },
  { value: 'icici', label: 'ICICI Bank' },
  { value: 'axis', label: 'Axis Bank' },
  { value: 'kotak', label: 'Kotak Mahindra Bank' },
  { value: 'pnb', label: 'Punjab National Bank' },
  { value: 'bob', label: 'Bank of Baroda' },
  { value: 'canara', label: 'Canara Bank' },
  { value: 'union', label: 'Union Bank of India' },
  { value: 'idbi', label: 'IDBI Bank' },
  { value: 'indusind', label: 'IndusInd Bank' },
  { value: 'yes', label: 'Yes Bank' },
  { value: 'other', label: 'Other' },
] as const

export const SKILL_AREAS = [
  { value: 'engineering', label: 'Engineering' },
  { value: 'computer_science', label: 'Computer Science' },
  { value: 'mathematics', label: 'Mathematics' },
  { value: 'physics', label: 'Physics' },
  { value: 'chemistry', label: 'Chemistry' },
  { value: 'biology', label: 'Biology' },
  { value: 'business', label: 'Business' },
  { value: 'finance', label: 'Finance' },
  { value: 'economics', label: 'Economics' },
  { value: 'literature', label: 'Literature' },
  { value: 'arts', label: 'Arts & Design' },
  { value: 'education', label: 'Education' },
  { value: 'data_entry', label: 'Data Entry' },
  { value: 'research', label: 'Research' },
  { value: 'writing', label: 'Writing' },
  { value: 'translation', label: 'Translation' },
] as const
