/**
 * @fileoverview Drag-and-drop file upload component with preview support.
 * @module components/shared/file-upload
 */

"use client"

import { useCallback, useState } from "react"
import { useDropzone } from "react-dropzone"
import { Upload, X, File, FileText, Image, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

interface FileUploadProps {
  value?: File | null
  onChange: (file: File | null) => void
  accept?: Record<string, string[]>
  maxSize?: number
  disabled?: boolean
  className?: string
  placeholder?: string
}

const DEFAULT_ACCEPT = {
  "application/pdf": [".pdf"],
  "application/msword": [".doc"],
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document": [".docx"],
}

export function FileUpload({
  value,
  onChange,
  accept = DEFAULT_ACCEPT,
  maxSize = 10 * 1024 * 1024, // 10MB default
  disabled = false,
  className,
  placeholder = "Click or drag file to upload",
}: FileUploadProps) {
  const [isUploading, setIsUploading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const onDrop = useCallback(
    (acceptedFiles: File[], rejectedFiles: unknown[]) => {
      setError(null)

      if (rejectedFiles.length > 0) {
        setError("File type not supported or file too large")
        return
      }

      if (acceptedFiles.length > 0) {
        setIsUploading(true)
        // Simulate upload delay for visual feedback
        setTimeout(() => {
          onChange(acceptedFiles[0])
          setIsUploading(false)
        }, 500)
      }
    },
    [onChange]
  )

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept,
    maxSize,
    multiple: false,
    disabled: disabled || isUploading,
  })

  const removeFile = (e: React.MouseEvent) => {
    e.stopPropagation()
    onChange(null)
    setError(null)
  }

  const getFileIcon = (file: File) => {
    if (file.type.startsWith("image/")) return Image
    if (file.type === "application/pdf") return FileText
    return File
  }

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + " B"
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
    return (bytes / (1024 * 1024)).toFixed(1) + " MB"
  }

  if (value) {
    const FileIcon = getFileIcon(value)
    return (
      <div className={cn("relative", className)}>
        <div className="flex items-center gap-3 p-4 border rounded-lg bg-muted/50">
          <div className="flex-shrink-0 w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center">
            <FileIcon className="w-5 h-5 text-primary" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{value.name}</p>
            <p className="text-xs text-muted-foreground">{formatFileSize(value.size)}</p>
          </div>
          <Button
            type="button"
            variant="ghost"
            size="icon"
            onClick={removeFile}
            disabled={disabled}
            className="flex-shrink-0"
          >
            <X className="w-4 h-4" />
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className={className}>
      <div
        {...getRootProps()}
        className={cn(
          "relative border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors",
          isDragActive
            ? "border-primary bg-primary/5"
            : "border-muted-foreground/25 hover:border-primary/50 hover:bg-muted/50",
          (disabled || isUploading) && "opacity-50 cursor-not-allowed",
          error && "border-destructive"
        )}
      >
        <input {...getInputProps()} />

        <div className="flex flex-col items-center gap-2">
          {isUploading ? (
            <Loader2 className="w-10 h-10 text-primary animate-spin" />
          ) : (
            <Upload className="w-10 h-10 text-muted-foreground" />
          )}

          <div className="space-y-1">
            <p className="text-sm font-medium">
              {isDragActive ? "Drop the file here" : placeholder}
            </p>
            <p className="text-xs text-muted-foreground">
              PDF, DOC, DOCX up to {formatFileSize(maxSize)}
            </p>
          </div>
        </div>
      </div>

      {error && (
        <p className="mt-2 text-sm text-destructive">{error}</p>
      )}
    </div>
  )
}
