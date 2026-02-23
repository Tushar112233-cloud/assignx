/**
 * Store exports for Zustand state management
 *
 * Store Usage Guide:
 * - useUserStore: Profile data with fetchUser() - use for displaying user info
 * - useAuthStore: Auth state & onboarding tracking - use for auth flows
 * - useWalletStore: Wallet balance and transactions
 * - useProjectStore: Project list and management
 * - useNotificationStore: Push notifications
 */

// User profile store - fetches and caches user profile data
export { useUserStore } from "./user-store";

// Wallet store - balance and transaction management
export { useWalletStore } from "./wallet-store";

// Notification store - push notification management
export { useNotificationStore } from "./notification-store";

// Project store - project list, tabs, and filtering
export { useProjectStore } from "./project-store";

// Booking store - expert consultation bookings
export { useBookingStore } from "./booking-store";

// Auth store - authentication state and onboarding flow
export {
  useAuthStore,
  useNeedsOnboarding,
  useUserType,
  useWalletBalance,
} from "./auth-store";

// Re-export types
export type { User, StudentProfile, ProfessionalProfile, WalletProfile } from "./user-store";
export type { Wallet, WalletTransaction } from "./wallet-store";
export type { Notification } from "./notification-store";
export type { Project, ProjectStatus, ProjectTab, ProjectFile, ProjectDeliverable, ProjectQuote, ProjectRevision, ProjectTimeline } from "./project-store";
export type { UserType, OnboardingStep } from "./auth-store";
