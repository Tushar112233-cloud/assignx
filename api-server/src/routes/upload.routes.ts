import { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { authenticate } from '../middleware/auth';
import { uploadBufferToCloudinary, deleteFromCloudinary } from '../services/upload.service';
import { AppError } from '../middleware/errorHandler';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });

// POST /upload
router.post('/', authenticate, upload.single('file'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) throw new AppError('No file provided', 400);
    const folder = (req.body.folder as string) || 'assignx';
    const result = await uploadBufferToCloudinary(req.file.buffer, folder, req.file.originalname);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
});

// DELETE /upload
router.delete('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { publicId } = req.body;
    if (!publicId) throw new AppError('publicId is required', 400);
    await deleteFromCloudinary(publicId);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

export default router;
