'use client'

import { useState, useEffect, useCallback, useRef } from 'react'
import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { activationService } from '@/services/activation.service'
import { logger } from '@/lib/logger'
import type { DoerActivation, TrainingProgress, QuizAttempt } from '@/types/database'

interface ActivationState {
  activation: DoerActivation | null
  trainingProgress: TrainingProgress[]
  quizAttempts: QuizAttempt[]
  isLoading: boolean
  error: string | null
  setActivation: (activation: DoerActivation | null) => void
  setTrainingProgress: (progress: TrainingProgress[]) => void
  addTrainingProgress: (progress: TrainingProgress) => void
  setQuizAttempts: (attempts: QuizAttempt[]) => void
  addQuizAttempt: (attempt: QuizAttempt) => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  reset: () => void
}

export const useActivationStore = create<ActivationState>()(
  persist(
    (set) => ({
      activation: null,
      trainingProgress: [],
      quizAttempts: [],
      isLoading: false,
      error: null,

      setActivation: (activation) => set({ activation }),

      setTrainingProgress: (progress) => set({ trainingProgress: progress }),

      addTrainingProgress: (progress) =>
        set((state) => ({
          trainingProgress: [
            ...state.trainingProgress.filter((p) => p.module_id !== progress.module_id),
            progress,
          ],
        })),

      setQuizAttempts: (attempts) => set({ quizAttempts: attempts }),

      addQuizAttempt: (attempt) =>
        set((state) => ({
          quizAttempts: [...state.quizAttempts, attempt],
        })),

      setLoading: (loading) => set({ isLoading: loading }),

      setError: (error) => set({ error }),

      reset: () =>
        set({
          activation: null,
          trainingProgress: [],
          quizAttempts: [],
          isLoading: false,
          error: null,
        }),
    }),
    {
      name: 'activation-storage',
      partialize: (state) => ({
        activation: state.activation,
        trainingProgress: state.trainingProgress,
        quizAttempts: state.quizAttempts,
      }),
    }
  )
)

