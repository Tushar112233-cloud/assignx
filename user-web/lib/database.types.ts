/**
 * Database Types for AssignX New Features
 *
 * This file contains TypeScript type definitions for the new database tables:
 * - Colleges (campus verification)
 * - Campus Posts (Campus Pulse feature)
 * - Campus Interactions (likes, comments, saves)
 * - Experts (1:1 consultation)
 * - Expert Bookings (session bookings)
 *
 * @module lib/database.types
 */

// ============================================================================
// ENUMS
// ============================================================================

/**
 * Campus post categories
 */
export type CampusPostCategory =
  | 'events'
  | 'opportunities'
  | 'resources'
  | 'lost_found'
  | 'marketplace'
  | 'housing'
  | 'rides'
  | 'study_groups'
  | 'clubs'
  | 'announcements'
  | 'discussions'
  | 'questions';

/**
 * Expert consultation categories
 */
export type ExpertCategory =
  | 'academic'
  | 'career'
  | 'research'
  | 'technology'
  | 'entrepreneurship'
  | 'finance'
  | 'mental_health'
  | 'fitness'
  | 'language'
  | 'arts'
  | 'law'
  | 'other';

/**
 * Expert verification status
 */
export type ExpertVerificationStatus =
  | 'pending'
  | 'under_review'
  | 'verified'
  | 'rejected'
  | 'suspended';

/**
 * Booking status
 */
export type ExpertBookingStatus =
  | 'pending'
  | 'confirmed'
  | 'in_progress'
  | 'completed'
  | 'cancelled'
  | 'rejected'
  | 'no_show'
  | 'rescheduled';

/**
 * Payment status
 */
export type ExpertPaymentStatus =
  | 'pending'
  | 'authorized'
  | 'captured'
  | 'refunded'
  | 'partially_refunded'
  | 'failed';

/**
 * Campus post status
 */
export type CampusPostStatus = 'draft' | 'active' | 'closed' | 'archived' | 'deleted';

/**
 * College type
 */
export type CollegeType = 'university' | 'college' | 'institute' | 'autonomous';

/**
 * Report reasons
 */
export type ReportReason =
  | 'spam'
  | 'inappropriate'
  | 'harassment'
  | 'hate_speech'
  | 'misinformation'
  | 'scam'
  | 'off_topic'
  | 'other';

/**
 * Report status
 */
export type ReportStatus = 'pending' | 'reviewed' | 'resolved' | 'dismissed';

// ============================================================================
// COLLEGES
// ============================================================================

/**
 * College record from database
 */
