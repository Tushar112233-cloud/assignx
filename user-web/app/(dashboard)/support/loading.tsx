import { Skeleton } from "@/components/ui/skeleton";

/**
 * Support page loading state
 * Shows skeleton UI for FAQs, contact form, and tickets
 */
export default function SupportLoading() {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Header Skeleton */}
      <div className="border-b p-4">
        <Skeleton className="h-8 w-40" />
      </div>

      <div className="flex-1 p-4 lg:p-6 space-y-6">
        {/* Title Row Skeleton */}
        <div className="flex items-center justify-between">
          <div className="space-y-2">
            <Skeleton className="h-8 w-40" />
            <Skeleton className="h-4 w-56" />
          </div>
          <Skeleton className="h-10 w-28" />
        </div>

        {/* Two Column Grid Skeleton */}
        <div className="grid gap-6 lg:grid-cols-2">
          {/* Left Column - FAQs */}
          <div className="space-y-6">
            <div className="rounded-lg border p-6 space-y-4">
              <Skeleton className="h-6 w-48" />
              <div className="space-y-3">
                {[1, 2, 3, 4, 5].map((i) => (
                  <div key={i} className="border rounded-lg p-4">
                    <div className="flex items-center justify-between">
                      <Skeleton className="h-5 w-3/4" />
                      <Skeleton className="h-4 w-4" />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right Column - Contact & Tickets */}
          <div className="space-y-6">
            {/* Contact Form */}
            <div className="rounded-lg border p-6 space-y-4">
              <Skeleton className="h-6 w-32" />
              <div className="space-y-4">
                <div className="space-y-2">
                  <Skeleton className="h-4 w-20" />
                  <Skeleton className="h-10 w-full" />
                </div>
                <div className="space-y-2">
                  <Skeleton className="h-4 w-24" />
                  <Skeleton className="h-24 w-full" />
                </div>
                <Skeleton className="h-10 w-full" />
              </div>
            </div>

            {/* Ticket History */}
            <div className="rounded-lg border p-6 space-y-4">
              <Skeleton className="h-6 w-36" />
              <div className="space-y-3">
                {[1, 2].map((i) => (
                  <div key={i} className="border rounded-lg p-4 space-y-2">
                    <div className="flex justify-between">
                      <Skeleton className="h-4 w-48" />
                      <Skeleton className="h-5 w-16" />
                    </div>
                    <Skeleton className="h-3 w-24" />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
