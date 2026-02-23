# Doer Platform Feature Comparison Report

> **Generated:** December 28, 2025
> **Platforms Compared:** doer-web (Next.js) vs doer_app (Flutter)
> **Reference Document:** AssignX_Complete_Features.md (Features D01-D57)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Completion Overview](#2-completion-overview)
3. [Detailed Feature Analysis](#3-detailed-feature-analysis)
   - [A. Onboarding & Registration](#a-onboarding--registration-d01-d12)
   - [B. Activation Flow](#b-activation-flow--gatekeeper-d13-d20)
   - [C. Main Dashboard](#c-main-dashboard-d21-d32)
   - [D. Active Projects](#d-active-projects-d33-d41)
   - [E. Resources & Tools](#e-resources--tools-d42-d46)
   - [F. Profile & Earnings](#f-profile--earnings-d47-d57)
4. [Feature Gaps Analysis](#4-feature-gaps-analysis)
5. [File Structure Comparison](#5-file-structure-comparison)
6. [Recommendations](#6-recommendations)
7. [Implementation Priority Matrix](#7-implementation-priority-matrix)

---

## 1. Executive Summary

This document provides a comprehensive comparison between the **doer-web** (Next.js) and **doer_app** (Flutter) implementations against the planned features specification (D01-D57) from the AssignX Complete Features document.

### Key Findings

| Metric | doer-web | doer_app |
|--------|----------|----------|
| **Total Features Planned** | 57 | 57 |
| **Features Implemented** | 57 (100%) | 53 (93%) |
| **Features Missing** | 0 | 4 |
| **Overall Completion** | 100% | 93% |

### Platform Status

- **doer-web (Next.js):** ✅ **COMPLETE** - All 57 features implemented
- **doer_app (Flutter):** ⚠️ **NEAR COMPLETE** - 4 optional features missing

---

## 2. Completion Overview

### Feature Category Breakdown

| Category | Total | doer-web | doer_app | Gap |
|----------|-------|----------|----------|-----|
| A. Onboarding & Registration | 12 | 12 ✅ | 12 ✅ | 0 |
| B. Activation Flow | 8 | 8 ✅ | 8 ✅ | 0 |
| C. Main Dashboard | 12 | 12 ✅ | 12 ✅ | 0 |
| D. Active Projects | 9 | 9 ✅ | 9 ✅ | 0 |
| E. Resources & Tools | 5 | 5 ✅ | 4 ⚠️ | 1 |
| F. Profile & Earnings | 11 | 11 ✅ | 8 ⚠️ | 3 |
| **TOTAL** | **57** | **57** | **53** | **4** |

### Visual Completion Chart

```
doer-web:  [████████████████████████████████████████] 100%
doer_app:  [█████████████████████████████████████░░░]  93%
```

---

## 3. Detailed Feature Analysis

### A. Onboarding & Registration (D01-D12)

**Status: Both platforms COMPLETE**

| ID | Feature | Priority | doer-web | doer_app | Notes |
|----|---------|----------|----------|----------|-------|
| D01 | Splash Screen | Core | ✅ | ✅ | Clean logo animation with footer |
| D02 | Onboarding Carousel | Core | ✅ | ✅ | 4 slides with Skip + Next |
| D03 | Slide 1 - Opportunity | Core | ✅ | ✅ | "Countless opportunities in your field" |
| D04 | Slide 2 - Rewards | Core | ✅ | ✅ | "Small Tasks, Big Rewards" |
| D05 | Slide 3 - Support | Core | ✅ | ✅ | "Supervisor Support (24x7)" |
| D06 | Slide 4 - Action | Core | ✅ | ✅ | "Learn While You Earn" CTA |
| D07 | Registration Form | Core | ✅ | ✅ | Full Name, Email, Phone, Password |
| D08 | Terms Agreement | Core | ✅ | ✅ | Checkbox with T&C link |
| D09 | Create Account CTA | Core | ✅ | ✅ | Primary registration button |
| D10 | Profile Setup - Qualification | Core | ✅ | ✅ | Dropdown: High School to PhD |
| D11 | Profile Setup - Skills | Core | ✅ | ✅ | Multi-select chips for areas of interest |
| D12 | Profile Setup - Experience | Core | ✅ | ✅ | Beginner/Intermediate/Pro slider |

#### Implementation Details

**doer-web files:**
- `app/(onboarding)/welcome/page.tsx` - Carousel entry point
- `components/onboarding/OnboardingCarousel.tsx` - Slide carousel
- `components/onboarding/RegistrationForm.tsx` - Registration form
- `components/onboarding/ProfileSetupForm.tsx` - Profile setup

**doer_app files:**
- `lib/features/splash/splash_screen.dart` - Splash screen
- `lib/features/onboarding/screens/onboarding_screen.dart` - Carousel
- `lib/features/auth/screens/register_screen.dart` - Registration
- `lib/features/onboarding/screens/profile_setup_screen.dart` - Profile setup
- `lib/features/onboarding/widgets/chip_selector.dart` - Skill selection
- `lib/features/onboarding/widgets/experience_slider.dart` - Experience level

---

### B. Activation Flow / Gatekeeper (D13-D20)

**Status: Both platforms COMPLETE**

| ID | Feature | Priority | doer-web | doer_app | Notes |
|----|---------|----------|----------|----------|-------|
| D13 | Activation Gate UI | Core | ✅ | ✅ | Dashboard locked until 3 steps complete |
| D14 | Step 1: Training Module | Core | ✅ | ✅ | Video/PDF content with progress tracking |
| D15 | Mark as Complete | Core | ✅ | ✅ | Button to confirm training completion |
| D16 | Step 2: Interview Quiz | Core | ✅ | ✅ | MCQ-based quiz with 5-10 questions |
| D17 | Quiz Pass/Fail Logic | Core | ✅ | ✅ | Success/Fail messaging with retry option |
| D18 | Step 3: Bank Details | Core | ✅ | ✅ | Account Number, IFSC, UPI ID |
| D19 | Finish Setup CTA | Core | ✅ | ✅ | Completes activation, redirects to dashboard |
| D20 | Re-attempt Quiz | Important | ✅ | ✅ | Allow retry after reviewing training |

#### Implementation Details

**doer-web files:**
- `app/(activation)/layout.tsx` - Activation layout wrapper
- `app/(activation)/training/page.tsx` - Training page
- `app/(activation)/quiz/page.tsx` - Quiz page
- `app/(activation)/bank-details/page.tsx` - Bank details page
- `components/activation/ActivationGate.tsx` - Gate UI component
- `components/activation/TrainingModule.tsx` - Training content
- `components/activation/QuizComponent.tsx` - Quiz UI
- `components/activation/BankDetailsForm.tsx` - Bank form

**doer_app files:**
- `lib/features/activation/screens/activation_gate_screen.dart` - Gate screen
- `lib/features/activation/screens/training_screen.dart` - Training screen
- `lib/features/activation/screens/quiz_screen.dart` - Quiz screen
- `lib/features/activation/screens/bank_details_screen.dart` - Bank screen
- `lib/features/activation/widgets/activation_stepper.dart` - Progress stepper
- `lib/features/activation/widgets/quiz_question.dart` - Quiz question widget
- `lib/features/activation/widgets/quiz_result.dart` - Result display
- `lib/features/activation/widgets/training_module_card.dart` - Training card

---

### C. Main Dashboard (D21-D32)

**Status: Both platforms COMPLETE**

| ID | Feature | Priority | doer-web | doer_app | Notes |
|----|---------|----------|----------|----------|-------|
| D21 | Top Header | Core | ✅ | ✅ | Logo/Name, Notification Bell, Menu |
| D22 | Menu Drawer / Sidebar | Core | ✅ | ✅ | User Info, Availability, Menu Items |
| D23 | Availability Toggle | Core | ✅ | ✅ | 🟢 Available / ⚪ Busy switch |
| D24 | Sidebar Menu Items | Core | ✅ | ✅ | Profile, Reviews, Statistics, Help, Settings |
| D25 | Dashboard Tabs | Core | ✅ | ✅ | "Assigned to Me" + "Open Pool" |
| D26 | Assigned to Me Tab | Core | ✅ | ✅ | Tasks from Supervisor |
| D27 | Open Pool Tab | Core | ✅ | ✅ | Available tasks to grab |
| D28 | Project Card in List | Core | ✅ | ✅ | Title, Urgency Badge, Price, Deadline |
| D29 | Accept Task Button | Core | ✅ | ✅ | With confirmation dialog |
| D30 | Urgency Badge | Important | ✅ | ✅ | 🔥 Fire icon for <6h deadlines |
| D31 | Statistics Page | Important | ✅ | ✅ | Detailed performance graphs |
| D32 | Reviews Page | Important | ✅ | ✅ | Feedback score and history |

#### Implementation Details

**doer-web files:**
- `app/(main)/dashboard/page.tsx` - Main dashboard
- `app/(main)/statistics/page.tsx` - Statistics page
- `app/(main)/reviews/page.tsx` - Reviews page
- `components/layout/Header.tsx` - Top header
- `components/layout/Sidebar.tsx` - Side navigation
- `components/layout/MainLayout.tsx` - Layout wrapper
- `components/shared/AvailabilityToggle.tsx` - Availability switch
- `components/dashboard/AssignedTaskList.tsx` - Assigned tasks
- `components/dashboard/TaskPoolList.tsx` - Open pool tasks
- `components/dashboard/ProjectCard.tsx` - Project card component

**doer_app files:**
- `lib/features/dashboard/screens/dashboard_screen.dart` - Main dashboard
- `lib/features/dashboard/screens/statistics_screen.dart` - Statistics
- `lib/features/dashboard/screens/reviews_screen.dart` - Reviews
- `lib/features/dashboard/widgets/app_header.dart` - Top header
- `lib/features/dashboard/widgets/app_drawer.dart` - Navigation drawer
- `lib/features/dashboard/widgets/project_card.dart` - Project card
- `lib/features/dashboard/widgets/urgency_badge.dart` - Urgency indicator
- `lib/features/dashboard/widgets/availability_toggle.dart` - Availability switch
- `lib/features/dashboard/widgets/stat_card.dart` - Stat display

---

### D. Active Projects (D33-D41)

**Status: Both platforms COMPLETE**

| ID | Feature | Priority | doer-web | doer_app | Notes |
|----|---------|----------|----------|----------|-------|
| D33 | Active Projects Tabs | Core | ✅ | ✅ | Active, Under Review, Completed |
| D34 | Active Tab | Core | ✅ | ✅ | Work in Progress with workspace button |
| D35 | Workspace View | Core | ✅ | ✅ | Project details, chat, file upload |
| D36 | Under Review Tab | Core | ✅ | ✅ | Submitted work, "QC in Progress" status |
| D37 | Completed Tab | Core | ✅ | ✅ | History with "Paid"/"Approved" status |
| D38 | Revision Requested Flag | Core | ✅ | ✅ | Red highlight when Supervisor rejects |
| D39 | File Upload | Core | ✅ | ✅ | Submit completed work for QC |
| D40 | Chat with Supervisor | Core | ✅ | ✅ | In-context communication |
| D41 | Deadline Display | Core | ✅ | ✅ | Clear deadline countdown |

#### Implementation Details

**doer-web files:**
- `app/(main)/projects/page.tsx` - Projects list page
- `app/(main)/projects/[id]/page.tsx` - Project detail page
- `components/projects/WorkspaceView.tsx` - Full workspace
- `components/projects/ActiveProjectsTab.tsx` - Active tab
- `components/projects/UnderReviewTab.tsx` - Under review tab
- `components/projects/CompletedTab.tsx` - Completed tab
- `components/projects/FileUpload.tsx` - File upload component
- `components/projects/ChatPanel.tsx` - Chat interface
- `components/projects/RevisionBanner.tsx` - Revision alert

**doer_app files:**
- `lib/features/workspace/screens/workspace_screen.dart` - Main workspace
- `lib/features/workspace/screens/project_detail_screen.dart` - Project details
- `lib/features/workspace/screens/submit_work_screen.dart` - Submission screen
- `lib/features/workspace/screens/revision_screen.dart` - Revision handling
- `lib/features/workspace/screens/chat_screen.dart` - Chat screen
- `lib/features/workspace/widgets/file_upload.dart` - File upload
- `lib/features/workspace/widgets/progress_tracker.dart` - Progress tracking
- `lib/features/workspace/widgets/project_info_card.dart` - Project info
- `lib/features/dashboard/widgets/deadline_countdown.dart` - Deadline timer

---

### E. Resources & Tools (D42-D46)

**Status: doer-web COMPLETE | doer_app 4/5 (80%)**

| ID | Feature | Priority | doer-web | doer_app | Notes |
|----|---------|----------|----------|----------|-------|
| D42 | Training Center | Core | ✅ | ✅ | Re-watch training videos |
| D43 | AI Report Generator | Core | ✅ | ✅ | Check AI percentage in work |
| D44 | Citation Builder | Core | ✅ | ✅ | URL → APA/Harvard reference |
| D45 | Format Templates | Core | ✅ | ❌ | **MISSING IN APP** |
| D46 | Resources Grid Layout | Important | ✅ | ✅ | Clean grid display |

#### Gap Analysis: D45 Format Templates

**What's in doer-web:**
```typescript
// components/resources/FormatTemplates.tsx
- Downloadable Word templates
- Downloadable PowerPoint templates
- Standard formatting guides
- Template preview functionality
- Download tracking
```

**Missing in doer_app:**
- No `format_templates_screen.dart`
- No template download functionality
- No template preview

#### Implementation Details

**doer-web files:**
- `app/(main)/resources/page.tsx` - Resources hub
- `components/resources/ResourcesGrid.tsx` - Grid layout
- `components/resources/TrainingCenter.tsx` - Training videos
- `components/resources/AIReportGenerator.tsx` - AI checker
- `components/resources/CitationBuilder.tsx` - Citation generator
- `components/resources/FormatTemplates.tsx` - **Template downloads**

**doer_app files:**
- `lib/features/resources/screens/resources_hub_screen.dart` - Resources hub
- `lib/features/resources/screens/training_center_screen.dart` - Training
- `lib/features/resources/screens/ai_checker_screen.dart` - AI checker
- `lib/features/resources/screens/citation_builder_screen.dart` - Citations
- ❌ `format_templates_screen.dart` - **MISSING**

---

### F. Profile & Earnings (D47-D57)

**Status: doer-web COMPLETE | doer_app 8/11 (73%)**

| ID | Feature | Priority | doer-web | doer_app | Notes |
|----|---------|----------|----------|----------|-------|
| D47 | Scorecard Section | Core | ✅ | ✅ | Active, Completed, Earnings, Rating |
| D48 | Edit Profile | Core | ✅ | ✅ | Update qualifications and skills |
| D49 | Payment History | Core | ✅ | ✅ | Past withdrawals and pending payments |
| D50 | Bank Details Management | Core | ✅ | ✅ | Edit/Update bank info |
| D51 | Contact Support | Core | ✅ | ✅ | WhatsApp/Ticket system |
| D52 | Log Out | Core | ✅ | ✅ | Profile footer action |
| D53 | Request Payout Button | Core | ✅ | ⚠️ | Web has dedicated component |
| D54 | Pending Payments Display | Important | ✅ | ✅ | Earnings awaiting clearance |
| D55 | Earnings Graph | Optional | ✅ | ❌ | **MISSING IN APP** |
| D56 | Rating Breakdown | Optional | ✅ | ❌ | **MISSING IN APP** |
| D57 | Skill Verification Status | Optional | ✅ | ❌ | **MISSING IN APP** |

#### Gap Analysis: D55 Earnings Graph

**What's in doer-web:**
```typescript
// components/profile/EarningsGraph.tsx
- Visual chart showing earnings over time
- Daily/Weekly/Monthly views
- Interactive data points
- Trend indicators
- Export functionality
```

**Missing in doer_app:**
- No earnings visualization
- No chart widget
- Only shows total earnings number

#### Gap Analysis: D56 Rating Breakdown

**What's in doer-web:**
```typescript
// components/profile/RatingBreakdown.tsx
- Overall rating display
- Quality rating (separate metric)
- Timeliness rating (separate metric)
- Communication rating (separate metric)
- Total reviews count
- Historical trend
```

**Missing in doer_app:**
- Only shows overall rating
- No breakdown by category
- No detailed feedback view

#### Gap Analysis: D57 Skill Verification Status

**What's in doer-web:**
```typescript
// components/profile/SkillVerification.tsx
- List of declared skills
- Verification status per skill (verified/pending/unverified)
- Request verification button
- Verification badge display
```

**Missing in doer_app:**
- Skills shown but no verification status
- No verification workflow

#### Implementation Details

**doer-web files:**
- `app/(main)/profile/page.tsx` - Profile hub
- `components/profile/Scorecard.tsx` - Stats card
- `components/profile/EditProfile.tsx` - Edit form
- `components/profile/PaymentHistory.tsx` - Transaction list
- `components/profile/BankSettings.tsx` - Bank management
- `components/profile/SupportSection.tsx` - Help & support
- `components/profile/RequestPayout.tsx` - Payout request
- `components/profile/EarningsGraph.tsx` - **Earnings chart**
- `components/profile/RatingBreakdown.tsx` - **Rating details**
- `components/profile/SkillVerification.tsx` - **Skill verification**

**doer_app files:**
- `lib/features/profile/screens/profile_screen.dart` - Profile screen
- `lib/features/profile/screens/edit_profile_screen.dart` - Edit profile
- `lib/features/profile/screens/payment_history_screen.dart` - Payments
- `lib/features/profile/screens/settings_screen.dart` - Settings
- `lib/features/profile/screens/notifications_screen.dart` - Notifications
- ❌ `earnings_graph_screen.dart` - **MISSING**
- ❌ `rating_breakdown_screen.dart` - **MISSING**
- ❌ `skill_verification_screen.dart` - **MISSING**

---

## 4. Feature Gaps Analysis

### Missing Features in doer_app

| ID | Feature | Priority | Impact | Effort |
|----|---------|----------|--------|--------|
| D45 | Format Templates | Core | Medium | Low |
| D55 | Earnings Graph | Optional | Low | Medium |
| D56 | Rating Breakdown | Optional | Low | Low |
| D57 | Skill Verification | Optional | Low | Medium |

### Detailed Gap Descriptions

#### Gap 1: Format Templates (D45) - CORE PRIORITY

**Description:** Downloadable Word/PowerPoint templates for standard formatting

**User Impact:**
- Doers cannot access pre-formatted templates on mobile
- Must switch to web for template downloads
- Inconsistent experience across platforms

**Required Implementation:**
1. Create `lib/features/resources/screens/format_templates_screen.dart`
2. Add template list with download buttons
3. Implement file download using `url_launcher` or `dio`
4. Add template preview (optional)

**Estimated Effort:** 4-6 hours

---

#### Gap 2: Earnings Graph (D55) - OPTIONAL

**Description:** Visual chart showing earnings over time with trends

**User Impact:**
- Doers cannot visualize earning patterns
- No insight into earning trends
- Reduced engagement with earnings data

**Required Implementation:**
1. Add `fl_chart` or `syncfusion_flutter_charts` package
2. Create earnings graph widget
3. Integrate with profile screen
4. Add time period selector (Daily/Weekly/Monthly)

**Estimated Effort:** 6-8 hours

---

#### Gap 3: Rating Breakdown (D56) - OPTIONAL

**Description:** Detailed rating breakdown by category (Quality, Timeliness, Communication)

**User Impact:**
- Doers see only overall rating
- No actionable feedback on specific areas
- Harder to identify improvement areas

**Required Implementation:**
1. Create rating breakdown widget
2. Add category-specific rating display
3. Show historical trend per category
4. Integrate with profile/reviews screen

**Estimated Effort:** 3-4 hours

---

#### Gap 4: Skill Verification (D57) - OPTIONAL

**Description:** Show verification status for each declared skill

**User Impact:**
- No visibility into skill verification status
- Cannot request skill verification
- Missing trust indicators

**Required Implementation:**
1. Create skill verification screen/widget
2. Add verification status badges
3. Implement verification request flow
4. Show verification history

**Estimated Effort:** 4-6 hours

---

## 5. File Structure Comparison

### doer-web Structure
```
doer-web/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── (onboarding)/
│   │   ├── welcome/page.tsx
│   │   └── profile-setup/page.tsx
│   ├── (activation)/
│   │   ├── training/page.tsx
│   │   ├── quiz/page.tsx
│   │   └── bank-details/page.tsx
│   └── (main)/
│       ├── dashboard/page.tsx
│       ├── projects/page.tsx
│       ├── projects/[id]/page.tsx
│       ├── resources/page.tsx
│       ├── statistics/page.tsx
│       ├── reviews/page.tsx
│       └── profile/page.tsx
├── components/
│   ├── onboarding/
│   ├── activation/
│   ├── dashboard/
│   ├── projects/
│   ├── resources/
│   ├── profile/
│   └── layout/
└── services/
```

### doer_app Structure
```
doer_app/
└── lib/
    ├── features/
    │   ├── splash/
    │   │   └── splash_screen.dart
    │   ├── auth/
    │   │   └── screens/
    │   ├── onboarding/
    │   │   ├── screens/
    │   │   └── widgets/
    │   ├── activation/
    │   │   ├── screens/
    │   │   └── widgets/
    │   ├── dashboard/
    │   │   ├── screens/
    │   │   └── widgets/
    │   ├── workspace/
    │   │   ├── screens/
    │   │   └── widgets/
    │   ├── resources/
    │   │   └── screens/
    │   └── profile/
    │       └── screens/
    ├── providers/
    ├── data/
    │   ├── models/
    │   ├── repositories/
    │   └── mock/
    ├── core/
    │   ├── constants/
    │   ├── router/
    │   └── theme/
    └── shared/
        ├── widgets/
        └── utils/
```

---

## 6. Recommendations

### Immediate Actions (Before Launch)

1. **Implement D45 Format Templates** (Core Priority)
   - Create template download screen
   - Add to resources hub navigation
   - Test file downloads on iOS and Android

### Post-Launch Enhancements

2. **Add D55 Earnings Graph** (Optional)
   - Integrate charting library
   - Create earnings visualization
   - Add to profile screen

3. **Add D56 Rating Breakdown** (Optional)
   - Create rating detail component
   - Show category breakdowns
   - Add to reviews section

4. **Add D57 Skill Verification** (Optional)
   - Create verification UI
   - Add request verification flow
   - Display verification badges

### Code Quality Improvements

5. **Ensure Consistent API Integration**
   - Both platforms should use same Supabase queries
   - Standardize response handling
   - Share API documentation

6. **Standardize UI Patterns**
   - Ensure visual consistency between platforms
   - Use same color coding for statuses
   - Match animation timing

---

## 7. Implementation Priority Matrix

| Priority | Feature | Platform | Effort | Business Impact |
|----------|---------|----------|--------|-----------------|
| 🔴 HIGH | D45 Format Templates | doer_app | Low | Medium |
| 🟡 MEDIUM | D55 Earnings Graph | doer_app | Medium | Low |
| 🟢 LOW | D56 Rating Breakdown | doer_app | Low | Low |
| 🟢 LOW | D57 Skill Verification | doer_app | Medium | Low |

### Sprint Planning Suggestion

**Sprint 1 (Before Launch):**
- [ ] D45 Format Templates (4-6 hours)

**Sprint 2 (Post-Launch Week 1):**
- [ ] D55 Earnings Graph (6-8 hours)
- [ ] D56 Rating Breakdown (3-4 hours)

**Sprint 3 (Post-Launch Week 2):**
- [ ] D57 Skill Verification (4-6 hours)

---

## Appendix: Feature ID Reference

| ID Range | Category | Count |
|----------|----------|-------|
| D01-D12 | Onboarding & Registration | 12 |
| D13-D20 | Activation Flow | 8 |
| D21-D32 | Main Dashboard | 12 |
| D33-D41 | Active Projects | 9 |
| D42-D46 | Resources & Tools | 5 |
| D47-D57 | Profile & Earnings | 11 |
| **TOTAL** | | **57** |

---

*Document generated by feature analysis on December 28, 2025*
*Reference: AssignX_Complete_Features.md*
