/**
 * File validation utilities
 * Provides secure file upload validation for deliverables
 */

/** Allowed MIME types for file uploads */
export const ALLOWED_MIME_TYPES = [
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-powerpoint',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
  'text/plain',
  'text/csv',
  'application/zip',
  'application/x-rar-compressed',
] as const

/** Maximum file size in bytes (50MB) */
export const MAX_FILE_SIZE = 50 * 1024 * 1024

/** Mapping of MIME types to allowed extensions */
const MIME_TO_EXTENSIONS: Record<string, string[]> = {
  'application/pdf': ['pdf'],
  'application/msword': ['doc'],
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document': ['docx'],
  'application/vnd.ms-excel': ['xls'],
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': ['xlsx'],
  'application/vnd.ms-powerpoint': ['ppt'],
  'application/vnd.openxmlformats-officedocument.presentationml.presentation': ['pptx'],
  'image/jpeg': ['jpg', 'jpeg'],
  'image/png': ['png'],
  'image/gif': ['gif'],
  'image/webp': ['webp'],
  'text/plain': ['txt'],
  'text/csv': ['csv'],
  'application/zip': ['zip'],
  'application/x-rar-compressed': ['rar'],
}

/** File validation result */
export interface FileValidationResult {
  valid: boolean
  error?: string
}

/**
 * Validate a file for upload
 * @param file - The file to validate
 * @returns Validation result with error message if invalid
 */
export function validateFile(file: File): FileValidationResult {
  // Check file size
  if (file.size > MAX_FILE_SIZE) {
    const maxSizeMB = MAX_FILE_SIZE / (1024 * 1024)
    return {
      valid: false,
      error: `File size exceeds ${maxSizeMB}MB limit. Your file is ${(file.size / (1024 * 1024)).toFixed(1)}MB.`,
    }
  }

  // Check if file is empty
  if (file.size === 0) {
    return {
      valid: false,
      error: 'File is empty',
    }
  }

  // Check MIME type
  if (!ALLOWED_MIME_TYPES.includes(file.type as typeof ALLOWED_MIME_TYPES[number])) {
    return {
      valid: false,
      error: `File type "${file.type || 'unknown'}" is not allowed. Allowed types: PDF, Word, Excel, PowerPoint, images, text, and archives.`,
    }
  }

  // Get file extension
  const fileName = file.name.toLowerCase()
  const lastDotIndex = fileName.lastIndexOf('.')

  if (lastDotIndex === -1) {
    return {
      valid: false,
      error: 'File must have an extension',
    }
  }

  const extension = fileName.slice(lastDotIndex + 1)

  // Check for dangerous extensions
  const dangerousExtensions = ['exe', 'bat', 'cmd', 'sh', 'ps1', 'vbs', 'js', 'msi', 'dll', 'scr']
  if (dangerousExtensions.includes(extension)) {
    return {
      valid: false,
      error: `File extension ".${extension}" is not allowed for security reasons`,
    }
  }

  // Verify extension matches MIME type
  const allowedExtensions = MIME_TO_EXTENSIONS[file.type]
  if (!allowedExtensions || !allowedExtensions.includes(extension)) {
    return {
      valid: false,
      error: `File extension ".${extension}" does not match the file type "${file.type}"`,
    }
  }

  // Check for double extensions (e.g., file.pdf.exe)
  const parts = fileName.split('.')
  if (parts.length > 2) {
    const potentialHiddenExt = parts[parts.length - 2]
    if (dangerousExtensions.includes(potentialHiddenExt)) {
      return {
        valid: false,
        error: 'File appears to have a hidden dangerous extension',
      }
    }
  }

  return { valid: true }
}

/**
 * Generate a safe filename for storage
 * @param originalName - The original filename
 * @param projectId - The project ID for namespacing
 * @returns A safe, unique filename
 */
export function generateSafeFileName(originalName: string, projectId: string): string {
  // Get extension
  const lastDotIndex = originalName.lastIndexOf('.')
  const extension = lastDotIndex !== -1 ? originalName.slice(lastDotIndex + 1).toLowerCase() : ''

  // Generate unique filename with timestamp and random string
  const timestamp = Date.now()
  const randomStr = Math.random().toString(36).substring(2, 10)

  return `${projectId}/${timestamp}-${randomStr}.${extension}`
}

/**
 * Get human-readable file size
 * @param bytes - File size in bytes
 * @returns Formatted file size string
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes'

  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))

  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`
}
