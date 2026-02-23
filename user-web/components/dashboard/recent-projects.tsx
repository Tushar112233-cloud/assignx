"use client";

/**
 * @fileoverview Premium Recent Projects Section
 *
 * Redesigned with glassmorphism cards and premium styling
 * matching the SAAS dashboard design system.
 */

import { useEffect } from "react";
import Link from "next/link";
import { motion, useReducedMotion } from "framer-motion";
import {
  Plus,
  ArrowRight,
  Clock,
  Loader2,
  FileText,
  BookOpen,
  Calculator,
  Beaker,
  Globe,
  Scale,
  Briefcase,
  Heart,
  Cpu,
  Palette,
  Music,
  Languages,
  GraduationCap,
  Building2,
  Microscope,
  FolderKanban,
  type LucideIcon,
} from "lucide-react";
import { formatDistanceToNow } from "date-fns";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useProjectStore, type Project } from "@/stores";
import { cn } from "@/lib/utils";

/**
 * Icon map for subject icons - avoids wildcard import (~500KB savings)
 */
const SUBJECT_ICONS: Record<string, LucideIcon> = {
  FileText,
  BookOpen,
  Calculator,
  Beaker,
  Globe,
  Scale,
  Briefcase,
  Heart,
  Cpu,
  Palette,
  Music,
  Languages,
  GraduationCap,
  Building2,
  Microscope,
};

/**
 * Status badge colors - premium palette
 */
const statusColors: Record<string, string> = {
  submitted: "dashboard-status-pending",
  analyzing: "dashboard-status-review",
  quoted: "dashboard-status-review",
  payment_pending: "dashboard-status-review",
  paid: "dashboard-status-completed",
  assigned: "dashboard-status-progress",
  in_progress: "dashboard-status-progress",
  delivered: "dashboard-status-progress",
  qc_approved: "dashboard-status-completed",
  completed: "dashboard-status-completed",
  cancelled: "bg-red-100/80 text-red-700 dark:bg-red-900/30 dark:text-red-400",
  refunded: "bg-gray-100/80 text-gray-600 dark:bg-gray-800/50 dark:text-gray-400",
};

/**
 * Format status for display
 */
function formatStatus(status: string): string {
  return status
    .split("_")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

// Animation variants
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 12 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.4,
      ease: [0.16, 1, 0.3, 1] as const,
    },
  },
};

/**
 * Recent projects section for dashboard
 */
export function RecentProjects() {
  const { projects, isLoading, fetchProjects } = useProjectStore();
  const prefersReducedMotion = useReducedMotion();

  useEffect(() => {
    fetchProjects();
  }, [fetchProjects]);

  const recentProjects = projects.slice(0, 3);

  if (isLoading) {
    return (
      <div className="dashboard-activity-card">
        <div className="dashboard-activity-header">
          <div className="dashboard-activity-title">
            <FolderKanban className="h-5 w-5 text-primary" />
            Recent Projects
          </div>
        </div>
        <div className="flex items-center justify-center py-12">
          <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        </div>
      </div>
    );
  }

  if (recentProjects.length === 0) {
    return (
      <div className="dashboard-activity-card">
        <div className="dashboard-activity-header">
          <div className="dashboard-activity-title">
            <FolderKanban className="h-5 w-5 text-primary" />
            Recent Projects
          </div>
        </div>

        <div className="relative text-center py-8">
          {/* Decorative background */}
          <div className="absolute -right-4 -top-4 h-24 w-24 rounded-full bg-primary/5 blur-xl" />
          <div className="absolute -bottom-4 -left-4 h-20 w-20 rounded-full bg-accent/5 blur-xl" />

          <div className="relative z-10">
            <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-primary/15 to-primary/5">
              <Plus className="h-6 w-6 text-primary" />
            </div>
            <h3 className="text-base font-semibold">Start Your First Project</h3>
            <p className="mt-1 text-sm text-muted-foreground/80 max-w-xs mx-auto">
              Get expert help with essays, reports, or any academic task
            </p>
            <Button asChild className="mt-5" size="sm">
              <Link href="/projects/new">
                <Plus className="mr-1.5 h-3.5 w-3.5" />
                New Project
              </Link>
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="dashboard-activity-card">
      <div className="dashboard-activity-header">
        <div className="dashboard-activity-title">
          <FolderKanban className="h-5 w-5 text-primary" />
          Recent Projects
          <span className="dashboard-activity-badge">{recentProjects.length}</span>
        </div>
        <Button variant="ghost" size="sm" asChild className="text-xs h-8">
          <Link href="/projects" className="flex items-center gap-1 text-muted-foreground hover:text-primary transition-colors">
            View all
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </Button>
      </div>

      <motion.div
        variants={prefersReducedMotion ? {} : containerVariants}
        initial="hidden"
        animate="visible"
      >
        {recentProjects.map((project) => (
          <motion.div
            key={project.id}
            variants={prefersReducedMotion ? {} : itemVariants}
          >
            <ProjectCard project={project} />
          </motion.div>
        ))}
      </motion.div>

      <Link href="/projects" className="dashboard-view-all">
        View all projects
        <ArrowRight className="h-4 w-4" />
      </Link>
    </div>
  );
}

/**
 * Individual project card with premium styling
 */
function ProjectCard({ project }: { project: Project }) {
  const iconName = project.subjectIcon || project.subject?.icon;
  const projectNumber = project.projectNumber || project.project_number;
  const createdAt = project.createdAt || project.created_at;
  const Icon = iconName && SUBJECT_ICONS[iconName] ? SUBJECT_ICONS[iconName] : FileText;

  // Map status to dot color
  const getDotColor = (status: string) => {
    if (["completed", "qc_approved", "paid"].includes(status)) return "dashboard-activity-dot-success";
    if (["in_progress", "assigned", "delivered"].includes(status)) return "dashboard-activity-dot-blue";
    if (["analyzing", "quoted", "payment_pending"].includes(status)) return "dashboard-activity-dot-accent";
    return "dashboard-activity-dot-primary";
  };

  return (
    <Link
      href={`/project/${project.id}`}
      className="dashboard-activity-item group cursor-pointer"
    >
      {/* Status dot */}
      <div className={cn("dashboard-activity-dot", getDotColor(project.status))} />

      {/* Content */}
      <div className="dashboard-activity-content">
        <p className="dashboard-activity-name group-hover:text-primary transition-colors">
          {project.title}
        </p>
        <div className="flex items-center gap-2 dashboard-activity-meta">
          <span className="font-mono">{projectNumber}</span>
          <span>•</span>
          <span className="flex items-center gap-1">
            <Clock className="h-3 w-3" />
            {formatDistanceToNow(new Date(createdAt), { addSuffix: true })}
          </span>
        </div>
      </div>

      {/* Status badge */}
      <span className={cn("dashboard-activity-status shrink-0", statusColors[project.status])}>
        {formatStatus(project.status)}
      </span>
    </Link>
  );
}
