/**
 * Resources components shared constants and mock data
 * @module components/resources/constants
 */

import { Globe, BookOpen, FileText, Newspaper } from 'lucide-react'
import type { ReferenceStyleType, FormatTemplate, TemplateCategory } from '@/types/database'

/**
 * Reference style options for citation builder
 */
export const referenceStyles: { value: ReferenceStyleType; label: string; description: string }[] = [
  { value: 'APA', label: 'APA 7th Edition', description: 'American Psychological Association' },
  { value: 'Harvard', label: 'Harvard', description: 'Author-date system' },
  { value: 'MLA', label: 'MLA 9th Edition', description: 'Modern Language Association' },
  { value: 'Chicago', label: 'Chicago', description: 'Chicago Manual of Style' },
  { value: 'IEEE', label: 'IEEE', description: 'Institute of Electrical and Electronics Engineers' },
  { value: 'Vancouver', label: 'Vancouver', description: 'Medical and scientific papers' },
]

/**
 * Source type options for citation builder
 */
export const sourceTypes = [
  { value: 'website', label: 'Website', icon: Globe },
  { value: 'book', label: 'Book', icon: BookOpen },
  { value: 'journal', label: 'Journal Article', icon: FileText },
  { value: 'article', label: 'News Article', icon: Newspaper },
] as const

/**
 * Source type values
 */
export type SourceTypeValue = (typeof sourceTypes)[number]['value']

/**
 * Mock templates for FormatTemplates demo
 */
export const mockTemplates: FormatTemplate[] = [
  {
    id: '1',
    name: 'Research Paper Template',
    description: 'Standard academic research paper format with proper margins, headings, and citation placeholders.',
    category: 'document',
    file_url: '/templates/research-paper.docx',
    preview_url: '/templates/previews/research-paper.png',
    file_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    file_size: 45678,
    download_count: 1234,
    is_active: true,
    created_at: new Date().toISOString(),
  },
  {
    id: '2',
    name: 'Essay Template',
    description: 'Simple essay template with introduction, body paragraphs, and conclusion structure.',
    category: 'document',
    file_url: '/templates/essay.docx',
    preview_url: '/templates/previews/essay.png',
    file_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    file_size: 32456,
    download_count: 2567,
    is_active: true,
    created_at: new Date().toISOString(),
  },
  {
    id: '3',
    name: 'Business Report Template',
    description: 'Professional business report format with executive summary, charts, and recommendations.',
    category: 'document',
    file_url: '/templates/business-report.docx',
    preview_url: '/templates/previews/business-report.png',
    file_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    file_size: 67890,
    download_count: 987,
    is_active: true,
    created_at: new Date().toISOString(),
  },
  {
    id: '4',
    name: 'Academic Presentation',
    description: 'Clean academic presentation template with slide layouts for research presentations.',
    category: 'presentation',
    file_url: '/templates/academic-ppt.pptx',
    preview_url: '/templates/previews/academic-ppt.png',
    file_type: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    file_size: 234567,
    download_count: 567,
    is_active: true,
    created_at: new Date().toISOString(),
  },
  {
    id: '5',
    name: 'Business Pitch Deck',
    description: 'Modern pitch deck template for business proposals and startup presentations.',
    category: 'presentation',
    file_url: '/templates/pitch-deck.pptx',
    preview_url: '/templates/previews/pitch-deck.png',
    file_type: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    file_size: 345678,
    download_count: 432,
    is_active: true,
    created_at: new Date().toISOString(),
  },
  {
    id: '6',
    name: 'Data Analysis Template',
    description: 'Excel template with pre-built formulas for common statistical analysis.',
    category: 'spreadsheet',
    file_url: '/templates/data-analysis.xlsx',
    preview_url: '/templates/previews/data-analysis.png',
    file_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    file_size: 123456,
    download_count: 789,
    is_active: true,
    created_at: new Date().toISOString(),
  },
  {
    id: '7',
    name: 'Budget Tracker',
    description: 'Financial tracking template with income, expenses, and visualization charts.',
    category: 'spreadsheet',
    file_url: '/templates/budget-tracker.xlsx',
    preview_url: '/templates/previews/budget-tracker.png',
    file_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    file_size: 98765,
    download_count: 654,
    is_active: true,
    created_at: new Date().toISOString(),
  },
  {
    id: '8',
    name: 'Case Study Template',
    description: 'Structured case study format with problem, analysis, and recommendations sections.',
    category: 'document',
    file_url: '/templates/case-study.docx',
    preview_url: '/templates/previews/case-study.png',
    file_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    file_size: 54321,
    download_count: 876,
    is_active: true,
    created_at: new Date().toISOString(),
  },
]

