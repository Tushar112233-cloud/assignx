import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/roleGuard';
import { Supervisor, SupervisorActivation, User, Project, Doer, UserDoerReview, SupervisorDoerReview, SupervisorWallet, WalletTransaction, SupportTicket, Subject, Notification, TrainingModule, ChatRoom } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

/** Auto-add a user to the project's chat room (upsert + join) */
async function autoJoinProjectChat(projectId: string, userId: string, role: string) {
  const chatRoom = await ChatRoom.findOneAndUpdate(
    { projectId, roomType: 'project_all' },
    { $setOnInsert: { projectId, roomType: 'project_all', name: 'Project Chat', participants: [] } },
    { upsert: true, new: true }
  );
  const isInRoom = chatRoom.participants.some((p: any) => p.id.toString() === userId);
  if (!isInRoom) {
    await ChatRoom.updateOne(
      { _id: chatRoom._id },
      { $push: { participants: { id: userId, role, joinedAt: new Date(), isActive: true } } }
    );
  }
}

// GET /supervisors/me - Get current supervisor's data
router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const obj = supervisor.toObject();
    res.json({
      ...obj,
      id: obj._id,
      // Flat snake_case bank fields expected by frontend types
      bank_name: obj.bankDetails?.bankName || null,
      bank_account_number: obj.bankDetails?.accountNumber || null,
      bank_account_name: obj.bankDetails?.accountName || null,
      bank_ifsc_code: obj.bankDetails?.ifscCode || null,
      upi_id: obj.bankDetails?.upiId || null,
      bank_verified: obj.bankDetails?.verified || false,
      // Flat snake_case supervisor fields
      years_of_experience: obj.yearsOfExperience ?? 0,
      is_available: obj.isAvailable ?? true,
      is_activated: obj.isActivated ?? false,
      is_access_granted: obj.isAccessGranted ?? false,
      average_rating: obj.averageRating ?? 0,
      total_reviews: obj.totalReviews ?? 0,
      total_earnings: obj.totalEarnings ?? 0,
    });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/me/activation - Get current supervisor's activation status
router.get('/me/activation', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) {
      return res.json({ activation: null });
    }

    const activation = await SupervisorActivation.findOne({ supervisorId: supervisor._id });
    res.json(activation || { trainingCompleted: false, quizPassed: false, isActivated: supervisor.isActivated || false });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisors/me/activation - Update activation fields (e.g. mark training complete)
