import { z } from "zod"

/**
 * File Upload Security Validation
 *
 * Provides comprehensive validation for file uploads including:
 * - File type validation (MIME type and magic bytes)
 * - File size limits
 * - File name sanitization
 * - Extension validation
 */

/**
 * Allowed file types with their MIME types and magic bytes
 */
export const ALLOWED_FILE_TYPES = {
  // Documents
  "application/pdf": {
    extensions: [".pdf"],
    magicBytes: [0x25, 0x50, 0x44, 0x46], // %PDF
    maxSize: 25 * 1024 * 1024, // 25MB for PDFs
  },
  "application/msword": {
    extensions: [".doc"],
    magicBytes: [0xd0, 0xcf, 0x11, 0xe0], // OLE compound document
    maxSize: 25 * 1024 * 1024,
  },
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document": {
    extensions: [".docx"],
    magicBytes: [0x50, 0x4b, 0x03, 0x04], // ZIP (Office Open XML)
    maxSize: 25 * 1024 * 1024,
  },
  "application/vnd.ms-excel": {
    extensions: [".xls"],
    magicBytes: [0xd0, 0xcf, 0x11, 0xe0], // OLE compound document
    maxSize: 25 * 1024 * 1024,
  },
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": {
    extensions: [".xlsx"],
    magicBytes: [0x50, 0x4b, 0x03, 0x04], // ZIP (Office Open XML)
    maxSize: 25 * 1024 * 1024,
  },
  "application/vnd.ms-powerpoint": {
    extensions: [".ppt"],
    magicBytes: [0xd0, 0xcf, 0x11, 0xe0], // OLE compound document
    maxSize: 50 * 1024 * 1024,
  },
  "application/vnd.openxmlformats-officedocument.presentationml.presentation": {
    extensions: [".pptx"],
    magicBytes: [0x50, 0x4b, 0x03, 0x04], // ZIP (Office Open XML)
    maxSize: 50 * 1024 * 1024,
  },
  // Images
  "image/jpeg": {
    extensions: [".jpg", ".jpeg"],
    magicBytes: [0xff, 0xd8, 0xff], // JPEG
    maxSize: 10 * 1024 * 1024,
  },
  "image/png": {
    extensions: [".png"],
    magicBytes: [0x89, 0x50, 0x4e, 0x47], // PNG
    maxSize: 10 * 1024 * 1024,
  },
  "image/gif": {
    extensions: [".gif"],
    magicBytes: [0x47, 0x49, 0x46, 0x38], // GIF87a or GIF89a
    maxSize: 5 * 1024 * 1024,
  },
  "image/webp": {
    extensions: [".webp"],
    magicBytes: [0x52, 0x49, 0x46, 0x46], // RIFF
    maxSize: 10 * 1024 * 1024,
  },
  // Text
  "text/plain": {
    extensions: [".txt"],
    magicBytes: null, // Text files have no magic bytes
    maxSize: 5 * 1024 * 1024,
  },
} as const

export type AllowedMimeType = keyof typeof ALLOWED_FILE_TYPES

/**
 * Default maximum file size (10MB)
 */
export const DEFAULT_MAX_FILE_SIZE = 10 * 1024 * 1024

/**
 * File validation result
 */
export interface FileValidationResult {
  valid: boolean
  error?: string
  sanitizedName?: string
  mimeType?: string
}

/**
 * Validates file extension matches MIME type
 */
export function validateFileExtension(
  fileName: string,
  mimeType: string
): boolean {
  const fileConfig = ALLOWED_FILE_TYPES[mimeType as AllowedMimeType]
  if (!fileConfig) return false

  const ext = fileName.toLowerCase().slice(fileName.lastIndexOf("."))
  return (fileConfig.extensions as readonly string[]).includes(ext)
}

/**
 * Validates magic bytes of file content
 * @param data - First few bytes of the file (as Uint8Array or number array)
 * @param mimeType - Expected MIME type
 */
export function validateMagicBytes(
  data: Uint8Array | number[],
  mimeType: string
): boolean {
  const fileConfig = ALLOWED_FILE_TYPES[mimeType as AllowedMimeType]
  if (!fileConfig) return false
  if (fileConfig.magicBytes === null) return true // Text files

  const magicBytes = fileConfig.magicBytes
  if (data.length < magicBytes.length) return false

  for (let i = 0; i < magicBytes.length; i++) {
    if (data[i] !== magicBytes[i]) return false
  }
  return true
}

/**
 * Sanitizes file name to prevent path traversal and other attacks
 */
