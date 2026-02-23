"use client";

import { useState } from "react";
import { FileText, Download, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { generateInvoiceHTML } from "@/lib/actions/invoice";
import { toast } from "sonner";

interface InvoiceDownloadButtonProps {
  projectId: string;
  projectNumber: string;
  variant?: "default" | "outline" | "ghost";
  size?: "default" | "sm" | "lg" | "icon";
  className?: string;
}

/**
 * Invoice Download Button Component
 * Downloads invoice as PDF for completed projects
 * Implements U37 from feature spec
 */
export function InvoiceDownloadButton({
  projectId,
  projectNumber,
  variant = "outline",
  size = "sm",
  className,
}: InvoiceDownloadButtonProps) {
  const [isLoading, setIsLoading] = useState(false);

  const handleDownload = async () => {
    setIsLoading(true);

    try {
      const invoiceHTML = await generateInvoiceHTML(projectId);

      if (!invoiceHTML) {
        toast.error("Invoice not available for this project");
        return;
      }

      // Create a new window with the invoice HTML
      const printWindow = window.open("", "_blank");
      if (!printWindow) {
        toast.error("Please allow popups to download invoice");
        return;
      }

      printWindow.document.write(invoiceHTML);
      printWindow.document.close();

      // Wait for content to load then trigger print
      printWindow.onload = () => {
        printWindow.focus();
        printWindow.print();
      };

      toast.success("Invoice opened for download");
    } catch (error) {
      console.error("Error generating invoice:", error);
      toast.error("Failed to generate invoice");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Button
      variant={variant}
      size={size}
      onClick={handleDownload}
      disabled={isLoading}
      className={className}
    >
      {isLoading ? (
        <Loader2 className="h-4 w-4 animate-spin" />
      ) : (
        <FileText className="h-4 w-4" />
      )}
      <span className="ml-2">Invoice</span>
    </Button>
  );
}
