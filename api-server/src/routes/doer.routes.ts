import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/roleGuard';
import { Doer, DoerActivation, DoerReview, Profile, Project, Wallet } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/** Normalize a doer document to snake_case for frontend compatibility */
function normalizeDoer(obj: Record<string, any>) {
  return {
    ...obj,
    id: obj._id,
    profile_id: obj.profileId,
    is_activated: obj.isActivated,
    is_available: obj.isAvailable,
    qualification: obj.qualification,
    university_name: obj.universityName,
    experience_level: obj.experienceLevel,
    years_of_experience: obj.yearsOfExperience,
    bio: obj.bio,
    max_concurrent_projects: obj.maxConcurrentProjects,
    activated_at: obj.activatedAt,
    total_earnings: obj.totalEarnings,
    total_projects_completed: obj.totalProjectsCompleted,
    average_rating: obj.averageRating,
    total_reviews: obj.totalReviews,
    success_rate: obj.successRate,
    on_time_delivery_rate: obj.onTimeDeliveryRate,
    bank_account_name: obj.bankDetails?.accountName,
    bank_account_number: obj.bankDetails?.accountNumber,
    bank_ifsc_code: obj.bankDetails?.ifscCode,
    bank_name: obj.bankDetails?.bankName,
    bank_upi_id: obj.bankDetails?.upiId,
    bank_verified: obj.bankDetails?.verified,
    is_flagged: obj.isFlagged,
    is_access_granted: obj.isAccessGranted,
    created_at: obj.createdAt,
    updated_at: obj.updatedAt,
  };
}

// GET /doers
router.get('/', authenticate, requireRole('admin', 'supervisor'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', isActivated, isAvailable } = req.query;
    const filter: Record<string, unknown> = {};
    if (isActivated !== undefined) filter.isActivated = isActivated === 'true';
    if (isAvailable !== undefined) filter.isAvailable = isAvailable === 'true';

    const skip = (Number(page) - 1) * Number(limit);
    const [doers, total] = await Promise.all([
      Doer.find(filter).populate('profileId', 'fullName email avatarUrl').skip(skip).limit(Number(limit)).sort({ createdAt: -1 }),
      Doer.countDocuments(filter),
    ]);

    const normalizedDoers = doers.map(d => {
      const obj = d.toObject();
      const profile = obj.profileId && typeof obj.profileId === 'object' ? obj.profileId as any : null;
      return {
        ...normalizeDoer(obj),
        // Flatten populated profile
        full_name: profile?.fullName || null,
        email: profile?.email || null,
        avatar_url: profile?.avatarUrl || null,
        // Flatten skills and subjects to string arrays
        skills: (obj.skills || []).map((s: any) => typeof s === 'string' ? s : s.skillId || s.name || 'Unknown'),
        subjects: (obj.subjects || []).map((s: any) => typeof s === 'string' ? s : s.name || s.subjectId || 'Unknown'),
      };
    });
    res.json({ doers: normalizedDoers, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// GET /doers/by-profile/:profileId
router.get('/by-profile/:profileId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findOne({ profileId: req.params.profileId }).populate('profileId', 'fullName email avatarUrl phone');
    if (!doer) throw new AppError('Doer not found', 404);
    res.json(normalizeDoer(doer.toObject()));
  } catch (err) {
    next(err);
  }
});

// GET /doers/by-profile/:profileId/full - Full profile with stats for profile page
router.get('/by-profile/:profileId/full', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profileId = req.params.profileId;
    const [profile, doer, wallet, activeCount] = await Promise.all([
      Profile.findById(profileId).select('-refreshTokens'),
      Doer.findOne({ profileId }),
      Wallet.findOne({ profileId }),
      Project.countDocuments({ doerId: profileId, status: { $in: ['assigned', 'in_progress', 'revision_requested'] } }),
    ]);

    if (!profile) throw new AppError('Profile not found', 404);

    const profileObj = profile.toObject();
    const normalizedProfile = {
      ...profileObj,
      id: profileObj._id,
      full_name: profileObj.fullName,
      user_type: profileObj.userType,
      avatar_url: profileObj.avatarUrl,
      created_at: profileObj.createdAt,
      updated_at: profileObj.updatedAt,
    };

    let normalizedDoer = null;
    let stats = null;

    if (doer) {
      normalizedDoer = normalizeDoer(doer.toObject());
      stats = {
        activeAssignments: activeCount,
        completedProjects: doer.totalProjectsCompleted || 0,
        totalEarnings: doer.totalEarnings || 0,
        pendingEarnings: wallet?.balance || 0,
        averageRating: doer.averageRating || 0,
        totalReviews: doer.totalReviews || 0,
        successRate: doer.successRate || 0,
        onTimeDeliveryRate: doer.onTimeDeliveryRate || 0,
        qualityRating: 0,
        timelinessRating: 0,
        communicationRating: 0,
      };
    }

    res.json({ profile: normalizedProfile, doer: normalizedDoer, stats });
  } catch (err) {
    next(err);
  }
});

// GET /doers/:id
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findById(req.params.id).populate('profileId', 'fullName email avatarUrl phone');
    if (!doer) throw new AppError('Doer not found', 404);
    res.json({ doer });
  } catch (err) {
    next(err);
  }
});

// PUT /doers/:id
router.put('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!doer) throw new AppError('Doer not found', 404);
    res.json({ doer });
  } catch (err) {
    next(err);
  }
});

// POST /doers/:id/skills
router.post('/:id/skills', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findByIdAndUpdate(
      req.params.id,
      { skills: req.body.skills },
      { new: true }
    );
    if (!doer) throw new AppError('Doer not found', 404);
    res.json({ doer });
  } catch (err) {
    next(err);
  }
});

// POST /doers/:id/subjects
router.post('/:id/subjects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findByIdAndUpdate(
      req.params.id,
      { subjects: req.body.subjects },
      { new: true }
    );
    if (!doer) throw new AppError('Doer not found', 404);
    res.json({ doer });
  } catch (err) {
    next(err);
  }
});

// PUT /doers/:id/bank-details
router.put('/:id/bank-details', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findByIdAndUpdate(
      req.params.id,
      { bankDetails: req.body },
      { new: true }
    );
    if (!doer) throw new AppError('Doer not found', 404);
    res.json({ doer });
  } catch (err) {
    next(err);
  }
});

// GET /doers/:id/activation
router.get('/:id/activation', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const activation = await DoerActivation.findOne({ doerId: req.params.id });
    res.json({ activation });
  } catch (err) {
    next(err);
  }
});

// GET /doers/:id/reviews
router.get('/:id/reviews', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20' } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const [reviews, total] = await Promise.all([
      DoerReview.find({ doerId: req.params.id })
        .populate('reviewerId', 'fullName avatarUrl')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      DoerReview.countDocuments({ doerId: req.params.id }),
    ]);

    const normalizedReviews = reviews.map(r => {
      const obj = r.toObject();
      const reviewer = obj.reviewerId && typeof obj.reviewerId === 'object' ? obj.reviewerId as any : null;
      return {
        ...obj,
        id: obj._id,
        doer_id: obj.doerId,
        reviewer_id: obj.reviewerId,
        project_id: obj.projectId,
        created_at: obj.createdAt,
        reviewer_name: reviewer?.fullName || null,
        reviewer_avatar: reviewer?.avatarUrl || null,
      };
    });

    res.json({ reviews: normalizedReviews, total });
  } catch (err) {
    next(err);
  }
});

export default router;
