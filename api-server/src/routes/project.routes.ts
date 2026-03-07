import { Router, Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/roleGuard';
import { Project, Notification, Supervisor, ChatRoom } from '../models';
import { uploadBufferToCloudinary } from '../services/upload.service';
import { AppError } from '../middleware/errorHandler';
import multer from 'multer';

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

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });

// GET /projects
router.get('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', status, search, unassigned } = req.query;
    const filter: Record<string, unknown> = {};

    // Filter by role — unknown roles get an empty result set (not all projects)
    // user-web users can have role 'user', 'student', or 'professional'
    if (['user', 'student', 'professional'].includes(req.user!.role)) {
      filter.userId = req.user!.id;
    } else if (req.user!.role === 'doer') {
      if (req.query.pool === 'true') {
        // Open pool: projects sent to pool by supervisor, not yet claimed by any doer
        filter.isOpenPool = true;
        filter.doerId = { $exists: false };
        filter.status = { $in: ['quoted', 'paid'] };
      } else {
        filter.doerId = req.user!.id;
      }
    } else if (req.user!.role === 'supervisor') {
      if (unassigned === 'true') {
        // Supervisor requesting unassigned projects (global pool to claim)
        filter.supervisorId = { $exists: false };
        const supervisorDoc = await Supervisor.findById(req.user!.id).select('expertise');
        if (supervisorDoc?.expertise?.length) {
          filter.subjectId = { $in: supervisorDoc.expertise };
        } else {
          // No expertise set — show all unassigned projects
        }
      } else {
        filter.supervisorId = req.user!.id;
      }
    } else if (req.user!.role !== 'admin') {
      // Unrecognized role — return empty to prevent data leakage
      return res.json({ projects: [], total: 0, page: 1, totalPages: 0 });
    }
    // admin sees all

    if (status) {
      // Support comma-separated status values (e.g. "submitted,analyzing")
      const statuses = (status as string).split(',').map((s: string) => s.trim()).filter(Boolean);
      filter.status = statuses.length === 1 ? statuses[0] : { $in: statuses };
    }
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
        final_quote: obj.pricing?.finalQuote,
        doer_payout: obj.pricing?.doerPayout || 0,
        supervisor_commission: obj.pricing?.supervisorCommission || 0,
        status_updated_at: obj.statusUpdatedAt,
        doer_assigned_at: obj.doerAssignedAt,
        created_at: obj.createdAt,
        updated_at: obj.updatedAt,
        delivered_at: obj.delivery?.deliveredAt,
        completed_at: obj.delivery?.completedAt,
        subject: obj.subjectId && typeof obj.subjectId === 'object' ? { id: (obj.subjectId as any)._id, name: (obj.subjectId as any).name } : null,
        is_open_pool: obj.isOpenPool || false,
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
    // Cast subjectId to ObjectId only if it's a valid 24-char hex string
    if (body.subjectId && typeof body.subjectId === 'string' && /^[0-9a-fA-F]{24}$/.test(body.subjectId)) {
      body.subjectId = new mongoose.Types.ObjectId(body.subjectId);
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

    // Ownership check — only participants and admins can view a project
    const uid = req.user!.id;
    const resolveId = (field: any): string | undefined => {
      if (!field) return undefined;
      // Handles both raw ObjectId (no ._id) and populated documents (have ._id)
      return (field._id ?? field).toString();
    };
    const isParticipant =
      resolveId(project.userId) === uid ||
      resolveId(project.supervisorId) === uid ||
      resolveId(project.doerId) === uid ||
      req.user!.role === 'admin';
    if (!isParticipant) throw new AppError('Forbidden', 403);

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
      // Provide populated user/doer/supervisor data as frontend-expected shapes
      profiles: userPopulated ? { full_name: (obj.userId as any).fullName, email: (obj.userId as any).email, avatar_url: (obj.userId as any).avatarUrl, phone: (obj.userId as any).phone } : null,
      user: userPopulated ? { full_name: (obj.userId as any).fullName, email: (obj.userId as any).email, avatar_url: (obj.userId as any).avatarUrl, phone: (obj.userId as any).phone } : null,
      doers: doerPopulated ? { full_name: (obj.doerId as any).fullName, email: (obj.doerId as any).email, avatar_url: (obj.doerId as any).avatarUrl, average_rating: null, profiles: { full_name: (obj.doerId as any).fullName, email: (obj.doerId as any).email, avatar_url: (obj.doerId as any).avatarUrl } } : null,
      supervisors: supervisorPopulated ? { full_name: (obj.supervisorId as any).fullName, email: (obj.supervisorId as any).email, avatar_url: (obj.supervisorId as any).avatarUrl } : null,
      supervisor: supervisorPopulated ? { full_name: (obj.supervisorId as any).fullName, email: (obj.supervisorId as any).email, avatar_url: (obj.supervisorId as any).avatarUrl } : null,
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
      is_open_pool: obj.isOpenPool || false,
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
      deliverables: (obj.deliverables || []).map((d: any) => {
        const bytes = d.fileSizeBytes || 0;
        const sizeStr = bytes > 1024 * 1024
          ? `${(bytes / (1024 * 1024)).toFixed(1)} MB`
          : bytes > 1024
          ? `${(bytes / 1024).toFixed(0)} KB`
          : `${bytes} B`;
        return {
          id: d._id,
          name: d.fileName,
          url: d.fileUrl,
          file_type: d.fileType,
          size: sizeStr,
          version: d.version,
          qc_status: d.qcStatus,
          isFinal: d.version === (obj.deliverables || []).length,
          uploadedAt: d.createdAt,
        };
      }),
    };

    res.json({ project: normalized });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id
