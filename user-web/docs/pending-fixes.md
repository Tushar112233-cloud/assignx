# Pending Fixes - AssignX User Web

This document tracked all mocked/incomplete functionality that needed to be connected to real backends (Supabase/Cloudinary).

**Status: ALL FIXES COMPLETED** (January 2025)

---

## Completed Fixes

### 1. File Downloads (3 Components) - FIXED

#### 1.1 `components/project-detail/attached-files.tsx` - FIXED
- Now uses `file.url` to trigger actual browser downloads
- Added `url` property to `AttachedFile` type

#### 1.2 `components/project-detail/deliverable-item.tsx` - FIXED
- Now uses `deliverable.url` for actual downloads
- Added `url` property to `Deliverable` type

#### 1.3 `components/projects/invoice-download.tsx` - FIXED
- Created `/api/invoices/[projectId]/route.ts` API endpoint
- Generates styled HTML invoice that can be printed to PDF
- Fetches project and profile data from Supabase

---

### 2. Avatar Upload - FIXED

**File:** `components/profile/avatar-upload-dialog.tsx`

- Uploads to Cloudinary via `uploadAvatar` server action
- Saves URL to `profiles.avatar_url` in Supabase
- Base64 file encoding for upload

**Server Action:** `uploadAvatar(base64Data, fileName)` in `lib/actions/data.ts`

---

### 3. Feedback Submission - FIXED

**File:** `components/settings/feedback-section.tsx`

- Now calls `submitFeedback` server action
- Maps feedback type to satisfaction score for database compatibility
- Saves to `user_feedback` table

---

### 4. Revision Request - FIXED

**File:** `components/projects/revision-request-form.tsx`

- Now calls `createRevisionRequest` server action
- Inserts into `project_revisions` table
- Updates project status to `revision_requested`

**Server Action:** `createRevisionRequest(projectId, feedback)` in `lib/actions/data.ts`

---

### 5. Data Export - FIXED

**File:** `components/settings/data-section.tsx`

- Now calls `exportUserData` server action
- Exports real user data from all tables (profile, projects, files, payments, feedback)
- Downloads as JSON file

**Server Action:** `exportUserData()` in `lib/actions/data.ts`

---

### 6. Book Session - FIXED

**File:** `components/connect/book-session-sheet.tsx`

- Now calls `bookExpertSession` server action
- Creates booking record with graceful fallback if table doesn't exist

**Server Action:** `bookExpertSession(data)` in `lib/actions/data.ts`

---

### 7. Ask Question (Connect) - FIXED

**File:** `components/connect/ask-question-sheet.tsx`

- Now calls `submitConnectQuestion` server action
- Saves to `connect_questions` table or falls back to `support_tickets`

**Server Action:** `submitConnectQuestion(data)` in `lib/actions/data.ts`

---

## Database Tables Status

| Table | Status | Used By |
|-------|--------|---------|
| `profiles` | Connected | Auth, Profile, Avatar Upload |
| `projects` | Connected | Project creation/listing |
| `project_files` | Connected | File uploads (Cloudinary) |
| `project_deliverables` | Connected | Deliverable downloads |
| `project_revisions` | Connected | Revision requests |
| `user_feedback` | Connected | Feedback form |
| `marketplace_listings` | Connected | Marketplace |
| `payment_methods` | Connected | Payment methods page |
| `wallets` | Connected | Wallet functionality |
| `notifications` | Connected | Notifications |
| `support_tickets` | Connected | Support page, fallback for questions |
| `expert_bookings` | Graceful fallback | Session bookings |
| `connect_questions` | Graceful fallback | Community questions |

---

## Environment Variables

### Currently Configured
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=configured
NEXT_PUBLIC_SUPABASE_ANON_KEY=configured

# Razorpay
RAZORPAY_KEY_ID=configured
RAZORPAY_KEY_SECRET=configured
NEXT_PUBLIC_RAZORPAY_KEY_ID=configured

# Cloudinary
CLOUDINARY_CLOUD_NAME=drknn3ujj
CLOUDINARY_API_KEY=configured
CLOUDINARY_API_SECRET=configured
```

---

## Server Actions Added/Updated

| Action | File | Description |
|--------|------|-------------|
| `uploadAvatar` | `lib/actions/data.ts` | Upload avatar to Cloudinary, save URL to profiles |
| `createRevisionRequest` | `lib/actions/data.ts` | Create revision request, update project status |
| `exportUserData` | `lib/actions/data.ts` | Export all user data as JSON |
| `bookExpertSession` | `lib/actions/data.ts` | Create expert session booking |
| `submitConnectQuestion` | `lib/actions/data.ts` | Submit community question |
| `uploadProjectFile` | `lib/actions/data.ts` | Updated to use Cloudinary |

---

## Notes

- All file storage now uses Cloudinary instead of Supabase Storage
- File URLs are stored in Supabase tables (`file_url` columns)
- Server actions have graceful fallbacks for missing tables
- Invoice generation returns HTML (can be printed to PDF by browser)
