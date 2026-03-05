# OTP Auth Rebuild Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace magic-link auth with pure OTP flow across api-server, user-web, and user_app (Flutter). Add account existence checks, multi-role support, attempt lockouts, and seamless onboarding.

**Architecture:** API-first approach — rebuild the API endpoints first, then update both frontends to consume them. The API sends 6-digit OTP codes via email (no clickable links). Login checks account existence before sending OTP. Signup creates profile on OTP verify.

**Tech Stack:** Express/MongoDB (api-server), Next.js/React (user-web), Flutter/Riverpod (user_app), Resend (email), bcryptjs (hashing), JWT (tokens)

---

## Task 1: Update AuthToken Schema

**Files:**
- Modify: `api-server/src/models/AuthToken.ts`

**Step 1: Rewrite the AuthToken model**

Replace the entire file:

```typescript
import mongoose, { Schema, Document } from 'mongoose';

export interface IAuthToken extends Document {
  email: string;
  otp: string;
  type: string;
  role: string;
  purpose: 'login' | 'signup';
  attempts: number;
  lockedUntil: Date | null;
  expiresAt: Date;
  createdAt: Date;
}

const authTokenSchema = new Schema<IAuthToken>({
  email: { type: String, required: true },
  otp: { type: String, required: true },
  type: { type: String, default: 'otp' },
  role: { type: String, default: '' },
  purpose: { type: String, enum: ['login', 'signup'], required: true },
  attempts: { type: Number, default: 0 },
  lockedUntil: { type: Date, default: null },
  expiresAt: { type: Date, required: true, index: { expireAfterSeconds: 0 } },
  createdAt: { type: Date, default: Date.now },
});

// Index for quick lookups
authTokenSchema.index({ email: 1, purpose: 1 });

export const AuthToken = mongoose.model<IAuthToken>('AuthToken', authTokenSchema, 'auth_tokens');
```

**Step 2: Verify the model compiles**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit src/models/AuthToken.ts 2>&1 | head -20`

**Step 3: Commit**

```bash
git add api-server/src/models/AuthToken.ts
git commit -m "refactor: update AuthToken schema for pure OTP flow

Remove magic link fields (sessionId, verified). Add purpose, attempts, lockedUntil for OTP security."
```

---

## Task 2: Update Profile Schema for Multi-Role

**Files:**
- Modify: `api-server/src/models/Profile.ts`

**Step 1: Add userTypes array and primaryUserType to Profile**

In `api-server/src/models/Profile.ts`, update the interface (lines 3-19) and schema (lines 22-44):

Interface changes — add after line 10 (`userType`):
```typescript
  userTypes: string[];
  primaryUserType: string;
```

Schema changes — add after the `userType` field (line 29):
```typescript
    userTypes: { type: [String], default: [] },
    primaryUserType: { type: String, default: '' },
```

Also update the `userType` enum to include `'student'`, `'professional'`, `'business'`:
```typescript
    userType: { type: String, enum: ['user', 'student', 'professional', 'business', 'doer', 'supervisor', 'admin'], default: 'user' },
```

**Step 2: Verify compilation**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit src/models/Profile.ts 2>&1 | head -20`

**Step 3: Commit**

```bash
git add api-server/src/models/Profile.ts
git commit -m "feat: add multi-role support to Profile schema

Add userTypes array and primaryUserType fields. Expand userType enum to include student/professional/business."
```

---

## Task 3: Rewrite Auth Service (OTP Only)

**Files:**
- Modify: `api-server/src/services/auth.service.ts`

**Step 1: Replace the entire auth service**

