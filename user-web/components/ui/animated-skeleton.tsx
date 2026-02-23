"use client";

/**
 * AnimatedSkeleton - Enhanced skeleton loading with shimmer animation
 * Provides smooth loading states with Framer Motion
 */

import * as React from "react";
import { motion } from "framer-motion";

import { cn } from "@/lib/utils";

export interface AnimatedSkeletonProps {
  /** Custom className */
  className?: string;
  /** Animation style */
  variant?: "pulse" | "shimmer" | "wave";
  /** Shape preset */
  shape?: "rectangle" | "circle" | "text" | "avatar" | "button" | "card";
  /** Width (for rectangle/text) */
  width?: string | number;
  /** Height (for rectangle) */
  height?: string | number;
  /** Number of text lines (for text variant) */
  lines?: number;
  /** Show animation */
  isAnimating?: boolean;
}

const shimmerGradient = `linear-gradient(
  90deg,
  transparent 0%,
  hsl(var(--muted-foreground) / 0.08) 50%,
  transparent 100%
)`;

export function AnimatedSkeleton({
  className,
  variant = "shimmer",
  shape = "rectangle",
  width,
  height,
  lines = 3,
  isAnimating = true,
}: AnimatedSkeletonProps) {
  const baseClasses = "bg-muted rounded-lg overflow-hidden";

  // Shape-specific styles
  const shapeStyles: Record<string, string> = {
    rectangle: "",
    circle: "rounded-full aspect-square",
    text: "h-4 rounded",
    avatar: "rounded-full size-10",
    button: "h-10 rounded-xl",
    card: "h-48 rounded-2xl",
  };

  // Text skeleton with multiple lines
  if (shape === "text" && lines > 1) {
    return (
      <div className={cn("space-y-2", className)}>
        {Array.from({ length: lines }).map((_, i) => (
          <motion.div
            key={i}
            className={cn(baseClasses, "h-4 rounded")}
            style={{
              width: i === lines - 1 ? "60%" : "100%",
              ...(variant === "shimmer" && {
                backgroundImage: shimmerGradient,
                backgroundSize: "200% 100%",
              }),
            }}
            animate={
              isAnimating && variant === "shimmer"
                ? {
                    backgroundPosition: ["200% 0", "-200% 0"],
                  }
                : isAnimating && variant === "pulse"
                ? { opacity: [0.5, 1, 0.5] }
                : undefined
            }
            transition={
              variant === "shimmer"
                ? {
                    duration: 1.5,
                    repeat: Infinity,
                    ease: "linear",
                    delay: i * 0.1,
                  }
                : variant === "pulse"
                ? {
                    duration: 1.5,
                    repeat: Infinity,
                    ease: "easeInOut",
                    delay: i * 0.1,
                  }
                : undefined
            }
          />
        ))}
      </div>
    );
  }

  // Single skeleton element
  const sizeStyles: React.CSSProperties = {
    width: width ?? (shape === "avatar" ? undefined : "100%"),
    height:
      height ??
      (shape === "card"
        ? undefined
        : shape === "text"
        ? undefined
        : shape === "button"
        ? undefined
        : shape === "avatar"
        ? undefined
        : 20),
  };

  return (
    <motion.div
      className={cn(baseClasses, shapeStyles[shape], className)}
      style={{
        ...sizeStyles,
        ...(variant === "shimmer" && {
          backgroundImage: shimmerGradient,
          backgroundSize: "200% 100%",
        }),
      }}
      animate={
        isAnimating && variant === "shimmer"
          ? {
              backgroundPosition: ["200% 0", "-200% 0"],
            }
          : isAnimating && variant === "pulse"
          ? { opacity: [0.5, 1, 0.5] }
          : isAnimating && variant === "wave"
          ? { scaleX: [0.98, 1.02, 0.98] }
          : undefined
      }
      transition={{
        duration: variant === "wave" ? 2 : 1.5,
        repeat: Infinity,
        ease: variant === "shimmer" ? "linear" : "easeInOut",
      }}
    />
  );
}

/**
 * SkeletonCard - Full card skeleton for loading states
 */
export function SkeletonCard({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "bg-card rounded-2xl border p-6 space-y-4",
        className
      )}
    >
      <div className="flex items-center gap-3">
        <AnimatedSkeleton shape="avatar" />
        <div className="flex-1 space-y-2">
          <AnimatedSkeleton shape="text" width="60%" />
          <AnimatedSkeleton shape="text" width="40%" />
        </div>
      </div>
      <AnimatedSkeleton height={100} className="rounded-xl" />
      <div className="flex gap-2">
        <AnimatedSkeleton shape="button" width="30%" />
        <AnimatedSkeleton shape="button" width="30%" />
      </div>
    </div>
  );
}

/**
 * SkeletonProjectCard - Project card loading skeleton
 */
export function SkeletonProjectCard({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "bg-card rounded-2xl border p-5 space-y-4",
        className
      )}
    >
      {/* Status badge */}
      <div className="flex justify-between items-start">
        <AnimatedSkeleton width={80} height={24} className="rounded-full" />
        <AnimatedSkeleton width={60} height={20} className="rounded" />
      </div>

      {/* Title & description */}
      <div className="space-y-2">
        <AnimatedSkeleton shape="text" width="80%" />
        <AnimatedSkeleton shape="text" lines={2} />
      </div>

      {/* Progress bar */}
      <AnimatedSkeleton height={8} className="rounded-full" />

      {/* Footer */}
      <div className="flex justify-between items-center pt-2">
        <AnimatedSkeleton width={100} height={20} />
        <AnimatedSkeleton shape="avatar" className="size-8" />
      </div>
    </div>
  );
}

/**
 * SkeletonList - List of skeleton items
 */
export function SkeletonList({
  count = 3,
  className,
}: {
  count?: number;
  className?: string;
}) {
  return (
    <div className={cn("space-y-3", className)}>
      {Array.from({ length: count }).map((_, i) => (
        <div
          key={i}
          className="flex items-center gap-3 p-3 rounded-xl bg-card border"
        >
          <AnimatedSkeleton shape="avatar" />
          <div className="flex-1 space-y-2">
            <AnimatedSkeleton shape="text" width="70%" />
            <AnimatedSkeleton shape="text" width="50%" />
          </div>
        </div>
      ))}
    </div>
  );
}

/**
 * SkeletonDashboard - Full dashboard loading skeleton
 */
export function SkeletonDashboard() {
  return (
    <div className="space-y-6 p-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div className="space-y-2">
          <AnimatedSkeleton width={200} height={32} />
          <AnimatedSkeleton width={300} height={20} />
        </div>
        <AnimatedSkeleton shape="button" width={120} />
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="bg-card rounded-2xl border p-4 space-y-2">
            <AnimatedSkeleton width={40} height={40} className="rounded-xl" />
            <AnimatedSkeleton width="60%" height={24} />
            <AnimatedSkeleton width="40%" height={16} />
          </div>
        ))}
      </div>

      {/* Projects section */}
      <div className="space-y-4">
        <AnimatedSkeleton width={150} height={24} />
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <SkeletonProjectCard key={i} />
          ))}
        </div>
      </div>
    </div>
  );
}
