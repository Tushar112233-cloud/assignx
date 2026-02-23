"use client"

import { Skeleton } from "@/components/ui/skeleton"

/**
 * ReviewsLoadingSkeleton Component
 *
 * A comprehensive loading skeleton that matches the Reviews page layout structure.
 * Provides visual feedback during data fetching with shimmer animations.
 *
 * Layout matches:
 * - Hero banner (large rounded-[28px] card)
 * - 4 stat cards in a grid
 * - Analytics dashboard (2-column layout)
 * - Reviews list (3-4 cards)
 *
 * Uses:
 * - Teal-tinted skeleton backgrounds via CSS variable
 * - Shimmer animation effect via global CSS
 * - Responsive grid layouts
 *
 * @example
 * ```tsx
 * {isLoading ? <ReviewsLoadingSkeleton /> : <ReviewsContent />}
 * ```
 */
export function ReviewsLoadingSkeleton() {
  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="space-y-2">
          <Skeleton className="h-8 w-48 skeleton-shimmer" />
          <Skeleton className="h-4 w-72 skeleton-shimmer" />
        </div>
        <Skeleton className="h-9 w-40 rounded-full skeleton-shimmer" />
      </div>

      {/* Hero Banner Skeleton */}
      <div className="relative overflow-hidden rounded-[28px] bg-gradient-to-br from-[#E6F5F3] via-[#EBF7F5] to-[#E9FAFA] p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
        <div className="grid gap-6 lg:grid-cols-[1fr_320px]">
          {/* Left column */}
          <div className="space-y-4">
            <Skeleton className="h-7 w-32 rounded-full bg-[#E6F5F3] skeleton-shimmer" />
            <div className="space-y-3">
              <div className="flex items-center gap-2">
                {[...Array(5)].map((_, i) => (
                  <Skeleton key={i} className="h-7 w-7 rounded-full bg-white/50 skeleton-shimmer" />
                ))}
                <Skeleton className="h-8 w-16 ml-2 bg-white/50 skeleton-shimmer" />
              </div>
              <Skeleton className="h-5 w-48 bg-white/50 skeleton-shimmer" />
            </div>
            <Skeleton className="h-16 w-full max-w-xl bg-white/50 skeleton-shimmer" />
            <div className="flex gap-3 pt-2">
              <Skeleton className="h-11 w-40 rounded-full bg-white/70 skeleton-shimmer" />
              <Skeleton className="h-11 w-36 rounded-full bg-white/70 skeleton-shimmer" />
            </div>
          </div>

          {/* Right column - Stat cards */}
          <div className="flex flex-col gap-3">
            {[...Array(3)].map((_, i) => (
              <div
                key={i}
                className="flex items-center gap-3 rounded-2xl bg-white/85 p-4 border border-white/70"
              >
                <Skeleton className="h-10 w-10 rounded-xl skeleton-shimmer" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-3 w-20 skeleton-shimmer" />
                  <Skeleton className="h-4 w-24 skeleton-shimmer" />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Stats Overview Cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[...Array(4)].map((_, i) => (
          <div
            key={i}
            className="rounded-xl bg-white p-4 shadow-[0_16px_35px_rgba(30,58,138,0.08)]"
          >
            <div className="flex items-center gap-4">
              <Skeleton className="h-12 w-12 rounded-xl skeleton-shimmer" />
              <div className="flex-1 space-y-2">
                <Skeleton className="h-8 w-16 skeleton-shimmer" />
                <Skeleton className="h-4 w-24 skeleton-shimmer" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Analytics Dashboard Skeleton (2-column layout) */}
      <div className="grid gap-6 lg:grid-cols-3">
        {/* Rating Distribution */}
        <div className="rounded-xl bg-white p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
          <div className="space-y-3 pb-3">
            <Skeleton className="h-5 w-36 skeleton-shimmer" />
            <Skeleton className="h-4 w-48 skeleton-shimmer" />
          </div>
          <div className="space-y-3">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="flex items-center gap-3">
                <Skeleton className="h-4 w-12 skeleton-shimmer" />
                <Skeleton className="h-2.5 flex-1 rounded-full skeleton-shimmer" />
                <Skeleton className="h-4 w-8 skeleton-shimmer" />
              </div>
            ))}
          </div>
        </div>

        {/* Category Performance */}
        <div className="lg:col-span-2 rounded-xl bg-white p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
          <div className="space-y-3 pb-3">
            <Skeleton className="h-5 w-40 skeleton-shimmer" />
            <Skeleton className="h-4 w-56 skeleton-shimmer" />
          </div>
          <div className="grid gap-4 sm:grid-cols-3">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="p-4 rounded-xl bg-[hsl(var(--skeleton-base))]/30">
                <div className="flex items-center justify-between mb-2">
                  <Skeleton className="h-4 w-20 skeleton-shimmer" />
                  <Skeleton className="h-5 w-10 skeleton-shimmer" />
                </div>
                <div className="flex gap-1 mb-2">
                  {[...Array(5)].map((_, j) => (
                    <Skeleton key={j} className="h-3 w-3 rounded-full skeleton-shimmer" />
                  ))}
                </div>
                <Skeleton className="h-3 w-32 skeleton-shimmer" />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Reviews List Skeleton */}
      <div className="rounded-xl bg-white p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
        {/* List Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
          <div className="space-y-2">
            <Skeleton className="h-6 w-32 skeleton-shimmer" />
            <Skeleton className="h-4 w-64 skeleton-shimmer" />
          </div>
          <Skeleton className="h-10 w-40 rounded-lg skeleton-shimmer" />
        </div>

        {/* Review Cards */}
        <div className="space-y-6">
          {[...Array(3)].map((_, i) => (
            <div key={i}>
              {i > 0 && <div className="h-px bg-slate-200 mb-6" />}
              <div className="space-y-4">
                {/* Review header */}
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <Skeleton className="h-10 w-10 rounded-full skeleton-shimmer" />
                    <div className="space-y-2">
                      <Skeleton className="h-4 w-32 skeleton-shimmer" />
                      <Skeleton className="h-3 w-24 skeleton-shimmer" />
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="flex gap-1">
                      {[...Array(5)].map((_, j) => (
                        <Skeleton key={j} className="h-4 w-4 rounded-full skeleton-shimmer" />
                      ))}
                    </div>
                    <Skeleton className="h-6 w-10 rounded-full ml-2 skeleton-shimmer" />
                  </div>
                </div>

                {/* Project badge */}
                <Skeleton className="h-6 w-48 rounded-md skeleton-shimmer" />

                {/* Review text */}
                <div className="space-y-2">
                  <Skeleton className="h-16 w-full rounded-lg opacity-50 skeleton-shimmer" />
                </div>

                {/* Category ratings */}
                <div className="flex flex-wrap gap-4">
                  {[...Array(3)].map((_, j) => (
                    <Skeleton key={j} className="h-8 w-36 rounded-full skeleton-shimmer" />
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
