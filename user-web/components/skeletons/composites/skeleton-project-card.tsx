"use client";

import { cn } from "@/lib/utils";
import {
  SkeletonBox,
  SkeletonCircle,
  SkeletonText,
  SkeletonBadge
} from "../primitives";

interface SkeletonProjectCardProps {
  className?: string;
  delay?: number;
  variant?: "compact" | "full";
}

/**
 * Project card skeleton for grid/list layouts
 */
export function SkeletonProjectCard({
  className,
  delay = 0,
  variant = "compact",
}: SkeletonProjectCardProps) {
  if (variant === "full") {
    return (
      <div
        className={cn(
          "p-6 rounded-xl border border-border bg-card",
          className
        )}
      >
        {/* Header: Badge + Menu */}
        <div className="flex items-center justify-between mb-4">
          <SkeletonBadge width={80} delay={delay} />
          <SkeletonCircle size={24} delay={delay + 50} />
        </div>

        {/* Title & Description */}
        <SkeletonText width="70%" lineHeight={24} delay={delay + 100} />
        <SkeletonText lines={2} className="mt-2" delay={delay + 150} />

        {/* Progress Bar */}
        <div className="mt-4">
          <SkeletonBox height={6} rounded="full" className="w-full" delay={delay + 200} />
        </div>

        {/* Footer: Avatar + Due Date */}
        <div className="flex items-center justify-between mt-4 pt-4 border-t border-border">
          <div className="flex items-center gap-2">
            <SkeletonCircle size={32} delay={delay + 250} />
            <SkeletonText width={80} delay={delay + 300} />
          </div>
          <SkeletonText width={100} delay={delay + 350} />
        </div>
      </div>
    );
  }

  // Compact variant for grid
  return (
    <div
      className={cn(
        "p-5 rounded-xl border border-border bg-card",
        className
      )}
    >
      {/* Status Badge */}
      <SkeletonBadge width={70} delay={delay} />

      {/* Title */}
      <SkeletonText width="85%" lineHeight={20} className="mt-3" delay={delay + 50} />

      {/* Description */}
      <SkeletonText width="60%" lineHeight={14} className="mt-2" delay={delay + 100} />

      {/* Progress */}
      <div className="mt-4">
        <SkeletonBox height={4} rounded="full" className="w-full" delay={delay + 150} />
      </div>

      {/* Footer */}
      <div className="flex items-center gap-2 mt-4">
        <SkeletonCircle size={24} delay={delay + 200} />
        <SkeletonText width={60} delay={delay + 250} />
      </div>
    </div>
  );
}
