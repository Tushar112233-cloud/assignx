"use client";

import { Check, Circle, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";
import type { ProjectStatus } from "@/types/project";

interface TimelineMilestone {
  id: string;
  label: string;
  shortLabel: string;
}

const milestones: TimelineMilestone[] = [
  { id: "submitted", label: "Submitted", shortLabel: "Submit" },
  { id: "analyzed", label: "Analyzed", shortLabel: "Analyze" },
  { id: "paid", label: "Paid", shortLabel: "Paid" },
  { id: "assigned", label: "Assigned", shortLabel: "Assign" },
  { id: "in_progress", label: "In Progress", shortLabel: "Working" },
  { id: "qc", label: "QC Check", shortLabel: "QC" },
  { id: "delivered", label: "Delivered", shortLabel: "Done" },
];

/**
 * Map project status to milestone completion
 */
function getMilestoneStatus(
  milestoneId: string,
  projectStatus: ProjectStatus
): "completed" | "current" | "pending" {
  const statusOrder: Record<string, number> = {
    submitted: 0,
    analyzing: 1,
    quoted: 1,
    payment_pending: 1,
    analyzed: 1,
    paid: 2,
    assigned: 3,
    in_progress: 4,
    qc: 5,
    qc_approved: 5,
    delivered: 6,
    completed: 7,
  };

  const milestoneOrder: Record<string, number> = {
    submitted: 0,
    analyzed: 1,
    paid: 2,
    assigned: 3,
    in_progress: 4,
    qc: 5,
    delivered: 6,
  };

  const currentStep = statusOrder[projectStatus] ?? 0;
  const milestoneStep = milestoneOrder[milestoneId] ?? 0;

  if (milestoneStep < currentStep) return "completed";
  if (milestoneStep === currentStep) return "current";
  return "pending";
}

interface ProjectTimelineProps {
  status: ProjectStatus;
  className?: string;
}

/**
 * Horizontal milestone stepper for project progress
 */
export function ProjectTimeline({ status, className }: ProjectTimelineProps) {
  // Don't show timeline for cancelled/refunded
  if (status === "cancelled" || status === "refunded") {
    return null;
  }

  return (
    <div className={cn("w-full overflow-x-auto", className)}>
      <div className="flex min-w-max items-center justify-between px-2">
        {milestones.map((milestone, index) => {
          const milestoneStatus = getMilestoneStatus(milestone.id, status);
          const isLast = index === milestones.length - 1;

          return (
            <div key={milestone.id} className="flex items-center">
              {/* Milestone Node */}
              <div className="flex flex-col items-center">
                <div
                  className={cn(
                    "flex h-8 w-8 items-center justify-center rounded-full border-2 transition-colors",
                    milestoneStatus === "completed" &&
                      "border-green-500 bg-green-500 text-white",
                    milestoneStatus === "current" &&
                      "border-primary bg-primary text-primary-foreground",
                    milestoneStatus === "pending" &&
                      "border-muted-foreground/30 bg-background text-muted-foreground/50"
                  )}
                >
                  {milestoneStatus === "completed" && (
                    <Check className="h-4 w-4" />
                  )}
                  {milestoneStatus === "current" && (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  )}
                  {milestoneStatus === "pending" && (
                    <Circle className="h-3 w-3" />
                  )}
                </div>
                <span
                  className={cn(
                    "mt-2 text-xs font-medium",
                    milestoneStatus === "completed" && "text-green-600 dark:text-green-400",
                    milestoneStatus === "current" && "text-primary",
                    milestoneStatus === "pending" && "text-muted-foreground/50"
                  )}
                >
                  <span className="hidden sm:inline">{milestone.label}</span>
                  <span className="sm:hidden">{milestone.shortLabel}</span>
                </span>
              </div>

              {/* Connector Line */}
              {!isLast && (
                <div
                  className={cn(
                    "mx-1 h-0.5 w-8 sm:w-12",
                    milestoneStatus === "completed"
                      ? "bg-green-500"
                      : "bg-muted-foreground/20"
                  )}
                />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
