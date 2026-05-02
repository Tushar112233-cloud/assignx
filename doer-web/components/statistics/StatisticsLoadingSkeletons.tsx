import { Skeleton } from '@/components/ui/skeleton';

/**
 * Loading skeletons for the Statistics page
 * Matches the exact layout structure of the redesigned statistics page
 */
export default function StatisticsLoadingSkeletons() {
  return (
    <div className="space-y-8">
      {/* Hero Banner Skeleton */}
      <Skeleton className="h-64 rounded-[32px]" />

      {/* 4-Column Stat Cards Grid */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[...Array(4)].map((_, index) => (
          <Skeleton
            key={`stat-card-${index}`}
            className="h-32 rounded-2xl"
          />
        ))}
      </div>

      {/* Bento Grid (2x2) - Varying Heights */}
      <div className="grid gap-6 lg:grid-cols-2">
        <Skeleton className="h-80 rounded-[24px]" />
        <Skeleton className="h-80 rounded-[24px]" />
        <Skeleton className="h-96 rounded-[24px] lg:col-span-2" />
      </div>

      {/* Full-Width Heatmap */}
      <Skeleton className="h-64 rounded-[24px]" />

      {/* 2-Column Insights Grid */}
      <div className="grid gap-6 lg:grid-cols-2">
        <Skeleton className="h-80 rounded-[24px]" />
        <Skeleton className="h-80 rounded-[24px]" />
      </div>
    </div>
  );
}
