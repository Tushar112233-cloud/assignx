import { Router, Request, Response, NextFunction } from 'express';
import { Subject, Skill, University, ReferenceStyle } from '../models';

const router = Router();

// GET /subjects
router.get('/subjects', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const subjects = await Subject.find({ isActive: true }).sort({ name: 1 });
    res.json({ subjects });
  } catch (err) {
    next(err);
  }
});

// GET /skills
router.get('/skills', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const skills = await Skill.find({ isActive: true }).sort({ name: 1 });
    res.json({ skills });
  } catch (err) {
    next(err);
  }
});

// GET /universities
router.get('/universities', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const universities = await University.find({ isActive: true }).sort({ name: 1 });
    res.json({ universities });
  } catch (err) {
    next(err);
  }
});

// GET /reference-styles
router.get('/reference-styles', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const styles = await ReferenceStyle.find({ isActive: true }).sort({ name: 1 });
    res.json({ styles });
  } catch (err) {
    next(err);
  }
});

export default router;
