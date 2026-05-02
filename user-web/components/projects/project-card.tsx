"use client";

import { memo } from "react";
import Link from "next/link";
import { Card, CardContent } from "@/components/ui/card";
import { ProjectCardHeader } from "./project-card-header";
import { ProjectCardBody } from "./project-card-body";
import { ProjectCardFooter } from "./project-card-footer";
import { cn } from "@/lib/utils";
import type { Project } from "@/stores";

interface ProjectCardProps {
  project: Project;
  onPayNow?: (project: Project) => void;
  className?: string;
}

/**
 * Complete project card component
 * Combines header, body, and footer
 * Supports both old camelCase and new snake_case field names
 * Memoized for performance in lists
 */
export const ProjectCard = memo(function ProjectCard({ project, onPayNow, className }: ProjectCardProps) {
  // Get values supporting both old and new field names
  const title = project.title;
  const subjectName = project.subjectName || project.subject?.name;
  const subjectIcon = project.subjectIcon || project.subject?.icon;
  const projectNumber = project.projectNumber || project.project_number;
  const deadline = project.deadline;
  const progress = project.progress ?? project.progress_percentage ?? 0;
  const quoteAmount = project.quoteAmount || project.final_quote || project.user_quote || undefined;

  const handleAction = () => {
    // Handle Pay Now action for payment pending projects
    if (
      (project.status === "payment_pending" || project.status === "quoted") &&
      onPayNow
    ) {
      onPayNow(project);
      return;
    }

    // For other statuses, navigation is handled by the Link wrapper
  };

  const isPaymentAction =
    project.status === "payment_pending" || project.status === "quoted";

  const cardContent = (
    <Card
      className={cn(
        "transition-all duration-200 hover:shadow-md",
        isPaymentAction && "border-orange-200 dark:border-orange-800",
        className
      )}
    >
      <CardContent className="space-y-4 p-4">
        <ProjectCardHeader
          title={title}
          subjectName={subjectName}
          subjectIcon={subjectIcon}
        />
        <ProjectCardBody
          projectNumber={projectNumber}
          deadline={deadline}
          progress={progress}
          status={project.status}
        />
        <ProjectCardFooter
          status={project.status}
          quoteAmount={quoteAmount}
          progress={progress}
          onAction={handleAction}
        />
      </CardContent>
    </Card>
  );

  // Wrap in Link for non-payment actions
  if (!isPaymentAction) {
    return (
      <Link href={`/project/${project.id}`} className="block">
        {cardContent}
      </Link>
    );
  }

  return cardContent;
});
