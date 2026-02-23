import { createClient } from '@/lib/supabase/client'
import { verifyDoerOwnership, getAuthenticatedUser } from '@/lib/auth-helpers'
import { logger } from '@/lib/logger'
import type {
  DoerActivation,
  TrainingModule,
  TrainingProgress,
  QuizQuestion,
  QuizAttempt,
} from '@/types/database'

/**
 * Activation service
 * Handles all activation-related API calls
 */
export const activationService = {
  /**
   * Get activation status for a doer
   * @security Verifies ownership before returning data
   */
  async getActivationStatus(doerId: string): Promise<DoerActivation | null> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    const { data, error } = await supabase
      .from('doer_activation')
      .select('*')
      .eq('doer_id', doerId)
      .single()

    if (error) {
      logger.error('Activation', 'Error fetching activation status:', error)
      return null
    }

    return data
  },

  /**
   * Create initial activation record
   * @security Verifies ownership before creating record
   */
  async createActivation(doerId: string): Promise<DoerActivation | null> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    const { data, error } = await supabase
      .from('doer_activation')
      .insert({
        doer_id: doerId,
        training_completed: false,
        quiz_passed: false,
        total_quiz_attempts: 0,
        bank_details_added: false,
        is_fully_activated: false,
      })
      .select()
      .single()

    if (error) {
      logger.error('Activation', 'Error creating activation:', error)
      return null
    }

    return data
  },

  /**
   * Get all training modules
   */
  async getTrainingModules(): Promise<TrainingModule[]> {
    const supabase = createClient()

    const { data, error } = await supabase
      .from('training_modules')
      .select('*')
      .eq('is_active', true)
      .order('sequence_order', { ascending: true })

    if (error) {
      logger.error('Activation', 'Error fetching training modules:', error)
      return []
    }

    return data || []
  },

  /**
   * Get training progress for a doer
   * @security Verifies ownership before returning data
   */
  async getTrainingProgress(doerId: string): Promise<TrainingProgress[]> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    // Get profile_id from doer record (training_progress uses profile_id)
    const { data: doer, error: doerError } = await supabase
      .from('doers')
      .select('profile_id')
      .eq('id', doerId)
      .single()

    if (doerError || !doer) {
      logger.error('Activation', 'Error fetching doer for training progress:', doerError)
      return []
    }

    const { data, error } = await supabase
      .from('training_progress')
      .select('*')
      .eq('profile_id', doer.profile_id)

    if (error) {
      logger.error('Activation', 'Error fetching training progress:', error)
      return []
    }

    return data || []
  },

  /**
   * Update training progress for a module
   * @security Verifies ownership before updating
   */
  async updateTrainingProgress(
    doerId: string,
    moduleId: string,
    progress: Partial<TrainingProgress>
  ): Promise<TrainingProgress | null> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    // Get profile_id from doer record (training_progress uses profile_id)
    const { data: doer, error: doerError } = await supabase
      .from('doers')
      .select('profile_id')
      .eq('id', doerId)
      .single()

    if (doerError || !doer) {
      logger.error('Activation', 'Error fetching doer for training progress update:', doerError)
      return null
    }

    const { data, error } = await supabase
      .from('training_progress')
      .upsert({
        profile_id: doer.profile_id,
        module_id: moduleId,
        ...progress,
      })
      .select()
      .single()

    if (error) {
      logger.error('Activation', 'Error updating training progress:', error)
      return null
    }

    return data
  },

  /**
   * Mark training as completed
   * @security Verifies ownership before updating
   */
  async completeTraining(doerId: string): Promise<boolean> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    const { error } = await supabase
      .from('doer_activation')
      .update({
        training_completed: true,
        training_completed_at: new Date().toISOString(),
      })
      .eq('doer_id', doerId)

    if (error) {
      logger.error('Activation', 'Error completing training:', error)
      return false
    }

    return true
  },

  /**
   * Get quiz questions (excludes correct answers for security)
   */
  async getQuizQuestions(): Promise<Omit<QuizQuestion, 'correct_option_ids'>[]> {
    const supabase = createClient()

    // SECURITY: Only select non-sensitive columns
    // correct_option_ids is excluded to prevent answer leakage
    const { data, error } = await supabase
      .from('quiz_questions')
      .select('id, target_role, question_text, question_type, options, explanation, points, sequence_order, is_active, created_at, updated_at')
      .eq('is_active', true)
      .eq('target_role', 'doer')
      .order('sequence_order', { ascending: true })

    if (error) {
      logger.error('Activation', 'Error fetching quiz questions:', error)
      return []
    }

    return data || []
  },

  /**
   * Validate quiz answers server-side
   * @internal Used by submitQuizAttempt
   */
  async validateQuizAnswers(
    answers: Record<string, number>
  ): Promise<{ correctCount: number; totalQuestions: number }> {
    const supabase = createClient()

    // Fetch correct answers (server-side only)
    const { data: questions, error } = await supabase
      .from('quiz_questions')
      .select('id, correct_option_ids')
      .eq('is_active', true)
      .eq('target_role', 'doer')

    if (error || !questions) {
      logger.error('Activation', 'Error validating quiz answers:', error)
      return { correctCount: 0, totalQuestions: 0 }
    }

    let correctCount = 0
    for (const q of questions) {
      const userAnswer = answers[q.id]
      if (userAnswer !== undefined && q.correct_option_ids.includes(userAnswer)) {
        correctCount++
      }
    }

    return { correctCount, totalQuestions: questions.length }
  },

  /**
   * Get quiz attempts for a doer
   * @security Verifies ownership before returning data
   */
  async getQuizAttempts(doerId: string): Promise<QuizAttempt[]> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    // Get profile_id from doer record (quiz_attempts uses profile_id, not doer_id)
    const { data: doer, error: doerError } = await supabase
      .from('doers')
      .select('profile_id')
      .eq('id', doerId)
      .single()

    if (doerError || !doer) {
      logger.error('Activation', 'Error fetching doer for quiz attempts:', doerError)
      return []
    }

    const { data, error } = await supabase
      .from('quiz_attempts')
      .select('*')
      .eq('profile_id', doer.profile_id)
      .order('started_at', { ascending: false })

    if (error) {
      logger.error('Activation', 'Error fetching quiz attempts:', error)
      return []
    }

    return data || []
  },

  /**
   * Submit quiz attempt
   * SECURITY: Score is validated server-side, client values are ignored
   * @security Verifies ownership before submitting
   * @security Rate limited to 3 attempts per hour
   */
  async submitQuizAttempt(
    doerId: string,
    _score: number, // Ignored - calculated server-side
    _totalQuestions: number, // Ignored - calculated server-side
    answers: Record<string, number>
  ): Promise<{ attempt: QuizAttempt | null; passed: boolean; rateLimited?: boolean; retryAfterMinutes?: number }> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    // Get profile_id from doer record (quiz_attempts uses profile_id, not doer_id)
    const { data: doer, error: doerError } = await supabase
      .from('doers')
      .select('profile_id')
      .eq('id', doerId)
      .single()

    if (doerError || !doer) {
      logger.error('Activation', 'Error fetching doer for quiz attempt:', doerError)
      return { attempt: null, passed: false }
    }

    // SECURITY: Rate limiting - max 3 attempts per hour
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString()
    const { data: recentAttempts, error: rateError } = await supabase
      .from('quiz_attempts')
      .select('started_at')
      .eq('profile_id', doer.profile_id)
      .gte('started_at', oneHourAgo)
      .order('started_at', { ascending: false })

    if (!rateError && recentAttempts && recentAttempts.length >= 3) {
      // Calculate when user can try again (oldest attempt + 1 hour)
      const oldestAttempt = new Date(recentAttempts[recentAttempts.length - 1].started_at)
      const retryAfter = new Date(oldestAttempt.getTime() + 60 * 60 * 1000)
      const minutesRemaining = Math.ceil((retryAfter.getTime() - Date.now()) / (60 * 1000))

      logger.error('Activation', 'Quiz rate limit exceeded for profile:', doer.profile_id)
      return {
        attempt: null,
        passed: false,
        rateLimited: true,
        retryAfterMinutes: minutesRemaining > 0 ? minutesRemaining : 1,
      }
    }

    // SECURITY: Validate answers server-side (don't trust client score)
    const { correctCount, totalQuestions } = await this.validateQuizAnswers(answers)
    const scorePercentage = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0
    const isPassed = scorePercentage >= 80

    // Get the count of previous attempts to determine attempt_number
    const { count: previousAttempts, error: countError } = await supabase
      .from('quiz_attempts')
      .select('*', { count: 'exact', head: true })
      .eq('profile_id', doer.profile_id)

    if (countError) {
      logger.error('Activation', 'Error counting previous quiz attempts:', countError)
    }

    const attemptNumber = (previousAttempts || 0) + 1

    // Create quiz attempt record (uses profile_id, FK to profiles)
    // SECURITY: Using server-validated scores, not client-provided values
    const { data: attempt, error: attemptError } = await supabase
      .from('quiz_attempts')
      .insert({
        profile_id: doer.profile_id,
        target_role: 'doer',
        attempt_number: attemptNumber,
        score_percentage: scorePercentage,
        correct_answers: correctCount,
        total_questions: totalQuestions,
        passing_score: 80,
        is_passed: isPassed,
        answers,
        started_at: new Date().toISOString(),
        completed_at: new Date().toISOString(),
      })
      .select()
      .single()

    if (attemptError) {
      logger.error('Activation', 'Error submitting quiz attempt:', attemptError)
      return { attempt: null, passed: false }
    }

    // Update activation status if passed
    if (isPassed && attempt) {
      const { error: activationError } = await supabase
        .from('doer_activation')
        .update({
          quiz_passed: true,
          quiz_passed_at: new Date().toISOString(),
          quiz_attempt_id: attempt.id,
        })
        .eq('doer_id', doerId)

      if (activationError) {
        logger.error('Activation', 'Error updating activation status:', activationError)
      }
    }

    // Increment quiz attempts counter
    const { error: rpcError } = await supabase.rpc('increment_quiz_attempts', { doer_id_param: doerId })
    if (rpcError) {
      logger.error('Activation', 'Error incrementing quiz attempts:', rpcError)
    }

    return { attempt, passed: isPassed }
  },

  /**
   * Submit bank details
   * @security Verifies ownership before updating bank details
   */
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
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    // Update doer record with bank details
    const { error: doerError } = await supabase
      .from('doers')
      .update({
        bank_account_name: bankDetails.accountHolderName,
        bank_account_number: bankDetails.accountNumber,
        bank_ifsc_code: bankDetails.ifscCode,
        bank_name: bankDetails.bankName,
        upi_id: bankDetails.upiId,
      })
      .eq('id', doerId)

    if (doerError) {
      logger.error('Activation', 'Error updating bank details:', doerError)
      return false
    }

    // Update activation status
    const { error: activationError } = await supabase
      .from('doer_activation')
      .update({
        bank_details_added: true,
        bank_details_added_at: new Date().toISOString(),
        is_fully_activated: true,
        activated_at: new Date().toISOString(),
      })
      .eq('doer_id', doerId)

    if (activationError) {
      logger.error('Activation', 'Error completing activation:', activationError)
      return false
    }

    // Also update the doer is_activated flag
    await supabase
      .from('doers')
      .update({ is_activated: true })
      .eq('id', doerId)

    return true
  },

  /**
   * Check if doer is fully activated
   * @security Verifies ownership before returning data
   */
  async isFullyActivated(doerId: string): Promise<boolean> {
    // SECURITY: Verify the authenticated user owns this doer record
    await verifyDoerOwnership(doerId)

    const supabase = createClient()

    const { data, error } = await supabase
      .from('doer_activation')
      .select('is_fully_activated')
      .eq('doer_id', doerId)
      .single()

    if (error || !data) {
      return false
    }

    return data.is_fully_activated
  },
}
