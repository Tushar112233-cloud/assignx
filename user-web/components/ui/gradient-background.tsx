"use client";

import { cn } from "@/lib/utils";

/**
 * Props for GradientBackground component
 */
interface GradientBackgroundProps {
  /** Child content to render */
  children: React.ReactNode;
  /** Additional CSS classes for the container */
  className?: string;
  /** Gradient variant - determines positioning and colors */
  variant?: "default" | "subtle" | "intense" | "warm";
  /** Whether to include the gradient blobs */
  showGradients?: boolean;
}

/**
 * GradientBackground - Reusable subtle gradient background
 *
 * Provides consistent mesh gradient styling from corners,
 * matching the onboarding/login page design system.
 *
 * Coffee Bean Brand Colors:
 * - Primary: #765341
 * - Primary Light: #A07A65
 * - Secondary: #34312D
 *
 * @example
 * ```tsx
 * <GradientBackground variant="subtle">
 *   <PageContent />
 * </GradientBackground>
 * ```
 */
export function GradientBackground({
  children,
  className,
  variant = "default",
  showGradients = true,
}: GradientBackgroundProps) {
  const variants = {
    default: {
      topLeft: "bg-[#765341]/[0.06]",
      bottomRight: "bg-[#A07A65]/[0.04]",
      extra: "bg-[#34312D]/[0.03]",
    },
    subtle: {
      topLeft: "bg-[#765341]/[0.04]",
      bottomRight: "bg-[#A07A65]/[0.03]",
      extra: "bg-[#34312D]/[0.02]",
    },
    intense: {
      topLeft: "bg-[#765341]/[0.12]",
      bottomRight: "bg-[#A07A65]/[0.08]",
      extra: "bg-[#34312D]/[0.05]",
    },
    warm: {
      topLeft: "bg-[#765341]/[0.08]",
      bottomRight: "bg-[#D4A574]/[0.06]",
      extra: "bg-[#A07A65]/[0.04]",
    },
  };

  const colors = variants[variant];

  return (
    <div className={cn("relative", className)}>
      {showGradients && (
        <div className="pointer-events-none absolute inset-0 overflow-hidden">
          {/* Top-left gradient blob */}
          <div
            className={cn(
              "absolute -top-40 -left-40 w-80 h-80 rounded-full blur-3xl",
              colors.topLeft
            )}
          />
          {/* Bottom-right gradient blob */}
          <div
            className={cn(
              "absolute -bottom-40 -right-40 w-80 h-80 rounded-full blur-3xl",
              colors.bottomRight
            )}
          />
          {/* Optional extra blob for variety */}
          <div
            className={cn(
              "absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 rounded-full blur-3xl opacity-50",
              colors.extra
            )}
          />
        </div>
      )}
      <div className="relative z-10">{children}</div>
    </div>
  );
}

/**
 * MeshGradient - Animated mesh gradient background
 *
 * More prominent gradient effect with subtle animation,
 * suitable for hero sections or featured areas.
 */
export function MeshGradient({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("relative overflow-hidden", className)}>
      {/* Animated gradient background */}
      <div className="absolute inset-[-50%] animate-gradient-rotate pointer-events-none">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(118,83,65,0.12)_0%,transparent_40%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(52,49,45,0.10)_0%,transparent_40%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_40%_80%,rgba(160,122,101,0.08)_0%,transparent_40%)]" />
      </div>
      <div className="relative z-10">{children}</div>
    </div>
  );
}
