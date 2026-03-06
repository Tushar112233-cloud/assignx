import { Router, Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/roleGuard';
import {
  User, Project, Doer, Supervisor, UserWallet, DoerWallet, SupervisorWallet, WalletTransaction,
  SupportTicket, Notification, Banner, FAQ, LearningResource,
  TrainingModule, College, AppSetting, AuditLog, CommunityPost,
  AccessRequest,
} from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Helper: find wallet across all three wallet collections
async function findAnyWallet(id: string, session?: mongoose.ClientSession) {
  const opts = session ? { session } : {};
  const uw = await UserWallet.findOne({ userId: id }, null, opts);
  if (uw) return { wallet: uw, walletType: 'user' as const };
  const dw = await DoerWallet.findOne({ doerId: id }, null, opts);
  if (dw) return { wallet: dw, walletType: 'doer' as const };
  const sw = await SupervisorWallet.findOne({ supervisorId: id }, null, opts);
  if (sw) return { wallet: sw, walletType: 'supervisor' as const };
  return null;
}

// All admin routes require admin role
router.use(authenticate, requireRole('admin'));

// GET /admin/dashboard
router.get('/dashboard', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [totalUsers, totalProjects, totalDoers, totalSupervisors, activeProjects, openTickets] = await Promise.all([
      User.countDocuments(),
      Project.countDocuments(),
      Doer.countDocuments(),
      Supervisor.countDocuments(),
      Project.countDocuments({ status: { $nin: ['completed', 'cancelled', 'draft'] } }),
      SupportTicket.countDocuments({ status: { $in: ['open', 'in_progress'] } }),
    ]);

    // Revenue (sum of all completed project payments)
    const revenueAgg = await WalletTransaction.aggregate([
      { $match: { transactionType: { $in: ['project_payment', 'topup'] }, status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    res.json({
      stats: {
        totalUsers,
        totalProjects,
        totalDoers,
        totalSupervisors,
        activeProjects,
        openTickets,
        totalRevenue: revenueAgg[0]?.total || 0,
      },
    });
  } catch (err) {
    next(err);
  }
});

// GET /admin/users
router.get('/users', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', userType, search } = req.query;
    const filter: Record<string, unknown> = {};
    if (userType) filter.userType = userType;
    if (search) {
      filter.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    const [users, total] = await Promise.all([
      User.find(filter).select('-refreshTokens').sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      User.countDocuments(filter),
    ]);

    res.json({ users, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// GET /admin/projects
router.get('/projects', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', status, search } = req.query;
    const filter: Record<string, unknown> = {};
    if (status) filter.status = status;
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { projectNumber: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    const [projects, total] = await Promise.all([
      Project.find(filter)
        .populate('userId', 'fullName email')
        .populate('doerId', 'fullName email')
        .populate('supervisorId', 'fullName email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Project.countDocuments(filter),
    ]);

    res.json({ projects, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// GET /admin/financial-summary
router.get('/financial-summary', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [totalRevenue, totalPayouts, pendingPayouts] = await Promise.all([
      WalletTransaction.aggregate([
        { $match: { amount: { $gt: 0 }, status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$amount' } } },
      ]),
      WalletTransaction.aggregate([
        { $match: { transactionType: 'payout', status: 'completed' } },
        { $group: { _id: null, total: { $sum: { $abs: '$amount' } } } },
      ]),
      WalletTransaction.aggregate([
        { $match: { transactionType: 'payout', status: 'pending' } },
        { $group: { _id: null, total: { $sum: { $abs: '$amount' } } } },
      ]),
    ]);

    res.json({
      summary: {
        totalRevenue: totalRevenue[0]?.total || 0,
        totalPayouts: totalPayouts[0]?.total || 0,
        pendingPayouts: pendingPayouts[0]?.total || 0,
      },
    });
  } catch (err) {
    next(err);
  }
});

// GET /admin/transactions/:userId
router.get('/transactions/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '50' } = req.query;
    const result = await findAnyWallet(req.params.userId);
    if (!result) return res.json({ transactions: [], total: 0 });

    const { wallet } = result;
    const skip = (Number(page) - 1) * Number(limit);
    const [transactions, total] = await Promise.all([
      WalletTransaction.find({ walletId: wallet._id }).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      WalletTransaction.countDocuments({ walletId: wallet._id }),
    ]);

    res.json({ transactions, total, page: Number(page), wallet });
  } catch (err) {
    next(err);
  }
});

// POST /admin/refund
router.post('/refund', async (req: Request, res: Response, next: NextFunction) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const { userId, amount, reason, projectId, role } = req.body;
    if (!userId || !amount) throw new AppError('userId and amount required', 400);

    let result = await findAnyWallet(userId, session);
    if (!result) {
      // Create a wallet for this user. Use role hint from request body if provided.
      if (role === 'doer') {
        const created = await DoerWallet.create([{ doerId: userId }], { session });
        result = { wallet: created[0], walletType: 'doer' };
      } else if (role === 'supervisor') {
        const created = await SupervisorWallet.create([{ supervisorId: userId }], { session });
        result = { wallet: created[0], walletType: 'supervisor' };
      } else {
        const created = await UserWallet.create([{ userId: userId }], { session });
        result = { wallet: created[0], walletType: 'user' };
      }
    }

    const { wallet, walletType } = result;
    const balanceBefore = wallet.balance;
    wallet.balance += amount;
    wallet.totalCredited += amount;
    await wallet.save({ session });

    await WalletTransaction.create([{
      walletId: wallet._id,
      walletType,
      transactionType: 'refund',
      amount,
      status: 'completed',
      description: reason || 'Admin refund',
      referenceId: projectId,
      referenceType: 'project',
      balanceBefore,
      balanceAfter: wallet.balance,
    }], { session });

    await session.commitTransaction();
    res.json({ success: true, balance: wallet.balance });
  } catch (err) {
    await session.abortTransaction();
    next(err);
  } finally {
    session.endSession();
  }
});

// GET /admin/support/stats
router.get('/support/stats', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [open, inProgress, resolved, closed] = await Promise.all([
      SupportTicket.countDocuments({ status: 'open' }),
      SupportTicket.countDocuments({ status: 'in_progress' }),
      SupportTicket.countDocuments({ status: 'resolved' }),
      SupportTicket.countDocuments({ status: 'closed' }),
    ]);
    res.json({ stats: { open, inProgress, resolved, closed, total: open + inProgress + resolved + closed } });
  } catch (err) {
    next(err);
  }
});

// GET /admin/analytics/user-growth
router.get('/analytics/user-growth', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { months = '12' } = req.query;
    const startDate = new Date();
    startDate.setMonth(startDate.getMonth() - Number(months));

    const growth = await User.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: { year: { $year: '$createdAt' }, month: { $month: '$createdAt' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } },
    ]);

    res.json({ growth });
  } catch (err) {
    next(err);
  }
});

// GET /admin/analytics/revenue
router.get('/analytics/revenue', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { months = '12' } = req.query;
    const startDate = new Date();
    startDate.setMonth(startDate.getMonth() - Number(months));

    const revenue = await WalletTransaction.aggregate([
      { $match: { amount: { $gt: 0 }, status: 'completed', createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: { year: { $year: '$createdAt' }, month: { $month: '$createdAt' } },
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } },
    ]);

    res.json({ revenue });
  } catch (err) {
    next(err);
  }
});

