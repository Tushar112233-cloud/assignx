"use client";

import { useState } from "react";
import { FileText, Download, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface InvoiceDownloadProps {
  projectId: string;
  projectNumber: string;
  className?: string;
}

/**
 * Invoice download button component
 * Downloads invoice PDF for completed projects
 */
export function InvoiceDownload({
  projectId,
  projectNumber,
  className,
}: InvoiceDownloadProps) {
  const [isDownloading, setIsDownloading] = useState(false);

  const handleDownload = async () => {
    setIsDownloading(true);

    try {
      // Fetch invoice from API
      const response = await fetch(`/api/invoices/${projectId}`);

      if (!response.ok) {
        throw new Error("Failed to generate invoice");
      }

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const fileName = `Invoice_${projectNumber.replace("#", "")}.pdf`;

      // Trigger download
      const link = document.createElement("a");
      link.href = url;
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      // Cleanup
      window.URL.revokeObjectURL(url);
      toast.success(`Invoice downloaded: ${fileName}`);
    } catch {
      toast.error("Failed to download invoice. Please try again.");
    } finally {
      setIsDownloading(false);
    }
  };

  return (
    <Button
      variant="outline"
      size="sm"
      onClick={handleDownload}
      disabled={isDownloading}
      className={cn("gap-2", className)}
    >
      {isDownloading ? (
        <>
          <Loader2 className="h-4 w-4 animate-spin" />
          Downloading...
        </>
      ) : (
        <>
          <FileText className="h-4 w-4" />
          Download Invoice
        </>
      )}
    </Button>
  );
}
