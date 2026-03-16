# Training Modules System Design

## Overview

Admins upload training/learning modules via the `/learning` page in admin-web. Each module targets a role (doer, supervisor, or all) and can be marked required or optional. During onboarding, doers and supervisors must complete all required modules before accessing the main app. Completion is auto-tracked based on engagement (trust-based, client-reported).

## Data Model

### TrainingModule (update existing `training_modules` collection)

```
title: string (required)
description: string (required)
contentType: 'video' | 'document' | 'text' (required)
contentUrl: string (video link or Cloudinary document URL; required for video/document)
contentHtml: string (rich text content; required for text type)
thumbnailUrl: string (optional)
durationMinutes: number (estimated minutes to complete)
targetRole: 'doer' | 'supervisor' | 'all' (required)
isMandatory: boolean (default: true)
order: number (display sequence)
isActive: boolean (default: true)
createdAt, updatedAt: timestamps
```

Replaces the old `videoUrl` and `duration` fields with `contentType` + `contentUrl` + `durationMinutes`.

### TrainingProgress (update existing `training_progress` collection)

```
userId: ObjectId (required)
userRole: 'doer' | 'supervisor' (required)
moduleId: ObjectId -> TrainingModule (required)
status: 'not_started' | 'in_progress' | 'completed' (default: 'not_started')
progress: number (0-100)
startedAt: Date
completedAt: Date
lastAccessedAt: Date
```

Unique index on `{userId, userRole, moduleId}`.

Note: Remove the old `completed: boolean` field. Use `status === 'completed'` as the single source of truth. All endpoint validation checks `status === 'completed'` instead of `completed: true`.

## Auto-Completion Rules

- **Video**: Complete when user has watched >= 90% of the duration (tracked client-side via time on page)
- **Document**: Complete when user opens/downloads the document
- **Text**: Complete when user scrolls to the bottom of the content

Progress is trust-based (client-reported). The API enforces monotonic progress — a new value is only accepted if it's greater than the existing value, and a completed module cannot be un-completed.

## API Endpoints

### Training Routes (existing, updated — all role-aware)

All endpoints use `req.user.role` to determine whether the caller is a doer or supervisor, and branch accordingly.

