"use client";

import { cn } from "@/lib/utils";
import { SkeletonHero, SkeletonStatsRow, SkeletonFilterPills } from "../composites";
import { SkeletonProjectCard } from "../composites";
import { SkeletonBox } from "../primitives";

interface ProjectsSkeletonProps {
  className?: string;
}

/**
 * Full page skeleton for Projects (/projects)
 * Matches the unified layout structure
 */
export function ProjectsSkeleton({ className }: ProjectsSkeletonProps) {
  return (
    <div className={cn("space-y-6 p-4 md:p-6", className)}>
      {/* Hero Section */}
      <SkeletonHero height={120} delay={0} showButton />

      {/* Quick Actions Bar */}
      <div className="flex items-center justify-between gap-4">
        <SkeletonFilterPills count={4} delay={100} />
        <SkeletonBox width={200} height={40} rounded="lg" delay={200} />
      </div>

      {/* Stats Row */}
      <SkeletonStatsRow delay={250} />

      {/* Projects List */}
      <div className="space-y-4">
        {[1, 2, 3, 4].map((i) => (
          <SkeletonProjectCard key={i} variant="full" delay={400 + i * 75} />
        ))}
      </div>
    </div>
  );
}
