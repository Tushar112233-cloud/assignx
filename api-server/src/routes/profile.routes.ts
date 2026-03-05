import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { Profile, Student, Professional, Doer, Supervisor, Wallet, WalletTransaction, Project } from '../models';
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
    const profileObj = profile.toObject() as Record<string, any>;
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
      students: roleData && (profile.userType === 'user' || (profile.userType as string) === 'student') ? roleData : null,
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
    const allowedFields = ['fullName', 'phone', 'onboardingStep', 'onboardingCompleted', 'twoFactorEnabled', 'userType', 'userTypes', 'primaryUserType'];
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
      // Mark onboarding complete and set userType on Profile
      const profileUpdates: Record<string, unknown> = { onboardingCompleted: true, userType: 'student' };
      if (req.body.fullName) profileUpdates.fullName = req.body.fullName;
      const existingProfile = await Profile.findById(req.user!.id);
      if (existingProfile) {
        const types = Array.isArray(existingProfile.userTypes) ? [...existingProfile.userTypes] : [];
        if (!types.includes('student')) types.push('student');
        profileUpdates.userTypes = types;
        if (!existingProfile.primaryUserType) profileUpdates.primaryUserType = 'student';
      }
      await Profile.findByIdAndUpdate(req.user!.id, profileUpdates);
      return res.json({ student: updated });
    }
    const student = await Student.create({ ...req.body, profileId: req.user!.id });
    // Mark onboarding complete and set userType on Profile
    const profileUpdates: Record<string, unknown> = { onboardingCompleted: true, userType: 'student' };
    if (req.body.fullName) profileUpdates.fullName = req.body.fullName;
    const existingProfile = await Profile.findById(req.user!.id);
    if (existingProfile) {
      const types = Array.isArray(existingProfile.userTypes) ? [...existingProfile.userTypes] : [];
      if (!types.includes('student')) types.push('student');
      profileUpdates.userTypes = types;
      if (!existingProfile.primaryUserType) profileUpdates.primaryUserType = 'student';
    }
    await Profile.findByIdAndUpdate(req.user!.id, profileUpdates);
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
      // Mark onboarding complete and set userType on Profile
      const profileUpdates: Record<string, unknown> = { onboardingCompleted: true, userType: 'professional' };
      if (req.body.fullName) profileUpdates.fullName = req.body.fullName;
      const existingProfile = await Profile.findById(req.user!.id);
      if (existingProfile) {
        const types = Array.isArray(existingProfile.userTypes) ? [...existingProfile.userTypes] : [];
        if (!types.includes('professional')) types.push('professional');
        profileUpdates.userTypes = types;
        if (!existingProfile.primaryUserType) profileUpdates.primaryUserType = 'professional';
      }
      await Profile.findByIdAndUpdate(req.user!.id, profileUpdates);
      return res.json({ professional: updated });
    }
    const professional = await Professional.create({ ...req.body, profileId: req.user!.id });
    // Mark onboarding complete and set userType on Profile
    const profileUpdates: Record<string, unknown> = { onboardingCompleted: true, userType: 'professional' };
    if (req.body.fullName) profileUpdates.fullName = req.body.fullName;
    const existingProfile = await Profile.findById(req.user!.id);
    if (existingProfile) {
      const types = Array.isArray(existingProfile.userTypes) ? [...existingProfile.userTypes] : [];
      if (!types.includes('professional')) types.push('professional');
      profileUpdates.userTypes = types;
      if (!existingProfile.primaryUserType) profileUpdates.primaryUserType = 'professional';
    }
    await Profile.findByIdAndUpdate(req.user!.id, profileUpdates);
    res.status(201).json({ professional });
  } catch (err) {
    next(err);
  }
});

// GET /profiles/search?email=... — find a user by email
router.get('/search', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email } = req.query;
    if (!email || typeof email !== 'string') throw new AppError('Email is required', 400);

    const profile = await Profile.findOne({ email: email.toLowerCase().trim() })
      .select('fullName email avatarUrl userType');

    if (!profile) {
      return res.json({ user: null });
    }

    // Doers and supervisors cannot receive peer transfers
    const nonTransferRoles = ['doer', 'supervisor', 'admin'];
    if (nonTransferRoles.includes(profile.userType)) {
      return res.json({ user: null });
    }

    res.json({
      user: {
        id: profile._id,
        email: profile.email,
        full_name: profile.fullName || '',
        avatar_url: profile.avatarUrl || null,
        user_type: profile.userType,
      },
    });
  } catch (err) {
    next(err);
  }
});