// GET /admin/analytics/projects-by-status
router.get('/analytics/projects-by-status', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const byStatus = await Project.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);
    res.json({ byStatus });
  } catch (err) {
    next(err);
  }
});

// POST /admin/doers/:id/approve
router.post('/doers/:id/approve', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findByIdAndUpdate(req.params.id, { isAccessGranted: true, isActivated: true, activatedAt: new Date() }, { new: true });
    if (!doer) throw new AppError('Doer not found', 404);

    await Notification.create({
      recipientId: doer._id,
      recipientRole: 'doer',
      type: 'access_approved',
      title: 'Access Approved',
      message: 'Your doer application has been approved!',
    });

    res.json({ doer });
  } catch (err) {
    next(err);
  }
});

// POST /admin/doers/:id/reject
router.post('/doers/:id/reject', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findByIdAndUpdate(
      req.params.id,
      { isAccessGranted: false, flagReason: req.body.reason },
      { new: true }
    );
    if (!doer) throw new AppError('Doer not found', 404);
    res.json({ doer });
  } catch (err) {
    next(err);
  }
});

// POST /admin/supervisors/:id/approve
router.post('/supervisors/:id/approve', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findByIdAndUpdate(req.params.id, { isAccessGranted: true }, { new: true });
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    await Notification.create({
      recipientId: supervisor._id,
      recipientRole: 'supervisor',
      type: 'access_approved',
      title: 'Access Approved',
      message: 'Your supervisor application has been approved!',
    });

    res.json({ supervisor });
  } catch (err) {
    next(err);
  }
});

