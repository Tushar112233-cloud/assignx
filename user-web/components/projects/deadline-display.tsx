"use client";

import { useMemo } from "react";
import { Clock, AlertTriangle, CheckCircle } from "lucide-react";
import { cn } from "@/lib/utils";

interface DeadlineDisplayProps {
  deadline: string;
  className?: string;
  showIcon?: boolean;
}

/**
 * Color-coded deadline display
 * Red: < 24h, Orange: < 3 days, Green: > 3 days, Gray: Past
 */
export function DeadlineDisplay({
  deadline,
  className,
  showIcon = true,
}: DeadlineDisplayProps) {
  const { text, colorClass, Icon, isPast } = useMemo(() => {
    const now = new Date();
    const deadlineDate = new Date(deadline);
    const diffMs = deadlineDate.getTime() - now.getTime();
    const diffHours = diffMs / (1000 * 60 * 60);
    const diffDays = diffHours / 24;

    // Past deadline
    if (diffMs < 0) {
      return {
        text: "Past deadline",
        colorClass: "text-muted-foreground",
        Icon: CheckCircle,
        isPast: true,
      };
    }

    // Less than 24 hours
    if (diffHours < 24) {
      const hours = Math.floor(diffHours);
      const minutes = Math.floor((diffHours - hours) * 60);
      return {
        text: `${hours}h ${minutes}m left`,
        colorClass: "text-red-600 dark:text-red-400",
        Icon: AlertTriangle,
        isPast: false,
      };
    }

    // Less than 3 days
    if (diffDays < 3) {
      const days = Math.floor(diffDays);
      const hours = Math.floor((diffDays - days) * 24);
      return {
        text: `${days}d ${hours}h left`,
        colorClass: "text-orange-600 dark:text-orange-400",
        Icon: Clock,
        isPast: false,
      };
    }

    // More than 3 days
    const days = Math.floor(diffDays);
    return {
      text: `${days} days left`,
      colorClass: "text-green-600 dark:text-green-400",
      Icon: Clock,
      isPast: false,
    };
  }, [deadline]);

  return (
    <div className={cn("flex items-center gap-1.5 text-sm", colorClass, className)}>
      {showIcon && <Icon className="h-4 w-4" />}
      <span className={cn(isPast && "line-through")}>{text}</span>
    </div>
  );
}
