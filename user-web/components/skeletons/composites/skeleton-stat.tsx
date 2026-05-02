"use client";

import { cn } from "@/lib/utils";
import { SkeletonCircle, SkeletonText, SkeletonBadge } from "../primitives";

interface SkeletonStatProps {
  className?: string;
  delay?: number;
}

/**
 * Stat card skeleton matching the unified layout
 */
export function SkeletonStat({ className, delay = 0 }: SkeletonStatProps) {
  return (
    <div
      className={cn(
        "p-5 rounded-xl border border-border bg-card",
        className
      )}
    >
      <div className="flex items-start justify-between mb-3">
        <SkeletonCircle size={40} delay={delay} />
        <SkeletonBadge width={50} delay={delay + 50} />
      </div>
      <SkeletonText width="60%" lineHeight={28} delay={delay + 100} />
      <SkeletonText width="80px" lineHeight={14} className="mt-1" delay={delay + 150} />
    </div>
  );
}