router.put('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    const uid = req.user!.id;
    const role = req.user!.role;
    const isUser = project.userId?.toString() === uid;
    const isDoer = project.doerId?.toString() === uid;
    const isSupervisor = project.supervisorId?.toString() === uid;
    const isAdmin = role === 'admin';

    if (!isUser && !isDoer && !isSupervisor && !isAdmin) throw new AppError('Forbidden', 403);

    // Role-based field allowlist — prevent privilege escalation via body params
    const allowedByUser = ['title', 'description', 'requirements', 'budget', 'deadline', 'wordCount', 'pageCount', 'specificInstructions'];
    const allowedByDoer = ['liveDocumentUrl', 'progressPercentage', 'notes'];
    const allowedBySupervisor = ['deadline', 'notes', 'liveDocumentUrl', 'progressPercentage'];
    const allowedByAdmin = Object.keys(req.body);

    const allowedFields = isAdmin ? allowedByAdmin : isSupervisor ? allowedBySupervisor : isDoer ? allowedByDoer : allowedByUser;
    const updates: Record<string, unknown> = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    }

    const updated = await Project.findByIdAndUpdate(req.params.id, updates, { new: true });

    const io = req.app.get('io');
    if (io && updated?.userId) {
      io.to(`user:${updated.userId}`).emit('project:updated', { projectId: updated._id });
    }

    // Notify participants when live doc URL is updated
    if (updates.liveDocumentUrl !== undefined && updated) {
      const recipients = [updated.userId, updated.supervisorId, updated.doerId]
        .filter(id => id && id.toString() !== uid);
      for (const recipientId of recipients) {
        const recipientRole = recipientId!.toString() === updated.userId?.toString() ? 'user'
          : recipientId!.toString() === updated.supervisorId?.toString() ? 'supervisor' : 'doer';
        const notification = await Notification.create({
          recipientId,
          recipientRole,
          type: 'live_doc_updated',
          title: 'Live Document Updated',
          message: updates.liveDocumentUrl
            ? `A live document link has been added to "${updated.title}"`
            : `Live document link removed from "${updated.title}"`,
          data: { projectId: updated._id },
        });
        if (io) io.to(`user:${recipientId}`).emit('notification:new', notification);
      }
    }

    res.json({ project: updated });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/status
