'use client'

import { useState, useCallback, useMemo, useRef, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  CheckCircle2,
  ChevronRight,
  ChevronLeft,
  RotateCcw,
  AlertTriangle
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'
import { Label } from '@/components/ui/label'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { cn } from '@/lib/utils'
import { QUIZ_SETTINGS } from '@/lib/constants'
import type { QuizQuestion } from '@/types/database'

/** Quiz questions without correct answers (security - validated server-side) */
type SafeQuizQuestion = Omit<QuizQuestion, 'correct_option_ids'>

/** Quiz result data */
export interface QuizResult {
  score: number
  totalQuestions: number
  correctAnswers: number
  answers: Record<string, number>
  isPassed: boolean
}

interface QuizComponentProps {
  /** Quiz questions from database (without correct answers for security) */
  questions: SafeQuizQuestion[]
  /** Callback when quiz is passed with result data */
  onPass: (result: QuizResult) => void
  /** Callback when quiz is failed with result data */
  onFail: (result: QuizResult) => void
  /** Number of previous attempts */
  previousAttempts?: number
}

/**
 * Quiz component for activation
 * Presents MCQ questions and handles pass/fail logic
 */
export function QuizComponent({
  questions,
  onPass,
  onFail,
  previousAttempts = 0,
}: QuizComponentProps) {
  const [currentQuestion, setCurrentQuestion] = useState(0)
  const [answers, setAnswers] = useState<Record<string, number>>({})
  const [showResults, setShowResults] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  /** Ref for focus management when question changes */
  const questionHeadingRef = useRef<HTMLHeadingElement>(null)

  /** Focus management: Move focus to question when it changes */
  useEffect(() => {
    if (questionHeadingRef.current && !showResults) {
      // Small delay to allow animation to complete
      const timer = setTimeout(() => {
        questionHeadingRef.current?.focus()
      }, 100)
      return () => clearTimeout(timer)
    }
  }, [currentQuestion, showResults])

  /** Memoized computed values */
  const totalQuestions = questions.length
  const attemptsRemaining = useMemo(() =>
    QUIZ_SETTINGS.maxAttempts - previousAttempts - 1,
    [previousAttempts]
  )

  /** Current question data */
  const question = questions[currentQuestion]

  /** Progress percentage */
  const progressPercentage = useMemo(() =>
    totalQuestions > 0 ? ((currentQuestion + 1) / totalQuestions) * 100 : 0,
    [currentQuestion, totalQuestions]
  )

  // Show message if no questions
  if (questions.length === 0) {
    return (
      <div className="max-w-lg mx-auto text-center py-12">
        <AlertTriangle className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
        <h2 className="text-xl font-semibold mb-2">No Quiz Questions Available</h2>
        <p className="text-muted-foreground">
          Please contact support if this issue persists.
        </p>
      </div>
    )
  }

  /** Check if current question is answered */
  const isAnswered = useMemo(() =>
    answers[question.id] !== undefined,
    [answers, question.id]
  )

  /** Handle answer selection */
  const handleAnswer = useCallback((answerIndex: number) => {
    setAnswers(prev => ({
      ...prev,
      [question.id]: answerIndex,
    }))
  }, [question.id])

  /** Navigate to next question */
  const handleNext = useCallback(() => {
    if (currentQuestion < totalQuestions - 1) {
      setCurrentQuestion(prev => prev + 1)
    }
  }, [currentQuestion, totalQuestions])

  /** Navigate to previous question */
  const handlePrevious = useCallback(() => {
    if (currentQuestion > 0) {
      setCurrentQuestion(prev => prev - 1)
    }
  }, [currentQuestion])

  /** Submit quiz - score is validated server-side */
  const handleSubmit = useCallback(async () => {
    setIsSubmitting(true)
    // Note: Score is calculated and validated server-side for security
    // We show a neutral "submitted" state until parent provides actual results
    setShowResults(true)
    setIsSubmitting(false)
  }, [])

  /** Handle retry */
  const handleRetry = useCallback(() => {
    setCurrentQuestion(0)
    setAnswers({})
    setShowResults(false)
  }, [])

  /** Handle continue after results - submits to server for validation */
  const handleContinue = useCallback(() => {
    // Create result with answers - score is calculated server-side
    const result: QuizResult = {
      score: 0, // Will be calculated server-side
      totalQuestions,
      correctAnswers: 0, // Will be calculated server-side
      answers,
      isPassed: false, // Will be determined server-side
    }

    // Always call onPass - the server will determine actual pass/fail
    // Parent component handles server response and routing
    onPass(result)
  }, [totalQuestions, answers, onPass])

  /** Check if all questions are answered */
  const allAnswered = useMemo(() =>
    Object.keys(answers).length === totalQuestions,
    [answers, totalQuestions]
  )

  if (showResults) {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="max-w-lg mx-auto"
      >
        <Card className="border-2 border-primary">
          <CardHeader className="text-center">
            <div className="mx-auto mb-4 w-20 h-20 rounded-full flex items-center justify-center bg-primary/10">
              <CheckCircle2 className="w-10 h-10 text-primary" />
            </div>
            <CardTitle className="text-2xl">Quiz Completed!</CardTitle>
            <CardDescription className="text-base">
              You answered all {totalQuestions} questions. Click below to submit your answers for review.
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-6">
            {/* Summary */}
            <div className="bg-muted/50 rounded-lg p-4 space-y-2">
              <div className="flex justify-between text-sm">
                <span>Questions Answered</span>
                <span className="font-medium">{Object.keys(answers).length} / {totalQuestions}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>Passing Score Required</span>
                <span className="font-medium">{QUIZ_SETTINGS.passingScore}%</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>Attempts Used</span>
                <span className="font-medium">{previousAttempts + 1}</span>
              </div>
            </div>

            {/* Questions answered indicator */}
            <div className="space-y-3">
              <h4 className="font-medium text-sm">Questions Answered</h4>
              <div className="grid grid-cols-5 gap-2">
                {questions.map((q, index) => {
                  const isAnswered = answers[q.id] !== undefined

                  return (
                    <div
                      key={q.id}
                      className={cn(
                        'aspect-square rounded-lg flex items-center justify-center text-sm font-medium',
                        isAnswered
                          ? 'bg-primary/20 text-primary'
                          : 'bg-muted text-muted-foreground'
                      )}
                    >
                      {index + 1}
                    </div>
                  )
                })}
              </div>
            </div>
          </CardContent>

          <CardFooter className="flex-col gap-3">
            <Button onClick={handleContinue} className="w-full" size="lg">
              Submit Answers
              <ChevronRight className="w-4 h-4 ml-2" />
            </Button>
            <Button variant="outline" onClick={handleRetry} className="w-full">
              <RotateCcw className="w-4 h-4 mr-2" />
              Review Answers
            </Button>
          </CardFooter>
        </Card>
      </motion.div>
    )
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Header */}
      <div className="text-center space-y-2">
        <h1 className="text-2xl font-bold">Knowledge Quiz</h1>
        <p className="text-muted-foreground">
          Answer all questions to complete this step
        </p>
      </div>

      {/* Progress */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium">
              Question {currentQuestion + 1} of {totalQuestions}
            </span>
            <span className="text-sm text-muted-foreground">
              {Object.keys(answers).length} answered
            </span>
          </div>
          <Progress value={progressPercentage} className="h-2" />
        </CardContent>
      </Card>

      {/* Question card */}
      <AnimatePresence mode="wait">
        <motion.div
          key={currentQuestion}
          initial={{ opacity: 0, x: 50 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -50 }}
        >
          <Card>
            <CardHeader>
              <CardTitle
                ref={questionHeadingRef}
                tabIndex={-1}
                className="text-lg leading-relaxed focus:outline-none"
                aria-live="polite"
              >
                {question.question_text}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <RadioGroup
                value={answers[question.id]?.toString()}
                onValueChange={(value) => handleAnswer(parseInt(value))}
                className="space-y-3"
              >
                {question.options.map((option) => (
                  <div
                    key={option.id}
                    role="option"
                    tabIndex={0}
                    aria-selected={answers[question.id] === option.id}
                    className={cn(
                      'flex items-center space-x-3 p-4 rounded-lg border transition-colors cursor-pointer',
                      'focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2',
                      answers[question.id] === option.id
                        ? 'border-primary bg-primary/5'
                        : 'border-border hover:bg-muted/50'
                    )}
                    onClick={() => handleAnswer(option.id)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' || e.key === ' ') {
                        e.preventDefault()
                        handleAnswer(option.id)
                      }
                    }}
                  >
                    <RadioGroupItem value={option.id.toString()} id={`option-${option.id}`} />
                    <Label
                      htmlFor={`option-${option.id}`}
                      className="flex-1 cursor-pointer text-base"
                    >
                      {option.text}
                    </Label>
                  </div>
                ))}
              </RadioGroup>
            </CardContent>
            <CardFooter className="flex justify-between">
              <Button
                variant="outline"
                onClick={handlePrevious}
                disabled={currentQuestion === 0}
              >
                <ChevronLeft className="w-4 h-4 mr-2" />
                Previous
              </Button>

              {currentQuestion < totalQuestions - 1 ? (
                <Button
                  onClick={handleNext}
                  disabled={!isAnswered}
                >
                  Next
                  <ChevronRight className="w-4 h-4 ml-2" />
                </Button>
              ) : (
                <Button
                  onClick={handleSubmit}
                  disabled={!allAnswered || isSubmitting}
                  className="bg-green-600 hover:bg-green-700"
                >
                  {isSubmitting ? 'Submitting...' : 'Submit Quiz'}
                  <CheckCircle2 className="w-4 h-4 ml-2" />
                </Button>
              )}
            </CardFooter>
          </Card>
        </motion.div>
      </AnimatePresence>

      {/* Question navigation dots */}
      <nav className="flex justify-center gap-2 flex-wrap" aria-label="Question navigation">
        {questions.map((q, index) => {
          const isAnswered = answers[q.id] !== undefined
          const isCurrent = index === currentQuestion
          return (
            <button
              key={q.id}
              onClick={() => setCurrentQuestion(index)}
              aria-label={`Go to question ${index + 1}${isAnswered ? ' (answered)' : ''}${isCurrent ? ' (current)' : ''}`}
              aria-current={isCurrent ? 'step' : undefined}
              className={cn(
                'w-8 h-8 rounded-full text-sm font-medium transition-colors',
                'focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2',
                isCurrent && 'bg-primary text-primary-foreground',
                !isCurrent && isAnswered && 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300',
                !isCurrent && !isAnswered && 'bg-muted text-muted-foreground hover:bg-muted/80'
              )}
            >
              {index + 1}
            </button>
          )
        })}
      </nav>
    </div>
  )
}
