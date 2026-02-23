# Components Documentation

## Overview

All components are organized by feature module in the `components/` directory. Each module has an `index.ts` barrel file for clean imports.

---

## Auth Components (`components/auth/`)

Authentication and onboarding components.

| Component | Description | Props |
|-----------|-------------|-------|
| `GoogleSignInButton` | OAuth sign-in button | `isLoading?: boolean` |
| `SplashScreen` | Initial loading screen | - |
| `OnboardingCarousel` | Onboarding slides carousel | `onComplete: () => void` |
| `OnboardingSlide` | Single onboarding slide | `slide: OnboardingSlide` |
| `RoleSelection` | User type selection (Student/Professional) | `onSelect: (role) => void` |
| `StudentSignupForm` | Student registration form | `onSuccess: () => void` |
| `ProfessionalSignupForm` | Professional registration form | `onSuccess: () => void` |
| `ProgressSteps` | Multi-step progress indicator | `currentStep, totalSteps` |
| `UniversitySelector` | Searchable university dropdown | `value, onChange, error?` |
| `CourseSelector` | Course/degree selection | `value, onChange, error?` |
| `IndustrySelector` | Industry selection for professionals | `value, onChange, error?` |
| `TermsModal` | Terms and conditions modal | `open, onOpenChange` |
| `SuccessAnimation` | Registration success animation | - |

### Usage Example
```tsx
import { GoogleSignInButton, StudentSignupForm } from "@/components/auth";

<GoogleSignInButton isLoading={loading} />
<StudentSignupForm onSuccess={() => router.push("/home")} />
```

---

## Dashboard Components (`components/dashboard/`)

Main dashboard layout and shared components.

| Component | Description | Props |
|-----------|-------------|-------|
| `DashboardHeader` | Top header with greeting, wallet, notifications | - |
| `Sidebar` | Desktop sidebar navigation | - |
| `MobileNav` | Mobile bottom navigation | `onFabClick: () => void` |
| `PersonalizedGreeting` | Time-based greeting message | - |
| `WalletPill` | Wallet balance display | - |
| `NotificationBell` | Notifications dropdown | - |
| `BannerCarousel` | Promotional banners slider | - |
| `ServicesGrid` | 2x2 services grid | - |
| `ServiceCard` | Single service card | `service: Service` |
| `CentralFab` | Floating action button | `onClick: () => void` |
| `UploadSheet` | Service selection sheet | `open, onOpenChange` |

### Layout Structure
```tsx
// Dashboard layout includes:
// - Sidebar (desktop) or MobileNav (mobile)
// - DashboardHeader
// - Main content area
```

---

## Projects Components (`components/projects/`)

Project list and management.

| Component | Description | Props |
|-----------|-------------|-------|
| `ProjectList` | Filterable projects list | - |
| `ProjectTabs` | Status filter tabs | `value, onChange` |
| `ProjectCard` | Project card with status | `project: Project` |
| `ProjectCardHeader` | Card header with title | `project` |
| `ProjectCardBody` | Card body with details | `project` |
| `ProjectCardFooter` | Card footer with actions | `project` |
| `StatusBadge` | Status indicator badge | `status: ProjectStatus` |
| `ProgressBar` | Project progress bar | `progress: number` |
| `DeadlineDisplay` | Deadline with countdown | `deadline: string` |
| `AutoApprovalTimer` | 48h auto-approval countdown | `deadline: string` |
| `PaymentPromptModal` | Payment reminder modal | `project, open, onOpenChange` |
| `InvoiceDownload` | Invoice download button | `projectId` |
| `RevisionRequestForm` | Request revision form | `projectId` |
| `ProjectTimeline` | Project status timeline | `project` |

### Status Flow
```
analyzing → quoted → payment_pending → paid → assigned →
in_progress → delivered → qc_approved → completed
```

---

## Project Detail Components (`components/project-detail/`)

Detailed project view.

| Component | Description | Props |
|-----------|-------------|-------|
| `ProjectDetailHeader` | Project title and status | `project` |
| `StatusBanner` | Current status banner | `status, progress` |
| `DeadlineCountdown` | Countdown to deadline | `deadline` |
| `ProjectBriefAccordion` | Collapsible project details | `project` |
| `LiveDraftTracker` | Real-time progress tracker | `progress` |
| `DeliverablesSection` | Deliverables list | `deliverables` |
| `DeliverableItem` | Single deliverable item | `deliverable` |
| `AttachedFiles` | File attachments list | `files` |
| `QualityReportBadge` | Quality check badge | `report` |
| `FloatingChatButton` | Chat access FAB | `onClick` |
| `ChatWindow` | In-app chat window | `projectId` |

---

## Add Project Components (`components/add-project/`)

Project creation wizard.

| Component | Description | Props |
|-----------|-------------|-------|
| `NewProjectForm` | Multi-step project form | `onSuccess: (id, number) => void` |
| `FormSteps` | Step indicator | `currentStep` |
| `SubjectSelector` | Subject selection grid | `value, onChange, error?` |
| `DeadlinePicker` | Calendar deadline picker | `value, onChange` |
| `FileUploadZone` | Drag & drop file upload | `files, onFilesChange` |
| `PriceEstimate` | Dynamic price calculator | `wordCount, deadline` |
| `SubmissionSuccess` | Success confirmation | `projectId, projectNumber, serviceType` |
| `ReportForm` | AI/Plagiarism report form | `onSuccess` |
| `ProofreadingForm` | Proofreading service form | `onSuccess` |
| `ConsultationForm` | Expert consultation form | `onSuccess` |

