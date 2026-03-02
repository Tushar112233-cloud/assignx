import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { Expert, ExpertBooking } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /experts
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { specialization, search } = req.query;
    const filter: Record<string, unknown> = { isActive: true };
    if (specialization) filter.specialization = specialization;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { specialization: { $regex: search, $options: 'i' } },
      ];
    }

    const experts = await Expert.find(filter).sort({ rating: -1 });
    res.json({ experts });
  } catch (err) {
    next(err);
  }
});

// POST /experts/bookings (must be before /:id)
router.post('/bookings', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const booking = await ExpertBooking.create({
      ...req.body,
      userId: req.user!.id,
    });
    res.status(201).json({ booking });
  } catch (err) {
    next(err);
  }
});

// GET /experts/bookings/me (must be before /:id)
router.get('/bookings/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const bookings = await ExpertBooking.find({ userId: req.user!.id })
      .populate('expertId')
      .sort({ date: -1 });
    res.json({ bookings });
  } catch (err) {
    next(err);
  }
});

// GET /experts/:id
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const expert = await Expert.findById(req.params.id);
    if (!expert) throw new AppError('Expert not found', 404);
    res.json({ expert });
  } catch (err) {
    next(err);
  }
});

// POST /experts/:id/review
router.post('/:id/review', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { rating, review, bookingId } = req.body;

    if (bookingId) {
      await ExpertBooking.findByIdAndUpdate(bookingId, { rating, review });
    }

    const expert = await Expert.findById(req.params.id);
    if (!expert) throw new AppError('Expert not found', 404);

    const newTotal = expert.totalReviews + 1;
    const newRating = ((expert.rating * expert.totalReviews) + rating) / newTotal;
    expert.rating = Math.round(newRating * 10) / 10;
    expert.totalReviews = newTotal;
    await expert.save();

    res.json({ expert });
  } catch (err) {
    next(err);
  }
});

export default router;
