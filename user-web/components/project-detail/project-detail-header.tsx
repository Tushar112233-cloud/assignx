"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowLeft, MoreVertical, XCircle, Headphones, FileText, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { cn } from "@/lib/utils";
import { generateInvoiceHTML } from "@/lib/actions/invoice";
import { toast } from "sonner";
import type { ProjectStatus } from "@/types/project";

interface ProjectDetailHeaderProps {
  title: string;
  projectNumber?: string;
  projectId?: string;
  status?: ProjectStatus;
  onCancelProject?: () => void;
  onContactSupport?: () => void;
  className?: string;
}

/**
 * Sticky header for project detail page
 * Includes back navigation, title, and kebab menu
 */
export function ProjectDetailHeader({
  title,
  projectNumber,
  projectId,
  status,
  onCancelProject,
  onContactSupport,
  className,
}: ProjectDetailHeaderProps) {
  const router = useRouter();
  const [isDownloadingInvoice, setIsDownloadingInvoice] = useState(false);

  const handleBack = () => {
    router.push("/projects");
  };

  const handleDownloadInvoice = async () => {
    if (!projectId) {
      toast.error("Project ID not available");
      return;
    }

    setIsDownloadingInvoice(true);
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
      setIsDownloadingInvoice(false);
    }
  };

  // Check if invoice should be available (completed or delivered projects)
  const showInvoice = status === "completed" || status === "delivered" || status === "qc_approved";

  return (
    <header
      className={cn(
        "sticky top-0 z-40 flex h-14 items-center justify-between border-b bg-background px-4",
        className
      )}
    >
      {/* Left: Back button + Title */}
      <div className="flex items-center gap-3 min-w-0">
        <Button
          variant="ghost"
          size="icon"
          onClick={handleBack}
          className="shrink-0"
        >
          <ArrowLeft className="h-5 w-5" />
          <span className="sr-only">Back to projects</span>
        </Button>

        <div className="min-w-0">
          <h1 className="truncate text-sm font-semibold">{title}</h1>
          {projectNumber && <p className="text-xs text-muted-foreground">{projectNumber}</p>}
        </div>
      </div>

      {/* Right: Kebab menu */}
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon" className="shrink-0">
            <MoreVertical className="h-5 w-5" />
            <span className="sr-only">More options</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          {showInvoice && (
            <>
              <DropdownMenuItem
                onClick={handleDownloadInvoice}
                disabled={isDownloadingInvoice}
                className="gap-2"
              >
                {isDownloadingInvoice ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <FileText className="h-4 w-4" />
                )}
                Download Invoice
              </DropdownMenuItem>
              <DropdownMenuSeparator />
            </>
          )}
          <DropdownMenuItem
            onClick={onContactSupport}
            className="gap-2"
          >
            <Headphones className="h-4 w-4" />
            Contact Support
          </DropdownMenuItem>
          <DropdownMenuItem
            onClick={onCancelProject}
            className="gap-2 text-destructive focus:text-destructive"
          >
            <XCircle className="h-4 w-4" />
            Cancel Project
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </header>
  );
}
