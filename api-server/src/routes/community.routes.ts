import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { optionalAuth } from '../middleware/auth';
import { CommunityPost, PostInteraction } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /community/posts
router.get('/posts', optionalAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', postType, category, search } = req.query;
    const filter: Record<string, unknown> = { isActive: true };
    if (postType) filter.postType = postType;
    if (category) filter.category = category;
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    const [posts, total] = await Promise.all([
      CommunityPost.find(filter)
        .populate('userId', 'fullName avatarUrl')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      CommunityPost.countDocuments(filter),
    ]);

    // If user is logged in, check their interactions
    let userInteractions: Record<string, string[]> = {};
    if (req.user) {
      const postIds = posts.map(p => p._id);
      const interactions = await PostInteraction.find({
        postId: { $in: postIds },
        userId: req.user.id,
      });
      for (const i of interactions) {
        const key = i.postId.toString();
        if (!userInteractions[key]) userInteractions[key] = [];
        userInteractions[key].push(i.type);
      }
    }

    res.json({ posts, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)), userInteractions });
  } catch (err) {
    next(err);
  }
});

// GET /community/posts/saved (must be before /:id)
router.get('/posts/saved', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const saves = await PostInteraction.find({ userId: req.user!.id, type: 'save' });
    const postIds = saves.map(s => s.postId);

    const posts = await CommunityPost.find({ _id: { $in: postIds }, isActive: true })
      .populate('userId', 'fullName avatarUrl')
      .sort({ createdAt: -1 });

    res.json({ posts });
  } catch (err) {
    next(err);
  }
});

// POST /community/posts
router.post('/posts', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.create({
      userId: req.user!.id,
      postType: req.body.postType,
      title: req.body.title,
      content: req.body.content,
      imageUrl: req.body.imageUrl,
      category: req.body.category,
      tags: req.body.tags || [],
    });
    res.status(201).json({ post });
  } catch (err) {
    next(err);
  }
});

// GET /community/posts/:id
router.get('/posts/:id', optionalAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.findByIdAndUpdate(
      req.params.id,
      { $inc: { viewCount: 1 } },
      { new: true }
    ).populate('userId', 'fullName avatarUrl')
     .populate('comments.userId', 'fullName avatarUrl');

    if (!post) throw new AppError('Post not found', 404);

    let userInteraction: string[] = [];
    if (req.user) {
      const interactions = await PostInteraction.find({ postId: post._id, userId: req.user.id });
      userInteraction = interactions.map(i => i.type);
    }

    res.json({ post, userInteraction });
  } catch (err) {
    next(err);
  }
});

// PUT /community/posts/:id
router.put('/posts/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.findOneAndUpdate(
      { _id: req.params.id, userId: req.user!.id },
      req.body,
      { new: true }
    );
    if (!post) throw new AppError('Post not found or unauthorized', 404);
    res.json({ post });
  } catch (err) {
    next(err);
  }
});

// DELETE /community/posts/:id
router.delete('/posts/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const filter: Record<string, unknown> = { _id: req.params.id };
    if (req.user!.role !== 'admin') filter.userId = req.user!.id;

    const post = await CommunityPost.findOneAndUpdate(filter, { isActive: false }, { new: true });
    if (!post) throw new AppError('Post not found or unauthorized', 404);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// POST /community/posts/:id/like
router.post('/posts/:id/like', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const existing = await PostInteraction.findOne({
      postId: req.params.id,
      userId: req.user!.id,
      type: 'like',
    });

    if (existing) {
      await PostInteraction.deleteOne({ _id: existing._id });
      await CommunityPost.findByIdAndUpdate(req.params.id, { $inc: { likeCount: -1 } });
      return res.json({ liked: false });
    }

    await PostInteraction.create({ postId: req.params.id, userId: req.user!.id, type: 'like' });
    await CommunityPost.findByIdAndUpdate(req.params.id, { $inc: { likeCount: 1 } });
    res.json({ liked: true });
  } catch (err) {
    next(err);
  }
});

