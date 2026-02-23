import { Skeleton } from '@/components/ui/skeleton'

/**
 * Loading skeleton for (onboarding) route group pages.
 */
export default function OnboardingLoading() {
  return (
    <div className="flex flex-col items-center justify-center space-y-6 py-12">
      <Skeleton className="h-12 w-12 rounded-full" />
      <Skeleton className="h-8 w-56 rounded-lg" />
      <Skeleton className="h-4 w-72 rounded" />
      <div className="w-full max-w-md space-y-4 mt-4">
        <Skeleton className="h-48 w-full rounded-2xl" />
        <Skeleton className="h-12 w-full rounded-xl" />
      </div>
    </div>
  )
}
