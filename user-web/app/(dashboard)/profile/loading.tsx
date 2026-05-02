import { Skeleton } from "@/components/ui/skeleton";

/**
 * Profile page loading state
 * Shows skeleton UI while profile data is loading
 */
export default function ProfileLoading() {
  return (
    <div className="flex flex-col p-4 lg:p-6">
      {/* Header Skeleton */}
      <div className="mb-6">
        <Skeleton className="mb-2 h-8 w-32" />
        <Skeleton className="h-4 w-64" />
      </div>

      {/* Profile Card Skeleton */}
      <div className="rounded-lg border p-6">
        <div className="flex items-start gap-6">
          {/* Avatar */}
          <Skeleton className="h-24 w-24 rounded-full" />

          {/* Info */}
          <div className="flex-1 space-y-3">
            <Skeleton className="h-6 w-48" />
            <Skeleton className="h-4 w-64" />
            <Skeleton className="h-4 w-32" />
          </div>
        </div>

        {/* Form Fields */}
        <div className="mt-8 grid gap-6 md:grid-cols-2">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="space-y-2">
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-10 w-full" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
