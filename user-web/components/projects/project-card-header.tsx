"use client";

import {
  Laptop,
  TrendingUp,
  Briefcase,
  Leaf,
  Brain,
  Megaphone,
  Users,
  BarChart2,
  BookOpen,
  Atom,
  FlaskConical,
  FileText,
} from "lucide-react";
import { cn } from "@/lib/utils";

interface ProjectCardHeaderProps {
  title: string;
  subjectName?: string;
  subjectIcon?: string;
  className?: string;
}

/**
 * Icon mapping for subject types
 */
const iconMap: Record<string, React.ElementType> = {
  laptop: Laptop,
  "trending-up": TrendingUp,
  briefcase: Briefcase,
  leaf: Leaf,
  brain: Brain,
  megaphone: Megaphone,
  users: Users,
  "bar-chart-2": BarChart2,
  "book-open": BookOpen,
  atom: Atom,
  "flask-conical": FlaskConical,
};

/**
 * Project card header with title and subject icon
 */
export function ProjectCardHeader({
  title,
  subjectName,
  subjectIcon,
  className,
}: ProjectCardHeaderProps) {
  const Icon = (subjectIcon && iconMap[subjectIcon]) || FileText;

  return (
    <div className={cn("flex items-start gap-3", className)}>
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
        <Icon className="h-5 w-5" />
      </div>
      <div className="min-w-0 flex-1">
        <h3 className="truncate font-semibold leading-tight">{title}</h3>
        <p className="text-sm text-muted-foreground">{subjectName || "Project"}</p>
      </div>
    </div>
  );
}
