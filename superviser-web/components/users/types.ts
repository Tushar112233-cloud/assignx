/**
 * @fileoverview Type definitions for the users module.
 * @module components/users/types
 */

export interface User {
  id: string
  full_name: string
  email: string
  phone?: string
  avatar_url?: string
  college?: string
  course?: string
  year?: string
  joined_at: string
  last_active_at?: string
  is_verified: boolean
  total_projects: number
  active_projects: number
  completed_projects: number
  total_spent: number
  average_project_value: number
}

export interface UserProject {
  id: string
  project_number: string
  title: string
  subject: string
  service_type: string
  status: string
  deadline: string
  created_at: string
  completed_at?: string
  user_amount: number
  doer_name?: string
  supervisor_name?: string
  rating?: number
}

export interface UserStats {
  total_spent: number
  this_month_spent: number
  average_project_value: number
  projects_by_subject: { subject: string; count: number }[]
  projects_by_status: { status: string; count: number }[]
}

export type UserFilterStatus = "all" | "active" | "inactive"
export type UserSortOption =
  | "name_asc"
  | "name_desc"
  | "projects_high"
  | "projects_low"
  | "spent_high"
  | "spent_low"
  | "recent"
