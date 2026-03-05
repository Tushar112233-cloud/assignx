import { Router, Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { checkAccount, sendOTP, verifyOTP, doerSignup, supervisorSignup, refreshTokens, logout } from '../services/auth.service';
import { AccessRequest } from '../models/AccessRequest';
import { generateAccessToken, generateRefreshToken } from '../services/jwt.service';
import { authenticate } from '../middleware/auth';
import { authLimiter } from '../middleware/rateLimiter';
import { Profile, Doer, Supervisor, Admin, Student, Professional } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

const DEV_BYPASS_EMAILS = ['admin@gmail.com'];

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

// POST /auth/doer-signup - Verify OTP + create doer profile (pending admin approval)
router.post('/doer-signup', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, otp, fullName, metadata } = req.body;
    if (!email || !otp || !fullName || !metadata) {
      throw new AppError('email, otp, fullName, and metadata are required', 400);
    }
    const result = await doerSignup(
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

router.get('/access-status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = (email as string).toLowerCase().trim();
    const profile = await Profile.findOne({ email: normalizedEmail });

    if (!profile) {
      // Check if there's a pending access request
      if (role === 'doer') {
        const accessReq = await AccessRequest.findOne({ email: normalizedEmail, role: 'doer' }).sort({ createdAt: -1 });
        if (accessReq) {
          if (accessReq.status === 'pending') return res.json({ status: 'pending' });
          if (accessReq.status === 'rejected') return res.json({ status: 'rejected' });
        }
      }
      return res.json({ status: 'not_found' });
    }

    if (role === 'doer') {
      const doer = await Doer.findOne({ profileId: profile._id });
      if (!doer) {
        // Check access request
        const accessReq = await AccessRequest.findOne({ email: normalizedEmail, role: 'doer' }).sort({ createdAt: -1 });
        if (accessReq && accessReq.status === 'pending') {
          return res.json({ status: 'pending' });
        }
        return res.json({ status: 'approved', needsOnboarding: true });
      }
      if (!doer.isActivated) {
        return res.json({ status: 'pending', isActivated: false });
      }
      return res.json({ status: 'approved', isActivated: true });
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

// GET /auth/supervisor-status?email= — Unified status check for supervisor login/signup
router.get('/supervisor-status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = (email as string).toLowerCase().trim();

    // Check access request first
    const accessReq = await AccessRequest.findOne({ email: normalizedEmail, role: 'supervisor' }).sort({ createdAt: -1 });

    if (!accessReq) {
      // Check if they have a profile+supervisor record (legacy)
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

router.post('/logout', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = req.body;
    await logout(req.user!.id, refreshToken || '');
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

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
      roleData = await Student.findOne({ profileId: profile._id }) ||
                 await Professional.findOne({ profileId: profile._id });
    }

    res.json({ profile, roleData });
  } catch (err) {
    next(err);
  }
});

export default router;
