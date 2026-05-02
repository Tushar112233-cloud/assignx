/**
 * @fileoverview Type definitions for the resources module.
 * @module components/resources/types
 */

export type ResourceCategory =
  | "quality_tools"
  | "pricing"
  | "training"
  | "documentation"

export interface ResourceTool {
  id: string
  name: string
  description: string
  category: ResourceCategory
  icon: string
  href?: string
  isExternal?: boolean
  isPremium?: boolean
  usageCount?: number
}

// Plagiarism Check Types
export interface PlagiarismCheckResult {
  id: string
  file_name: string
  overall_score: number
  unique_content: number
  matched_content: number
  sources_found: number
  checked_at: string
  matches: PlagiarismMatch[]
  status: "pending" | "processing" | "completed" | "failed"
}

export interface PlagiarismMatch {
  id: string
  source_url: string
  source_title: string
  matched_text: string
  similarity_percentage: number
  word_count: number
}

// AI Detection Types
export interface AIDetectionResult {
  id: string
  file_name: string
  ai_probability: number
  human_probability: number
  mixed_probability: number
  overall_verdict: "human" | "ai_generated" | "mixed" | "uncertain"
  confidence_level: "high" | "medium" | "low"
  checked_at: string
  segments: AISegment[]
  status: "pending" | "processing" | "completed" | "failed"
}

export interface AISegment {
  id: string
  text: string
  start_index: number
  end_index: number
  classification: "human" | "ai_generated" | "mixed"
  probability: number
}

// Pricing Guide Types
export interface PricingTier {
  id: string
  name: string
  description: string
  base_price_per_page: number
  base_price_per_word: number
  min_pages?: number
  max_pages?: number
}

export interface UrgencyMultiplier {
  id: string
  name: string
  hours: number
  multiplier: number
  description: string
}

export interface ComplexityMultiplier {
  id: string
  name: string
  multiplier: number
  description: string
  examples: string[]
}

export interface PricingGuide {
  tiers: PricingTier[]
  urgency_multipliers: UrgencyMultiplier[]
  complexity_multipliers: ComplexityMultiplier[]
  supervisor_commission_percentage: number
  platform_fee_percentage: number
  doer_base_percentage: number
}

// Training Types
export interface TrainingVideo {
  id: string
  title: string
  description: string
  duration: string
  thumbnail_url?: string
  video_url: string
  category: TrainingCategory
  difficulty: "beginner" | "intermediate" | "advanced"
  is_required: boolean
  is_completed?: boolean
  completed_at?: string
  order: number
}

export type TrainingCategory =
  | "onboarding"
  | "qc_process"
  | "communication"
  | "tools"
  | "advanced"

export interface TrainingProgress {
  total_videos: number
  completed_videos: number
  required_videos: number
  required_completed: number
  completion_percentage: number
  last_watched_at?: string
}

// Constants
export const RESOURCE_CATEGORIES: Record<
  ResourceCategory,
  { label: string; description: string }
> = {
  quality_tools: {
    label: "Quality Tools",
    description: "Tools for checking plagiarism, AI content, and quality",
  },
  pricing: {
    label: "Pricing",
    description: "Guides and calculators for project pricing",
  },
  training: {
    label: "Training",
    description: "Videos and materials for skill development",
  },
  documentation: {
    label: "Documentation",
    description: "Reference materials and guidelines",
  },
}

export const TRAINING_CATEGORIES: Record<
  TrainingCategory,
  { label: string; description: string }
> = {
  onboarding: {
    label: "Getting Started",
    description: "Essential videos for new supervisors",
  },
  qc_process: {
    label: "QC Process",
    description: "How to review and approve submissions",
  },
  communication: {
    label: "Communication",
    description: "Client and expert communication best practices",
  },
  tools: {
    label: "Using Tools",
    description: "How to use platform tools effectively",
  },
  advanced: {
    label: "Advanced Topics",
    description: "Deep dives into specialized topics",
  },
}

export const AI_VERDICT_CONFIG: Record<
  AIDetectionResult["overall_verdict"],
  { label: string; color: string; bgColor: string; description: string }
> = {
  human: {
    label: "Human Written",
    color: "text-green-700",
    bgColor: "bg-green-100",
    description: "Content appears to be written by a human",
  },
  ai_generated: {
    label: "AI Generated",
    color: "text-red-700",
    bgColor: "bg-red-100",
    description: "Content appears to be AI-generated",
  },
  mixed: {
    label: "Mixed Content",
    color: "text-amber-700",
    bgColor: "bg-amber-100",
    description: "Content contains both human and AI-generated text",
  },
  uncertain: {
    label: "Uncertain",
    color: "text-gray-700",
    bgColor: "bg-gray-100",
    description: "Unable to determine with confidence",
  },
}
