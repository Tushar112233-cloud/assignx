# Supervisor Web Application - Issues Report

> **Generated:** December 27, 2025
> **Scope:** Authentication, Supabase Queries, Page Implementations
> **Status:** ALL ISSUES RESOLVED

---

## Resolution Summary

All 6 issues identified in this report have been fixed and committed:

| Commit | Description |
|--------|-------------|
| `40e78be` | fix(profile): Replace mock data with real database queries and implement logout |
| `dfaaed1` | fix(projects): Implement real QC approve/reject handlers |
| `e1b37b8` | fix(hooks): Implement subjectId filter in useDoers hook |
| `1f597e6` | feat(chat): Add chat hook with file upload support |
| `90d5c8f` | fix(dashboard): Replace hardcoded subjects with real expertise data |

**Migration Applied:** `create_chat_files_storage_bucket` - Creates storage bucket for chat file uploads

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Critical Issues](#critical-issues)
3. [Medium Priority Issues](#medium-priority-issues)
4. [Low Priority Issues](#low-priority-issues)
5. [Code Quality Observations](#code-quality-observations)
6. [Recommended Fixes](#recommended-fixes)

---

## Executive Summary

| Category | Status | Issues Found |
|----------|--------|--------------|
| Authentication | **Working** | 0 Critical |
| Supabase Queries | **Fixed** | 1 Medium (RESOLVED) |
| Dashboard Page | **Fixed** | 1 Low (RESOLVED) |
| Projects Page | **Fixed** | 1 Medium (RESOLVED) |
| Profile Page | **Fixed** | 2 Critical (RESOLVED) |
| Chat System | **Fixed** | 1 Low (RESOLVED) |
| Doers Management | **Fixed** | 1 Medium (RESOLVED) |

**Total Issues:** 6 (2 Critical, 2 Medium, 2 Low) - **ALL RESOLVED**

---

## Critical Issues

### Issue #1: Profile Page Uses Mock Data Instead of Real Database

**Severity:** Critical
**File:** `app/(dashboard)/profile/page.tsx`
**Lines:** 45-72

#### Description
The profile page displays hardcoded mock data instead of fetching the actual supervisor profile from Supabase. This means:
- Users see fake data (Dr. Rajesh Kumar) instead of their own profile
- Profile edits are not persisted to the database
- Statistics shown are completely fabricated

#### Current Code
```tsx
// Line 45-72 - Hardcoded mock profile
const MOCK_PROFILE: SupervisorProfile = {
  id: "sup-1",
  full_name: "Dr. Rajesh Kumar",
  email: "rajesh.kumar@example.com",
  phone: "+91 98765 43210",
  avatar_url: "",
  qualification: "Ph.D. in Economics",
  years_of_experience: 12,
  expertise_areas: [
    "Economics",
    "Finance",
    "Business Studies",
    "Statistics",
    "Marketing",
  ],
  bio: "Experienced academic professional...",
  rating: 4.7,
  total_reviews: 128,
  joined_at: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000).toISOString(),
  is_available: true,
  bank_details: {
    bank_name: "HDFC Bank",
    account_number: "****4521",
    ifsc_code: "HDFC0001234",
    upi_id: "rajesh@hdfc",
    account_holder_name: "Rajesh Kumar",
  },
}
```

#### Expected Behavior
The page should use the `useSupervisor()` hook to fetch real data:
```tsx
import { useSupervisor, useSupervisorStats } from "@/hooks"

export default function ProfilePage() {
  const { supervisor, profile, isLoading, error } = useSupervisor()
  const { stats } = useSupervisorStats()

  // Use supervisor and profile data instead of MOCK_PROFILE
}
```

#### Impact
- Users cannot view their actual profile information
- Profile editing functionality is broken
- Trust issues if users notice fake data

#### Database Tables Affected
- `profiles` - Should be queried for user info
- `supervisors` - Should be queried for supervisor-specific data
- `supervisor_reviews` - For actual review count and ratings

---

### Issue #2: Profile Logout Does Not Actually Sign Out User

**Severity:** Critical
**File:** `app/(dashboard)/profile/page.tsx`
**Lines:** 134-137

#### Description
The logout button on the profile page only logs to console and does not actually sign the user out of the application.

#### Current Code
```tsx
const handleLogout = () => {
  // TODO: Implement logout
  console.log("Logging out...")
}
```

#### Expected Behavior
```tsx
import { useAuth } from "@/hooks"

export default function ProfilePage() {
  const { signOut } = useAuth()

  const handleLogout = async () => {
    await signOut()
    // signOut already handles redirect to /login
  }
}
```

#### Impact
- Users cannot log out from the profile page
- Security concern - users may leave sessions active unintentionally
- Breaks expected UX flow

#### Related Files
- `hooks/use-auth.ts` - Contains the `signOut` function that should be used

---

## Medium Priority Issues

### Issue #3: Project Actions Use Placeholder Console Logs

**Severity:** Medium
**File:** `app/(dashboard)/projects/page.tsx`
**Lines:** 156-170

#### Description
The approve and reject handlers for QC review only log to console instead of making actual API calls to update project status.

#### Current Code
```tsx
const handleApprove = async (projectId: string, message?: string) => {
  // In production, call API to approve project
  console.log("Approving project:", projectId, message)
  await refetch()
}

const handleReject = async (
  projectId: string,
  feedback: string,
  severity: "minor" | "major" | "critical"
) => {
  // In production, call API to reject project
  console.log("Rejecting project:", projectId, feedback, severity)
  await refetch()
}
```

#### Expected Behavior
```tsx
import { createClient } from "@/lib/supabase/client"

const handleApprove = async (projectId: string, message?: string) => {
  const supabase = createClient()

  const { error } = await supabase
    .from("projects")
    .update({
      status: "qc_approved",
      status_updated_at: new Date().toISOString(),
      completion_notes: message,
    })
    .eq("id", projectId)

  if (error) {
    toast.error("Failed to approve project")
    return
  }

  toast.success("Project approved successfully")
  await refetch()
}

const handleReject = async (
  projectId: string,
  feedback: string,
  severity: "minor" | "major" | "critical"
) => {
  const supabase = createClient()

  // Create revision request
  const { error: revisionError } = await supabase
    .from("project_revisions")
    .insert({
      project_id: projectId,
      revision_number: 1, // Should calculate based on existing revisions
      requested_by: userId,
      requested_by_type: "supervisor",
      feedback,
      status: "pending",
    })

  // Update project status
  const { error: projectError } = await supabase
    .from("projects")
    .update({
      status: "qc_rejected",
      status_updated_at: new Date().toISOString(),
    })
    .eq("id", projectId)

  if (revisionError || projectError) {
    toast.error("Failed to reject project")
    return
  }

  toast.success("Revision requested")
  await refetch()
}
```

#### Impact
- Supervisors cannot actually approve or reject projects through the UI
- QC workflow is completely non-functional
- Projects remain stuck in `submitted_for_qc` status

#### Database Tables Affected
- `projects` - Status needs to be updated
- `project_revisions` - New revision records need to be created
- `project_status_history` - Automatically updated by trigger

---

### Issue #4: Unused subjectId Filter in useDoers Hook

**Severity:** Medium
**File:** `hooks/use-doers.ts`
**Lines:** 78

#### Description
The `subjectId` parameter is accepted and included in the dependency array but is never actually used to filter the query.

#### Current Code
```tsx
interface UseDoersOptions {
  subjectId?: string  // Accepted but not used
  isAvailable?: boolean
  limit?: number
  offset?: number
  searchQuery?: string
}

const fetchDoers = useCallback(async () => {
  // ... query building

  // subjectId is NEVER used to filter the query!

}, [subjectId, isAvailable, limit, offset, searchQuery])  // In deps but not used
```

#### Expected Behavior
```tsx
const fetchDoers = useCallback(async () => {
  let query = supabase
    .from("doers")
    .select(`
      *,
      profiles!profile_id (*),
      doer_subjects!inner (
        subjects (*)
      )
    `, { count: "exact" })
    .eq("is_activated", true)

  // Filter by subject if provided
  if (subjectId) {
    query = supabase
      .from("doers")
      .select(`
        *,
        profiles!profile_id (*),
        doer_subjects!inner (
          subjects (*)
        )
      `, { count: "exact" })
      .eq("is_activated", true)
      .eq("doer_subjects.subject_id", subjectId)
  }

  // ... rest of query
}, [subjectId, isAvailable, limit, offset, searchQuery])
```

#### Impact
- Cannot filter doers by subject/expertise area
- When assigning doers to projects, supervisors can't find specialists
- Feature appears to work but doesn't actually filter

#### Database Tables Affected
- `doer_subjects` - Join table that should be used for filtering

---

## Low Priority Issues

### Issue #5: Chat File Upload References Non-Existent Storage Bucket

**Severity:** Low
**File:** `hooks/use-chat.ts`
**Lines:** 221-232

#### Description
The chat file upload feature references a Supabase storage bucket named `chat-files` that may not exist in the database.

#### Current Code
```tsx
const sendFile = useCallback(async (file: File) => {
  // ...

  const { data: uploadData, error: uploadError } = await supabase.storage
    .from("chat-files")  // This bucket must exist
    .upload(fileName, file)

  // ...
}, [roomId])
```

#### Required Action
Ensure the storage bucket exists in Supabase:

```sql
-- Run in Supabase SQL Editor
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-files', 'chat-files', true);

-- Set up RLS policies
CREATE POLICY "Authenticated users can upload chat files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'chat-files');

CREATE POLICY "Users can view chat files"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'chat-files');
```

#### Impact
- File sharing in chat will fail silently
- Error only visible in console/network tab
- Users may think files uploaded when they didn't

---

### Issue #6: Dashboard Filter Uses Hardcoded Subject List

**Severity:** Low
**File:** `app/(dashboard)/dashboard/page.tsx`
**Lines:** 163-165

#### Description
The subject filter in the RequestFilter component uses hardcoded values instead of fetching from the `subjects` table.

#### Current Code
```tsx
<RequestFilter
  supervisorFields={["computer_science", "engineering"]}  // Hardcoded
  onFilterChange={handleFilterChange}
/>
```

#### Expected Behavior
```tsx
// Fetch supervisor's expertise areas from database
const { supervisor } = useSupervisor()

// Get subjects from supervisor_expertise table
const expertiseSubjects = supervisor?.expertise || []

<RequestFilter
  supervisorFields={expertiseSubjects.map(s => s.subject_id)}
  onFilterChange={handleFilterChange}
/>
```

#### Impact
- Filter doesn't reflect actual supervisor expertise
- May show incorrect filtering options
- Minor UX issue

---

## Code Quality Observations

### Positive Patterns Found

1. **Proper TypeScript Usage**
   - All hooks have proper type definitions
   - Database types are auto-generated and properly used
   - Good use of generics for reusable types

2. **Real-time Subscriptions**
   - Chat and notifications properly implement Supabase real-time
   - Proper cleanup in useEffect return statements

3. **Error Handling**
   - Most hooks have try-catch blocks
   - Errors are stored in state for UI display

4. **Query Optimization**
   - Uses `{ count: "exact" }` for pagination
   - Proper use of `.range()` for offset pagination

### Areas for Improvement

1. **Inconsistent Loading States**
   - Some pages show skeletons, others don't
   - Consider a unified loading component

2. **Missing Error Boundaries**
   - Query failures may crash components
   - Should wrap pages in error boundaries

3. **No Query Caching**
   - React Query is installed but some hooks don't use it
   - Could benefit from stale-while-revalidate pattern

---

## Recommended Fixes

### Priority 1 - Critical (Fix Immediately)

| Issue | File | Estimated Time |
|-------|------|----------------|
| Profile uses mock data | `profile/page.tsx` | 1-2 hours |
| Logout not working | `profile/page.tsx` | 15 minutes |

### Priority 2 - Medium (Fix This Week)

| Issue | File | Estimated Time |
|-------|------|----------------|
| QC approve/reject placeholder | `projects/page.tsx` | 2-3 hours |
| Subject filter not working | `use-doers.ts` | 1 hour |

### Priority 3 - Low (Fix When Convenient)

| Issue | File | Estimated Time |
|-------|------|----------------|
| Chat storage bucket | Supabase Dashboard | 30 minutes |
| Hardcoded filter subjects | `dashboard/page.tsx` | 30 minutes |

---

## Verification Checklist

After fixing issues, verify:

- [ ] Profile page shows logged-in user's actual data
- [ ] Profile edit saves to database and persists on refresh
- [ ] Logout button successfully signs out and redirects to login
- [ ] QC approve updates project status to `qc_approved`
- [ ] QC reject creates revision record and updates status to `qc_rejected`
- [ ] Doer list can be filtered by subject
- [ ] Chat file uploads work without errors
- [ ] Dashboard filter shows supervisor's actual expertise areas

---

## Appendix: Related Database Schema

### Tables Referenced in Issues

```
profiles
├── id (UUID, PK)
├── email
├── full_name
├── phone
├── avatar_url
├── user_type
└── ...

supervisors
├── id (UUID, PK)
├── profile_id (FK → profiles.id)
├── qualification
├── years_of_experience
├── is_available
├── average_rating
├── total_reviews
└── ...

supervisor_expertise
├── id (UUID, PK)
├── supervisor_id (FK → supervisors.id)
├── subject_id (FK → subjects.id)
└── is_primary

projects
├── id (UUID, PK)
├── status (project_status enum)
├── supervisor_id (FK → supervisors.id)
├── doer_id (FK → doers.id)
└── ...

project_revisions
├── id (UUID, PK)
├── project_id (FK → projects.id)
├── revision_number
├── requested_by (FK → profiles.id)
├── feedback
└── status
```

---

**Report End**
