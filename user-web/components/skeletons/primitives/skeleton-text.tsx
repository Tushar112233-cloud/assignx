"use client";

import { cn } from "@/lib/utils";
import { SkeletonBase } from "./skeleton-base";

interface SkeletonTextProps {
  width?: string | number;
  lines?: number;
  className?: string;
  lineHeight?: number;
  gap?: number;
  animate?: "shimmer" | "pulse" | "wave" | "none";
  delay?: number;
}

/**
 * Text skeleton with natural width variance for multiple lines
 * @param width - Width of the text lines (number = pixels, string = CSS value)
 * @param lines - Number of text lines to render
 * @param className - Additional CSS classes
 * @param lineHeight - Height of each line in pixels
 * @param gap - Gap between lines in pixels
 * @param animate - Animation type
 * @param delay - Animation delay in milliseconds
 */
export function SkeletonText({
  width = "100%",
  lines = 1,
  className,
  lineHeight = 16,
  gap = 8,
  animate = "pulse",
  delay = 0,
}: SkeletonTextProps) {
  // Create natural-looking line widths with deterministic values
  const getLineWidth = (index: number, total: number): string => {
    if (index === total - 1 && total > 1) return "60%"; // Last line shorter
    if (index === 0) return typeof width === "number" ? `${width}px` : width; // First line full width
    // Use deterministic widths based on index
    const widths = [92, 88, 95, 85, 90, 87, 93, 89];
    return `${widths[index % widths.length]}%`;
  };

  if (lines === 1) {
    return (
      <SkeletonBase
        className={cn("rounded", className)}
        animate={animate}
        delay={delay}
        style={{
          width: typeof width === "number" ? `${width}px` : width,
          height: `${lineHeight}px`,
        }}
      />
    );
  }

  return (
    <div
      className={cn("flex flex-col", className)}
      style={{ gap: `${gap}px` }}
    >
      {Array.from({ length: lines }).map((_, i) => (
        <SkeletonBase
          key={i}
          className="rounded"
          animate={animate}
          delay={delay + i * 50}
          style={{
            width: getLineWidth(i, lines),
            height: `${lineHeight}px`,
          }}
        />
      ))}
    </div>
  );
}
