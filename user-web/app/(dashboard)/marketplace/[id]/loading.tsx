import { Skeleton } from "@/components/ui/skeleton";

export default function MarketplaceDetailLoading() {
  return (
    <div className="flex-1 p-6 md:p-8 max-w-5xl mx-auto">
      {/* Back button skeleton */}
      <div className="flex items-center justify-between mb-6">
        <Skeleton className="h-9 w-20" />
        <div className="flex items-center gap-2">
          <Skeleton className="h-9 w-9 rounded-lg" />
          <Skeleton className="h-9 w-9 rounded-lg" />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main content skeleton */}
        <div className="lg:col-span-2 space-y-6">
          {/* Image skeleton */}
          <Skeleton className="aspect-[4/3] w-full rounded-xl" />

          {/* Title & price skeleton */}
          <div className="space-y-2">
            <Skeleton className="h-8 w-3/4" />
            <Skeleton className="h-6 w-32" />
          </div>

          {/* Meta skeleton */}
          <div className="flex gap-4">
            <Skeleton className="h-5 w-20" />
            <Skeleton className="h-5 w-20" />
            <Skeleton className="h-5 w-24" />
          </div>

          {/* Badges skeleton */}
          <div className="flex gap-2">
            <Skeleton className="h-6 w-20 rounded-full" />
            <Skeleton className="h-6 w-24 rounded-full" />
          </div>

          {/* Description skeleton */}
          <div className="space-y-2">
            <Skeleton className="h-5 w-28" />
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-3/4" />
          </div>
        </div>

        {/* Sidebar skeleton */}
        <div className="space-y-4">
          {/* Seller card skeleton */}
          <div className="p-4 rounded-xl border border-border bg-card space-y-4">
            <div className="flex items-center gap-3">
              <Skeleton className="h-12 w-12 rounded-full" />
              <div className="flex-1 space-y-2">
                <Skeleton className="h-4 w-24" />
                <Skeleton className="h-3 w-32" />
              </div>
            </div>
            <Skeleton className="h-10 w-full rounded-lg" />
          </div>

          {/* Safety tips skeleton */}
          <div className="p-4 rounded-xl border border-border bg-muted/50 space-y-3">
            <Skeleton className="h-4 w-20" />
            <Skeleton className="h-3 w-full" />
            <Skeleton className="h-3 w-full" />
            <Skeleton className="h-3 w-3/4" />
          </div>
        </div>
      </div>
    </div>
  );
}
