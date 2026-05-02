'use client'

import { useState, useCallback, useRef } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Upload,
  File,
  FileText,
  Image as ImageIcon,
  X,
  CheckCircle2,
  AlertCircle,
  Loader2,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'

/** Accepted file types */
const ACCEPTED_TYPES = {
  'application/pdf': ['.pdf'],
  'application/msword': ['.doc'],
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document': ['.docx'],
  'application/vnd.ms-powerpoint': ['.ppt'],
  'application/vnd.openxmlformats-officedocument.presentationml.presentation': ['.pptx'],
  'application/vnd.ms-excel': ['.xls'],
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': ['.xlsx'],
  'image/jpeg': ['.jpg', '.jpeg'],
  'image/png': ['.png'],
  'text/plain': ['.txt'],
  'text/csv': ['.csv'],
  'application/zip': ['.zip'],
}

/** Max file size in bytes (10MB) */
const MAX_FILE_SIZE = 10 * 1024 * 1024

interface FileWithPreview extends File {
  preview?: string
  progress?: number
  status?: 'pending' | 'uploading' | 'success' | 'error'
  error?: string
}

interface FileUploadProps {
  /** Callback when files are selected */
  onFilesSelected?: (files: File[]) => void
  /** Callback when files are uploaded */
  onUpload?: (files: File[]) => Promise<void>
  /** Whether upload is in progress */
  isUploading?: boolean
  /** Maximum number of files */
  maxFiles?: number
  /** Whether to allow multiple files */
  multiple?: boolean
  /** Custom accepted types */
  acceptedTypes?: string[]
  /** Custom max size in MB */
  maxSizeMB?: number
  /** Additional class name */
  className?: string
}

/**
 * File upload component with drag and drop
 * Supports multiple files, progress, and validation
 */
