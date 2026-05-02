"use client";

import { cn } from "@/lib/utils";
import { SkeletonBase } from "./skeleton-base";

interface SkeletonButtonProps {
  size?: "sm" | "default" | "lg";
  width?: string | number;
  className?: string;
  animate?: "shimmer" | "pulse" | "wave";
  delay?: number;
}

/**
 * Button-shaped skeleton placeholder
 * @param size - Button size variant matching shadcn/ui button sizes
 * @param width - Custom width (overrides default minWidth)
 * @param className - Additional CSS classes
 * @param animate - Animation type
 * @param delay - Animation delay in milliseconds
 */
export function SkeletonButton({
  size = "default",
  width,
  className,
  animate = "shimmer",
  delay = 0,
}: SkeletonButtonProps) {
  const sizeStyles = {
    sm: { height: 32, minWidth: 64 },
    default: { height: 40, minWidth: 80 },
    lg: { height: 48, minWidth: 96 },
  }[size];

  return (
    <SkeletonBase
      className={cn("rounded-lg", className)}
      animate={animate}
      delay={delay}
      style={{
        width: typeof width === "number" ? `${width}px` : width || sizeStyles.minWidth,
        height: sizeStyles.height,
      }}
    />
  );
}