router.put('/:id/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Only doers, supervisors, and admins can change project status via this endpoint.
    // Regular users (clients) approve via PUT /projects/:id/approve instead.
    if (!['doer', 'supervisor', 'admin'].includes(req.user!.role)) {
      throw new AppError('Insufficient permissions to change project status', 403);
    }
    const { status, notes } = req.body;
    const VALID_STATUSES = ['draft', 'submitted', 'analyzing', 'quoted', 'payment_pending', 'paid', 'assigned', 'in_progress', 'submitted_for_qc', 'qc_in_progress', 'qc_approved', 'delivered', 'revision_requested', 'in_revision', 'approved', 'auto_approved', 'completed', 'cancelled'];
    if (!VALID_STATUSES.includes(status)) {
      throw new AppError(`Invalid status value: ${status}`, 400);
    }
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

    // Create persistent notifications for key status transitions
    const statusNotifications: { recipientId: any; recipientRole: string; type: string; title: string; message: string }[] = [];
    if (status === 'delivered') {
      if (project.userId) {
        statusNotifications.push({
          recipientId: project.userId,
          recipientRole: 'user',
          type: 'project_delivered',
          title: 'Project Delivered',
          message: `Your project "${project.title}" has been delivered and is ready for review`,
        });
      }
      if (project.supervisorId) {
        statusNotifications.push({
          recipientId: project.supervisorId,
          recipientRole: 'supervisor',
          type: 'project_delivered',
          title: 'Project Delivered',
          message: `Project "${project.title}" has been delivered by the doer`,
        });
      }
    } else if (status === 'in_progress') {
      if (project.userId) {
        statusNotifications.push({
          recipientId: project.userId,
          recipientRole: 'user',
          type: 'project_started',
          title: 'Work Started',
          message: `Work has started on your project "${project.title}"`,
        });
      }
    } else if (status === 'submitted_for_qc') {
      if (project.supervisorId) {
        statusNotifications.push({
          recipientId: project.supervisorId,
          recipientRole: 'supervisor',
          type: 'project_submitted_for_qc',
          title: 'Project Submitted for QC',
          message: `Project "${project.title}" has been submitted for quality check`,
        });
      }
    } else if (status === 'revision_requested') {
      if (project.doerId) {
        statusNotifications.push({
          recipientId: project.doerId,
          recipientRole: 'doer',
          type: 'revision_requested',
          title: 'Revision Requested',
          message: `A revision has been requested for project "${project.title}"`,
        });
      }
    }

    for (const n of statusNotifications) {
      const notification = await Notification.create({
        recipientId: n.recipientId,
        recipientRole: n.recipientRole,
        type: n.type,
        title: n.title,
        message: n.message,
        data: { projectId: project._id },
      });
      if (io) io.to(`user:${n.recipientId}`).emit('notification:new', notification);
    }

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// GET /projects/:id/files
router.get('/:id/files', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id).select('files');
    if (!project) throw new AppError('Project not found', 404);
    const files = (project.files || []).map((f: any) => ({
      id: f._id,
      file_name: f.fileName,
      file_url: f.fileUrl,
      file_type: f.fileType,
      file_size_bytes: f.fileSizeBytes,
      file_category: f.fileCategory,
      created_at: f.createdAt,
    }));
    res.json({ files });
  } catch (err) {
    next(err);
  }
});

// GET /projects/:id/deliverables
router.get('/:id/deliverables', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id).select('deliverables');
    if (!project) throw new AppError('Project not found', 404);
    const deliverables = (project.deliverables || []).map((d: any) => {
      const bytes = d.fileSizeBytes || 0;
      const sizeStr = bytes > 1024 * 1024
        ? `${(bytes / (1024 * 1024)).toFixed(1)} MB`
        : bytes > 1024
        ? `${(bytes / 1024).toFixed(0)} KB`
        : `${bytes} B`;
      return {
        id: d._id,
        name: d.fileName,
        url: d.fileUrl,
        file_type: d.fileType,
        size: sizeStr,
        version: d.version,
        qc_status: d.qcStatus,
        isFinal: d.version === (project.deliverables || []).length,
        uploadedAt: d.createdAt,
      };
    });
    res.json({ deliverables });
  } catch (err) {
    next(err);
  }
});

