# Database Restructure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Eliminate the centralized `profiles` collection. Each role (user, doer, supervisor, admin) becomes a fully independent collection with its own auth fields. JWT `sub` = role collection `_id`.

**Architecture:** Remove two-level ID system. Merge auth fields (email, fullName, phone, refreshTokens) into each role collection. Update all references from `profileId` to direct role IDs. Same email can exist across roles.

**Tech Stack:** MongoDB/Mongoose, Express, Next.js, JWT

---

## Phase 1: New Models (API Server)

### Task 1: Update Doer model — add auth fields

**Files:**
- Modify: `api-server/src/models/Doer.ts`

**Step 1: Add auth fields to Doer schema**

Add these fields to the existing Doer schema (alongside existing fields like qualification, skills, etc.):

```typescript
email: { type: String, required: true, unique: true, lowercase: true, trim: true },
fullName: { type: String },
phone: { type: String },
phoneVerified: { type: Boolean, default: false },
avatarUrl: { type: String },
onboardingCompleted: { type: Boolean, default: false },
onboardingStep: { type: Number, default: 0 },
refreshTokens: [{
  token: { type: String, required: true },
  expiresAt: { type: Date, required: true },
}],
lastLoginAt: { type: Date },
```

Remove `profileId` field.

**Step 2: Commit**

```
git add api-server/src/models/Doer.ts
git commit -m "feat: add auth fields to Doer model, remove profileId"
```

---

### Task 2: Update Supervisor model — add auth fields

**Files:**
- Modify: `api-server/src/models/Supervisor.ts`

Same auth fields as Task 1. Remove `profileId`.

**Commit:** `feat: add auth fields to Supervisor model, remove profileId`

---

### Task 3: Update Admin model — standalone auth

**Files:**
- Modify: `api-server/src/models/Admin.ts`

Add auth fields (email, fullName, refreshTokens, lastLoginAt). Remove `profileId`. Admin already has `email` — ensure it has all auth fields.

**Commit:** `feat: make Admin model standalone with auth fields`

---

### Task 4: Create User model (merge Student + Professional)

**Files:**
- Create: `api-server/src/models/User.ts`

```typescript
import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  email: string;
  fullName: string;
  phone: string;
  phoneVerified: boolean;
  avatarUrl: string;
  userType: 'student' | 'professional' | 'business';
  onboardingCompleted: boolean;
  onboardingStep: number;
  refreshTokens: Array<{ token: string; expiresAt: Date }>;
  lastLoginAt: Date;
  // Student fields
  universityId?: mongoose.Types.ObjectId;
  courseId?: mongoose.Types.ObjectId;
  semester?: number;
  yearOfStudy?: number;
  studentIdNumber?: string;
  expectedGraduationYear?: number;
  collegeEmail?: string;
  collegeEmailVerified?: boolean;
  preferredSubjects?: mongoose.Types.ObjectId[];
  // Professional fields
  professionalType?: string;
  industryId?: mongoose.Types.ObjectId;
  jobTitle?: string;
  companyName?: string;
  linkedinUrl?: string;
  // Business fields
  businessType?: string;
  gstNumber?: string;
  // Common
  preferences?: Record<string, any>;
  twoFactorEnabled?: boolean;
  twoFactorSecret?: string;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>({
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  fullName: { type: String },
  phone: { type: String },
  phoneVerified: { type: Boolean, default: false },
  avatarUrl: { type: String },
  userType: { type: String, enum: ['student', 'professional', 'business'], required: true },
  onboardingCompleted: { type: Boolean, default: false },
  onboardingStep: { type: Number, default: 0 },
  refreshTokens: [{
    token: { type: String, required: true },
    expiresAt: { type: Date, required: true },
  }],
  lastLoginAt: { type: Date },
  // Student
  universityId: { type: Schema.Types.ObjectId, ref: 'University' },
  courseId: { type: Schema.Types.ObjectId },
  semester: { type: Number },
  yearOfStudy: { type: Number },
  studentIdNumber: { type: String },
  expectedGraduationYear: { type: Number },
  collegeEmail: { type: String },
  collegeEmailVerified: { type: Boolean, default: false },
  preferredSubjects: [{ type: Schema.Types.ObjectId, ref: 'Subject' }],
  // Professional
  professionalType: { type: String },
  industryId: { type: Schema.Types.ObjectId },
  jobTitle: { type: String },
  companyName: { type: String },
  linkedinUrl: { type: String },
  // Business
  businessType: { type: String },
  gstNumber: { type: String },
  // Common
  preferences: { type: Schema.Types.Mixed },
  twoFactorEnabled: { type: Boolean, default: false },
  twoFactorSecret: { type: String },
}, { timestamps: true });

userSchema.index({ userType: 1 });

export const User = mongoose.model<IUser>('User', userSchema);
```

