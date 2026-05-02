import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { TrainingModule, TrainingProgress, AppSetting, LearningResource } from '../models';

const router = Router();

// GET /resources/learning - Learning resources (training modules)
router.get('/learning', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { is_active, sort } = req.query;
    const filter: Record<string, unknown> = {};
    if (is_active === 'true') filter.isActive = true;

    let sortObj: Record<string, 1 | -1> = { createdAt: -1 };
    if (sort === '-created_at') sortObj = { createdAt: -1 };
    else if (sort === 'created_at') sortObj = { createdAt: 1 };

    const modules = await TrainingModule.find(filter).sort(sortObj);
    res.json({ data: modules, total: modules.length });
  } catch (err) {
    next(err);
  }
});

// ---------- TOOLS ----------

// GET /resources/tools - List all tools from learning_resources collection
router.get('/tools', authenticate, async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const tools = await LearningResource.find({ isActive: true }).sort({ order: 1 });
    res.json({ tools });
  } catch (err) {
    next(err);
  }
});

// GET /resources/tools/:id - Get a specific tool
router.get('/tools/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tool = await LearningResource.findById(req.params.id);
    if (!tool) return res.status(404).json({ error: 'Tool not found' });
    res.json({ tool });
  } catch (err) {
    next(err);
  }
});

// POST /resources/tools/:id/track - Track tool usage (no-op for now)
router.post('/tools/:id/track', authenticate, async (_req: Request, res: Response) => {
  res.json({ success: true });
});

// ---------- TRAINING VIDEOS ----------

// GET /resources/training - List training videos from training_modules collection
router.get('/training', authenticate, async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const modules = await TrainingModule.find({ isActive: true }).sort({ order: 1 });
    res.json({ videos: modules });
  } catch (err) {
    next(err);
  }
});

// GET /resources/training/:id - Get a specific training video
router.get('/training/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const module = await TrainingModule.findById(req.params.id);
    if (!module) return res.status(404).json({ error: 'Training module not found' });
    res.json({ video: module });
  } catch (err) {
    next(err);
  }
});

// PUT /resources/training/:id/progress - Update watch progress
router.put('/training/:id/progress', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { progress, completed } = req.body;
    const userId = req.user!.id;
    const userRole = req.user!.role as 'doer' | 'supervisor';
    const moduleId = req.params.id;

    const update: Record<string, unknown> = { lastAccessedAt: new Date() };
    if (typeof progress === 'number') update.progress = progress;
    if (typeof completed === 'boolean') {
      update.completed = completed;
      if (completed) update.completedAt = new Date();
    }

    const record = await TrainingProgress.findOneAndUpdate(
      { userId, userRole, moduleId },
      { $set: update },
      { upsert: true, new: true }
    );
    res.json({ success: true, progress: record });
  } catch (err) {
    next(err);
  }
});

// ---------- PRICING ----------

// GET /resources/pricing - Get project pricing config from app_settings
router.get('/pricing', authenticate, async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [projectPricing, quotePricing, turnitinPricing] = await Promise.all([
      AppSetting.findOne({ key: 'project_pricing' }),
      AppSetting.findOne({ key: 'quote_pricing' }),
      AppSetting.findOne({ key: 'turnitin_pricing' }),
    ]);

    res.json({
      project_pricing: projectPricing?.value ?? {},
      quote_pricing: quotePricing?.value ?? {},
      turnitin_pricing: turnitinPricing?.value ?? {},
      currency: 'INR',
    });
  } catch (err) {
    next(err);
  }
});

export default router;
