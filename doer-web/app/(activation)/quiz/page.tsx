'use client'

import { useState, useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import dynamic from 'next/dynamic'
import type { QuizResult } from '@/components/activation/QuizComponent'
import { ROUTES } from '@/lib/constants'

/** Lazy load heavy QuizComponent (contains animations) */
const QuizComponent = dynamic(
  () => import('@/components/activation/QuizComponent').then(mod => ({ default: mod.QuizComponent })),
  {
    loading: () => (
      <div className="flex min-h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    ),
    ssr: false
  }
)
import { apiClient, getAccessToken } from '@/lib/api/client'
import { activationService } from '@/services/activation.service'
import { useAuthToken } from '@/hooks/useAuthToken'
import type { QuizQuestion } from '@/types/database'

/** Quiz questions without correct answers (security - not sent to client) */
type SafeQuizQuestion = Omit<QuizQuestion, 'correct_option_ids'>

/**
 * Quiz page
 * Step 2 of the activation flow
 */
export default function QuizPage() {
  const router = useRouter()
  const { hasToken, isReady } = useAuthToken({ redirectOnMissing: true })
  const [questions, setQuestions] = useState<SafeQuizQuestion[]>([])
  const [previousAttempts, setPreviousAttempts] = useState(0)
  const [error, setError] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSubmitting, setIsSubmitting] = useState(false)

  /** Ref to track if component is mounted (prevents memory leaks) */
  const isMountedRef = useRef(true)

  /**
   * Cleanup: Mark component as unmounted
   */
  useEffect(() => {
    isMountedRef.current = true
    return () => {
      isMountedRef.current = false
    }
  }, [])

  /**
   * Fetch quiz questions on mount
   */
  useEffect(() => {
    if (!isReady || !hasToken) return

    const init = async () => {
      try {
        // Fetch quiz questions from database
        const quizQuestions = await activationService.getQuizQuestions()
        if (!isMountedRef.current) return
        setQuestions(quizQuestions)

        // Get current user from JWT
        const currentUser = await apiClient<{ id: string }>('/api/auth/me')
        if (!currentUser) {
          if (isMountedRef.current) setIsLoading(false)
          return
        }

        // Get doer record
        try {
          const doer = await apiClient<{ id: string }>(`/api/doers/by-profile/${currentUser.id}`)
          if (doer && isMountedRef.current) {
            // Fetch activation status to get attempt count
            const activation = await activationService.getActivationStatus(doer.id)
            if (activation && isMountedRef.current) {
              setPreviousAttempts(activation.total_quiz_attempts || 0)
            }
          }
        } catch {
          // No doer record yet
        }
      } catch (err) {
        console.error('Error initializing quiz:', err)
      } finally {
        if (isMountedRef.current) setIsLoading(false)
      }
    }

    init()
  }, [isReady, hasToken])

  /**
   * Handle quiz pass
   * Fetches user/doer on-demand and saves quiz results
   */
  const handlePass = async (result: QuizResult) => {
    setError(null)
    setIsSubmitting(true)

    try {
      // Get current user from JWT
      const user = await apiClient<{ id: string }>('/api/auth/me')

      if (!isMountedRef.current) return

      if (!user) {
        setError('You must be logged in to complete the quiz')
        return
      }

      // Get doer record
      let doer: { id: string } | null = null
      try {
        doer = await apiClient<{ id: string }>(`/api/doers/by-profile/${user.id}`)
      } catch {
        // No doer record
      }

      if (!isMountedRef.current) return

      if (!doer) {
        setError('Doer profile not found')
        return
      }

      // Submit quiz attempt
      const { passed, rateLimited, retryAfterMinutes } = await activationService.submitQuizAttempt(
        doer.id,
        result.correctAnswers,
        result.totalQuestions,
        result.answers
      )

      if (!isMountedRef.current) return

      // Handle rate limiting
      if (rateLimited) {
        setError(`Too many quiz attempts. Please wait ${retryAfterMinutes} minute${retryAfterMinutes !== 1 ? 's' : ''} before trying again.`)
        return
      }

      if (passed) {
        router.push(ROUTES.bankDetails)
      } else {
        setError('Quiz not passed. Review the training materials and try again.')
        setPreviousAttempts(prev => prev + 1)
      }
    } catch (err) {
      if (!isMountedRef.current) return
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred'
      setError(errorMessage)
    } finally {
      if (isMountedRef.current) setIsSubmitting(false)
    }
  }

  /**
   * Handle quiz fail
   * Fetches user/doer on-demand and saves failed attempt
   */
  const handleFail = async (result: QuizResult) => {
    setError(null)
    setIsSubmitting(true)

    try {
      // Get current user from JWT
      const user = await apiClient<{ id: string }>('/api/auth/me').catch(() => null)

      if (!isMountedRef.current) return

      if (!user) {
        router.push(ROUTES.training)
        return
      }

      // Get doer record
      const doer = await apiClient<{ id: string }>(`/api/doers/by-profile/${user.id}`).catch(() => null)

      if (!isMountedRef.current) return

      if (doer) {
        // Submit failed quiz attempt
        const { rateLimited, retryAfterMinutes } = await activationService.submitQuizAttempt(
          doer.id,
          result.correctAnswers,
          result.totalQuestions,
          result.answers
        )

        if (!isMountedRef.current) return

        // Handle rate limiting
        if (rateLimited) {
          setError(`Too many quiz attempts. Please wait ${retryAfterMinutes} minute${retryAfterMinutes !== 1 ? 's' : ''} before trying again.`)
          return
        }
      }

      router.push(ROUTES.training)
    } catch (err) {
      if (isMountedRef.current) router.push(ROUTES.training)
    } finally {
      if (isMountedRef.current) setIsSubmitting(false)
    }
  }

  if (!isReady || isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    )
  }

  if (!hasToken) {
    return null // Will redirect via useAuthToken
  }

  return (
    <>
      {error && (
        <div className="fixed top-4 left-4 right-4 z-50 rounded-md bg-destructive/10 p-3 text-sm text-destructive">
          {error}
        </div>
      )}
      {isSubmitting && (
        <div className="fixed inset-0 z-50 bg-background/80 backdrop-blur-sm flex items-center justify-center">
          <div className="flex flex-col items-center gap-3">
            <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            <p className="text-sm text-muted-foreground">Saving your results...</p>
          </div>
        </div>
      )}
      <QuizComponent
        questions={questions}
        onPass={handlePass}
        onFail={handleFail}
        previousAttempts={previousAttempts}
      />
    </>
  )
}
