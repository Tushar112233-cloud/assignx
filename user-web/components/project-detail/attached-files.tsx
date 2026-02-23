"use client";

import { FileText, FileImage, Download } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import type { AttachedFile } from "@/types/project";

interface AttachedFilesProps {
  files: AttachedFile[];
  className?: string;
}

/**
 * Get icon for file type
 */
function getFileIcon(type: AttachedFile["type"]) {
  switch (type) {
    case "image":
      return <FileImage className="h-4 w-4 text-green-500" />;
    case "pdf":
      return <FileText className="h-4 w-4 text-red-500" />;
    case "doc":
    case "docx":
      return <FileText className="h-4 w-4 text-blue-500" />;
    default:
      return <FileText className="h-4 w-4 text-muted-foreground" />;
  }
}

/**
 * Display list of user-attached files
 */
export function AttachedFiles({ files, className }: AttachedFilesProps) {
  if (files.length === 0) {
    return (
      <p className="text-sm text-muted-foreground">No files attached</p>
    );
  }

  const handleDownload = (file: AttachedFile) => {
    if (!file.url) {
      toast.error("File URL not available");
      return;
    }

    // Create download link and trigger download
    const link = document.createElement("a");
    link.href = file.url;
    link.download = file.name;
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    toast.success(`Downloading: ${file.name}`);
  };

  return (
    <div className={cn("space-y-2", className)}>
      {files.map((file) => (
        <div
          key={file.id}
          className="flex items-center justify-between rounded-lg border bg-muted/50 p-3"
        >
          <div className="flex items-center gap-3 min-w-0">
            {getFileIcon(file.type)}
            <div className="min-w-0">
              <p className="truncate text-sm font-medium">{file.name}</p>
              <p className="text-xs text-muted-foreground">{file.size}</p>
            </div>
          </div>

          <Button
            variant="ghost"
            size="icon"
            onClick={() => handleDownload(file)}
            className="shrink-0"
          >
            <Download className="h-4 w-4" />
            <span className="sr-only">Download {file.name}</span>
          </Button>
        </div>
      ))}
    </div>
  );
}
