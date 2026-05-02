"use client";

import { Button } from "@/components/ui/button";
import { StatusBadge } from "./status-badge";
import { cn } from "@/lib/utils";
import type { ProjectStatus } from "@/types/project";

interface ProjectCardFooterProps {
  status: ProjectStatus;
  quoteAmount?: number;
  progress?: number;
  onAction?: () => void;
  className?: string;
}

/**
 * Get action button config based on status
 */
function getActionConfig(status: ProjectStatus): {
  label: string;
  variant: "default" | "secondary" | "outline" | "destructive";
  disabled: boolean;
} {
  switch (status) {
    case "analyzing":
      return { label: "View Details", variant: "outline", disabled: true };
    case "quoted":
    case "payment_pending":
      return { label: "Pay Now", variant: "default", disabled: false };
    case "paid":
    case "assigned":
    case "in_progress":
      return { label: "View Details", variant: "secondary", disabled: false };
    case "delivered":
    case "qc_approved":
      return { label: "Review", variant: "default", disabled: false };
    case "completed":
      return { label: "View Details", variant: "outline", disabled: false };
    case "cancelled":
    case "refunded":
      return { label: "View Details", variant: "outline", disabled: false };
    default:
      return { label: "View", variant: "outline", disabled: false };
  }
}

/**
 * Project card footer with status badge and action button
 */
export function ProjectCardFooter({
  status,
  quoteAmount,
  progress,
  onAction,
  className,
}: ProjectCardFooterProps) {
  const actionConfig = getActionConfig(status);

  return (
    <div className={cn("flex items-center justify-between gap-3", className)}>
      <StatusBadge
        status={status}
        quoteAmount={quoteAmount}
        progress={progress}
      />
      <Button
        variant={actionConfig.variant}
        size="sm"
        disabled={actionConfig.disabled}
        onClick={onAction}
        className="shrink-0"
      >
        {actionConfig.label}
      </Button>
    </div>
  );
}
