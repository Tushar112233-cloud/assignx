/**
 * Project components utilities
 * Shared helper functions for project-related components
 * @module components/projects/utils
 */

/**
 * Time remaining result
 */
export interface TimeRemainingResult {
  /** Formatted time string */
  text: string
  /** Whether deadline is urgent */
  isUrgent: boolean
  /** Progress percentage (0-100) */
  percentage: number
  /** Days remaining */
  days: number
  /** Hours remaining */
  hours: number
  /** Minutes remaining */
  minutes: number
}

/**
 * Calculate time remaining until deadline
 * @param deadline - ISO date string for deadline
 * @returns Time remaining details
 */
export function getTimeRemaining(deadline: string): TimeRemainingResult {
  const now = new Date()
  const deadlineDate = new Date(deadline)
  const diff = deadlineDate.getTime() - now.getTime()

  if (diff <= 0) {
    return { text: 'Overdue', isUrgent: true, percentage: 100, days: 0, hours: 0, minutes: 0 }
  }

  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))

  let text: string
  if (days > 0) {
    text = `${days}d ${hours}h ${minutes}m`
  } else if (hours > 0) {
    text = `${hours}h ${minutes}m`
  } else {
    text = `${minutes}m`
  }

  const maxTime = 7 * 24 * 60 * 60 * 1000
  const percentage = Math.min(100, Math.max(0, ((maxTime - diff) / maxTime) * 100))

  return {
    text,
    isUrgent: hours < 6 && days === 0,
    percentage,
    days,
    hours,
    minutes,
  }
}

/**
 * Format file size for display
 * @param bytes - File size in bytes
 * @returns Formatted file size string
 */
export function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

/**
 * Format date for display
 * @param date - ISO date string
 * @returns Formatted date string
 */
export function formatDate(date: string): string {
  return new Date(date).toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

/**
 * Format time for display
 * @param date - ISO date string
 * @returns Formatted time string
 */
export function formatTime(date: string): string {
  return new Date(date).toLocaleTimeString('en-IN', {
    hour: '2-digit',
    minute: '2-digit',
  })
}

/**
 * Get status color class based on project status
 * @param status - Project status
 * @returns Tailwind color classes
 */
export function getStatusColor(status: string): string {
  switch (status) {
    case 'in_progress':
      return 'bg-blue-500/10 text-blue-600'
    case 'assigned':
      return 'bg-yellow-500/10 text-yellow-600'
    case 'revision_requested':
      return 'bg-red-500/10 text-red-600'
    case 'submitted':
      return 'bg-purple-500/10 text-purple-600'
    case 'qc_review':
      return 'bg-orange-500/10 text-orange-600'
    case 'completed':
      return 'bg-green-500/10 text-green-600'
    default:
      return 'bg-muted'
  }
}

/**
 * Get QC status badge color
 * @param status - QC status
 * @returns Tailwind color classes
 */
export function getQCStatusColor(status: string): string {
  switch (status) {
    case 'approved':
      return 'bg-green-500'
    case 'rejected':
      return 'bg-red-500'
    case 'pending':
      return 'bg-yellow-500'
    default:
      return 'bg-muted'
  }
}