export interface College {
  id: string;
  name: string;
  short_name: string | null;
  domain: string | null;
  logo_url: string | null;
  city: string | null;
  state: string | null;
  country: string;
  address: string | null;
  website: string | null;
  established_year: number | null;
  college_type: CollegeType | null;
  is_verified: boolean;
  is_active: boolean;
  total_students: number;
  metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

/**
 * College insert payload
 */
export interface CollegeInsert {
  name: string;
  short_name?: string | null;
  domain?: string | null;
  logo_url?: string | null;
  city?: string | null;
  state?: string | null;
  country?: string;
  address?: string | null;
  website?: string | null;
  established_year?: number | null;
  college_type?: CollegeType | null;
  is_verified?: boolean;
  is_active?: boolean;
  metadata?: Record<string, unknown>;
}

/**
 * College update payload
 */
export interface CollegeUpdate extends Partial<CollegeInsert> {
  total_students?: number;
}

// ============================================================================
// CAMPUS POSTS
// ============================================================================

/**
 * Campus post record from database
 */
export interface CampusPost {
  id: string;
  user_id: string;
  college_id: string | null;
  category: CampusPostCategory;
  title: string;
  content: string | null;
  images: string[];
  is_admin_post: boolean;
  is_pinned: boolean;
  is_anonymous: boolean;
  location: string | null;
  latitude: number | null;
  longitude: number | null;
  event_date: string | null;
  event_end_date: string | null;
  event_venue: string | null;
  event_link: string | null;
  deadline: string | null;
  apply_link: string | null;
  company_name: string | null;
  price: number | null;
  is_negotiable: boolean;
  condition: string | null;
  likes_count: number;
  comments_count: number;
  saves_count: number;
  views_count: number;
  shares_count: number;
  is_flagged: boolean;
  flag_reason: string | null;
  flagged_at: string | null;
  flagged_by: string | null;
  is_hidden: boolean;
  hidden_reason: string | null;
  status: CampusPostStatus;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
}

/**
 * Campus post with author and college info
 */
export interface CampusPostWithRelations extends CampusPost {
  author?: {
    id: string;
    full_name: string;
    avatar_url: string | null;
    is_college_verified: boolean;
  };
  college?: {
    id: string;
    name: string;
    short_name: string | null;
  };
  is_liked?: boolean;
  is_saved?: boolean;
}

/**
 * Campus post insert payload
 */
export interface CampusPostInsert {
  user_id: string;
  college_id?: string | null;
  category: CampusPostCategory;
  title: string;
  content?: string | null;
  images?: string[];
  is_anonymous?: boolean;
  location?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  event_date?: string | null;
  event_end_date?: string | null;
  event_venue?: string | null;
  event_link?: string | null;
  deadline?: string | null;
  apply_link?: string | null;
  company_name?: string | null;
  price?: number | null;
  is_negotiable?: boolean;
  condition?: string | null;
  status?: CampusPostStatus;
  expires_at?: string | null;
}

/**
 * Campus post update payload
 */
export interface CampusPostUpdate extends Partial<Omit<CampusPostInsert, 'user_id'>> {
  is_pinned?: boolean;
  is_admin_post?: boolean;
}

// ============================================================================
// CAMPUS INTERACTIONS
// ============================================================================

/**
 * Campus post like
 */
export interface CampusPostLike {
  id: string;
  post_id: string;
  user_id: string;
  created_at: string;
}

/**
 * Campus post comment
 */
export interface CampusPostComment {
  id: string;
  post_id: string;
  user_id: string;
  parent_id: string | null;
  content: string;
  is_anonymous: boolean;
  likes_count: number;
  replies_count: number;
  is_flagged: boolean;
  flag_reason: string | null;
  is_hidden: boolean;
  is_edited: boolean;
  edited_at: string | null;
  created_at: string;
  updated_at: string;
}

/**
 * Comment with author info
 */
export interface CampusPostCommentWithAuthor extends CampusPostComment {
  author?: {
    id: string;
    full_name: string;
    avatar_url: string | null;
  };
  is_liked?: boolean;
  replies?: CampusPostCommentWithAuthor[];
}

/**
 * Comment insert payload
 */
export interface CampusPostCommentInsert {
  post_id: string;
  user_id: string;
  parent_id?: string | null;
  content: string;
  is_anonymous?: boolean;
}

/**
 * Saved post
 */
export interface CampusSavedPost {
  id: string;
  post_id: string;
  user_id: string;
  collection_name: string;
  notes: string | null;
  created_at: string;
}

/**
 * Post report
 */
export interface CampusPostReport {
  id: string;
  post_id: string | null;
  comment_id: string | null;
  reporter_id: string;
  reason: ReportReason;
  description: string | null;
  status: ReportStatus;
  reviewed_by: string | null;
  reviewed_at: string | null;
  resolution_notes: string | null;
  action_taken: string | null;
  created_at: string;
}

// ============================================================================
// EXPERTS
// ============================================================================

/**
 * Expert availability slot
 */
export interface AvailabilitySlot {
  start: string; // HH:mm format
  end: string; // HH:mm format
}

/**
 * Expert availability
 */
export interface ExpertAvailability {
  timezone: string;
  slots: {
    monday: AvailabilitySlot[];
    tuesday: AvailabilitySlot[];
    wednesday: AvailabilitySlot[];
    thursday: AvailabilitySlot[];
    friday: AvailabilitySlot[];
    saturday: AvailabilitySlot[];
    sunday: AvailabilitySlot[];
  };
}

/**
 * Expert record from database
 */
export interface Expert {
  id: string;
  user_id: string;
  headline: string;
  designation: string;
  organization: string | null;
  bio: string | null;
  category: ExpertCategory;
  specializations: string[];
  languages: string[];
  hourly_rate: number;
  currency: string;
  session_duration: number;
  min_session_duration: number;
  max_session_duration: number;
  google_meet_link: string | null;
  zoom_link: string | null;
  whatsapp_number: string | null;
  calendly_link: string | null;
  custom_booking_link: string | null;
  preferred_platform: string;
  availability: ExpertAvailability;
  is_instant_booking: boolean;
  advance_booking_days: number;
  buffer_time_minutes: number;
  verification_status: ExpertVerificationStatus;
  verified_at: string | null;
  verified_by: string | null;
  verification_notes: string | null;
  identity_verified: boolean;
  credentials_verified: boolean;
  resume_url: string | null;
  linkedin_url: string | null;
  portfolio_url: string | null;
  certificate_urls: string[];
  rating: number;
  total_reviews: number;
  total_sessions: number;
  total_earnings: number;
  completed_sessions: number;
  cancelled_sessions: number;
  response_time_hours: number | null;
  is_active: boolean;
  is_featured: boolean;
  is_accepting_bookings: boolean;
  metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

/**
 * Expert with user profile info
 */
export interface ExpertWithProfile extends Expert {
  profile?: {
    id: string;
    full_name: string;
    avatar_url: string | null;
    is_college_verified: boolean;
    college?: {
      name: string;
      short_name: string | null;
    };
  };
  education?: ExpertEducation[];
  experience?: ExpertExperience[];
  achievements?: ExpertAchievement[];
}

/**
 * Expert insert payload
 */
export interface ExpertInsert {
  user_id: string;
  headline: string;
  designation: string;
  organization?: string | null;
  bio?: string | null;
  category: ExpertCategory;
  specializations: string[];
  languages?: string[];
  hourly_rate: number;
  currency?: string;
  session_duration?: number;
  min_session_duration?: number;
  max_session_duration?: number;
  google_meet_link?: string | null;
  zoom_link?: string | null;
  whatsapp_number?: string | null;
  calendly_link?: string | null;
  custom_booking_link?: string | null;
  preferred_platform?: string;
  availability?: ExpertAvailability;
  is_instant_booking?: boolean;
  advance_booking_days?: number;
  buffer_time_minutes?: number;
  resume_url?: string | null;
  linkedin_url?: string | null;
  portfolio_url?: string | null;
  certificate_urls?: string[];
}

/**
 * Expert update payload
 */
export interface ExpertUpdate extends Partial<Omit<ExpertInsert, 'user_id'>> {
  is_active?: boolean;
  is_accepting_bookings?: boolean;
}

/**
 * Expert education record
 */
export interface ExpertEducation {
  id: string;
  expert_id: string;
  institution: string;
  degree: string;
  field_of_study: string | null;
  start_year: number | null;
  end_year: number | null;
  is_current: boolean;
  description: string | null;
  created_at: string;
}

/**
 * Expert experience record
 */
export interface ExpertExperience {
  id: string;
  expert_id: string;
  company: string;
  title: string;
  location: string | null;
  start_date: string | null;
  end_date: string | null;
  is_current: boolean;
  description: string | null;
  created_at: string;
}

/**
 * Expert achievement record
 */
export interface ExpertAchievement {
  id: string;
  expert_id: string;
  title: string;
  issuer: string | null;
  date_received: string | null;
  description: string | null;
  proof_url: string | null;
  created_at: string;
}

// ============================================================================
// EXPERT BOOKINGS
// ============================================================================

/**
 * Expert booking record from database
 */
export interface ExpertBooking {
  id: string;
  booking_number: string;
  expert_id: string;
  user_id: string;
  topic: string;
  description: string | null;
  category: ExpertCategory | null;
  scheduled_start: string;
  scheduled_end: string;
  actual_start: string | null;
  actual_end: string | null;
  duration_minutes: number;
  timezone: string;
  meeting_platform: string | null;
  meeting_link: string | null;
  meeting_id: string | null;
  meeting_password: string | null;
  hourly_rate: number;
  session_amount: number;
  platform_fee: number;
  tax_amount: number;
  discount_amount: number;
  coupon_code: string | null;
  total_amount: number;
  currency: string;
  payment_status: ExpertPaymentStatus;
  payment_id: string | null;
  payment_order_id: string | null;
  payment_method: string | null;
  paid_at: string | null;
  refund_id: string | null;
  refund_amount: number | null;
  refunded_at: string | null;
  status: ExpertBookingStatus;
  cancelled_by: string | null;
  cancellation_reason: string | null;
  cancelled_at: string | null;
  rejection_reason: string | null;
  user_rating: number | null;
  user_review: string | null;
  expert_rating: number | null;
  expert_feedback: string | null;
  rescheduled_from: string | null;
  reschedule_count: number;
  max_reschedules: number;
  pre_session_notes: string | null;
  post_session_notes: string | null;
  reminder_sent_24h: boolean;
  reminder_sent_1h: boolean;
  metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

/**
 * Booking with expert and user info
 */
export interface ExpertBookingWithRelations extends ExpertBooking {
  expert?: ExpertWithProfile;
  user?: {
    id: string;
    full_name: string;
    avatar_url: string | null;
    email: string;
  };
}

/**
 * Booking insert payload
 */
export interface ExpertBookingInsert {
  expert_id: string;
  user_id: string;
  topic: string;
  description?: string | null;
  scheduled_start: string;
  scheduled_end: string;
  duration_minutes: number;
  timezone?: string;
  meeting_platform?: string | null;
  hourly_rate: number;
  session_amount: number;
  platform_fee?: number;
  total_amount: number;
  payment_method?: string | null;
}

/**
 * Booking update payload
 */
export interface ExpertBookingUpdate {
  status?: ExpertBookingStatus;
  meeting_link?: string | null;
  meeting_id?: string | null;
  meeting_password?: string | null;
  payment_status?: ExpertPaymentStatus;
  payment_id?: string | null;
  payment_order_id?: string | null;
  paid_at?: string | null;
  actual_start?: string | null;
  actual_end?: string | null;
  cancellation_reason?: string | null;
  rejection_reason?: string | null;
  pre_session_notes?: string | null;
  post_session_notes?: string | null;
  user_rating?: number | null;
  user_review?: string | null;
  expert_rating?: number | null;
  expert_feedback?: string | null;
}

// ============================================================================
// EXPERT REVIEWS
// ============================================================================

/**
 * Expert review record
 */
export interface ExpertReview {
  id: string;
  expert_id: string;
  booking_id: string;
  user_id: string;
  overall_rating: number;
  knowledge_rating: number | null;
  communication_rating: number | null;
  helpfulness_rating: number | null;
  punctuality_rating: number | null;
  review_title: string | null;
  review_text: string | null;
  expert_response: string | null;
  responded_at: string | null;
  is_public: boolean;
  is_verified: boolean;
  is_featured: boolean;
  is_flagged: boolean;
  flag_reason: string | null;
  is_hidden: boolean;
  helpful_count: number;
  not_helpful_count: number;
  created_at: string;
  updated_at: string;
}

/**
 * Review with author info
 */
export interface ExpertReviewWithAuthor extends ExpertReview {
  author?: {
    id: string;
    full_name: string;
    avatar_url: string | null;
  };
  user_vote?: boolean | null; // true = helpful, false = not helpful, null = no vote
}

/**
 * Review insert payload
 */
export interface ExpertReviewInsert {
  expert_id: string;
  booking_id: string;
  user_id: string;
  overall_rating: number;
  knowledge_rating?: number | null;
  communication_rating?: number | null;
  helpfulness_rating?: number | null;
  punctuality_rating?: number | null;
  review_title?: string | null;
  review_text?: string | null;
}

// ============================================================================
// PROFILE UPDATES
// ============================================================================

/**
 * Notification preferences
 */
export interface NotificationPreferences {
  email_notifications: boolean;
  push_notifications: boolean;
  whatsapp_notifications: boolean;
  campus_updates: boolean;
  expert_reminders: boolean;
  marketing_emails: boolean;
}

/**
 * Social links
 */
export interface SocialLinks {
  linkedin?: string;
  twitter?: string;
  github?: string;
  instagram?: string;
  website?: string;
  [key: string]: string | undefined;
}

/**
 * Profile college verification fields
 */
export interface ProfileCollegeFields {
  college_email: string | null;
  is_college_verified: boolean;
  college_id: string | null;
  college_verified_at: string | null;
}

/**
 * Profile tour fields
 */
export interface ProfileTourFields {
  has_completed_tour: boolean;
  tour_completed_at: string | null;
  tour_steps_completed: string[];
}

/**
 * Profile additional fields
 */
export interface ProfileAdditionalFields {
  bio: string | null;
  headline: string | null;
  skills: string[];
  interests: string[];
  social_links: SocialLinks;
  notification_preferences: NotificationPreferences;
  is_profile_public: boolean;
  show_college: boolean;
  show_projects: boolean;
  allow_messages: boolean;
}

/**
 * Extended profile with new fields
 */
export interface ExtendedProfile extends ProfileCollegeFields, ProfileTourFields, ProfileAdditionalFields {
  id: string;
  email: string;
  full_name: string;
  avatar_url: string | null;
  phone: string | null;
  phone_verified: boolean;
  user_type: 'student' | 'professional' | 'expert' | 'college_admin' | 'admin';
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// WHATSAPP NOTIFICATIONS
// ============================================================================

/**
 * WhatsApp notification record
 */
export interface WhatsAppNotification {
  id: string;
  profile_id: string | null;
  phone_number: string;
  template_name: string;
  template_params: Record<string, string>;
  message_text: string | null;
  booking_id: string | null;
  entity_type: string | null;
  entity_id: string | null;
  status: 'pending' | 'sent' | 'delivered' | 'read' | 'failed';
  provider: string | null;
  provider_message_id: string | null;
  error_message: string | null;
  scheduled_at: string | null;
  sent_at: string | null;
  delivered_at: string | null;
  read_at: string | null;
  created_at: string;
}

// ============================================================================
// FUNCTION RETURN TYPES
// ============================================================================

/**
 * Toggle like response
 */
export interface ToggleLikeResponse {
  success: boolean;
  liked: boolean;
  likes_count: number;
}

/**
 * Toggle save response
 */
export interface ToggleSaveResponse {
  success: boolean;
  saved: boolean;
}

/**
 * Create booking response
 */
export interface CreateBookingResponse {
  success: boolean;
  booking_id: string;
  booking_number: string;
  session_amount: number;
  platform_fee: number;
  total_amount: number;
  currency: string;
}

/**
 * Cancel booking response
 */
export interface CancelBookingResponse {
  success: boolean;
  refund_eligible: boolean;
  cancelled_by: 'expert' | 'user';
}

/**
 * College verification init response
 */
export interface CollegeVerificationResponse {
  success: boolean;
  college_id: string;
  college_name: string;
  verification_token?: string;
  expires_at?: string;
}

/**
 * Expert availability response
 */
export interface ExpertAvailabilityResponse {
  date: string;
  day: string;
  timezone: string;
  available_slots: AvailabilitySlot[];
  booked_slots: { start_time: string; end_time: string }[];
  session_duration: number;
  buffer_time: number;
}

// ============================================================================
// SEARCH/FILTER TYPES
// ============================================================================

/**
 * Campus posts search params
 */
export interface CampusPostsSearchParams {
  college_id?: string;
  category?: CampusPostCategory;
  search_query?: string;
  limit?: number;
  offset?: number;
}

/**
 * Experts search params
 */
export interface ExpertsSearchParams {
  category?: ExpertCategory;
  search_query?: string;
  min_rate?: number;
  max_rate?: number;
  min_rating?: number;
  specializations?: string[];
  sort_by?: 'rating' | 'price_low' | 'price_high' | 'sessions';
  limit?: number;
  offset?: number;
}

// ============================================================================
// HELPER TYPES
// ============================================================================

/**
 * Pagination info
 */
export interface PaginationInfo {
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}

/**
 * Paginated response
 */
export interface PaginatedResponse<T> {
  data: T[];
  pagination: PaginationInfo;
}

/**
 * API response wrapper
 */
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}
