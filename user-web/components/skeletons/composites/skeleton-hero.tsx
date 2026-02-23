"use client";

import { cn } from "@/lib/utils";
import { SkeletonText, SkeletonButton } from "../primitives";

interface SkeletonHeroProps {
  className?: string;
  height?: number;
  delay?: number;
  showButton?: boolean;
}

/**
 * Hero section skeleton for page headers
 */
export function SkeletonHero({
  className,
  height = 140,
  delay = 0,
  showButton = false,
}: SkeletonHeroProps) {
  return (
    <div
      className={cn(
        "rounded-2xl bg-muted/50 p-6 flex flex-col justify-center",
        className
      )}
      style={{ height: `${height}px` }}
    >
      <SkeletonText width="50%" lineHeight={28} delay={delay} />
      <SkeletonText width="70%" lineHeight={16} className="mt-2" delay={delay + 50} />
      {showButton && (
        <SkeletonButton size="default" width={120} className="mt-4" delay={delay + 100} />
      )}
    </div>
  );
}
