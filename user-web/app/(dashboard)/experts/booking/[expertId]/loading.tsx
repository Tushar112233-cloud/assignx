import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

/**
 * Loading skeleton for expert booking page
 */
export default function ExpertBookingLoading() {
  return (
    <div className="container max-w-4xl mx-auto px-4 py-6 space-y-6">
      {/* Back Button Skeleton */}
      <Skeleton className="h-9 w-32" />

      {/* Header Skeleton */}
      <div className="text-center">
        <Skeleton className="h-8 w-48 mx-auto mb-2" />
        <Skeleton className="h-5 w-64 mx-auto" />
      </div>

      {/* Step Indicator Skeleton */}
      <div className="flex items-center justify-center gap-2 mb-6">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="flex items-center">
            <Skeleton className="w-8 h-8 rounded-full" />
            <Skeleton className="w-16 h-4 ml-2 hidden sm:block" />
            {i < 2 && <Skeleton className="w-8 h-0.5 mx-2" />}
          </div>
        ))}
      </div>

      <div className="grid md:grid-cols-3 gap-6">
        {/* Main Content Skeleton */}
        <div className="md:col-span-2 space-y-4">
          {/* Calendar Skeleton */}
          <Card>
            <CardHeader>
              <Skeleton className="h-5 w-32" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-64 w-full" />
            </CardContent>
          </Card>

          {/* Time Slots Skeleton */}
          <Card>
            <CardHeader>
              <Skeleton className="h-5 w-48" />
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
                {Array.from({ length: 8 }).map((_, i) => (
                  <Skeleton key={i} className="h-10 rounded-md" />
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Navigation Buttons Skeleton */}
          <div className="flex justify-end mt-6">
            <Skeleton className="h-10 w-24" />
          </div>
        </div>

        {/* Sidebar Skeleton */}
        <div className="space-y-4">
          <Card>
            <CardContent className="p-4">
              <div className="flex items-center gap-3 mb-4">
                <Skeleton className="h-12 w-12 rounded-full" />
                <div className="space-y-2">
                  <Skeleton className="h-4 w-24" />
                  <Skeleton className="h-3 w-32" />
                </div>
              </div>
              <Skeleton className="h-16 w-full rounded-lg" />
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-4 space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="flex items-center gap-2">
                  <Skeleton className="h-4 w-4 rounded-full" />
                  <Skeleton className="h-4 w-32" />
                </div>
              ))}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
