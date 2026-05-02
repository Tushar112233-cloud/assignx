"use client";

import { cn } from "@/lib/utils";
import { SkeletonCircle, SkeletonText } from "../primitives";

interface SkeletonActivityItemProps {
  className?: string;
  delay?: number;
}

/**
 * Activity feed item skeleton for dashboard
 */
export function SkeletonActivityItem({
  className,
  delay = 0,
}: SkeletonActivityItemProps) {
  return (
    <div
      className={cn(
        "flex items-center gap-3 py-3",
        className
      )}
    >
      {/* Avatar */}
      <SkeletonCircle size={36} delay={delay} />

      {/* Content */}
      <div className="flex-1 min-w-0">
        <SkeletonText width="80%" lineHeight={14} delay={delay + 50} />
      </div>

      {/* Timestamp */}
      <SkeletonText width={50} lineHeight={12} delay={delay + 100} />
    </div>
  );
}
