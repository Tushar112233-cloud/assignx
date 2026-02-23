import { describe, it, expect } from 'vitest'

/**
 * Quiz scoring utility functions
 * Extracted for testability
 */

interface QuizOption {
  id: number
  text: string
}

interface QuizQuestion {
  id: string
  question_text: string
  options: QuizOption[]
  correct_option_ids: number[]
}

/**
 * Calculate quiz score
 * @param questions - Array of quiz questions
 * @param answers - User's answers (question_id -> selected option id)
 * @returns Score details
 */
export function calculateQuizScore(
  questions: QuizQuestion[],
  answers: Record<string, number>
): {
  correctCount: number
  totalQuestions: number
  percentage: number
} {
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
 * Check if quiz is passed
 * @param percentage - Score percentage
 * @param passingScore - Minimum passing score (default 80)
 * @returns Whether the quiz is passed
 */
export function isQuizPassed(percentage: number, passingScore = 80): boolean {
  return percentage >= passingScore
}

/**
 * Check if a single question is correctly answered
 * @param question - The question
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

// Tests
describe('Quiz Scoring', () => {
  const mockQuestions: QuizQuestion[] = [
    {
      id: 'q1',
      question_text: 'What is 2 + 2?',
      options: [
        { id: 1, text: '3' },
        { id: 2, text: '4' },
        { id: 3, text: '5' },
      ],
      correct_option_ids: [2],
    },
    {
      id: 'q2',
      question_text: 'What color is the sky?',
      options: [
        { id: 1, text: 'Red' },
        { id: 2, text: 'Blue' },
        { id: 3, text: 'Green' },
      ],
      correct_option_ids: [2],
    },
    {
      id: 'q3',
      question_text: 'Is water wet?',
      options: [
        { id: 1, text: 'Yes' },
        { id: 2, text: 'No' },
      ],
      correct_option_ids: [1],
    },
    {
      id: 'q4',
      question_text: 'What is the capital of France?',
      options: [
        { id: 1, text: 'London' },
        { id: 2, text: 'Paris' },
        { id: 3, text: 'Berlin' },
      ],
      correct_option_ids: [2],
    },
    {
      id: 'q5',
      question_text: 'What year did World War II end?',
      options: [
        { id: 1, text: '1944' },
        { id: 2, text: '1945' },
        { id: 3, text: '1946' },
      ],
      correct_option_ids: [2],
    },
  ]

  describe('calculateQuizScore', () => {
    it('should calculate 100% for all correct answers', () => {
      const answers: Record<string, number> = {
        q1: 2,
        q2: 2,
        q3: 1,
        q4: 2,
        q5: 2,
      }

      const result = calculateQuizScore(mockQuestions, answers)

      expect(result.correctCount).toBe(5)
      expect(result.totalQuestions).toBe(5)
      expect(result.percentage).toBe(100)
    })

    it('should calculate 0% for all wrong answers', () => {
      const answers: Record<string, number> = {
        q1: 1, // wrong (correct is 2)
        q2: 1, // wrong (correct is 2)
        q3: 2, // wrong (correct is 1)
        q4: 1, // wrong (correct is 2)
        q5: 1, // wrong (correct is 2)
      }

      const result = calculateQuizScore(mockQuestions, answers)

      expect(result.correctCount).toBe(0)
      expect(result.totalQuestions).toBe(5)
      expect(result.percentage).toBe(0)
    })

    it('should calculate 60% for 3 out of 5 correct', () => {
      const answers: Record<string, number> = {
        q1: 2, // correct
        q2: 2, // correct
        q3: 1, // correct
        q4: 1, // wrong
        q5: 1, // wrong
      }

      const result = calculateQuizScore(mockQuestions, answers)

      expect(result.correctCount).toBe(3)
      expect(result.totalQuestions).toBe(5)
      expect(result.percentage).toBe(60)
    })

    it('should handle empty answers', () => {
      const answers: Record<string, number> = {}

      const result = calculateQuizScore(mockQuestions, answers)

      expect(result.correctCount).toBe(0)
      expect(result.totalQuestions).toBe(5)
      expect(result.percentage).toBe(0)
    })

    it('should handle partial answers', () => {
      const answers: Record<string, number> = {
        q1: 2, // correct
        q2: 2, // correct
        // q3, q4, q5 not answered
      }

      const result = calculateQuizScore(mockQuestions, answers)

      expect(result.correctCount).toBe(2)
      expect(result.totalQuestions).toBe(5)
      expect(result.percentage).toBe(40)
    })

    it('should handle empty questions array', () => {
      const result = calculateQuizScore([], { q1: 2 })

      expect(result.correctCount).toBe(0)
      expect(result.totalQuestions).toBe(0)
      expect(result.percentage).toBe(0)
    })
  })

  describe('isQuizPassed', () => {
    it('should return true for 80% or higher', () => {
      expect(isQuizPassed(80)).toBe(true)
      expect(isQuizPassed(85)).toBe(true)
      expect(isQuizPassed(100)).toBe(true)
    })

    it('should return false for below 80%', () => {
      expect(isQuizPassed(79)).toBe(false)
      expect(isQuizPassed(50)).toBe(false)
      expect(isQuizPassed(0)).toBe(false)
    })

    it('should respect custom passing score', () => {
      expect(isQuizPassed(70, 70)).toBe(true)
      expect(isQuizPassed(69, 70)).toBe(false)
      expect(isQuizPassed(90, 90)).toBe(true)
    })
  })

  describe('isAnswerCorrect', () => {
    const question: QuizQuestion = {
      id: 'test',
      question_text: 'Test question',
      options: [
        { id: 1, text: 'Option 1' },
        { id: 2, text: 'Option 2' },
      ],
      correct_option_ids: [2],
    }

    it('should return true for correct answer', () => {
      expect(isAnswerCorrect(question, 2)).toBe(true)
    })

    it('should return false for wrong answer', () => {
      expect(isAnswerCorrect(question, 1)).toBe(false)
    })

    it('should return false for undefined answer', () => {
      expect(isAnswerCorrect(question, undefined)).toBe(false)
    })
  })

  describe('Multiple correct answers support', () => {
    const multiAnswerQuestion: QuizQuestion = {
      id: 'multi',
      question_text: 'Which are primary colors?',
      options: [
        { id: 1, text: 'Red' },
        { id: 2, text: 'Blue' },
        { id: 3, text: 'Yellow' },
        { id: 4, text: 'Green' },
      ],
      correct_option_ids: [1, 2, 3], // Multiple correct answers
    }

    it('should accept any of the correct options', () => {
      expect(isAnswerCorrect(multiAnswerQuestion, 1)).toBe(true)
      expect(isAnswerCorrect(multiAnswerQuestion, 2)).toBe(true)
      expect(isAnswerCorrect(multiAnswerQuestion, 3)).toBe(true)
    })

    it('should reject incorrect option', () => {
      expect(isAnswerCorrect(multiAnswerQuestion, 4)).toBe(false)
    })
  })
})
