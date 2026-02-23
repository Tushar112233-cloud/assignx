"use client";

import { useState, useCallback } from "react";
import { Upload, X, FileText, Image, File, AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { cn } from "@/lib/utils";
import type { UploadedFile } from "@/types/add-project";

interface FileUploadZoneProps {
  files: UploadedFile[];
  onFilesChange: (files: UploadedFile[]) => void;
  maxFiles?: number;
  maxSizeMB?: number;
  acceptedTypes?: string[];
  className?: string;
}

const DEFAULT_ACCEPTED_TYPES = [
  "application/pdf",
  "application/msword",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "image/jpeg",
  "image/png",
  "image/webp",
];

/**
 * Format file size for display
 */
function formatFileSize(bytes: number): string {
  if (bytes === 0) return "0 Bytes";
  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + " " + sizes[i];
}

/**
 * Get file icon based on type
 */
function getFileIcon(type: string) {
  if (type.startsWith("image/")) return Image;
  if (type.includes("pdf") || type.includes("word")) return FileText;
  return File;
}

/**
 * Drag and drop file upload zone
 */
export function FileUploadZone({
  files,
  onFilesChange,
  maxFiles = 5,
  maxSizeMB = 10,
  acceptedTypes = DEFAULT_ACCEPTED_TYPES,
  className,
}: FileUploadZoneProps) {
  const [isDragging, setIsDragging] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  }, []);

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  }, []);

  const validateFile = useCallback(
    (file: File): string | null => {
      console.log("[FileUpload] Validating file:", {
        fileName: file.name,
        fileType: file.type,
        acceptedTypes,
        isTypeAccepted: acceptedTypes.includes(file.type)
      });

      if (!acceptedTypes.includes(file.type)) {
        return `File type not supported: ${file.name} (type: ${file.type})`;
      }
      if (file.size > maxSizeMB * 1024 * 1024) {
        return `File too large: ${file.name} (max ${maxSizeMB}MB)`;
      }
      return null;
    },
    [acceptedTypes, maxSizeMB]
  );

  const processFiles = useCallback(
    (newFiles: FileList | null) => {
      console.log("[FileUpload] processFiles called", {
        newFilesCount: newFiles?.length,
        currentFilesCount: files.length,
        maxFiles
      });

      if (!newFiles) {
        console.log("[FileUpload] No files provided");
        return;
      }

      setError(null);

      if (files.length + newFiles.length > maxFiles) {
        const errorMsg = `Maximum ${maxFiles} files allowed`;
        console.log("[FileUpload] Error:", errorMsg);
        setError(errorMsg);
        return;
      }

      const filesToAdd: UploadedFile[] = [];

      Array.from(newFiles).forEach((file, index) => {
        console.log(`[FileUpload] Processing file ${index + 1}:`, {
          name: file.name,
          type: file.type,
          size: file.size,
          sizeMB: (file.size / (1024 * 1024)).toFixed(2) + "MB"
        });

        const validationError = validateFile(file);
        if (validationError) {
          console.log("[FileUpload] Validation error:", validationError);
          setError(validationError);
          return;
        }

        // Simulate upload (in production, this would be actual upload)
        const uploadedFile: UploadedFile = {
          id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
          file,
          name: file.name,
          size: file.size,
          type: file.type,
          progress: 100, // Mock complete
          status: "complete",
        };

        console.log("[FileUpload] File validated successfully:", uploadedFile.id);
        filesToAdd.push(uploadedFile);
      });

      if (filesToAdd.length > 0) {
        console.log("[FileUpload] Adding files to state:", filesToAdd.length);
        onFilesChange([...files, ...filesToAdd]);
      } else {
        console.log("[FileUpload] No valid files to add");
      }
    },
    [files, maxFiles, onFilesChange, validateFile]
  );

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      setIsDragging(false);
      processFiles(e.dataTransfer.files);
    },
    [processFiles]
  );

  const handleFileInput = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      processFiles(e.target.files);
      e.target.value = ""; // Reset input
    },
    [processFiles]
  );

  const removeFile = useCallback(
    (fileId: string) => {
      onFilesChange(files.filter((f) => f.id !== fileId));
      setError(null);
    },
    [files, onFilesChange]
  );

  return (
    <div className={cn("space-y-4", className)}>
      {/* Drop Zone */}
      <div
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        className={cn(
          "relative flex min-h-32 flex-col items-center justify-center rounded-lg border-2 border-dashed p-6 transition-colors",
          isDragging
            ? "border-primary bg-primary/5"
            : "border-muted-foreground/25 hover:border-muted-foreground/50",
          files.length >= maxFiles && "pointer-events-none opacity-50"
        )}
      >
        <input
          type="file"
          multiple
          accept={acceptedTypes.join(",")}
          onChange={handleFileInput}
          className="absolute inset-0 cursor-pointer opacity-0"
          disabled={files.length >= maxFiles}
        />
        <Upload
          className={cn(
            "mb-2 h-8 w-8",
            isDragging ? "text-primary" : "text-muted-foreground"
          )}
        />
        <p className="text-center text-sm text-muted-foreground">
          <span className="font-medium text-foreground">Click to upload</span>{" "}
          or drag and drop
        </p>
        <p className="mt-1 text-xs text-muted-foreground">
          PDF, DOC, DOCX, or images (max {maxSizeMB}MB each)
        </p>
        {files.length > 0 && (
          <p className="mt-2 text-xs text-muted-foreground">
            {files.length} of {maxFiles} files uploaded
          </p>
        )}
      </div>

      {/* Error Message */}
      {error && (
        <div className="flex items-center gap-2 rounded-md bg-destructive/10 p-3 text-sm text-destructive">
          <AlertCircle className="h-4 w-4 shrink-0" />
          <p>{error}</p>
        </div>
      )}

      {/* File List */}
      {files.length > 0 && (
        <div className="space-y-2">
          {files.map((file) => {
            const IconComponent = getFileIcon(file.type);
            return (
              <div
                key={file.id}
                className="flex items-center gap-3 rounded-lg border bg-muted/50 p-3"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-background">
                  <IconComponent className="h-5 w-5 text-muted-foreground" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{file.name}</p>
                  <p className="text-xs text-muted-foreground">
                    {formatFileSize(file.size)}
                  </p>
                  {file.status === "uploading" && (
                    <Progress value={file.progress} className="mt-1 h-1" />
                  )}
                </div>
                <Button
                  type="button"
                  variant="ghost"
                  size="icon"
                  className="h-8 w-8 shrink-0"
                  onClick={() => removeFile(file.id)}
                >
                  <X className="h-4 w-4" />
                  <span className="sr-only">Remove file</span>
                </Button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
