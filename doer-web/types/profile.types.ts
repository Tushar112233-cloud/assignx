/**
 * Profile and user-related types
 * @module types/profile
 */

import type { UserRole, Qualification, ExperienceLevel } from './common.types'

/**
 * User profile interface
 * Core identity information for all users
 */
export interface Profile {
  /** Unique identifier */
  id: string
  /** User email address */
  email: string
  /** Full display name */
  full_name: string
  /** Phone number (optional) */
  phone: string | null
  /** Whether phone is verified */
  phone_verified: boolean
  /** Profile picture URL */
  avatar_url: string | null
  /** User type in the system */
  user_type: UserRole
  /** Account creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string
}

/**
 * Doer profile interface
 * Extended profile for workers/doers
 */
export interface Doer {
  /** Unique doer identifier */
  id: string
  /** Reference to profile */
  profile_id: string
  /** Educational qualification */
  qualification: Qualification | null
  /** University name */
  university_name: string | null
  /** Skill experience level */
  experience_level: ExperienceLevel | null
  /** Years of experience */
  years_of_experience: number | null
  /** Short biography */
  bio: string | null
  /** Availability status */
  is_available: boolean
  /** Availability updated timestamp */
  availability_updated_at: string | null
  /** Maximum concurrent projects */
  max_concurrent_projects: number
  /** Activation completion status */
  is_activated: boolean
  /** Activation timestamp */
  activated_at: string | null
  /** Lifetime earnings */
  total_earnings: number
  /** Count of completed projects */
  total_projects_completed: number
  /** Average rating (1-5) */
  average_rating: number
  /** Total reviews received */
  total_reviews: number
  /** Success rate percentage */
  success_rate: number
  /** On-time delivery rate percentage */
  on_time_delivery_rate: number
  /** Bank account holder name */
  bank_account_name: string | null
  /** Bank account number */
  bank_account_number: string | null
  /** IFSC code for bank */
  bank_ifsc_code: string | null
  /** Bank name */
  bank_name: string | null
  /** UPI ID for payments */
  upi_id: string | null
  /** Bank verification status */
  bank_verified: boolean
  /** Flag status */
  is_flagged: boolean
  /** Flag reason */
  flag_reason: string | null
  /** Flagged by user ID */
  flagged_by: string | null
  /** Flag timestamp */
  flagged_at: string | null
  /** Creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string
}

/**
 * Skill interface
 * Available skills in the platform
 */
export interface Skill {
  /** Unique identifier */
  id: string
  /** Skill name */
  name: string
  /** Skill category */
  category: string | null
  /** Active status */
  is_active: boolean
}

/**
 * Doer-Skill relationship
 * Links doers to their skills with proficiency
 */
export interface DoerSkill {
  /** Unique identifier */
  id: string
  /** Doer reference */
  doer_id: string
  /** Skill reference */
  skill_id: string
  /** Proficiency level */
  proficiency_level: ExperienceLevel
  /** Verification status */
  is_verified: boolean
}

/**
 * Subject interface
 * Academic subjects for project categorization
 */
export interface Subject {
  /** Unique identifier */
  id: string
  /** Subject name */
  name: string
  /** Parent subject for hierarchy */
  parent_id: string | null
  /** Active status */
  is_active: boolean
}

/**
 * Doer-Subject relationship
 * Links doers to subjects they can work on
 */
export interface DoerSubject {
  /** Unique identifier */
  id: string
  /** Doer reference */
  doer_id: string
  /** Subject reference */
  subject_id: string
}

/**
 * University interface
 * Educational institutions for verification
 */
export interface University {
  /** Unique identifier */
  id: string
  /** University name */
  name: string
  /** City location */
  city: string | null
  /** State/Province */
  state: string | null
  /** Country */
  country: string
  /** Email domain for verification */
  email_domain: string | null
  /** Active status */
  is_active: boolean
}

/**
 * Doer statistics for dashboard
 * Computed summary of performance metrics
 */
export interface DoerStats {
  /** Currently active assignments */
  activeAssignments: number
  /** Total completed projects */
  completedProjects: number
  /** Total lifetime earnings */
  totalEarnings: number
  /** Pending/locked earnings */
  pendingEarnings: number
  /** Average overall rating */
  averageRating: number
  /** Total reviews received */
  totalReviews: number
  /** Project success rate percentage */
  successRate: number
  /** On-time delivery percentage */
  onTimeDeliveryRate: number
  /** Quality rating average */
  qualityRating: number
  /** Timeliness rating average */
  timelinessRating: number
  /** Communication rating average */
  communicationRating: number
}

/**
 * Skill with verification details
 * Extended skill for verification display
 */
export interface SkillWithVerification extends Skill {
  /** Current proficiency level */
  proficiency_level: ExperienceLevel
  /** Verification status */
  is_verified: boolean
  /** Verification timestamp */
  verified_at: string | null
}

/**
 * Doer review from supervisor
 * Rating and feedback for completed work
 */
export interface DoerReview {
  /** Unique identifier */
  id: string
  /** Doer being reviewed */
  doer_id: string
  /** Supervisor who gave review */
  reviewer_id: string
  /** Reviewer display name */
  reviewer_name: string | null
  /** Related project */
  project_id: string
  /** Project title for display */
  project_title: string | null
  /** Quality rating (1-5) */
  quality_rating: number
  /** Timeliness rating (1-5) */
  timeliness_rating: number
  /** Communication rating (1-5) */
  communication_rating: number
  /** Overall rating (1-5) */
  overall_rating: number
  /** Written feedback */
  feedback: string | null
  /** Public visibility */
  is_public: boolean
  /** Review timestamp */
  created_at: string
}
