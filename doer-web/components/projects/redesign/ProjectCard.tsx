'use client'

import { motion } from 'framer-motion'
import {
  Clock,
  ExternalLink,
  MessageSquare,
  Flame,
  Calendar,
  User,
  BookOpen,
} from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'
import type { Project, ProjectStatus } from '@/types/database'

/**
 * Props for ProjectCard component
 */
interface ProjectCardProps {
  /** Project data */
  project: Project
  /** Callback when card is clicked */
  onProjectClick?: (projectId: string) => void
  /** Callback when open workspace is clicked */
  onOpenWorkspace?: (projectId: string) => void
  /** Callback when chat is clicked */
  onChatClick?: (projectId: string) => void
  /** Additional CSS classes */
  className?: string
}

/**
 * Status configuration for badge display
 */
interface StatusConfig {
  label: string
  color: string
  bgColor: string
  textColor: string
  pulseColor?: string
}

/**
 * Get status configuration for badge styling
 * @param status - Project status
 * @returns Status configuration object
 */
function getStatusConfig(status: ProjectStatus): StatusConfig {
  switch (status) {
    case 'assigned':
      return {
        label: 'Not Started',
        color: 'bg-amber-500',
        bgColor: 'bg-amber-500/10',
        textColor: 'text-amber-700',
        pulseColor: 'bg-amber-400',
      }
    case 'in_progress':
      return {
        label: 'In Progress',
        color: 'bg-sky-500',
        bgColor: 'bg-sky-500/10',
        textColor: 'text-sky-700',
        pulseColor: 'bg-sky-400',
      }
    case 'revision_requested':
      return {
        label: 'Revision Needed',
        color: 'bg-rose-500',
        bgColor: 'bg-rose-500/10',
        textColor: 'text-rose-700',
        pulseColor: 'bg-rose-400',
      }
    case 'in_revision':
      return {
        label: 'In Revision',
        color: 'bg-violet-500',
        bgColor: 'bg-violet-500/10',
        textColor: 'text-violet-700',
        pulseColor: 'bg-violet-400',
      }
    case 'submitted_for_qc':
      return {
        label: 'Under Review',
        color: 'bg-indigo-500',
        bgColor: 'bg-indigo-500/10',
        textColor: 'text-indigo-700',
        pulseColor: 'bg-indigo-400',
      }
    case 'delivered':
      return {
        label: 'Delivered',
        color: 'bg-emerald-500',
        bgColor: 'bg-emerald-500/10',
        textColor: 'text-emerald-700',
      }
    case 'completed':
      return {
        label: 'Completed',
        color: 'bg-green-500',
        bgColor: 'bg-green-500/10',
        textColor: 'text-green-700',
      }
    default:
      return {
        label: status,
        color: 'bg-slate-500',
        bgColor: 'bg-slate-500/10',
        textColor: 'text-slate-700',
      }
  }
}

/**
 * Calculate time remaining until deadline
 * @param deadline - Deadline date string
 * @returns Time information object
 */
function getTimeRemaining(deadline: string) {
  const now = new Date()
  const deadlineDate = new Date(deadline)
  const diffMs = deadlineDate.getTime() - now.getTime()
  const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24))

  let text = ''
  let isUrgent = false
  let color = 'text-slate-600'
  let bgColor = 'bg-slate-100'

  if (diffDays < 0) {
    text = `${Math.abs(diffDays)} days overdue`
    isUrgent = true
    color = 'text-rose-700'
    bgColor = 'bg-rose-100'
  } else if (diffDays === 0) {
    text = 'Due today'
    isUrgent = true
    color = 'text-rose-700'
    bgColor = 'bg-rose-100'
  } else if (diffDays === 1) {
    text = 'Due tomorrow'
    isUrgent = true
    color = 'text-amber-700'
    bgColor = 'bg-amber-100'
  } else if (diffDays <= 3) {
    text = `Due in ${diffDays} days`
    isUrgent = true
    color = 'text-amber-700'
    bgColor = 'bg-amber-100'
  } else if (diffDays <= 7) {
    text = `Due in ${diffDays} days`
    color = 'text-slate-700'
    bgColor = 'bg-slate-100'
  } else {
    text = `Due in ${diffDays} days`
    color = 'text-slate-600'
    bgColor = 'bg-slate-100'
  }

  // Calculate progress percentage (inverse - closer to deadline = higher percentage)
  const totalDays = 14 // Assume 2 weeks is typical project timeline
  const percentage = Math.min(100, Math.max(0, ((totalDays - diffDays) / totalDays) * 100))

  return { text, isUrgent, color, bgColor, percentage, days: diffDays }
}

