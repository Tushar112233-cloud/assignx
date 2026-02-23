# User-Web Application Issues Report

> **Generated:** December 27, 2025
> **Reviewed By:** Claude Code
> **Scope:** Database integration, authentication, data fetching, and page functionality

---

## Executive Summary

The user-web application has a solid foundation with properly configured Supabase authentication, well-structured Zustand stores, and correct server actions. However, **several pages are using mock/hardcoded data instead of querying the database**, and there are gaps in route protection and type definitions.

| Category | Status |
|----------|--------|
| Authentication | Working |
| Route Protection | Partial |
| Data Fetching | Mixed (some pages use mocks) |
| Form Submissions | Incomplete |
| Type Safety | Incomplete |

---

## Table of Contents

1. [Critical Issues](#critical-issues)
2. [Moderate Issues](#moderate-issues)
3. [Minor Issues](#minor-issues)
4. [Working Components](#working-components)
5. [Recommended Fixes](#recommended-fixes)

---

## Critical Issues

### ISSUE-001: Profile Page Uses Mock Data

**Severity:** Critical
**File:** `app/(dashboard)/profile/page.tsx`
**Lines:** 39-43

**Current Implementation:**
```typescript
// In a real app, these would come from API/context
const [profile, setProfile] = useState(mockUserProfile);
const [academicInfo, setAcademicInfo] = useState(mockAcademicInfo);
const [preferences, setPreferences] = useState(mockUserPreferences);
const [security, setSecurity] = useState(mockSecuritySettings);
const [subscription, setSubscription] = useState(mockUserSubscription);
```

**Problem:**
- Profile page displays hardcoded mock data from `lib/data/profile.ts`
- User's actual profile from Supabase is never fetched
- All profile updates are only saved to local state, not persisted to database

**Impact:**
- Users see fake data instead of their actual profile
- Profile changes are lost on page refresh
- Academic info, preferences, and security settings don't persist

**Required Fix:**
- Use `useUserStore` to fetch user profile
- Create server actions for updating profile sections
- Fetch student/professional extension data based on user type

---

### ISSUE-002: Project Detail Page Uses Mock JSON

**Severity:** Critical
**File:** `app/project/[id]/page.tsx`
**Lines:** 20-32

**Current Implementation:**
```typescript
import projectDetailsData from "@/lib/data/project-details.json";

function getProjectDetail(id: string): ProjectDetail | null {
  const data = projectDetailsData as Record<string, ProjectDetail>;
  return data[id] || null;
}
```

**Problem:**
- Project details are loaded from a static JSON file
- The `getProjectById` server action exists in `lib/actions/data.ts` but is not used
- Real project data from database is never displayed

**Impact:**
- Users cannot view their actual project details
- Project status, deliverables, timeline are all fake
- Chat messages, files, and quality reports are not real

**Existing Server Action (unused):**
```typescript
// lib/actions/data.ts - Line 72-100
export async function getProjectById(id: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: project, error } = await supabase
    .from("projects")
    .select(`
      *,
      subject:subjects (id, name, icon, slug),
      reference_style:reference_styles (id, name, short_name),
      files:project_files (*),
      deliverables:project_deliverables (*),
      quotes:project_quotes (*),
      revisions:project_revisions (*),
      timeline:project_timeline (*)
    `)
    .eq("id", id)
    .eq("user_id", user.id)
    .single();

  return project;
}
```

---

### ISSUE-003: Connect Page Uses Mock Data

**Severity:** Critical
**File:** `app/(dashboard)/connect/page.tsx`
**Lines:** 18-23

**Current Implementation:**
```typescript
import {
  featuredTutors,
  allTutors,
  sharedResources,
  studyGroups,
} from "@/lib/data/connect";
```

**Problem:**
- All tutor, resource, and study group data is hardcoded
- No database tables exist for this feature (tutors, resources, study_groups)
- This appears to be a placeholder feature

**Impact:**
- Connect/marketplace feature is non-functional
- Users see fake tutors and resources

**Note:** This may be intentional if the Connect feature is planned for future development. However, if this feature should be live, database tables need to be created.

---

### ISSUE-004: New Project Form Doesn't Save to Database

**Severity:** Critical
**File:** `components/add-project/new-project-form.tsx`
**Lines:** 91-101

**Current Implementation:**
```typescript
const handleFinalSubmit = step4Form.handleSubmit(async (data) => {
  setIsSubmitting(true);
  try {
    // Mock submission - just waits and generates fake IDs
    await new Promise((resolve) => setTimeout(resolve, 1500));
    const projectId = `proj_${Date.now()}`;
    const projectNumber = `AX-${Math.floor(100000 + Math.random() * 900000)}`;
    onSuccess(projectId, projectNumber);
  } catch {
    toast.error("Something went wrong. Please try again.");
    setIsSubmitting(false);
  }
});
```

**Problem:**
- Form submission just waits 1.5 seconds and generates fake IDs
- No data is sent to Supabase
- Files are not uploaded to storage
- Project is never created in the database

**Impact:**
- Users cannot submit new projects
- Projects list will be empty (unless manually inserted into DB)
- Core business functionality is broken

**Required Server Action:**
```typescript
// Needs to be created in lib/actions/data.ts
export async function createProject(data: {
  serviceType: string;
  title: string;
  subjectId: string;
  topic?: string;
  wordCount: number;
  referenceStyleId?: string;
  deadline: string;
  urgencyLevel: string;
  instructions?: string;
  files?: File[];
}) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return { error: "Not authenticated" };

  // 1. Create project record
  // 2. Upload files to storage
  // 3. Create project_files records
  // 4. Return project id and number
}
```

---

### ISSUE-005: Incomplete Route Protection

**Severity:** Critical
**File:** `lib/supabase/middleware.ts`
**Lines:** 43-47

**Current Implementation:**
```typescript
const protectedRoutes = ["/projects", "/profile", "/connect"];
const isProtectedRoute = protectedRoutes.some((route) =>
  request.nextUrl.pathname.startsWith(route)
);
```

**Problem:**
Protected routes list is incomplete. Missing routes:
- `/home` - Dashboard home page
- `/settings` - App settings page
- `/support` - Help & support page
- `/project/[id]` - Project detail pages

**Impact:**
- Unauthenticated users can access dashboard pages
- May cause errors when pages try to fetch user-specific data
- Security vulnerability

**Required Fix:**
```typescript
const protectedRoutes = [
  "/home",
  "/projects",
  "/project",  // Covers /project/[id]
  "/profile",
  "/connect",
  "/settings",
  "/support",
];
```

---

## Moderate Issues

### ISSUE-006: Project Status Type Mismatch

**Severity:** Moderate
**Files:**
- `stores/project-store.ts` (Lines 7-19)
- `types/database.ts` (Lines 59-72)

**Database Schema (from database.md):**
```sql
project_status ENUM:
draft | submitted | analyzing | quoted | payment_pending | paid |
assigning | assigned | in_progress | submitted_for_qc | qc_in_progress |
qc_approved | qc_rejected | delivered | revision_requested | in_revision |
completed | auto_approved | cancelled | refunded
```

**Current Store Definition:**
```typescript
export type ProjectStatus =
  | "submitted"
  | "analyzing"
  | "quoted"
  | "payment_pending"
  | "paid"
  | "assigned"
  | "in_progress"
  | "delivered"
  | "qc_approved"
  | "completed"
  | "cancelled"
  | "refunded";
```

**Missing Statuses:**
- `draft`
- `assigning`
- `submitted_for_qc`
- `qc_in_progress`
- `qc_rejected`
- `revision_requested`
- `in_revision`
- `auto_approved`

**Tab Mapping Issue:**
```typescript
const tabStatuses: Record<ProjectTab, ProjectStatus[]> = {
  in_review: ["submitted", "analyzing", "quoted", "payment_pending"],
  in_progress: ["paid", "assigned", "in_progress"],
  for_review: ["delivered", "qc_approved"],
  history: ["completed", "cancelled", "refunded"],
};
```

Projects with statuses like `revision_requested`, `in_revision`, `qc_rejected` will not appear in any tab.

---

### ISSUE-007: Database Types File is Incomplete

**Severity:** Moderate
**File:** `types/database.ts`

**Current State:**
Only defines the `profiles` table with 9 columns.

**Missing:**
- 63 other tables from the schema
- All enum types
- Proper Insert/Update types for all tables

**Impact:**
- No TypeScript type safety for database queries
- IDE autocomplete doesn't work for table columns
- Runtime errors possible from typos in column names

**Recommendation:**
Generate types using Supabase CLI:
```bash
npx supabase gen types typescript --project-id <project-id> > types/database.ts
```

---

### ISSUE-008: Proofreading, Report, and Consultation Forms Mock Submission

**Severity:** Moderate
**Files:**
- `components/add-project/proofreading-form.tsx`
- `components/add-project/report-form.tsx`
- `components/add-project/consultation-form.tsx`

**Problem:**
Like the main project form, these specialized forms also mock their submissions and don't save to the database.

---

## Minor Issues

### ISSUE-009: User Feedback Table Schema Mismatch

**Severity:** Minor
**File:** `lib/actions/data.ts`
**Lines:** 454-461

**Current Implementation:**
```typescript
const { error } = await supabase
  .from("user_feedback")
  .insert({
    profile_id: user.id,      // Should be: user_id
    feedback_type: data.type, // Column doesn't exist
    content: data.message,    // Column doesn't exist
    rating: data.rating,      // Column doesn't exist
  });
```

**Database Schema (from database.md):**
```
user_feedback:
- user_id (not profile_id)
- overall_satisfaction
- would_recommend
- feedback_text (not content)
- improvement_suggestions
- nps_score
```

---

### ISSUE-010: Support Ticket Creation - Unnecessary Custom Number

**Severity:** Minor
**File:** `lib/actions/data.ts`
**Lines:** 315-317

**Current Implementation:**
```typescript
const ticketNumber = `TKT-${Date.now().toString(36).toUpperCase()}`;
```

**Issue:**
Database has a trigger `generate_ticket_number()` that auto-generates ticket numbers in format `TKT-YYYY-XXXXX`. The manual generation here may conflict or be unnecessary.

---

### ISSUE-011: Reference Styles Query Missing display_order Column

**Severity:** Minor
**File:** `lib/actions/data.ts`
**Lines:** 427-431

**Current Implementation:**
```typescript
const { data: styles, error } = await supabase
  .from("reference_styles")
  .select("*")
  .eq("is_active", true)
  .order("display_order", { ascending: true });
```

**Issue:**
The `reference_styles` table in the schema doesn't have a `display_order` column. This query may fail or return unsorted results.

---

## Working Components

The following components are correctly implemented and functional:

### Authentication
| Component | File | Status |
|-----------|------|--------|
| Supabase Browser Client | `lib/supabase/client.ts` | Working |
| Supabase Server Client | `lib/supabase/server.ts` | Working |
| Session Middleware | `lib/supabase/middleware.ts` | Working |
| Google OAuth Sign In | `lib/actions/auth.ts` | Working |
| Auth Callback Handler | `app/auth/callback/route.ts` | Working |
| Profile Creation | `lib/actions/auth.ts` | Working |

### Stores (Zustand)
| Store | File | Status |
|-------|------|--------|
| User Store | `stores/user-store.ts` | Working - fetches from Supabase |
| Project Store | `stores/project-store.ts` | Working - fetches from Supabase |
| Wallet Store | `stores/wallet-store.ts` | Working - fetches from Supabase |
| Notification Store | `stores/notification-store.ts` | Working - fetches from Supabase |

### Server Actions
| Action | File | Status |
|--------|------|--------|
| getProfile | `lib/actions/data.ts` | Working |
| getProjects | `lib/actions/data.ts` | Working |
| getProjectById | `lib/actions/data.ts` | Working but unused |
| getNotifications | `lib/actions/data.ts` | Working |
| markNotificationRead | `lib/actions/data.ts` | Working |
| getWallet | `lib/actions/data.ts` | Working |
| getWalletTransactions | `lib/actions/data.ts` | Working |
| getBanners | `lib/actions/data.ts` | Working |
| getSupportTickets | `lib/actions/data.ts` | Working |
| createSupportTicket | `lib/actions/data.ts` | Working |
| getUniversities | `lib/actions/data.ts` | Working |
| getCourses | `lib/actions/data.ts` | Working |
| getSubjects | `lib/actions/data.ts` | Working |
| getIndustries | `lib/actions/data.ts` | Working |

### Pages
| Page | File | Status |
|------|------|--------|
| Login | `app/(auth)/login/page.tsx` | Working |
| Onboarding | `app/(auth)/onboarding/page.tsx` | Working |
| Dashboard Home | `app/(dashboard)/home/page.tsx` | Working |
| Projects List | `app/(dashboard)/projects/page.tsx` | Working |
| Settings | `app/(dashboard)/settings/page.tsx` | Working |

### Components
| Component | File | Status |
|-----------|------|--------|
| Personalized Greeting | `components/dashboard/personalized-greeting.tsx` | Working |
| Wallet Pill | `components/dashboard/wallet-pill.tsx` | Working |
| Notification Bell | `components/dashboard/notification-bell.tsx` | Working |
| Project List | `components/projects/project-list.tsx` | Working |
| Ticket History | `components/support/ticket-history.tsx` | Working |

---

## Recommended Fixes

### Priority 1: Critical Fixes (Required for Basic Functionality)

1. **Fix Route Protection**
   - Add missing routes to protected routes array
   - Estimated time: 5 minutes

2. **Create Project Submission Action**
   - Create `createProject` server action
   - Integrate with new project form
   - Handle file uploads
   - Estimated time: 2-3 hours

3. **Fix Project Detail Page**
   - Replace mock JSON with `getProjectById` call
   - Update component to handle loading states
   - Estimated time: 1 hour

4. **Fix Profile Page**
   - Use `useUserStore` for profile data
   - Create server actions for profile updates
   - Handle student vs professional data
   - Estimated time: 2-3 hours

### Priority 2: Important Fixes

5. **Update Project Status Types**
   - Add missing statuses to TypeScript types
   - Update tab status mapping
   - Estimated time: 30 minutes

6. **Generate Proper Database Types**
   - Run Supabase type generation
   - Replace manual type definitions
   - Estimated time: 30 minutes

7. **Fix User Feedback Schema**
   - Update column names to match database
   - Estimated time: 15 minutes

### Priority 3: Nice to Have

8. **Connect Feature Database**
   - Design and create tutors/resources tables
   - Or mark as "Coming Soon" feature
   - Estimated time: Varies

---

## Appendix: File Reference

### Files with Issues
```
app/(dashboard)/profile/page.tsx      - Uses mock data
app/(dashboard)/connect/page.tsx      - Uses mock data
app/project/[id]/page.tsx             - Uses mock JSON
components/add-project/new-project-form.tsx - Mock submission
lib/supabase/middleware.ts            - Incomplete route protection
lib/actions/data.ts                   - Minor schema mismatches
stores/project-store.ts               - Missing status types
types/database.ts                     - Incomplete types
```

### Files Working Correctly
```
lib/supabase/client.ts
lib/supabase/server.ts
lib/actions/auth.ts
app/auth/callback/route.ts
stores/user-store.ts
stores/wallet-store.ts
stores/notification-store.ts
components/dashboard/personalized-greeting.tsx
components/dashboard/wallet-pill.tsx
components/dashboard/notification-bell.tsx
components/projects/project-list.tsx
components/support/ticket-history.tsx
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-27 | Claude Code | Initial comprehensive review |
