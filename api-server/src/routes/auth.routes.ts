import { Router, Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { checkAccount, sendOTP, verifyOTP, doerSignup, supervisorSignup, refreshTokens, logout } from '../services/auth.service';
import { AccessRequest } from '../models/AccessRequest';
import { generateAccessToken, generateRefreshToken } from '../services/jwt.service';
import { authenticate } from '../middleware/auth';
import { authLimiter } from '../middleware/rateLimiter';
import { User, Doer, Supervisor, Admin } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

const DEV_BYPASS_EMAILS = ['admin@gmail.com', 'admin@assignx.in'];

function getModelByRole(role: string): any {
  switch (role) {
    case 'user': case 'student': case 'professional': case 'business': return User;
    case 'doer': return Doer;
    case 'supervisor': return Supervisor;
    case 'admin': return Admin;
    default: throw new AppError(`Invalid role: ${role}`, 400);
  }
}

async function directLogin(email: string, role: string) {
  const effectiveRole = ['student', 'professional', 'business'].includes(role) ? 'user' : role;
  const Model = getModelByRole(role);

  let account = await Model.findOne({ email });
  if (!account) {
    if (effectiveRole === 'admin') {
      account = await Admin.create({
        email,
        fullName: email === 'admin@gmail.com' ? 'Admin User' : '',
        adminRole: 'super_admin',
      });
    } else if (effectiveRole === 'user') {
      account = await User.create({
        email,
        fullName: '',
        userType: (role as 'student' | 'professional' | 'business') || 'student',
        onboardingCompleted: true,
      });
    } else if (effectiveRole === 'doer') {
      account = await Doer.create({
        email,
        fullName: '',
        isActivated: true,
        onboardingCompleted: true,
      });
    } else if (effectiveRole === 'supervisor') {
      account = await Supervisor.create({
        email,
        fullName: '',
        isActivated: true,
        onboardingCompleted: true,
      });
    }
  }

  const tokenPayload = {
    sub: account!._id.toString(),
    email: (account as any).email,
    role: effectiveRole,
  };

  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  const refreshHash = await bcrypt.hash(refreshToken, 10);
  (account as any).refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  (account as any).lastLoginAt = new Date();
  await account!.save();

  const userData = {
    id: account!._id,
    email: (account as any).email,
    fullName: (account as any).fullName,
    avatarUrl: (account as any).avatarUrl,
    role: effectiveRole,
    userType: effectiveRole,
    onboardingCompleted: (account as any).onboardingCompleted ?? true,
  };

  return {
    accessToken,
    refreshToken,
    user: userData,
    profile: userData,
  };
}

router.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password, role } = req.body;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = email.toLowerCase().trim();
    const loginRole = role || 'user';

    // Admin password-based login
    if (loginRole === 'admin' || DEV_BYPASS_EMAILS.includes(normalizedEmail)) {
      const admin = await Admin.findOne({ email: normalizedEmail });

      if (admin && admin.password && password) {
        const isValid = await bcrypt.compare(password, admin.password);
        if (!isValid) {
          throw new AppError('Invalid credentials', 401);
        }
        const result = await directLogin(normalizedEmail, 'admin');
        return res.json(result);
      }

      // Dev bypass for known emails (no password required)
      if (DEV_BYPASS_EMAILS.includes(normalizedEmail)) {
        const result = await directLogin(normalizedEmail, 'admin');
        return res.json(result);
      }

      if (!admin) {
        throw new AppError('No admin account found for this email', 404);
      }
      throw new AppError('Invalid credentials', 401);
    }

    if (!password) {
      // In dev mode, allow passwordless login
      if (process.env.NODE_ENV === 'development') {
        const result = await directLogin(normalizedEmail, loginRole);
        return res.json(result);
      }
      throw new AppError('Password is required', 400);
    }

    // Check if account exists in the role's collection
    const Model = getModelByRole(loginRole);
    const account = await Model.findOne({ email: normalizedEmail });
    if (!account) {
      throw new AppError('No account found for this email', 404);
    }

    if (process.env.NODE_ENV === 'development') {
      const result = await directLogin(normalizedEmail, loginRole);
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
    const { email, role } = req.body;
    if (!email) throw new AppError('Email is required', 400);
    const result = await checkAccount(email, role);
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
    if (!role) throw new AppError('Role is required', 400);
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
    if (!role) throw new AppError('Role is required', 400);
    const result = await verifyOTP(email, otp, purpose, role);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

router.post('/doer-signup', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, otp, fullName, metadata } = req.body;
    if (!email || !otp || !fullName || !metadata) {
      throw new AppError('email, otp, fullName, and metadata are required', 400);
    }
    const result = await doerSignup(email.toLowerCase().trim(), otp, fullName.trim(), metadata);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
});

