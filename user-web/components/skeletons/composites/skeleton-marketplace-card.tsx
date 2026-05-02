"use client";

import { cn } from "@/lib/utils";
import {
  SkeletonBox,
  SkeletonText,
  SkeletonBadge
} from "../primitives";

interface SkeletonMarketplaceCardProps {
  className?: string;
  delay?: number;
  height?: number;
}

/**
 * Marketplace/Connect card skeleton for masonry grid
 */
export function SkeletonMarketplaceCard({
  className,
  delay = 0,
  height,
}: SkeletonMarketplaceCardProps) {
  // Random height for masonry effect
  const imageHeight = height || (180 + Math.floor(Math.random() * 100));

  return (
    <div
      className={cn(
        "rounded-xl border border-border bg-card overflow-hidden mb-4",
        className
      )}
    >
      {/* Image */}
      <SkeletonBox
        height={imageHeight}
        className="w-full"
        rounded="sm"
        delay={delay}
      />

      {/* Content */}
      <div className="p-3">
        {/* Title */}
        <SkeletonText width="90%" lineHeight={16} delay={delay + 100} />

        {/* Meta row */}
        <div className="flex items-center justify-between mt-2">
          <SkeletonText width={60} lineHeight={12} delay={delay + 150} />
          <SkeletonBadge width={50} delay={delay + 200} />
        </div>
      </div>
    </div>
  );
}
