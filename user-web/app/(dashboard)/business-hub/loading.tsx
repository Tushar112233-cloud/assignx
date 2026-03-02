"use client";

import { Loader2 } from "lucide-react";

/**
 * Loading state for Business Hub pages
 * Displays skeleton placeholders matching the page layout
 */
export default function BusinessHubLoading() {
  return (
    <div className="min-h-[calc(100vh-3.5rem)] bg-background">
      <div className="max-w-6xl mx-auto px-4 md:px-6 py-6 space-y-6">
        {/* Hero skeleton */}
        <div className="h-48 md:h-56 rounded-2xl bg-gradient-to-br from-emerald-200 to-teal-200 dark:from-emerald-900/30 dark:to-teal-900/30 animate-pulse" />

        {/* Search skeleton */}
        <div className="max-w-2xl mx-auto">
          <div className="h-11 bg-muted rounded-xl animate-pulse" />
        </div>

        {/* Filter tabs skeleton */}
        <div className="flex gap-2 overflow-hidden">
          {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
            <div
              key={i}
              className="h-9 w-24 bg-muted rounded-full animate-pulse flex-shrink-0"
            />
          ))}
        </div>

        {/* Post grid skeleton */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div
              key={i}
              className="rounded-2xl border border-border/50 overflow-hidden"
            >
              <div className="h-40 bg-muted animate-pulse" />
              <div className="p-4 space-y-3">
                <div className="flex gap-2">
                  <div className="h-5 w-20 bg-muted rounded-full animate-pulse" />
                  <div className="h-5 w-16 bg-muted rounded-full animate-pulse" />
                </div>
                <div className="h-5 w-3/4 bg-muted rounded animate-pulse" />
                <div className="h-4 w-full bg-muted rounded animate-pulse" />
                <div className="h-4 w-2/3 bg-muted rounded animate-pulse" />
                <div className="flex items-center gap-2 pt-2">
                  <div className="h-7 w-7 bg-muted rounded-full animate-pulse" />
                  <div className="h-4 w-24 bg-muted rounded animate-pulse" />
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Centered loader */}
        <div className="flex items-center justify-center py-8">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      </div>
    </div>
  );
}