```typescript
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { AuthToken, Profile } from '../models';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from './jwt.service';
import { sendOTPEmail } from './email.service';
import { AppError } from '../middleware/errorHandler';

const OTP_EXPIRY_MINUTES = 10;
const OTP_MAX_ATTEMPTS = 5;
const OTP_LOCKOUT_MINUTES = 15;
const OTP_RESEND_COOLDOWN_SECONDS = 60;

/**
 * Generate a 6-digit numeric OTP.
 */
function generateOTP(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Check if an email has a registered profile.
 */
export const checkAccount = async (email: string) => {
  const profile = await Profile.findOne({ email: email.toLowerCase().trim() });
  return { exists: !!profile };
};

/**
 * Send OTP to email for login or signup.
 */
export const sendOTP = async (email: string, purpose: 'login' | 'signup', role?: string) => {
  const normalizedEmail = email.toLowerCase().trim();

  // Check account existence based on purpose
  const profile = await Profile.findOne({ email: normalizedEmail });

  if (purpose === 'login' && !profile) {
    throw new AppError('No account found for this email. Please sign up first.', 404);
  }

  if (purpose === 'signup' && profile) {
    throw new AppError('An account with this email already exists. Please log in instead.', 409);
  }

  // Check resend cooldown — find most recent OTP for this email+purpose
  const recentToken = await AuthToken.findOne({
    email: normalizedEmail,
    purpose,
  }).sort({ createdAt: -1 });

  if (recentToken) {
    const elapsed = Date.now() - recentToken.createdAt.getTime();
    if (elapsed < OTP_RESEND_COOLDOWN_SECONDS * 1000) {
      const remaining = Math.ceil((OTP_RESEND_COOLDOWN_SECONDS * 1000 - elapsed) / 1000);
      throw new AppError(`Please wait ${remaining} seconds before requesting a new code.`, 429);
    }
  }

  // Invalidate previous OTPs for this email+purpose
  await AuthToken.deleteMany({ email: normalizedEmail, purpose });

  // Generate and store new OTP
  const otp = generateOTP();
  const hashedOTP = await bcrypt.hash(otp, 10);

  await AuthToken.create({
    email: normalizedEmail,
    otp: hashedOTP,
    type: 'otp',
    role: role || '',
    purpose,
    attempts: 0,
    lockedUntil: null,
    expiresAt: new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000),
  });

  // Send OTP email (logs to file in dev mode)
  await sendOTPEmail(normalizedEmail, otp);

  return {
    success: true,
    message: 'Verification code sent to your email.',
    expiresIn: OTP_EXPIRY_MINUTES * 60,
  };
};

/**
 * Verify OTP and authenticate user.
 */
export const verifyOTP = async (email: string, otp: string, purpose: 'login' | 'signup', role?: string) => {
  const normalizedEmail = email.toLowerCase().trim();

  // Find the OTP token
  const authToken = await AuthToken.findOne({ email: normalizedEmail, purpose });
  if (!authToken) {
    throw new AppError('No verification code found. Please request a new one.', 400);
  }

  // Check lockout
  if (authToken.lockedUntil && authToken.lockedUntil > new Date()) {
    const remaining = Math.ceil((authToken.lockedUntil.getTime() - Date.now()) / 60000);
    throw new AppError(`Too many failed attempts. Try again in ${remaining} minutes.`, 429);
  }

  // Check expiry
  if (authToken.expiresAt < new Date()) {
    await AuthToken.deleteOne({ _id: authToken._id });
    throw new AppError('Verification code has expired. Please request a new one.', 400);
  }

  // Verify OTP
  const isValid = await bcrypt.compare(otp, authToken.otp);
  if (!isValid) {
    authToken.attempts += 1;

    if (authToken.attempts >= OTP_MAX_ATTEMPTS) {
      authToken.lockedUntil = new Date(Date.now() + OTP_LOCKOUT_MINUTES * 60 * 1000);
      await authToken.save();
      throw new AppError(`Too many failed attempts. Try again in ${OTP_LOCKOUT_MINUTES} minutes.`, 429);
    }

    await authToken.save();
    const remaining = OTP_MAX_ATTEMPTS - authToken.attempts;
    throw new AppError(`Invalid verification code. ${remaining} attempts remaining.`, 400);
  }

  // OTP is valid — delete it
  await AuthToken.deleteOne({ _id: authToken._id });

  // Find or create profile
  let profile = await Profile.findOne({ email: normalizedEmail });

  if (purpose === 'signup') {
    if (profile) {
      throw new AppError('Account already exists. Please log in.', 409);
    }
    const userType = role || 'user';
    profile = await Profile.create({
      email: normalizedEmail,
      userType,
      userTypes: role ? [role] : [],
      primaryUserType: role || '',
    });
  } else {
    // Login
    if (!profile) {
      throw new AppError('No account found. Please sign up first.', 404);
    }
  }

  // Generate JWT tokens
  const effectiveRole = profile.primaryUserType || profile.userType;
  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: effectiveRole,
  };

  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  // Store refresh token hash
  const refreshHash = await bcrypt.hash(refreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  profile.lastLoginAt = new Date();
  await profile.save();

  const profileData = {
    id: profile._id,
    email: profile.email,
    fullName: profile.fullName,
    avatarUrl: profile.avatarUrl,
    userType: effectiveRole,
    userTypes: profile.userTypes,
    primaryUserType: profile.primaryUserType,
    onboardingCompleted: profile.onboardingCompleted,
  };

  return {
    accessToken,
    refreshToken,
    user: profileData,
    profile: profileData,
  };
};

export const refreshTokens = async (refreshToken: string) => {
  let decoded;
  try {
    decoded = verifyRefreshToken(refreshToken);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }

  const profile = await Profile.findById(decoded.sub);
  if (!profile) {
    throw new AppError('User not found', 404);
  }

  // Verify refresh token exists in stored hashes
  let tokenFound = false;
  let tokenIndex = -1;
  for (let i = 0; i < profile.refreshTokens.length; i++) {
    const match = await bcrypt.compare(refreshToken, profile.refreshTokens[i].token);
    if (match) {
      tokenFound = true;
      tokenIndex = i;
      break;
    }
  }

  if (!tokenFound) {
    throw new AppError('Refresh token revoked', 401);
  }

  // Remove old token
  profile.refreshTokens.splice(tokenIndex, 1);

  // Generate new tokens
  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.primaryUserType || profile.userType,
  };

  const newAccessToken = generateAccessToken(tokenPayload);
  const newRefreshToken = generateRefreshToken(tokenPayload);

  // Store new refresh token hash
  const refreshHash = await bcrypt.hash(newRefreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  await profile.save();

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
};

export const logout = async (profileId: string, refreshToken: string) => {
  const profile = await Profile.findById(profileId);
  if (!profile) return;

  for (let i = 0; i < profile.refreshTokens.length; i++) {
    const match = await bcrypt.compare(refreshToken, profile.refreshTokens[i].token);
    if (match) {
      profile.refreshTokens.splice(i, 1);
      await profile.save();
      break;
    }
  }
};
```

**Step 2: Verify compilation**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit src/services/auth.service.ts 2>&1 | head -30`

**Step 3: Commit**

```bash
git add api-server/src/services/auth.service.ts
git commit -m "feat: rewrite auth service for pure OTP flow

