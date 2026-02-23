import { Skeleton } from '@/components/ui/skeleton'

/**
 * Loading skeleton for (auth) route group pages.
 */
export default function AuthLoading() {
  return (
    <div className="flex flex-col items-center justify-center space-y-6 py-8">
      <Skeleton className="h-10 w-48 rounded-lg" />
      <Skeleton className="h-4 w-64 rounded" />
      <div className="w-full max-w-sm space-y-4 mt-6">
        <Skeleton className="h-12 w-full rounded-xl" />
        <Skeleton className="h-12 w-full rounded-xl" />
        <Skeleton className="h-12 w-full rounded-xl" />
      </div>
    </div>
  )
}
