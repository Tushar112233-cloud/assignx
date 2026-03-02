import { Skeleton } from "@/components/ui/skeleton";

/**
 * Loading skeleton for the Marketplace page
 * Shows filter bar placeholder and 6 card placeholders in a grid
 */
export default function MarketplaceLoading() {
  return (
    <div className="min-h-screen bg-background">
      {/* Hero skeleton */}
      <div className="px-6 pt-6 pb-4">
        <Skeleton className="h-40 w-full rounded-2xl" />
      </div>

      {/* Search bar skeleton */}
      <div className="px-6 pb-4">
        <div className="max-w-2xl mx-auto">
          <Skeleton className="h-12 w-full rounded-xl" />
        </div>
      </div>

      {/* Category tabs skeleton */}
      <div className="px-6 pb-6">
        <div className="flex justify-center gap-2">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-9 w-24 rounded-full" />
          ))}
        </div>
      </div>

      {/* Grid skeleton */}
      <div className="px-6">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="rounded-xl border border-border overflow-hidden">
              <Skeleton className="aspect-[4/3] w-full" />
              <div className="p-3 space-y-2">
                <Skeleton className="h-4 w-3/4" />
                <div className="flex justify-between">
                  <Skeleton className="h-3 w-1/3" />
                  <Skeleton className="h-4 w-16 rounded" />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