Replace sendMagicLink/verifyMagicLink/checkMagicLinkStatus with sendOTP/verifyOTP/checkAccount.
Add attempt tracking, lockout, resend cooldown, and login vs signup distinction."
```

---

## Task 4: Rewrite Auth Routes

**Files:**
- Modify: `api-server/src/routes/auth.routes.ts`

**Step 1: Replace the auth routes file**

```typescript
import { Router, Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { checkAccount, sendOTP, verifyOTP, refreshTokens, logout } from '../services/auth.service';
import { generateAccessToken, generateRefreshToken } from '../services/jwt.service';
import { authenticate } from '../middleware/auth';
import { authLimiter } from '../middleware/rateLimiter';
import { Profile, Doer, Supervisor, Admin, Student, Professional } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Dev emails that can bypass OTP and login directly
const DEV_BYPASS_EMAILS = ['admin@gmail.com'];

/**
 * Helper: find or create profile, generate tokens, return auth response.
 */
async function directLogin(email: string, userType?: string) {
  let profile = await Profile.findOne({ email });
  if (!profile) {
    profile = await Profile.create({
      email,
      userType: userType || 'admin',
      userTypes: [userType || 'admin'],
      primaryUserType: userType || 'admin',
      fullName: email === 'admin@gmail.com' ? 'Admin User' : undefined,
      onboardingCompleted: true,
    });
    if ((profile.userType === 'admin') && !(await Admin.findOne({ profileId: profile._id }))) {
      await Admin.create({ profileId: profile._id, email, adminRole: 'super_admin' });
    }
  }

  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.primaryUserType || profile.userType,
  };

  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  const refreshHash = await bcrypt.hash(refreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  profile.lastLoginAt = new Date();
  await profile.save();

  return {
    accessToken,
    refreshToken,
    user: {
      id: profile._id,
      email: profile.email,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      role: profile.primaryUserType || profile.userType,
      userType: profile.primaryUserType || profile.userType,
      userTypes: profile.userTypes || [],
      primaryUserType: profile.primaryUserType || profile.userType,
      onboardingCompleted: profile.onboardingCompleted,
    },
    profile: {
      id: profile._id,
      email: profile.email,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      userType: profile.primaryUserType || profile.userType,
      userTypes: profile.userTypes || [],
      primaryUserType: profile.primaryUserType || profile.userType,
      onboardingCompleted: profile.onboardingCompleted,
    },
  };
}

// POST /auth/login - Direct email-based login (no OTP) for dev bypass emails
router.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = email.toLowerCase().trim();

    if (DEV_BYPASS_EMAILS.includes(normalizedEmail)) {
      const result = await directLogin(normalizedEmail, 'admin');
      return res.json(result);
    }

    if (!password) {
      throw new AppError('Password is required for non-bypass accounts', 400);
    }

    const profile = await Profile.findOne({ email: normalizedEmail });
    if (!profile) {
      throw new AppError('No account found for this email', 404);
    }

    if (process.env.NODE_ENV === 'development') {
      const result = await directLogin(normalizedEmail, profile.userType);
      return res.json(result);
    }

    throw new AppError('Invalid credentials', 401);
  } catch (err) {
    next(err);
  }
});

// POST /auth/dev-login - Bypass login for development
router.post('/dev-login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = req.body;
    if (!email) throw new AppError('Email is required', 400);
    const result = await directLogin(email.toLowerCase().trim(), role || 'user');
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/check-account - Check if email is registered
router.post('/check-account', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email } = req.body;
    if (!email) throw new AppError('Email is required', 400);
    const result = await checkAccount(email);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/send-otp - Send OTP for login or signup
router.post('/send-otp', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, purpose, role } = req.body;
    if (!email) throw new AppError('Email is required', 400);
    if (!purpose || !['login', 'signup'].includes(purpose)) {
      throw new AppError('Purpose must be "login" or "signup"', 400);
    }
    const result = await sendOTP(email, purpose, role);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/verify - Verify OTP code
router.post('/verify', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, otp, purpose, role } = req.body;
    if (!email || !otp) throw new AppError('Email and OTP are required', 400);
    if (!purpose || !['login', 'signup'].includes(purpose)) {
      throw new AppError('Purpose must be "login" or "signup"', 400);
    }
    const result = await verifyOTP(email, otp, purpose, role);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// GET /auth/access-status - Check if an email has access (for doer/supervisor login flow)
router.get('/access-status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const profile = await Profile.findOne({ email: (email as string).toLowerCase().trim() });
    if (!profile) {
      return res.json({ status: 'not_found' });
    }

    if (role === 'doer') {
      const doer = await Doer.findOne({ profileId: profile._id });
      if (!doer) return res.json({ status: 'approved', needsOnboarding: true });
      return res.json({ status: 'approved', isActivated: doer.isActivated });
    }

    if (role === 'supervisor') {
      const supervisor = await Supervisor.findOne({ profileId: profile._id });
      if (!supervisor) return res.json({ status: 'approved', needsOnboarding: true });
      return res.json({ status: 'approved' });
    }

    res.json({ status: 'approved' });
  } catch (err) {
    next(err);
  }
});

// GET /auth/access-request - Alias for access-status (used by superviser-web)
router.get('/access-request', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const profile = await Profile.findOne({ email: (email as string).toLowerCase().trim() });
    if (!profile) return res.json({ status: 'not_found' });

    if (role === 'supervisor') {
      const supervisor = await Supervisor.findOne({ profileId: profile._id });
      if (!supervisor) return res.json({ status: 'approved', needsOnboarding: true });
      return res.json({ status: 'approved' });
    }

    res.json({ status: 'approved' });
  } catch (err) {
    next(err);
  }
});

// POST /auth/refresh
router.post('/refresh', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) throw new AppError('Refresh token is required', 400);
    const result = await refreshTokens(refreshToken);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/logout
router.post('/logout', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = req.body;
    await logout(req.user!.id, refreshToken || '');
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /auth/me
router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id).select('-refreshTokens');
    if (!profile) throw new AppError('Profile not found', 404);

    let roleData = null;
    if (profile.userType === 'doer') {
      roleData = await Doer.findOne({ profileId: profile._id });
    } else if (profile.userType === 'supervisor') {
      roleData = await Supervisor.findOne({ profileId: profile._id });
    } else if (profile.userType === 'admin') {
      roleData = await Admin.findOne({ profileId: profile._id });
    } else {
      // For user/student/professional/business, try both
      roleData = await Student.findOne({ profileId: profile._id }) ||
                 await Professional.findOne({ profileId: profile._id });
    }

    res.json({ profile, roleData });
  } catch (err) {
    next(err);
  }
});

export default router;
```

**Step 2: Verify compilation**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit src/routes/auth.routes.ts 2>&1 | head -30`

