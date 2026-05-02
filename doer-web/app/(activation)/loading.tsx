import { Skeleton } from '@/components/ui/skeleton'

/**
 * Loading skeleton for (activation) route group pages.
 */
export default function ActivationLoading() {
  return (
    <div className="flex flex-col items-center justify-center space-y-6 py-12">
      <Skeleton className="h-8 w-48 rounded-lg" />
      <Skeleton className="h-4 w-64 rounded" />
      <div className="w-full max-w-lg space-y-4 mt-4">
        <Skeleton className="h-32 w-full rounded-2xl" />
        <Skeleton className="h-12 w-full rounded-xl" />
        <Skeleton className="h-12 w-full rounded-xl" />
      </div>
    </div>
  )
}
