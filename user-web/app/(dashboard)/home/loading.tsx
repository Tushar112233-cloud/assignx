import { Skeleton } from "@/components/ui/skeleton";

/**
 * Dashboard home page loading state
 * Shows skeleton UI for banners, services, and recent projects
 */
export default function HomeLoading() {
  return (
    <div className="flex flex-col">
      {/* Header Skeleton */}
      <div className="border-b p-4">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-40" />
          <div className="flex gap-2">
            <Skeleton className="h-10 w-10 rounded-full" />
            <Skeleton className="h-10 w-10 rounded-full" />
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 space-y-8 p-4 lg:p-6">
        {/* Banner Carousel Skeleton */}
        <section>
          <Skeleton className="h-40 w-full rounded-xl" />
        </section>

        {/* Services Grid Skeleton */}
        <section>
          <Skeleton className="mb-4 h-6 w-32" />
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="rounded-lg border p-4 space-y-3">
                <Skeleton className="h-12 w-12 rounded-lg mx-auto" />
                <Skeleton className="h-4 w-20 mx-auto" />
              </div>
            ))}
          </div>
        </section>

        {/* Campus Pulse Skeleton */}
        <section>
          <div className="flex items-center justify-between mb-4">
            <Skeleton className="h-6 w-36" />
            <Skeleton className="h-4 w-16" />
          </div>
          <div className="flex gap-4 overflow-hidden">
            {[1, 2, 3].map((i) => (
              <div
                key={i}
                className="flex-shrink-0 w-64 rounded-lg border p-4 space-y-2"
              >
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-3/4" />
                <Skeleton className="h-3 w-20" />
              </div>
            ))}
          </div>
        </section>

        {/* Recent Projects Skeleton */}
        <section>
          <div className="flex items-center justify-between mb-4">
            <Skeleton className="h-6 w-32" />
            <Skeleton className="h-4 w-16" />
          </div>
          <div className="space-y-3">
            {[1, 2, 3].map((i) => (
              <div
                key={i}
                className="flex items-center gap-4 rounded-lg border p-4"
              >
                <Skeleton className="h-12 w-12 rounded-lg" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-5 w-48" />
                  <Skeleton className="h-3 w-32" />
                </div>
                <Skeleton className="h-6 w-20" />
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}
