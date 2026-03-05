import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { TrainingModule, TrainingProgress, QuizQuestion, QuizAttempt, Doer } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /training/modules
router.get('/modules', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { role } = req.query;
    const filter: Record<string, unknown> = { isActive: true };
    if (role) {
      filter.$or = [{ targetRole: role }, { targetRole: 'all' }];
    }

    const modules = await TrainingModule.find(filter).sort({ order: 1 });
    res.json({ modules });
  } catch (err) {
    next(err);
  }
});

// GET /training/progress
router.get('/progress', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const progress = await TrainingProgress.find({ userId: req.user!.id, userRole: req.user!.role })
      .populate('moduleId');
    res.json({ progress });
  } catch (err) {
    next(err);
  }
});

// PUT /training/progress/:moduleId
router.put('/progress/:moduleId', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const updates: Record<string, unknown> = {
      progress: req.body.progress,
      lastAccessedAt: new Date(),
      userRole: req.user!.role,
    };
    if (req.body.progress >= 100) {
      updates.completed = true;
      updates.completedAt = new Date();
    }

    const progress = await TrainingProgress.findOneAndUpdate(
      { userId: req.user!.id, userRole: req.user!.role, moduleId: req.params.moduleId },
      updates,
      { new: true, upsert: true }
    );
    res.json({ progress });
  } catch (err) {
    next(err);
  }
});

// GET /training/quiz
router.get('/quiz', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { moduleId } = req.query;
    const filter: Record<string, unknown> = { isActive: true };
    if (moduleId) filter.moduleId = moduleId;

    const questions = await QuizQuestion.find(filter).sort({ order: 1 });
    // Don't send correctAnswer to client
    const sanitized = questions.map(q => ({
      _id: q._id,
      moduleId: q.moduleId,
      question: q.question,
      options: q.options,
      order: q.order,
    }));
    res.json({ questions: sanitized });
  } catch (err) {
    next(err);
  }
});

// POST /training/quiz/attempt
router.post('/quiz/attempt', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { moduleId, answers } = req.body;

    // Fetch correct answers
    const questions = await QuizQuestion.find({ moduleId, isActive: true });
    const questionMap = new Map(questions.map(q => [q._id.toString(), q.correctAnswer]));

    let correct = 0;
    const gradedAnswers = answers.map((a: { questionId: string; selectedAnswer: number }) => {
      const isCorrect = questionMap.get(a.questionId) === a.selectedAnswer;
      if (isCorrect) correct++;
      return { ...a, isCorrect };
    });

    const score = questions.length > 0 ? Math.round((correct / questions.length) * 100) : 0;
    const passed = score >= 70;

    const attempt = await QuizAttempt.create({
      userId: req.user!.id,
      userRole: req.user!.role,
      moduleId,
      answers: gradedAnswers,
      score,
      totalQuestions: questions.length,
      passed,
    });

    res.json({ attempt });
  } catch (err) {
    next(err);
  }
});

// GET /training/quiz/attempts
router.get('/quiz/attempts', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { moduleId } = req.query;
    const filter: Record<string, unknown> = { userId: req.user!.id, userRole: req.user!.role };
    if (moduleId) filter.moduleId = moduleId;

    const attempts = await QuizAttempt.find(filter).sort({ createdAt: -1 });
    res.json({ attempts });
  } catch (err) {
    next(err);
  }
});

// POST /training/complete - Mark all mandatory training as complete for the doer
router.post('/complete', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // JWT sub IS the doer _id now
    const doerId = req.user!.id;

    // Get all mandatory modules for doers
    const mandatoryModules = await TrainingModule.find({
      isActive: true,
      $or: [{ targetRole: 'doer' }, { targetRole: 'all' }],
    });

    // If there are mandatory modules, verify all are completed
    if (mandatoryModules.length > 0) {
      const completedProgress = await TrainingProgress.find({
        userId: doerId,
        userRole: req.user!.role,
        completed: true,
        moduleId: { $in: mandatoryModules.map(m => m._id) },
      });

      if (completedProgress.length < mandatoryModules.length) {
        throw new AppError(
          `You must complete all ${mandatoryModules.length} training modules. ${completedProgress.length} completed so far.`,
          400
        );
      }
    }

    // Update doer record — JWT sub IS the doer _id
    const doer = await Doer.findById(doerId);
    if (!doer) {
      throw new AppError('Doer profile not found.', 404);
    }

    doer.trainingCompleted = true;
    doer.trainingCompletedAt = new Date();
    await doer.save();

    res.json({ success: true, message: 'Training completed successfully!' });
  } catch (err) {
    next(err);
  }
});

// GET /training/status - Get training completion status for the current doer
router.get('/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // JWT sub IS the doer _id
    const doerId = req.user!.id;

    const doer = await Doer.findById(doerId);
    if (!doer) {
      throw new AppError('Doer profile not found.', 404);
    }

    // Get all mandatory modules
    const mandatoryModules = await TrainingModule.find({
      isActive: true,
      $or: [{ targetRole: 'doer' }, { targetRole: 'all' }],
    }).sort({ order: 1 });

    // Get progress for all modules
    const progress = await TrainingProgress.find({
      userId: doerId,
      userRole: req.user!.role,
      moduleId: { $in: mandatoryModules.map(m => m._id) },
    });

    const progressMap = new Map(progress.map(p => [p.moduleId.toString(), p]));

    const modules = mandatoryModules.map(m => ({
      id: m._id,
      title: m.title,
      description: m.description,
      videoUrl: m.videoUrl,
      thumbnailUrl: m.thumbnailUrl,
      duration: m.duration,
      category: m.category,
      order: m.order,
      completed: progressMap.get(m._id.toString())?.completed || false,
      progress: progressMap.get(m._id.toString())?.progress || 0,
    }));

    res.json({
      trainingCompleted: doer.trainingCompleted,
      totalModules: mandatoryModules.length,
      completedModules: progress.filter(p => p.completed).length,
      modules,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
