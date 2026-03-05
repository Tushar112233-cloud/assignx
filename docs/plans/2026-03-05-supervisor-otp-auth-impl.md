# Supervisor OTP Auth Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace magic link auth with OTP-based login/signup for supervisor-web and superviser_app, with admin approval workflow and training module gate.

**Architecture:** API-first approach. Build backend endpoints first (supervisor-status, supervisor-signup, module endpoints), then rewrite supervisor-web frontend (Next.js), then rewrite superviser_app frontend (Flutter). Existing TrainingModule and SupervisorActivation models are reused. Admin approval endpoint already creates Supervisor records — we enhance it with metadata population.

**Tech Stack:** Express + MongoDB (api-server), Next.js 16 + React (superviser-web), Flutter + Riverpod + GoRouter (superviser_app)

---

## Task 1: Add `GET /auth/supervisor-status` endpoint

**Files:**
- Modify: `/Volumes/Crucial X9/AssignX/api-server/src/routes/auth.routes.ts`

**Step 1: Add the endpoint after the existing `/auth/access-request` route (after line 235)**

```typescript
// GET /auth/supervisor-status?email= — Unified status check for supervisor login/signup
router.get('/supervisor-status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = (email as string).toLowerCase().trim();

    // Check access request first (most common for new users)
    const accessReq = await AccessRequest.findOne({ email: normalizedEmail, role: 'supervisor' }).sort({ createdAt: -1 });

    if (!accessReq) {
      // No access request — check if they have a profile+supervisor record (legacy)
      const profile = await Profile.findOne({ email: normalizedEmail, userType: 'supervisor' });
      if (profile) {
        const supervisor = await Supervisor.findOne({ profileId: profile._id });
        if (supervisor) {
          return res.json({ status: 'approved', isActivated: supervisor.isActivated });
        }
      }
      return res.json({ status: 'not_found' });
    }

    if (accessReq.status === 'pending') {
      return res.json({ status: 'pending' });
    }

    if (accessReq.status === 'rejected') {
      return res.json({ status: 'rejected' });
    }

    // Approved — check activation
    const profile = await Profile.findOne({ email: normalizedEmail });
    if (!profile) {
      return res.json({ status: 'approved', isActivated: false });
    }

    const supervisor = await Supervisor.findOne({ profileId: profile._id });
    return res.json({
      status: 'approved',
      isActivated: supervisor?.isActivated ?? false,
    });
  } catch (err) {
    next(err);
  }
});
```

**Step 2: Verify API server compiles**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -20`

**Step 3: Commit**

```bash
git add api-server/src/routes/auth.routes.ts
git commit -m "feat(api): add GET /auth/supervisor-status endpoint"
```

---

## Task 2: Add `POST /auth/supervisor-signup` endpoint

**Files:**
- Modify: `/Volumes/Crucial X9/AssignX/api-server/src/services/auth.service.ts`
- Modify: `/Volumes/Crucial X9/AssignX/api-server/src/routes/auth.routes.ts`

**Step 1: Add `supervisorSignup` function in auth.service.ts (after `doerSignup`)**

```typescript
/**
 * Verify OTP for supervisor signup — creates AccessRequest (pending).
 * Does NOT issue JWT tokens or create Profile (admin must approve first).
 */
