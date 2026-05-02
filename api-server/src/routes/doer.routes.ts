import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/roleGuard';
import { Doer, DoerActivation, DoerWallet, UserDoerReview, SupervisorDoerReview, Project } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/** Normalize a doer document to snake_case for frontend compatibility */
function normalizeDoer(obj: Record<string, any>) {
  return {
    ...obj,
    id: obj._id,
    full_name: obj.fullName,
    email: obj.email,
    avatar_url: obj.avatarUrl,
    phone: obj.phone,
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
    training_completed: obj.trainingCompleted,
    trainingCompleted: obj.trainingCompleted,
    onboarding_completed: obj.onboardingCompleted,
    onboardingCompleted: obj.onboardingCompleted,
    is_flagged: obj.isFlagged,
    is_access_granted: obj.isAccessGranted,
    created_at: obj.createdAt,
    updated_at: obj.updatedAt,
  };
}

// GET /doers/me — current doer's own profile
router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findById(req.user!.id).lean();
    if (!doer) throw new AppError('Doer not found', 404);
    res.json(normalizeDoer(doer as Record<string, any>));
  } catch (err) { next(err); }
});

// GET /doers
router.get('/', authenticate, requireRole('admin', 'supervisor'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', isActivated, isAvailable } = req.query;
    const filter: Record<string, unknown> = {};
    if (isActivated !== undefined) filter.isActivated = isActivated === 'true';
    if (isAvailable !== undefined) filter.isAvailable = isAvailable === 'true';

    const skip = (Number(page) - 1) * Number(limit);
    const [doers, total] = await Promise.all([
      Doer.find(filter).skip(skip).limit(Number(limit)).sort({ createdAt: -1 }),
      Doer.countDocuments(filter),
    ]);

    const normalizedDoers = doers.map(d => {
      const obj = d.toObject();
      return {
        ...normalizeDoer(obj),
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

// GET /doers/by-id/:doerId
router.get('/by-id/:doerId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findById(req.params.doerId);
    if (!doer) throw new AppError('Doer not found', 404);
    res.json(normalizeDoer(doer.toObject()));
  } catch (err) {
    next(err);
  }
});

// GET /doers/by-id/:doerId/full - Full profile with stats for profile page
router.get('/by-id/:doerId/full', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doerId = req.params.doerId;
    const [doer, wallet, activeCount] = await Promise.all([
      Doer.findById(doerId),
      DoerWallet.findOne({ doerId }),
      Project.countDocuments({ doerId, status: { $in: ['assigned', 'in_progress', 'revision_requested'] } }),
    ]);

    if (!doer) throw new AppError('Doer not found', 404);

    const doerObj = doer.toObject();
    const normalizedDoerData = normalizeDoer(doerObj);

    const stats = {
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

    res.json({ doer: normalizedDoerData, stats });
  } catch (err) {
    next(err);
  }
});

// GET /doers/:id
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findById(req.params.id);
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
    const doerId = req.params.id;

    const [userReviews, supervisorReviews, userTotal, supervisorTotal] = await Promise.all([
      UserDoerReview.find({ doerId })
        .populate('userId', 'fullName avatarUrl')
        .sort({ createdAt: -1 })
        .lean(),
      SupervisorDoerReview.find({ doerId })
        .populate('supervisorId', 'fullName avatarUrl')
        .sort({ createdAt: -1 })
        .lean(),
      UserDoerReview.countDocuments({ doerId }),
      SupervisorDoerReview.countDocuments({ doerId }),
    ]);

    // Normalize and tag each review with its source
    const normalizedUserReviews = userReviews.map((r: any) => {
      const reviewer = r.userId && typeof r.userId === 'object' ? r.userId : null;
      return {
        id: r._id,
        doer_id: r.doerId,
        project_id: r.projectId,
        rating: r.rating,
        review: r.review,
        source: 'user',
        reviewer_name: reviewer?.fullName || null,
        reviewer_avatar: reviewer?.avatarUrl || null,
        created_at: r.createdAt,
      };
    });

    const normalizedSupervisorReviews = supervisorReviews.map((r: any) => {
      const reviewer = r.supervisorId && typeof r.supervisorId === 'object' ? r.supervisorId : null;
      return {
        id: r._id,
        doer_id: r.doerId,
        project_id: r.projectId,
        rating: r.rating,
        review: r.review,
        source: 'supervisor',
        reviewer_name: reviewer?.fullName || null,
        reviewer_avatar: reviewer?.avatarUrl || null,
        created_at: r.createdAt,
      };
    });

    // Combine, sort by date descending, then paginate
    const allReviews = [...normalizedUserReviews, ...normalizedSupervisorReviews]
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(skip, skip + Number(limit));

    const total = userTotal + supervisorTotal;

    res.json({ reviews: allReviews, total });
  } catch (err) {
    next(err);
  }
});

export default router;