**Commit:** `feat: create User model merging Student + Professional`

---

### Task 5: Update AuthToken model — add role scoping

**Files:**
- Modify: `api-server/src/models/AuthToken.ts`

Ensure `role` field exists and is required. Update composite index to `email + role + purpose`.

**Commit:** `feat: scope auth tokens by email + role`

---

### Task 6: Update wallet models — split by role

**Files:**
- Create: `api-server/src/models/UserWallet.ts`
- Create: `api-server/src/models/DoerWallet.ts`
- Create: `api-server/src/models/SupervisorWallet.ts`
- Modify: `api-server/src/models/WalletTransaction.ts` — add `walletType` field
- Modify: `api-server/src/models/Wallet.ts` — deprecate or delete

Each wallet model is identical structure but references its own role collection:
- `UserWallet.userId` → User
- `DoerWallet.doerId` → Doer
- `SupervisorWallet.supervisorId` → Supervisor

`WalletTransaction` adds: `walletType: { type: String, enum: ['user', 'doer', 'supervisor'], required: true }`

**Commit:** `feat: split wallets by role, add walletType to transactions`

---

### Task 7: Update Project model references

**Files:**
- Modify: `api-server/src/models/Project.ts`

Change references:
- `userId: { type: Schema.Types.ObjectId, ref: 'User' }` (was ref: 'Profile')
- `doerId: { type: Schema.Types.ObjectId, ref: 'Doer' }` (was ref: 'Profile')
- `supervisorId: { type: Schema.Types.ObjectId, ref: 'Supervisor' }` (was ref: 'Profile')
- Update all embedded refs: `cancellation.cancelledBy`, `files[].uploadedBy`, `deliverables[].uploadedBy`, `deliverables[].qcBy`, `revisions[].requestedBy`, `statusHistory[].changedBy` — add `role` field alongside each `id` ref.

**Commit:** `feat: update Project model to reference role collections directly`

---

### Task 8: Update ChatRoom + ChatMessage models

**Files:**
- Modify: `api-server/src/models/ChatRoom.ts`
- Modify: `api-server/src/models/ChatMessage.ts`

ChatRoom participants: change `profileId` to `id` + `role`:
```typescript
participants: [{
  id: { type: Schema.Types.ObjectId, required: true },
  role: { type: String, enum: ['user', 'doer', 'supervisor', 'admin'], required: true },
  joinedAt: { type: Date, default: Date.now },
  lastSeenAt: { type: Date },
  lastReadMessageId: { type: Schema.Types.ObjectId, ref: 'ChatMessage' },
  isMuted: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true },
}]
```

ChatMessage: `senderId` stays, `senderRole` already exists. Update `readBy` to `[{ id, role }]`.

**Commit:** `feat: update chat models for role-based participants`

---

### Task 9: Update Notification model

**Files:**
- Modify: `api-server/src/models/Notification.ts`

Change `userId` to `recipientId` + `recipientRole`:
```typescript
recipientId: { type: Schema.Types.ObjectId, required: true },
recipientRole: { type: String, enum: ['user', 'doer', 'supervisor', 'admin'], required: true },
```

Update index: `{ recipientId: 1, recipientRole: 1, isRead: 1, createdAt: -1 }`

**Commit:** `feat: update Notification model with recipientId + recipientRole`

---

### Task 10: Update remaining models