export const supervisorSignup = async (
  email: string,
  otp: string,
  fullName: string,
  metadata: {
    qualification: string;
    yearsOfExperience: number;
    expertiseAreas: string[];
    bio?: string | null;
    bankName: string;
    accountNumber: string;
    ifscCode: string;
    upiId?: string | null;
  }
) => {
  // Find and verify OTP
  const authTokens = await AuthToken.find({ email, type: 'otp_signup' });
  if (authTokens.length === 0) {
    throw new AppError('No verification code found. Please request a new one.', 400);
  }

  let matchedToken = null;
  for (const at of authTokens) {
    const isValid = await bcrypt.compare(otp, at.otp);
    if (isValid) {
      matchedToken = at;
      break;
    }
  }

  if (!matchedToken) {
    throw new AppError('Invalid or expired verification code.', 400);
  }

  // Clean up used token
  await AuthToken.deleteOne({ _id: matchedToken._id });

  // Check for existing pending request
  const existing = await AccessRequest.findOne({ email, role: 'supervisor', status: 'pending' });
  if (existing) {
    return {
      success: true,
      message: 'Your application is already under review.',
    };
  }

  // Create access request
  await AccessRequest.create({
    email,
    role: 'supervisor',
    fullName,
    status: 'pending',
    metadata: {
      qualification: metadata.qualification,
      yearsOfExperience: metadata.yearsOfExperience,
      expertiseAreas: metadata.expertiseAreas,
      bio: metadata.bio || null,
      bankName: metadata.bankName,
      accountNumber: metadata.accountNumber,
      ifscCode: metadata.ifscCode,
      upiId: metadata.upiId || null,
    },
  });

  return {
    success: true,
    message: 'Your application has been submitted for review. You will be notified once approved.',
  };
};
```

**Step 2: Update the import in auth.service.ts to include AccessRequest**

The file already imports `AccessRequest` via `import { AccessRequest } from '../models/AccessRequest';` — confirm this.

**Step 3: Add route in auth.routes.ts (after the doer-signup route)**

```typescript
// POST /auth/supervisor-signup - Verify OTP + create access request (pending admin approval)
router.post('/supervisor-signup', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, otp, fullName, metadata } = req.body;
    if (!email || !otp || !fullName || !metadata) {
      throw new AppError('email, otp, fullName, and metadata are required', 400);
    }
    const result = await supervisorSignup(
      email.toLowerCase().trim(),
      otp,
      fullName.trim(),
      metadata
    );
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
});
```

**Step 4: Update the import at top of auth.routes.ts to include `supervisorSignup`**

Change:
```typescript
import { sendOTP, verifyOTP, doerSignup, sendMagicLink, verifyMagicLink, checkMagicLinkStatus, refreshTokens, logout } from '../services/auth.service';
```
To:
```typescript
import { sendOTP, verifyOTP, doerSignup, supervisorSignup, sendMagicLink, verifyMagicLink, checkMagicLinkStatus, refreshTokens, logout } from '../services/auth.service';
```

**Step 5: Update `sendOTP` in auth.service.ts to handle supervisor role for signup**

The current `sendOTP` function only validates doer-specific logic. Add supervisor checks inside the `purpose === 'signup'` block:

```typescript
if (purpose === 'signup') {
  if (role === 'doer') {
    // existing doer check...
    const existingProfile = await Profile.findOne({ email });
    if (existingProfile && existingProfile.userType === 'doer') {
      const doer = await Doer.findOne({ profileId: existingProfile._id });
      if (doer) {
        throw new AppError('An account with this email already exists. Please login instead.', 409);
      }
    }
  }
  if (role === 'supervisor') {
    // Check for existing pending access request
    const existingRequest = await AccessRequest.findOne({ email, role: 'supervisor', status: 'pending' });
    if (existingRequest) {
      throw new AppError('You already have a pending application. Please wait for approval.', 409);
    }
    // Check for existing approved supervisor
    const existingProfile = await Profile.findOne({ email, userType: 'supervisor' });
    if (existingProfile) {
      const supervisor = await Supervisor.findOne({ profileId: existingProfile._id });
      if (supervisor) {
        throw new AppError('An account with this email already exists. Please login instead.', 409);
      }
    }
  }
}
```

Also update the `purpose === 'login'` block to handle supervisor role:

```typescript
if (purpose === 'login') {
  const profile = await Profile.findOne({ email });
  if (!profile) {
    throw new AppError('No account found for this email.', 404);
  }
  if (role === 'doer') {
    const doer = await Doer.findOne({ profileId: profile._id });
    if (!doer) {
      throw new AppError('No doer account found. Please register first.', 404);
    }
    if (!doer.isActivated) {
      throw new AppError('Your profile is under review. Please wait for approval.', 403);
    }
  }
  // Supervisor login: profile must exist, supervisor record must exist
  if (role === 'supervisor') {
    const supervisor = await Supervisor.findOne({ profileId: profile._id });
    if (!supervisor) {
      throw new AppError('Your supervisor account is not set up yet. Please wait for approval.', 403);
    }
  }
}
```

**Step 6: Add the Supervisor import to auth.service.ts if not already there**

Change:
```typescript
import { AuthToken, Profile, Doer } from '../models';
```
To:
```typescript
import { AuthToken, Profile, Doer, Supervisor } from '../models';
```

**Step 7: Verify compilation**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -20`

**Step 8: Commit**

```bash
git add api-server/src/services/auth.service.ts api-server/src/routes/auth.routes.ts
git commit -m "feat(api): add supervisor-signup endpoint and update sendOTP for supervisor role"
```

---

## Task 3: Enhance admin approval to populate Supervisor record with metadata