// GET /projects/:id/revisions
router.get('/:id/revisions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id).select('revisions');
    if (!project) throw new AppError('Project not found', 404);
    const revisions = (project.revisions || []).map((r: any) => ({
      id: r._id,
      revision_number: r.revisionNumber,
      feedback: r.feedback,
      specific_changes: r.specificChanges,
      response_notes: r.responseNotes,
      status: r.status,
      created_at: r.createdAt,
      completed_at: r.completedAt,
    }));
    res.json({ revisions });
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
    const timeline = project.statusHistory.map((s: any) => {
      const obj = s.toObject ? s.toObject() : s;
      return {
        id: obj._id?.toString(),
        from_status: obj.fromStatus || '',
        to_status: obj.toStatus || '',
        notes: obj.notes || '',
        created_at: obj.createdAt || obj.created_at || null,
        changed_by: obj.changedBy?.toString() || null,
      };
    });
    res.json({ timeline });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/assign-doer
router.put('/:id/assign-doer', authenticate, requireRole('supervisor', 'admin'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { doerId } = req.body;
    if (!doerId) throw new AppError('doerId is required', 400);

    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);
    if (project.status !== 'paid') throw new AppError('Cannot assign a doer until the client has paid', 403);

    const oldStatus = project.status;
    project.doerId = doerId;
    project.status = 'assigned';
    project.statusUpdatedAt = new Date();
    project.doerAssignedAt = new Date();
    project.statusHistory.push({
      fromStatus: oldStatus,
      toStatus: 'assigned',
      changedBy: req.user!.id as any,
      notes: 'Doer assigned by supervisor after client payment',
      createdAt: new Date(),
    });
    await project.save();

    // Notify doer
    const doerNotification = await Notification.create({
      recipientId: doerId,
      recipientRole: 'doer',
      type: 'project_assigned',
      title: 'New Project Assigned',
      message: `You have been assigned to project "${project.title}"`,
      data: { projectId: project._id },
    });

    const io = req.app.get('io');
    if (io) {
      io.to(`user:${doerId}`).emit('notification:new', doerNotification);
    }

    // Notify project owner
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
    await autoJoinProjectChat(req.params.id as string, doerId, 'doer');

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
    // Only the project owner (client) can approve their own project
    if (String(project.userId) !== req.user!.id) {
      throw new AppError('Only the project owner can approve this project', 403);
    }

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

    // Notify supervisor and doer that project is completed
    const io = req.app.get('io');
    const completionTargets = [
      { recipientId: project.supervisorId, recipientRole: 'supervisor' },
      { recipientId: project.doerId, recipientRole: 'doer' },
    ].filter(t => t.recipientId);

    for (const target of completionTargets) {
      const notification = await Notification.create({
        recipientId: target.recipientId,
        recipientRole: target.recipientRole,
        type: 'project_completed',
        title: 'Project Completed',
        message: `Project "${project.title}" has been approved and completed`,
        data: { projectId: project._id },
      });
      if (io) io.to(`user:${target.recipientId}`).emit('notification:new', notification);
    }

    res.json({ project });
  } catch (err) {
    next(err);
  }
});

// PUT /projects/:id/grade
router.put('/:id/grade', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id).select('userId');
    if (!project) throw new AppError('Project not found', 404);
    if (String(project.userId) !== req.user!.id) {
      throw new AppError('Only the project owner can grade this project', 403);
    }
    const updated = await Project.findByIdAndUpdate(
      req.params.id,
      { 'userApproval.grade': req.body.grade, 'userApproval.feedback': req.body.feedback },
      { new: true }
    );
    res.json({ project: updated });
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
    // Return a single quote entry: prefer finalQuote, fall back to userQuote
    const quoteAmount = project.pricing?.finalQuote || project.pricing?.userQuote;
    if (quoteAmount) {
      // Find the "quoted" status change timestamp for accurate positioning in timeline
      const fullProject = await Project.findById(req.params.id).select('statusHistory');
      const quotedEntry = fullProject?.statusHistory?.find((s: any) => s.toStatus === 'quoted');
      quotes.push({
        id: `${project._id}-quote`,
        type: 'final_quote',
        user_amount: quoteAmount,
        status: 'accepted',
        created_at: quotedEntry?.createdAt || (project as any).createdAt,
      });
    }

    res.json({ quotes });
  } catch (err) {
    next(err);
  }
});

// POST /projects/:id/quote — supervisor sets a quote for the user to pay
// Doer assignment happens AFTER user payment via /assign-doer or /open-pool
router.post('/:id/quote', authenticate, requireRole('supervisor', 'admin'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userQuote, doerPayout } = req.body;
    if (!userQuote || userQuote <= 0) throw new AppError('userQuote is required and must be positive', 400);
    if (!doerPayout || doerPayout <= 0) throw new AppError('doerPayout is required and must be positive', 400);

    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);

    const supervisorCommission = Math.ceil(userQuote * 0.15);
    const platformFee = Math.ceil(userQuote * 0.20);

    project.pricing = {
      ...project.pricing,
      userQuote,
      doerPayout,
      supervisorCommission,
      platformFee,
      finalQuote: userQuote,
    };

    const oldStatus = project.status;
    project.status = 'quoted';
    project.statusUpdatedAt = new Date();
    project.statusHistory.push({
      fromStatus: oldStatus,
      toStatus: 'quoted',
      changedBy: req.user!.id as any,
      notes: `Quote set: ₹${userQuote}. Awaiting client payment.`,
      createdAt: new Date(),
    });
    await project.save();

    const io = req.app.get('io');
    if (io && project.userId) {
      io.to(`user:${project.userId}`).emit('project:statusChanged', {
        projectId: project._id,
        status: 'quoted',
        oldStatus,
      });
    }

    await Notification.create({
      recipientId: project.userId,
      recipientRole: 'user',
      type: 'project_quoted',
      title: 'Quote Ready',
      message: `Your project "${project.title}" has been quoted at ₹${userQuote}. Please complete payment to begin work.`,
      data: { projectId: project._id },
    });

    res.json({ success: true, project });
  } catch (err) {
    next(err);
  }
});