/**
 * ProjectCard Component
 *
 * A modern, interactive project card with:
 * - Hover lift effect with smooth transition
 * - Status badge with optional pulse animation
 * - Gradient progress bar
 * - Action buttons appearing on hover
 * - Prominent earnings display
 * - Deadline countdown with color coding
 * - Responsive design for all screen sizes
 *
 * @example
 * ```tsx
 * <ProjectCard
 *   project={projectData}
 *   onProjectClick={(id) => router.push(`/projects/${id}`)}
 *   onOpenWorkspace={(id) => window.open(`/workspace/${id}`)}
 *   onChatClick={(id) => setActiveChatId(id)}
 * />
 * ```
 */
export function ProjectCard({
  project,
  onProjectClick,
  onOpenWorkspace,
  onChatClick,
  className,
}: ProjectCardProps) {
  const statusConfig = getStatusConfig(project.status)
  const timeInfo = getTimeRemaining(project.deadline)
  const isUrgent = timeInfo.isUrgent || project.is_urgent
  const payout = project.price ?? project.doer_payout ?? 0

  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.98 }}
      whileHover={{ y: -4 }}
      transition={{ duration: 0.2 }}
      className={cn(
        'group relative overflow-hidden rounded-2xl border border-border/70 bg-white/80 backdrop-blur-sm',
        'shadow-[0_12px_30px_rgba(148,163,184,0.12)] transition-all',
        'hover:shadow-[0_24px_60px_rgba(30,58,138,0.12)] hover:border-[#B8C4FF]/50',
        project.status === 'revision_requested' && 'border-rose-300 bg-rose-50/40',
        isUrgent && project.status !== 'revision_requested' && 'border-amber-300/60',
        className
      )}
      onClick={() => onProjectClick?.(project.id)}
      role="button"
      tabIndex={0}
      onKeyDown={(event) => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault()
          onProjectClick?.(project.id)
        }
      }}
    >
      {/* Gradient overlay on hover */}
      <div className="pointer-events-none absolute inset-0 opacity-0 transition-opacity group-hover:opacity-100">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(91,124,255,0.06),transparent_50%)]" />
      </div>

      {/* Card content */}
      <div className="relative p-5 space-y-4">
        {/* Header: Icon, Status, and Payout */}
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3 flex-1 min-w-0">
            {/* Project icon */}
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(91,124,255,0.25)]">
              <BookOpen className="h-5 w-5" />
            </div>

            {/* Status badge with pulse animation */}
            <div className="flex items-center gap-2">
              <Badge
                variant="outline"
                className={cn(
                  'relative rounded-full px-2.5 py-1 text-xs font-semibold border-0',
                  statusConfig.bgColor,
                  statusConfig.textColor
                )}
              >
                {/* Pulse animation for active states */}
                {statusConfig.pulseColor && (
                  <span className="absolute -left-1 -top-1 flex h-3 w-3">
                    <span
                      className={cn(
                        'absolute inline-flex h-full w-full animate-ping rounded-full opacity-75',
                        statusConfig.pulseColor
                      )}
                    />
                    <span
                      className={cn(
                        'relative inline-flex h-3 w-3 rounded-full',
                        statusConfig.color
                      )}
                    />
                  </span>
                )}
                <span className="ml-2">{statusConfig.label}</span>
              </Badge>

              {/* Urgent indicator */}
              {isUrgent && (
                <Badge
                  variant="secondary"
                  className="rounded-full px-2 py-0.5 text-xs font-semibold bg-rose-500/10 text-rose-700 border-0"
                >
                  <Flame className="h-3 w-3 mr-1" />
                  Urgent
                </Badge>
              )}
            </div>
          </div>

          {/* Payout */}
          <div className="text-right shrink-0">
            <p className="text-xs font-medium text-slate-500 uppercase tracking-wide">
              Payout
            </p>
            <p className="text-xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
              ₹{payout.toLocaleString('en-IN')}
            </p>
          </div>
        </div>

        {/* Project title */}
        <div className="space-y-2">
          <h3 className="text-base font-semibold text-slate-900 line-clamp-2 leading-snug">
            {project.title}
          </h3>

          {/* Project metadata */}
          <div className="flex flex-wrap items-center gap-2 text-xs text-slate-500">
            {project.subject_name && (
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#EEF2FF]">
                <BookOpen className="h-3 w-3 text-[#4F6CF7]" />
                <span className="font-medium text-slate-700">{project.subject_name}</span>
              </div>
            )}
            {project.supervisor_name && (
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-slate-50">
                <User className="h-3 w-3 text-slate-500" />
                <span>{project.supervisor_name}</span>
              </div>
            )}
          </div>
        </div>

        {/* Progress bar with gradient */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-xs">
            <span className="font-medium text-slate-600">Progress</span>
            <span className="font-semibold text-slate-700">
              {Math.round(project.progress_percentage || 0)}%
            </span>
          </div>
          <div className="relative h-2 w-full overflow-hidden rounded-full bg-slate-100">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${project.progress_percentage || 0}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
              className={cn(
                'h-full rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF]',
                isUrgent && 'from-rose-500 via-rose-400 to-rose-500',
                project.status === 'completed' && 'from-emerald-500 via-emerald-400 to-teal-500'
              )}
            />
          </div>
        </div>

        {/* Footer: Deadline and Actions */}
        <div className="flex items-center justify-between gap-3 pt-2">
          {/* Deadline */}
          <div
            className={cn(
              'flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium',
              timeInfo.bgColor,
              timeInfo.color
            )}
          >
            <Calendar className="h-3.5 w-3.5" />
            <span>{timeInfo.text}</span>
          </div>

          {/* Action buttons - appear on hover */}
          <div className="flex items-center gap-2 opacity-0 transition-opacity group-hover:opacity-100">
            {onChatClick && (
              <Button
                size="sm"
                variant="ghost"
                className="h-8 w-8 rounded-full p-0 hover:bg-[#E3E9FF] hover:text-[#4F6CF7]"
                onClick={(event) => {
                  event.stopPropagation()
                  onChatClick(project.id)
                }}
                aria-label="Open chat"
              >
                <MessageSquare className="h-4 w-4" />
              </Button>
            )}
            {onOpenWorkspace && (
              <Button
                size="sm"
                className={cn(
                  'h-8 gap-1.5 rounded-full px-3 text-xs font-semibold shadow-[0_8px_20px_rgba(91,124,255,0.25)]',
                  project.status === 'revision_requested'
                    ? 'bg-rose-600 hover:bg-rose-700'
                    : 'bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] hover:shadow-[0_12px_28px_rgba(91,124,255,0.35)]'
                )}
                onClick={(event) => {
                  event.stopPropagation()
                  onOpenWorkspace(project.id)
                }}
              >
                <ExternalLink className="h-3.5 w-3.5" />
                {project.status === 'revision_requested' ? 'Review' : 'Open'}
              </Button>
            )}
          </div>
        </div>
      </div>
    </motion.div>
  )
}