**Files:**
- Modify: `/Volumes/Crucial X9/AssignX/api-server/src/routes/admin.routes.ts` (lines 818-876)

**Step 1: Update the supervisor creation block in `POST /admin/access-requests/:id/approve`**

Replace the existing supervisor creation (lines 858-863):
```typescript
    if (request.role === 'supervisor' && !(await Supervisor.findOne({ profileId: profile._id }))) {
      await Supervisor.create({
        profileId: profile._id,
        isAccessGranted: true,
      });
    }
```

With:
```typescript
    if (request.role === 'supervisor' && !(await Supervisor.findOne({ profileId: profile._id }))) {
      const meta = request.metadata || {};
      await Supervisor.create({
        profileId: profile._id,
        isAccessGranted: true,
        isApproved: true,
        isActivated: false,
        qualification: meta.qualification || '',
        yearsOfExperience: meta.yearsOfExperience || 0,
        bio: meta.bio || '',
        expertise: meta.expertiseAreas || [],
        bankDetails: {
          accountName: request.fullName,
          accountNumber: meta.accountNumber || '',
          ifscCode: meta.ifscCode || '',
          bankName: meta.bankName || '',
          upiId: meta.upiId || '',
          verified: false,
        },
      });
    }
```

**Step 2: Verify compilation**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -20`

**Step 3: Commit**

```bash
git add api-server/src/routes/admin.routes.ts
git commit -m "feat(api): populate Supervisor metadata from AccessRequest on admin approval"
```

---

## Task 4: Add training module endpoints for supervisors

**Files:**
- Modify: `/Volumes/Crucial X9/AssignX/api-server/src/routes/supervisor.routes.ts`

**Step 1: Add module endpoints at the end of the supervisor routes file (before the export)**

You need to first read the file to understand the existing imports and structure. The file uses `authenticate` middleware and has access to `Supervisor`, `TrainingModule`, `SupervisorActivation` from models.

Add these routes:

```typescript
// GET /supervisors/me/modules — Get training modules with completion status
router.get('/me/modules', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id);
    if (!profile) throw new AppError('Profile not found', 404);

    const supervisor = await Supervisor.findOne({ profileId: profile._id });
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    // Get all active training modules for supervisors
    const modules = await TrainingModule.find({
      isActive: true,
      targetRole: { $in: ['supervisor', 'all'] },
    }).sort({ order: 1 });

    // Get completion status
    const activation = await SupervisorActivation.findOne({ supervisorId: supervisor._id });
    const completedSteps = activation?.completedSteps || [];

    const modulesWithStatus = modules.map((m) => ({
      _id: m._id,
      title: m.title,
      description: m.description,
      videoUrl: m.videoUrl,
      thumbnailUrl: m.thumbnailUrl,
      duration: m.duration,
      category: m.category,
      order: m.order,
      isCompleted: completedSteps.includes(m._id.toString()),
    }));

    const totalRequired = modules.length;
    const totalCompleted = completedSteps.filter((s: string) =>
      modules.some((m) => m._id.toString() === s)
    ).length;

    res.json({
      modules: modulesWithStatus,
      totalRequired,
      totalCompleted,
      allCompleted: totalRequired > 0 && totalCompleted >= totalRequired,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisors/me/modules/:moduleId/complete — Mark a module as completed
router.put('/me/modules/:moduleId/complete', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id);
    if (!profile) throw new AppError('Profile not found', 404);

    const supervisor = await Supervisor.findOne({ profileId: profile._id });
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const { moduleId } = req.params;

    // Verify module exists
    const trainingModule = await TrainingModule.findById(moduleId);
    if (!trainingModule) throw new AppError('Training module not found', 404);

    // Upsert activation record
    let activation = await SupervisorActivation.findOne({ supervisorId: supervisor._id });
    if (!activation) {
      activation = await SupervisorActivation.create({
        supervisorId: supervisor._id,
        step: 0,
        completedSteps: [],
      });
    }

    // Add module to completed steps if not already there
    if (!activation.completedSteps.includes(moduleId)) {
      activation.completedSteps.push(moduleId);
      activation.step = activation.completedSteps.length;
    }

    // Check if all required modules are completed
    const allModules = await TrainingModule.find({
      isActive: true,
      targetRole: { $in: ['supervisor', 'all'] },
    });

    const allModuleIds = allModules.map((m) => m._id.toString());
    const allCompleted = allModuleIds.every((id) => activation!.completedSteps.includes(id));

    if (allCompleted && allModules.length > 0) {
      activation.isCompleted = true;
      activation.isActivated = true;
      activation.trainingCompleted = true;
      activation.completedAt = new Date();
      activation.activatedAt = new Date();

      // Also update the supervisor record
      supervisor.isActivated = true;
      supervisor.activatedAt = new Date();
      await supervisor.save();
    }

    await activation.save();

    res.json({
      success: true,
      completedSteps: activation.completedSteps,
      allCompleted,
      isActivated: supervisor.isActivated,
    });
  } catch (err) {
    next(err);
  }
});
```

**Step 2: Ensure TrainingModule and SupervisorActivation are imported in supervisor.routes.ts**

Check the imports at the top of the file. If not present, add:
```typescript
import { TrainingModule, SupervisorActivation } from '../models';
```

**Step 3: Verify compilation**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -20`