**Step 3: Commit**

```bash
git add api-server/src/routes/auth.routes.ts
git commit -m "feat: rewrite auth routes for pure OTP flow

Add POST /auth/check-account and POST /auth/send-otp.
Update POST /auth/verify to accept purpose param.
Remove magic link endpoints."
```

---

## Task 5: Clean Up Email Service

**Files:**
- Modify: `api-server/src/services/email.service.ts`

**Step 1: Remove sendMagicLinkEmail, keep sendOTPEmail**

Replace the entire file with just the OTP email function (the `sendOTPEmail` already exists at line 38):

```typescript
import resend from '../config/resend';

export const sendOTPEmail = async (email: string, otp: string): Promise<void> => {
  const fromEmail = process.env.RESEND_FROM_EMAIL || 'AssignX <noreply@assignx.in>';

  // In dev mode, log OTP to file for easy access
  if (process.env.NODE_ENV !== 'production') {
    const fs = await import('fs');
    const logLine = `[DEV-OTP] ${new Date().toISOString()} | ${email} | OTP: ${otp}\n`;
    fs.appendFileSync('/private/tmp/api-server.log', logLine);
    console.log(`[DEV-OTP] ${email} -> ${otp}`);
  }

  try {
    const result = await resend.emails.send({
      from: fromEmail,
      to: email,
      subject: 'Your AssignX verification code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #1a1a1a;">Your verification code</h2>
          <p style="color: #444; font-size: 15px;">Use the code below to verify your email. It expires in 10 minutes.</p>
          <div style="text-align: center; margin: 28px 0;">
            <div style="display: inline-block; background: #F7F9FF; border: 2px solid #5A7CFF; border-radius: 12px; padding: 16px 40px; letter-spacing: 8px; font-size: 32px; font-weight: 700; color: #1a1a1a;">
              ${otp}
            </div>
          </div>
          <p style="color: #888; font-size: 13px;">If you didn't request this code, you can safely ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;" />
          <p style="color: #aaa; font-size: 12px;">This is an automated message from AssignX.</p>
        </div>
      `,
    });

    if (result.error) {
      console.warn(`[EMAIL] OTP send failed for ${email}:`, result.error.message);
    } else {
      console.log(`[EMAIL] Sent OTP email to ${email} (id: ${result.data?.id})`);
    }
  } catch (err: any) {
    console.warn(`[EMAIL] Failed to send OTP to ${email}:`, err.message);
  }
};
```

**Step 2: Check for any remaining imports of sendMagicLinkEmail**

Run: `grep -r "sendMagicLinkEmail\|sendMagicLink" "/Volumes/Crucial X9/AssignX/api-server/src/" --include="*.ts"`

Fix any remaining imports.

**Step 3: Commit**

```bash
git add api-server/src/services/email.service.ts
git commit -m "refactor: remove magic link email template

Keep only sendOTPEmail. Magic link flow is fully removed."
```

---

## Task 6: Update Profile Routes for Multi-Role

**Files:**
- Modify: `api-server/src/routes/profile.routes.ts`

**Step 1: Update GET /profiles/me (lines 12-50) to return multi-role data**

Update the response building (around line 34) to include `userTypes` and `primaryUserType`:

```typescript
    const roles = Array.isArray(profileObj.userTypes) && profileObj.userTypes.length > 0
      ? profileObj.userTypes
      : Array.isArray(profileObj.roles) && profileObj.roles.length > 0
        ? profileObj.roles
        : [profileObj.userType];
    res.json({
      ...profileObj,
      id: profileObj._id,
      full_name: profileObj.fullName,
      user_type: profileObj.primaryUserType || profileObj.userType,
      user_types: roles,
      primary_user_type: profileObj.primaryUserType || profileObj.userType,
      avatar_url: profileObj.avatarUrl,
      is_active: true,
      user_roles: roles,
      wallet: wallet ? { id: wallet._id, profile_id: wallet.profileId, balance: wallet.balance, currency: wallet.currency } : null,
      students: roleData && (profile.userType === 'user' || profile.userType === 'student') ? roleData : null,
      roleData,
      profile: profileObj,
    });
```

**Step 2: Update PUT /profiles/me (lines 53-68) to allow updating userTypes**

Add `'userTypes'` and `'primaryUserType'` to the `allowedFields` array at line 55:

```typescript
    const allowedFields = ['fullName', 'phone', 'onboardingStep', 'onboardingCompleted', 'twoFactorEnabled', 'userType', 'userTypes', 'primaryUserType'];
```

**Step 3: Update POST /profiles/student (lines 83-103) and POST /profiles/professional (lines 134-154)**

In the student endpoint, when setting userType, also update userTypes:
```typescript
      const profileUpdates: Record<string, unknown> = { onboardingCompleted: true, userType: 'student' };
      // Add 'student' to userTypes if not already present
      const existingProfile = await Profile.findById(req.user!.id);
      if (existingProfile) {
        const types = existingProfile.userTypes || [];
        if (!types.includes('student')) types.push('student');
        profileUpdates.userTypes = types;
        if (!existingProfile.primaryUserType) profileUpdates.primaryUserType = 'student';
      }
```

Apply the same pattern to the professional endpoint with `'professional'`.

**Step 4: Commit**

```bash
git add api-server/src/routes/profile.routes.ts
git commit -m "feat: update profile routes for multi-role support

Return userTypes/primaryUserType in GET /profiles/me.
Update student/professional creation to maintain userTypes array."
```

---

## Task 7: Verify API Server Compiles and Starts

**Step 1: Run full TypeScript check**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && npx tsc --noEmit 2>&1 | head -50`

Fix any compilation errors.

**Step 2: Start the server to verify it boots**

Run: `cd "/Volumes/Crucial X9/AssignX/api-server" && timeout 10 npx ts-node-dev src/index.ts 2>&1 | tail -20`

