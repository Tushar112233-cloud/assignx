import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { Investor, PitchDeck } from '../models';
import { IInvestor } from '../models/Investor';
import { IPitchDeck } from '../models/PitchDeck';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// --- Normalize helpers ---

function formatTicketSize(investor: IInvestor): string {
  if (!investor.ticketSize) return 'Undisclosed';
  const { min, max, currency } = investor.ticketSize;
  const fmt = (n: number) => {
    if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(n % 1_000_000 === 0 ? 0 : 1)}M`;
    if (n >= 1_000) return `${(n / 1_000).toFixed(n % 1_000 === 0 ? 0 : 0)}K`;
    return String(n);
  };
  return `${currency === 'INR' ? '\u20B9' : '$'}${fmt(min)} - ${currency === 'INR' ? '\u20B9' : '$'}${fmt(max)}`;
}

function normalizeInvestor(investor: IInvestor) {
  return {
    id: investor._id,
    _id: investor._id,
    name: investor.name,
    firm: investor.firm,
    avatar: investor.avatarUrl || null,
    avatar_url: investor.avatarUrl || null,
    bio: investor.bio,
    funding_stages: investor.fundingStages,
    fundingStages: investor.fundingStages,
    sectors: investor.sectors,
    ticket_size: investor.ticketSize || null,
    ticketSize: formatTicketSize(investor),
    ticket_size_formatted: formatTicketSize(investor),
    deal_count: investor.dealCount,
    dealCount: investor.dealCount,
    portfolio: investor.dealCount,
    linkedin_url: investor.linkedinUrl || null,
    linkedinUrl: investor.linkedinUrl || null,
    website_url: investor.websiteUrl || null,
    websiteUrl: investor.websiteUrl || null,
    contact_email: investor.contactEmail || null,
    contactEmail: investor.contactEmail || null,
    is_active: investor.isActive,
    isActive: investor.isActive,
    added_by: investor.addedBy,
    created_at: investor.createdAt,
    updated_at: investor.updatedAt,
  };
}

function normalizePitchDeck(deck: IPitchDeck) {
  const userObj = deck.userId as any;
  const investorObj = deck.investorId as any;
  return {
    id: deck._id,
    _id: deck._id,
    user_id: userObj?._id || deck.userId,
    userId: userObj?._id || deck.userId,
    submitter_name: userObj?.fullName || userObj?.name || null,
    submitter_email: userObj?.email || null,
    investor_name: investorObj?.name || null,
    investor_firm: investorObj?.firm || null,
    title: deck.title,
    name: deck.title,
    description: deck.description || null,
    file_url: deck.fileUrl,
    fileUrl: deck.fileUrl,
    investor_id: investorObj?._id || deck.investorId || null,
    investorId: investorObj?._id || deck.investorId || null,
    status: deck.status,
    feedback: deck.feedback || null,
    uploaded_at: deck.createdAt,
    uploadedAt: deck.createdAt,
    created_at: deck.createdAt,
    updated_at: deck.updatedAt,
  };
}

// ============================================================================
// Pitch Deck Routes (must be before /:id to avoid route conflicts)
// ============================================================================

// POST /investors/pitch-decks - upload pitch deck (authenticated)
router.post('/pitch-decks', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    const { title, description, fileUrl, investorId } = req.body;

    if (!title || !fileUrl) {
      throw new AppError('title and fileUrl are required', 400);
    }

    const deck = await PitchDeck.create({
      userId: user.id,
      title,
      description,
      fileUrl,
      investorId: investorId || undefined,
      status: 'pending',
    });

    res.status(201).json({ pitchDeck: normalizePitchDeck(deck as IPitchDeck) });
  } catch (err) {
    next(err);
  }
});

// GET /investors/pitch-decks/my - get user's pitch decks
router.get('/pitch-decks/my', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    const decks = await PitchDeck.find({ userId: user.id }).sort({ createdAt: -1 });

    res.json({
      pitchDecks: decks.map((d) => normalizePitchDeck(d as IPitchDeck)),
    });
  } catch (err) {
    next(err);
  }
});

// GET /investors/pitch-decks/all - get all pitch decks (admin only)
router.get('/pitch-decks/all', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const { status, page: pageParam, perPage: perPageParam } = req.query;
    const filter: Record<string, unknown> = {};
    if (status && status !== 'all') filter.status = status;

    const page = Math.max(1, parseInt(pageParam as string) || 1);
    const perPage = Math.min(100, Math.max(1, parseInt(perPageParam as string) || 50));
    const skip = (page - 1) * perPage;

    const [decks, total] = await Promise.all([
      PitchDeck.find(filter)
        .populate('userId', 'fullName email')
        .populate('investorId', 'name firm')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(perPage),
      PitchDeck.countDocuments(filter),
    ]);

    res.json({
      pitchDecks: decks.map((d) => normalizePitchDeck(d as IPitchDeck)),
      total,
      page,
      totalPages: Math.ceil(total / perPage),
    });
  } catch (err) {
    next(err);
  }
});

// PUT /investors/pitch-decks/:id/status - update pitch deck status (admin only)
router.put('/pitch-decks/:id/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const { status, feedback } = req.body;
    if (!status || !['pending', 'reviewed', 'shortlisted', 'rejected'].includes(status)) {
      throw new AppError('Valid status is required (pending, reviewed, shortlisted, rejected)', 400);
    }

    const updates: Record<string, unknown> = { status };
    if (feedback !== undefined) updates.feedback = feedback;

    const deck = await PitchDeck.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!deck) throw new AppError('Pitch deck not found', 404);

    res.json({ pitchDeck: normalizePitchDeck(deck as IPitchDeck) });
  } catch (err) {
    next(err);
  }
});

// GET /investors/pitch-decks/by-investor/:investorId - pitch decks for a specific investor (admin only)
router.get('/pitch-decks/by-investor/:investorId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const investor = await Investor.findById(req.params.investorId);
    if (!investor) throw new AppError('Investor not found', 404);

    const decks = await PitchDeck.find({ investorId: req.params.investorId })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 });

    const normalized = decks.map((d: any) => ({
      id: d._id,
      _id: d._id,
      user_id: d.userId?._id || d.userId,
      submitter_name: d.userId?.fullName || 'Unknown',
      submitter_email: d.userId?.email || '',
      title: d.title,
      description: d.description || null,
      file_url: d.fileUrl,
      investor_id: d.investorId,
      status: d.status,
      feedback: d.feedback || null,
      created_at: d.createdAt,
      updated_at: d.updatedAt,
    }));

    res.json({
      pitchDecks: normalized,
      total: normalized.length,
    });
  } catch (err) {
    next(err);
  }
});

// ============================================================================
// Investor Routes
// ============================================================================

// GET /investors - list investors (authenticated, with filters)
router.get('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { stage, sector, search, page: pageParam, perPage: perPageParam } = req.query;

    const filter: Record<string, unknown> = { isActive: true };

    if (stage && stage !== 'all') {
      filter.fundingStages = stage;
    }
    if (sector && sector !== 'All') {
      filter.sectors = sector;
    }
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { firm: { $regex: search, $options: 'i' } },
        { bio: { $regex: search, $options: 'i' } },
      ];
    }

    const page = Math.max(1, parseInt(pageParam as string) || 1);
    const perPage = Math.min(100, Math.max(1, parseInt(perPageParam as string) || 50));
    const skip = (page - 1) * perPage;

    const [investors, total] = await Promise.all([
      Investor.find(filter).sort({ dealCount: -1, createdAt: -1 }).skip(skip).limit(perPage),
      Investor.countDocuments(filter),
    ]);

    const totalPages = Math.ceil(total / perPage);

    res.json({
      investors: investors.map((inv) => normalizeInvestor(inv as IInvestor)),
      total,
      page,
      totalPages,
    });
  } catch (err) {
    next(err);
  }
});

// GET /investors/stats - stats for hero section
router.get('/stats', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [activeInvestors, totalDecks, shortlistedDecks] = await Promise.all([
      Investor.countDocuments({ isActive: true }),
      PitchDeck.countDocuments(),
      PitchDeck.countDocuments({ status: 'shortlisted' }),
    ]);

    res.json({
      activeInvestors,
      totalDecks,
      fundedStartups: shortlistedDecks,
    });
  } catch (err) {
    next(err);
  }
});

// GET /investors/:id - single investor (must be after all /investors/... routes)
router.get('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const investor = await Investor.findById(req.params.id);
    if (!investor) throw new AppError('Investor not found', 404);
    res.json({ investor: normalizeInvestor(investor as IInvestor) });
  } catch (err) {
    next(err);
  }
});

// POST /investors - create investor (admin only)
router.post('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const {
      name, firm, avatarUrl, bio, fundingStages, sectors,
      ticketSize, dealCount, linkedinUrl, websiteUrl, contactEmail,
    } = req.body;

    if (!name || !firm || !bio || !fundingStages?.length || !sectors?.length) {
      throw new AppError('name, firm, bio, fundingStages, and sectors are required', 400);
    }

    const investor = await Investor.create({
      name,
      firm,
      avatarUrl,
      bio,
      fundingStages,
      sectors,
      ticketSize: ticketSize || undefined,
      dealCount: dealCount || 0,
      linkedinUrl,
      websiteUrl,
      contactEmail,
      addedBy: user.id,
    });

    res.status(201).json({ investor: normalizeInvestor(investor as IInvestor) });
  } catch (err) {
    next(err);
  }
});

// PUT /investors/:id - update investor (admin only)
router.put('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const allowedFields = [
      'name', 'firm', 'avatarUrl', 'bio', 'fundingStages', 'sectors',
      'ticketSize', 'dealCount', 'linkedinUrl', 'websiteUrl', 'contactEmail', 'isActive',
    ];

    const updates: Record<string, unknown> = {};
    for (const key of allowedFields) {
      if (req.body[key] !== undefined) {
        updates[key] = req.body[key];
      }
    }

    const investor = await Investor.findByIdAndUpdate(req.params.id, updates, { new: true, runValidators: true });
    if (!investor) throw new AppError('Investor not found', 404);

    res.json({ investor: normalizeInvestor(investor as IInvestor) });
  } catch (err) {
    next(err);
  }
});

// DELETE /investors/:id - deactivate investor (admin only, soft delete)
router.delete('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const investor = await Investor.findByIdAndUpdate(req.params.id, { isActive: false }, { new: true });
    if (!investor) throw new AppError('Investor not found', 404);

    res.json({ message: 'Investor deactivated', investor: normalizeInvestor(investor as IInvestor) });
  } catch (err) {
    next(err);
  }
});

export default router;