1. `GET /api/training/modules?role=doer|supervisor` - Returns active modules for role (includes `all`), ordered by `order`. Response includes all content fields: `contentType`, `contentUrl`, `contentHtml`, `durationMinutes`, `isMandatory`.
2. `GET /api/training/progress` - Returns authenticated user's progress on all modules
3. `PUT /api/training/progress/:moduleId` - Update progress (body: `{ progress: number }`). Enforces monotonic progress (new >= existing). Auto-sets `status: 'completed'` at progress 100.
4. `POST /api/training/complete` - **Role-aware**: Validates all mandatory modules (filtered by `isMandatory: true` AND `targetRole` matching user's role or `all`) have `status: 'completed'`. For doers: sets `Doer.trainingCompleted = true`. For supervisors: sets `SupervisorActivation.trainingCompleted = true`.
5. `GET /api/training/status` - **Role-aware**: Returns `{ completed: boolean, totalRequired: number, completedRequired: number, modules: [...] }`. Queries the correct model (Doer vs SupervisorActivation) based on `req.user.role`.

### Admin Routes (existing, updated)

1. `GET /api/admin/training-modules` - List all modules (no role filter, shows everything)
2. `POST /api/admin/training-modules` - Create module. For document type: frontend uploads file to Cloudinary via existing `/api/upload` endpoint first, then passes the URL in `contentUrl`.
3. `PUT /api/admin/training-modules/:id` - Update module
4. `DELETE /api/admin/training-modules/:id` - Soft delete (set `isActive: false`)

### Upload Strategy

Document uploads use the existing `/api/upload` endpoint (Cloudinary). The admin frontend uploads the file first, gets back a URL, then includes that URL in the training module creation/update payload. No multipart handling needed on the training-modules routes themselves.

## Admin-Web (`/learning` page)

Repurpose existing LearningForm and LearningDataTable components:

### Data Table
- Columns: Title, Content Type (badge), Target Role (badge), Required (indicator), Order, Active (toggle), Actions
- Filters: content type, target role, required status
- Actions: Edit, Delete, Reorder

### Form (Create/Edit)
- Title (text input, required)
- Description (textarea, required)
- Content Type (select: Video Link / Document Upload / Text Content)
- Conditional fields based on content type:
  - Video: URL input for video link
  - Document: File upload (PDF, DOCX, etc.) -> uploads to Cloudinary via `/api/upload`, stores returned URL
  - Text: Rich textarea for content
- Thumbnail (optional image upload)
- Target Role (select: Doer / Supervisor / All)
- Required toggle (default: on)
- Duration in minutes (number input)
- Order (number input)
- Active toggle

## Doer-Web (update existing `/training` page)

### Activation Flow Change

The activation flow changes from 3 steps to 2 steps:
- **Old**: Training -> Quiz -> Bank Details
- **New**: Training -> Bank Details

The quiz step is removed. Routes `/quiz` can remain but are no longer part of the activation stepper. `useActivation.ts` step logic updates from 3 steps to 2.

### Module List View
- Shows all modules for role `doer` or `all`
- Each module card shows: title, description, content type icon, duration, completion status
- Required modules have a visual indicator
- Progress bar at top: "X of Y required modules completed"

### Module Content Views
- **Video**: Embedded video player (YouTube/Vimeo iframe or HTML5 video). Tracks time watched.
- **Document**: Preview with download button. Marks complete on open/download.
- **Text**: Scrollable content area. Tracks scroll position, completes at bottom.

### Flow
1. User lands on `/training` during onboarding
2. Sees list of modules with completion status
3. Clicks a module -> opens content view
4. Auto-completion triggers based on engagement
5. Returns to list, sees updated progress
6. When all required modules done -> "Continue" button activates
7. Click Continue -> calls `POST /api/training/complete` -> proceeds to bank details

## Superviser-Web (update existing `/training` page)

Same pattern as doer-web:
- Fetch modules where targetRole = 'supervisor' or 'all'
- Same auto-completion logic
- Same module content views
- **Must call `POST /api/training/complete`** via Continue button before navigating to dashboard (sets server-side flag)
- `ActivationGuard` redirect target changes from `/modules` to `/training`
- Guard checks `trainingCompleted` specifically (via `/api/training/status`)

## Enforcement

### Doer-Web
- `useActivation` hook fetches training status on mount
- If required modules incomplete -> redirect to `/training`
- Main layout (`(main)/layout.tsx`) blocks dashboard access until training complete
- Activation stepper shows 2 steps (training, bank details) instead of 3

### Superviser-Web
- `ActivationGuard` checks training completion via `GET /api/training/status`
- If required modules incomplete -> redirect to `/training` (not `/modules`)
- Dashboard layout blocks access until complete

### API Server
- `POST /api/training/complete` validates server-side that all mandatory modules (`isMandatory: true`) for the user's role have progress records with `status: 'completed'`
- Doer: sets `Doer.trainingCompleted = true`, `Doer.trainingCompletedAt = now`
- Supervisor: sets `SupervisorActivation.trainingCompleted = true`, `SupervisorActivation.trainingCompletedAt = now`

## Field Name Convention

API model fields are camelCase (e.g., `contentType`, `durationMinutes`, `isMandatory`). The existing API response normalization layer converts to snake_case for frontend consumption (e.g., `content_type`, `duration_minutes`, `is_mandatory`). No additional mapping needed — the existing normalizer handles new fields automatically.

## Bug Fixes (included in this work)

1. **superviser-web training service**: Fix `markModuleComplete()` to call `PUT /api/training/progress/${moduleId}` with `{ progress: 100 }` instead of `POST /api/training/progress` with wrong payload shape.
2. **superviser-web ActivationGuard**: Change redirect from `/modules` to `/training`.
3. **API training routes**: Make `/complete` and `/status` role-aware (currently hardcoded to doer-only).

## File Changes Summary

### API Server
- `src/models/TrainingModule.ts` - Add contentType, contentUrl, contentHtml, isMandatory, rename duration -> durationMinutes
- `src/models/TrainingProgress.ts` - Replace completed boolean with status enum, add startedAt
- `src/routes/training.routes.ts` - Make all endpoints role-aware, add monotonic progress guard, filter by isMandatory
- `src/routes/admin.routes.ts` - Update training module CRUD, change delete to soft-delete

### Admin-Web
- `app/(authenticated)/learning/page.tsx` - Wire up to training modules API
- `components/admin/learning/learning-form.tsx` - Rebuild for training modules with content type switching
- `components/admin/learning/learning-data-table.tsx` - Update columns for training modules
- `lib/admin/actions/learning.ts` - Point to training-modules endpoints

### Doer-Web
- `app/(activation)/training/page.tsx` - Update for new module types and auto-completion
- `hooks/useActivation.ts` - Simplify to 2 steps (remove quiz), use status field
- `app/(activation)/layout.tsx` - Update stepper to 2 steps (training, bank details)

### Superviser-Web
- `app/training/page.tsx` - Update for new module types, auto-completion, call /complete on Continue
- `lib/services/training.ts` - Fix markModuleComplete to use correct endpoint
- `components/auth/activation-guard.tsx` - Redirect to /training, check trainingCompleted via /status
