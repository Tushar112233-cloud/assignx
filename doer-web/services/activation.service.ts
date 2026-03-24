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
      const data = await apiClient<{ activation: DoerActivation | null }>(`/api/doers/${doerId}/activation`)
      return data.activation || null
    } catch (err) {
      logger.error('Activation', 'Error fetching activation status:', err)
      return null
    }
  },

  async createActivation(doerId: string): Promise<DoerActivation | null> {
    // The activation record is created server-side during doer signup.
    // Just fetch the existing one (or return null if not yet created).
    try {
      const data = await apiClient<{ activation: DoerActivation | null }>(`/api/doers/${doerId}/activation`)
      return data.activation || null
    } catch (err) {
      logger.error('Activation', 'Error fetching activation:', err)
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

  async getTrainingProgress(_doerId: string): Promise<TrainingProgress[]> {
    try {
      const data = await apiClient<{ progress: TrainingProgress[] }>(
        `/api/training/progress`
      )
      return data.progress || []
    } catch (err) {
      logger.error('Activation', 'Error fetching training progress:', err)
      return []
    }
  },

  async updateTrainingProgress(
    _doerId: string,
    moduleId: string,
    progress: Partial<TrainingProgress>
  ): Promise<TrainingProgress | null> {
    try {
      // API expects { progress: <number> } where progress >= 100 triggers completion
      const progressValue = progress.progress_percentage || 0
      const data = await apiClient<{ progress: TrainingProgress }>(`/api/training/progress/${moduleId}`, {
        method: 'PUT',
        body: JSON.stringify({
          progress: progressValue,
        }),
      })
      return data.progress || null
    } catch (err) {
      logger.error('Activation', 'Error updating training progress:', err)
      return null
    }
  },

  async completeTraining(_doerId: string): Promise<boolean> {
    try {
      await apiClient(`/api/training/complete`, {
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
      const data = await apiClient<{ questions: any[] }>(
        '/api/training/quiz?role=doer'
      )
      // Normalize API response (MongoDB camelCase) to frontend format (snake_case)
      return (data.questions || []).map((q: any) => ({
        id: (q._id || q.id || '').toString(),
        target_role: q.targetRole || q.target_role || 'doer',
        question_text: q.question || q.question_text || '',
        question_type: q.questionType || q.question_type || 'multiple_choice',
        options: Array.isArray(q.options)
          ? q.options.map((opt: any, idx: number) =>
              typeof opt === 'string'
                ? { id: idx, text: opt }
                : { id: opt.id ?? idx, text: opt.text || opt }
            )
          : [],
        explanation: q.explanation || null,
        points: q.points || 1,
        sequence_order: q.order ?? q.sequence_order ?? 0,
        moduleId: (q.moduleId || '').toString(),
        created_at: q.createdAt || q.created_at || new Date().toISOString(),
        updated_at: q.updatedAt || q.updated_at || new Date().toISOString(),
        is_active: q.isActive ?? q.is_active ?? true,
      }))
    } catch (err) {
      logger.error('Activation', 'Error fetching quiz questions:', err)
      return []
    }
  },

  async validateQuizAnswers(
    answers: Record<string, number>,
    moduleId?: string
  ): Promise<{ correctCount: number; totalQuestions: number }> {
    // Validation is done server-side during quiz attempt submission.
    // Submit the attempt and extract the score from the response.
    try {
      // Transform Record<questionId, selectedAnswer> to array format expected by API
      const answersArray = Object.entries(answers).map(([questionId, selectedAnswer]) => ({
        questionId,
        selectedAnswer,
      }))

      const result = await apiClient<{ attempt: { score: number; totalQuestions: number; passed: boolean } }>(
        '/api/training/quiz/attempt',
        {
          method: 'POST',
          body: JSON.stringify({ answers: answersArray, moduleId }),
        }
      )
      const attempt = result.attempt
      const correctCount = Math.round((attempt.score / 100) * attempt.totalQuestions)
      return { correctCount, totalQuestions: attempt.totalQuestions }
    } catch (err) {
      logger.error('Activation', 'Error validating quiz answers:', err)
      return { correctCount: 0, totalQuestions: 0 }
    }
  },

  async getQuizAttempts(_doerId: string): Promise<QuizAttempt[]> {
    try {
      const data = await apiClient<{ attempts: QuizAttempt[] }>(
        `/api/training/quiz/attempts`
      )
      return data.attempts || []
    } catch (err) {
      logger.error('Activation', 'Error fetching quiz attempts:', err)
      return []
    }
  },

  async submitQuizAttempt(
    _doerId: string,
    _score: number,
    _totalQuestions: number,
    answers: Record<string, number>,
    moduleId?: string
  ): Promise<{ attempt: QuizAttempt | null; passed: boolean; rateLimited?: boolean; retryAfterMinutes?: number }> {
    try {
      // Transform Record<questionId, selectedAnswer> to array format expected by API
      const answersArray = Object.entries(answers).map(([questionId, selectedAnswer]) => ({
        questionId,
        selectedAnswer,
      }))

      const data = await apiClient<{
        attempt: QuizAttempt & { passed: boolean }
      }>('/api/training/quiz/attempt', {
        method: 'POST',
        body: JSON.stringify({
          moduleId,
          answers: answersArray,
        }),
      })

      return {
        attempt: data.attempt || null,
        passed: data.attempt?.passed ?? false,
      }
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
          accountName: bankDetails.accountHolderName,
          accountNumber: bankDetails.accountNumber,
          ifscCode: bankDetails.ifscCode,
          bankName: bankDetails.bankName,
          upiId: bankDetails.upiId,
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
      const data = await apiClient<{ activation: DoerActivation | null }>(`/api/doers/${doerId}/activation`)
      return data?.activation?.is_fully_activated ?? false
    } catch {
      return false
    }
  },
}