### Step Components (`components/add-project/steps/`)
| Component | Description |
|-----------|-------------|
| `StepSubject` | Subject and topic selection |
| `StepRequirements` | Word count and references |
| `StepDeadline` | Deadline selection |
| `StepDetails` | Additional details and files |

---

## Connect Components (`components/connect/`)

Student Connect / Marketplace.

| Component | Description | Props |
|-----------|-------------|-------|
| `ConnectSearchBar` | Search with filter button | `value, onChange, onFilterClick` |
| `CategoryFilter` | Category tabs | `selected, onChange` |
| `FeaturedTutors` | Featured tutors carousel | `tutors, onTutorClick, onBookTutor` |
| `TutorCard` | Tutor profile card | `tutor, onClick, onBook` |
| `TutorProfileSheet` | Tutor detail sheet | `tutor, open, onOpenChange, onBook` |
| `BookSessionSheet` | Session booking form | `tutor, open, onOpenChange, onSuccess` |
| `ResourceCard` | Shared resource card | `resource` |
| `StudyGroupCard` | Study group card | `group` |
| `FilterSheet` | Advanced filters | `filters, onFiltersChange, open, onApply` |
| `QASection` | Questions & Answers section | - |
| `QuestionCard` | Q&A question card | `question, onClick?` |
| `AskQuestionSheet` | Ask question form | `open, onOpenChange, onSuccess?` |

---

## Profile Components (`components/profile/`)

User profile settings.

| Component | Description | Props |
|-----------|-------------|-------|
| `ProfileHeader` | Avatar and name header | `user` |
| `SettingsTabs` | Settings navigation tabs | `value, onChange` |
| `PersonalInfoForm` | Personal details form | `user, onSave` |
| `AcademicInfoSection` | University/course info | `user, onSave` |
| `PreferencesSection` | App preferences | - |
| `SecuritySection` | Password and 2FA | `securitySettings` |
| `SubscriptionCard` | Subscription status | `subscription` |
| `AvatarUploadDialog` | Avatar upload modal | `open, onOpenChange, onUpload` |
| `DangerZone` | Account deletion | - |

### Security Sub-components (`components/profile/security/`)
| Component | Description |
|-----------|-------------|
| `PasswordCard` | Password change card |
| `TwoFactorCard` | 2FA settings card |
| `ActiveSessionsCard` | Active sessions list |
| `SessionItem` | Single session item |
| `PasswordChangeDialog` | Password change modal |
| `RevokeAllDialog` | Revoke sessions confirmation |

---

## Settings Components (`components/settings/`)

App settings.

| Component | Description | Props |
|-----------|-------------|-------|
| `DataSection` | Data export and cache | - |
| `AppInfoSection` | App version info | - |
| `FeedbackSection` | Feedback form | - |

---

## Support Components (`components/support/`)

Help and support.

| Component | Description | Props |
|-----------|-------------|-------|
| `FAQSection` | FAQ accordion | - |
| `ContactForm` | Contact form | - |
| `TicketHistory` | Support tickets list | - |

---

## UI Components (`components/ui/`)

shadcn/ui primitives. See [shadcn/ui documentation](https://ui.shadcn.com/).

| Component | Based On |
|-----------|----------|
| `Accordion` | Radix UI Accordion |
| `AlertDialog` | Radix UI Alert Dialog |
| `Avatar` | Radix UI Avatar |
| `Badge` | Custom |
| `Button` | Custom |
| `Calendar` | react-day-picker |
| `Card` | Custom |
| `Checkbox` | Radix UI Checkbox |
| `Command` | cmdk |
| `Dialog` | Radix UI Dialog |
| `DropdownMenu` | Radix UI Dropdown Menu |
| `Form` | React Hook Form |
| `Input` | Custom |
| `Label` | Radix UI Label |
| `Popover` | Radix UI Popover |
| `Progress` | Radix UI Progress |
| `RadioGroup` | Radix UI Radio Group |
| `ScrollArea` | Radix UI Scroll Area |
| `Select` | Radix UI Select |
| `Separator` | Radix UI Separator |
| `Sheet` | Radix UI Dialog (sheet variant) |
| `Skeleton` | Custom |
| `Slider` | Radix UI Slider |
| `Switch` | Radix UI Switch |
| `Tabs` | Radix UI Tabs |
| `Textarea` | Custom |
| `Tooltip` | Radix UI Tooltip |
| `Sonner` | sonner (toasts) |

---

## Shared Components (`components/shared/`)

Cross-cutting utilities.

| Component | Description | Props |
|-----------|-------------|-------|
| `SupportButton` | Floating support button | - |

---

## Component Best Practices

### File Structure
```tsx
"use client"; // If using client hooks

import { ... } from "react";
import { ... } from "@/components/ui/...";
import { ... } from "@/lib/...";
import type { ... } from "@/types/...";

/** Props for ComponentName */
interface ComponentNameProps {
  // Props definition
}

/** Component description */
export function ComponentName({ prop1, prop2 }: ComponentNameProps) {
  // Component logic
  return (
    // JSX
  );
}
```

### Import Pattern
```tsx
// Use barrel imports
import { Button, Card } from "@/components/ui/button";
import { ProjectCard, StatusBadge } from "@/components/projects";

// Avoid
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
```
