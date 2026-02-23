# Pages Documentation

> **AdminX Supervisor Panel** - App Router Pages Reference

## Table of Contents

1. [Overview](#overview)
2. [Route Groups](#route-groups)
3. [Public Pages](#public-pages)
4. [Auth Pages](#auth-pages)
5. [Activation Pages](#activation-pages)
6. [Dashboard Pages](#dashboard-pages)
7. [Loading States](#loading-states)
8. [Error Handling](#error-handling)

---

## Overview

AdminX uses Next.js 16 App Router with route groups for organizing pages by authentication state.

### Route Structure

```
app/
├── (auth)/           # Unauthenticated pages
├── (activation)/     # Activation flow
├── (dashboard)/      # Protected authenticated pages
├── api/              # API routes
├── layout.tsx        # Root layout
├── page.tsx          # Landing page
├── error.tsx         # Global error boundary
└── not-found.tsx     # 404 page
```

---

## Route Groups

### (auth)

Pages accessible without authentication.

- Login
- Register
- Onboarding

**Layout:** Centered card layout without sidebar.

### (activation)

Pages for supervisor activation flow.

- Training videos
- Quiz
- Results

**Layout:** Minimal layout with progress indicator.

### (dashboard)

Protected pages requiring authentication.

All main application functionality.

**Layout:** Full layout with sidebar, header, and main content area.

---

## Public Pages

### Landing Page

**Path:** `/`
**File:** `app/page.tsx`

Redirects to login or dashboard based on auth state.

```tsx
// Behavior
if (authenticated) {
  redirect('/dashboard')
} else {
  redirect('/login')
}
```

### Not Found (404)

**Path:** `/*` (any unmatched route)
**File:** `app/not-found.tsx`

Custom 404 error page.

**Features:**
- Friendly error message
- Link to return home
- Search suggestion

---

## Auth Pages

### Login

**Path:** `/login`
**File:** `app/(auth)/login/page.tsx`

Supervisor login page.

**Features:**
- Email/password form
- "Remember me" option
- OAuth providers (Google)
- Forgot password link
- Register link

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Email | email | Required, valid email |
| Password | password | Required, min 8 chars |

**Redirects:**
- Success → `/dashboard` or `/onboarding` (new user)
- Already logged in → `/dashboard`

---

### Register

**Path:** `/register`
**File:** `app/(auth)/register/page.tsx`

New supervisor registration page.

**Features:**
- Registration form
- OAuth signup
- Terms acceptance
- Login link

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Full Name | text | Required |
| Email | email | Required, unique |
| Password | password | Required, min 8 chars |
| Confirm Password | password | Must match |

**Redirects:**
- Success → `/onboarding`

---

### Onboarding

**Path:** `/onboarding`
**File:** `app/(auth)/onboarding/page.tsx`

Multi-step onboarding for new supervisors.

**Steps:**

1. **Welcome Slides**
   - Platform introduction
   - Role explanation
   - Benefits overview

2. **Professional Profile**
   - Full name
   - Phone number
   - Qualification
   - Years of experience
   - Subjects/expertise
   - Bio

3. **Banking Details**
   - Bank name
   - Account holder name
   - Account number
   - IFSC code

4. **Application Review**
   - Review all entered data
   - Edit any section
   - Submit application

5. **Verification Pending**
   - Status display
   - Expected timeline
   - Contact support option

**Redirects:**
- Completion → `/activation` (after approval)

---

## Activation Pages

### Activation

**Path:** `/activation`
**File:** `app/(activation)/activation/page.tsx`

Supervisor activation flow (training + quiz).

**Phases:**

1. **Training Videos**
   - Required video content
   - Progress tracking
   - Must complete all to proceed

2. **Quiz**
   - Multiple choice questions
   - 80% minimum to pass
   - Limited attempts

3. **Results**
   - Score display
   - Pass/fail status
   - Retry option (if failed)
   - Continue to dashboard (if passed)

**Redirects:**
- Pass → `/dashboard`
- Not activated → Locked on `/activation`

---

## Dashboard Pages

### Dashboard Home

**Path:** `/dashboard`
**File:** `app/(dashboard)/dashboard/page.tsx`

Main dashboard with overview widgets.

**Sections:**
1. **Stats Overview**
   - Active projects count
   - Pending requests
   - Today's completed
   - Total earnings

2. **New Requests**
   - Projects needing quotes
   - Quick analyze action

3. **Ready to Assign**
   - Paid projects awaiting doer
   - Quick assign action

4. **Recent Activity**
   - Latest notifications
   - Recent messages

---

### Projects

**Path:** `/projects`
**File:** `app/(dashboard)/projects/page.tsx`

Project management page.

**Tabs:**
1. **All Projects** - Complete list with filters
2. **Ongoing** - In-progress projects
3. **For Review** - QC pending submissions
4. **Completed** - Finished projects

**Features:**
- Search projects
- Filter by status, date, subject
- Sort options
- Project cards with actions
- QC review modal

---

### Chat

**Path:** `/chat`
**File:** `app/(dashboard)/chat/page.tsx`

Chat room list page.

**Features:**
- List of all chat rooms
- Unread count badges
- Search conversations
- Last message preview

### Chat Room

**Path:** `/chat/[roomId]`
**File:** `app/(dashboard)/chat/[roomId]/page.tsx`

Individual chat room.

**Features:**
- Real-time messaging
- Message history
- File attachments
- Participant info
- Project context

---

### Doers

**Path:** `/doers`
**File:** `app/(dashboard)/doers/page.tsx`

Doer management page.

**Features:**
- Stats overview (total, available, busy, blacklisted)
- Doer cards grid
- Search by name, skills, subjects
- Filter by status, verification
- Sort by rating, projects, name
- Doer detail sheet
- Blacklist management

---

### Earnings

**Path:** `/earnings`
**File:** `app/(dashboard)/earnings/page.tsx`

Earnings and payments page.

**Tabs:**
1. **Overview** - Summary and graphs
2. **Transactions** - Payment ledger
3. **Commission** - Commission breakdown

**Features:**
- Earnings charts (area/bar/line)
- Monthly/weekly views
- Transaction history
- Export to CSV
- Commission details

---

### Profile

**Path:** `/profile`
**File:** `app/(dashboard)/profile/page.tsx`

Supervisor profile page.

**Tabs:**
1. **Profile** - Edit profile info
2. **Stats** - Performance statistics
3. **Reviews** - Reviews received
4. **Blacklist** - Blacklisted doers

**Features:**
- Edit profile form
- Avatar upload
- Performance metrics
- Review history
- Blacklist management

---

### Resources

**Path:** `/resources`
**File:** `app/(dashboard)/resources/page.tsx`

Tools and training resources.

**Tabs:**
1. **Quality Tools**
   - Plagiarism Checker
   - AI Content Detector

2. **Pricing**
   - Pricing Guide
   - Price Calculator

3. **Training**
   - Video library
   - Progress tracking

---

### Settings

**Path:** `/settings`
**File:** `app/(dashboard)/settings/page.tsx`

Application settings.

**Sections:**
- Notification preferences
- Theme selection
- Language (future)
- Account settings

---

### Notifications

**Path:** `/notifications`
**File:** `app/(dashboard)/notifications/page.tsx`

Notification center.

**Features:**
- All notifications list
- Filter by type
- Mark as read
- Mark all as read
- Delete notifications

---

### Support

**Path:** `/support`
**File:** `app/(dashboard)/support/page.tsx`

Help and support page.

**Features:**
- Create support ticket
- View ticket history
- Ticket detail view
- Reply to tickets
- FAQ section

---

### Users

**Path:** `/users`
**File:** `app/(dashboard)/users/page.tsx`

User (client) management page.

**Features:**
- User stats overview
- User cards grid
- Search and filter
- User detail sheet
- Quick chat action

---

## Loading States

Each dashboard page has a `loading.tsx` file for loading states.

**Pattern:**
```tsx
// app/(dashboard)/[page]/loading.tsx
export default function Loading() {
  return <PageSkeleton />
}
```

**Skeleton Types:**
- `DashboardSkeleton` - Dashboard cards
- `ProjectsSkeleton` - Project list
- `ChatSkeleton` - Chat interface
- `TableSkeleton` - Data tables
- `GridSkeleton` - Card grids

---

## Error Handling

### Global Error

**File:** `app/error.tsx`

Catches unhandled errors across the app.

```tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <ErrorDisplay
      message={error.message}
      onRetry={reset}
    />
  )
}
```

### Dashboard Error

**File:** `app/(dashboard)/error.tsx`

Catches errors within the dashboard layout.

### Not Found

**Files:**
- `app/not-found.tsx` - Global 404
- `app/(dashboard)/not-found.tsx` - Dashboard 404

---

## Middleware

**File:** `middleware.ts`

Handles route protection and redirects.

```typescript
// Protected routes require authentication
const protectedRoutes = ['/dashboard', '/chat', '/projects', ...]

// Public routes skip auth check
const publicRoutes = ['/login', '/register']

// Activation required routes
const activationRequiredRoutes = ['/dashboard', ...]
```

**Flow:**
1. Check if route is protected
2. Verify session exists
3. Check if user is activated
4. Redirect appropriately

---

## Page Metadata

Each page exports metadata for SEO:

```typescript
// app/(dashboard)/dashboard/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Dashboard | AdminX',
  description: 'Supervisor dashboard overview',
}
```
