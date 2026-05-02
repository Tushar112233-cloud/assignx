"use client";

import { useEffect, useState } from "react";
import { Clock, AlertCircle } from "lucide-react";
import { cn } from "@/lib/utils";

interface AutoApprovalTimerProps {
  deadline: string;
  className?: string;
}

interface TimeLeft {
  hours: number;
  minutes: number;
  seconds: number;
  totalSeconds: number;
}

/**
 * Calculate time remaining until deadline
 */
function calculateTimeLeft(deadline: string): TimeLeft {
  const now = new Date();
  const deadlineDate = new Date(deadline);
  const diffMs = deadlineDate.getTime() - now.getTime();

  if (diffMs <= 0) {
    return { hours: 0, minutes: 0, seconds: 0, totalSeconds: 0 };
  }

  const totalSeconds = Math.floor(diffMs / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  return { hours, minutes, seconds, totalSeconds };
}

/**
 * Auto-approval countdown timer
 * Shows remaining time before auto-approval
 */
export function AutoApprovalTimer({
  deadline,
  className,
}: AutoApprovalTimerProps) {
  const [timeLeft, setTimeLeft] = useState<TimeLeft>(() =>
    calculateTimeLeft(deadline)
  );

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeLeft(calculateTimeLeft(deadline));
    }, 1000);

    return () => clearInterval(timer);
  }, [deadline]);

  // Determine urgency level
  const isUrgent = timeLeft.hours < 6;
  const isExpired = timeLeft.totalSeconds <= 0;

  if (isExpired) {
    return (
      <div
        className={cn(
          "flex items-center gap-2 rounded-lg bg-green-100 px-3 py-2 text-sm text-green-700 dark:bg-green-900/30 dark:text-green-400",
          className
        )}
      >
        <AlertCircle className="h-4 w-4" />
        <span>Auto-approved</span>
      </div>
    );
  }

  // Format time display
  const formatTime = () => {
    const parts: string[] = [];
    if (timeLeft.hours > 0) {
      parts.push(`${timeLeft.hours}h`);
    }
    parts.push(`${timeLeft.minutes.toString().padStart(2, "0")}m`);
    parts.push(`${timeLeft.seconds.toString().padStart(2, "0")}s`);
    return parts.join(" ");
  };

  return (
    <div
      className={cn(
        "flex items-center gap-2 rounded-lg px-3 py-2 text-sm",
        isUrgent
          ? "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400"
          : "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400",
        className
      )}
    >
      <Clock className={cn("h-4 w-4", isUrgent && "animate-pulse")} />
      <span>
        Auto-approves in <strong>{formatTime()}</strong>
      </span>
    </div>
  );
}
