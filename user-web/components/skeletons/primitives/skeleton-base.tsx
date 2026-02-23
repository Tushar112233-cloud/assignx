"use client";

import { cn } from "@/lib/utils";

interface SkeletonBaseProps {
  className?: string;
  animate?: "shimmer" | "pulse" | "wave" | "none";
  delay?: number;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}

/**
 * Base skeleton with animation variants
 * @param className - Additional CSS classes
 * @param animate - Animation type: shimmer (gradient sweep), pulse (opacity), wave (scale)
 * @param delay - Animation delay in milliseconds
 * @param style - Inline styles for dimensions
 * @param children - Optional children (e.g., icons)
 */
export function SkeletonBase({
  className,
  animate = "shimmer",
  delay = 0,
  style,
  children,
}: SkeletonBaseProps) {
  const animationClass = {
    shimmer: "skeleton-shimmer",
    pulse: "animate-pulse",
    wave: "skeleton-wave",
    none: "",
  }[animate];

  return (
    <div
      className={cn(
        "bg-muted rounded-md",
        animationClass,
        className
      )}
      style={{ animationDelay: `${delay}ms`, ...style }}
    >
      {children}
    </div>
  );
}