export function FileUpload({
  onFilesSelected,
  onUpload,
  isUploading = false,
  maxFiles = 5,
  multiple = true,
  acceptedTypes,
  maxSizeMB = 10,
  className,
}: FileUploadProps) {
  const [files, setFiles] = useState<FileWithPreview[]>([])
  const [isDragging, setIsDragging] = useState(false)
  const [uploadProgress, setUploadProgress] = useState(0)
  const inputRef = useRef<HTMLInputElement>(null)

  const maxSize = maxSizeMB * 1024 * 1024
  const accept = acceptedTypes?.join(',') || Object.keys(ACCEPTED_TYPES).join(',')

  /** Validate a file */
  const validateFile = useCallback(
    (file: File): string | null => {
      // Check file size
      if (file.size > maxSize) {
        return `File exceeds ${maxSizeMB}MB limit`
      }

      // Check file type
      const validTypes = acceptedTypes || Object.keys(ACCEPTED_TYPES)
      if (!validTypes.includes(file.type)) {
        return 'File type not supported'
      }

      return null
    },
    [maxSize, maxSizeMB, acceptedTypes]
  )

  /** Handle file selection */
  const handleFiles = useCallback(
    (newFiles: FileList | File[]) => {
      const fileArray = Array.from(newFiles)

      // Check max files limit
      if (files.length + fileArray.length > maxFiles) {
        alert(`Maximum ${maxFiles} files allowed`)
        return
      }

      const processedFiles: FileWithPreview[] = fileArray.map((file) => {
        const error = validateFile(file)
        return Object.assign(file, {
          preview: file.type.startsWith('image/')
            ? URL.createObjectURL(file)
            : undefined,
          progress: 0,
          status: error ? 'error' : 'pending',
          error,
        } as Partial<FileWithPreview>)
      })

      const validFiles = processedFiles.filter((f) => f.status !== 'error')

      setFiles((prev) => [...prev, ...processedFiles])

      if (onFilesSelected && validFiles.length > 0) {
        onFilesSelected(validFiles)
      }
    },
    [files.length, maxFiles, validateFile, onFilesSelected]
  )

  /** Handle drag events */
  const handleDrag = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
  }, [])

  const handleDragIn = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setIsDragging(true)
  }, [])

  const handleDragOut = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setIsDragging(false)
  }, [])

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault()
      e.stopPropagation()
      setIsDragging(false)

      if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
        handleFiles(e.dataTransfer.files)
      }
    },
    [handleFiles]
  )

  /** Remove a file */
  const removeFile = useCallback((index: number) => {
    setFiles((prev) => {
      const newFiles = [...prev]
      const removed = newFiles.splice(index, 1)[0]
      if (removed.preview) {
        URL.revokeObjectURL(removed.preview)
      }
      return newFiles
    })
  }, [])

  /** Handle upload */
  const handleUpload = useCallback(async () => {
    if (!onUpload || files.length === 0) return

    const validFiles = files.filter((f) => f.status === 'pending')
    if (validFiles.length === 0) return

    // Update status to uploading
    setFiles((prev) =>
      prev.map((f) =>
        f.status === 'pending' ? { ...f, status: 'uploading' } : f
      )
    )

    try {
      await onUpload(validFiles)

      // Update status to success
      setFiles((prev) =>
        prev.map((f) =>
          f.status === 'uploading' ? { ...f, status: 'success', progress: 100 } : f
        )
      )
      setUploadProgress(100)
    } catch (error) {
      // Update status to error
      setFiles((prev) =>
        prev.map((f) =>
          f.status === 'uploading'
            ? {
                ...f,
                status: 'error',
                error: error instanceof Error ? error.message : 'Upload failed',
              }
            : f
        )
      )
    }
  }, [files, onUpload])

  /** Get file icon based on type */
  const getFileIcon = (file: File) => {
    if (file.type?.startsWith('image/')) {
      return <ImageIcon className="h-6 w-6" />
    }
    if (file.type?.includes('pdf')) {
      return <FileText className="h-6 w-6 text-red-500" />
    }
    return <File className="h-6 w-6" />
  }

  /** Format file size */
  const formatSize = (bytes: number | undefined) => {
    if (bytes == null || isNaN(bytes)) return 'Unknown size'
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }

  return (
    <div className={cn('space-y-4', className)}>
      {/* Drop zone */}
      <div
        onClick={() => inputRef.current?.click()}
        onDragEnter={handleDragIn}
        onDragLeave={handleDragOut}
        onDragOver={handleDrag}
        onDrop={handleDrop}
        className={cn(
          'border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors',
          isDragging
            ? 'border-primary bg-primary/5'
            : 'border-muted-foreground/25 hover:border-primary/50'
        )}
      >
        <input
          ref={inputRef}
          type="file"
          accept={accept}
          multiple={multiple}
          onChange={(e) => e.target.files && handleFiles(e.target.files)}
          className="hidden"
        />

        <Upload className="h-10 w-10 mx-auto text-muted-foreground mb-4" />

        <p className="text-sm font-medium">
          {isDragging ? 'Drop files here' : 'Drag & drop files here'}
        </p>
        <p className="text-xs text-muted-foreground mt-1">
          or click to browse
        </p>
        <p className="text-xs text-muted-foreground mt-2">
          PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX, JPG, PNG, TXT, CSV, ZIP (max {maxSizeMB}MB)
        </p>
      </div>

      {/* File list */}
      <AnimatePresence mode="popLayout">
        {files.length > 0 && (
          <div className="space-y-2">
            {files.map((file, index) => (
              <motion.div
                key={`${file.name}-${index}`}
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, x: -10 }}
                className={cn(
                  'flex items-center gap-3 p-3 rounded-lg border',
                  file.status === 'error' && 'border-destructive bg-destructive/5',
                  file.status === 'success' && 'border-green-500 bg-green-50',
                  file.status === 'pending' && 'border-border',
                  file.status === 'uploading' && 'border-primary bg-primary/5'
                )}
              >
                {/* File icon or preview */}
                <div className="flex-shrink-0">
                  {file.preview ? (
                    <img
                      src={file.preview}
                      alt={file.name}
                      className="h-10 w-10 rounded object-cover"
                    />
                  ) : (
                    getFileIcon(file)
                  )}
                </div>

                {/* File info */}
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{file.name}</p>
                  <p className="text-xs text-muted-foreground">
                    {formatSize(file.size)}
                    {file.error && (
                      <span className="text-destructive ml-2">{file.error}</span>
                    )}
                  </p>

                  {/* Progress bar */}
                  {file.status === 'uploading' && (
                    <Progress value={file.progress} className="h-1 mt-1" />
                  )}
                </div>

                {/* Status icon */}
                <div className="flex-shrink-0">
                  {file.status === 'uploading' && (
                    <Loader2 className="h-5 w-5 animate-spin text-primary" />
                  )}
                  {file.status === 'success' && (
                    <CheckCircle2 className="h-5 w-5 text-green-500" />
                  )}
                  {file.status === 'error' && (
                    <AlertCircle className="h-5 w-5 text-destructive" />
                  )}
                  {file.status === 'pending' && (
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      onClick={(e) => {
                        e.stopPropagation()
                        removeFile(index)
                      }}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </AnimatePresence>

      {/* Upload button */}
      {files.some((f) => f.status === 'pending') && onUpload && (
        <Button
          onClick={handleUpload}
          disabled={isUploading}
          className="w-full"
        >
          {isUploading ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              Uploading...
            </>
          ) : (
            <>
              <Upload className="h-4 w-4 mr-2" />
              Upload {files.filter((f) => f.status === 'pending').length} file(s)
            </>
          )}
        </Button>
      )}

      {/* Overall progress */}
      {isUploading && (
        <div className="space-y-1">
          <Progress value={uploadProgress} className="h-2" />
          <p className="text-xs text-muted-foreground text-center">
            Uploading... {uploadProgress}%
          </p>
        </div>
      )}
    </div>
  )
}