// POST /admin/supervisors/:id/reject
router.post('/supervisors/:id/reject', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findByIdAndUpdate(
      req.params.id,
      { isAccessGranted: false, flagReason: req.body.reason },
      { new: true }
    );
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    res.json({ supervisor });
  } catch (err) {
    next(err);
  }
});

// CRUD /admin/banners
router.get('/banners', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const banners = await Banner.find().sort({ order: 1 });
    res.json({ banners });
  } catch (err) { next(err); }
});

router.post('/banners', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const banner = await Banner.create(req.body);
    res.status(201).json({ banner });
  } catch (err) { next(err); }
});

router.put('/banners/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const banner = await Banner.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!banner) throw new AppError('Banner not found', 404);
    res.json({ banner });
  } catch (err) { next(err); }
});

router.delete('/banners/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await Banner.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// CRUD /admin/faqs
router.get('/faqs', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const faqs = await FAQ.find().sort({ order: 1 });
    res.json({ faqs });
  } catch (err) { next(err); }
});

router.post('/faqs', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const faq = await FAQ.create(req.body);
    res.status(201).json({ faq });
  } catch (err) { next(err); }
});

router.put('/faqs/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const faq = await FAQ.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!faq) throw new AppError('FAQ not found', 404);
    res.json({ faq });
  } catch (err) { next(err); }
});

router.delete('/faqs/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await FAQ.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// CRUD /admin/learning-resources
router.get('/learning-resources', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const resources = await LearningResource.find().sort({ order: 1 });
    res.json({ resources });
  } catch (err) { next(err); }
});

router.post('/learning-resources', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const resource = await LearningResource.create(req.body);
    res.status(201).json({ resource });
  } catch (err) { next(err); }
});

router.put('/learning-resources/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const resource = await LearningResource.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!resource) throw new AppError('Resource not found', 404);
    res.json({ resource });
  } catch (err) { next(err); }
});

router.delete('/learning-resources/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await LearningResource.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// CRUD /admin/training-modules
router.get('/training-modules', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const modules = await TrainingModule.find().sort({ order: 1 });
    res.json({ modules });
  } catch (err) { next(err); }
});

router.post('/training-modules', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const module = await TrainingModule.create(req.body);
    res.status(201).json({ module });
  } catch (err) { next(err); }
});

router.put('/training-modules/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const module = await TrainingModule.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!module) throw new AppError('Module not found', 404);
    res.json({ module });
  } catch (err) { next(err); }
});

router.delete('/training-modules/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await TrainingModule.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// CRUD /admin/colleges
router.get('/colleges', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const colleges = await College.find().populate('universityId', 'name').sort({ name: 1 });
    res.json({ colleges });
  } catch (err) { next(err); }
});

router.post('/colleges', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const college = await College.create(req.body);
    res.status(201).json({ college });
  } catch (err) { next(err); }
});

router.put('/colleges/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const college = await College.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!college) throw new AppError('College not found', 404);
    res.json({ college });
  } catch (err) { next(err); }
});

router.delete('/colleges/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await College.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// CRUD /admin/settings
router.get('/settings', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const settings = await AppSetting.find();
    res.json({ settings });
  } catch (err) { next(err); }
});

router.post('/settings', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const setting = await AppSetting.findOneAndUpdate(
      { key: req.body.key },
      req.body,
      { upsert: true, new: true }
    );
    res.json({ setting });
  } catch (err) { next(err); }
});

router.put('/settings/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const setting = await AppSetting.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!setting) throw new AppError('Setting not found', 404);
    res.json({ setting });
  } catch (err) { next(err); }
});

