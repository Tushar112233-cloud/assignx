"use client";

import { cn } from "@/lib/utils";

/**
 * Get time-based gradient class
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 17) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

/**
 * Projects page loading skeleton
 * Matches the redesigned ProjectsPro layout
 */
export default function ProjectsLoading() {
  return (
    <div className={cn("mesh-background mesh-gradient-bottom-right-animated h-full overflow-hidden", getTimeBasedGradientClass())}>
      <div className="relative z-10 h-full overflow-y-auto">
        {/* ═══════════════════════════════════════════════════════════════ */}
        {/* HEADER SKELETON */}
        {/* ═══════════════════════════════════════════════════════════════ */}
        <header className="sticky top-0 z-20 backdrop-blur-xl bg-background/60 border-b border-border/40">
          <div className="max-w-[1400px] mx-auto px-4 py-4 md:px-6 lg:px-8">
            <div className="flex items-center justify-between gap-4">
              {/* Left - Title skeleton */}
              <div className="flex items-center gap-4">
                <div className="h-12 w-12 rounded-2xl bg-violet-500/30 animate-pulse" />
                <div className="space-y-2">
                  <div className="h-6 w-32 bg-foreground/10 rounded-lg animate-pulse" />
                  <div className="h-4 w-24 bg-foreground/5 rounded-lg animate-pulse hidden sm:block" />
                </div>
              </div>

              {/* Right - Actions skeleton */}
              <div className="flex items-center gap-3">
                <div className="hidden md:block h-10 w-64 bg-white/40 dark:bg-white/5 rounded-xl animate-pulse" />
                <div className="h-10 w-10 sm:w-32 bg-violet-500/30 rounded-xl animate-pulse" />
              </div>
            </div>

            {/* Mobile Search skeleton */}
            <div className="mt-3 md:hidden h-10 w-full bg-white/40 dark:bg-white/5 rounded-xl animate-pulse" />
          </div>
        </header>

        {/* ═══════════════════════════════════════════════════════════════ */}
        {/* MAIN CONTENT */}
        {/* ═══════════════════════════════════════════════════════════════ */}
        <main className="max-w-[1400px] mx-auto px-4 py-6 md:px-6 lg:px-8 space-y-6">
          {/* ═══════════════════════════════════════════════════════════════ */}
          {/* STATS BAR SKELETON */}
          {/* ═══════════════════════════════════════════════════════════════ */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            {[
              { color: "violet", selected: true },
              { color: "blue", selected: false },
              { color: "amber", selected: false },
              { color: "emerald", selected: false },
            ].map((stat, index) => (
              <StatCardSkeleton key={index} color={stat.color} isSelected={stat.selected} />
            ))}
          </div>

          {/* ═══════════════════════════════════════════════════════════════ */}
          {/* FEATURED PROJECT SKELETON */}
          {/* ═══════════════════════════════════════════════════════════════ */}
          <section className="space-y-3">
            <div className="flex items-center gap-2">
              <div className="h-4 w-4 bg-amber-500/30 rounded animate-pulse" />
              <div className="h-4 w-32 bg-foreground/10 rounded animate-pulse" />
            </div>
            <div className="w-full h-[140px] md:h-[120px] rounded-2xl bg-gradient-to-br from-stone-800/50 via-stone-900/50 to-neutral-900/50 animate-pulse" />
          </section>

          {/* ═══════════════════════════════════════════════════════════════ */}
          {/* FILTER BAR SKELETON */}
          {/* ═══════════════════════════════════════════════════════════════ */}
          <div className="flex items-center gap-2 pt-2">
            <div className="h-4 w-4 bg-muted-foreground/20 rounded animate-pulse" />
            <div className="h-4 w-40 bg-muted-foreground/10 rounded animate-pulse" />
          </div>

          {/* ═══════════════════════════════════════════════════════════════ */}
          {/* PROJECTS GRID SKELETON */}
          {/* ═══════════════════════════════════════════════════════════════ */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
              <ProjectCardSkeleton key={i} index={i} />
            ))}
          </div>
        </main>
      </div>
    </div>
  );
}

/**
 * Stat Card Skeleton
 */
