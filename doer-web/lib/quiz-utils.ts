/**
 * Quiz scoring utility functions
 * Used by QuizComponent and tests
 */

import type { QuizQuestion } from '@/types/database'

interface ScoreResult {
  correctCount: number
  totalQuestions: number
  percentage: number
}

/**
 * Calculate quiz score
 * @param questions - Array of quiz questions
 * @param answers - User's answers (question_id -> selected option id)
 * @returns Score details with correct count, total, and percentage
 */
export function calculateQuizScore(
  questions: QuizQuestion[],
  answers: Record<string, number>
): ScoreResult {
  let correctCount = 0

  questions.forEach((q) => {
    const userAnswer = answers[q.id]
    // Check if user's selected option ID is in the correct_option_ids array
    if (userAnswer !== undefined && q.correct_option_ids.includes(userAnswer)) {
      correctCount++
    }
  })

  const totalQuestions = questions.length
  const percentage = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0

  return {
    correctCount,
    totalQuestions,
    percentage,
  }
}

/**
 * Check if quiz is passed based on score percentage
 * @param percentage - Score percentage (0-100)
 * @param passingScore - Minimum passing score (default 80)
 * @returns Whether the quiz is passed
 */
export function isQuizPassed(percentage: number, passingScore = 80): boolean {
  return percentage >= passingScore
}

/**
 * Check if a single question is correctly answered
 * @param question - The quiz question
 * @param selectedOptionId - User's selected option ID
 * @returns Whether the answer is correct
 */
export function isAnswerCorrect(
  question: QuizQuestion,
  selectedOptionId: number | undefined
): boolean {
  if (selectedOptionId === undefined) return false
  return question.correct_option_ids.includes(selectedOptionId)
}

/**
 * Get the number of remaining quiz attempts
 * @param previousAttempts - Number of previous attempts
 * @param maxAttempts - Maximum allowed attempts (default 3)
 * @returns Number of remaining attempts
 */
export function getRemainingAttempts(previousAttempts: number, maxAttempts = 3): number {
  return Math.max(0, maxAttempts - previousAttempts)
}
