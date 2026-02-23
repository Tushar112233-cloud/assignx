/**
 * Types for Student Connect / Marketplace module
 * Batch 7: Student Connect
 */

/**
 * Tutor expertise level
 */
export type ExpertiseLevel = "beginner" | "intermediate" | "expert" | "master";

/**
 * Tutor availability status
 */
export type AvailabilityStatus = "available" | "busy" | "offline";

/**
 * Connect category types
 */
export type ConnectCategory = "all" | "tutors" | "resources" | "study-groups" | "qa";

/**
 * Resource type
 */
export type ResourceType = "notes" | "template" | "guide" | "practice" | "video";

/**
 * Study group status
 */
export type GroupStatus = "open" | "full" | "private";

/**
 * Tutor profile
 */
export interface Tutor {
  id: string;
  name: string;
  avatar?: string;
  verified: boolean;
  rating: number;
  reviewCount: number;
  subjects: string[];
  expertise: ExpertiseLevel;
  hourlyRate: number;
  currency: string;
  availability: AvailabilityStatus;
  bio: string;
  completedSessions: number;
  responseTime: string;
  languages: string[];
  education?: string;
  featured?: boolean;
}

/**
 * Shared resource
 */
export interface Resource {
  id: string;
  title: string;
  description: string;
  type: ResourceType;
  subject: string;
  author: {
    id: string;
    name: string;
    avatar?: string;
  };
  downloads: number;
  rating: number;
  ratingCount: number;
  createdAt: Date;
  fileSize?: string;
  fileType?: string;
  previewUrl?: string;
  isPremium: boolean;
  price?: number;
}

/**
 * Study group
 */
export interface StudyGroup {
  id: string;
  name: string;
  description: string;
  subject: string;
  coverImage?: string;
  memberCount: number;
  maxMembers: number;
  status: GroupStatus;
  createdBy: {
    id: string;
    name: string;
    avatar?: string;
  };
  nextSession?: Date;
  topics: string[];
  isJoined?: boolean;
}

/**
 * Q&A Question
 */
export interface Question {
  id: string;
  title: string;
  content: string;
  subject: string;
  author: {
    id: string;
    name: string;
    avatar?: string;
  };
  answerCount: number;
  upvotes: number;
  createdAt: Date;
  isAnswered: boolean;
  tags: string[];
}

/**
 * Q&A Answer
 */
export interface Answer {
  id: string;
  questionId: string;
  content: string;
  author: {
    id: string;
    name: string;
    avatar?: string;
    isExpert?: boolean;
  };
  upvotes: number;
  isAccepted: boolean;
  createdAt: Date;
}

/** Q&A filter status */
export type QAFilterStatus = "all" | "unanswered" | "answered";

/**
 * Booking session data
 */
export interface BookingSession {
  tutorId: string;
  date: Date;
  timeSlot: string;
  duration: number;
  subject: string;
  topic?: string;
  notes?: string;
}

/**
 * Filter options for tutors
 */
export interface TutorFilters {
  subjects: string[];
  minRating: number;
  maxHourlyRate: number;
  availability: AvailabilityStatus[];
  expertise: ExpertiseLevel[];
  languages: string[];
}

/**
 * Filter options for resources
 */
export interface ResourceFilters {
  types: ResourceType[];
  subjects: string[];
  minRating: number;
  priceRange: "free" | "paid" | "all";
}

/**
 * Time slot for booking
 */
export interface TimeSlot {
  id: string;
  time: string;
  available: boolean;
}
