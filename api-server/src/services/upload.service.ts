import cloudinary from '../config/cloudinary';
import { AppError } from '../middleware/errorHandler';

interface UploadResult {
  url: string;
  publicId: string;
  format: string;
  bytes: number;
}

export const uploadToCloudinary = async (
  filePath: string,
  folder: string = 'assignx'
): Promise<UploadResult> => {
  try {
    const result = await cloudinary.uploader.upload(filePath, {
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
  folder: string = 'assignx'
): Promise<UploadResult> => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
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
    await cloudinary.uploader.destroy(publicId);
  } catch {
    throw new AppError('File deletion failed', 500);
  }
};
