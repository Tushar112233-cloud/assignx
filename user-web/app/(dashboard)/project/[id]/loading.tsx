import { Loader2 } from "lucide-react";
import { Skeleton } from "@/components/ui/skeleton";

/**
 * Project detail loading state
 * Shows skeleton UI while project details are loading
 */
export default function ProjectDetailLoading() {
  return (
    <div className="flex min-h-screen flex-col">
      {/* Header Skeleton */}
      <div className="border-b bg-background/95 p-4 backdrop-blur">
        <div className="flex items-center gap-4">
          <Skeleton className="h-8 w-8" />
          <div className="flex-1">
            <Skeleton className="mb-1 h-5 w-48" />
            <Skeleton className="h-4 w-24" />
          </div>
        </div>
      </div>

      {/* Status Banner Skeleton */}
      <Skeleton className="h-12 w-full" />

      {/* Main Content */}
      <main className="flex-1 space-y-4 p-4 lg:p-6">
        {/* Deadline Skeleton */}
        <Skeleton className="h-24 w-full rounded-lg" />

        {/* Brief Skeleton */}
        <div className="rounded-lg border p-4">
          <Skeleton className="mb-4 h-6 w-32" />
          <div className="space-y-2">
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-3/4" />
            <Skeleton className="h-4 w-1/2" />
          </div>
        </div>

        {/* Deliverables Skeleton */}
        <div className="rounded-lg border p-4">
          <Skeleton className="mb-4 h-6 w-32" />
          <div className="space-y-3">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center gap-3">
                <Skeleton className="h-5 w-5" />
                <Skeleton className="h-4 flex-1" />
                <Skeleton className="h-8 w-24" />
              </div>
            ))}
          </div>
        </div>

        {/* Center loader */}
        <div className="flex justify-center py-8">
          <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        </div>
      </main>
    </div>
  );
}
