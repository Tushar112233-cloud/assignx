import fs from 'fs/promises';
import path from 'path';
import crypto from 'crypto';

import { getCloudinary } from '../config/cloudinary';
import { AppError } from '../middleware/errorHandler';

interface UploadResult {
  url: string;
  publicId: string;
  format: string;
  bytes: number;
}

function cloudinaryConfigured(): boolean {
  return Boolean(
    process.env.CLOUDINARY_CLOUD_NAME &&
      process.env.CLOUDINARY_API_KEY &&
      process.env.CLOUDINARY_API_SECRET
  );
}

function inferExt(originalName?: string): string {
  if (originalName?.includes('.')) {
    const ext = path.extname(originalName).slice(0, 10);
    return ext || '.bin';
  }
  return '.bin';
}

/** Dev/local fallback when Cloudinary keys are not set — serves files from /uploads. */
async function uploadBufferToDisk(
  buffer: Buffer,
  folder: string,
  originalName?: string
): Promise<UploadResult> {
  const safeFolder = folder.replace(/^\/+|\/+$/g, '').replace(/\.\./g, '');
  const baseDir = path.join(process.cwd(), 'uploads', safeFolder);
  await fs.mkdir(baseDir, { recursive: true });
  const ext = inferExt(originalName);
  const name = `${crypto.randomUUID()}${ext}`;
  const fullPath = path.join(baseDir, name);
  await fs.writeFile(fullPath, buffer);
  const port = process.env.PORT || 4000;
  const publicBase = (process.env.PUBLIC_API_URL || `http://localhost:${port}`).replace(/\/$/, '');
  const relative = `/uploads/${safeFolder}/${name}`.replace(/\\/g, '/');
  const url = `${publicBase}${relative}`;
  return {
    url,
    publicId: `local:${safeFolder}/${name}`,
    format: ext.replace('.', '') || 'bin',
    bytes: buffer.length,
  };
}

export const uploadToCloudinary = async (
  filePath: string,
  folder: string = 'assignx'
): Promise<UploadResult> => {
  try {
    if (!cloudinaryConfigured()) {
      const buf = await fs.readFile(filePath);
      return uploadBufferToDisk(buf, folder, path.basename(filePath));
    }
    const result = await getCloudinary().uploader.upload(filePath, {
      folder,
      resource_type: 'auto',
    });
    return {
      url: result.secure_url,
      publicId: result.public_id,
      format: result.format,
      bytes: result.bytes,
    };
  } catch (error) {
    throw new AppError('File upload failed', 500);
  }
};

export const uploadBufferToCloudinary = async (
  buffer: Buffer,
  folder: string = 'assignx',
  originalName?: string
): Promise<UploadResult> => {
  if (!cloudinaryConfigured()) {
    return uploadBufferToDisk(buffer, folder, originalName);
  }

  return new Promise((resolve, reject) => {
    const stream = getCloudinary().uploader.upload_stream(
      { folder, resource_type: 'auto' },
      (error, result) => {
        if (error || !result) {
          return reject(new AppError('File upload failed', 500));
        }
        resolve({
          url: result.secure_url,
          publicId: result.public_id,
          format: result.format,
          bytes: result.bytes,
        });
      }
    );
    stream.end(buffer);
  });
};

export const deleteFromCloudinary = async (publicId: string): Promise<void> => {
  try {
    if (publicId.startsWith('local:')) {
      const rel = publicId.slice('local:'.length);
      const fullPath = path.join(process.cwd(), 'uploads', rel);
      await fs.unlink(fullPath).catch(() => {});
      return;
    }
    if (!cloudinaryConfigured()) return;
    await getCloudinary().uploader.destroy(publicId);
  } catch {
    throw new AppError('File deletion failed', 500);
  }
};
