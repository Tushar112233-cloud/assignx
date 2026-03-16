import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { User, UserWallet, WalletTransaction, Project } from '../models';
import { uploadBufferToCloudinary } from '../services/upload.service';
import { AppError } from '../middleware/errorHandler';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

// GET /users/me
router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user!.id).select('-refreshTokens');
    if (!user) throw new AppError('User not found', 404);

    const wallet = await UserWallet.findOne({ userId: user._id });

    const userObj = user.toObject() as Record<string, any>;
    res.json({
      ...userObj,
      id: userObj._id,
      full_name: userObj.fullName,
      user_type: userObj.userType,
      avatar_url: userObj.avatarUrl,
      is_active: true,
      wallet: wallet ? { id: wallet._id, user_id: wallet.userId, balance: wallet.balance, currency: wallet.currency } : null,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /users/me
router.put('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const allowedFields = ['fullName', 'phone', 'avatarUrl', 'onboardingStep', 'onboardingCompleted', 'userType',
      'universityId', 'courseId', 'semester', 'yearOfStudy', 'studentIdNumber',
      'expectedGraduationYear', 'collegeEmail', 'preferredSubjects',
      'professionalType', 'industryId', 'jobTitle', 'companyName', 'linkedinUrl',
      'businessType', 'gstNumber'];
    const updates: Record<string, unknown> = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    }

    const user = await User.findByIdAndUpdate(req.user!.id, updates, { new: true }).select('-refreshTokens');
    if (!user) throw new AppError('User not found', 404);

    res.json({ user });
  } catch (err) {
    next(err);
  }
});

// POST /users/avatar
router.post('/avatar', authenticate, upload.single('avatar'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) throw new AppError('No file provided', 400);
    const result = await uploadBufferToCloudinary(req.file.buffer, 'assignx/avatars');
    const user = await User.findByIdAndUpdate(req.user!.id, { avatarUrl: result.url }, { new: true }).select('-refreshTokens');
    res.json({ user, avatarUrl: result.url });
  } catch (err) {
    next(err);
  }
});

// GET /users/search?email=...
router.get('/search', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email } = req.query;
    if (!email || typeof email !== 'string') throw new AppError('Email is required', 400);

    const user = await User.findOne({ email: email.toLowerCase().trim() })
      .select('fullName email avatarUrl userType');

    if (!user) {
      return res.json({ user: null });
    }

    res.json({
      user: {
        id: user._id,
        email: user.email,
        full_name: user.fullName || '',
        avatar_url: user.avatarUrl || null,
        user_type: user.userType,
      },
    });
  } catch (err) {
    next(err);
  }
});

// GET /users/preferences
router.get('/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user!.id).select('preferences');
    if (!user) throw new AppError('User not found', 404);
    res.json({ preferences: user.preferences || {} });
  } catch (err) {
    next(err);
  }
});

// PUT /users/preferences
router.put('/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user!.id).select('preferences');
    if (!user) throw new AppError('User not found', 404);

    const merged = { ...(user.preferences || {}), ...req.body };
    user.preferences = merged;
    user.markModified('preferences');
    await user.save();

    res.json({ preferences: merged });
  } catch (err) {
    next(err);
  }
});

// GET /users/me/preferences (alias)
router.get('/me/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user!.id).select('preferences');
    if (!user) throw new AppError('User not found', 404);
    res.json(user.preferences || {});
  } catch (err) {
    next(err);
  }
});

// PUT /users/me/preferences (alias)
router.put('/me/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user!.id).select('preferences');
    if (!user) throw new AppError('User not found', 404);

    const merged = { ...(user.preferences || {}), ...req.body };
    user.preferences = merged;
    user.markModified('preferences');
    await user.save();

    res.json(merged);
  } catch (err) {
    next(err);
  }
});

// GET /users/me/export
router.get('/me/export', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const [user, wallet, projects] = await Promise.all([
      User.findById(userId).select('-refreshTokens'),
      UserWallet.findOne({ userId }),
      Project.find({ userId }).select('-__v').sort({ createdAt: -1 }),
    ]);

    const transactions = wallet
      ? await WalletTransaction.find({ walletId: wallet._id }).sort({ createdAt: -1 }).limit(500)
      : [];

    res.json({
      exported_at: new Date().toISOString(),
      user,
      wallet,
      transactions,
      projects,
    });
  } catch (err) {
    next(err);
  }
});

// GET /users/me/referral
router.get('/me/referral', authenticate, async (req: Request, res: Response) => {
  res.json({
    id: req.user!.id,
    userId: req.user!.id,
    code: '',
    totalReferrals: 0,
    totalEarnings: 0,
    createdAt: new Date().toISOString(),
  });
});

// GET /users/me/payment-methods
router.get('/me/payment-methods', authenticate, async (_req: Request, res: Response) => {
  res.json({ paymentMethods: [] });
});

// POST /users/me/payment-methods
router.post('/me/payment-methods', authenticate, async (req: Request, res: Response) => {
  res.status(201).json({ ...req.body, id: Date.now().toString(), createdAt: new Date().toISOString() });
});

// DELETE /users/me/payment-methods/:id
router.delete('/me/payment-methods/:id', authenticate, async (_req: Request, res: Response) => {
  res.json({ success: true });
});

// GET /users/me/subjects
router.get('/me/subjects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.user!.id);
    if (!user || !user.preferredSubjects || user.preferredSubjects.length === 0) {
      return res.json({ subjects: [] });
    }

    await user.populate('preferredSubjects', 'name category');
    const subjects = (user.preferredSubjects || []).map((s: any) => ({
      id: String(s._id || s),
      name: s.name || null,
      category: s.category || null,
    }));
    res.json({ subjects });
  } catch (err) {
    next(err);
  }
});

// PUT /users/me/subjects
router.put('/me/subjects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { subjects } = req.body as { subjects: string[] };
    if (!Array.isArray(subjects)) throw new AppError('subjects must be an array', 400);

    const user = await User.findById(req.user!.id);
    if (!user) throw new AppError('User not found', 404);

    user.preferredSubjects = subjects as any;
    await user.save();

    await user.populate('preferredSubjects', 'name category');
    const populated = (user.preferredSubjects || []).map((s: any) => ({
      id: String(s._id),
      name: s.name,
      category: s.category,
    }));
    res.json({ subjects: populated });
  } catch (err) {
    next(err);
  }
});

// GET /users/:id
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.params.id).select('fullName email avatarUrl userType');
    if (!user) throw new AppError('User not found', 404);
    const obj = user.toObject();
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

// GET /users/:id/preferences
router.get('/:id/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.params.id).select('preferences');
    if (!user) throw new AppError('User not found', 404);
    res.json(user.preferences || {});
  } catch (err) {
    next(err);
  }
});

// PUT /users/:id/preferences
router.put('/:id/preferences', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.params.id).select('preferences');
    if (!user) throw new AppError('User not found', 404);

    const merged = { ...(user.preferences || {}), ...req.body };
    user.preferences = merged;
    user.markModified('preferences');
    await user.save();

    res.json(merged);
  } catch (err) {
    next(err);
  }
});

export default router;
