"use client";

import { cn } from "@/lib/utils";

interface ProgressBarProps {
  progress: number;
  className?: string;
  showLabel?: boolean;
  size?: "sm" | "md" | "lg";
}

/**
 * Visual progress bar for project completion
 * Shows percentage with color gradient
 */
export function ProgressBar({
  progress,
  className,
  showLabel = false,
  size = "sm",
}: ProgressBarProps) {
  // Clamp progress between 0 and 100
  const clampedProgress = Math.min(100, Math.max(0, progress));

  // Determine color based on progress
  const getProgressColor = () => {
    if (clampedProgress >= 100) return "bg-green-500";
    if (clampedProgress >= 70) return "bg-blue-500";
    if (clampedProgress >= 30) return "bg-yellow-500";
    return "bg-orange-500";
  };

  const sizeClasses = {
    sm: "h-1.5",
    md: "h-2",
    lg: "h-3",
  };

  return (
    <div className={cn("w-full", className)}>
      {showLabel && (
        <div className="mb-1 flex justify-between text-xs text-muted-foreground">
          <span>Progress</span>
          <span>{clampedProgress}%</span>
        </div>
      )}
      <div
        className={cn(
          "w-full overflow-hidden rounded-full bg-muted",
          sizeClasses[size]
        )}
      >
        <div
          className={cn(
            "h-full rounded-full transition-all duration-500 ease-out",
            getProgressColor()
          )}
          style={{ width: `${clampedProgress}%` }}
        />
      </div>
    </div>
  );
}
