"use client";

import { useState, useEffect } from "react";
import { Clock, AlertTriangle } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";

interface DeadlineCountdownProps {
  deadline?: string | null;
  className?: string;
}

interface TimeLeft {
  days: number;
  hours: number;
  minutes: number;
  isOverdue: boolean;
}

/**
 * Calculate time remaining until deadline
 */
function calculateTimeLeft(deadline: string): TimeLeft {
  const now = new Date().getTime();
  const deadlineTime = new Date(deadline).getTime();
  const difference = deadlineTime - now;

  if (difference <= 0) {
    return { days: 0, hours: 0, minutes: 0, isOverdue: true };
  }

  return {
    days: Math.floor(difference / (1000 * 60 * 60 * 24)),
    hours: Math.floor((difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)),
    minutes: Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60)),
    isOverdue: false,
  };
}

/**
 * Get color classes based on time remaining
 */
function getColorClasses(timeLeft: TimeLeft): {
  bg: string;
  text: string;
  icon: string;
} {
  if (timeLeft.isOverdue) {
    return {
      bg: "bg-red-50 dark:bg-red-900/20",
      text: "text-red-700 dark:text-red-400",
      icon: "text-red-500",
    };
  }

  const totalHours = timeLeft.days * 24 + timeLeft.hours;

  if (totalHours < 24) {
    // Less than 24 hours - red/urgent
    return {
      bg: "bg-red-50 dark:bg-red-900/20",
      text: "text-red-700 dark:text-red-400",
      icon: "text-red-500",
    };
  }

  if (totalHours < 72) {
    // 1-3 days - yellow/warning
    return {
      bg: "bg-yellow-50 dark:bg-yellow-900/20",
      text: "text-yellow-700 dark:text-yellow-400",
      icon: "text-yellow-500",
    };
  }

  // More than 3 days - green/safe
  return {
    bg: "bg-green-50 dark:bg-green-900/20",
    text: "text-green-700 dark:text-green-400",
    icon: "text-green-500",
  };
}

/**
 * Real-time countdown display for project deadline
 */
export function DeadlineCountdown({
  deadline,
  className,
}: DeadlineCountdownProps) {
  const [timeLeft, setTimeLeft] = useState<TimeLeft>(() =>
    deadline ? calculateTimeLeft(deadline) : { days: 0, hours: 0, minutes: 0, isOverdue: false }
  );

  useEffect(() => {
    if (!deadline) return;

    // Update every minute
    const timer = setInterval(() => {
      setTimeLeft(calculateTimeLeft(deadline));
    }, 60000);

    return () => clearInterval(timer);
  }, [deadline]);

  if (!deadline) return null;

  const colors = getColorClasses(timeLeft);

  return (
    <Card className={cn(colors.bg, "border-0", className)}>
      <CardContent className="flex items-center gap-3 p-4">
        {timeLeft.isOverdue ? (
          <AlertTriangle className={cn("h-5 w-5", colors.icon)} />
        ) : (
          <Clock className={cn("h-5 w-5", colors.icon)} />
        )}

        <div className="flex-1">
          <p className="text-xs text-muted-foreground">Deadline</p>
          {timeLeft.isOverdue ? (
            <p className={cn("text-sm font-semibold", colors.text)}>
              Overdue
            </p>
          ) : (
            <p className={cn("text-sm font-semibold", colors.text)}>
              Due in: {timeLeft.days > 0 && `${timeLeft.days} Days, `}
              {timeLeft.hours} Hours, {timeLeft.minutes} Min
            </p>
          )}
        </div>

        <div className="text-right">
          <p className="text-xs text-muted-foreground">
            {new Date(deadline).toLocaleDateString("en-IN", {
              day: "numeric",
              month: "short",
              year: "numeric",
            })}
          </p>
          <p className="text-xs text-muted-foreground">
            {new Date(deadline).toLocaleTimeString("en-IN", {
              hour: "2-digit",
              minute: "2-digit",
            })}
          </p>
        </div>
      </CardContent>
    </Card>
  );
}
