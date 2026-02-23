"use client";

import { cn } from "@/lib/utils";
import { SkeletonBase } from "./skeleton-base";
import { ImageIcon } from "lucide-react";

interface SkeletonImageProps {
  aspectRatio?: "square" | "video" | "portrait" | "wide";
  width?: string | number;
  height?: string | number;
  className?: string;
  showIcon?: boolean;
  animate?: "shimmer" | "pulse" | "wave";
  delay?: number;
}

/**
 * Image skeleton with aspect ratio support
 * @param aspectRatio - Predefined aspect ratio (square, video, portrait, wide)
 * @param width - Width of the image (number = pixels, string = CSS value)
 * @param height - Height of the image (used when aspectRatio is not set)
 * @param className - Additional CSS classes
 * @param showIcon - Whether to show a placeholder image icon
 * @param animate - Animation type
 * @param delay - Animation delay in milliseconds
 */
export function SkeletonImage({
  aspectRatio,
  width = "100%",
  height,
  className,
  showIcon = true,
  animate = "shimmer",
  delay = 0,
}: SkeletonImageProps) {
  const aspectRatioClass = aspectRatio ? {
    square: "aspect-square",
    video: "aspect-video",
    portrait: "aspect-[3/4]",
    wide: "aspect-[4/3]",
  }[aspectRatio] : "";

  return (
    <SkeletonBase
      className={cn(
        "rounded-xl flex items-center justify-center",
        aspectRatioClass,
        className
      )}
      animate={animate}
      delay={delay}
      style={{
        width: typeof width === "number" ? `${width}px` : width,
        height: !aspectRatio && height ? (typeof height === "number" ? `${height}px` : height) : undefined,
      }}
    >
      {showIcon && (
        <ImageIcon className="h-8 w-8 text-muted-foreground/30" />
      )}
    </SkeletonBase>
  );
}
