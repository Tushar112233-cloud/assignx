/**
 * Resources components shared constants
 * @module components/resources/constants
 */

import { Globe, BookOpen, FileText, Newspaper } from 'lucide-react'
import type { ReferenceStyleType, TemplateCategory } from '@/types/database'

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
