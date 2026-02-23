export * from "./database";
export * from "./project";
export * from "./account-upgrade";

/**
 * Common types used across the application
 */

export interface User {
  id: string;
  email: string;
  fullName: string | null;
  phone: string | null;
  userType: "student" | "professional" | "business";
  avatarUrl: string | null;
}

export type ServiceType =
  | "new_project"
  | "proofreading"
  | "plagiarism_check"
  | "ai_detection"
  | "expert_opinion";
