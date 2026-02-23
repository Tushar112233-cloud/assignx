/**
 * Types for Expert Consultation module
 * Professional consultation booking with commission-based payments
 */

/**
 * Expert availability status
 */
export type ExpertAvailability = "available" | "busy" | "offline";

/**
 * Consultation session status
 */
export type SessionStatus = "upcoming" | "in_progress" | "completed" | "cancelled" | "no_show";

/**
 * Expert specialization categories
 */
export type ExpertSpecialization =
  | "academic_writing"
  | "research_methodology"
  | "data_analysis"
  | "programming"
  | "mathematics"
  | "science"
  | "business"
  | "engineering"
  | "law"
  | "medicine"
  | "arts"
  | "other";

/**
 * Expert profile
 */
export interface Expert {
  id: string;
  name: string;
  avatar?: string;
  designation: string;
  bio: string;
  verified: boolean;
  rating: number;
  reviewCount: number;
  totalSessions: number;
  specializations: ExpertSpecialization[];
  pricePerSession: number;
  currency: string;
  availability: ExpertAvailability;
  responseTime: string;
  languages: string[];
  education?: string;
  experience?: string;
  featured?: boolean;
  createdAt: Date;
}

/**
 * Expert availability slot
 */
export interface AvailabilitySlot {
  id: string;
  expertId: string;
  date: Date;
  startTime: string;
  endTime: string;
  isBooked: boolean;
}

/**
 * Consultation booking
 */
export interface ConsultationBooking {
  id: string;
  expertId: string;
  clientId: string;
  date: Date;
  startTime: string;
  endTime: string;
  duration: number; // in minutes
  topic?: string;
  notes?: string;
  status: SessionStatus;
  meetLink?: string;
  totalAmount: number;
  expertAmount: number;
  platformFee: number;
  currency: string;
  paymentId?: string;
  paymentStatus: "pending" | "completed" | "refunded" | "failed";
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Expert review
 */
export interface ExpertReview {
  id: string;
  expertId: string;
  clientId: string;
  bookingId: string;
  rating: number;
  comment: string;
  clientName: string;
  clientAvatar?: string;
  createdAt: Date;
  helpful?: number;
}

/**
 * Commission breakdown
 */
export interface CommissionBreakdown {
  totalAmount: number;
  expertAmount: number;
  platformFee: number;
  expertPercentage: number;
  platformPercentage: number;
  currency: string;
  formattedTotal: string;
  formattedExpertAmount: string;
  formattedPlatformFee: string;
}

/**
 * Time slot for booking selection
 */
export interface TimeSlot {
  id: string;
  time: string;
  displayTime: string;
  available: boolean;
}

/**
 * Expert filter options
 */
export interface ExpertFilters {
  specializations: ExpertSpecialization[];
  minRating: number;
  maxPrice: number;
  availability: ExpertAvailability[];
  languages: string[];
  sortBy: "rating" | "price_low" | "price_high" | "sessions" | "newest";
}

/**
 * Booking form data
 */
export interface BookingFormData {
  expertId: string;
  date: Date;
  timeSlot: TimeSlot;
  topic?: string;
  notes?: string;
}

/**
 * WhatsApp notification types
 */
export type WhatsAppNotificationType =
  | "booking_confirmation"
  | "booking_reminder"
  | "session_completed"
  | "review_request";

/**
 * WhatsApp notification payload
 */
export interface WhatsAppNotificationPayload {
  type: WhatsAppNotificationType;
  phoneNumber: string;
  expertName: string;
  clientName: string;
  sessionDate: string;
  sessionTime: string;
  meetLink?: string;
  bookingId?: string;
}

/**
 * Specialization display config
 */
export const SPECIALIZATION_LABELS: Record<ExpertSpecialization, string> = {
  academic_writing: "Academic Writing",
  research_methodology: "Research Methodology",
  data_analysis: "Data Analysis",
  programming: "Programming",
  mathematics: "Mathematics",
  science: "Science",
  business: "Business",
  engineering: "Engineering",
  law: "Law",
  medicine: "Medicine",
  arts: "Arts",
  other: "Other",
};

/**
 * Default consultation duration in minutes
 */
export const DEFAULT_SESSION_DURATION = 60;

/**
 * Commission rates
 */
export const COMMISSION_RATES = {
  EXPERT_PERCENTAGE: 66.67,
  PLATFORM_PERCENTAGE: 33.33,
} as const;
