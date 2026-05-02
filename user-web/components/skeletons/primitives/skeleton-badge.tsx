"use client";

import { cn } from "@/lib/utils";
import { SkeletonBase } from "./skeleton-base";

interface SkeletonBadgeProps {
  width?: string | number;
  className?: string;
  animate?: "shimmer" | "pulse" | "wave";
  delay?: number;
}

/**
 * Badge/pill-shaped skeleton placeholder
 * @param width - Width of the badge (number = pixels, string = CSS value)
 * @param className - Additional CSS classes
 * @param animate - Animation type
 * @param delay - Animation delay in milliseconds
 */
export function SkeletonBadge({
  width = 60,
  className,
  animate = "shimmer",
  delay = 0,
}: SkeletonBadgeProps) {
  return (
    <SkeletonBase
      className={cn("rounded-full", className)}
      animate={animate}
      delay={delay}
      style={{
        width: typeof width === "number" ? `${width}px` : width,
        height: 24,
      }}
    />
  );
}
