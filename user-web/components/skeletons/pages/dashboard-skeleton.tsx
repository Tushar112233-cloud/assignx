"use client";

import { cn } from "@/lib/utils";
import { SkeletonHero, SkeletonStatsRow } from "../composites";
import { SkeletonProjectCard, SkeletonActivityItem } from "../composites";
import { SkeletonText } from "../primitives";

interface DashboardSkeletonProps {
  className?: string;
}

/**
 * Full page skeleton for Dashboard (/home)
 * Matches the unified layout structure
 */
export function DashboardSkeleton({ className }: DashboardSkeletonProps) {
  return (
    <div className={cn("space-y-6 p-4 md:p-6", className)}>
      {/* Hero Section */}
      <SkeletonHero height={140} delay={0} />

      {/* Stats Row */}
      <SkeletonStatsRow delay={100} />

      {/* Recent Projects Section */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <SkeletonText width={150} lineHeight={24} delay={300} />
          <SkeletonText width={80} lineHeight={16} delay={350} />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3].map((i) => (
            <SkeletonProjectCard key={i} delay={400 + i * 75} />
          ))}
        </div>
      </div>

      {/* Activity Feed Section */}
      <div className="space-y-4">
        <SkeletonText width={140} lineHeight={24} delay={650} />

        <div className="rounded-xl border border-border bg-card p-4">
          <div className="space-y-1 divide-y divide-border">
            {[1, 2, 3, 4, 5].map((i) => (
              <SkeletonActivityItem key={i} delay={700 + i * 50} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
