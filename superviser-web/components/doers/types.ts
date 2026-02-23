/**
 * @fileoverview Type definitions for the doers module.
 * @module components/doers/types
 */

/** Represents an expert/doer who completes projects */
export interface Doer {
  id: string
  full_name: string
  email: string
  phone?: string
  avatar_url?: string
  qualification: string
  years_of_experience: number
  skills: string[]
  subjects: string[]
  bio?: string
  rating: number
  total_reviews: number
  total_projects: number
  completed_projects: number
  active_projects: number
  success_rate: number
  total_earnings?: number
  average_response_time?: string
  joined_at: string
  is_available: boolean
  is_verified: boolean
  is_blacklisted?: boolean
  blacklist_reason?: string
  last_active_at?: string
}

/** Review left for a doer on a completed project */
export interface DoerReview {
  id: string
  doer_id: string
  project_id: string
  project_number?: string
  project_title?: string
  reviewer_name: string
  reviewer_type?: "user" | "supervisor"
  rating: number
  comment: string
  created_at: string
}

/** Project assigned to a doer */
export interface DoerProject {
  id: string
  project_number: string
  title: string
  subject?: string
  status: string
  deadline: string
  assigned_at?: string
  completed_at?: string
  user_amount?: number
  doer_payout?: number
  amount?: number
  rating?: number
}

/** Aggregated statistics for a doer */
export interface DoerStats {
  total_earnings: number
  this_month_earnings: number
  average_rating: number
  total_reviews: number
  on_time_delivery_rate: number
  revision_rate: number
  projects_by_subject: { subject: string; count: number }[]
}

/** Filter options for doer status */
export type DoerFilterStatus = "all" | "available" | "busy" | "blacklisted"

/** Sort options for doer listing */
export type DoerSortOption =
  | "name_asc"
  | "name_desc"
  | "rating_high"
  | "rating_low"
  | "projects_high"
  | "projects_low"
  | "earnings_high"
  | "recent"

/** Rating filter options */
export type RatingFilter = "all" | "4plus" | "4_5plus" | "5"
