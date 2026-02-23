# TypeScript Types Documentation

## Overview

All type definitions are in the `types/` directory. Each module has its own type file, with `index.ts` providing common types and re-exports.

---

## Common Types (`types/index.ts`)

### User
```typescript
export interface User {
  id: string;
  email: string;
  fullName: string | null;
  phone: string | null;
  userType: "student" | "professional" | "business";
  avatarUrl: string | null;
}
```

### Project Status
```typescript
export type ProjectStatus =
  | "submitted"      // Initial submission
  | "analyzing"      // Under review
  | "quoted"         // Price quoted
  | "payment_pending"// Awaiting payment
  | "paid"           // Payment received
  | "assigned"       // Writer assigned
  | "in_progress"    // Work in progress
  | "delivered"      // Delivered to client
  | "qc_approved"    // Quality check passed
  | "completed"      // Client approved
  | "cancelled"      // Cancelled by client
  | "refunded";      // Refund processed
```

### Service Type
```typescript
export type ServiceType =
  | "new_project"      // Full project support
  | "proofreading"     // Proofreading service
  | "plagiarism_check" // Plagiarism detection
  | "ai_detection"     // AI content detection
  | "expert_opinion";  // Expert consultation
```

---

## Project Types (`types/project.ts`)

### Project
```typescript
export interface Project {
  id: string;
  projectNumber: string;      // e.g., "#AX-2940"
  title: string;
  subjectId: string;
  subjectName: string;
  subjectIcon: string;        // Lucide icon name
  status: ProjectStatus;
  progress: number;           // 0-100
  deadline: string;           // ISO date
  createdAt: string;          // ISO date

  // Optional fields based on status
  quoteAmount?: number;
  wordCount?: number;
  referenceStyle?: string;
  deliveredAt?: string;
  completedAt?: string;
  cancelledAt?: string;
  refundedAt?: string;
  autoApprovalDeadline?: string;
}
```

### Project Tab
```typescript
export type ProjectTab =
  | "in_review"    // analyzing, quoted, payment_pending
  | "in_progress"  // paid, assigned, in_progress
  | "for_review"   // delivered, qc_approved
  | "history";     // completed, cancelled, refunded
```

### Tab Status Mapping
```typescript
export const TAB_STATUSES: Record<ProjectTab, ProjectStatus[]> = {
  in_review: ["analyzing", "quoted", "payment_pending"],
  in_progress: ["paid", "assigned", "in_progress"],
  for_review: ["delivered", "qc_approved"],
  history: ["completed", "cancelled", "refunded"],
};
```

---

## Profile Types (`types/profile.ts`)

### Profile Settings
```typescript
export interface ProfileSettings {
  personal: PersonalInfo;
  academic: AcademicInfo;
  preferences: PreferencesInfo;
  security: SecurityInfo;
  subscription: SubscriptionInfo;
}
```

### Personal Info
```typescript
export interface PersonalInfo {
  fullName: string;
  email: string;
  phone: string;
  dateOfBirth: string;
  gender: "male" | "female" | "other" | "prefer_not_to_say";
  bio: string;
  avatarUrl?: string;
}
```

### Academic Info
```typescript
export interface AcademicInfo {
  university: { id: string; name: string };
  course: { id: string; name: string };
  semester: number;
  enrollmentYear: number;
  collegeEmail?: string;
  studentId?: string;
}
```

### Security Info
```typescript
export interface SecurityInfo {
  passwordLastChanged: string;
  twoFactorEnabled: boolean;
  twoFactorMethod?: "app" | "sms" | "email";
  activeSessions: Session[];
}

export interface Session {
  id: string;
  device: string;
  browser: string;
  location: string;
  lastActive: string;
  isCurrent: boolean;
}
```

### Subscription Info
```typescript
export interface SubscriptionInfo {
  plan: "free" | "basic" | "premium" | "enterprise";
  status: "active" | "expired" | "cancelled";
  startDate: string;
  endDate?: string;
  features: string[];
}
```

---

## Connect Types (`types/connect.ts`)