// POST /profiles/roles — add a role to the current user
router.post('/roles', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { role } = req.body;
    if (!role) throw new AppError('Role is required', 400);

    const profile = await Profile.findById(req.user!.id);
    if (!profile) throw new AppError('Profile not found', 404);

    if (!profile.userTypes || profile.userTypes.length === 0) {
      profile.userTypes = [profile.userType];
    }

    if (!profile.userTypes.includes(role)) {
      profile.userTypes.push(role);
      await profile.save();
    }

    res.json({ roles: profile.userTypes });
  } catch (err) {
    next(err);
  }
});

// DELETE /profiles/roles — remove a role from the current user
router.delete('/roles', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { role } = req.body;
    if (!role) throw new AppError('Role is required', 400);

    const profile = await Profile.findById(req.user!.id);
    if (!profile) throw new AppError('Profile not found', 404);

    if (role === profile.primaryUserType || role === profile.userType) {
      throw new AppError('Cannot remove your primary role', 400);
    }

    if (!profile.userTypes || profile.userTypes.length === 0) {
      profile.userTypes = [profile.userType];
    }

    profile.userTypes = profile.userTypes.filter((r: string) => r !== role);
    await profile.save();

    res.json({ roles: profile.userTypes });
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

// GET /profiles/me/export — export all user data as JSON
router.get('/me/export', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profileId = req.user!.id;

    const [profile, wallet, projects] = await Promise.all([
      Profile.findById(profileId).select('-refreshTokens -password'),
      Wallet.findOne({ profileId }),
      Project.find({ userId: profileId }).select('-__v').sort({ createdAt: -1 }),
    ]);

    const transactions = wallet
      ? await WalletTransaction.find({ walletId: wallet._id }).sort({ createdAt: -1 }).limit(500)
      : [];

    res.json({
      exported_at: new Date().toISOString(),
      profile,
      wallet,
      transactions,
      projects,
    });
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

// GET /profiles/me/subjects — fetch current user's preferred subjects
router.get('/me/subjects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const student = await Student.findOne({ profileId: req.user!.id });
    if (!student) return res.json({ subjects: [] });

    await student.populate('preferredSubjects', 'name category');
    const subjects = (student.preferredSubjects || []).map((s: any) => ({
      id: String(s._id || s),
      name: s.name || null,
      category: s.category || null,
    }));
    res.json({ subjects });
  } catch (err) {
    next(err);
  }
});

// PUT /profiles/me/subjects — update current user's preferred subjects
router.put('/me/subjects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { subjects } = req.body as { subjects: string[] };
    if (!Array.isArray(subjects)) throw new AppError('subjects must be an array', 400);

    let student = await Student.findOne({ profileId: req.user!.id });
    if (!student) {
      // Create student record if it doesn't exist
      student = await Student.create({ profileId: req.user!.id, preferredSubjects: subjects });
    } else {
      student.preferredSubjects = subjects as any;
      await student.save();
    }

    await student.populate('preferredSubjects', 'name category');
    const populated = (student.preferredSubjects || []).map((s: any) => ({
      id: String(s._id),
      name: s.name,
      category: s.category,
    }));
    res.json({ subjects: populated });
  } catch (err) {
    next(err);
  }
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

// GET /profiles/:id/preferences
router.get('/:id/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.params.id).select('preferences');
    if (!profile) throw new AppError('Profile not found', 404);
    res.json(profile.preferences || {});
  } catch (err) {
    next(err);
  }
});

// PUT /profiles/:id/preferences
router.put('/:id/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.params.id).select('preferences');
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

// GET /profiles/:id
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await Profile.findById(req.params.id).select('fullName email avatarUrl userType');
    if (!profile) throw new AppError('Profile not found', 404);
    const obj = profile.toObject();
    res.json({
      ...obj,
      id: obj._id,
      full_name: obj.fullName || null,
      email: obj.email || null,
      avatar_url: obj.avatarUrl || null,
      user_type: obj.userType || null,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
