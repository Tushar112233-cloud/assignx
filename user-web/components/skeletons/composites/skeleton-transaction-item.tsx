"use client";

import { cn } from "@/lib/utils";
import {
  SkeletonCircle,
  SkeletonText,
  SkeletonBadge
} from "../primitives";

interface SkeletonTransactionItemProps {
  className?: string;
  delay?: number;
}

/**
 * Transaction list item skeleton for wallet page
 */
export function SkeletonTransactionItem({
  className,
  delay = 0,
}: SkeletonTransactionItemProps) {
  return (
    <div
      className={cn(
        "flex items-center gap-4 p-4 rounded-xl border border-border bg-card",
        className
      )}
    >
      {/* Avatar/Icon */}
      <SkeletonCircle size={44} delay={delay} />

      {/* Content */}
      <div className="flex-1 min-w-0">
        <SkeletonText width="60%" lineHeight={16} delay={delay + 50} />
        <SkeletonText width="40%" lineHeight={12} className="mt-1" delay={delay + 100} />
      </div>

      {/* Amount & Status */}
      <div className="text-right shrink-0">
        <SkeletonText width={70} lineHeight={16} delay={delay + 150} />
        <SkeletonBadge width={60} className="mt-1 ml-auto" delay={delay + 200} />
      </div>
    </div>
  );
}