**Step 4: Commit**

```bash
git add api-server/src/routes/supervisor.routes.ts
git commit -m "feat(api): add training module endpoints for supervisor activation"
```

---

## Task 5: Seed default training modules for supervisors

**Files:**
- Create: `/Volumes/Crucial X9/AssignX/api-server/src/scripts/seed-supervisor-modules.ts`

**Step 1: Create the seed script**

```typescript
import mongoose from 'mongoose';
import { TrainingModule } from '../models';
import dotenv from 'dotenv';
dotenv.config();

const SUPERVISOR_MODULES = [
  {
    title: 'Platform Overview',
    description: 'Learn how the AssignX platform works, your role as a supervisor, and how projects flow from submission to completion.',
    category: 'orientation',
    targetRole: 'supervisor',
    order: 1,
    duration: 10,
    isActive: true,
  },
  {
    title: 'Quality Review Guidelines',
    description: 'Understand the quality standards expected for every project. Learn how to evaluate deliverables, provide constructive feedback, and ensure consistency.',
    category: 'training',
    targetRole: 'supervisor',
    order: 2,
    duration: 15,
    isActive: true,
  },
  {
    title: 'Communication & Ethics',
    description: 'Best practices for communicating with doers and clients. Ethical guidelines, confidentiality requirements, and conflict resolution.',
    category: 'training',
    targetRole: 'supervisor',
    order: 3,
    duration: 10,
    isActive: true,
  },
];

async function seed() {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/AssignX';
  await mongoose.connect(uri);
  console.log('Connected to MongoDB');

  for (const mod of SUPERVISOR_MODULES) {
    const existing = await TrainingModule.findOne({ title: mod.title, targetRole: 'supervisor' });
    if (!existing) {
      await TrainingModule.create(mod);
      console.log(`Created: ${mod.title}`);
    } else {
      console.log(`Exists: ${mod.title}`);
    }
  }

  await mongoose.disconnect();
  console.log('Done');
}

seed().catch(console.error);
```

**Step 2: Run the seed script**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx ts-node src/scripts/seed-supervisor-modules.ts`

**Step 3: Commit**

```bash
git add api-server/src/scripts/seed-supervisor-modules.ts
git commit -m "feat(api): add seed script for supervisor training modules"
```

---

## Task 6: Rewrite supervisor-web login form for OTP flow

**Files:**
- Rewrite: `/Volumes/Crucial X9/AssignX/superviser-web/components/auth/login-form.tsx`
- Modify: `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts`

**Step 1: Add new API helpers in `lib/api/auth.ts`**

Add these functions (keep existing ones that are still used):

```typescript
/**
 * Check supervisor status by email.
 */
export async function checkSupervisorStatus(
  email: string
): Promise<{ status: 'not_found' | 'pending' | 'rejected' | 'approved'; isActivated?: boolean }> {
  return apiFetch(`/api/auth/supervisor-status?email=${encodeURIComponent(email)}`)
}

/**
 * Send OTP to email for supervisor login or signup.
 */
export async function sendSupervisorOTP(
  email: string,
  purpose: 'login' | 'signup' = 'login'
): Promise<{ success: boolean; message: string }> {
  return apiFetch('/api/auth/send-otp', {
    method: 'POST',
    body: JSON.stringify({ email, role: 'supervisor', purpose }),
  })
}

/**
 * Verify OTP and get tokens (for login).
 */
