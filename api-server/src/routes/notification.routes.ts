import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { Notification } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /notifications
router.get('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', unreadOnly } = req.query;
    const filter: Record<string, unknown> = { userId: req.user!.id };
    if (unreadOnly === 'true') filter.isRead = false;

    const skip = (Number(page) - 1) * Number(limit);
    const [notifications, total, unreadCount] = await Promise.all([
      Notification.find(filter).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      Notification.countDocuments(filter),
      Notification.countDocuments({ userId: req.user!.id, isRead: false }),
    ]);

    res.json({ notifications, total, unreadCount, page: Number(page) });
  } catch (err) {
    next(err);
  }
});

// PUT /notifications/:id/read
router.put('/:id/read', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user!.id },
      { isRead: true, readAt: new Date() },
      { new: true }
    );
    if (!notification) throw new AppError('Notification not found', 404);
    res.json({ notification });
  } catch (err) {
    next(err);
  }
});

// PUT /notifications/read-all
router.put('/read-all', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    await Notification.updateMany(
      { userId: req.user!.id, isRead: false },
      { isRead: true, readAt: new Date() }
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// GET /notifications/unread-count
router.get('/unread-count', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const count = await Notification.countDocuments({ userId: req.user!.id, isRead: false });
    res.json({ count });
  } catch (err) {
    next(err);
  }
});

// PUT /notifications/mark-all-read (alias for read-all)
router.put('/mark-all-read', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    await Notification.updateMany(
      { userId: req.user!.id, isRead: false },
      { isRead: true, readAt: new Date() }
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// DELETE /notifications/all
router.delete('/all', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    await Notification.deleteMany({ userId: req.user!.id });
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// DELETE /notifications/:id
router.delete('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await Notification.findOneAndDelete({ _id: req.params.id, userId: req.user!.id });
    if (!result) throw new AppError('Notification not found', 404);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

export default router;
