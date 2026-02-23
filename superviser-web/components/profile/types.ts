/**
 * @fileoverview Type definitions for the profile module.
 * @module components/profile/types
 */

export interface SupervisorProfile {
  id: string
  full_name: string
  email: string
  phone: string
  avatar_url?: string
  qualification: string
  years_of_experience: number
  expertise_areas: string[]
  bio?: string
  rating: number
  total_reviews: number
  joined_at: string
  is_available: boolean
  bank_details: BankDetails
}

export interface BankDetails {
  bank_name: string
  account_number: string
  ifsc_code: string
  upi_id?: string
  account_holder_name: string
}

export interface ProfileStats {
  active_projects: number
  completed_projects: number
  pending_qc: number
  success_rate: number
  total_earnings: number
  this_month_earnings: number
  average_response_time: string
  client_satisfaction: number
}

export interface PerformanceMetric {
  label: string
  value: number
  target: number
  unit?: string
  trend?: "up" | "down" | "stable"
  change_percentage?: number
}

export interface SupervisorReview {
  id: string
  project_id: string
  project_title: string
  client_name: string
  client_avatar?: string
  rating: number
  comment: string
  created_at: string
  response?: string
  responded_at?: string
}

export interface ReviewStats {
  average_rating: number
  total_reviews: number
  rating_distribution: {
    1: number
    2: number
    3: number
    4: number
    5: number
  }
  recent_reviews: SupervisorReview[]
}

export interface BlacklistedDoer {
  id: string
  doer_id: string
  doer_name: string
  doer_avatar?: string
  doer_rating: number
  reason: string
  blacklisted_at: string
  project_id?: string
  project_title?: string
}

export interface Transaction {
  id: string
  type: TransactionType
  amount: number
  description: string
  project_id?: string
  project_title?: string
  status: "pending" | "completed" | "failed"
  created_at: string
  reference_id?: string
}

export type TransactionType =
  | "project_earning"
  | "commission"
  | "bonus"
  | "withdrawal"
  | "refund"
  | "penalty"

export interface EarningsData {
  period: string
  earnings: number
  projects_completed: number
  commission: number
}

export interface EarningsSummary {
  total_earnings: number
  total_commission: number
  pending_payout: number
  last_payout_date?: string
  last_payout_amount?: number
  monthly_earnings: EarningsData[]
  weekly_earnings: EarningsData[]
}

export interface CommissionBreakdown {
  project_id: string
  project_title: string
  user_amount: number
  doer_payout: number
  supervisor_commission: number
  platform_fee: number
  completed_at: string
}

export interface SupportContact {
  type: "email" | "phone" | "chat"
  value: string
  label: string
  available_hours?: string
}
