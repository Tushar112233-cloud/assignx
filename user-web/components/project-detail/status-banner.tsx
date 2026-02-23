"use client";

import {
  Clock,
  FileCheck,
  CreditCard,
  UserCheck,
  Loader2,
  CheckCircle,
  XCircle,
  RotateCcw,
} from "lucide-react";
import { cn } from "@/lib/utils";
import type { ProjectStatus } from "@/types/project";
import { STATUS_CONFIG } from "@/types/project";

interface StatusBannerProps {
  status: ProjectStatus;
  className?: string;
}

/**
 * Get icon for status
 */
function getStatusIcon(status: ProjectStatus) {
  const iconClass = "h-3 w-3";

  switch (status) {
    case "analyzing":
    case "quoted":
      return <Clock className={iconClass} />;
    case "payment_pending":
      return <CreditCard className={iconClass} />;
    case "paid":
    case "assigned":
      return <UserCheck className={iconClass} />;
    case "in_progress":
      return <Loader2 className={cn(iconClass, "animate-spin")} />;
    case "delivered":
    case "qc_approved":
      return <FileCheck className={iconClass} />;
    case "completed":
      return <CheckCircle className={iconClass} />;
    case "cancelled":
      return <XCircle className={iconClass} />;
    case "refunded":
      return <RotateCcw className={iconClass} />;
    default:
      return <Clock className={iconClass} />;
  }
}

/**
 * Compact status badge/chip
 */
export function StatusBanner({ status, className }: StatusBannerProps) {
  const config = STATUS_CONFIG[status];

  return (
    <div
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium",
        config.bgClass,
        config.textClass,
        className
      )}
    >
      {getStatusIcon(status)}
      <span>{config.label}</span>
    </div>
  );
}