router.put('/me/activation', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const allowedFields = ['trainingCompleted', 'quizPassed'];
    const updates: Record<string, unknown> = {};
    for (const key of allowedFields) {
      if (req.body[key] !== undefined) {
        updates[key] = req.body[key];
      }
    }

    const activation = await SupervisorActivation.findOneAndUpdate(
      { supervisorId: supervisor._id },
      { $set: updates },
      { new: true, upsert: true }
    );

    res.json(activation);
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/me/stats - Stats for supervisor dashboard hooks
router.get('/me/stats', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const [totalProjects, activeProjects, completedProjects, pendingQuotes, wallet, doerCount] = await Promise.all([
      Project.countDocuments({ supervisorId: req.user!.id }),
      Project.countDocuments({ supervisorId: req.user!.id, status: { $in: ['assigned', 'in_progress', 'under_review'] } }),
      Project.countDocuments({ supervisorId: req.user!.id, status: 'completed' }),
      Project.countDocuments({ supervisorId: req.user!.id, status: { $in: ['submitted', 'analyzing'] } }),
      SupervisorWallet.findOne({ supervisorId: req.user!.id }),
      Doer.countDocuments({ isActivated: true }),
    ]);

    res.json({
      totalProjects,
      activeProjects,
      completedProjects,
      pendingQuotes,
      totalEarnings: supervisor.totalEarnings || 0,
      pendingEarnings: wallet?.balance || 0,
      averageRating: supervisor.averageRating || 0,
      totalDoers: doerCount,
    });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/me/dashboard - Dashboard stats for supervisor
router.get('/me/dashboard', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const [activeProjects, totalProjects, doerCount] = await Promise.all([
      Project.countDocuments({ supervisorId: req.user!.id, status: { $in: ['assigned', 'in_progress', 'under_review'] } }),
      Project.countDocuments({ supervisorId: req.user!.id }),
      Doer.countDocuments({ isActivated: true }),
    ]);

    res.json({
      activeProjects,
      totalProjects,
      availableDoers: doerCount,
      totalEarnings: supervisor.totalEarnings || 0,
      averageRating: supervisor.averageRating || 0,
      totalReviews: supervisor.totalReviews || 0,
    });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/me/users - Get clients associated with supervisor's projects
router.get('/me/users', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '200', offset = '0' } = req.query;
    // Find all unique user IDs from supervisor's projects
    const projects = await Project.find({ supervisorId: req.user!.id }).select('userId pricing status createdAt');
    const userIdMap = new Map<string, { projectCount: number; totalSpent: number; lastProjectAt: Date | null }>();
    for (const p of projects) {
      const uid = p.userId?.toString();
      if (!uid) continue;
      const existing = userIdMap.get(uid) || { projectCount: 0, totalSpent: 0, lastProjectAt: null };
      existing.projectCount++;
      existing.totalSpent += (p as any).pricing?.userQuote || 0;
      if (!existing.lastProjectAt || p.createdAt > existing.lastProjectAt) {
        existing.lastProjectAt = p.createdAt;
      }
      userIdMap.set(uid, existing);
    }

    const userIds = Array.from(userIdMap.keys());
    const users_docs = await User.find({ _id: { $in: userIds } }).select('fullName email avatarUrl phone createdAt');

    const users = users_docs.map(p => {
      const stats = userIdMap.get(p._id.toString()) || { projectCount: 0, totalSpent: 0, lastProjectAt: null };
      return {
        id: p._id,
        full_name: p.fullName,
        email: p.email,
        avatar_url: p.avatarUrl,
        phone: p.phone,
        created_at: p.createdAt,
        project_count: stats.projectCount,
        total_spent: stats.totalSpent,
        last_project_at: stats.lastProjectAt,
      };
    });

    res.json({ users, total: users.length });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/me/blacklist - Get supervisor's blacklisted doers
router.get('/me/blacklist', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    // Return blacklisted doer IDs from supervisor document (or empty array)
    const blacklist = (supervisor as any).blacklistedDoers || [];
    res.json({ doers: blacklist });
  } catch (err) {
    next(err);
  }
});

// POST /supervisors/me/blacklist - Add doer to blacklist
router.post('/me/blacklist', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { doerId, reason } = req.body;
    if (!doerId) throw new AppError('Doer ID is required', 400);
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    // Add to blacklist array (create if doesn't exist)
    const blacklist = (supervisor as any).blacklistedDoers || [];
    if (!blacklist.some((d: any) => d.id === doerId)) {
      blacklist.push({ id: doerId, reason, addedAt: new Date() });
      (supervisor as any).blacklistedDoers = blacklist;
      await supervisor.save();
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// DELETE /supervisors/me/blacklist/:doerId - Remove doer from blacklist
router.delete('/me/blacklist/:doerId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    const blacklist = (supervisor as any).blacklistedDoers || [];
    (supervisor as any).blacklistedDoers = blacklist.filter((d: any) => d.id !== req.params.doerId);
    await supervisor.save();
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/me/expertise - Get supervisor expertise/subjects
router.get('/me/expertise', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) return res.json({ expertise: [], subjects: [] });

    const subjects: any[] = [];

    res.json({
      expertise: supervisor.expertise || [],
      subjects,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisors/me/subjects - Update supervisor subjects
router.put('/me/subjects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { subjects } = req.body as { subjects: { subjectId: string; isPrimary: boolean }[] };
    if (!Array.isArray(subjects)) throw new AppError('subjects must be an array', 400);

    // Validate all subjectIds exist
    const subjectIds = subjects.map(s => s.subjectId);
    const validSubjects = await Subject.find({ _id: { $in: subjectIds }, isActive: true });
    if (validSubjects.length !== subjectIds.length) {
      throw new AppError('One or more subject IDs are invalid', 400);
    }

    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    supervisor.subjects = subjects.map(s => ({
      subjectId: s.subjectId as any,
      isPrimary: s.isPrimary ?? false,
    }));

    // Also update legacy expertise strings
    supervisor.expertise = validSubjects.map(s => s.name);

    await supervisor.save();

    // Return populated subjects
    await supervisor.populate('subjects.subjectId', 'name category');
    const populated = (supervisor.subjects || []).map(s => ({
      id: (s.subjectId as any)?._id || s.subjectId,
      name: (s.subjectId as any)?.name || '',
      category: (s.subjectId as any)?.category || '',
      isPrimary: s.isPrimary,
    }));

    res.json({ subjects: populated, expertise: supervisor.expertise });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/:userId/activation-status - Check if a supervisor is activated
router.get('/:userId/activation-status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // userId IS the supervisor _id now
    const supervisor = await Supervisor.findById(req.params.userId);
    if (!supervisor) {
      return res.json({ isActivated: false, is_activated: false });
    }
    const activated = supervisor.isActivated === true;
    res.json({ isActivated: activated, is_activated: activated });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors
router.get('/', authenticate, requireRole('admin'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20' } = req.query;
    const skip = (Number(page) - 1) * Number(limit);
    const [supervisors, total] = await Promise.all([
      Supervisor.find().skip(skip).limit(Number(limit)).sort({ createdAt: -1 }),
      Supervisor.countDocuments(),
    ]);
    res.json({ supervisors, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// NOTE: /:id routes moved to end of file to avoid catching named routes like /profile, /projects, etc.

// =====================================================================
// SUPERVISOR-PREFIXED ROUTES (for mobile app compatibility)
// The supervisor mobile app calls /supervisor/projects, /supervisor/doers, etc.
// =====================================================================

// ---------- PROFILE (alias for /me) ----------

// GET /supervisor/profile - Get supervisor profile
router.get('/profile', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const obj = supervisor.toObject();

    res.json({
      ...obj,
      id: obj._id,
      userId: req.user!.id,
      fullName: obj.fullName || null,
      full_name: obj.fullName || null,
      email: obj.email || null,
      avatarUrl: obj.avatarUrl || null,
      avatar_url: obj.avatarUrl || null,
      phone: obj.phone || null,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisor/profile - Update supervisor profile
router.put('/profile', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findByIdAndUpdate(
      req.user!.id,
      req.body,
      { new: true }
    );
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const obj = supervisor.toObject();

    res.json({
      ...obj,
      id: obj._id,
      userId: req.user!.id,
      fullName: obj.fullName || null,
      email: obj.email || null,
      avatarUrl: obj.avatarUrl || null,
      phone: obj.phone || null,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisor/profile/availability
router.put('/profile/availability', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findByIdAndUpdate(
      req.user!.id,
      { isAvailable: req.body.is_available ?? req.body.isAvailable },
      { new: true }
    );
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    res.json({ success: true, isAvailable: supervisor.isAvailable });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/profile/availability
router.get('/profile/availability', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    res.json({ isAvailable: supervisor?.isAvailable ?? true, is_available: supervisor?.isAvailable ?? true });
  } catch (err) {
    next(err);
  }
});

// ---------- PROJECTS ----------

// GET /supervisor/projects - Get projects for current supervisor
router.get('/projects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status, statuses, sort, order, limit = '50', page = '1', search, view } = req.query;
    const filter: Record<string, unknown> = {};

    // Build base filter based on view mode
    if (view === 'pool') {
      // Unassigned projects matching supervisor's subjects
      const supervisor = await Supervisor.findById(req.user!.id);
      const subjectIds = (supervisor?.subjects || []).map(s => s.subjectId);
      filter.supervisorId = null;
      filter.subjectId = { $in: subjectIds };
      filter.status = { $in: ['submitted', 'analyzing', 'quoted', 'paid'] };
    } else if (view === 'all') {
      // Both assigned + matching pool
      const supervisor = await Supervisor.findById(req.user!.id);
      const subjectIds = (supervisor?.subjects || []).map(s => s.subjectId);
      filter.$or = [
        { supervisorId: req.user!.id },
        { supervisorId: null, subjectId: { $in: subjectIds }, status: { $in: ['submitted', 'analyzing', 'quoted', 'paid'] } },
      ];
    } else {
      // Default: assigned projects only
      filter.supervisorId = req.user!.id;
    }

    // Additional status filter (only for non-pool views where status isn't already set)
    if (view !== 'pool') {
      if (status) {
        filter.status = status;
      } else if (statuses) {
        filter.status = { $in: (statuses as string).split(',') };
      }
    }

    if (search) {
      const searchFilter = [
        { title: { $regex: search, $options: 'i' } },
        { topic: { $regex: search, $options: 'i' } },
      ];
      // If $or already exists (from 'all' view), wrap in $and
      if (filter.$or) {
        filter.$and = [{ $or: filter.$or as any[] }, { $or: searchFilter }];
        delete filter.$or;
      } else {
        filter.$or = searchFilter;
      }
    }

    const skip = (Number(page) - 1) * Number(limit);
    let sortObj: Record<string, 1 | -1> = { createdAt: -1 };
    if (sort === 'deadline') sortObj = { originalDeadline: order === 'asc' ? 1 : -1 };
    else if (sort === 'delivered_at') sortObj = { 'delivery.deliveredAt': order === 'asc' ? 1 : -1 };
    else if (sort === 'completed_at') sortObj = { 'delivery.completedAt': order === 'asc' ? 1 : -1 };

    const [projects, total] = await Promise.all([
      Project.find(filter)
        .populate('userId', 'fullName email avatarUrl phone')
        .populate('doerId', 'fullName email avatarUrl')
        .populate('subjectId', 'name')
        .skip(skip)
        .limit(Number(limit))
        .sort(sortObj),
      Project.countDocuments(filter),
    ]);

    const normalizedProjects = projects.map((p) => {
      const obj = p.toObject();
      const user = obj.userId && typeof obj.userId === 'object' ? obj.userId as any : null;
      const doer = obj.doerId && typeof obj.doerId === 'object' ? obj.doerId as any : null;
      const subject = obj.subjectId && typeof obj.subjectId === 'object' ? obj.subjectId as any : null;
      return {
        ...obj,
        id: obj._id,
        projectNumber: obj.projectNumber,
        project_number: obj.projectNumber,
        user_id: user?._id || obj.userId,
        doer_id: doer?._id || obj.doerId,
        supervisor_id: obj.supervisorId,
        clientName: user?.fullName || null,
        clientEmail: user?.email || null,
        doerName: doer?.fullName || null,
        subject: subject?.name || null,
        userQuote: obj.pricing?.userQuote || 0,
        user_quote: obj.pricing?.userQuote || 0,
        doerAmount: obj.pricing?.doerPayout || 0,
        supervisorAmount: obj.pricing?.supervisorCommission || 0,
        service_type: obj.serviceType,
        word_count: obj.wordCount,
        page_count: obj.pageCount,
        progress_percentage: obj.progressPercentage,
        created_at: obj.createdAt,
        updated_at: obj.updatedAt,
        delivered_at: obj.delivery?.deliveredAt,
        completed_at: obj.delivery?.completedAt,
      };
    });

    res.json({ projects: normalizedProjects, total, page: Number(page) });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/projects/:id - Get single project
router.get('/projects/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id)
      .populate('userId', 'fullName email avatarUrl phone')
      .populate('doerId', 'fullName email avatarUrl')
      .populate('supervisorId', 'fullName email avatarUrl')
      .populate('subjectId', 'name')
      .populate('referenceStyleId', 'name');

    if (!project) throw new AppError('Project not found', 404);

    const obj = project.toObject();
    const user = obj.userId && typeof obj.userId === 'object' ? obj.userId as any : null;
    const doer = obj.doerId && typeof obj.doerId === 'object' ? obj.doerId as any : null;
    const subject = obj.subjectId && typeof obj.subjectId === 'object' ? obj.subjectId as any : null;

    res.json({
      ...obj,
      id: obj._id,
      projectNumber: obj.projectNumber,
      project_number: obj.projectNumber,
      user_id: user?._id || obj.userId,
      doer_id: doer?._id || obj.doerId,
      supervisor_id: obj.supervisorId,
      clientName: user?.fullName || null,
      clientEmail: user?.email || null,
      clientPhone: user?.phone || null,
      doerName: doer?.fullName || null,
      subject: subject?.name || null,
      userQuote: obj.pricing?.userQuote || 0,
      doerAmount: obj.pricing?.doerPayout || 0,
      supervisorAmount: obj.pricing?.supervisorCommission || 0,
      platformAmount: obj.pricing?.platformFee || 0,
      service_type: obj.serviceType,
      word_count: obj.wordCount,
      page_count: obj.pageCount,
      progress_percentage: obj.progressPercentage,
      specific_instructions: obj.specificInstructions,
      live_document_url: obj.liveDocumentUrl,
      created_at: obj.createdAt,
      updated_at: obj.updatedAt,
      delivered_at: obj.delivery?.deliveredAt,
      completed_at: obj.delivery?.completedAt,
      deliverables: (obj.deliverables || []).map((d: any) => ({
        ...d,
        id: d._id,
        file_name: d.fileName,
        file_url: d.fileUrl,
        file_type: d.fileType,
        file_size_bytes: d.fileSizeBytes,
        qc_status: d.qcStatus,
        created_at: d.createdAt,
      })),
    });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisor/projects/:id/status
router.put('/projects/:id/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status, notes } = req.body;
    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    const oldStatus = project.status;
    project.status = status;
    project.statusUpdatedAt = new Date();
    project.statusHistory.push({
      fromStatus: oldStatus,
      toStatus: status,
      changedBy: req.user!.id as any,
      notes: notes || '',
      createdAt: new Date(),
    });
    await project.save();

    res.json({ project, success: true });
  } catch (err) {
    next(err);
  }
});

// POST /supervisor/projects/:id/quote
router.post('/projects/:id/quote', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { user_amount, doer_amount, supervisor_amount, platform_amount, base_price, urgency_fee, complexity_fee } = req.body;
    const project = await Project.findByIdAndUpdate(
      req.params.id,
      {
        'pricing.userQuote': user_amount || base_price,
        'pricing.doerPayout': doer_amount || 0,
        'pricing.supervisorCommission': supervisor_amount || 0,
        'pricing.platformFee': platform_amount || 0,
        'pricing.urgencyFee': urgency_fee || 0,
        'pricing.complexityFee': complexity_fee || 0,
        status: 'quoted',
        statusUpdatedAt: new Date(),
      },
      { new: true }
    );
    if (!project) throw new AppError('Project not found', 404);

    // Notify project owner about the quote
    const quoteAmount = user_amount || base_price;
    if (project.userId) {
      const notification = await Notification.create({
        recipientId: project.userId,
        recipientRole: 'user',
        type: 'project_quoted',
        title: 'Quote Ready',
        message: `Your project "${project.title}" has been quoted at R${quoteAmount}`,
        data: { projectId: project._id },
      });
      const io = req.app.get('io');
      if (io) io.to(`user:${project.userId}`).emit('notification:new', notification);
    }

    res.json({ success: true, project });
  } catch (err) {
    next(err);
  }
});

// POST /supervisor/projects/:id/assign-doer
router.post('/projects/:id/assign-doer', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { doer_id } = req.body;
    const project = await Project.findByIdAndUpdate(
      req.params.id,
      { doerId: doer_id, status: 'assigned', statusUpdatedAt: new Date(), doerAssignedAt: new Date() },
      { new: true }
    );
    if (!project) throw new AppError('Project not found', 404);

    const io = req.app.get('io');

    // Notify the doer they've been assigned
    if (doer_id) {
      const doerNotification = await Notification.create({
        recipientId: doer_id,
        recipientRole: 'doer',
        type: 'project_assigned',
        title: 'New Project Assigned',
        message: `You have been assigned to project "${project.title}"`,
        data: { projectId: project._id },
      });
      if (io) io.to(`user:${doer_id}`).emit('notification:new', doerNotification);
    }

    // Notify the project owner
    if (project.userId) {
      const ownerNotification = await Notification.create({
        recipientId: project.userId,
        recipientRole: 'user',
        type: 'doer_assigned',
        title: 'Writer Assigned',
        message: `A writer has been assigned to your project "${project.title}"`,
        data: { projectId: project._id },
      });
      if (io) io.to(`user:${project.userId}`).emit('notification:new', ownerNotification);
    }

    // Auto-add doer to project chat room
    if (doer_id) await autoJoinProjectChat(req.params.id as string, doer_id, 'doer');

    res.json({ success: true, project });
  } catch (err) {
    next(err);
  }
});

// POST /supervisor/projects/:id/revisions
router.post('/projects/:id/revisions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    const revisionNumber = project.revisions.length + 1;
    project.revisions.push({
      requestedBy: req.user!.id as any,
      requestedByType: 'supervisor',
      revisionNumber,
      feedback: req.body.feedback || '',
      specificChanges: req.body.specific_changes || req.body.specificChanges || '',
      responseNotes: '',
      status: 'pending',
      createdAt: new Date(),
      completedAt: undefined as any,
    });
    project.status = 'revision_requested';
    project.statusUpdatedAt = new Date();
    await project.save();

    // Notify the doer about revision request
    if (project.doerId) {
      const notification = await Notification.create({
        recipientId: project.doerId,
        recipientRole: 'doer',
        type: 'revision_requested',
        title: 'Revision Requested',
        message: `A revision has been requested for project "${project.title}"`,
        data: { projectId: project._id },
      });
      const io = req.app.get('io');
      if (io) io.to(`user:${project.doerId}`).emit('notification:new', notification);
    }

    res.json({ success: true, project });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/projects/:id/deliverables
router.get('/projects/:id/deliverables', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id).select('deliverables');
    if (!project) throw new AppError('Project not found', 404);

    const deliverables = (project.deliverables || []).map((d: any) => ({
      ...d.toObject ? d.toObject() : d,
      id: d._id,
      file_name: d.fileName,
      file_url: d.fileUrl,
      file_type: d.fileType,
      file_size_bytes: d.fileSizeBytes,
      qc_status: d.qcStatus,
      created_at: d.createdAt,
    }));

    res.json({ deliverables });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisor/projects/:id/deliverables/:deliverableId/approve
router.put('/projects/:id/deliverables/:deliverableId/approve', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    const deliverable = (project.deliverables as any).id(req.params.deliverableId);
    if (!deliverable) throw new AppError('Deliverable not found', 404);

    (deliverable as any).qcStatus = 'approved';
    (deliverable as any).qcNotes = req.body.qc_notes || req.body.notes || '';
    (deliverable as any).qcAt = new Date();
    (deliverable as any).qcBy = req.user!.id;

    // Also update project status to qc_approved
    const oldStatus = project.status;
    if (oldStatus === 'submitted_for_qc' || oldStatus === 'qc_in_progress') {
      project.status = 'qc_approved' as any;
      project.statusUpdatedAt = new Date();
      project.statusHistory.push({
        fromStatus: oldStatus,
        toStatus: 'qc_approved',
        changedBy: req.user!.id as any,
        notes: 'QC approved by supervisor',
        createdAt: new Date(),
      });
    }

    await project.save();

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// ---------- DASHBOARD REQUESTS ----------

// GET /supervisor/dashboard/requests
router.get('/dashboard/requests', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status, subject } = req.query;
    const filter: Record<string, unknown> = { supervisorId: req.user!.id };

    if (status === 'submitted') {
      filter.status = { $in: ['submitted', 'analyzing'] };
    } else if (status === 'paid') {
      filter.status = 'paid';
    } else if (status) {
      filter.status = status;
    }

    if (subject && subject !== 'All') {
      filter['subject'] = { $regex: subject, $options: 'i' };
    }

    const projects = await Project.find(filter)
      .populate('userId', 'fullName email avatarUrl phone')
      .populate('subjectId', 'name')
      .sort({ createdAt: -1 })
      .limit(50);

    const normalizedProjects = projects.map(p => {
      const obj = p.toObject();
      const user = obj.userId && typeof obj.userId === 'object' ? obj.userId as any : null;
      const subj = obj.subjectId && typeof obj.subjectId === 'object' ? obj.subjectId as any : null;
      return {
        ...obj,
        id: obj._id,
        projectNumber: obj.projectNumber,
        clientName: user?.fullName || null,
        clientEmail: user?.email || null,
        subject: subj?.name || null,
        userQuote: obj.pricing?.userQuote || 0,
        service_type: obj.serviceType,
        word_count: obj.wordCount,
        page_count: obj.pageCount,
        created_at: obj.createdAt,
      };
    });

    res.json({ projects: normalizedProjects });
  } catch (err) {
    next(err);
  }
});

// ---------- DOERS ----------

// GET /supervisor/doers - List all doers (for supervisor)
router.get('/doers', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '20', offset = '0', search, expertise, isAvailable, minRating, sortBy, ascending } = req.query;

    const filter: Record<string, unknown> = { isActivated: true };
    if (isAvailable !== undefined) filter.isAvailable = isAvailable === 'true';
    if (minRating) filter.averageRating = { $gte: Number(minRating) };

    const skip = Number(offset);
    const lim = Number(limit);
    let sortObj: Record<string, 1 | -1> = { createdAt: -1 };
    if (sortBy === 'rating') sortObj = { averageRating: ascending === 'true' ? 1 : -1 };
    else if (sortBy === 'name') sortObj = { fullName: ascending === 'true' ? 1 : -1 };

    const doers = await Doer.find(filter)
      .skip(skip)
      .limit(lim)
      .sort(sortObj);

    let normalizedDoers = doers.map(d => {
      const obj = d.toObject();
      return {
        ...obj,
        id: obj._id,
        fullName: obj.fullName || null,
        full_name: obj.fullName || null,
        email: obj.email || null,
        avatarUrl: obj.avatarUrl || null,
        avatar_url: obj.avatarUrl || null,
        averageRating: obj.averageRating || 0,
        totalReviews: obj.totalReviews || 0,
        totalProjectsCompleted: obj.totalProjectsCompleted || 0,
        isAvailable: obj.isAvailable,
        skills: (obj.skills || []).map((s: any) => typeof s === 'string' ? s : s.name || s.skillId || 'Unknown'),
        subjects: (obj.subjects || []).map((s: any) => typeof s === 'string' ? s : s.name || s.subjectId || 'Unknown'),
      };
    });

    // Client-side search filter (search in name/email)
    if (search) {
      const q = (search as string).toLowerCase();
      normalizedDoers = normalizedDoers.filter(d =>
        (d.fullName || '').toLowerCase().includes(q) || (d.email || '').toLowerCase().includes(q)
      );
    }

    // Client-side expertise filter
    if (expertise) {
      const exp = (expertise as string).toLowerCase();
      normalizedDoers = normalizedDoers.filter(d =>
        d.subjects.some((s: string) => s.toLowerCase().includes(exp)) ||
        d.skills.some((s: string) => s.toLowerCase().includes(exp))
      );
    }

    res.json({ doers: normalizedDoers, total: normalizedDoers.length });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/doers/available
router.get('/doers/available', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { expertise } = req.query;
    const filter: Record<string, unknown> = { isActivated: true, isAvailable: true };

    const doers = await Doer.find(filter)
      .sort({ averageRating: -1 })
      .limit(50);

    let normalizedDoers = doers.map(d => {
      const obj = d.toObject();
      return {
        ...obj,
        id: obj._id,
        fullName: obj.fullName || null,
        email: obj.email || null,
        avatarUrl: obj.avatarUrl || null,
        averageRating: obj.averageRating || 0,
        skills: (obj.skills || []).map((s: any) => typeof s === 'string' ? s : s.name || 'Unknown'),
        subjects: (obj.subjects || []).map((s: any) => typeof s === 'string' ? s : s.name || 'Unknown'),
      };
    });

    if (expertise && expertise !== 'All') {
      const exp = (expertise as string).toLowerCase();
      normalizedDoers = normalizedDoers.filter(d =>
        d.subjects.some((s: string) => s.toLowerCase().includes(exp)) ||
        d.skills.some((s: string) => s.toLowerCase().includes(exp))
      );
    }

    res.json({ doers: normalizedDoers });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/doers/count
router.get('/doers/count', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { isAvailable } = req.query;
    const filter: Record<string, unknown> = { isActivated: true };
    if (isAvailable !== undefined) filter.isAvailable = isAvailable === 'true';

    const count = await Doer.countDocuments(filter);
    res.json({ count });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/doers/:id
router.get('/doers/:doerId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doer = await Doer.findById(req.params.doerId);
    if (!doer) throw new AppError('Doer not found', 404);

    const obj = doer.toObject();

    res.json({
      ...obj,
      id: obj._id,
      fullName: obj.fullName || null,
      email: obj.email || null,
      avatarUrl: obj.avatarUrl || null,
      phone: obj.phone || null,
      averageRating: obj.averageRating || 0,
      totalReviews: obj.totalReviews || 0,
      skills: (obj.skills || []).map((s: any) => typeof s === 'string' ? s : s.name || 'Unknown'),
      subjects: (obj.subjects || []).map((s: any) => typeof s === 'string' ? s : s.name || 'Unknown'),
    });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/doers/:id/reviews
router.get('/doers/:doerId/reviews', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '20', offset = '0' } = req.query;
    const skip = Number(offset);
    const lim = Number(limit);

    // Query both review collections and combine results
    const [userReviews, supervisorReviews] = await Promise.all([
      UserDoerReview.find({ doerId: req.params.doerId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(lim),
      SupervisorDoerReview.find({ doerId: req.params.doerId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(lim),
    ]);

    const normalizedUserReviews = userReviews.map(r => {
      const obj = r.toObject();
      return {
        ...obj,
        id: obj._id,
        reviewerName: (obj as any).reviewerName || null,
        reviewerAvatar: (obj as any).reviewerAvatar || null,
        source: 'user',
      };
    });

    const normalizedSupervisorReviews = supervisorReviews.map(r => {
      const obj = r.toObject();
      return {
        ...obj,
        id: obj._id,
        reviewerName: (obj as any).reviewerName || null,
        reviewerAvatar: (obj as any).reviewerAvatar || null,
        source: 'supervisor',
      };
    });

    // Combine and sort by createdAt descending
    const allReviews = [...normalizedUserReviews, ...normalizedSupervisorReviews]
      .sort((a, b) => new Date((b as any).createdAt).getTime() - new Date((a as any).createdAt).getTime())
      .slice(0, lim);

    res.json({ reviews: allReviews });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/doers/:id/projects
router.get('/doers/:doerId/projects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '20', offset = '0' } = req.query;
    const projects = await Project.find({ doerId: req.params.doerId, supervisorId: req.user!.id })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 })
      .skip(Number(offset))
      .limit(Number(limit));

    const normalized = projects.map(p => {
      const obj = p.toObject();
      const user = obj.userId && typeof obj.userId === 'object' ? obj.userId as any : null;
      return {
        ...obj,
        id: obj._id,
        projectNumber: obj.projectNumber,
        clientName: user?.fullName || null,
        userQuote: obj.pricing?.userQuote || 0,
        created_at: obj.createdAt,
      };
    });

    res.json({ projects: normalized });
  } catch (err) {
    next(err);
  }
});

// ---------- EARNINGS ----------

// GET /supervisor/earnings/summary
router.get('/earnings/summary', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    const wallet = await SupervisorWallet.findOne({ supervisorId: req.user!.id });

    const now = new Date();
    const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    let thisMonthEarnings = 0;
    if (wallet) {
      const monthlyAgg = await WalletTransaction.aggregate([
        { $match: { walletId: wallet._id, amount: { $gt: 0 }, status: 'completed', createdAt: { $gte: thisMonth } } },
        { $group: { _id: null, total: { $sum: '$amount' } } },
      ]);
      thisMonthEarnings = monthlyAgg[0]?.total || 0;
    }

    res.json({
      totalEarnings: supervisor?.totalEarnings || wallet?.totalCredited || 0,
      thisMonthEarnings,
      pendingEarnings: wallet?.balance || 0,
      completedProjects: supervisor?.totalProjectsCompleted || 0,
      averageRating: supervisor?.averageRating || 0,
      totalReviews: supervisor?.totalReviews || 0,
      balance: wallet?.balance || 0,
      totalCredited: wallet?.totalCredited || 0,
      totalDebited: wallet?.totalDebited || 0,
      totalWithdrawn: wallet?.totalWithdrawn || 0,
    });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/earnings/chart
router.get('/earnings/chart', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '12' } = req.query;
    const wallet = await SupervisorWallet.findOne({ supervisorId: req.user!.id });
    if (!wallet) return res.json({ data: [] });

    const earnings = await WalletTransaction.aggregate([
      { $match: { walletId: wallet._id, amount: { $gt: 0 }, status: 'completed' } },
      {
        $group: {
          _id: { year: { $year: '$createdAt' }, month: { $month: '$createdAt' } },
          amount: { $sum: '$amount' },
          projectCount: { $sum: 1 },
        },
      },
      { $sort: { '_id.year': -1, '_id.month': -1 } },
      { $limit: Number(limit) },
    ]);

    const data = earnings.map(e => ({
      period: `${e._id.year}-${String(e._id.month).padStart(2, '0')}`,
      amount: e.amount,
      projectCount: e.projectCount,
    }));

    res.json({ data });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/earnings/commissions
router.get('/earnings/commissions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Return commissions from completed projects
    const projects = await Project.find({
      supervisorId: req.user!.id,
      status: 'completed',
    }).select('pricing title projectNumber completedAt').sort({ 'delivery.completedAt': -1 }).limit(50);

    const commissions = projects.map(p => {
      const obj = p.toObject();
      return {
        projectId: obj._id,
        projectTitle: obj.title,
        projectNumber: obj.projectNumber,
        userAmount: obj.pricing?.userQuote || 0,
        commissionAmount: obj.pricing?.supervisorCommission || 0,
        commissionRate: obj.pricing?.userQuote ? ((obj.pricing.supervisorCommission || 0) / obj.pricing.userQuote * 100).toFixed(1) : '0',
        projectCount: 1,
      };
    });

    res.json({ commissions });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/earnings/performance
router.get('/earnings/performance', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    const [totalProjects, completedProjects, activeProjects] = await Promise.all([
      Project.countDocuments({ supervisorId: req.user!.id }),
      Project.countDocuments({ supervisorId: req.user!.id, status: 'completed' }),
      Project.countDocuments({ supervisorId: req.user!.id, status: { $in: ['assigned', 'in_progress', 'under_review'] } }),
    ]);

    res.json({
      totalProjects,
      completedProjects,
      activeProjects,
      averageRating: supervisor?.averageRating || 0,
      totalReviews: supervisor?.totalReviews || 0,
      onTimeDeliveryRate: supervisor?.onTimeDeliveryRate || 0,
      successRate: totalProjects > 0 ? Math.round((completedProjects / totalProjects) * 100) : 0,
      averageResponseTime: 0,
    });
  } catch (err) {
    next(err);
  }
});

// ---------- REVIEWS ----------

// GET /supervisor/reviews
router.get('/reviews', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '20', offset = '0', minRating, maxRating } = req.query;
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) return res.json({ reviews: [] });

    // Reviews could be SupervisorDoerReviews where the supervisor is the reviewer
    // or some other review model. Return empty for now as stub.
    res.json({ reviews: [], total: 0 });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/reviews/summary
router.get('/reviews/summary', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    res.json({
      averageRating: supervisor?.averageRating || 0,
      totalReviews: supervisor?.totalReviews || 0,
      ratingDistribution: { '5': 0, '4': 0, '3': 0, '2': 0, '1': 0 },
    });
  } catch (err) {
    next(err);
  }
});

// ---------- BLACKLIST (alias for /me/blacklist) ----------

// GET /supervisor/blacklist
router.get('/blacklist', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    const blacklist = (supervisor as any).blacklistedDoers || [];
    res.json({ doers: blacklist });
  } catch (err) {
    next(err);
  }
});

// POST /supervisor/blacklist
router.post('/blacklist', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { doer_id, reason } = req.body;
    if (!doer_id) throw new AppError('Doer ID is required', 400);
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    const blacklist = (supervisor as any).blacklistedDoers || [];
    if (!blacklist.some((d: any) => d.id === doer_id)) {
      blacklist.push({ id: doer_id, reason, addedAt: new Date() });
      (supervisor as any).blacklistedDoers = blacklist;
      await supervisor.save();
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// DELETE /supervisor/blacklist/:doerId
router.delete('/blacklist/:doerId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    const blacklist = (supervisor as any).blacklistedDoers || [];
    (supervisor as any).blacklistedDoers = blacklist.filter((d: any) => d.id !== req.params.doerId);
    await supervisor.save();
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// ---------- CLIENTS ----------

// GET /supervisor/clients
router.get('/clients', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '200', offset = '0', search, sortBy, ascending } = req.query;
    const projects = await Project.find({ supervisorId: req.user!.id }).select('userId pricing status createdAt');
    const userIdMap = new Map<string, { projectCount: number; totalSpent: number; lastProjectAt: Date | null }>();
    for (const p of projects) {
      const uid = p.userId?.toString();
      if (!uid) continue;
      const existing = userIdMap.get(uid) || { projectCount: 0, totalSpent: 0, lastProjectAt: null };
      existing.projectCount++;
      existing.totalSpent += (p as any).pricing?.userQuote || 0;
      if (!existing.lastProjectAt || p.createdAt > existing.lastProjectAt) {
        existing.lastProjectAt = p.createdAt;
      }
      userIdMap.set(uid, existing);
    }

    const userIds = Array.from(userIdMap.keys());
    let users_docs = await User.find({ _id: { $in: userIds } }).select('fullName email avatarUrl phone createdAt');

    if (search) {
      const q = (search as string).toLowerCase();
      users_docs = users_docs.filter(p => (p.fullName || '').toLowerCase().includes(q) || (p.email || '').toLowerCase().includes(q));
    }

    const clients = users_docs.map(p => {
      const stats = userIdMap.get(p._id.toString()) || { projectCount: 0, totalSpent: 0, lastProjectAt: null };
      return {
        id: p._id,
        fullName: p.fullName,
        full_name: p.fullName,
        email: p.email,
        avatarUrl: p.avatarUrl,
        avatar_url: p.avatarUrl,
        phone: p.phone,
        createdAt: p.createdAt,
        created_at: p.createdAt,
        projectCount: stats.projectCount,
        project_count: stats.projectCount,
        totalSpent: stats.totalSpent,
        total_spent: stats.totalSpent,
        lastProjectAt: stats.lastProjectAt,
        last_project_at: stats.lastProjectAt,
      };
    });

    const start = Number(offset);
    const end = start + Number(limit);
    res.json({ clients: clients.slice(start, end), total: clients.length });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/clients/count
router.get('/clients/count', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const projects = await Project.find({ supervisorId: req.user!.id }).select('userId');
    const uniqueUsers = new Set(projects.map(p => p.userId?.toString()).filter(Boolean));
    res.json({ count: uniqueUsers.size });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/clients/:id
router.get('/clients/:clientId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const client = await User.findById(req.params.clientId).select('fullName email avatarUrl phone createdAt');
    if (!client) throw new AppError('Client not found', 404);

    const projects = await Project.find({ userId: req.params.clientId, supervisorId: req.user!.id })
      .select('pricing status createdAt');
    const projectCount = projects.length;
    const totalSpent = projects.reduce((sum, p) => sum + ((p as any).pricing?.userQuote || 0), 0);

    res.json({
      id: client._id,
      fullName: client.fullName,
      full_name: client.fullName,
      email: client.email,
      avatarUrl: client.avatarUrl,
      avatar_url: client.avatarUrl,
      phone: client.phone,
      createdAt: client.createdAt,
      projectCount,
      totalSpent,
    });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/clients/:id/projects
router.get('/clients/:clientId/projects', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '20', offset = '0' } = req.query;
    const projects = await Project.find({ userId: req.params.clientId, supervisorId: req.user!.id })
      .sort({ createdAt: -1 })
      .skip(Number(offset))
      .limit(Number(limit));

    const normalized = projects.map(p => {
      const obj = p.toObject();
      return {
        id: obj._id,
        project_id: obj._id,
        projectNumber: obj.projectNumber,
        title: obj.title,
        status: obj.status,
        amount: obj.pricing?.userQuote || 0,
        user_quote: obj.pricing?.userQuote || 0,
        created_at: obj.createdAt,
        completed_at: obj.delivery?.completedAt,
      };
    });

    res.json({ projects: normalized });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisor/clients/:id/notes
router.put('/clients/:clientId/notes', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Store notes in supervisor document (or a separate collection)
    // For now, store as a simple stub
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/clients/:id/notes
router.get('/clients/:clientId/notes', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.json({ notes: '' });
  } catch (err) {
    next(err);
  }
});

// ---------- ACTIVATION ----------

// GET /supervisor/activation/modules
router.get('/activation/modules', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const activation = await SupervisorActivation.findOne({ supervisorId: req.user!.id });
    res.json({
      progress: activation ? {
        trainingCompleted: activation.trainingCompleted,
        quizPassed: activation.quizPassed,
      } : {},
    });
  } catch (err) {
    next(err);
  }
});

// POST /supervisor/activation/modules/:moduleId/complete
router.post('/activation/modules/:moduleId/complete', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    await SupervisorActivation.findOneAndUpdate(
      { supervisorId: req.user!.id },
      { $set: { [`progress.${req.params.moduleId}`]: true } },
      { upsert: true, new: true }
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/activation/quiz/:quizId
router.get('/activation/quiz/:quizId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Stub: quiz content is hardcoded in the mobile app
    res.json({ quizId: req.params.quizId });
  } catch (err) {
    next(err);
  }
});

// POST /supervisor/activation/quiz/submit
router.post('/activation/quiz/submit', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { passed, score } = req.body;
    if (passed) {
      await SupervisorActivation.findOneAndUpdate(
        { supervisorId: req.user!.id },
        { quizPassed: true, quizScore: score },
        { upsert: true, new: true }
      );
    }
    res.json({ success: true, passed, score });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/activation/quiz/:quizId/attempts
router.get('/activation/quiz/:quizId/attempts', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.json({ count: 0 });
  } catch (err) {
    next(err);
  }
});

// POST /supervisor/activation/activate
router.post('/activation/activate', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findByIdAndUpdate(
      req.user!.id,
      { isActivated: true, activatedAt: new Date() },
      { new: true }
    );
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    await SupervisorActivation.findOneAndUpdate(
      { supervisorId: supervisor._id },
      { isActivated: true, activatedAt: new Date() },
      { upsert: true }
    );

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// ---------- REGISTRATION ----------

// POST /supervisor/registration
router.post('/registration', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const existing = await Supervisor.findById(req.user!.id);
    if (existing) {
      const updated = await Supervisor.findByIdAndUpdate(existing._id, req.body, { new: true });
      return res.json({ supervisor: updated, status: 'updated' });
    }

    const supervisor = await Supervisor.create({ ...req.body, _id: req.user!.id });
    await SupervisorActivation.create({ supervisorId: supervisor._id });
    res.status(201).json({ supervisor, status: 'created' });
  } catch (err) {
    next(err);
  }
});

// GET /supervisor/registration/status
router.get('/registration/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) return res.json({ status: 'not_registered' });

    const activation = await SupervisorActivation.findOne({ supervisorId: supervisor._id });
    res.json({
      status: supervisor.isActivated ? 'activated' : (supervisor as any).isApproved ? 'approved' : 'pending',
      supervisor: {
        id: supervisor._id,
        isActivated: supervisor.isActivated,
        isApproved: (supervisor as any).isApproved,
      },
      activation,
    });
  } catch (err) {
    next(err);
  }
});

// =====================================================================
// WILDCARD :id ROUTES (must be LAST to avoid catching named routes)
// =====================================================================

// GET /supervisors/:id
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.params.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    res.json({ supervisor });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisors/:id
router.put('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!supervisor) throw new AppError('Supervisor not found', 404);
    res.json({ supervisor });
  } catch (err) {
    next(err);
  }
});

// GET /supervisors/me/modules -- Get training modules with completion status
router.get('/me/modules', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    // Get all active training modules for supervisors
    const modules = await TrainingModule.find({
      isActive: true,
      targetRole: { $in: ['supervisor', 'all'] },
    }).sort({ order: 1 });

    // Get completion status
    const activation = await SupervisorActivation.findOne({ supervisorId: supervisor._id });
    const completedSteps = activation?.completedSteps || [];

    const modulesWithStatus = modules.map((m) => ({
      _id: m._id,
      title: m.title,
      description: m.description,
      videoUrl: m.videoUrl,
      thumbnailUrl: m.thumbnailUrl,
      duration: m.duration,
      category: m.category,
      order: m.order,
      isCompleted: completedSteps.includes(m._id.toString()),
    }));

    const totalRequired = modules.length;
    const totalCompleted = completedSteps.filter((s: string) =>
      modules.some((m) => m._id.toString() === s)
    ).length;

    res.json({
      modules: modulesWithStatus,
      totalRequired,
      totalCompleted,
      allCompleted: totalRequired > 0 && totalCompleted >= totalRequired,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /supervisors/me/modules/:moduleId/complete -- Mark a module as completed
router.put('/me/modules/:moduleId/complete', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const supervisor = await Supervisor.findById(req.user!.id);
    if (!supervisor) throw new AppError('Supervisor not found', 404);

    const moduleId = req.params.moduleId as string;

    // Verify module exists
    const trainingModule = await TrainingModule.findById(moduleId);
    if (!trainingModule) throw new AppError('Training module not found', 404);

    // Upsert activation record
    let activation = await SupervisorActivation.findOne({ supervisorId: supervisor._id });
    if (!activation) {
      activation = await SupervisorActivation.create({
        supervisorId: supervisor._id,
        step: 0,
        completedSteps: [],
      });
    }

    // Add module to completed steps if not already there
    const steps = activation.completedSteps as string[];
    if (!steps.includes(moduleId)) {
      steps.push(moduleId);
      activation.step = steps.length;
    }

    // Check if all required modules are completed
    const allModules = await TrainingModule.find({
      isActive: true,
      targetRole: { $in: ['supervisor', 'all'] },
    });

    const allModuleIds = allModules.map((m) => m._id.toString());
    const allCompleted = allModuleIds.every((id) => activation!.completedSteps.includes(id));

    if (allCompleted && allModules.length > 0) {
      activation.isCompleted = true;
      activation.isActivated = true;
      activation.trainingCompleted = true;
      activation.completedAt = new Date();
      activation.activatedAt = new Date();

      // Also update the supervisor record
      supervisor.isActivated = true;
      supervisor.activatedAt = new Date();
      await supervisor.save();
    }

    await activation.save();

    res.json({
      success: true,
      completedSteps: activation.completedSteps,
      allCompleted,
      isActivated: supervisor.isActivated,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