// POST /projects/:id/claim-from-pool — doer self-assigns from the open pool
router.post('/:id/claim-from-pool', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'doer') throw new AppError('Only doers can claim from pool', 403);

    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);
    if (!project.isOpenPool) throw new AppError('Project is not in the open pool', 400);
    if (project.doerId) throw new AppError('Project has already been claimed', 400);
    if (project.status !== 'paid') throw new AppError('Project payment is pending — doer cannot claim yet', 400);

    project.doerId = req.user!.id as any;
    project.isOpenPool = false;
    project.doerAssignedAt = new Date();
    project.status = 'assigned';
    project.statusUpdatedAt = new Date();
    project.statusHistory.push({
      fromStatus: 'quoted',
      toStatus: 'assigned',
      changedBy: req.user!.id as any,
      notes: 'Claimed from open pool by doer',
      createdAt: new Date(),
    });
    await project.save();

    const io = req.app.get('io');

    // Notify supervisor
    if (project.supervisorId) {
      const notification = await Notification.create({
        recipientId: project.supervisorId,
        recipientRole: 'supervisor',
        type: 'pool_claimed',
        title: 'Pool Project Claimed',
        message: `A doer has claimed "${project.title}" from the open pool`,
        data: { projectId: project._id },
      });
      if (io) io.to(`user:${project.supervisorId}`).emit('notification:new', notification);
    }

    // Notify project owner
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

    res.json({ success: true, project });
  } catch (err) {
    next(err);
  }
});

// POST /projects/:id/open-pool — supervisor sends project to the open doer pool (only after client pays)
router.post('/:id/open-pool', authenticate, requireRole('supervisor', 'admin'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);
    if (project.status !== 'paid') throw new AppError('Cannot open pool until the client has paid', 403);

    project.isOpenPool = true;
    // Remove any direct doer pre-assignment if there was one
    if (project.doerId && !project.doerAssignedAt) {
      project.doerId = undefined as any;
    }
    project.statusHistory.push({
      fromStatus: project.status,
      toStatus: project.status,
      changedBy: req.user!.id as any,
      notes: 'Project sent to open pool',
      createdAt: new Date(),
    });
    await project.save();

    res.json({ success: true, project });
  } catch (err) {
    next(err);
  }
});

// POST /projects/:id/claim — supervisor self-assigns to an unassigned project
router.post('/:id/claim', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'supervisor') throw new AppError('Only supervisors can claim projects', 403);

    const project = await Project.findById(req.params.id);
    if (!project) throw new AppError('Project not found', 404);
    if (project.supervisorId) throw new AppError('Project already claimed', 400);

    // Verify subject expertise match
    const supervisorDoc = await Supervisor.findById(req.user!.id).select('expertise');
    if (!supervisorDoc) throw new AppError('Supervisor profile not found', 404);

    const expertiseList = (supervisorDoc.expertise || []).map((e: string) => e.toLowerCase());
    if (project.subjectId && expertiseList.length > 0 && !expertiseList.includes(project.subjectId.toString().toLowerCase())) {
      throw new AppError('This project does not match your subject expertise', 403);
    }

    project.supervisorId = req.user!.id as any;
    project.statusHistory.push({
      fromStatus: project.status,
      toStatus: project.status,
      changedBy: req.user!.id as any,
      notes: 'Project claimed by supervisor',
      createdAt: new Date(),
    });
    await project.save();

    // Notify project owner that a supervisor has been assigned
    if (project.userId) {
      const notification = await Notification.create({
        recipientId: project.userId,
        recipientRole: 'user',
        type: 'project_claimed',
        title: 'Supervisor Assigned',
        message: `A supervisor has been assigned to "${project.title}"`,
        data: { projectId: project._id },
      });
      const io = req.app.get('io');
      if (io) io.to(`user:${project.userId}`).emit('notification:new', notification);
    }

    // Auto-add supervisor to project chat room
    await autoJoinProjectChat(req.params.id as string, req.user!.id, 'supervisor');

    res.json({ success: true, project });
  } catch (err) {
    next(err);
  }
});

export default router;
