import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/roleGuard';
import { Project, Notification } from '../models';
import { uploadBufferToCloudinary } from '../services/upload.service';
import { AppError } from '../middleware/errorHandler';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });

// GET /projects
router.get('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', status, search } = req.query;
    const filter: Record<string, unknown> = {};

    // Filter by role
    if (req.user!.role === 'user') {
      filter.userId = req.user!.id;
    } else if (req.user!.role === 'doer') {
      filter.doerId = req.user!.id;
    } else if (req.user!.role === 'supervisor') {
      filter.supervisorId = req.user!.id;
    }
    // admin sees all

    if (status) filter.status = status;
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { topic: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    const [projects, total] = await Promise.all([
      Project.find(filter)
        .populate('userId', 'fullName email avatarUrl')
        .populate('doerId', 'fullName email avatarUrl')
        .populate('supervisorId', 'fullName email avatarUrl')
        .populate('subjectId', 'name')
        .skip(skip)
        .limit(Number(limit))
        .sort({ createdAt: -1 }),
      Project.countDocuments(filter),
    ]);

    // Normalize project fields for frontend compatibility
    const normalizedProjects = projects.map((p) => {
      const obj = p.toObject();
      return {
        ...obj,
        id: obj._id,
        project_number: obj.projectNumber,
        user_id: obj.userId,
        service_type: obj.serviceType,
        subject_id: obj.subjectId,
        reference_style_id: obj.referenceStyleId,
        word_count: obj.wordCount,
        page_count: obj.pageCount,
        progress_percentage: obj.progressPercentage,
        user_quote: obj.pricing?.userQuote,
        created_at: obj.createdAt,
        updated_at: obj.updatedAt,
        delivered_at: obj.delivery?.deliveredAt,
        completed_at: obj.delivery?.completedAt,
        subject: obj.subjectId && typeof obj.subjectId === 'object' ? { id: (obj.subjectId as any)._id, name: (obj.subjectId as any).name } : null,
      };
    });
    res.json({ projects: normalizedProjects, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// POST /projects
router.post('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const projectCount = await Project.countDocuments();
    const projectNumber = `AX-${String(projectCount + 1).padStart(6, '0')}`;

    // Map frontend field names to model field names
    const body = { ...req.body };
    if (body.instructions && !body.specificInstructions) {
      body.specificInstructions = body.instructions;
      delete body.instructions;
    }
    if (body.deadline) {
      body.originalDeadline = body.deadline;
    }

    const project = await Project.create({
      ...body,
      userId: req.user!.id,
      projectNumber,
      status: 'submitted',
      statusHistory: [{
        fromStatus: '',
        toStatus: 'submitted',
        changedBy: req.user!.id,
        notes: 'Project created',
        createdAt: new Date(),
      }],
    });

    res.status(201).json({ project });
  } catch (err) {
    next(err);
  }
});

// GET /projects/:id
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id)
      .populate('userId', 'fullName email avatarUrl phone')
      .populate('doerId', 'fullName email avatarUrl')
      .populate('supervisorId', 'fullName email avatarUrl')
      .populate('subjectId', 'name')
      .populate('referenceStyleId', 'name');

    if (!project) throw new AppError('Project not found', 404);

    // Normalize fields for frontend compatibility
    const obj = project.toObject();

    // Extract IDs from populated fields (populated => object, not populated => ObjectId string)
    const userPopulated = obj.userId && typeof obj.userId === 'object' && obj.userId._id;
    const doerPopulated = obj.doerId && typeof obj.doerId === 'object' && obj.doerId._id;
    const supervisorPopulated = obj.supervisorId && typeof obj.supervisorId === 'object' && obj.supervisorId._id;

    const normalized = {
      ...obj,
      id: obj._id,
      project_number: obj.projectNumber,
      user_id: userPopulated ? (obj.userId as any)._id : obj.userId,
      doer_id: doerPopulated ? (obj.doerId as any)._id : obj.doerId,
      supervisor_id: supervisorPopulated ? (obj.supervisorId as any)._id : obj.supervisorId,
      // Provide populated user/doer data as frontend-expected shapes
      profiles: userPopulated ? { full_name: (obj.userId as any).fullName, email: (obj.userId as any).email, avatar_url: (obj.userId as any).avatarUrl, phone: (obj.userId as any).phone } : null,
      doers: doerPopulated ? { profiles: { full_name: (obj.doerId as any).fullName, email: (obj.doerId as any).email, avatar_url: (obj.doerId as any).avatarUrl }, average_rating: null } : null,
      supervisors: supervisorPopulated ? { full_name: (obj.supervisorId as any).fullName, email: (obj.supervisorId as any).email, avatar_url: (obj.supervisorId as any).avatarUrl } : null,
      // Also keep subjects in frontend-expected shape
      subjects: obj.subjectId && typeof obj.subjectId === 'object' ? { name: (obj.subjectId as any).name } : null,
      service_type: obj.serviceType,
      subject_id: obj.subjectId && typeof obj.subjectId === 'object' ? (obj.subjectId as any)._id : obj.subjectId,
      reference_style_id: obj.referenceStyleId && typeof obj.referenceStyleId === 'object' ? (obj.referenceStyleId as any)._id : obj.referenceStyleId,
      word_count: obj.wordCount,
      page_count: obj.pageCount,
      progress_percentage: obj.progressPercentage,
      specific_instructions: obj.specificInstructions,
      user_quote: obj.pricing?.userQuote,
      final_quote: obj.pricing?.finalQuote,
      live_document_url: obj.liveDocumentUrl,
      ai_score: obj.qualityCheck?.aiScore,
      ai_report_url: obj.qualityCheck?.aiReportUrl,
      plagiarism_score: obj.qualityCheck?.plagiarismScore,
      plagiarism_report_url: obj.qualityCheck?.plagiarismReportUrl,
      created_at: obj.createdAt,
      updated_at: obj.updatedAt,
      delivered_at: obj.delivery?.deliveredAt,
      completed_at: obj.delivery?.completedAt,
      cancelled_at: obj.cancelledAt,
      status_updated_at: obj.statusUpdatedAt,
      doer_assigned_at: obj.doerAssignedAt,
      doer_payout: obj.pricing?.doerPayout || 0,
      supervisor_commission: obj.pricing?.supervisorCommission || 0,
      subject: obj.subjectId && typeof obj.subjectId === 'object' ? { id: (obj.subjectId as any)._id, name: (obj.subjectId as any).name } : null,
      reference_style: obj.referenceStyleId && typeof obj.referenceStyleId === 'object' ? { id: (obj.referenceStyleId as any)._id, name: (obj.referenceStyleId as any).name } : null,
      files: (obj.files || []).map((f: any) => ({
        id: f._id,
        file_name: f.fileName,
        file_url: f.fileUrl,
        file_type: f.fileType,
        file_size_bytes: f.fileSizeBytes,
        file_category: f.fileCategory,
        created_at: f.createdAt,
      })),
      deliverables: (obj.deliverables || []).map((d: any) => ({
        id: d._id,
        file_name: d.fileName,
        file_url: d.fileUrl,
        file_type: d.fileType,
        file_size_bytes: d.fileSizeBytes,
        version: d.version,
        qc_status: d.qcStatus,
        is_final: d.version === (obj.deliverables || []).length,
        created_at: d.createdAt,
      })),
    };

    res.json({ project: normalized });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id
