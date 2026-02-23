"use client";

import { cn } from "@/lib/utils";
import { SkeletonBadge } from "../primitives";

interface SkeletonFilterPillsProps {
  count?: number;
  className?: string;
  delay?: number;
}

/**
 * Filter pills skeleton for quick actions bar
 */
export function SkeletonFilterPills({
  count = 4,
  className,
  delay = 0,
}: SkeletonFilterPillsProps) {
  return (
    <div className={cn("flex items-center gap-2 overflow-x-auto", className)}>
      {Array.from({ length: count }).map((_, i) => (
        <SkeletonBadge
          key={i}
          width={70 + Math.random() * 30}
          delay={delay + i * 30}
        />
      ))}
    </div>
  );
}