export function sanitizeFileName(fileName: string): string {
  // Remove path components
  let sanitized = fileName.replace(/^.*[/\\]/, "")

  // Remove special characters that could be problematic
  sanitized = sanitized.replace(/[/\\:*?"<>|]/g, "_")

  // Remove null bytes and control characters
  sanitized = sanitized.replace(/[\x00-\x1f\x7f]/g, "")

  // Limit length (preserving extension)
  const ext = sanitized.slice(sanitized.lastIndexOf("."))
  const name = sanitized.slice(0, sanitized.lastIndexOf("."))
  if (name.length > 200) {
    sanitized = name.slice(0, 200) + ext
  }

  // Ensure not empty
  if (!sanitized || sanitized === ext) {
    sanitized = `file_${Date.now()}${ext}`
  }

  return sanitized
}

/**
 * Get maximum allowed size for a MIME type
 */
export function getMaxFileSize(mimeType: string): number {
  const fileConfig = ALLOWED_FILE_TYPES[mimeType as AllowedMimeType]
  return fileConfig?.maxSize ?? DEFAULT_MAX_FILE_SIZE
}

/**
 * Comprehensive file validation
 */
export function validateFile(
  file: {
    name: string
    type: string
    size: number
    data?: Uint8Array // Optional: for magic byte validation
  },
  options: {
    maxSize?: number
    allowedTypes?: AllowedMimeType[]
    validateMagicBytes?: boolean
  } = {}
): FileValidationResult {
  const {
    maxSize,
    allowedTypes = Object.keys(ALLOWED_FILE_TYPES) as AllowedMimeType[],
    validateMagicBytes: shouldValidateMagicBytes = true,
  } = options

  // Check MIME type is allowed
  if (!allowedTypes.includes(file.type as AllowedMimeType)) {
    return {
      valid: false,
      error: `File type '${file.type}' is not allowed. Allowed types: ${allowedTypes.join(", ")}`,
    }
  }

  // Check file extension matches MIME type
  if (!validateFileExtension(file.name, file.type)) {
    return {
      valid: false,
      error: "File extension does not match file type",
    }
  }

  // Check file size
  const maxAllowedSize = maxSize ?? getMaxFileSize(file.type)
  if (file.size > maxAllowedSize) {
    const maxMB = (maxAllowedSize / (1024 * 1024)).toFixed(1)
    return {
      valid: false,
      error: `File size exceeds maximum allowed size of ${maxMB}MB`,
    }
  }

  if (file.size === 0) {
    return {
      valid: false,
      error: "File is empty",
    }
  }

  // Check magic bytes if data is provided
  if (shouldValidateMagicBytes && file.data && file.data.length > 0) {
    if (!validateMagicBytes(file.data, file.type)) {
      return {
        valid: false,
        error: "File content does not match declared file type",
      }
    }
  }

  // Sanitize file name
  const sanitizedName = sanitizeFileName(file.name)

  return {
    valid: true,
    sanitizedName,
    mimeType: file.type,
  }
}

/**
 * Zod schema for file upload validation
 */
export const fileUploadSchema = z.object({
  name: z
    .string()
    .min(1, "File name is required")
    .max(255, "File name too long")
    .refine(
      (name) => {
        // Check for path traversal attempts
        if (name.includes("..") || name.includes("/") || name.includes("\\")) {
          return false
        }
        // Check for null bytes
        if (name.includes("\0")) {
          return false
        }
        return true
      },
      "Invalid file name"
    ),
  type: z.string().refine(
    (type) => type in ALLOWED_FILE_TYPES,
    { message: "File type is not allowed" }
  ),
  size: z
    .number()
    .positive("File size must be positive")
    .refine(
      (size) => size <= 50 * 1024 * 1024,
      "File size must be less than 50MB"
    ),
  base64Data: z.string().min(1, "File data is required").optional(),
})

export type FileUploadInput = z.infer<typeof fileUploadSchema>

/**
 * Validates and sanitizes a File object (browser)
 */
export async function validateBrowserFile(
  file: File,
  options?: {
    maxSize?: number
    allowedTypes?: AllowedMimeType[]
  }
): Promise<FileValidationResult> {
  // Read first bytes for magic byte validation
  const buffer = await file.slice(0, 8).arrayBuffer()
  const data = new Uint8Array(buffer)

  return validateFile(
    {
      name: file.name,
      type: file.type,
      size: file.size,
      data,
    },
    {
      ...options,
      validateMagicBytes: true,
    }
  )
}
