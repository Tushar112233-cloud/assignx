"use client";

import { cn } from "@/lib/utils";
import { SkeletonBase } from "./skeleton-base";

interface SkeletonBoxProps {
  width?: string | number;
  height?: string | number;
  className?: string;
  rounded?: "sm" | "md" | "lg" | "xl" | "2xl" | "full";
  animate?: "shimmer" | "pulse" | "wave" | "none";
  delay?: number;
}

/**
 * Rectangular skeleton placeholder
 * @param width - Width of the box (number = pixels, string = CSS value)
 * @param height - Height of the box (number = pixels, string = CSS value)
 * @param className - Additional CSS classes
 * @param rounded - Border radius variant
 * @param animate - Animation type
 * @param delay - Animation delay in milliseconds
 */
export function SkeletonBox({
  width,
  height,
  className,
  rounded = "lg",
  animate = "shimmer",
  delay = 0,
}: SkeletonBoxProps) {
  const roundedClass = {
    sm: "rounded-sm",
    md: "rounded-md",
    lg: "rounded-lg",
    xl: "rounded-xl",
    "2xl": "rounded-2xl",
    full: "rounded-full",
  }[rounded];

  return (
    <SkeletonBase
      className={cn(roundedClass, className)}
      animate={animate}
      delay={delay}
      style={{
        width: typeof width === "number" ? `${width}px` : width,
        height: typeof height === "number" ? `${height}px` : height,
      }}
    />
  );
}