export async function verifySupervisorOTP(
  email: string,
  otp: string
): Promise<{ accessToken: string; refreshToken: string; user: AuthUser; profile: AuthUser }> {
  const data = await apiFetch<{ accessToken: string; refreshToken: string; user?: AuthUser; profile?: AuthUser }>('/api/auth/verify', {
    method: 'POST',
    body: JSON.stringify({ email, otp }),
  })

  setTokens(data.accessToken, data.refreshToken)
  const user = data.user || data.profile
  if (user) storeUser(user)

  return { ...data, user: user!, profile: user! }
}

/**
 * Supervisor signup: verify OTP + create access request.
 */
export async function supervisorSignup(
  email: string,
  otp: string,
  fullName: string,
  metadata: Record<string, unknown>
): Promise<{ success: boolean; message: string }> {
  return apiFetch('/api/auth/supervisor-signup', {
    method: 'POST',
    body: JSON.stringify({ email, otp, fullName, metadata }),
  })
}
```

**Step 2: Rewrite login-form.tsx**

Replace the entire file with a new OTP-based login form. The flow:
1. Email input screen
2. On submit: call `checkSupervisorStatus(email)`
3. If not_found → show error with link to register
4. If pending → show "under review" message
5. If rejected → show "rejected" with re-apply link
6. If approved → call `sendSupervisorOTP(email, 'login')` → show OTP input
7. On OTP submit: call `verifySupervisorOTP(email, otp)` → check isActivated → redirect to `/modules` or `/dashboard`

The component should have:
- `phase: 'email' | 'otp'` state
- Email input with the same glass card styling
- 6-digit OTP input (individual boxes or single input)
- Resend OTP button with 60s cooldown
- Error states matching current design language
- Dev bypass emails still work

**Step 3: Update login page.tsx**

Update trust card labels from "Passwordless / Magic link" to "OTP Verified" language.

**Step 4: Verify dev server compiles**

Run: `cd "/Volumes/Crucial X9/AssignX/superviser-web" && npx next build 2>&1 | tail -20`

**Step 5: Commit**

```bash
git add superviser-web/components/auth/login-form.tsx superviser-web/lib/api/auth.ts superviser-web/app/\(auth\)/login/page.tsx
git commit -m "feat(web): rewrite supervisor login form with OTP flow"
```

---

## Task 7: Rewrite supervisor-web register form with OTP verification (Step 4)

**Files:**
- Rewrite: `/Volumes/Crucial X9/AssignX/superviser-web/components/auth/register-form.tsx`

**Step 1: Modify the register form**

The current flow: Steps 1-3 collect data, Step 4 is review + submit.

New flow: Steps 1-3 stay the same. Step 4 becomes:
1. Show review summary (same as current)
2. "Send OTP" button sends OTP to the email from Step 1
3. OTP input appears below the review
4. User enters OTP and clicks "Submit Application"
5. Calls `supervisorSignup(email, otp, fullName, metadata)` which verifies OTP server-side
6. On success → redirect to `/pending`

Key changes to the existing `RegisterForm` component:
- Add `otpSent: boolean` and `otp: string` state
- Add `resendCooldown: number` state
- Step 4 review section stays, but the "Submit Application" button first triggers OTP send
- After OTP sent, show OTP input field + submit button
- The `handleSubmit` function now calls `supervisorSignup` with OTP instead of raw `apiFetch('/api/access-requests')`

**Step 2: Verify dev server compiles**

**Step 3: Commit**

```bash
git add superviser-web/components/auth/register-form.tsx
git commit -m "feat(web): add OTP verification to supervisor registration step 4"
```

---

## Task 8: Simplify supervisor-web pending page

**Files:**
- Rewrite: `/Volumes/Crucial X9/AssignX/superviser-web/app/(auth)/pending/page.tsx`

**Step 1: Replace with simplified version**

Remove the 4-step progress tracker. Replace with:
- Clock icon with orange glow
- "Your application is under review"
- "You'll receive an email once approved."
- Email badge (keep the PendingEmailBadge component)
- "Back to sign in" button
- "Re-apply" link (goes to /register)

Keep the same glass aesthetic and color scheme (orange-50, orange-600, etc).

**Step 2: Commit**

```bash
git add superviser-web/app/\(auth\)/pending/page.tsx
git commit -m "feat(web): simplify pending page to plain review message"
```

---

## Task 9: Add training modules page to supervisor-web

**Files:**
- Create: `/Volumes/Crucial X9/AssignX/superviser-web/app/(main)/modules/page.tsx`
- Modify: `/Volumes/Crucial X9/AssignX/superviser-web/middleware.ts` (if exists, or create)

**Step 1: Create the modules page**

This page:
- Fetches `GET /api/supervisors/me/modules` on load
- Shows list of training modules with completion status
- Each module has a "Mark Complete" button (or is already marked done)
- When all modules are completed, shows "Continue to Dashboard" button
- Call `PUT /api/supervisors/me/modules/:moduleId/complete` on each completion
- Clean, card-based UI matching the auth pages aesthetic

**Step 2: Add middleware or layout guard**

In the supervisor-web main layout or middleware, check:
- If user is authenticated but `isActivated === false`, redirect to `/modules`
- If user is on `/modules` and `isActivated === true`, redirect to `/dashboard`

Check if there's an existing middleware file first. The check should use the `/api/auth/me` response which includes `roleData.isActivated`.

**Step 3: Commit**

```bash
git add superviser-web/app/\(main\)/modules/page.tsx superviser-web/middleware.ts
git commit -m "feat(web): add training modules page with activation gate"
```

---

## Task 10: Clean up magic link code from supervisor-web

**Files:**
- Modify: `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts` (remove unused magic link functions)
- Delete or modify: `/Volumes/Crucial X9/AssignX/superviser-web/app/api/auth/callback/route.ts`
- Delete or modify: `/Volumes/Crucial X9/AssignX/superviser-web/app/api/auth/setup-supervisor/route.ts`
- Modify: `/Volumes/Crucial X9/AssignX/superviser-web/components/auth/login-form.tsx` (ensure no magic link references remain)

**Step 1: Remove magic link functions from auth.ts**

Remove: `sendMagicLink`, `checkMagicLinkStatus` functions. Keep `verifyOTP` as it may be used elsewhere (or it's now replaced by `verifySupervisorOTP`).

**Step 2: Remove the callback route** (was for magic link email click)

Delete or empty: `app/api/auth/callback/route.ts`

**Step 3: Remove setup-supervisor route** (no longer needed — supervisor created on admin approval)

Delete or empty: `app/api/auth/setup-supervisor/route.ts`

**Step 4: Commit**

```bash
git add -A superviser-web/
git commit -m "chore(web): remove magic link code from supervisor-web"
```

---

## Task 11: Rewrite superviser_app login screen for OTP flow

**Files:**
- Rewrite: `/Volumes/Crucial X9/AssignX/superviser_app/lib/features/auth/presentation/screens/login_screen.dart`
- Modify: `/Volumes/Crucial X9/AssignX/superviser_app/lib/features/auth/data/repositories/auth_repository.dart`
- Modify: `/Volumes/Crucial X9/AssignX/superviser_app/lib/features/auth/presentation/providers/auth_provider.dart`

**Step 1: Add OTP methods to AuthRepository**

Add these methods to `auth_repository.dart`:

```dart
/// Check supervisor status by email.
Future<Map<String, dynamic>> checkSupervisorStatus(String email) async {
  try {
    final response = await ApiClient.get(
      '/auth/supervisor-status?email=${Uri.encodeComponent(email)}',
    );
    return response as Map<String, dynamic>? ?? {'status': 'not_found'};
  } on ApiException catch (e) {
    throw AppAuthException(e.message);
  }
}