router.delete('/settings/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await AppSetting.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// POST /admin/moderation/flag-user
router.post('/moderation/flag-user', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id, role, reason } = req.body;
    if (!id || !role) throw new AppError('id and role are required', 400);

    if (role === 'doer') {
      const doer = await Doer.findByIdAndUpdate(id, { isFlagged: true, flagReason: reason });
      if (!doer) throw new AppError('Doer not found', 404);
    } else if (role === 'supervisor') {
      const supervisor = await Supervisor.findByIdAndUpdate(id, { isFlagged: true, flagReason: reason });
      if (!supervisor) throw new AppError('Supervisor not found', 404);
    } else {
      throw new AppError('Invalid role for flagging', 400);
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// POST /admin/moderation/unflag-user
router.post('/moderation/unflag-user', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id, role } = req.body;
    if (!id || !role) throw new AppError('id and role are required', 400);

    if (role === 'doer') {
      const doer = await Doer.findByIdAndUpdate(id, { isFlagged: false, flagReason: '' });
      if (!doer) throw new AppError('Doer not found', 404);
    } else if (role === 'supervisor') {
      const supervisor = await Supervisor.findByIdAndUpdate(id, { isFlagged: false, flagReason: '' });
      if (!supervisor) throw new AppError('Supervisor not found', 404);
    } else {
      throw new AppError('Invalid role for unflagging', 400);
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /admin/analytics/overview
router.get('/analytics/overview', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [totalUsers, newUsers, totalProjects, completedProjects, activeProjects, openTickets, inProgressTickets, totalDoers, pendingDoerApprovals] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } }),
      Project.countDocuments(),
      Project.countDocuments({ status: 'completed' }),
      Project.countDocuments({ status: { $nin: ['completed', 'cancelled', 'draft'] } }),
      SupportTicket.countDocuments({ status: 'open' }),
      SupportTicket.countDocuments({ status: 'in_progress' }),
      Doer.countDocuments({ isActivated: true }),
      Doer.countDocuments({ isAccessGranted: false }),
    ]);

    const revenueAgg = await WalletTransaction.aggregate([
      { $match: { amount: { $gt: 0 }, status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    const userTypeDist = await User.aggregate([
      { $group: { _id: '$userType', count: { $sum: 1 } } },
    ]);
    const userTypeDistribution: Record<string, number> = {};
    for (const u of userTypeDist) {
      userTypeDistribution[u._id || 'unknown'] = u.count;
    }

    const topSubjects = await Project.aggregate([
      { $group: { _id: '$subject', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 10 },
    ]);

    const projectStatusBreakdown: Record<string, number> = {};
    const statusAgg = await Project.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]);
    for (const s of statusAgg) {
      projectStatusBreakdown[s._id || 'unknown'] = s.count;
    }

    res.json({
      totalUsers,
      newUsers,
      totalProjects,
      completedProjects,
      completionRate: totalProjects > 0 ? ((completedProjects / totalProjects) * 100).toFixed(1) : '0',
      totalRevenue: revenueAgg[0]?.total || 0,
      userTypeDistribution,
      topSubjects: topSubjects.map(s => ({ subject: s._id, count: s.count })),
      pendingDoerApprovals,
      activeDoers: totalDoers,
      openSupportTickets: openTickets,
      inProgressTickets,
      activeProjects,
      projectStatusBreakdown,
    });
  } catch (err) {
    next(err);
  }
});

// GET /admin/crm/dashboard
router.get('/crm/dashboard', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [totalCustomers, newThisMonth] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } }),
    ]);

    const activeThisMonth = await Project.distinct('userId', {
      createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
    }).then(ids => ids.length);

    const pipeline: Record<string, { count: number; value: number }> = {};
    for (const status of ['quoted', 'paid', 'in_progress', 'completed']) {
      const agg = await Project.aggregate([
        { $match: { status } },
        { $group: { _id: null, count: { $sum: 1 }, value: { $sum: '$budget' } } },
      ]);
      pipeline[status] = { count: agg[0]?.count || 0, value: agg[0]?.value || 0 };
    }

    const segmentAgg = await User.aggregate([
      { $group: { _id: '$userSubType', count: { $sum: 1 } } },
    ]);
    const segments: Record<string, number> = {};
    for (const s of segmentAgg) {
      segments[s._id || 'general'] = s.count;
    }

    const topCustomers = await Project.aggregate([
      { $group: { _id: '$userId', projectCount: { $sum: 1 }, totalSpend: { $sum: '$budget' } } },
      { $sort: { totalSpend: -1 } },
      { $limit: 10 },
      { $lookup: { from: 'users', localField: '_id', foreignField: '_id', as: 'user' } },
      { $unwind: { path: '$user', preserveNullAndEmptyArrays: true } },
      { $project: { _id: 1, projectCount: 1, totalSpend: 1, fullName: '$user.fullName', email: '$user.email' } },
    ]);

    res.json({
      totalCustomers,
      activeThisMonth,
      newThisMonth,
      churnRate: 0,
      pipeline,
      segments,
      topCustomers,
    });
  } catch (err) {
    next(err);
  }
});