**Files:**
- Modify: `api-server/src/models/SupportTicket.ts` — `raisedById` + `raisedByRole`, `assignedTo` → Admin
- Modify: `api-server/src/models/TrainingProgress.ts` — `userId` + `userRole`
- Modify: `api-server/src/models/QuizAttempt.ts` — `userId` + `userRole`
- Modify: `api-server/src/models/CommunityPost.ts` — `userId` → User (direct)
- Modify: `api-server/src/models/PostInteraction.ts` — `userId` → User
- Modify: `api-server/src/models/MarketplaceListing.ts` — `userId` → User
- Modify: `api-server/src/models/ExpertBooking.ts` — `userId` → User
- Modify: `api-server/src/models/Expert.ts` — remove `profileId`
- Modify: `api-server/src/models/PayoutRequest.ts` — `recipientId` + `recipientRole`
- Modify: `api-server/src/models/AuditLog.ts` — `actorId` + `actorRole`
- Modify: `api-server/src/models/AccessRequest.ts` — `reviewedBy` → Admin
- Modify: `api-server/src/models/DoerReview.ts` — split into two or add `reviewerRole`
- Modify: `api-server/src/models/TrainingModule.ts` — add `targetRole`
- Modify: `api-server/src/models/QuizQuestion.ts` — add `targetRole`

**Commit:** `feat: update all remaining models to remove Profile references`

---

### Task 11: Create review models

**Files:**
- Create: `api-server/src/models/UserDoerReview.ts`
- Create: `api-server/src/models/SupervisorDoerReview.ts`
- Delete or deprecate: `api-server/src/models/DoerReview.ts`

**Commit:** `feat: split DoerReview into UserDoerReview + SupervisorDoerReview`

---

### Task 12: Update models index + delete deprecated models

**Files:**
- Modify: `api-server/src/models/index.ts`
- Delete: `api-server/src/models/Profile.ts`
- Delete: `api-server/src/models/Student.ts`
- Delete: `api-server/src/models/Professional.ts`
- Delete: `api-server/src/models/Wallet.ts` (replaced by role-specific wallets)

Add to index: `User`, `UserWallet`, `DoerWallet`, `SupervisorWallet`, `UserDoerReview`, `SupervisorDoerReview`
Remove: `Profile`, `Student`, `Professional`, `Wallet`

**Commit:** `feat: update model exports, delete Profile/Student/Professional`

---

## Phase 2: Auth Service + JWT (API Server)

### Task 13: Update JWT service

**Files:**
- Modify: `api-server/src/services/jwt.service.ts`

No structural change needed — `TokenPayload` already has `{ sub, email, role }`. Just ensure `sub` will now be the role collection `_id` (not profile `_id`). This is handled in auth.service.ts.

---

### Task 14: Rewrite auth.service.ts

**Files:**
- Modify: `api-server/src/services/auth.service.ts`

Major changes:
- `sendOTP(email, purpose, role)` — look up account in the correct collection based on `role`
- `verifyOTP(email, otp, purpose, role)` — on login, find user in role collection, issue JWT with `sub = roleDoc._id`
- `doerSignup()` — create doc directly in `doers` collection (no Profile)
- `supervisorSignup()` — create doc directly in `supervisors` collection
- `checkAccount(email, role)` — look in role-specific collection
- `refreshTokens()` — find refresh token in role-specific collection
- `logout()` — remove refresh token from role-specific collection
- Remove all `Profile.findOne()` / `Profile.findById()` calls

Helper function to get the correct model by role:
```typescript
function getModelByRole(role: string) {
  switch (role) {
    case 'user': return User;
    case 'doer': return Doer;
    case 'supervisor': return Supervisor;
    case 'admin': return Admin;
    default: throw new AppError('Invalid role', 400);
  }
}
```

**Commit:** `feat: rewrite auth service for role-based collections`

---

### Task 15: Rewrite auth.routes.ts

**Files:**
- Modify: `api-server/src/routes/auth.routes.ts`

- `/login` — accept `role` in body, look up in correct collection
- `/dev-login` — create doc in correct role collection
- `/check-account` — accept `role`, check correct collection
- `/send-otp` — already has `role` param, pass through
- `/verify` — already has `role`, issue JWT with role collection `_id`
- `/doer-signup` — create in `doers` directly
- `/supervisor-signup` — create in `supervisors` directly
- `/access-status` — check `doers`/`supervisors` + `access_requests`
- `/refresh` — decode token to get role, find in correct collection
- `/logout` — decode token to get role
- `/me` — find in correct collection by `req.user.role`

**Commit:** `feat: rewrite auth routes for role-based collections`