router.post('/supervisor-signup', authLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, otp, fullName, metadata } = req.body;
    if (!email || !otp || !fullName || !metadata) {
      throw new AppError('email, otp, fullName, and metadata are required', 400);
    }
    const result = await supervisorSignup(email.toLowerCase().trim(), otp, fullName.trim(), metadata);
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

    if (role === 'doer') {
      const doer = await Doer.findOne({ email: normalizedEmail });
      if (!doer) {
        const accessReq = await AccessRequest.findOne({ email: normalizedEmail, role: 'doer' }).sort({ createdAt: -1 });
        if (accessReq) {
          if (accessReq.status === 'pending') return res.json({ status: 'pending' });
          if (accessReq.status === 'rejected') return res.json({ status: 'rejected' });
        }
        return res.json({ status: 'not_found' });
      }
      if (!doer.isActivated) {
        return res.json({ status: 'pending', isActivated: false });
      }
      return res.json({ status: 'approved', isActivated: true });
    }

    if (role === 'supervisor') {
      const supervisor = await Supervisor.findOne({ email: normalizedEmail });
      if (!supervisor) {
        const accessReq = await AccessRequest.findOne({ email: normalizedEmail, role: 'supervisor' }).sort({ createdAt: -1 });
        if (accessReq) {
          if (accessReq.status === 'pending') return res.json({ status: 'pending' });
          if (accessReq.status === 'rejected') return res.json({ status: 'rejected' });
        }
        return res.json({ status: 'not_found' });
      }
      if (!(supervisor as any).isActivated) {
        return res.json({ status: 'pending', isActivated: false });
      }
      return res.json({ status: 'approved', isActivated: true });
    }

    // For users, just check if account exists
    if (role === 'user' || role === 'student' || role === 'professional' || role === 'business') {
      const user = await User.findOne({ email: normalizedEmail });
      if (!user) return res.json({ status: 'not_found' });
      return res.json({ status: 'approved' });
    }

    res.json({ status: 'not_found' });
  } catch (err) {
    next(err);
  }
});

router.get('/access-request', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = (email as string).toLowerCase().trim();

    if (role === 'supervisor') {
      const supervisor = await Supervisor.findOne({ email: normalizedEmail });
      if (!supervisor) return res.json({ status: 'approved', needsOnboarding: true });
      return res.json({ status: 'approved' });
    }

    res.json({ status: 'approved' });
  } catch (err) {
    next(err);
  }
});

router.get('/supervisor-status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const normalizedEmail = (email as string).toLowerCase().trim();

    const accessReq = await AccessRequest.findOne({ email: normalizedEmail, role: 'supervisor' }).sort({ createdAt: -1 });

    if (!accessReq) {
      const supervisor = await Supervisor.findOne({ email: normalizedEmail });
      if (supervisor) {
        return res.json({ status: 'approved', isActivated: (supervisor as any).isActivated });
      }
      return res.json({ status: 'not_found' });
    }

    if (accessReq.status === 'pending') return res.json({ status: 'pending' });
    if (accessReq.status === 'rejected') return res.json({ status: 'rejected' });

    const supervisor = await Supervisor.findOne({ email: normalizedEmail });
    return res.json({
      status: 'approved',
      isActivated: supervisor ? (supervisor as any).isActivated : false,
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
    const user = (req as any).user!;
    const { refreshToken } = req.body;
    await logout(user.id, user.role, refreshToken || '');
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user!;
    const Model = getModelByRole(user.role);
    const account = await Model.findById(user.id).select('-refreshTokens');
    if (!account) throw new AppError('Account not found', 404);

    res.json({
      ...((account as any).toObject()),
      id: account._id,
      role: user.role,
      userType: user.role,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
