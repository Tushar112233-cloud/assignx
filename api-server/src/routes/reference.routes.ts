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

// Static courses data (no DB model — same data used by web frontend)
const COURSES = [
  { id: '3f8292eb-a246-4b04-b8a9-16c0d5f4c509', name: 'Bachelor of Arts', shortName: 'B.A.', category: 'Undergraduate' },
  { id: '74ee88ae-1b72-405f-b27d-9a28986b3a0c', name: 'Bachelor of Business Administration', shortName: 'BBA', category: 'Undergraduate' },
  { id: 'dc376ecf-4e26-4b05-bbdf-0443425bf510', name: 'Bachelor of Commerce', shortName: 'B.Com', category: 'Undergraduate' },
  { id: 'fc9d8418-23fa-4361-a1a0-49faf26f2b9d', name: 'Bachelor of Science', shortName: 'B.Sc', category: 'Undergraduate' },
  { id: '8804440a-a0a6-43fc-822a-415a33afbd8f', name: 'Bachelor of Technology', shortName: 'B.Tech', category: 'Undergraduate' },
  { id: 'eec06e8b-e9e8-4103-a1ec-7417a7d5d465', name: 'Master of Arts', shortName: 'M.A.', category: 'Postgraduate' },
  { id: '16219f4b-7df1-4834-ab21-85f2675c7278', name: 'Master of Business Administration', shortName: 'MBA', category: 'Postgraduate' },
  { id: '5ebf6e4c-1b3e-42ce-8017-05cf66bdc028', name: 'Master of Science', shortName: 'M.Sc', category: 'Postgraduate' },
  { id: '60847fbd-b9a0-448d-b15b-5169169f02af', name: 'Master of Technology', shortName: 'M.Tech', category: 'Postgraduate' },
  { id: 'b2a1e983-9f85-4722-929f-bbec1ba69c1a', name: 'Doctor of Philosophy', shortName: 'PhD', category: 'Doctorate' },
];

// Static industries data (no DB model — same data used by web frontend)
const INDUSTRIES = [
  { id: '4aea7e47-7dd7-4616-97ba-ba9cc1a54837', name: 'Consulting', icon: 'briefcase' },
  { id: '2319932b-ae7c-4cbd-a849-485eafdf19f4', name: 'E-commerce', icon: 'shopping-cart' },
  { id: '712b28b1-e550-462d-a7d8-9f2c0e602310', name: 'Education', icon: 'graduation-cap' },
  { id: '74cf56ce-b733-4dd4-9e8a-a337c0f80528', name: 'Finance & Banking', icon: 'banknote' },
  { id: '315f21ed-d0ea-4d95-8130-d6637bb57031', name: 'Healthcare', icon: 'heart-pulse' },
  { id: 'b49b90dc-ea55-4521-a259-6d53813e720f', name: 'Information Technology', icon: 'laptop' },
  { id: '323ceb77-b64e-49f9-8036-48ad4460f6f3', name: 'Legal Services', icon: 'scale' },
  { id: 'a21afac6-8fc5-4c24-a5b0-b56006b17b51', name: 'Manufacturing', icon: 'factory' },
  { id: '2c6e03ec-18ab-43c1-8b63-e6d6a3d3d17b', name: 'Media & Entertainment', icon: 'film' },
  { id: '5a7dece6-c9c7-49bc-ade2-4215664d37d6', name: 'Real Estate', icon: 'building' },
];

// GET /courses (all courses — used by web)
router.get('/courses', (_req: Request, res: Response) => {
  res.json(COURSES);
});

// GET /industries (all industries — used by web and app)
router.get('/industries', (_req: Request, res: Response) => {
  res.json(INDUSTRIES);
});

// GET /universities/:id/courses (courses for a university — used by app)
// Returns all courses since courses aren't scoped to universities in this data model.
router.get('/universities/:id/courses', (_req: Request, res: Response) => {
  res.json(COURSES);
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