---

### Task 16: Update auth middleware

**Files:**
- Modify: `api-server/src/middleware/auth.ts`

No change needed — already extracts `{ id, email, role }` from JWT. The `id` will now be the role collection `_id` instead of profile `_id`.

---

## Phase 3: Route Handlers (API Server)

### Task 17: Delete profile.routes.ts, create user.routes.ts

**Files:**
- Delete: `api-server/src/routes/profile.routes.ts`
- Create: `api-server/src/routes/user.routes.ts`
- Modify: `api-server/src/routes/index.ts` — replace `/profiles` with `/users`

User routes handle: GET `/users/me`, PUT `/users/:id`, etc. Query `User` model directly.

**Commit:** `feat: replace profile routes with user routes`

---

### Task 18: Update doer.routes.ts

**Files:**
- Modify: `api-server/src/routes/doer.routes.ts`

- Remove `/by-profile/:profileId` endpoint (no more profileId)
- Use `req.user.id` directly as doer `_id`
- Update all `Doer.findOne({ profileId })` → `Doer.findById(req.user.id)`

**Commit:** `feat: update doer routes to use direct doer ID`

---

### Task 19: Update supervisor.routes.ts

**Files:**
- Modify: `api-server/src/routes/supervisor.routes.ts`

Same pattern as Task 18. Remove profileId lookups, use `req.user.id` directly.

**Commit:** `feat: update supervisor routes to use direct supervisor ID`

---

### Task 20: Update project.routes.ts

**Files:**
- Modify: `api-server/src/routes/project.routes.ts`

- Queries that filter by `userId`/`doerId`/`supervisorId` now use role collection IDs directly
- `req.user.id` = the role `_id`
- Population changes: `.populate('userId')` → from User collection, `.populate('doerId')` → from Doer, `.populate('supervisorId')` → from Supervisor

**Commit:** `feat: update project routes for role-based IDs`

---

### Task 21: Update chat.routes.ts

**Files:**
- Modify: `api-server/src/routes/chat.routes.ts`

- Creating rooms: use `{ id: req.user.id, role: req.user.role }` for participants
- Finding rooms: query `participants.id` + `participants.role`
- Sending messages: use `senderId: req.user.id`, `senderRole: req.user.role`

**Commit:** `feat: update chat routes for role-based participants`

---

### Task 22: Update wallet.routes.ts

**Files:**
- Modify: `api-server/src/routes/wallet.routes.ts`

- Determine wallet collection based on `req.user.role`:
  - user → UserWallet, doer → DoerWallet, supervisor → SupervisorWallet
- Transactions include `walletType`

**Commit:** `feat: update wallet routes for split wallets`

---

### Task 23: Update notification.routes.ts

**Files:**
- Modify: `api-server/src/routes/notification.routes.ts`

- Query: `{ recipientId: req.user.id, recipientRole: req.user.role }`
- Creating: set both `recipientId` and `recipientRole`

**Commit:** `feat: update notification routes for recipientId + recipientRole`

---

### Task 24: Update remaining route files

**Files:**
- Modify: `api-server/src/routes/support.routes.ts`
- Modify: `api-server/src/routes/community.routes.ts`
- Modify: `api-server/src/routes/marketplace.routes.ts`
- Modify: `api-server/src/routes/expert.routes.ts`
- Modify: `api-server/src/routes/training.routes.ts`
- Modify: `api-server/src/routes/payment.routes.ts`
- Modify: `api-server/src/routes/admin.routes.ts`
- Modify: `api-server/src/routes/connect.routes.ts`
- Modify: `api-server/src/routes/access-request.routes.ts`

All follow the same pattern: replace `Profile.findById()` with role-specific model lookups using `req.user.role`.

**Commit:** `feat: update all remaining routes to remove Profile dependency`

---

### Task 25: Update routes index

**Files:**
- Modify: `api-server/src/routes/index.ts`

- Remove: `router.use('/profiles', profileRoutes)`
- Add: `router.use('/users', userRoutes)`

**Commit:** `feat: update route index`

---

## Phase 4: Frontend — doer-web

### Task 26: Update types

**Files:**
- Modify: `doer-web/types/database.ts`
- Modify: `doer-web/types/profile.types.ts`

