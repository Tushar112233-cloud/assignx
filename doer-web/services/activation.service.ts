import { apiClient } from '@/lib/api/client'
import { logger } from '@/lib/logger'
import type {
  DoerActivation,
  TrainingModule,
  TrainingProgress,
  QuizQuestion,
  QuizAttempt,
} from '@/types/database'

export const activationService = {
  async getActivationStatus(doerId: string): Promise<DoerActivation | null> {
    try {
      return await apiClient<DoerActivation>(`/api/doers/${doerId}/activation`)
    } catch (err) {
      logger.error('Activation', 'Error fetching activation status:', err)
      return null
    }
  },

  async createActivation(doerId: string): Promise<DoerActivation | null> {
    try {
      return await apiClient<DoerActivation>(`/api/doers/${doerId}/activation`, {
        method: 'POST',
      })
    } catch (err) {
      logger.error('Activation', 'Error creating activation:', err)
      return null
    }
  },

  async getTrainingModules(): Promise<TrainingModule[]> {
    try {
      const data = await apiClient<{ modules: TrainingModule[] }>('/api/training/modules')
      return data.modules || []
    } catch (err) {
      logger.error('Activation', 'Error fetching training modules:', err)
      return []
    }
  },

  async getTrainingProgress(doerId: string): Promise<TrainingProgress[]> {
    try {
      const data = await apiClient<{ progress: TrainingProgress[] }>(
        `/api/training/progress?doer_id=${doerId}`
      )
      return data.progress || []
    } catch (err) {
      logger.error('Activation', 'Error fetching training progress:', err)
      return []
    }
  },

  async updateTrainingProgress(
    doerId: string,
    moduleId: string,
    progress: Partial<TrainingProgress>
  ): Promise<TrainingProgress | null> {
    try {
      return await apiClient<TrainingProgress>(`/api/training/progress/${moduleId}`, {
        method: 'PUT',
        body: JSON.stringify({
          doer_id: doerId,
          ...progress,
        }),
      })
    } catch (err) {
      logger.error('Activation', 'Error updating training progress:', err)
      return null
    }
  },

  async completeTraining(doerId: string): Promise<boolean> {
    try {
      await apiClient(`/api/doers/${doerId}/activation/complete-training`, {
        method: 'POST',
      })
      return true
    } catch (err) {
      logger.error('Activation', 'Error completing training:', err)
      return false
    }
  },

  async getQuizQuestions(): Promise<Omit<QuizQuestion, 'correct_option_ids'>[]> {
    try {
      const data = await apiClient<{ questions: Omit<QuizQuestion, 'correct_option_ids'>[] }>(
        '/api/training/quiz?role=doer'
      )
      return data.questions || []
    } catch (err) {
      logger.error('Activation', 'Error fetching quiz questions:', err)
      return []
    }
  },

  async validateQuizAnswers(
    answers: Record<string, number>
  ): Promise<{ correctCount: number; totalQuestions: number }> {
    try {
      return await apiClient<{ correctCount: number; totalQuestions: number }>(
        '/api/training/quiz/validate',
        {
          method: 'POST',
          body: JSON.stringify({ answers, role: 'doer' }),
        }
      )
    } catch (err) {
      logger.error('Activation', 'Error validating quiz answers:', err)
      return { correctCount: 0, totalQuestions: 0 }
    }
  },

  async getQuizAttempts(doerId: string): Promise<QuizAttempt[]> {
    try {
      const data = await apiClient<{ attempts: QuizAttempt[] }>(
        `/api/training/quiz/attempts?doer_id=${doerId}`
      )
      return data.attempts || []
    } catch (err) {
      logger.error('Activation', 'Error fetching quiz attempts:', err)
      return []
    }
  },

  async submitQuizAttempt(
    doerId: string,
    _score: number,
    _totalQuestions: number,
    answers: Record<string, number>
  ): Promise<{ attempt: QuizAttempt | null; passed: boolean; rateLimited?: boolean; retryAfterMinutes?: number }> {
    try {
      return await apiClient<{
        attempt: QuizAttempt | null
        passed: boolean
        rateLimited?: boolean
        retryAfterMinutes?: number
      }>('/api/training/quiz/attempt', {
        method: 'POST',
        body: JSON.stringify({
          doer_id: doerId,
          answers,
          role: 'doer',
        }),
      })
    } catch (err) {
      logger.error('Activation', 'Error submitting quiz attempt:', err)
      return { attempt: null, passed: false }
    }
  },

  async submitBankDetails(
    doerId: string,
    bankDetails: {
      accountHolderName: string
      accountNumber: string
      ifscCode: string
      bankName?: string
      upiId?: string
    }
  ): Promise<boolean> {
    try {
      await apiClient(`/api/doers/${doerId}/bank-details`, {
        method: 'PUT',
        body: JSON.stringify({
          bank_account_name: bankDetails.accountHolderName,
          bank_account_number: bankDetails.accountNumber,
          bank_ifsc_code: bankDetails.ifscCode,
          bank_name: bankDetails.bankName,
          upi_id: bankDetails.upiId,
        }),
      })
      return true
    } catch (err) {
      logger.error('Activation', 'Error submitting bank details:', err)
      return false
    }
  },

  async isFullyActivated(doerId: string): Promise<boolean> {
    try {
      const data = await apiClient<DoerActivation>(`/api/doers/${doerId}/activation`)
      return data?.is_fully_activated ?? false
    } catch {
      return false
    }
  },
}