### Tutor
```typescript
export interface Tutor {
  id: string;
  name: string;
  avatar?: string;
  verified: boolean;
  rating: number;           // 0-5
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

export type ExpertiseLevel = "beginner" | "intermediate" | "expert" | "master";
export type AvailabilityStatus = "available" | "busy" | "offline";
```

### Resource
```typescript
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

export type ResourceType = "notes" | "template" | "guide" | "practice" | "video";
```

### Study Group
```typescript
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

export type GroupStatus = "open" | "full" | "private";
```

### Q&A Types
```typescript
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

export type QAFilterStatus = "all" | "unanswered" | "answered";
```

### Filters
```typescript
export interface TutorFilters {
  subjects: string[];
  minRating: number;
  maxHourlyRate: number;
  availability: AvailabilityStatus[];
  expertise: ExpertiseLevel[];
  languages: string[];
}

export interface ResourceFilters {
  types: ResourceType[];
  subjects: string[];
  minRating: number;
  priceRange: "free" | "paid" | "all";
}
```

---

## Settings Types (`types/settings.ts`)

### App Version
```typescript
export interface AppVersion {
  version: string;      // e.g., "1.0.0"
  buildNumber: string;  // e.g., "2024.12.26"
  lastUpdated: string;  // ISO date
}
```

### Feedback Data
```typescript
export interface FeedbackData {
  type: "bug" | "feature" | "general";
  message: string;
  email?: string;
}
```

### Support Ticket
```typescript
export interface SupportTicket {
  id: string;
  subject: string;
  status: "open" | "in_progress" | "resolved" | "closed";
  createdAt: string;
  updatedAt: string;
  category: string;
}
```

### FAQ Item
```typescript
export interface FAQItem {
  id: string;
  question: string;
  answer: string;
  category: string;
}
```

### Contact Form
```typescript
export interface ContactFormData {
  name: string;
  email: string;
  subject: string;
  message: string;
  category: "general" | "billing" | "technical" | "account";
}
```

---

## Add Project Types (`types/add-project.ts`)

### Subject
```typescript
export interface Subject {
  id: string;
  name: string;
  icon: string;           // Lucide icon name
  color: string;          // Tailwind color class
  description?: string;
  popularTopics?: string[];
}
```

### Reference Style
```typescript
export type ReferenceStyle =
  | "apa7"
  | "mla9"
  | "harvard"
  | "chicago"
  | "ieee"
  | "vancouver"
  | "acs"
  | "none";
```

### Project Form Data
```typescript
export interface ProjectFormData {
  // Step 1
  subject: string;
  topic: string;

  // Step 2
  wordCount: number;
  referenceStyle: ReferenceStyle;
  referenceCount?: number;

  // Step 3
  deadline: Date;
  urgency: "standard" | "urgent" | "critical";

  // Step 4
  description: string;
  files: File[];
  specialInstructions?: string;
}
```

---

## Database Types (`types/database.ts`)

Generated from Supabase schema.

```typescript
export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name: string | null;
          phone: string | null;
          user_type: "student" | "professional" | "business";
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: { /* ... */ };
        Update: { /* ... */ };
      };
      students: { /* ... */ };
      professionals: { /* ... */ };
    };
  };
};
```

---

## Type Utilities

### Strict Omit
```typescript
type StrictOmit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;
```

### Form Schema to Type
```typescript
import { z } from "zod";
import { projectStep1Schema } from "@/lib/validations/project";

export type ProjectStep1Data = z.infer<typeof projectStep1Schema>;
```

---

## Best Practices

### 1. Prefer Interfaces
```typescript
// Good - extendable
interface User {
  id: string;
  name: string;
}

// Avoid unless union type needed
type User = {
  id: string;
  name: string;
};
```

### 2. Use Const Assertions for Literals
```typescript
export const STATUSES = ["active", "inactive", "pending"] as const;
export type Status = typeof STATUSES[number]; // "active" | "inactive" | "pending"
```

### 3. Discriminated Unions
```typescript
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: string };

function handleResult<T>(result: Result<T>) {
  if (result.success) {
    // TypeScript knows result.data exists
    return result.data;
  } else {
    // TypeScript knows result.error exists
    throw new Error(result.error);
  }
}
```
