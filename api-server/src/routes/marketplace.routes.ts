import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { optionalAuth } from '../middleware/auth';
import { MarketplaceListing, MarketplaceCategory, PostInteraction } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /marketplace/listings
router.get('/listings', optionalAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', category, search, minPrice, maxPrice } = req.query;
    const filter: Record<string, unknown> = { isActive: true, status: 'active' };
    if (category) filter.categoryId = category;
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) (filter.price as Record<string, number>).$gte = Number(minPrice);
      if (maxPrice) (filter.price as Record<string, number>).$lte = Number(maxPrice);
    }

    const skip = (Number(page) - 1) * Number(limit);
    const [listings, total] = await Promise.all([
      MarketplaceListing.find(filter)
        .populate('userId', 'fullName avatarUrl')
        .populate('categoryId', 'name')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      MarketplaceListing.countDocuments(filter),
    ]);

    res.json({ listings, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// POST /marketplace/listings
router.post('/listings', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const listing = await MarketplaceListing.create({
      ...req.body,
      userId: req.user!.id,
    });
    res.status(201).json({ listing });
  } catch (err) {
    next(err);
  }
});

// GET /marketplace/listings/:id
router.get('/listings/:id', optionalAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const listing = await MarketplaceListing.findByIdAndUpdate(
      req.params.id,
      { $inc: { viewCount: 1 } },
      { new: true }
    )
      .populate('userId', 'fullName avatarUrl')
      .populate('categoryId', 'name');

    if (!listing) throw new AppError('Listing not found', 404);
    res.json({ listing });
  } catch (err) {
    next(err);
  }
});

// PUT /marketplace/listings/:id
router.put('/listings/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const listing = await MarketplaceListing.findOneAndUpdate(
      { _id: req.params.id, userId: req.user!.id },
      req.body,
      { new: true }
    );
    if (!listing) throw new AppError('Listing not found or unauthorized', 404);
    res.json({ listing });
  } catch (err) {
    next(err);
  }
});

// DELETE /marketplace/listings/:id
router.delete('/listings/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const listing = await MarketplaceListing.findOneAndUpdate(
      { _id: req.params.id, userId: req.user!.id },
      { isActive: false, status: 'removed' },
      { new: true }
    );
    if (!listing) throw new AppError('Listing not found or unauthorized', 404);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// POST /marketplace/listings/:id/favorite
router.post('/listings/:id/favorite', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const existing = await PostInteraction.findOne({
      postId: req.params.id,
      userId: req.user!.id,
      type: 'save',
    });

    if (existing) {
      await PostInteraction.deleteOne({ _id: existing._id });
      await MarketplaceListing.findByIdAndUpdate(req.params.id, { $inc: { favoriteCount: -1 } });
      return res.json({ favorited: false });
    }

    await PostInteraction.create({ postId: req.params.id, userId: req.user!.id, type: 'save' });
    await MarketplaceListing.findByIdAndUpdate(req.params.id, { $inc: { favoriteCount: 1 } });
    res.json({ favorited: true });
  } catch (err) {
    next(err);
  }
});

// GET /marketplace/favorites
router.get('/favorites', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const saves = await PostInteraction.find({ userId: req.user!.id, type: 'save' });
    const ids = saves.map(s => s.postId);

    const listings = await MarketplaceListing.find({ _id: { $in: ids }, isActive: true })
      .populate('userId', 'fullName avatarUrl')
      .populate('categoryId', 'name');

    res.json({ listings });
  } catch (err) {
    next(err);
  }
});

// GET /marketplace/categories
router.get('/categories', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const categories = await MarketplaceCategory.find({ isActive: true }).sort({ order: 1 });
    res.json({ categories });
  } catch (err) {
    next(err);
  }
});

// ============================================================
// Tutor stub endpoints
// ============================================================

// GET /marketplace/tutors
router.get('/tutors', optionalAuth, async (_req: Request, res: Response) => {
  res.json({ tutors: [], total: 0 });
});

// GET /marketplace/tutors/:id
router.get('/tutors/:id', optionalAuth, async (req: Request, res: Response) => {
  res.status(404).json({ error: 'Tutor not found' });
});

// POST /marketplace/tutors/:id/book
router.post('/tutors/:id/book', authenticate, async (req: Request, res: Response) => {
  res.status(201).json({
    _id: Date.now().toString(),
    ...req.body,
    userId: req.user!.id,
    expertId: req.params.id,
    status: 'pending',
    createdAt: new Date().toISOString(),
  });
});

// GET /marketplace/tutors/:id/reviews
router.get('/tutors/:id/reviews', optionalAuth, async (_req: Request, res: Response) => {
  res.json({ reviews: [], total: 0 });
});

// POST /marketplace/tutors/:id/reviews
router.post('/tutors/:id/reviews', authenticate, async (req: Request, res: Response) => {
  res.status(201).json({
    _id: Date.now().toString(),
    ...req.body,
    userId: req.user!.id,
    expertId: req.params.id,
    createdAt: new Date().toISOString(),
  });
});

// ============================================================
// Session stub endpoints
// ============================================================

// GET /marketplace/sessions
router.get('/sessions', authenticate, async (_req: Request, res: Response) => {
  res.json({ sessions: [], total: 0 });
});

export default router;
