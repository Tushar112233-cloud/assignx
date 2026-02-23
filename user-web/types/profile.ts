/**
 * Profile module type definitions
 * Batch 8: Profile Settings
 */

/**
 * Account type for user categorization
 */
export type AccountType = "student" | "professional" | "business_owner";

/**
 * User profile information
 */
export interface UserProfile {
  id: string;
  email: string;
  emailVerified: boolean;
  avatar?: string;
  firstName: string;
  lastName: string;
  phone?: string;
  phoneVerified: boolean;
  dateOfBirth?: string;
  accountType?: AccountType;
  createdAt: string;
  updatedAt: string;
}

/**
 * Academic information
 */
export interface AcademicInfo {
  university: string;
  universityId?: string;
  major: string;
  yearLevel: YearLevel;
  studentId?: string;
  expectedGraduation?: string;
}

/**
 * Year level options
 */
export type YearLevel =
  | "freshman"
  | "sophomore"
  | "junior"
  | "senior"
  | "graduate"
  | "postgraduate";

/**
 * Notification preferences
 */
export interface NotificationPreferences {
  emailNotifications: boolean;
  pushNotifications: boolean;
  inAppNotifications: boolean;
  projectUpdates: boolean;
  marketingEmails: boolean;
  weeklyDigest: boolean;
}

/**
 * Theme options
 */
export type ThemeOption = "light" | "dark" | "system";

/**
 * Supported languages
 */
export type LanguageOption = "en" | "es" | "fr";

/**
 * User preferences
 */
export interface UserPreferences {
  theme: ThemeOption;
  language: LanguageOption;
  notifications: NotificationPreferences;
}

/**
 * Two-factor authentication status
 */
export interface TwoFactorAuth {
  enabled: boolean;
  method?: "authenticator" | "email";
  verifiedAt?: string;
}

/**
 * Active session information
 */
export interface ActiveSession {
  id: string;
  device: string;
  browser: string;
  location: string;
  ipAddress: string;
  lastActive: string;
  current: boolean;
}

/**
 * Security settings
 */
export interface SecuritySettings {
  twoFactorAuth: TwoFactorAuth;
  activeSessions: ActiveSession[];
  passwordLastChanged: string;
}

/**
 * Subscription tier
 */
export type SubscriptionTier = "free" | "pro" | "premium";

/**
 * Subscription status
 */
export type SubscriptionStatus = "active" | "cancelled" | "expired" | "trial";

/**
 * Subscription plan details
 */
export interface SubscriptionPlan {
  id: string;
  tier: SubscriptionTier;
  name: string;
  price: number;
  currency: string;
  interval: "month" | "year";
  features: string[];
  highlighted?: boolean;
}

/**
 * User subscription
 */
export interface UserSubscription {
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  currentPeriodStart: string;
  currentPeriodEnd: string;
  cancelAtPeriodEnd: boolean;
}

/**
 * University option for dropdown
 */
export interface UniversityOption {
  id: string;
  name: string;
  country: string;
}

/**
 * Profile settings tab
 */
export type ProfileTab =
  | "personal"
  | "academic"
  | "preferences"
  | "security"
  | "subscription";

/**
 * Password change form data
 */
export interface PasswordChangeData {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

/**
 * Form validation errors
 */
export interface FormErrors {
  [key: string]: string | undefined;
}