Verify it connects to MongoDB and starts listening.

**Step 3: Commit if any fixes were needed**

```bash
git add -A api-server/src/
git commit -m "fix: resolve compilation errors from auth rebuild"
```

---

## Task 8: Rewrite user-web Auth API Client

**Files:**
- Modify: `user-web/lib/api/auth.ts`

**Step 1: Replace the file**

```typescript
import { apiClient } from "./client";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

/** Emails that bypass OTP and login directly */
const DEV_BYPASS_EMAILS = ['admin@gmail.com', 'testuser@gmail.com', 'omrajpal.exe@gmail.com'];

export function isDevBypassEmail(email: string): boolean {
  return DEV_BYPASS_EMAILS.includes(email.toLowerCase().trim());
}

export async function devLogin(email: string): Promise<{ success: boolean; error?: string; user?: any }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/dev-login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), role: "user" }),
    });

    const data = await res.json();
    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Login failed" };
    }

    storeTokens(data);
    return { success: true, user: data.user || data.profile };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

/**
 * Check if an account exists for the given email.
 */
export async function checkAccount(email: string): Promise<{ exists: boolean; error?: string }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/check-account`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim() }),
    });

    const data = await res.json();
    if (!res.ok) {
      return { exists: false, error: data.message || "Check failed" };
    }

    return { exists: data.exists };
  } catch (error: any) {
    return { exists: false, error: error.message || "Network error" };
  }
}

/**
 * Send OTP to email for login or signup.
 */
export async function sendOTP(
  email: string,
  purpose: 'login' | 'signup',
  role?: string
): Promise<{ success: boolean; message?: string; error?: string }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/send-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), purpose, role }),
    });

    const data = await res.json();
    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Failed to send OTP" };
    }

    return { success: true, message: data.message || "Verification code sent" };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

/**
 * Verify OTP code.
 */
