/**
 * Database types barrel export
 * Re-exports all domain types and defines Database schema
 * @module types/database
 */

// Common types
export type {
  Json,
  UserRole,
  Qualification,
  ExperienceLevel,
  ActivationStatus,
} from './common.types'

// Profile types
export type {
  Profile,
  Doer,
  Skill,
  DoerSkill,
  Subject,
  DoerSubject,
  University,
  DoerStats,
  SkillWithVerification,
  DoerReview,
} from './profile.types'

// Activation types
export type {
  TrainingModuleType,
  QuizQuestionType,
  TrainingModule,
  TrainingProgress,
  QuizQuestion,
  QuizAttempt,
  DoerActivation,
} from './activation.types'

// Project types
export type {
  ProjectStatus,
  QCStatus,
  Project,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
} from './project.types'

// Chat types
export type {
  ChatRoomType,
  MessageType,
  NotificationType,
  ChatRoom,
  ChatMessage,
  ChatParticipant,
  Notification,
} from './chat.types'

// Finance types
export type {
  TransactionType,
  PayoutStatus,
  Wallet,
  WalletTransaction,
  Payout,
  PayoutRequest,
  EarningsData,
} from './finance.types'

// Support types
export type {
  TicketStatus,
  TicketPriority,
  SupportTicket,
  TicketMessage,
  FAQ,
} from './support.types'

// Resources types
export type {
  ReferenceStyleType,
  TemplateCategory,
  ReferenceStyle,
  FormatTemplate,
  Citation,
  AIReport,
} from './resources.types'

// Import types for Database schema
import type { Profile, Doer, Skill, DoerSkill, Subject, DoerSubject, University } from './profile.types'
import type { TrainingModule, TrainingProgress, QuizQuestion, QuizAttempt, DoerActivation } from './activation.types'
import type { Project, ProjectFile, ProjectDeliverable, ProjectRevision } from './project.types'
import type { ChatRoom, ChatMessage, ChatParticipant, Notification } from './chat.types'
import type { UserRole, Qualification, ExperienceLevel, ActivationStatus } from './common.types'
import type { TrainingModuleType, QuizQuestionType } from './activation.types'
import type { ProjectStatus, QCStatus } from './project.types'
import type { ChatRoomType, MessageType, NotificationType } from './chat.types'

/**
 * Database schema type for Supabase
 * Defines table structures for type-safe queries
 */
export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: Profile
        Insert: Omit<Profile, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<Profile, 'id'>>
      }
      doers: {
        Row: Doer
        Insert: Omit<Doer, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<Doer, 'id'>>
      }
      skills: {
        Row: Skill
        Insert: Omit<Skill, 'id'>
        Update: Partial<Omit<Skill, 'id'>>
      }
      doer_skills: {
        Row: DoerSkill
        Insert: Omit<DoerSkill, 'id'>
        Update: Partial<Omit<DoerSkill, 'id'>>
      }
      subjects: {
        Row: Subject
        Insert: Omit<Subject, 'id'>
        Update: Partial<Omit<Subject, 'id'>>
      }
      doer_subjects: {
        Row: DoerSubject
        Insert: Omit<DoerSubject, 'id'>
        Update: Partial<Omit<DoerSubject, 'id'>>
      }
      universities: {
        Row: University
        Insert: Omit<University, 'id'>
        Update: Partial<Omit<University, 'id'>>
      }
      training_modules: {
        Row: TrainingModule
        Insert: Omit<TrainingModule, 'id' | 'created_at'>
        Update: Partial<Omit<TrainingModule, 'id'>>
      }
      training_progress: {
        Row: TrainingProgress
        Insert: Omit<TrainingProgress, 'id'>
        Update: Partial<Omit<TrainingProgress, 'id'>>
      }
      quiz_questions: {
        Row: QuizQuestion
        Insert: Omit<QuizQuestion, 'id'>
        Update: Partial<Omit<QuizQuestion, 'id'>>
      }
      quiz_attempts: {
        Row: QuizAttempt
        Insert: Omit<QuizAttempt, 'id'>
        Update: Partial<Omit<QuizAttempt, 'id'>>
      }
      doer_activation: {
        Row: DoerActivation
        Insert: Omit<DoerActivation, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<DoerActivation, 'id'>>
      }
      projects: {
        Row: Project
        Insert: Omit<Project, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<Project, 'id'>>
      }
      project_files: {
        Row: ProjectFile
        Insert: Omit<ProjectFile, 'id' | 'created_at'>
        Update: Partial<Omit<ProjectFile, 'id'>>
      }
      project_deliverables: {
        Row: ProjectDeliverable
        Insert: Omit<ProjectDeliverable, 'id' | 'submitted_at'>
        Update: Partial<Omit<ProjectDeliverable, 'id'>>
      }
      project_revisions: {
        Row: ProjectRevision
        Insert: Omit<ProjectRevision, 'id' | 'created_at'>
        Update: Partial<Omit<ProjectRevision, 'id'>>
      }
      chat_rooms: {
        Row: ChatRoom
        Insert: Omit<ChatRoom, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<ChatRoom, 'id'>>
      }
      chat_messages: {
        Row: ChatMessage
        Insert: Omit<ChatMessage, 'id' | 'created_at'>
        Update: Partial<Omit<ChatMessage, 'id'>>
      }
      chat_participants: {
        Row: ChatParticipant
        Insert: Omit<ChatParticipant, 'id' | 'joined_at'>
        Update: Partial<Omit<ChatParticipant, 'id'>>
      }
      notifications: {
        Row: Notification
        Insert: Omit<Notification, 'id' | 'created_at'>
        Update: Partial<Omit<Notification, 'id'>>
      }
    }
    Enums: {
      user_role: UserRole
      qualification: Qualification
      experience_level: ExperienceLevel
      activation_status: ActivationStatus
      training_module_type: TrainingModuleType
      quiz_question_type: QuizQuestionType
      project_status: ProjectStatus
      chat_room_type: ChatRoomType
      message_type: MessageType
      notification_type: NotificationType
      qc_status: QCStatus
    }
  }
}
