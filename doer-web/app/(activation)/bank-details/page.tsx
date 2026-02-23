'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Skeleton } from '@/components/ui/skeleton'
import { BankDetailsForm } from '@/components/activation/BankDetailsForm'
import { ROUTES } from '@/lib/constants'
import { useAuth } from '@/hooks/useAuth'
import { activationService } from '@/services/activation.service'

/**
 * Bank details page
 * Step 3 of the activation flow
 */
export default function BankDetailsPage() {
  const router = useRouter()
  const { doer, isLoading: authLoading } = useAuth()
  const [error, setError] = useState<string | null>(null)

  // Show loading while auth is initializing
  if (authLoading) {
    return (
      <div className="flex flex-col items-center justify-center space-y-6 py-12">
        <Skeleton className="h-8 w-48 rounded-lg" />
        <Skeleton className="h-4 w-64 rounded" />
        <div className="w-full max-w-lg space-y-4 mt-4">
          <Skeleton className="h-12 w-full rounded-xl" />
          <Skeleton className="h-12 w-full rounded-xl" />
          <Skeleton className="h-12 w-full rounded-xl" />
          <Skeleton className="h-12 w-full rounded-xl" />
        </div>
      </div>
    )
  }

  /**
   * Handle form completion
   * Saves bank details to database and activates the doer
   */
  const handleComplete = async (data: {
    accountHolderName: string
    accountNumber: string
    confirmAccountNumber: string
    ifscCode: string
    upiId?: string
  }) => {
    setError(null)

    if (!doer?.id) {
      setError('You must be logged in to submit bank details')
      return
    }

    try {
      // Submit bank details to database
      const success = await activationService.submitBankDetails(doer.id, {
        accountHolderName: data.accountHolderName,
        accountNumber: data.accountNumber,
        ifscCode: data.ifscCode,
        upiId: data.upiId,
      })

      if (!success) {
        throw new Error('Failed to save bank details')
      }

      // Mark onboarding as complete in localStorage (for UI state)
      localStorage.setItem('hasSeenOnboarding', 'true')

      // Navigate to dashboard
      router.push(ROUTES.dashboard)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred'
      setError(errorMessage)
      console.error('Bank details submission error:', err)
    }
  }

  return (
    <>
      {error && (
        <div className="fixed top-4 left-4 right-4 z-50 rounded-md bg-destructive/10 p-3 text-sm text-destructive">
          {error}
        </div>
      )}
      <BankDetailsForm
        onComplete={handleComplete}
      />
    </>
  )
}