export async function verifyOTP(
  email: string,
  otp: string,
  purpose: 'login' | 'signup',
  role?: string
): Promise<{ success: boolean; error?: string; user?: any }> {
  try {
    const res = await fetch(`${API_URL}/api/auth/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: email.toLowerCase().trim(), otp, purpose, role }),
    });

    const data = await res.json();
    if (!res.ok) {
      return { success: false, error: data.message || data.error || "Verification failed" };
    }

    storeTokens(data);
    return { success: true, user: data.user || data.profile };
  } catch (error: any) {
    return { success: false, error: error.message || "Network error" };
  }
}

/**
 * Store tokens from auth response.
 */
function storeTokens(data: any) {
  if (data.accessToken) {
    localStorage.setItem("accessToken", data.accessToken);
    const secure = window.location.protocol === 'https:' ? '; Secure' : '';
    document.cookie = `accessToken=${data.accessToken}; path=/; max-age=604800; SameSite=Lax${secure}`;
    document.cookie = `loggedIn=true; path=/; max-age=604800; SameSite=Lax${secure}`;
  }
  if (data.refreshToken) {
    localStorage.setItem("refreshToken", data.refreshToken);
  }
  const user = data.user || data.profile;
  if (user) {
    localStorage.setItem("user", JSON.stringify(user));
  }
}

export async function logout(): Promise<void> {
  try {
    const token = localStorage.getItem("accessToken");
    if (token) {
      await fetch(`${API_URL}/api/auth/logout`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      }).catch(() => {});
    }
  } finally {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("user");
    document.cookie = "accessToken=; path=/; max-age=0";
    document.cookie = "loggedIn=; path=/; max-age=0";
  }
}

export function getAccessToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("accessToken");
}

export function isLoggedIn(): boolean {
  if (typeof window === "undefined") return false;
  return !!localStorage.getItem("accessToken");
}

export function getStoredUser(): any | null {
  if (typeof window === "undefined") return null;
  try {
    const user = localStorage.getItem("user");
    return user ? JSON.parse(user) : null;
  } catch {
    return null;
  }
}

export async function getCurrentUser(): Promise<any | null> {
  try {
    const user = await apiClient("/api/auth/me");
    if (user) {
      localStorage.setItem("user", JSON.stringify(user));
    }
    return user;
  } catch {
    return null;
  }
}
```

**Step 2: Commit**

```bash
git add user-web/lib/api/auth.ts
git commit -m "feat: rewrite user-web auth API for pure OTP flow

Replace sendMagicLink with sendOTP + checkAccount.
Add purpose param to verifyOTP. Set loggedIn cookie properly."
```

---

## Task 9: Delete user-web Magic Link Files

**Files:**
- Delete: `user-web/app/api/auth/magic-link/route.ts`
- Delete: `user-web/app/auth/callback/route.ts` (if exists)
- Delete: `user-web/components/auth/magic-link-form.tsx`

**Step 1: Remove the files**

```bash
rm -f "user-web/app/api/auth/magic-link/route.ts"
rmdir "user-web/app/api/auth/magic-link" 2>/dev/null || true
rm -f "user-web/app/auth/callback/route.ts"
rmdir "user-web/app/auth/callback" 2>/dev/null || true
rm -f "user-web/components/auth/magic-link-form.tsx"
```

**Step 2: Find and fix any imports of deleted files**

Run: `grep -r "magic-link-form\|magic-link/route\|auth/callback" user-web/app/ user-web/components/ user-web/lib/ --include="*.tsx" --include="*.ts" -l`

Fix any broken imports by removing the import lines or replacing with new components.

**Step 3: Commit**

```bash
git add -A user-web/
git commit -m "refactor: remove magic link files from user-web

Delete magic-link-form component, proxy route, and legacy callback route."
```

---

## Task 10: Rebuild user-web Login Page

**Files:**
- Modify: `user-web/app/(auth)/login/page.tsx`

**Step 1: Rewrite the login page**

The login page should have 2 states:
1. Email input + "Check account" button
2. OTP input (shown after account confirmed + OTP sent)

Read the existing file first to understand the layout/styling patterns, then rewrite it as a clean component using `checkAccount`, `sendOTP`, and `verifyOTP` from `lib/api/auth.ts`.

Key behaviors:
- On email submit: call `checkAccount(email)`. If `exists: false`, show "No account found" with link to `/signup`.
- If account exists: call `sendOTP(email, 'login')`. Show OTP input.
- On OTP submit: call `verifyOTP(email, otp, 'login')`. On success, set `loggedIn` cookie and redirect to `/home`.
- 60-second resend cooldown with visible countdown.
- Dev bypass: if `isDevBypassEmail(email)`, call `devLogin(email)` directly.

**Step 2: Verify the page renders**

Start user-web dev server and navigate to `/login`.

**Step 3: Commit**

```bash
git add user-web/app/\(auth\)/login/page.tsx
git commit -m "feat: rebuild login page with pure OTP flow

Check account existence before sending OTP. Show 'sign up' prompt if no account. 60s resend cooldown."
```

---

## Task 11: Rebuild user-web Signup Page

**Files:**
- Modify: `user-web/app/(auth)/signup/page.tsx`

**Step 1: Rewrite the signup page as a multi-step stepper**

Steps:
1. **Role Selection** — Student | Professional | Business cards
2. **Email + OTP** — Email input, send OTP, enter OTP (all in one step)
3. **Redirect** — On OTP verify success, redirect to `/signup/student` or `/signup/professional` based on role

Key behaviors:
- Step 1: Select role. Student validates `.edu`/`.ac.in`/etc domains.
- Step 2: Enter email. Call `sendOTP(email, 'signup', role)`. If 409 (account exists), show "Already have an account? Log in".
- Enter OTP. Call `verifyOTP(email, otp, 'signup', role)`. On success, store tokens and redirect.
- Store selected role in cookie `signup_role` for the onboarding pages.

**Step 2: Verify the page renders**

Navigate to `/signup` in the dev server.

**Step 3: Commit**

```bash
git add user-web/app/\(auth\)/signup/page.tsx
git commit -m "feat: rebuild signup page with role selection + OTP stepper

Three-step flow: role selection, email+OTP verification, redirect to onboarding."
```

---

## Task 12: Update user-web Auth Store for Multi-Role

**Files:**
- Modify: `user-web/stores/auth-store.ts`

**Step 1: Update onboarding checks for multi-role**

In `checkOnboardingComplete` (line 157), update to handle `userTypes` array:

```typescript
function checkOnboardingComplete(
  user: User | null,
  student: StudentProfile | null,
  professional: ProfessionalProfile | null
): boolean {
  if (!user) return false;

  const userType = user.primary_user_type || user.user_type;
  if (!userType) return false;

  if (userType === "student") {
    return student !== null && !!student.university_id;
  }

  if (userType === "professional" || userType === "business") {
    return professional !== null && !!professional.professional_type;
  }

  return false;
}
```

Similarly update `determineOnboardingStep` to use `primary_user_type || user_type`.

**Step 2: Commit**

```bash
git add user-web/stores/auth-store.ts
git commit -m "feat: update auth store for multi-role support

Use primaryUserType for onboarding checks. Support userTypes array."
```

---

## Task 13: Update Flutter Auth API

**Files:**
- Modify: `user_app/lib/core/api/auth_api.dart`

**Step 1: Replace the file**

```dart
import 'api_client.dart';
import '../storage/token_storage.dart';

class AuthApi {
  /// Check if an account exists for the given email.
  static Future<bool> checkAccount(String email) async {
    final response = await ApiClient.post('/auth/check-account', {'email': email});
    final data = response as Map<String, dynamic>;
    return data['exists'] == true;
  }

  /// Send OTP to the given email.
  static Future<void> sendOTP(String email, String purpose, {String? role}) async {
    await ApiClient.post('/auth/send-otp', {
      'email': email,
      'purpose': purpose,
      if (role != null) 'role': role,
    });
  }

  /// Verify the OTP code.
  /// Saves tokens on success and returns the user data.
  static Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
    String purpose, {
    String? role,
  }) async {
    final response = await ApiClient.post('/auth/verify', {
      'email': email,
      'otp': otp,
      'purpose': purpose,
      if (role != null) 'role': role,
    });
    final data = response as Map<String, dynamic>;

    if (data['accessToken'] != null && data['refreshToken'] != null) {
      await TokenStorage.saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
    }

    return data;
  }

  /// Log out the current user and clear tokens.
  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout');
    } catch (_) {}
    await TokenStorage.clearTokens();
  }

  /// Get the currently authenticated user.
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.get('/auth/me');
      return response as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
```

**Step 2: Commit**

```bash
git add user_app/lib/core/api/auth_api.dart
git commit -m "feat: rewrite Flutter auth API for pure OTP flow

Replace sendMagicLink with sendOTP + checkAccount. Add purpose param to verifyOTP."
```

---

## Task 14: Update Flutter Auth Repository

**Files:**
- Modify: `user_app/lib/data/repositories/auth_repository.dart`

**Step 1: Replace magic link methods with OTP methods**

Replace `signInWithMagicLink` (lines 22-36) with:

```dart
  /// Check if account exists.
  Future<bool> checkAccount(String email) async {
    debugPrint('[AUTH] Checking account for: $email');
    return await AuthApi.checkAccount(email);
  }

  /// Send OTP to email.
  Future<void> sendOTP({
    required String email,
    required String purpose,
    String? role,
  }) async {
    debugPrint('[AUTH] Sending OTP to: $email (purpose: $purpose)');
    await AuthApi.sendOTP(email, purpose, role: role);
  }

  /// Verify OTP.
  Future<Map<String, dynamic>?> verifyOtp({
    required String email,
    required String token,
    required String purpose,
    String? role,
  }) async {
    debugPrint('[AUTH] Verifying OTP for: $email');
    final data = await AuthApi.verifyOTP(email, token, purpose, role: role);
    return data;
  }
```

Remove the old `signInWithMagicLink` method. Keep everything else.

**Step 2: Commit**

```bash
git add user_app/lib/data/repositories/auth_repository.dart
git commit -m "feat: update Flutter auth repository for OTP flow

Replace signInWithMagicLink with checkAccount + sendOTP. Add purpose to verifyOtp."
```

---

## Task 15: Update Flutter Auth Provider

**Files:**
- Modify: `user_app/lib/providers/auth_provider.dart`

**Step 1: Replace signInWithMagicLink with new OTP methods**

Replace `signInWithMagicLink` (lines 237-267) with:

```dart
  /// Check if account exists.
  Future<bool> checkAccount(String email) async {
    return await _authRepository.checkAccount(email);
  }

  /// Send OTP for login or signup.
  Future<void> sendOTP({
    required String email,
    required String purpose,
    String? role,
  }) async {
    state = AsyncValue.data(state.valueOrNull?.copyWith(isLoading: true) ??
        const AuthStateData(isLoading: true));

    try {
      if (role != null) {
        final userType = UserType.values.firstWhere(
          (t) => t.toDbString() == role,
          orElse: () => UserType.student,
        );
        setPreSignInRole(userType);
      }

      await _authRepository.sendOTP(email: email, purpose: purpose, role: role);

      state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: false) ?? const AuthStateData(),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: false, error: e.toString()) ??
            AuthStateData(error: e.toString()),
      );
      rethrow;
    }
  }
```

Update `verifyOtp` (lines 269-303) to accept `purpose` and `role`:

```dart
  /// Verify OTP token.
  Future<bool> verifyOtp({
    required String email,
    required String token,
    required String purpose,
    String? role,
  }) async {
    state = AsyncValue.data(state.valueOrNull?.copyWith(isLoading: true) ??
        const AuthStateData(isLoading: true));

    try {
      final data = await _authRepository.verifyOtp(
        email: email,
        token: token,
        purpose: purpose,
        role: role,
      );

      if (data != null) {
        final userId = (data['user']?['_id'] ?? data['user']?['id'] ?? data['_id'] ?? data['id'] ?? '') as String;
        final userEmail = (data['user']?['email'] ?? data['email'] ?? email) as String;
        final user = AuthUser(id: userId, email: userEmail);
        final profile = await _authRepository.getUserProfile(userId);
        state = AsyncValue.data(AuthStateData(user: user, profile: profile));
        return true;
      } else {
        state = AsyncValue.data(
          state.valueOrNull?.copyWith(isLoading: false) ?? const AuthStateData(),
        );
        return false;
      }
    } catch (e) {
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: false, error: e.toString()) ??
            AuthStateData(error: e.toString()),
      );
      rethrow;
    }
  }
```

**Step 2: Commit**

```bash
git add user_app/lib/providers/auth_provider.dart
git commit -m "feat: update Flutter auth provider for OTP flow

Replace signInWithMagicLink with checkAccount + sendOTP. Add purpose to verifyOtp."
```

---

## Task 16: Delete Flutter Magic Link Screen

**Files:**
- Delete: `user_app/lib/features/auth/screens/magic_link_screen.dart`
- Delete: `user_app/lib/features/auth/widgets/google_sign_in_button.dart`
- Modify: `user_app/lib/core/router/app_router.dart`
- Modify: `user_app/lib/core/router/route_names.dart`

**Step 1: Remove magic link route from router**

In `app_router.dart`, remove the `magicLink` GoRoute (lines 162-173) and the `authCallback` GoRoute (lines 176-185). Remove the imports for `MagicLinkScreen` (line 12).

**Step 2: Remove route names**

In `route_names.dart`, remove lines 14-15:
```dart
  static const String magicLink = '/magic-link';
  static const String authCallback = '/auth-callback';
```

**Step 3: Update publicRoutes in router redirect**

In `app_router.dart` line 82-88, remove `RouteNames.magicLink` and `RouteNames.authCallback` from publicRoutes.

**Step 4: Delete files**

```bash
rm -f "user_app/lib/features/auth/screens/magic_link_screen.dart"
rm -f "user_app/lib/features/auth/widgets/google_sign_in_button.dart"
```

**Step 5: Commit**

```bash
git add -A user_app/
git commit -m "refactor: remove magic link screen and routes from Flutter app

Delete MagicLinkScreen, GoogleSignInButton. Remove magicLink and authCallback routes."
```

---

## Task 17: Rebuild Flutter Login Screen

**Files:**
- Modify: `user_app/lib/features/auth/screens/login_screen.dart`

**Step 1: Rewrite the login screen**

This is a large file (~53KB). Rewrite it with a clean two-state flow:

1. **Email state**: Email input field + "Continue" button
2. **OTP state**: 6-digit OTP input + "Verify" button + resend countdown

Key behaviors:
- On email submit: call `authNotifier.checkAccount(email)`. If false, show SnackBar "No account found" with "Sign Up" button that navigates to `/login` (signup screen in Flutter is the login screen entry, role selection is next).
- If account exists: call `authNotifier.sendOTP(email: email, purpose: 'login')`. Switch to OTP state.
- On OTP submit: call `authNotifier.verifyOtp(email: email, token: otp, purpose: 'login')`. On success, router redirects to home.
- 60-second resend countdown timer.

Keep the existing styling patterns (glass morphism, gradients) but simplify the widget tree.

**Step 2: Verify it compiles**

Run: `cd "/Volumes/Crucial X9/AssignX/user_app" && flutter analyze lib/features/auth/screens/login_screen.dart 2>&1 | tail -20`

**Step 3: Commit**

```bash
git add user_app/lib/features/auth/screens/login_screen.dart
git commit -m "feat: rebuild Flutter login screen with pure OTP flow

Two-state flow: email check then OTP entry. Account existence check before sending OTP."
```

---

## Task 18: Rebuild Flutter Sign-In Screen (or Merge Into Login)

**Files:**
- Modify: `user_app/lib/features/auth/screens/signin_screen.dart`

**Step 1: Decide — merge or keep separate**

The signin_screen.dart is the "returning user" screen. Since login_screen now handles returning users, make signin_screen redirect to login_screen or repurpose it as the signup entry point.

Simplest: make `SignInScreen` a thin wrapper that redirects to `LoginScreen`, OR repurpose it as the signup flow entry (email → OTP → role selection → onboarding).

Recommended: Repurpose `signin_screen.dart` as the signup screen with:
1. Email input
2. Send OTP with `purpose: 'signup'`
3. OTP verification
4. On success, navigate to role selection

**Step 2: Verify it compiles**

Run: `cd "/Volumes/Crucial X9/AssignX/user_app" && flutter analyze lib/features/auth/screens/signin_screen.dart 2>&1 | tail -20`

**Step 3: Commit**

```bash
git add user_app/lib/features/auth/screens/signin_screen.dart
git commit -m "feat: repurpose signin screen as signup flow entry

Email + OTP for signup purpose, then navigate to role selection."
```

---

## Task 19: Update Flutter Role Selection Screen

**Files:**
- Modify: `user_app/lib/features/onboarding/screens/role_selection_screen.dart`

**Step 1: Update to store role in userTypes**

When user selects a role, call:
```dart
await authNotifier.updateProfile(userType: selectedRole);
```

This already works. Just ensure the role maps correctly: Student → 'student', Job Seeker → 'professional', Business → 'business'.

**Step 2: Commit if changes were needed**

```bash
git add user_app/lib/features/onboarding/screens/role_selection_screen.dart
git commit -m "feat: update role selection for multi-role support"
```

---

## Task 20: Full Integration Smoke Test

**Step 1: Start the API server**

```bash
cd "/Volumes/Crucial X9/AssignX/api-server" && npx ts-node-dev src/index.ts &
```

**Step 2: Test the API endpoints with curl**

```bash
# Check non-existent account
curl -s -X POST http://localhost:4000/api/auth/check-account \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@test.com"}'
# Expected: {"exists":false}

# Send signup OTP
curl -s -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@test.com", "purpose": "signup", "role": "student"}'
# Expected: {"success":true,"message":"Verification code sent to your email.","expiresIn":600}

# Check the OTP from dev log
cat /private/tmp/api-server.log | grep "newuser@test.com" | tail -1

# Verify OTP (use the code from log)
curl -s -X POST http://localhost:4000/api/auth/verify \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@test.com", "otp": "CODE_HERE", "purpose": "signup", "role": "student"}'
# Expected: {"accessToken":"...","refreshToken":"...","user":{...}}

# Now check account exists
curl -s -X POST http://localhost:4000/api/auth/check-account \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@test.com"}'
# Expected: {"exists":true}

# Send login OTP
curl -s -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@test.com", "purpose": "login"}'
# Expected: {"success":true,...}
```

**Step 3: Test edge cases**

```bash
# Try signup for existing account
curl -s -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@test.com", "purpose": "signup"}'
# Expected: 409 error

# Try login for non-existent account
curl -s -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "nobody@test.com", "purpose": "login"}'
# Expected: 404 error

# Try wrong OTP (5 times for lockout)
# Expected: decreasing attempts message, then 429 lockout
```

**Step 4: Test user-web**

Start user-web and test login + signup flows in browser.

**Step 5: Final commit**

```bash
git add -A
git commit -m "feat: complete OTP auth rebuild across all platforms

API: pure OTP flow with check-account, send-otp, verify endpoints.
user-web: rebuilt login and signup pages.
user_app: rebuilt auth screens for Flutter.
Removed all magic link code."
```

---

## Summary of All Files Changed

### API Server
| File | Action |
|------|--------|
| `api-server/src/models/AuthToken.ts` | Rewrite — remove magic link fields |
| `api-server/src/models/Profile.ts` | Modify — add userTypes, primaryUserType |
| `api-server/src/services/auth.service.ts` | Rewrite — pure OTP functions |
| `api-server/src/services/email.service.ts` | Modify — remove magic link email |
| `api-server/src/routes/auth.routes.ts` | Rewrite — new endpoints |
| `api-server/src/routes/profile.routes.ts` | Modify — multi-role support |

### User-Web
| File | Action |
|------|--------|
| `user-web/lib/api/auth.ts` | Rewrite — OTP API client |
| `user-web/app/(auth)/login/page.tsx` | Rewrite — OTP login flow |
| `user-web/app/(auth)/signup/page.tsx` | Rewrite — role + OTP stepper |
| `user-web/stores/auth-store.ts` | Modify — multi-role |
| `user-web/components/auth/magic-link-form.tsx` | Delete |
| `user-web/app/api/auth/magic-link/route.ts` | Delete |
| `user-web/app/auth/callback/route.ts` | Delete |

### User App (Flutter)
| File | Action |
|------|--------|
| `user_app/lib/core/api/auth_api.dart` | Rewrite — OTP API |
| `user_app/lib/data/repositories/auth_repository.dart` | Modify — OTP methods |
| `user_app/lib/providers/auth_provider.dart` | Modify — OTP methods |
| `user_app/lib/features/auth/screens/login_screen.dart` | Rewrite — OTP login |
| `user_app/lib/features/auth/screens/signin_screen.dart` | Repurpose as signup |
| `user_app/lib/features/auth/screens/magic_link_screen.dart` | Delete |
| `user_app/lib/features/auth/widgets/google_sign_in_button.dart` | Delete |
| `user_app/lib/core/router/app_router.dart` | Modify — remove magic link routes |
| `user_app/lib/core/router/route_names.dart` | Modify — remove magic link names |
| `user_app/lib/features/onboarding/screens/role_selection_screen.dart` | Modify if needed |
