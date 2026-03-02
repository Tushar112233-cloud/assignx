import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { Profile, Student, Professional, Doer, Supervisor, Wallet } from '../models';
import { uploadBufferToCloudinary } from '../services/upload.service';
import { AppError } from '../middleware/errorHandler';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

// GET /profiles/me
router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id).select('-refreshTokens');
    if (!profile) throw new AppError('Profile not found', 404);

    let roleData = null;
    if (profile.userType === 'doer') {
      roleData = await Doer.findOne({ profileId: profile._id });
    } else if (profile.userType === 'supervisor') {
      roleData = await Supervisor.findOne({ profileId: profile._id });
    } else if (profile.userType === 'user') {
      roleData = await Student.findOne({ profileId: profile._id });
    }

    // Always include wallet data
    const wallet = await Wallet.findOne({ profileId: profile._id });

    // Build flat response that frontend expects
    const profileObj = profile.toObject();
    res.json({
      ...profileObj,
      id: profileObj._id,
      full_name: profileObj.fullName,
      user_type: profileObj.userType,
      avatar_url: profileObj.avatarUrl,
      is_active: true,
      user_roles: [profileObj.userType],
      wallet: wallet ? { id: wallet._id, profile_id: wallet.profileId, balance: wallet.balance, currency: wallet.currency } : null,
      students: roleData && profile.userType === 'user' ? roleData : null,
      roleData,
      profile: profileObj,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /profiles/me
router.put('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const allowedFields = ['fullName', 'phone', 'onboardingStep', 'onboardingCompleted', 'twoFactorEnabled'];
    const updates: Record<string, unknown> = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    }

    const profile = await Profile.findByIdAndUpdate(req.user!.id, updates, { new: true }).select('-refreshTokens');
    if (!profile) throw new AppError('Profile not found', 404);

    res.json({ profile });
  } catch (err) {
    next(err);
  }
});

// POST /profiles/avatar
router.post('/avatar', authenticate, upload.single('avatar'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) throw new AppError('No file provided', 400);
    const result = await uploadBufferToCloudinary(req.file.buffer, 'assignx/avatars');
    const profile = await Profile.findByIdAndUpdate(req.user!.id, { avatarUrl: result.url }, { new: true }).select('-refreshTokens');
    res.json({ profile, avatarUrl: result.url });
  } catch (err) {
    next(err);
  }
});

// POST /profiles/student
router.post('/student', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const existing = await Student.findOne({ profileId: req.user!.id });
    if (existing) {
      const updated = await Student.findByIdAndUpdate(existing._id, req.body, { new: true });
      return res.json({ student: updated });
    }
    const student = await Student.create({ ...req.body, profileId: req.user!.id });
    res.status(201).json({ student });
  } catch (err) {
    next(err);
  }
});

// GET /profiles/me/professional
router.get('/me/professional', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const professional = await Professional.findOne({ profileId: req.user!.id });
    if (!professional) {
      return res.json(null);
    }
    const obj = JSON.parse(JSON.stringify(professional.toObject())) as Record<string, unknown>;
    res.json({
      ...obj,
      id: obj._id,
      profile_id: obj.profileId,
      professional_type: obj.professionalType,
      industry_id: obj.industryId,
      industry_name: obj.industryName ?? null,
      job_title: obj.jobTitle,
      company_name: obj.companyName,
      linkedin_url: obj.linkedinUrl,
      business_type: obj.businessType,
      gst_number: obj.gstNumber,
      created_at: obj.createdAt ?? new Date().toISOString(),
      updated_at: obj.updatedAt ?? null,
    });
  } catch (err) {
    next(err);
  }
});

// POST /profiles/professional
router.post('/professional', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const existing = await Professional.findOne({ profileId: req.user!.id });
    if (existing) {
      const updated = await Professional.findByIdAndUpdate(existing._id, req.body, { new: true });
      return res.json({ professional: updated });
    }
    const professional = await Professional.create({ ...req.body, profileId: req.user!.id });
    res.status(201).json({ professional });
  } catch (err) {
    next(err);
  }
});

// GET /profiles/preferences
router.get('/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id).select('preferences');
    if (!profile) throw new AppError('Profile not found', 404);
    res.json({ preferences: profile.preferences || {} });
  } catch (err) {
    next(err);
  }
});

// PUT /profiles/preferences
router.put('/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id).select('preferences');
    if (!profile) throw new AppError('Profile not found', 404);

    const merged = { ...(profile.preferences || {}), ...req.body };
    profile.preferences = merged;
    profile.markModified('preferences');
    await profile.save();

    res.json({ preferences: merged });
  } catch (err) {
    next(err);
  }
});

// GET /profiles/me/preferences (alias for /profiles/preferences)
router.get('/me/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id).select('preferences');
    if (!profile) throw new AppError('Profile not found', 404);
    res.json(profile.preferences || {});
  } catch (err) {
    next(err);
  }
});

// PUT /profiles/me/preferences (alias for /profiles/preferences)
router.put('/me/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.user!.id).select('preferences');
    if (!profile) throw new AppError('Profile not found', 404);

    const merged = { ...(profile.preferences || {}), ...req.body };
    profile.preferences = merged;
    profile.markModified('preferences');
    await profile.save();

    res.json(merged);
  } catch (err) {
    next(err);
  }
});

// GET /profiles/me/referral
router.get('/me/referral', authenticate, async (req: Request, res: Response) => {
  res.json({
    id: req.user!.id,
    _id: req.user!.id,
    userId: req.user!.id,
    code: '',
    totalReferrals: 0,
    totalEarnings: 0,
    createdAt: new Date().toISOString(),
  });
});

// GET /profiles/me/payment-methods
router.get('/me/payment-methods', authenticate, async (_req: Request, res: Response) => {
  // Payment methods are not yet implemented in MongoDB
  res.json({ paymentMethods: [] });
});

// POST /profiles/me/payment-methods
router.post('/me/payment-methods', authenticate, async (req: Request, res: Response) => {
  // Stub: accept but return the input as-is
  res.status(201).json({ ...req.body, id: Date.now().toString(), createdAt: new Date().toISOString() });
});

// DELETE /profiles/me/payment-methods/:id
router.delete('/me/payment-methods/:id', authenticate, async (_req: Request, res: Response) => {
  res.json({ success: true });
});

// GET /profiles/:id
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.params.id).select('fullName email avatarUrl userType');
    if (!profile) throw new AppError('Profile not found', 404);
    res.json({ profile });
  } catch (err) {
    next(err);
  }
});

export default router;
