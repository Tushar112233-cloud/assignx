"use client";

import { Hash } from "lucide-react";
import { cn } from "@/lib/utils";
import { DeadlineDisplay } from "./deadline-display";
import { ProgressBar } from "./progress-bar";
import type { ProjectStatus } from "@/types/project";

interface ProjectCardBodyProps {
  projectNumber?: string;
  deadline?: string | null;
  progress: number;
  status: ProjectStatus;
  className?: string;
}

/**
 * Project card body with ID, deadline, and progress
 */
export function ProjectCardBody({
  projectNumber,
  deadline,
  progress,
  status,
  className,
}: ProjectCardBodyProps) {
  // Show progress bar only for active statuses
  const showProgress = ["paid", "assigned", "in_progress"].includes(status);

  return (
    <div className={cn("space-y-3", className)}>
      {/* Project ID and Deadline Row */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1.5 text-sm text-muted-foreground">
          <Hash className="h-3.5 w-3.5" />
          <span className="font-mono">{(projectNumber || "").replace("#", "")}</span>
        </div>
        {deadline && <DeadlineDisplay deadline={deadline} />}
      </div>

      {/* Progress Bar */}
      {showProgress && progress > 0 && (
        <ProgressBar progress={progress} showLabel size="sm" />
      )}
    </div>
  );
}
