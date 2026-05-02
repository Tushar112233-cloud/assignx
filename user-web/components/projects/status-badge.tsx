"use client";

import { cn } from "@/lib/utils";
import type { ProjectStatus } from "@/types/project";
import { STATUS_CONFIG } from "@/types/project";

interface StatusBadgeProps {
  status: ProjectStatus;
  quoteAmount?: number;
  progress?: number;
  className?: string;
}

/**
 * Color-coded status badge for project cards
 * Displays dynamic text based on status type
 */
export function StatusBadge({
  status,
  quoteAmount,
  progress,
  className,
}: StatusBadgeProps) {
  const config = STATUS_CONFIG[status];

  // Generate dynamic label based on status
  const getLabel = () => {
    switch (status) {
      case "payment_pending":
        return `Payment pending: ₹${quoteAmount || 0}`;
      case "in_progress":
        return progress ? `${progress}% Completed` : "Expert Working";
      default:
        return config.label;
    }
  };

  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium",
        config.bgClass,
        config.textClass,
        config.borderClass,
        className
      )}
    >
      {getLabel()}
    </span>
  );
}