Remove `Profile` type. The `Doer` type now includes auth fields (email, fullName, etc.). Remove all `profileId` references.

**Commit:** `feat(doer-web): update types for new DB architecture`

---

### Task 27: Update auth hooks and stores

**Files:**
- Modify: `doer-web/hooks/useAuth.ts`
- Modify: `doer-web/stores/authStore.ts`
- Modify: `doer-web/lib/api/auth.ts`
- Modify: `doer-web/lib/auth-helpers.ts`
- Modify: `doer-web/services/auth.service.ts`

Key changes:
- Remove `fetchProfile` — no `/api/profiles/me` endpoint
- JWT `sub` = doer `_id` directly
- `/api/auth/me` returns doer data directly (no need for separate profile + doer fetch)
- Remove `by-profile/:profileId` calls
- `useAuth` no longer has two-step init (fetch profile → fetch doer). One step: fetch doer by `req.user.id`.

**Commit:** `feat(doer-web): update auth for direct doer identity`

---

### Task 28: Update doer-web pages and components

**Files:**
- Modify: All 37 files that reference Profile/profileId (see analysis)
- Key files: login, register, profile, dashboard, settings, sidebar, etc.

Replace `user.id` (profile ID) with `doer.id` (doer ID) everywhere. Remove profile service calls.

**Commit:** `feat(doer-web): remove all Profile references from UI`

---

## Phase 5: Frontend — user-web

### Task 29: Update user-web types and auth

**Files:**
- Modify: 46 files in user-web that reference Profile

Key changes:
- `Profile` type → `User` type with `userType` field
- `/api/profiles/me` → `/api/users/me`
- Remove Student/Professional separation — all in User model
- Auth returns User doc directly

**Commit:** `feat(user-web): migrate from Profile to User model`

---

## Phase 6: Frontend — superviser-web

### Task 30: Update superviser-web types and auth

**Files:**
- Modify: 32 files in superviser-web that reference Profile

Key changes:
- JWT `sub` = supervisor `_id`
- `/api/profiles/me` → `/api/auth/me` returns supervisor doc
- Remove profileId lookups

**Commit:** `feat(superviser-web): migrate from Profile to Supervisor model`

---

## Phase 7: Frontend — admin-web

### Task 31: Update admin-web types and auth

**Files:**
- Modify: 16 files in admin-web that reference Profile

Key changes:
- JWT `sub` = admin `_id`
- Admin manages users/doers/supervisors from their respective collections
- Remove all Profile references from admin views

**Commit:** `feat(admin-web): migrate from Profile to standalone Admin model`

---

## Phase 8: Data Migration

### Task 32: Write migration script

**Files:**
- Create: `api-server/src/scripts/migrate-profiles-to-roles.ts`

Script logic:
1. For each Profile doc:
   - If `userType === 'doer'`: copy auth fields to existing Doer doc (matched by profileId), set `_id` to keep existing references OR create new mapping
   - If `userType === 'supervisor'`: same for Supervisor
   - If `userType === 'admin'`: copy to Admin
   - If `userType === 'user'/'student'/'professional'/'business'`: create User doc
2. Update all Project docs: replace `userId`/`doerId`/`supervisorId` with new IDs
3. Update ChatRoom participants
4. Update Notifications
5. Update Wallets → split into role-specific wallets
6. Update all other referencing collections
7. Log all changes for verification

**Commit:** `feat: add data migration script for profile elimination`

---

## Phase 9: Cleanup

### Task 33: Delete deprecated files and collections

- Delete `Profile.ts`, `Student.ts`, `Professional.ts`, `Wallet.ts` models
- Delete `profile.routes.ts`, `profile.service.ts`
- Drop `profiles`, `students`, `professionals` collections (after migration verified)
- Update all import paths

**Commit:** `feat: cleanup deprecated Profile-related code`

---

## Execution Order

Phases should be executed in order (1 → 9). Within each phase, tasks can be parallelized where they don't depend on each other.

**Critical path:** Phase 1 (models) → Phase 2 (auth) → Phase 3 (routes) → Phase 4-7 (frontends, parallelizable) → Phase 8 (migration) → Phase 9 (cleanup)

**Estimated scope:** ~175 files across 5 codebases, 33 tasks, 9 phases.
