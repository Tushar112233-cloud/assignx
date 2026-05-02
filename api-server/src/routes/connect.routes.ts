import { Router, Request, Response, NextFunction } from 'express';
import { authenticate, optionalAuth } from '../middleware/auth';
import { CommunityPost, PostInteraction } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Helper: normalize imageUrls for backward compat
function normalizePost(post: any) {
  if (!post) return post;
  const obj = typeof post.toObject === 'function' ? post.toObject() : { ...post };
  const urls = obj.imageUrls || [];
  obj.imageUrls = urls;
  obj.imageUrl = urls.length > 0 ? urls[0] : null;
  return obj;
}

function normalizePosts(posts: any[]) {
  return posts.map(normalizePost);
}

// ============================================================
// Q&A endpoints for Connect feature (backed by CommunityPost)
// ============================================================

// GET /connect/questions
router.get('/questions', optionalAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', search, tag } = req.query;
    const filter: Record<string, unknown> = { isActive: true, postType: 'campus', category: 'questions' };
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
      ];
    }
    if (tag) {
      filter.tags = tag;
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

    // Map posts to question-like shape for the frontend
    const questions = normalizePosts(posts).map(p => ({
      ...p,
      authorId: p.userId,
      answerCount: p.commentCount || 0,
      isAnswered: (p.commentCount || 0) > 0,
      status: (p.commentCount || 0) > 0 ? 'answered' : 'open',
    }));

    let userInteractions: Record<string, string[]> = {};
    if (req.user) {
      const postIds = posts.map(p => p._id);
      const interactions = await PostInteraction.find({ postId: { $in: postIds }, userId: req.user.id });
      for (const i of interactions) {
        const key = i.postId.toString();
        if (!userInteractions[key]) userInteractions[key] = [];
        userInteractions[key].push(i.type);
      }
    }

    res.json({ questions, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)), userInteractions });
  } catch (err) {
    next(err);
  }
});

// GET /connect/questions/:id
router.get('/questions/:id', optionalAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.findByIdAndUpdate(
      req.params.id,
      { $inc: { viewCount: 1 } },
      { new: true }
    ).populate('userId', 'fullName avatarUrl')
     .populate('comments.userId', 'fullName avatarUrl');

    if (!post || post.category !== 'questions') throw new AppError('Question not found', 404);

    const normalized = normalizePost(post);
    const question = {
      ...normalized,
      authorId: normalized.userId,
      answerCount: normalized.commentCount || 0,
      answers: (normalized.comments || []).map((c: any) => ({
        ...c,
        authorId: c.userId,
        questionId: post._id,
        isAccepted: false,
      })),
      isAnswered: (normalized.commentCount || 0) > 0,
      status: (normalized.commentCount || 0) > 0 ? 'answered' : 'open',
    };

    let userInteraction: string[] = [];
    if (req.user) {
      const interactions = await PostInteraction.find({ postId: post._id, userId: req.user.id });
      userInteraction = interactions.map(i => i.type);
    }

    res.json({ question, userInteraction });
  } catch (err) {
    next(err);
  }
});

// POST /connect/questions
router.post('/questions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.create({
      userId: req.user!.id,
      postType: 'campus',
      category: 'questions',
      title: req.body.title,
      content: req.body.content,
      imageUrls: req.body.imageUrls || [],
      tags: req.body.tags || [],
    });

    const normalized = normalizePost(post);
    const question = {
      ...normalized,
      authorId: normalized.userId,
      answerCount: 0,
      isAnswered: false,
      status: 'open',
    };

    res.status(201).json({ question });
  } catch (err) {
    next(err);
  }
});

// POST /connect/questions/:id/answers
router.post('/questions/:id/answers', authenticate, async (req: Request, res: Response, next: NextFunction) => {
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

    if (!post) throw new AppError('Question not found', 404);

    // Return the newly added answer (last comment)
    const comments = post.comments || [];
    const lastComment = comments[comments.length - 1];
    const answer = lastComment ? {
      _id: (lastComment as any)._id,
      questionId: post._id,
      content: lastComment.content,
      authorId: lastComment.userId,
      createdAt: lastComment.createdAt,
      isAccepted: false,
      likeCount: 0,
    } : null;

    res.status(201).json({ answer });
  } catch (err) {
    next(err);
  }
});

// POST /connect/questions/:id/vote (like/unlike the question)
router.post('/questions/:id/vote', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const existing = await PostInteraction.findOne({
      postId: req.params.id,
      userId: req.user!.id,
      type: 'like',
    });

    if (existing) {
      await PostInteraction.deleteOne({ _id: existing._id });
      await CommunityPost.findByIdAndUpdate(req.params.id, { $inc: { likeCount: -1 } });
      return res.json({ voted: false });
    }

    await PostInteraction.create({ postId: req.params.id, userId: req.user!.id, type: 'like' });
    await CommunityPost.findByIdAndUpdate(req.params.id, { $inc: { likeCount: 1 } });
    res.json({ voted: true });
  } catch (err) {
    next(err);
  }
});

// POST /connect/questions/:id/accept (mark question as answered - only question author)
router.post('/questions/:id/accept', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const post = await CommunityPost.findById(req.params.id);
    if (!post) throw new AppError('Question not found', 404);
    if (post.userId.toString() !== req.user!.id) {
      throw new AppError('Only the question author can accept an answer', 403);
    }
    // For now, just acknowledge. Could store accepted answer ID in the future.
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// POST /connect/answers/:id/vote (stub - votes on individual answers not yet tracked separately)
router.post('/answers/:id/vote', authenticate, async (_req: Request, res: Response) => {
  res.json({ success: true });
});

export default router;
