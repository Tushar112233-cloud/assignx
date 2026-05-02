import { Skeleton } from "@/components/ui/skeleton";

/**
 * Wallet page loading state
 * Shows skeleton UI for wallet balance and transactions
 */
export default function WalletLoading() {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Header Skeleton */}
      <div className="border-b p-4">
        <Skeleton className="h-8 w-40" />
      </div>

      <div className="flex-1 p-4 lg:p-6">
        {/* Title Skeleton */}
        <div className="mb-6">
          <Skeleton className="mb-2 h-8 w-32" />
          <Skeleton className="h-4 w-56" />
        </div>

        <div className="space-y-6">
          {/* Wallet Balance Card Skeleton */}
          <div className="rounded-lg bg-primary/10 p-6">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <Skeleton className="h-4 w-28 bg-primary/20" />
                <Skeleton className="h-10 w-36 bg-primary/20" />
                <Skeleton className="h-3 w-48 bg-primary/20" />
              </div>
              <Skeleton className="h-14 w-14 rounded-full bg-primary/20" />
            </div>
            <Skeleton className="mt-6 h-10 w-full bg-primary/20" />
          </div>

          {/* Transaction History Skeleton */}
          <div className="rounded-lg border">
            <div className="p-4 border-b">
              <Skeleton className="h-5 w-40" />
            </div>
            <div className="p-4 space-y-3">
              {[1, 2, 3, 4, 5].map((i) => (
                <div
                  key={i}
                  className="flex items-center justify-between p-3 rounded-lg border"
                >
                  <div className="flex items-center gap-3">
                    <Skeleton className="h-10 w-10 rounded-full" />
                    <div className="space-y-2">
                      <Skeleton className="h-4 w-32" />
                      <Skeleton className="h-3 w-24" />
                    </div>
                  </div>
                  <div className="text-right space-y-2">
                    <Skeleton className="h-5 w-16 ml-auto" />
                    <Skeleton className="h-4 w-20 ml-auto" />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
