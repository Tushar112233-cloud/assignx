/**
 * Activation flow types for doer onboarding
 * @module types/activation
 */

/**
 * Training module content type
 * Supported formats for training materials
 */
export type TrainingModuleType = 'video' | 'pdf' | 'article' | 'html'

/**
 * Quiz question type
 * Types of questions in activation quiz
 */
export type QuizQuestionType = 'multiple_choice' | 'true_false' | 'scenario'

/**
 * Target role for training/quiz content
 */
export type TargetRole = 'doer' | 'supervisor'

/**
 * Training module interface
 * Individual training content item
 */
export interface TrainingModule {
  /** Unique identifier */
  id: string
  /** Module title */
  title: string
  /** Module description */
  description: string | null
  /** Target role for this module */
  target_role: TargetRole
  /** Content type */
  content_type: TrainingModuleType
  /** Content URL (video/pdf/article) */
  content_url: string | null
  /** HTML content for inline display */
  content_html: string | null
  /** Thumbnail image URL (optional) */
  thumbnail_url?: string | null
  /** Duration in minutes */
  duration_minutes: number | null
  /** Display order */
  sequence_order: number
  /** Whether completion is mandatory */
  is_mandatory: boolean
  /** Active status */
  is_active: boolean
  /** Creation timestamp */
  created_at: string
  /** Update timestamp */
  updated_at: string
}

/**
 * Training progress interface
 * Tracks user progress through training
 */
export interface TrainingProgress {
  /** Unique identifier */
  id: string
  /** Profile reference */
  profile_id: string
  /** Module reference */
  module_id: string
  /** Start timestamp */
  started_at: string
  /** Completion timestamp */
  completed_at: string | null
  /** Progress percentage (0-100) */
  progress_percentage: number
  /** Completion status */
  is_completed: boolean
}

/**
 * Quiz question option interface
 */
export interface QuizOption {
  id: number
  text: string
}

/**
 * Quiz question interface
 * Individual quiz question with options
 */
export interface QuizQuestion {
  /** Unique identifier */
  id: string
  /** Target role for this question */
  target_role: TargetRole
  /** Question text */
  question_text: string
  /** Question type */
  question_type: QuizQuestionType
  /** Answer options (JSONB object) */
  options: QuizOption[]
  /** IDs of correct answers (supports multiple correct) */
  correct_option_ids: number[]
  /** Explanation for answer */
  explanation: string | null
  /** Points for this question */
  points: number
  /** Display order */
  sequence_order: number | null
  /** Active status */
  is_active: boolean
  /** Creation timestamp */
  created_at: string
  /** Update timestamp */
  updated_at: string
}

/**
 * Quiz attempt interface
 * Record of a quiz attempt
 */
export interface QuizAttempt {
  /** Unique identifier */
  id: string
  /** Profile who attempted */
  profile_id: string
  /** Target role for this attempt */
  target_role: TargetRole
  /** Attempt number (1, 2, 3, etc.) */
  attempt_number: number
  /** Answers given (question_id -> option_ids) */
  answers: Record<string, number | number[]>
  /** Total questions count */
  total_questions: number
  /** Number of correct answers */
  correct_answers: number
  /** Score percentage (0-100) */
  score_percentage: number
  /** Passing score threshold */
  passing_score: number
  /** Whether passed threshold */
  is_passed: boolean
  /** Start timestamp */
  started_at: string
  /** Completion timestamp */
  completed_at: string | null
}

/**
 * Doer activation interface
 * Tracks complete activation status
 */
export interface DoerActivation {
  /** Unique identifier */
  id: string
  /** Doer reference */
  doer_id: string
  /** Training completion status */
  training_completed: boolean
  /** Training completion timestamp */
  training_completed_at: string | null
  /** Quiz pass status */
  quiz_passed: boolean
  /** Quiz pass timestamp */
  quiz_passed_at: string | null
  /** Reference to passing quiz attempt */
  quiz_attempt_id: string | null
  /** Number of quiz attempts */
  total_quiz_attempts: number
  /** Bank details submission status */
  bank_details_added: boolean
  /** Bank details submission timestamp */
  bank_details_added_at: string | null
  /** Full activation status */
  is_fully_activated: boolean
  /** Full activation timestamp */
  activated_at: string | null
  /** Creation timestamp */
  created_at: string
  /** Last update timestamp */
  updated_at: string
}

/**
 * @deprecated Use total_quiz_attempts instead
 * Alias for backwards compatibility
 */
export type DoerActivationWithLegacy = DoerActivation & {
  /** @deprecated Use total_quiz_attempts */
  quiz_attempts?: number
}
