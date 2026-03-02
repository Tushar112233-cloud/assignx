import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { TrainingModule } from '../models';

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

// GET /resources/tools - List all tools (stub)
router.get('/tools', authenticate, async (_req: Request, res: Response) => {
  // Tools are not yet stored in the database; return default set
  res.json({
    tools: [
      { id: 'tool_1', name: 'Plagiarism Checker', type: 'plagiarism', description: 'Check assignments for plagiarism against billions of sources.', url: 'https://www.turnitin.com', isExternal: true, isPremium: false, usageCount: 0 },
      { id: 'tool_2', name: 'AI Content Detector', type: 'ai_detector', description: 'Detect AI-generated content in student submissions.', url: 'https://gptzero.me', isExternal: true, isPremium: false, usageCount: 0 },
      { id: 'tool_3', name: 'Grammarly', type: 'grammar', description: 'Advanced grammar and writing style checker.', url: 'https://app.grammarly.com', isExternal: true, isPremium: true, usageCount: 0 },
      { id: 'tool_4', name: 'Citation Generator', type: 'citation', description: 'Generate APA, MLA, Chicago citations automatically.', url: 'https://www.citationmachine.net', isExternal: true, isPremium: false, usageCount: 0 },
      { id: 'tool_5', name: 'Zotero', type: 'reference', description: 'Organize and manage your research references.', url: 'https://www.zotero.org/user/login', isExternal: true, isPremium: false, usageCount: 0 },
      { id: 'tool_6', name: 'Word Count Calculator', type: 'calculator', description: 'Calculate pages, words, and pricing for projects.', isExternal: false, isPremium: false, usageCount: 0 },
    ],
  });
});

// GET /resources/tools/:id - Get a specific tool (stub)
router.get('/tools/:id', authenticate, async (req: Request, res: Response) => {
  res.json({ id: req.params.id, name: 'Tool', type: 'plagiarism', description: '', url: '', isExternal: true, isPremium: false, usageCount: 0 });
});

// POST /resources/tools/:id/track - Track tool usage (stub)
router.post('/tools/:id/track', authenticate, async (_req: Request, res: Response) => {
  res.json({ success: true });
});

// ---------- TRAINING VIDEOS ----------

// GET /resources/training - List training videos (stub)
router.get('/training', authenticate, async (_req: Request, res: Response) => {
  // Return empty list; actual videos would be stored in a collection
  res.json({ videos: [] });
});

// GET /resources/training/:id - Get a specific training video (stub)
router.get('/training/:id', authenticate, async (req: Request, res: Response) => {
  res.json({ id: req.params.id, title: '', description: '', category: 'qc_basics', thumbnailUrl: '', videoUrl: '', duration: 0 });
});

// PUT /resources/training/:id/progress - Update watch progress (stub)
router.put('/training/:id/progress', authenticate, async (_req: Request, res: Response) => {
  res.json({ success: true });
});

// ---------- PRICING ----------

// GET /resources/pricing - Get pricing guide (stub)
router.get('/pricing', authenticate, async (_req: Request, res: Response) => {
  // Return default pricing data
  res.json({
    pricings: [
      { id: 'price_1', workType: 'essay', work_type: 'essay', academicLevel: 'high_school', academic_level: 'high_school', basePrice: 12.00, base_price: 12.00, description: 'Standard essay, high school level' },
      { id: 'price_2', workType: 'essay', work_type: 'essay', academicLevel: 'undergraduate', academic_level: 'undergraduate', basePrice: 15.00, base_price: 15.00, description: 'Standard essay, undergraduate level' },
      { id: 'price_3', workType: 'essay', work_type: 'essay', academicLevel: 'masters', academic_level: 'masters', basePrice: 20.00, base_price: 20.00, description: 'Standard essay, masters level' },
      { id: 'price_4', workType: 'essay', work_type: 'essay', academicLevel: 'phd', academic_level: 'phd', basePrice: 25.00, base_price: 25.00, description: 'Standard essay, PhD level' },
      { id: 'price_5', workType: 'research_paper', work_type: 'research_paper', academicLevel: 'undergraduate', academic_level: 'undergraduate', basePrice: 18.00, base_price: 18.00, description: 'Research paper with citations' },
      { id: 'price_6', workType: 'research_paper', work_type: 'research_paper', academicLevel: 'masters', academic_level: 'masters', basePrice: 24.00, base_price: 24.00, description: 'Research paper, masters level' },
      { id: 'price_7', workType: 'thesis', work_type: 'thesis', academicLevel: 'masters', academic_level: 'masters', basePrice: 28.00, base_price: 28.00, description: 'Masters thesis' },
      { id: 'price_8', workType: 'dissertation', work_type: 'dissertation', academicLevel: 'phd', academic_level: 'phd', basePrice: 35.00, base_price: 35.00, description: 'PhD dissertation' },
      { id: 'price_9', workType: 'editing', work_type: 'editing', academicLevel: 'undergraduate', academic_level: 'undergraduate', basePrice: 8.00, base_price: 8.00, description: 'Proofreading and editing per page' },
    ],
    currency: 'INR',
    notes: 'Prices are per page (275 words). Urgency multipliers apply.',
  });
});

export default router;