function StatCardSkeleton({ color, isSelected }: { color: string; isSelected: boolean }) {
  const colorClasses: Record<string, { bg: string; border: string; icon: string }> = {
    violet: {
      bg: isSelected ? "bg-violet-100/50 dark:bg-violet-950/40" : "bg-white/50 dark:bg-violet-950/15",
      border: isSelected ? "border-violet-300/50 dark:border-violet-700/50" : "border-violet-200/30 dark:border-violet-800/20",
      icon: "bg-violet-500/40",
    },
    blue: {
      bg: isSelected ? "bg-blue-100/50 dark:bg-blue-950/40" : "bg-white/50 dark:bg-blue-950/15",
      border: isSelected ? "border-blue-300/50 dark:border-blue-700/50" : "border-blue-200/30 dark:border-blue-800/20",
      icon: "bg-blue-500/40",
    },
    amber: {
      bg: isSelected ? "bg-amber-100/50 dark:bg-amber-950/40" : "bg-white/50 dark:bg-amber-950/15",
      border: isSelected ? "border-amber-300/50 dark:border-amber-700/50" : "border-amber-200/30 dark:border-amber-800/20",
      icon: "bg-amber-500/40",
    },
    emerald: {
      bg: isSelected ? "bg-emerald-100/50 dark:bg-emerald-950/40" : "bg-white/50 dark:bg-emerald-950/15",
      border: isSelected ? "border-emerald-300/50 dark:border-emerald-700/50" : "border-emerald-200/30 dark:border-emerald-800/20",
      icon: "bg-emerald-500/40",
    },
  };

  const c = colorClasses[color] || colorClasses.violet;

  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-2xl p-4 backdrop-blur-xl border",
        c.bg,
        c.border,
        isSelected && "ring-2 ring-offset-2 ring-offset-background ring-violet-500/20"
      )}
    >
      <div className="flex items-center gap-3">
        <div className={cn("h-10 w-10 rounded-xl animate-pulse", c.icon)} />
        <div className="space-y-2">
          <div className="h-7 w-10 bg-foreground/10 rounded animate-pulse" />
          <div className="h-3 w-14 bg-foreground/5 rounded animate-pulse" />
        </div>
      </div>
    </div>
  );
}

/**
 * Project Card Skeleton
 */
function ProjectCardSkeleton({ index }: { index: number }) {
  const variants = [
    { bg: "bg-white/60 dark:bg-violet-950/30", border: "border-violet-200/50 dark:border-violet-800/30", icon: "bg-violet-500/40" },
    { bg: "bg-white/60 dark:bg-emerald-950/20", border: "border-emerald-200/40 dark:border-emerald-800/20", icon: "bg-emerald-500/40" },
    { bg: "bg-white/60 dark:bg-amber-950/20", border: "border-amber-200/40 dark:border-amber-800/20", icon: "bg-amber-500/40" },
    { bg: "bg-white/60 dark:bg-blue-950/20", border: "border-blue-200/40 dark:border-blue-800/20", icon: "bg-blue-500/40" },
  ];

  const variant = variants[(index - 1) % 4];

  return (
    <div className={cn("relative overflow-hidden rounded-2xl p-4 backdrop-blur-xl border", variant.bg, variant.border)}>
      <div className="space-y-3">
        {/* Header */}
        <div className="flex items-start justify-between gap-2">
          <div className={cn("h-10 w-10 rounded-xl animate-pulse", variant.icon)} />
          <div className="h-6 w-20 bg-muted/30 rounded-lg animate-pulse" />
        </div>

        {/* Title skeleton */}
        <div className="space-y-2">
          <div className="h-4 w-full bg-foreground/10 rounded animate-pulse" />
          <div className="h-4 w-3/4 bg-foreground/10 rounded animate-pulse" />
        </div>

        {/* Meta skeleton */}
        <div className="h-3 w-28 bg-muted-foreground/15 rounded animate-pulse" />

        {/* Progress bar skeleton (some cards) */}
        {index % 3 === 1 && (
          <div className="space-y-1">
            <div className="flex justify-between">
              <div className="h-2.5 w-12 bg-muted-foreground/10 rounded animate-pulse" />
              <div className="h-2.5 w-8 bg-muted-foreground/10 rounded animate-pulse" />
            </div>
            <div className="h-1.5 w-full bg-muted/30 rounded-full overflow-hidden">
              <div className="h-full w-3/5 bg-violet-400/30 rounded-full animate-pulse" />
            </div>
          </div>
        )}

        {/* Footer skeleton */}
        <div className="flex items-center justify-between pt-2 border-t border-border/20">
          <div className="h-3 w-16 bg-muted-foreground/10 rounded animate-pulse" />
          <div className="h-4 w-4 bg-muted-foreground/10 rounded animate-pulse" />
        </div>
      </div>
    </div>
  );
}
