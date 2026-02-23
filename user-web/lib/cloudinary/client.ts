import { v2 as cloudinary } from "cloudinary";

/**
 * Cloudinary Configuration
 * Configure with environment variables
 */
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

export { cloudinary };

/**
 * Upload a file to Cloudinary
 * @param base64Data - Base64 encoded file data
 * @param options - Upload options
 * @returns Upload result with URL
 */
export async function uploadToCloudinary(
  base64Data: string,
  options: {
    folder: string;
    publicId?: string;
    resourceType?: "auto" | "image" | "video" | "raw";
  }
): Promise<{
  url: string;
  publicId: string;
  format: string;
  bytes: number;
}> {
  const result = await cloudinary.uploader.upload(
    `data:application/octet-stream;base64,${base64Data}`,
    {
      folder: options.folder,
      public_id: options.publicId,
      resource_type: options.resourceType || "auto",
      use_filename: true,
      unique_filename: true,
    }
  );

  return {
    url: result.secure_url,
    publicId: result.public_id,
    format: result.format,
    bytes: result.bytes,
  };
}

/**
 * Delete a file from Cloudinary
 * @param publicId - Cloudinary public ID
 * @param resourceType - Resource type (image, video, raw)
 */
export async function deleteFromCloudinary(
  publicId: string,
  resourceType: "image" | "video" | "raw" = "raw"
): Promise<void> {
  await cloudinary.uploader.destroy(publicId, {
    resource_type: resourceType,
  });
}

/**
 * Generate a Cloudinary folder path for project files
 * @param projectId - Project UUID
 * @returns Folder path
 */
export function getProjectFolder(projectId: string): string {
  return `assignx/projects/${projectId}`;
}

/**
 * Check if Cloudinary is properly configured
 * @returns True if all required environment variables are set
 */
export function isCloudinaryConfigured(): boolean {
  return !!(
    process.env.CLOUDINARY_CLOUD_NAME &&
    process.env.CLOUDINARY_API_KEY &&
    process.env.CLOUDINARY_API_SECRET
  );
}