router.put('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!project) throw new AppError('Project not found', 404);

    const io = req.app.get('io');
    if (io && project.userId) {
      io.to(`user:${project.userId}`).emit('project:updated', { projectId: project._id });
    }

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/status
router.put('/:id/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
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

    // Emit socket event
    const io = req.app.get('io');
    if (io) {
      const targets = [project.userId, project.doerId, project.supervisorId].filter(Boolean);
      targets.forEach((id) => {
        io.to(`user:${id}`).emit('project:statusChanged', {
          projectId: project._id,
          status,
          oldStatus,
        });
      });
    }

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// POST /projects/:id/files
router.post('/:id/files', authenticate, upload.single('file'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) throw new AppError('No file provided', 400);
    const result = await uploadBufferToCloudinary(req.file.buffer, 'assignx/projects');

    const project = await Project.findByIdAndUpdate(
      req.params.id,
      {
        $push: {
          files: {
            fileName: req.file.originalname,
            fileUrl: result.url,
            fileType: req.file.mimetype,
            fileSizeBytes: result.bytes,
            fileCategory: req.body.category || 'general',
            uploadedBy: req.user!.id,
            createdAt: new Date(),
          },
        },
      },
      { new: true }
    );

    if (!project) throw new AppError('Project not found', 404);
    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// POST /projects/:id/deliverables
router.post('/:id/deliverables', authenticate, upload.single('file'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) throw new AppError('No file provided', 400);
    const result = await uploadBufferToCloudinary(req.file.buffer, 'assignx/deliverables');

    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    const version = project.deliverables.length + 1;
    project.deliverables.push({
      fileName: req.file.originalname,
      fileUrl: result.url,
      fileType: req.file.mimetype,
      fileSizeBytes: result.bytes,
      version,
      qcStatus: 'pending',
      qcNotes: '',
      qcAt: undefined as any,
      qcBy: undefined as any,
      uploadedBy: req.user!.id as any,
      createdAt: new Date(),
    });

    await project.save();

    // Notify user
    const io = req.app.get('io');
    if (io && project.userId) {
      io.to(`user:${project.userId}`).emit('project:deliverable', { projectId: project._id, version });
    }

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// POST /projects/:id/revisions
router.post('/:id/revisions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    const revisionNumber = project.revisions.length + 1;
    project.revisions.push({
      requestedBy: req.user!.id as any,
      requestedByType: req.user!.role,
      revisionNumber,
      feedback: req.body.feedback || '',
      specificChanges: req.body.specificChanges || '',
      responseNotes: '',
      status: 'pending',
      createdAt: new Date(),
      completedAt: undefined as any,
    });

    project.status = 'revision_requested';
    project.statusUpdatedAt = new Date();
    await project.save();

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// GET /projects/:id/timeline
router.get('/:id/timeline', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id).select('statusHistory');
    if (!project) throw new AppError('Project not found', 404);
    res.json({ timeline: project.statusHistory });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/assign-doer
router.put('/:id/assign-doer', authenticate, requireRole('supervisor', 'admin'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { doerId } = req.body;
    const project = await Project.findByIdAndUpdate(
      req.params.id,
      { doerId, status: 'assigned', statusUpdatedAt: new Date() },
      { new: true }
    );
    if (!project) throw new AppError('Project not found', 404);

    // Notify doer
    await Notification.create({
      userId: doerId,
      type: 'project_assigned',
      title: 'New Project Assigned',
      message: `You have been assigned to project ${project.title}`,
      data: { projectId: project._id },
    });

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/assign-supervisor
router.put('/:id/assign-supervisor', authenticate, requireRole('admin'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { supervisorId } = req.body;
    const project = await Project.findByIdAndUpdate(
      req.params.id,
      { supervisorId },
      { new: true }
    );
    if (!project) throw new AppError('Project not found', 404);
    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/approve
router.put('/:id/approve', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    project.userApproval = {
      approved: true,
      approvedAt: new Date(),
      feedback: req.body.feedback || '',
      grade: req.body.grade || '',
    };
    project.status = 'completed';
    project.statusUpdatedAt = new Date();
    project.delivery.completedAt = new Date();
    await project.save();

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/grade
router.put('/:id/grade', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findByIdAndUpdate(
      req.params.id,
      { 'userApproval.grade': req.body.grade, 'userApproval.feedback': req.body.feedback },
      { new: true }
    );
    if (!project) throw new AppError('Project not found', 404);
    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// GET /projects/:id/quotes
router.get('/:id/quotes', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id).select('pricing');
    if (!project) throw new AppError('Project not found', 404);

    const quotes = [];
    if (project.pricing?.userQuote) {
      quotes.push({
        id: `${project._id}-user`,
        type: 'user_quote',
        amount: project.pricing.userQuote,
        status: 'accepted',
        createdAt: project.createdAt,
      });
    }
    if (project.pricing?.finalQuote) {
      quotes.push({
        id: `${project._id}-final`,
        type: 'final_quote',
        amount: project.pricing.finalQuote,
        status: 'accepted',
        createdAt: project.updatedAt,
      });
    }

    res.json({ quotes });
  } catch (err) {
    next(err);
  }
});

export default router;