/// Send OTP for supervisor login or signup.
Future<void> sendSupervisorOTP(String email, {String purpose = 'login'}) async {
  try {
    await ApiClient.post('/auth/send-otp', {
      'email': email,
      'role': 'supervisor',
      'purpose': purpose,
    });
  } on ApiException catch (e) {
    throw AppAuthException(e.message);
  }
}

/// Verify OTP and get tokens (for login).
Future<UserModel> verifySupervisorOTP(String email, String otp) async {
  try {
    final response = await ApiClient.post('/auth/verify', {
      'email': email,
      'otp': otp,
    });

    if (response == null) {
      throw const AppAuthException('Verification failed. Please try again.');
    }

    final accessToken = response['accessToken'] as String? ?? '';
    final refreshToken = response['refreshToken'] as String? ?? '';

    if (accessToken.isNotEmpty) {
      await TokenStorage.saveTokens(accessToken, refreshToken);
    }

    final userData = response['user'] as Map<String, dynamic>?
        ?? response['profile'] as Map<String, dynamic>?;
    if (userData == null) {
      throw const AppAuthException('Login failed. No user data returned.');
    }

    return UserModel.fromJson(userData);
  } on ApiException catch (e) {
    throw AppAuthException(e.message);
  }
}

/// Supervisor signup: verify OTP + create access request.
Future<void> supervisorSignup({
  required String email,
  required String otp,
  required String fullName,
  required Map<String, dynamic> metadata,
}) async {
  try {
    await ApiClient.post('/auth/supervisor-signup', {
      'email': email,
      'otp': otp,
      'fullName': fullName,
      'metadata': metadata,
    });
  } on ApiException catch (e) {
    throw AppAuthException(e.message);
  }
}
```

**Step 2: Add OTP methods to AuthNotifier**

Add to `auth_provider.dart`:

```dart
/// Check supervisor status by email.
Future<Map<String, dynamic>> checkSupervisorStatus(String email) async {
  try {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.checkSupervisorStatus(email);
    state = state.copyWith(isLoading: false);
    return result;
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
    return {'status': 'error'};
  }
}

