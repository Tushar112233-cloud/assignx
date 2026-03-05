import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/roleGuard';
import { SupportTicket, FAQ } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /support/tickets
router.get('/tickets', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', status } = req.query;
    const filter: Record<string, unknown> = {};

    if (req.user!.role !== 'admin') {
      filter.raisedById = req.user!.id;
      filter.raisedByRole = req.user!.role;
    }
    if (status) filter.status = status;

    const skip = (Number(page) - 1) * Number(limit);
    const [tickets, total] = await Promise.all([
      SupportTicket.find(filter).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      SupportTicket.countDocuments(filter),
    ]);

    res.json({ tickets, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// POST /support/tickets
router.post('/tickets', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ticket = await SupportTicket.create({
      raisedById: req.user!.id,
      raisedByRole: req.user!.role,
      userName: req.body.userName || '',
      subject: req.body.subject,
      description: req.body.description,
      category: req.body.category || 'general',
      priority: req.body.priority || 'medium',
    });
    res.status(201).json({ ticket });
  } catch (err) {
    next(err);
  }
});

// GET /support/tickets/:id
router.get('/tickets/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ticket = await SupportTicket.findById(req.params.id);
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ ticket });
  } catch (err) {
    next(err);
  }
});

// PUT /support/tickets/:id
router.put('/tickets/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const updates: Record<string, unknown> = {};
    if (req.body.status) {
      updates.status = req.body.status;
      if (req.body.status === 'resolved') updates.resolvedAt = new Date();
    }
    if (req.body.assignedTo) updates.assignedTo = req.body.assignedTo;
    if (req.body.priority) updates.priority = req.body.priority;

    const ticket = await SupportTicket.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ ticket });
  } catch (err) {
    next(err);
  }
});

// POST /support/tickets/:id/messages
router.post('/tickets/:id/messages', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ticket = await SupportTicket.findByIdAndUpdate(
      req.params.id,
      {
        $push: {
          messages: {
            senderId: req.user!.id,
            senderName: req.body.senderName || '',
            senderRole: req.user!.role,
            message: req.body.message,
            attachmentUrl: req.body.attachmentUrl,
            createdAt: new Date(),
          },
        },
      },
      { new: true }
    );
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ ticket });
  } catch (err) {
    next(err);
  }
});

// POST /support/feedback
router.post('/feedback', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ticket = await SupportTicket.create({
      raisedById: req.user!.id,
      raisedByRole: req.user!.role,
      userName: req.body.userName || '',
      subject: req.body.subject || 'User Feedback',
      description: req.body.feedback || req.body.description || '',
      category: 'feedback',
      priority: 'low',
      status: 'resolved',
      resolvedAt: new Date(),
    });
    res.status(201).json({ success: true, ticket });
  } catch (err) {
    next(err);
  }
});

// GET /support/faqs
router.get('/faqs', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { category } = req.query;
    const filter: Record<string, unknown> = { isActive: true };
    if (category) filter.category = category;

    const faqs = await FAQ.find(filter).sort({ order: 1 });
    res.json({ faqs });
  } catch (err) {
    next(err);
  }
});

// POST /support/faqs/:id/helpful
router.post('/faqs/:id/helpful', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const faq = await FAQ.findByIdAndUpdate(req.params.id, { $inc: { helpfulCount: 1 } }, { new: true });
    if (!faq) throw new AppError('FAQ not found', 404);
    res.json({ faq });
  } catch (err) {
    next(err);
  }
});

// GET /support/faqs/categories - Get FAQ categories
router.get('/faqs/categories', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const faqs = await FAQ.find({ isActive: true }).select('category');
    const categories = [...new Set(faqs.map(f => (f as any).category).filter(Boolean))];
    const categoryList = categories.map(c => ({
      id: c,
      name: c.charAt(0).toUpperCase() + c.slice(1),
    }));
    res.json({ categories: categoryList });
  } catch (err) {
    next(err);
  }
});

// PUT /support/tickets/:id/close
router.put('/tickets/:id/close', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const updates: Record<string, unknown> = {
      status: 'closed',
      resolvedAt: new Date(),
    };
    if (req.body.satisfaction_rating) updates.satisfactionRating = req.body.satisfaction_rating;
    if (req.body.satisfaction_feedback) updates.satisfactionFeedback = req.body.satisfaction_feedback;

    const ticket = await SupportTicket.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ ticket });
  } catch (err) {
    next(err);
  }
});

// PUT /support/tickets/:id/reopen
router.put('/tickets/:id/reopen', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ticket = await SupportTicket.findByIdAndUpdate(
      req.params.id,
      { status: 'open', resolvedAt: null },
      { new: true }
    );
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ ticket });
  } catch (err) {
    next(err);
  }
});

// PUT /support/tickets/:id/status
router.put('/tickets/:id/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status } = req.body;
    const updates: Record<string, unknown> = { status };
    if (status === 'resolved' || status === 'closed') updates.resolvedAt = new Date();

    const ticket = await SupportTicket.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ ticket });
  } catch (err) {
    next(err);
  }
});

// GET /support/tickets/:id/messages
router.get('/tickets/:id/messages', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ticket = await SupportTicket.findById(req.params.id);
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ messages: (ticket as any).messages || [] });
  } catch (err) {
    next(err);
  }
});

// POST /support/tickets/:id/attachments
router.post('/tickets/:id/attachments', authenticate, async (req: Request, res: Response) => {
  // Stub: accept attachment metadata
  res.json({ url: '', success: true });
});

// GET /support/tickets/count
router.get('/tickets/count', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status } = req.query;
    const filter: Record<string, unknown> = { raisedById: req.user!.id, raisedByRole: req.user!.role };
    if (status) filter.status = status;
    const count = await SupportTicket.countDocuments(filter);
    res.json({ count });
  } catch (err) {
    next(err);
  }
});

export default router;