/**
 * Category color mapping for templates
 */
export const categoryColors: Record<TemplateCategory, string> = {
  document: 'bg-blue-500/10 text-blue-600 border-blue-500/20',
  presentation: 'bg-orange-500/10 text-orange-600 border-orange-500/20',
  spreadsheet: 'bg-sky-500/10 text-sky-600 border-sky-500/20',
}

/**
 * Format file size for display
 * @param bytes - File size in bytes
 * @returns Formatted file size string
 */
export const formatFileSize = (bytes: number): string => {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

/**
 * Format duration for display
 * @param minutes - Duration in minutes
 * @returns Formatted duration string
 */
export const formatDuration = (minutes: number | null): string => {
  if (!minutes) return 'N/A'
  if (minutes < 60) return `${minutes} min`
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  return mins > 0 ? `${hours}h ${mins}m` : `${hours}h`
}

/**
 * Generate citation based on style
 * @param style - Reference style
 * @param data - Citation data
 * @returns Formatted citation string
 */
export const generateCitationByStyle = (
  style: ReferenceStyleType,
  data: {
    domain?: string
    url?: string
    date?: string
    title?: string
    author?: string
    year?: string
    publisher?: string
  }
): string => {
  const { domain = '', url = '', date = '', title = 'Title of page', author = 'Unknown Author', year = 'n.d.', publisher = '' } = data

  switch (style) {
    case 'APA':
      if (url) return `${domain}. (n.d.). ${title}. Retrieved ${date}, from ${url}`
      return `${author}. (${year}). ${title}${publisher ? `. ${publisher}` : ''}.`
    case 'Harvard':
      if (url) return `${domain} (n.d.) ${title}. Available at: ${url} (Accessed: ${date}).`
      return `${author} (${year}) ${title}${publisher ? `. ${publisher}` : ''}.`
    case 'MLA':
      if (url) return `"${title}." ${domain}, ${url}. Accessed ${date}.`
      return `${author}. "${title}."${publisher ? ` ${publisher},` : ''} ${year}.`
    case 'Chicago':
      if (url) return `${domain}. "${title}." Accessed ${date}. ${url}.`
      return `${author}. "${title}."${publisher ? ` ${publisher},` : ''} ${year}.`
    case 'IEEE':
      if (url) return `"${title}," ${domain}. [Online]. Available: ${url}. [Accessed: ${date}].`
      return `${author}, "${title},"${publisher ? ` ${publisher},` : ''} ${year}.`
    case 'Vancouver':
      if (url) return `${title} [Internet]. ${domain}; [cited ${date}]. Available from: ${url}`
      return `${author}. ${title}.${publisher ? ` ${publisher};` : ''} ${year}.`
    default:
      return `${domain || author}. ${url || title}. Accessed ${date || year}.`
  }
}

/**
 * AI report status color based on percentage
 * @param percentage - AI content percentage
 * @returns Tailwind color class
 */
export const getAIStatusColor = (percentage: number): string => {
  if (percentage <= 15) return 'text-[#4F6CF7]'
  if (percentage <= 30) return 'text-amber-600'
  return 'text-[#FF8B6A]'
}

/**
 * AI report status message based on percentage
 * @param percentage - AI content percentage
 * @returns Status message
 */
export const getAIStatusMessage = (percentage: number): string => {
  if (percentage <= 15) return 'Low AI content detected'
  if (percentage <= 30) return 'Moderate AI content detected'
  return 'High AI content detected'
}

/**
 * AI report badge color based on percentage
 * @param percentage - AI content percentage
 * @returns Badge color classes
 */
export const getAIBadgeColor = (percentage: number): string => {
  if (percentage <= 15) return 'bg-[#E3E9FF] text-[#4F6CF7] border-[#C7D2FE]'
  if (percentage <= 30) return 'bg-amber-500/10 text-amber-700 border-amber-500/30'
  return 'bg-[#FFE7E1] text-[#FF8B6A] border-[#FFD2C5]'
}

/**
 * AI report progress bar color based on percentage
 * @param percentage - AI content percentage
 * @returns Progress bar color class
 */
export const getAIProgressColor = (percentage: number): string => {
  if (percentage <= 15) return 'bg-[#5B7CFF]'
  if (percentage <= 30) return 'bg-amber-500'
  return 'bg-[#FF9B7A]'
}