/// Send OTP for supervisor login.
Future<bool> sendSupervisorOTP(String email, {String purpose = 'login'}) async {
  try {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repository.sendSupervisorOTP(email, purpose: purpose);
    state = state.copyWith(isLoading: false);
    return true;
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
    return false;
  }
}

/// Verify OTP and complete login.
Future<bool> verifySupervisorOTP(String email, String otp) async {
  try {
    state = state.copyWith(isLoading: true, clearError: true);
    final user = await _repository.verifySupervisorOTP(email, otp);
    await _loadUserData(user);
    return true;
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
    return false;
  }
}
```

**Step 3: Rewrite login_screen.dart**

Replace the entire login screen with OTP flow:
1. Email input screen (remove password, Google, magic link)
2. On submit: check supervisor status
   - not_found → show error with register link
   - pending → navigate to pending screen
   - rejected → show error with re-apply link
   - approved → send OTP → navigate to OTP entry screen
3. OTP entry screen (6 digit input)
4. On OTP verify → navigate based on isActivated (modules or dashboard)

Remove: ForgotPasswordScreen, _GoogleSignInButton from this file (or keep ForgotPasswordScreen if still needed for other flows — but since we're going OTP-only, remove it).

**Step 4: Commit**

```bash
git add superviser_app/lib/features/auth/
git commit -m "feat(app): rewrite Flutter login with OTP flow"
```

---

## Task 12: Rewrite superviser_app register screen for OTP flow

**Files:**
- Rewrite: `/Volumes/Crucial X9/AssignX/superviser_app/lib/features/auth/presentation/screens/register_screen.dart`

**Step 1: Create 4-step registration form matching web**

The Flutter register screen should have:
1. Step 1: Email & Full Name
2. Step 2: Professional Profile (qualification, years of experience, expertise areas, bio)
3. Step 3: Bank Details (bank name, account number, IFSC code, UPI ID)
4. Step 4: Review + OTP verification
   - Show review summary of all data
   - "Send OTP" button → sends OTP to email
   - OTP input field appears
   - "Submit Application" button → calls `supervisorSignup`
   - On success → navigate to pending screen

Use the same stepper UI pattern as the web version. Use `reactive_forms` since it's already a dependency.

**Step 2: Add pending and rejected screens**

Create a simple pending screen at: `/lib/features/auth/presentation/screens/pending_screen.dart`
- Shows "Your application is under review" message
- "Back to sign in" button

Create a rejected screen or handle rejected state inline in login screen.

**Step 3: Update router**

Add the pending route to `app_router.dart` if not already there (it's already there as `registrationPending` → `ApplicationPendingScreen`). Update that screen to show the simplified message.

**Step 4: Commit**

```bash
git add superviser_app/lib/features/auth/ superviser_app/lib/core/router/
git commit -m "feat(app): add 4-step OTP registration and pending/rejected screens"
```

---

## Task 13: Add training modules screen to superviser_app

**Files:**
- Create: `/Volumes/Crucial X9/AssignX/superviser_app/lib/features/activation/presentation/screens/modules_screen.dart`
- Modify: `/Volumes/Crucial X9/AssignX/superviser_app/lib/core/router/app_router.dart`

**Step 1: Create the modules screen**

This screen:
- Fetches training modules from `GET /api/supervisors/me/modules`
- Shows list of modules with completion checkmarks
- Each module has a "Mark Complete" button
- Calls `PUT /api/supervisors/me/modules/:moduleId/complete`
- When all complete, shows "Continue to Dashboard" button
- Update auth state to set isActivated = true

**Step 2: Update router guards**

In `app_router.dart`, the redirect logic already sends non-activated users to `registrationPending`. Update it to send them to the new modules screen instead (or update the existing activation flow to use the new modules endpoint).

**Step 3: Commit**

```bash
git add superviser_app/lib/features/activation/ superviser_app/lib/core/router/app_router.dart
git commit -m "feat(app): add training modules screen with activation gate"
```

---

## Task 14: Clean up old auth code from superviser_app

**Files:**
- Modify: `/Volumes/Crucial X9/AssignX/superviser_app/lib/features/auth/data/repositories/auth_repository.dart`
- Modify: `/Volumes/Crucial X9/AssignX/superviser_app/lib/features/auth/presentation/providers/auth_provider.dart`
- Modify: `/Volumes/Crucial X9/AssignX/superviser_app/lib/core/router/app_router.dart`

**Step 1: Remove unused auth methods from AuthRepository**

Remove: `signInWithEmail`, `signUpWithEmail`, `sendPasswordResetEmail`, `updatePassword`, `signInWithGoogle`, `signInWithMagicLink`

Keep: `signOut`, `getCurrentUser`, `hasSession`, `recoverSession`, `isAuthenticated`, `fetchUserProfile`, `fetchSupervisorData`, `isActivatedSupervisor` + the new OTP methods

**Step 2: Remove unused methods from AuthNotifier**

Remove: `signIn`, `signUp`, `sendPasswordReset`, `signInWithGoogle`, `signInWithMagicLink`

Keep: `signOut`, `refreshUser`, `clearError` + the new OTP methods

**Step 3: Remove ForgotPasswordScreen route from router**

Remove the `/forgot-password` route from `app_router.dart`.

**Step 4: Remove google_sign_in dependency if no longer needed**

Check if google_sign_in is used anywhere else. If not, remove from `pubspec.yaml`.

**Step 5: Commit**

```bash
git add superviser_app/
git commit -m "chore(app): remove old email/password/Google/magic-link auth code"
```

---

## Task 15: End-to-end manual testing

**Steps:**
1. Start API server: `cd api-server && npx ts-node-dev src/index.ts`
2. Start supervisor-web: `cd superviser-web && npx next dev --port 3001 --turbopack`
3. Run seed script for training modules
4. Test full signup flow on web:
   - Go to /register, fill steps 1-3, verify OTP in step 4
   - Confirm redirected to /pending
5. Test login with pending status:
   - Go to /login, enter the email
   - Confirm "under review" message shown
6. Approve in admin panel (or direct DB update):
   - `db.accessrequests.updateOne({email: "test@test.com"}, {$set: {status: "approved"}})`
   - Verify Supervisor record was created
7. Test login after approval:
   - Go to /login, enter email
   - OTP sent, enter OTP
   - Redirected to /modules (not activated yet)
8. Complete all training modules
9. Verify redirected to /dashboard
10. Test Flutter app with same flows

**No commit for this step — testing only.**

---

## Summary of all files changed

### api-server (backend)
- `src/routes/auth.routes.ts` — new supervisor-status + supervisor-signup routes
- `src/services/auth.service.ts` — supervisorSignup function, updated sendOTP for supervisor role
- `src/routes/admin.routes.ts` — enhanced approval to populate Supervisor metadata
- `src/routes/supervisor.routes.ts` — training module endpoints
- `src/scripts/seed-supervisor-modules.ts` — new seed script

### superviser-web (Next.js)
- `components/auth/login-form.tsx` — complete rewrite for OTP
- `components/auth/register-form.tsx` — add OTP verification to step 4
- `lib/api/auth.ts` — new OTP API helpers, remove magic link functions
- `app/(auth)/login/page.tsx` — update trust card labels
- `app/(auth)/pending/page.tsx` — simplify to plain message
- `app/(main)/modules/page.tsx` — new training modules page
- `middleware.ts` — activation gate
- `app/api/auth/callback/route.ts` — remove (magic link)
- `app/api/auth/setup-supervisor/route.ts` — remove

### superviser_app (Flutter)
- `lib/features/auth/data/repositories/auth_repository.dart` — OTP methods, remove old auth
- `lib/features/auth/presentation/providers/auth_provider.dart` — OTP methods, remove old auth
- `lib/features/auth/presentation/screens/login_screen.dart` — complete rewrite for OTP
- `lib/features/auth/presentation/screens/register_screen.dart` — 4-step form with OTP
- `lib/features/auth/presentation/screens/pending_screen.dart` — new simplified pending
- `lib/features/activation/presentation/screens/modules_screen.dart` — new modules screen
- `lib/core/router/app_router.dart` — update guards and routes