export function useActivation() {
  const store = useActivationStore()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const getCurrentStep = useCallback(() => {
    if (!store.activation) return 1
    if (!store.activation.training_completed) return 1
    if (!store.activation.quiz_passed) return 2
    if (!store.activation.bank_details_added) return 3
    return 3
  }, [store.activation])

  const isStepCompleted = useCallback(
    (step: number) => {
      if (!store.activation) return false
      switch (step) {
        case 1:
          return store.activation.training_completed
        case 2:
          return store.activation.quiz_passed
        case 3:
          return store.activation.bank_details_added
        default:
          return false
      }
    },
    [store.activation]
  )

  const isStepUnlocked = useCallback(
    (step: number) => {
      if (step === 1) return true
      if (!store.activation) return false
      switch (step) {
        case 2:
          return store.activation.training_completed
        case 3:
          return store.activation.quiz_passed
        default:
          return false
      }
    },
    [store.activation]
  )

  const getCompletedModules = useCallback(() => {
    return store.trainingProgress
      .filter((p) => p.status === 'completed')
      .map((p) => p.module_id)
  }, [store.trainingProgress])

  const getQuizAttempts = useCallback(() => {
    return store.quizAttempts.length
  }, [store.quizAttempts])

  const completeTrainingModule = useCallback(
    async (moduleId: string) => {
      const doerId = store.activation?.doer_id
      if (!doerId) return

      try {
        const dbProgress = await activationService.updateTrainingProgress(doerId, moduleId, {
          progress_percentage: 100,
          status: 'completed',
          completed_at: new Date().toISOString(),
        } as Partial<TrainingProgress>)

        if (dbProgress) {
          store.addTrainingProgress(dbProgress)
          return
        }
      } catch (err) {
        logger.error('Activation', 'Error persisting training progress:', err)
      }

      const progress: TrainingProgress = {
        id: `progress-${moduleId}`,
        user_id: doerId,
        user_role: 'doer',
        module_id: moduleId,
        started_at: new Date().toISOString(),
        completed_at: new Date().toISOString(),
        progress_percentage: 100,
        status: 'completed',
      }
      store.addTrainingProgress(progress)
    },
    [store]
  )

  const completeTraining = useCallback(async () => {
    if (!store.activation) return

    const doerId = store.activation.doer_id
    try {
      const success = await activationService.completeTraining(doerId)
      if (success) {
        const updatedActivation: DoerActivation = {
          ...store.activation,
          training_completed: true,
          training_completed_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        }
        store.setActivation(updatedActivation)
        return
      }
    } catch (err) {
      logger.error('Activation', 'Error persisting training completion:', err)
    }

    const updatedActivation: DoerActivation = {
      ...store.activation,
      training_completed: true,
      training_completed_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }
    store.setActivation(updatedActivation)
  }, [store])

  const submitQuizAttempt = useCallback(
    async (score: number, totalQuestions: number, answers: Record<string, number>) => {
      if (!store.activation) return false

      const doerId = store.activation.doer_id

      try {
        const result = await activationService.submitQuizAttempt(doerId, score, totalQuestions, answers)

        if (result.rateLimited) {
          store.setError(`Rate limited. Try again in ${result.retryAfterMinutes} minutes.`)
          return false
        }

        if (result.attempt) {
          store.addQuizAttempt(result.attempt)

          if (result.passed) {
            const updated = await activationService.getActivationStatus(doerId)
            if (updated) {
              store.setActivation(updated)
            }
          }
        }

        return result.passed
      } catch (err) {
        logger.error('Activation', 'Error submitting quiz attempt:', err)

        const isPassed = (score / totalQuestions) * 100 >= 80
        const attemptNumber = store.quizAttempts.length + 1

        const attempt: QuizAttempt = {
          id: `attempt-${Date.now()}`,
          user_id: store.activation.doer_id,
          user_role: 'doer',
          target_role: 'doer',
          attempt_number: attemptNumber,
          started_at: new Date().toISOString(),
          completed_at: new Date().toISOString(),
          score_percentage: (score / totalQuestions) * 100,
          correct_answers: score,
          total_questions: totalQuestions,
          passing_score: 80,
          is_passed: isPassed,
          answers,
        }
        store.addQuizAttempt(attempt)
        return isPassed
      }
    },
    [store]
  )

  const submitBankDetails = useCallback(
    async (bankDetails: {
      accountHolderName: string
      accountNumber: string
      ifscCode: string
      upiId?: string
    }) => {
      if (!store.activation) return

      const doerId = store.activation.doer_id

      try {
        const success = await activationService.submitBankDetails(doerId, bankDetails)
        if (success) {
          const updated = await activationService.getActivationStatus(doerId)
          if (updated) {
            store.setActivation(updated)
            return
          }
        }
      } catch (err) {
        logger.error('Activation', 'Error persisting bank details:', err)
      }

      const updatedActivation: DoerActivation = {
        ...store.activation,
        bank_details_added: true,
        bank_details_added_at: new Date().toISOString(),
        is_fully_activated: true,
        activated_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      }
      store.setActivation(updatedActivation)
    },
    [store]
  )

  const getProgressPercentage = useCallback(() => {
    let completed = 0
    if (store.activation?.training_completed) completed++
    if (store.activation?.quiz_passed) completed++
    if (store.activation?.bank_details_added) completed++
    return (completed / 3) * 100
  }, [store.activation])

  const isFullyActivated = useCallback(() => {
    return store.activation?.is_fully_activated ?? false
  }, [store.activation])

  const setActivationRef = useRef(store.setActivation)
  setActivationRef.current = store.setActivation
  const activationRef = useRef(store.activation)
  activationRef.current = store.activation

  // Initialize activation from API if not present
  useEffect(() => {
    if (!mounted) return

    let isCancelled = false

    const loadActivation = async () => {
      try {
        const token = getAccessToken()
        if (!token || isCancelled) return

        // Get the doer record for the authenticated user
        let doer: { id: string } | null = null
        try {
          doer = await apiClient<{ id: string }>(`/api/doers/me`)
        } catch {
          return
        }

        if (!doer || isCancelled) return

        // Fetch existing activation record from API
        const activation = await activationService.getActivationStatus(doer.id)
        if (isCancelled) return

        if (activation) {
          setActivationRef.current(activation)
        } else if (!activationRef.current) {
          const newActivation = await activationService.createActivation(doer.id)
          if (newActivation && !isCancelled) {
            setActivationRef.current(newActivation)
          }
        }
      } catch {
        // Activation fetch failed - keep existing store state if any
      }
    }

    loadActivation()

    return () => {
      isCancelled = true
    }
  }, [mounted])

  return {
    activation: store.activation,
    trainingProgress: store.trainingProgress,
    quizAttempts: store.quizAttempts,
    isLoading: store.isLoading,
    error: store.error,
    mounted,

    currentStep: getCurrentStep(),
    progressPercentage: getProgressPercentage(),
    isFullyActivated: isFullyActivated(),
    completedModules: getCompletedModules(),
    quizAttemptCount: getQuizAttempts(),

    isStepCompleted,
    isStepUnlocked,
    completeTrainingModule,
    completeTraining,
    submitQuizAttempt,
    submitBankDetails,
    reset: store.reset,
  }
}
