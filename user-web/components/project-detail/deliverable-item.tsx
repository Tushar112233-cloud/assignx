"use client";

import { useState } from "react";
import { FileText, Download, CheckCircle, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import type { Deliverable } from "@/types/project";

interface DeliverableItemProps {
  deliverable: Deliverable;
  className?: string;
}

/**
 * Get file extension color
 */
function getFileColor(name: string): string {
  const ext = name.split(".").pop()?.toLowerCase();

  switch (ext) {
    case "pdf":
      return "text-red-500";
    case "doc":
    case "docx":
      return "text-blue-500";
    case "xlsx":
    case "xls":
      return "text-green-500";
    case "zip":
    case "rar":
      return "text-yellow-500";
    default:
      return "text-muted-foreground";
  }
}

/**
 * Single deliverable file row
 */
export function DeliverableItem({
  deliverable,
  className,
}: DeliverableItemProps) {
  const [isDownloading, setIsDownloading] = useState(false);

  const handleDownload = async () => {
    if (!deliverable.url) {
      toast.error("File URL not available");
      return;
    }

    setIsDownloading(true);

    try {
      // Create download link and trigger download
      const link = document.createElement("a");
      link.href = deliverable.url;
      link.download = deliverable.name;
      link.target = "_blank";
      link.rel = "noopener noreferrer";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      toast.success(`Downloading: ${deliverable.name}`);
    } catch {
      toast.error("Failed to download file");
    } finally {
      setIsDownloading(false);
    }
  };

  return (
    <div
      className={cn(
        "flex items-center justify-between rounded-lg border p-3",
        deliverable.isFinal && "border-green-200 bg-green-50/50 dark:border-green-800 dark:bg-green-900/20",
        className
      )}
    >
      <div className="flex items-center gap-3 min-w-0">
        <div className="relative">
          <FileText className={cn("h-5 w-5", getFileColor(deliverable.name))} />
          {deliverable.isFinal && (
            <CheckCircle className="absolute -bottom-1 -right-1 h-3 w-3 text-green-500" />
          )}
        </div>

        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <p className="truncate text-sm font-medium">{deliverable.name}</p>
            <Badge variant="outline" className="shrink-0 text-xs">
              v{deliverable.version}
            </Badge>
            {deliverable.isFinal && (
              <Badge className="shrink-0 bg-green-500 text-xs hover:bg-green-600">
                Final
              </Badge>
            )}
          </div>
          <p className="text-xs text-muted-foreground">
            {deliverable.size} •{" "}
            {new Date(deliverable.uploadedAt).toLocaleDateString("en-IN", {
              day: "numeric",
              month: "short",
              hour: "2-digit",
              minute: "2-digit",
            })}
          </p>
        </div>
      </div>

      <Button
        variant="outline"
        size="sm"
        onClick={handleDownload}
        disabled={isDownloading}
        className="shrink-0 gap-2"
      >
        {isDownloading ? (
          <Loader2 className="h-4 w-4 animate-spin" />
        ) : (
          <Download className="h-4 w-4" />
        )}
        <span className="hidden sm:inline">Download</span>
      </Button>
    </div>
  );
}
