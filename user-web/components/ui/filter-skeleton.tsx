/**
 * @fileoverview Filter and Search Skeleton Components
 *
 * Skeleton loaders for filter tabs, search bars, and filter sheets.
 * Provides visual feedback during loading states.
 */

"use client";

import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";

/**
 * FilterTabsSkeleton - Skeleton for horizontal filter tabs/chips
 */
export function FilterTabsSkeleton({ count = 5, className }: { count?: number; className?: string }) {
  return (
    <div className={cn("flex gap-2 overflow-hidden", className)}>
      {Array.from({ length: count }).map((_, i) => (
        <Skeleton
          key={i}
          className={cn(
            "h-10 shrink-0 rounded-full",
            i === 0 ? "w-16" : "w-24"
          )}
          style={{ animationDelay: `${i * 0.1}s` }}
        />
      ))}
    </div>
  );
}

/**
 * SearchBarSkeleton - Skeleton for search input with button
 */
export function SearchBarSkeleton({ className }: { className?: string }) {
  return (
    <div className={cn("flex gap-2", className)}>
      <Skeleton className="h-10 flex-1 rounded-md" />
      <Skeleton className="h-10 w-20 rounded-md" />
      <Skeleton className="h-10 w-10 rounded-md" />
    </div>
  );
}

/**
 * FilterBarSkeleton - Complete filter bar skeleton (search + tabs)
 */
export function FilterBarSkeleton({
  tabCount = 5,
  className,
}: {
  tabCount?: number;
  className?: string;
}) {
  return (
    <div className={cn("space-y-4", className)}>
      <SearchBarSkeleton />
      <FilterTabsSkeleton count={tabCount} />
    </div>
  );
}

/**
 * CategoryFilterSkeleton - Skeleton for category filter chips
 */
export function CategoryFilterSkeleton({ count = 5, className }: { count?: number; className?: string }) {
  return (
    <div className={cn("relative", className)}>
      <div className="flex gap-2 overflow-x-auto pb-2">
        {Array.from({ length: count }).map((_, i) => (
          <Skeleton
            key={i}
            className={cn(
              "h-9 shrink-0 rounded-full",
              i === 0 ? "w-14" : "w-[88px]"
            )}
            style={{ animationDelay: `${i * 0.1}s` }}
          />
        ))}
      </div>
    </div>
  );
}

/**
 * SelectFilterSkeleton - Skeleton for select/dropdown filters
 */
export function SelectFilterSkeleton({ className }: { className?: string }) {
  return (
    <div className={cn("space-y-2", className)}>
      <Skeleton className="h-4 w-20" />
      <Skeleton className="h-10 w-full rounded-md" />
    </div>
  );
}

/**
 * FilterSheetContentSkeleton - Skeleton for filter sheet/panel content
 */
export function FilterSheetContentSkeleton({ className }: { className?: string }) {
  return (
    <div className={cn("space-y-6", className)}>
      {/* Multiple filter groups */}
      {Array.from({ length: 3 }).map((_, i) => (
        <SelectFilterSkeleton key={i} />
      ))}

      {/* Slider skeleton */}
      <div className="space-y-4">
        <div className="flex justify-between">
          <Skeleton className="h-4 w-20" />
          <Skeleton className="h-4 w-24" />
        </div>
        <Skeleton className="h-2 w-full rounded-full" />
      </div>

      {/* Action button */}
      <Skeleton className="h-10 w-full rounded-md" />
    </div>
  );
}

/**
 * ListingCardSkeleton - Skeleton for marketplace/listing cards
 */
export function ListingCardSkeleton({ className }: { className?: string }) {
  return (
    <div className={cn("space-y-3 rounded-xl border p-4", className)}>
      {/* Image placeholder */}
      <Skeleton className="aspect-[4/3] w-full rounded-lg" />

      {/* Title */}
      <Skeleton className="h-5 w-3/4" />

      {/* Description */}
      <div className="space-y-2">
        <Skeleton className="h-4 w-full" />
        <Skeleton className="h-4 w-2/3" />
      </div>

      {/* Price and badges */}
      <div className="flex items-center justify-between pt-2">
        <Skeleton className="h-6 w-20" />
        <Skeleton className="h-6 w-16 rounded-full" />
      </div>
    </div>
  );
}

/**
 * ListingGridSkeleton - Grid of listing card skeletons
 */
export function ListingGridSkeleton({
  count = 6,
  columns = 3,
  className,
}: {
  count?: number;
  columns?: number;
  className?: string;
}) {
  return (
    <div
      className={cn(
        "grid gap-4",
        columns === 2 && "grid-cols-1 sm:grid-cols-2",
        columns === 3 && "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3",
        columns === 4 && "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4",
        className
      )}
    >
      {Array.from({ length: count }).map((_, i) => (
        <ListingCardSkeleton key={i} />
      ))}
    </div>
  );
}

/**
 * ProfileCardSkeleton - Skeleton for user/tutor profile cards
 */
export function ProfileCardSkeleton({ className }: { className?: string }) {
  return (
    <div className={cn("flex items-start gap-4 rounded-xl border p-4", className)}>
      {/* Avatar */}
      <Skeleton className="h-12 w-12 shrink-0 rounded-full" />

      {/* Content */}
      <div className="flex-1 space-y-2">
        <Skeleton className="h-5 w-1/3" />
        <Skeleton className="h-4 w-2/3" />
        <div className="flex gap-2 pt-1">
          <Skeleton className="h-5 w-16 rounded-full" />
          <Skeleton className="h-5 w-16 rounded-full" />
        </div>
      </div>

      {/* Action */}
      <Skeleton className="h-9 w-20 shrink-0 rounded-md" />
    </div>
  );
}

/**
 * ProfileListSkeleton - List of profile card skeletons
 */
export function ProfileListSkeleton({ count = 4, className }: { count?: number; className?: string }) {
  return (
    <div className={cn("space-y-4", className)}>
      {Array.from({ length: count }).map((_, i) => (
        <ProfileCardSkeleton key={i} />
      ))}
    </div>
  );
}

/**
 * SearchResultsSkeleton - Complete search results page skeleton
 */
export function SearchResultsSkeleton({ className }: { className?: string }) {
  return (
    <div className={cn("space-y-6", className)}>
      {/* Search bar */}
      <SearchBarSkeleton />

      {/* Filter tabs */}
      <FilterTabsSkeleton count={5} />

      {/* Results count */}
      <div className="flex items-center justify-between">
        <Skeleton className="h-5 w-32" />
        <Skeleton className="h-9 w-28" />
      </div>

      {/* Results grid */}
      <ListingGridSkeleton count={6} columns={3} />
    </div>
  );
}
