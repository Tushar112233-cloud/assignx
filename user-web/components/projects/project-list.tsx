"use client";

import { useEffect } from "react";
import Link from "next/link";
import { FolderOpen, Loader2, Plus, FileText, Clock, CheckCircle2 } from "lucide-react";
import { useProjectStore, type Project } from "@/stores";
import { ProjectCard } from "./project-card";
import { Pagination } from "@/components/ui/pagination";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface ProjectListProps {
  onPayNow?: (project: Project) => void;
  className?: string;
}

/**
 * Empty state component with enhanced visuals
 */
function EmptyState() {
  return (
    <div className="relative overflow-hidden rounded-xl border border-dashed bg-gradient-to-br from-muted/30 to-muted/10 py-16 text-center">
      {/* Decorative background */}
      <div className="absolute -right-8 -top-8 h-32 w-32 rounded-full bg-primary/5" />
      <div className="absolute -bottom-8 -left-8 h-24 w-24 rounded-full bg-primary/5" />
      <div className="absolute right-1/4 top-1/4 h-16 w-16 rounded-full bg-blue-500/5" />

      <div className="relative z-10 flex flex-col items-center">
        <div className="mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-primary/20 to-primary/5">
          <FolderOpen className="h-10 w-10 text-primary" />
        </div>
        <h3 className="mb-2 text-xl font-semibold">No projects in this category</h3>
        <p className="mb-6 max-w-sm text-sm text-muted-foreground">
          When you submit projects, they&apos;ll appear here based on their status.
        </p>

        {/* Quick info */}
        <div className="mb-6 flex flex-wrap items-center justify-center gap-4 text-xs text-muted-foreground">
          <div className="flex items-center gap-1.5">
            <FileText className="h-3.5 w-3.5 text-blue-500" />
            <span>Submit projects</span>
          </div>
          <div className="flex items-center gap-1.5">
            <Clock className="h-3.5 w-3.5 text-yellow-500" />
            <span>Track progress</span>
          </div>
          <div className="flex items-center gap-1.5">
            <CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
            <span>Get delivered</span>
          </div>
        </div>

        <Button asChild size="sm">
          <Link href="/projects/new">
            <Plus className="mr-2 h-4 w-4" />
            Start New Project
          </Link>
        </Button>
      </div>
    </div>
  );
}

/**
 * Loading skeleton
 */
function LoadingSkeleton() {
  return (
    <div className="flex flex-col items-center justify-center py-12">
      <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      <p className="mt-2 text-sm text-muted-foreground">Loading projects...</p>
    </div>
  );
}

/**
 * Project list container with pagination
 * Fetches and displays projects filtered by active tab
 */
export function ProjectList({ onPayNow, className }: ProjectListProps) {
  const {
    activeTab,
    getPaginatedProjects,
    isLoading,
    fetchProjects,
    setPage,
  } = useProjectStore();

  const { projects, totalCount, totalPages, currentPage } =
    getPaginatedProjects(activeTab);

  // Fetch projects on mount
  useEffect(() => {
    fetchProjects();
  }, [fetchProjects]);

  if (isLoading) {
    return <LoadingSkeleton />;
  }

  if (totalCount === 0) {
    return <EmptyState />;
  }

  return (
    <div className={cn("space-y-4", className)}>
      {/* Results count */}
      <p className="text-sm text-muted-foreground">
        Showing {projects.length} of {totalCount} projects
      </p>

      {/* Project cards */}
      <div className="space-y-4">
        {projects.map((project) => (
          <ProjectCard key={project.id} project={project} onPayNow={onPayNow} />
        ))}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <Pagination
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={setPage}
          className="mt-6"
        />
      )}
    </div>
  );
}