// GET /admin/crm/segments
router.get('/crm/segments', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    res.json({
      highValue: { count: 0, users: [] },
      atRisk: { count: 0, users: [] },
      newUsers: { count: 0, users: [] },
      repeat: { count: 0, users: [] },
    });
  } catch (err) { next(err); }
});

// GET /admin/crm/communications
router.get('/crm/communications', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    res.json({ data: [], total: 0, page: 1, totalPages: 1 });
  } catch (err) { next(err); }
});

// GET /admin/crm/content-overview
router.get('/crm/content-overview', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [bannerCount, faqCount, learningCount] = await Promise.all([
      Banner.countDocuments(),
      FAQ.countDocuments(),
      LearningResource.countDocuments(),
    ]);
    const cpCount = await CommunityPost.countDocuments().catch(() => 0);

    res.json({
      banners: { data: [], total: bannerCount },
      faqs: { data: [], total: faqCount },
      listings: { data: [], total: 0 },
      campusPosts: { data: [], total: cpCount },
      learningResources: { data: [], total: learningCount },
    });
  } catch (err) { next(err); }
});

// GET /admin/crm/customers/:id
router.get('/crm/customers/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) throw new AppError('Customer not found', 404);

    const projects = await Project.find({ userId: req.params.id }).sort({ createdAt: -1 }).limit(20);
    const result = await findAnyWallet(req.params.id);
    const wallet = result?.wallet || null;

    res.json({ profile: user, projects, wallet, notes: [] });
  } catch (err) { next(err); }
});

// POST /admin/crm/customers/:id/notes
router.post('/crm/customers/:id/notes', async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.json({ success: true, note: { text: req.body.note, createdAt: new Date() } });
  } catch (err) { next(err); }
});

// GET /admin/crm/customers/:id/notes
router.get('/crm/customers/:id/notes', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    res.json([]);
  } catch (err) { next(err); }
});

// POST /admin/crm/announcements
router.post('/crm/announcements', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, body, targetSegment, targetRole } = req.body;
    let sentCount = 0;

    if (!targetRole || targetRole === 'user' || targetRole === 'all') {
      const users = await User.find().select('_id');
      for (const u of users) {
        await Notification.create({
          recipientId: u._id,
          recipientRole: 'user',
          type: 'announcement',
          title,
          message: body,
        });
      }
      sentCount += users.length;
    }

    if (targetRole === 'doer' || targetRole === 'all') {
      const doers = await Doer.find().select('_id');
      for (const d of doers) {
        await Notification.create({
          recipientId: d._id,
          recipientRole: 'doer',
          type: 'announcement',
          title,
          message: body,
        });
      }
      sentCount += doers.length;
    }

    if (targetRole === 'supervisor' || targetRole === 'all') {
      const supervisors = await Supervisor.find().select('_id');
      for (const s of supervisors) {
        await Notification.create({
          recipientId: s._id,
          recipientRole: 'supervisor',
          type: 'announcement',
          title,
          message: body,
        });
      }
      sentCount += supervisors.length;
    }

    res.json({ success: true, sent: sentCount });
  } catch (err) { next(err); }
});

// PUT /admin/crm/content-status
router.put('/crm/content-status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { table, id, active } = req.body;
    if (table === 'banners') await Banner.findByIdAndUpdate(id, { isActive: active });
    else if (table === 'faqs') await FAQ.findByIdAndUpdate(id, { isActive: active });
    else if (table === 'learning_resources') await LearningResource.findByIdAndUpdate(id, { isActive: active });
    res.json({ success: true });
  } catch (err) { next(err); }
});

