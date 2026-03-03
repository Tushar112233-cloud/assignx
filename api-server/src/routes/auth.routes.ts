import { Router, Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { sendMagicLink, verifyOTP, verifyMagicLink, checkMagicLinkStatus, refreshTokens, logout } from '../services/auth.service';
import { generateAccessToken, generateRefreshToken } from '../services/jwt.service';
import { authenticate } from '../middleware/auth';
import { authLimiter } from '../middleware/rateLimiter';
import { Profile, Doer, Supervisor, Admin, Student, Professional } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Dev emails that can bypass magic link and login directly
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
      fullName: email === 'admin@gmail.com' ? 'Admin User' : undefined,
      onboardingCompleted: true,
    });
    // Also create the role-specific document
    if ((profile.userType === 'admin') && !(await Admin.findOne({ profileId: profile._id }))) {
      await Admin.create({ profileId: profile._id, email, adminRole: 'super_admin' });
    }
  }

  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.userType,
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
      role: profile.userType,
      userType: profile.userType,
      onboardingCompleted: profile.onboardingCompleted,
    },
    profile: {
      id: profile._id,
      email: profile.email,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      userType: profile.userType,
      onboardingCompleted: profile.onboardingCompleted,
    },
  };
}

// POST /auth/login - Direct email-based login (no OTP) for dev bypass emails
// Also serves as password login for admin panel
router.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = email.toLowerCase().trim();

    // Dev bypass: allow direct login for specific emails
    if (DEV_BYPASS_EMAILS.includes(normalizedEmail)) {
      const result = await directLogin(normalizedEmail, 'admin');
      return res.json(result);
    }

    // For non-bypass emails, require a password or reject
    if (!password) {
      throw new AppError('Password is required for non-bypass accounts', 400);
    }

    // Check if profile exists
    const profile = await Profile.findOne({ email: normalizedEmail });
    if (!profile) {
      throw new AppError('No account found for this email', 404);
    }

    // For now, dev mode allows any password
    if (process.env.NODE_ENV === 'development') {
      const result = await directLogin(normalizedEmail, profile.userType);
      return res.json(result);
    }

    throw new AppError('Invalid credentials', 401);
  } catch (err) {
    next(err);
  }
});

// POST /auth/dev-login - Bypass login for development (no OTP, no password)
router.post('/dev-login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = req.body;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = email.toLowerCase().trim();
    const result = await directLogin(normalizedEmail, role || 'user');
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

    // For doers, check if they have a doer record
    if (role === 'doer') {
      const doer = await Doer.findOne({ profileId: profile._id });
      if (!doer) {
        // Profile exists but no doer record - they may need onboarding
        return res.json({ status: 'approved', needsOnboarding: true });
      }
      return res.json({ status: 'approved', isActivated: doer.isActivated });
    }

    // For supervisors, check supervisor record
    if (role === 'supervisor') {
      const supervisor = await Supervisor.findOne({ profileId: profile._id });
      if (!supervisor) {
        return res.json({ status: 'approved', needsOnboarding: true });
      }
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
    if (!profile) {
      return res.json({ status: 'not_found' });
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

// POST /auth/magic-link
router.post('/magic-link', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role, callbackUrl } = req.body;
    if (!email) throw new AppError('Email is required', 400);
    const result = await sendMagicLink(email.toLowerCase().trim(), role, callbackUrl);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/magic-link/verify - Mark magic link as verified (called from email link page)
router.post('/magic-link/verify', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, token } = req.body;
    if (!email || !token) throw new AppError('Email and token are required', 400);
    const result = await verifyMagicLink(email.toLowerCase().trim(), token);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/magic-link/check - Poll verification status (called from original login tab)
router.post('/magic-link/check', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, sessionId } = req.body;
    if (!email || !sessionId) throw new AppError('Email and sessionId are required', 400);
    const result = await checkMagicLinkStatus(email.toLowerCase().trim(), sessionId);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/verify
router.post('/verify', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) throw new AppError('Email and OTP are required', 400);
    const result = await verifyOTP(email.toLowerCase().trim(), otp);
    res.json(result);
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
    } else if (profile.userType === 'user') {
      roleData = await Student.findOne({ profileId: profile._id }) ||
                 await Professional.findOne({ profileId: profile._id });
    }

    res.json({ profile, roleData });
  } catch (err) {
    next(err);
  }
});

export default router;
