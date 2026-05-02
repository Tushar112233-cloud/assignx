/**
 * Resources and tools types
 * @module types/resources
 */

/**
 * Reference/citation style type
 * Academic citation formats
 */
export type ReferenceStyleType = 'APA' | 'Harvard' | 'MLA' | 'Chicago' | 'IEEE' | 'Vancouver'

/**
 * Template category type
 * Types of document templates
 */
export type TemplateCategory = 'document' | 'presentation' | 'spreadsheet'

/**
 * Reference style interface
 * Citation format definition
 */
export interface ReferenceStyle {
  /** Unique identifier */
  id: string
  /** Style name */
  name: ReferenceStyleType
  /** Style description */
  description: string | null
  /** Example citation */
  example: string | null
  /** Active status */
  is_active: boolean
}

/**
 * Format template interface
 * Downloadable document template
 */
export interface FormatTemplate {
  /** Unique identifier */
  id: string
  /** Template name */
  name: string
  /** Template description */
  description: string | null
  /** Template category */
  category: TemplateCategory
  /** Download URL */
  file_url: string
  /** Preview image URL */
  preview_url: string | null
  /** File MIME type */
  file_type: string
  /** File size in bytes */
  file_size: number
  /** Download count */
  download_count: number
  /** Active status */
  is_active: boolean
  /** Creation timestamp */
  created_at: string
}

/**
 * Citation interface
 * Saved citation reference
 */
export interface Citation {
  /** Unique identifier */
  id: string
  /** Owner doer ID */
  doer_id: string
  /** Source URL */
  url: string | null
  /** Citation style used */
  style: ReferenceStyleType
  /** Formatted citation text */
  formatted_citation: string
  /** Source type */
  source_type: 'website' | 'book' | 'journal' | 'article' | 'other'
  /** Source title */
  title: string | null
  /** Author name(s) */
  author: string | null
  /** Publication date */
  publication_date: string | null
  /** Access date */
  access_date: string | null
  /** Creation timestamp */
  created_at: string
}

/**
 * AI report interface
 * AI detection report
 */
export interface AIReport {
  /** Unique identifier */
  id: string
  /** Owner doer ID */
  doer_id: string
  /** Related project */
  project_id: string | null
  /** Input text analyzed */
  input_text: string | null
  /** Uploaded file URL */
  file_url: string | null
  /** AI content percentage */
  ai_percentage: number
  /** Original content percentage */
  originality_percentage: number
  /** Detailed analysis */
  detailed_breakdown: Record<string, unknown> | null
  /** Creation timestamp */
  created_at: string
}
