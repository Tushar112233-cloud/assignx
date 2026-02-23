import { Skeleton } from "@/components/ui/skeleton";

/**
 * Campus Connect marketplace loading state
 * Shows skeleton UI for search, categories, and masonry grid
 */
export default function ConnectLoading() {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Header Skeleton */}
      <div className="border-b p-4">
        <Skeleton className="h-8 w-40" />
      </div>

      <div className="flex-1 p-4 lg:p-6 space-y-4">
        {/* Page Header Skeleton */}
        <div className="flex items-start justify-between">
          <div className="space-y-2">
            <Skeleton className="h-8 w-40" />
            <Skeleton className="h-4 w-64" />
          </div>
          <Skeleton className="h-10 w-20" />
        </div>

        {/* Search Bar Skeleton */}
        <div className="flex gap-2">
          <Skeleton className="h-10 flex-1" />
          <Skeleton className="h-10 w-10" />
        </div>

        {/* Category Tabs Skeleton */}
        <div className="flex gap-2 overflow-x-auto pb-2">
          {[1, 2, 3, 4, 5].map((i) => (
            <Skeleton key={i} className="h-9 w-24 shrink-0" />
          ))}
        </div>

        {/* Results Count Skeleton */}
        <Skeleton className="h-4 w-32" />

        {/* Masonry Grid Skeleton */}
        <div className="columns-2 md:columns-3 lg:columns-4 gap-4 space-y-4">
          {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
            <div
              key={i}
              className="break-inside-avoid rounded-lg border overflow-hidden mb-4"
              style={{ height: `${150 + (i % 3) * 50}px` }}
            >
              <Skeleton className="h-full w-full" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
