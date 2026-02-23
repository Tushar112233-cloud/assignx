"use client";

/**
 * ReportButton - Flag icon button to report listings
 *
 * Features:
 * - Flag icon with hover states
 * - Disabled state when already reported
 * - Opens report dialog on click
 */

import { useState } from "react";
import { motion } from "framer-motion";
import { Flag } from "lucide-react";
import { cn } from "@/lib/utils";
import { ReportDialog } from "./report-dialog";

interface ReportButtonProps {
  /** The listing ID to report */
  listingId: string;
  /** Whether this listing has already been reported by the user */
  isReported?: boolean;
  /** Size variant */
  size?: "sm" | "md" | "lg";
  /** Show label text */
  showLabel?: boolean;
  /** Additional CSS classes */
  className?: string;
  /** Callback when report is submitted */
  onReportSubmitted?: () => void;
}

/**
 * ReportButton - Compact flag button for reporting listings
 */
export function ReportButton({
  listingId,
  isReported = false,
  size = "md",
  showLabel = false,
  className,
  onReportSubmitted,
}: ReportButtonProps) {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [localIsReported, setLocalIsReported] = useState(isReported);

  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!localIsReported) {
      setIsDialogOpen(true);
    }
  };

  const handleReportSuccess = () => {
    setLocalIsReported(true);
    onReportSubmitted?.();
  };

  const sizeConfig = {
    sm: { icon: "h-3.5 w-3.5", text: "text-xs", padding: "p-1.5" },
    md: { icon: "h-4 w-4", text: "text-sm", padding: "p-2" },
    lg: { icon: "h-5 w-5", text: "text-base", padding: "p-2.5" },
  };

  const config = sizeConfig[size];

  return (
    <>
      <motion.button
        onClick={handleClick}
        disabled={localIsReported}
        whileTap={{ scale: localIsReported ? 1 : 0.9 }}
        className={cn(
          "flex items-center gap-1.5 transition-colors rounded-lg",
          localIsReported
            ? "text-amber-600 dark:text-amber-500 cursor-not-allowed"
            : "text-muted-foreground hover:text-amber-600 dark:hover:text-amber-500 hover:bg-amber-50 dark:hover:bg-amber-950/30",
          config.padding,
          className
        )}
        title={localIsReported ? "Already reported" : "Report this listing"}
      >
        <Flag
          className={cn(
            config.icon,
            localIsReported && "fill-amber-500"
          )}
        />
        {showLabel && (
          <span className={cn("font-medium", config.text)}>
            {localIsReported ? "Reported" : "Report"}
          </span>
        )}
      </motion.button>

      <ReportDialog
        listingId={listingId}
        isOpen={isDialogOpen}
        onOpenChange={setIsDialogOpen}
        onSuccess={handleReportSuccess}
      />
    </>
  );
}

/**
 * ReportButtonOutline - Outlined version with background
 */
export function ReportButtonOutline({
  listingId,
  isReported = false,
  className,
  onReportSubmitted,
}: ReportButtonProps) {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [localIsReported, setLocalIsReported] = useState(isReported);

  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!localIsReported) {
      setIsDialogOpen(true);
    }
  };

  const handleReportSuccess = () => {
    setLocalIsReported(true);
    onReportSubmitted?.();
  };

  return (
    <>
      <motion.button
        onClick={handleClick}
        disabled={localIsReported}
        whileTap={{ scale: localIsReported ? 1 : 0.95 }}
        className={cn(
          "flex items-center gap-2 px-4 py-2 rounded-full border transition-all",
          localIsReported
            ? "bg-amber-50 border-amber-200 text-amber-700 dark:bg-amber-950/30 dark:border-amber-800 dark:text-amber-400 cursor-not-allowed"
            : "bg-card border-border hover:bg-amber-50 hover:border-amber-200 hover:text-amber-700 dark:hover:bg-amber-950/30 dark:hover:border-amber-800",
          className
        )}
        title={localIsReported ? "Already reported" : "Report this listing"}
      >
        <Flag
          className={cn(
            "h-4 w-4",
            localIsReported && "fill-amber-500"
          )}
        />
        <span className="font-medium text-sm">
          {localIsReported ? "Reported" : "Report"}
        </span>
      </motion.button>

      <ReportDialog
        listingId={listingId}
        isOpen={isDialogOpen}
        onOpenChange={setIsDialogOpen}
        onSuccess={handleReportSuccess}
      />
    </>
  );
}

export default ReportButton;