// POST /admin/crm/moderate-post
router.post('/crm/moderate-post', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { postId, action } = req.body;
    const update: Record<string, unknown> = {};
    if (action === 'hide') update.isHidden = true;
    else if (action === 'unhide') update.isHidden = false;
    else if (action === 'flag') update.isFlagged = true;
    else if (action === 'unflag') update.isFlagged = false;
    await CommunityPost.findByIdAndUpdate(postId, update);
    res.json({ success: true });
  } catch (err) { next(err); }
});

// GET /admin/access-requests
router.get('/access-requests', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', status, role, search } = req.query;
    const filter: Record<string, unknown> = {};
    if (status) filter.status = status;
    if (role) filter.role = role;
    if (search) {
      filter.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    const [requests, total] = await Promise.all([
      AccessRequest.find(filter).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      AccessRequest.countDocuments(filter),
    ]);

    res.json({ requests, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// POST /admin/access-requests/:id/approve
router.post('/access-requests/:id/approve', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const request = await AccessRequest.findByIdAndUpdate(
      req.params.id,
      { status: 'approved', reviewedAt: new Date(), reviewedBy: req.user!.id },
      { new: true }
    );
    if (!request) throw new AppError('Access request not found', 404);

    // Create Doer or Supervisor directly (they own auth fields now, no separate Profile)
    if (request.role === 'doer') {
      const existingDoer = await Doer.findOne({ email: request.email });
      if (existingDoer) {
        // Activate existing doer created during registration
        existingDoer.isActivated = true;
        existingDoer.isAccessGranted = true;
        existingDoer.activatedAt = new Date();
        await existingDoer.save();
      } else {
        const meta = request.metadata || {};
        const doer = await Doer.create({
          email: request.email,
          fullName: request.fullName,
          isAccessGranted: true,
          isActivated: true,
          activatedAt: new Date(),
          qualification: meta.qualification,
          experienceLevel: meta.experienceLevel,
          bio: meta.bio || '',
          bankDetails: {
            bankName: meta.bankName || '',
            accountNumber: meta.accountNumber || '',
            ifscCode: meta.ifscCode || '',
            upiId: meta.upiId || '',
          },
        });

        await Notification.create({
          recipientId: doer._id,
          recipientRole: 'doer',
          type: 'access_approved',
          title: 'Application Approved',
          message: `Your doer application has been approved!`,
        });
      }
    }

    if (request.role === 'supervisor') {
      const existingSupervisor = await Supervisor.findOne({ email: request.email });
      if (existingSupervisor) {
        // Activate existing supervisor created during registration
        existingSupervisor.isActivated = true;
        existingSupervisor.isAccessGranted = true;
        existingSupervisor.isApproved = true;
        existingSupervisor.activatedAt = new Date();
        await existingSupervisor.save();
      } else {
        const meta = request.metadata || {};
        const supervisor = await Supervisor.create({
          email: request.email,
          fullName: request.fullName,
          isAccessGranted: true,
          isApproved: true,
          isActivated: true,
          activatedAt: new Date(),
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

        await Notification.create({
          recipientId: supervisor._id,
          recipientRole: 'supervisor',
          type: 'access_approved',
          title: 'Application Approved',
          message: `Your supervisor application has been approved!`,
        });
      }
    }

    res.json({ request });
  } catch (err) {
    next(err);
  }
});

// POST /admin/access-requests/:id/reject
router.post('/access-requests/:id/reject', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const request = await AccessRequest.findByIdAndUpdate(
      req.params.id,
      { status: 'rejected', reviewedAt: new Date(), reviewedBy: req.user!.id },
      { new: true }
    );
    if (!request) throw new AppError('Access request not found', 404);
    res.json({ request });
  } catch (err) {
    next(err);
  }
});

// GET /admin/audit-logs
router.get('/audit-logs', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '50' } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const [logs, total] = await Promise.all([
      AuditLog.find().sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      AuditLog.countDocuments(),
    ]);

    res.json({ logs, total, page: Number(page) });
  } catch (err) {
    next(err);
  }
});

export default router;
