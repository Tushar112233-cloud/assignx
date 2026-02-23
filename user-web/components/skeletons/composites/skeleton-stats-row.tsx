"use client";

import { cn } from "@/lib/utils";
import { SkeletonStat } from "./skeleton-stat";

interface SkeletonStatsRowProps {
  count?: number;
  className?: string;
  delay?: number;
}

/**
 * Stats row skeleton - 4 column grid
 */
export function SkeletonStatsRow({
  count = 4,
  className,
  delay = 0,
}: SkeletonStatsRowProps) {
  return (
    <div className={cn("grid grid-cols-2 md:grid-cols-4 gap-4", className)}>
      {Array.from({ length: count }).map((_, i) => (
        <SkeletonStat key={i} delay={delay + i * 50} />
      ))}
    </div>
  );
}
