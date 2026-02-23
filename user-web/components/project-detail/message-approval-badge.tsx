"use client"

import { Clock, Check, X } from "lucide-react"
import { cn } from "@/lib/utils"
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip"

/**
 * Message approval status type
 */
export type MessageApprovalStatus = "pending" | "approved" | "rejected"

/**
 * Props for MessageApprovalBadge component
 */
interface MessageApprovalBadgeProps {
  /** Current approval status of the message */
  status: MessageApprovalStatus
  /** Name of the supervisor who approved/rejected */
  approvedBy?: string
  /** Timestamp when the message was approved/rejected */
  approvedAt?: string
  /** Reason for rejection (if rejected) */
  rejectionReason?: string
  /** Additional CSS classes */
  className?: string
  /** Size variant */
  size?: "sm" | "md"
}

/**
 * Status configuration mapping
 */
const statusConfig: Record<
  MessageApprovalStatus,
  {
    icon: typeof Clock
    label: string
    bgColor: string
    iconColor: string
    borderColor: string
  }
> = {
  pending: {
    icon: Clock,
    label: "Pending Approval",
    bgColor: "bg-amber-100 dark:bg-amber-900/30",
    iconColor: "text-amber-600 dark:text-amber-400",
    borderColor: "border-amber-200 dark:border-amber-700",
  },
  approved: {
    icon: Check,
    label: "Approved",
    bgColor: "bg-emerald-100 dark:bg-emerald-900/30",
    iconColor: "text-emerald-600 dark:text-emerald-400",
    borderColor: "border-emerald-200 dark:border-emerald-700",
  },
  rejected: {
    icon: X,
    label: "Rejected",
    bgColor: "bg-red-100 dark:bg-red-900/30",
    iconColor: "text-red-600 dark:text-red-400",
    borderColor: "border-red-200 dark:border-red-700",
  },
}

/**
 * Format timestamp for tooltip display
 */
function formatTimestamp(timestamp: string): string {
  const date = new Date(timestamp)
  return date.toLocaleString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  })
}

/**
 * MessageApprovalBadge component
 *
 * Displays message approval status as a small badge on the message bubble.
 * Shows pending (yellow), approved (green), or rejected (red) status.
 *
 * @example
 * ```tsx
 * <MessageApprovalBadge
 *   status="pending"
 *   className="absolute -bottom-1 -right-1"
 * />
 *
 * <MessageApprovalBadge
 *   status="approved"
 *   approvedBy="John Doe"
 *   approvedAt="2024-01-15T10:30:00Z"
 * />
 *
 * <MessageApprovalBadge
 *   status="rejected"
 *   approvedBy="Jane Smith"
 *   rejectionReason="Message contains inappropriate content"
 * />
 * ```
 */
export function MessageApprovalBadge({
  status,
  approvedBy,
  approvedAt,
  rejectionReason,
  className,
  size = "sm",
}: MessageApprovalBadgeProps) {
  const config = statusConfig[status]
  const Icon = config.icon

  const sizeClasses = {
    sm: "h-4 w-4 p-0.5",
    md: "h-5 w-5 p-1",
  }

  const iconSizeClasses = {
    sm: "h-2.5 w-2.5",
    md: "h-3 w-3",
  }

  // Build tooltip content
  const tooltipLines: string[] = [config.label]

  if (approvedBy) {
    tooltipLines.push(`By: ${approvedBy}`)
  }

  if (approvedAt) {
    tooltipLines.push(`At: ${formatTimestamp(approvedAt)}`)
  }

  if (rejectionReason && status === "rejected") {
    tooltipLines.push(`Reason: ${rejectionReason}`)
  }

  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <div
          className={cn(
            "inline-flex items-center justify-center rounded-full border shadow-sm",
            config.bgColor,
            config.borderColor,
            sizeClasses[size],
            className
          )}
          role="status"
          aria-label={config.label}
        >
          <Icon className={cn(iconSizeClasses[size], config.iconColor)} />
        </div>
      </TooltipTrigger>
      <TooltipContent
        side="top"
        className="max-w-xs text-left"
      >
        <div className="space-y-0.5">
          {tooltipLines.map((line, index) => (
            <p
              key={index}
              className={cn(
                "text-xs",
                index === 0 && "font-medium"
              )}
            >
              {line}
            </p>
          ))}
        </div>
      </TooltipContent>
    </Tooltip>
  )
}

/**
 * MessageApprovalBadgeInline component
 *
 * Inline variant of the approval badge for use within message content.
 * Shows status as text with icon for clearer visibility.
 */
export function MessageApprovalBadgeInline({
  status,
  rejectionReason,
  className,
}: Pick<MessageApprovalBadgeProps, "status" | "rejectionReason" | "className">) {
  const config = statusConfig[status]
  const Icon = config.icon

  return (
    <div
      className={cn(
        "inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-medium",
        config.bgColor,
        config.iconColor,
        className
      )}
    >
      <Icon className="h-3 w-3" />
      <span>{config.label}</span>
      {rejectionReason && status === "rejected" && (
        <span className="ml-1 font-normal opacity-80">
          - {rejectionReason}
        </span>
      )}
    </div>
  )
}

export default MessageApprovalBadge