// POST /community/posts/:id/save
router.post('/posts/:id/save', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const existing = await PostInteraction.findOne({
      postId: req.params.id,
      userId: req.user!.id,
      type: 'save',
    });

    if (existing) {
      await PostInteraction.deleteOne({ _id: existing._id });
      await CommunityPost.findByIdAndUpdate(req.params.id, { $inc: { saveCount: -1 } });
      return res.json({ saved: false });
    }

    await PostInteraction.create({ postId: req.params.id, userId: req.user!.id, type: 'save' });
    await CommunityPost.findByIdAndUpdate(req.params.id, { $inc: { saveCount: 1 } });
    res.json({ saved: true });
  } catch (err) {
    next(err);
  }
});

// POST /community/posts/:id/comments
router.post('/posts/:id/comments', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.findByIdAndUpdate(
      req.params.id,
      {
        $push: {
          comments: {
            userId: req.user!.id,
            content: req.body.content,
            parentId: req.body.parentId,
            createdAt: new Date(),
          },
        },
        $inc: { commentCount: 1 },
      },
      { new: true }
    ).populate('comments.userId', 'fullName avatarUrl');

    if (!post) throw new AppError('Post not found', 404);
    res.json({ post });
  } catch (err) {
    next(err);
  }
});

// POST /community/posts/:id/report
router.post('/posts/:id/report', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.findByIdAndUpdate(req.params.id, { isFlagged: true }, { new: true });
    if (!post) throw new AppError('Post not found', 404);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// ============================================================
// Pro Network stub endpoints
// ============================================================

// GET /community/pro-network
router.get('/pro-network', optionalAuth, async (_req: Request, res: Response) => {
  res.json({ posts: [], total: 0, page: 1, totalPages: 0 });
});

// GET /community/pro-network/saved
router.get('/pro-network/saved', authenticate, async (_req: Request, res: Response) => {
  res.json({ posts: [] });
});

// GET /community/pro-network/:id
router.get('/pro-network/:id', optionalAuth, async (req: Request, res: Response) => {
  res.status(404).json({ error: 'Pro network post not found' });
});

// POST /community/pro-network
router.post('/pro-network', authenticate, async (req: Request, res: Response) => {
  // Stub: return the posted data as a created post
  res.status(201).json({
    _id: Date.now().toString(),
    ...req.body,
    userId: req.user!.id,
    likeCount: 0,
    commentCount: 0,
    createdAt: new Date().toISOString(),
  });
});

// POST /community/pro-network/:id/like
router.post('/pro-network/:id/like', authenticate, async (_req: Request, res: Response) => {
  res.json({ liked: true });
});

// POST /community/pro-network/:id/save
router.post('/pro-network/:id/save', authenticate, async (_req: Request, res: Response) => {
  res.json({ saved: true });
});

// ============================================================
// Business Hub stub endpoints
// ============================================================

// GET /community/business-hub
router.get('/business-hub', optionalAuth, async (_req: Request, res: Response) => {
  res.json({ posts: [], total: 0, page: 1, totalPages: 0 });
});

// GET /community/business-hub/saved
router.get('/business-hub/saved', authenticate, async (_req: Request, res: Response) => {
  res.json({ posts: [] });
});

// GET /community/business-hub/:id
router.get('/business-hub/:id', optionalAuth, async (req: Request, res: Response) => {
  res.status(404).json({ error: 'Business hub post not found' });
});

// POST /community/business-hub
router.post('/business-hub', authenticate, async (req: Request, res: Response) => {
  res.status(201).json({
    _id: Date.now().toString(),
    ...req.body,
    userId: req.user!.id,
    likeCount: 0,
    commentCount: 0,
    createdAt: new Date().toISOString(),
  });
});

// POST /community/business-hub/:id/like
router.post('/business-hub/:id/like', authenticate, async (_req: Request, res: Response) => {
  res.json({ liked: true });
});

// POST /community/business-hub/:id/save
router.post('/business-hub/:id/save', authenticate, async (_req: Request, res: Response) => {
  res.json({ saved: true });
});

export default router;
