import { Router, Request, Response, NextFunction } from 'express';
import { AccessRequest } from '../models/AccessRequest';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /access-requests/check?email=...&role=...
router.get('/check', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = req.query;
    if (!email) throw new AppError('Email is required', 400);

    const request = await AccessRequest.findOne({
      email: (email as string).toLowerCase().trim(),
      ...(role ? { role: role as string } : {}),
    }).sort({ createdAt: -1 });

    if (!request) {
      return res.status(404).json({ error: 'No access request found' });
    }

    res.json({ id: request._id, status: request.status });
  } catch (err) {
    next(err);
  }
});

// POST /access-requests
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role, full_name, metadata } = req.body;
    if (!email || !role || !full_name) {
      throw new AppError('email, role, and full_name are required', 400);
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Check for existing pending request
    const existing = await AccessRequest.findOne({
      email: normalizedEmail,
      role,
      status: 'pending',
    });
    if (existing) {
      return res.json({ id: existing._id, status: existing.status });
    }

    const request = await AccessRequest.create({
      email: normalizedEmail,
      role,
      fullName: full_name,
      metadata: metadata || {},
    });

    res.status(201).json({ id: request._id, status: request.status });
  } catch (err) {
    next(err);
  }
});

export default router;
