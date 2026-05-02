"use client";

import { cn } from "@/lib/utils";
import { SkeletonBase } from "./skeleton-base";

interface SkeletonCircleProps {
  size?: number | string;
  className?: string;
  animate?: "shimmer" | "pulse" | "wave";
  delay?: number;
}

/**
 * Circular skeleton for avatars and icons
 * @param size - Diameter of the circle (number = pixels, string = CSS value)
 * @param className - Additional CSS classes
 * @param animate - Animation type
 * @param delay - Animation delay in milliseconds
 */
export function SkeletonCircle({
  size = 40,
  className,
  animate = "shimmer",
  delay = 0,
}: SkeletonCircleProps) {
  const sizeValue = typeof size === "number" ? `${size}px` : size;

  return (
    <SkeletonBase
      className={cn("rounded-full shrink-0", className)}
      animate={animate}
      delay={delay}
      style={{
        width: sizeValue,
        height: sizeValue,
      }}
    />
  );
}
