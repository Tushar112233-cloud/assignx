'use client'

import { motion } from 'framer-motion'
import { Calendar, Clock, CheckCircle2, Circle, AlertCircle } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import type { Project, ProjectStatus } from '@/types/database'

/**
 * Props for TimelineView component
 */
interface TimelineViewProps {
  /** List of projects to display in timeline */
  projects: Project[]
  /** Callback when project node is clicked */
  onProjectClick?: (projectId: string) => void
  /** Additional CSS classes */
  className?: string
}

/**
 * Props for individual timeline node
 */
interface TimelineNodeProps {
  /** Project data */
  project: Project
  /** Position index in timeline */
  index: number
  /** Total number of projects */
  total: number
  /** Click handler */
  onClick?: (projectId: string) => void
}

/**
 * Timeline node status configuration
 */
interface TimelineNodeConfig {
  icon: React.ElementType
  iconColor: string
  iconBg: string
  lineColor: string
  pulseColor?: string
}

/**
 * Get timeline node configuration based on status
 * @param status - Project status
 * @returns Node configuration
 */
function getNodeConfig(status: ProjectStatus): TimelineNodeConfig {
  switch (status) {
    case 'completed':
    case 'delivered':
      return {
        icon: CheckCircle2,
        iconColor: 'text-emerald-600',
        iconBg: 'bg-emerald-100',
        lineColor: 'bg-emerald-300',
      }
    case 'in_progress':
    case 'in_revision':
      return {
        icon: Circle,
        iconColor: 'text-sky-600',
        iconBg: 'bg-sky-100',
        lineColor: 'bg-sky-300',
        pulseColor: 'bg-sky-400',
      }
    case 'revision_requested':
      return {
        icon: AlertCircle,
        iconColor: 'text-rose-600',
        iconBg: 'bg-rose-100',
        lineColor: 'bg-rose-300',
        pulseColor: 'bg-rose-400',
      }
    case 'assigned':
      return {
        icon: Clock,
        iconColor: 'text-amber-600',
        iconBg: 'bg-amber-100',
        lineColor: 'bg-amber-300',
      }
    default:
      return {
        icon: Circle,
        iconColor: 'text-slate-500',
        iconBg: 'bg-slate-100',
        lineColor: 'bg-slate-300',
      }
  }
}

/**
 * Format deadline for display
 * @param deadline - Deadline date string
 * @returns Formatted date string
 */
function formatDeadline(deadline: string): string {
  const date = new Date(deadline)
  const now = new Date()
  const diffDays = Math.ceil((date.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))

  if (diffDays < 0) {
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
  } else if (diffDays === 0) {
    return 'Today'
  } else if (diffDays === 1) {
    return 'Tomorrow'
  } else if (diffDays <= 7) {
    return `${diffDays}d`
  }

  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

/**
 * TimelineNode Component
 *
 * Individual project node in the timeline
 */
function TimelineNode({ project, index, total, onClick }: TimelineNodeProps) {
  const config = getNodeConfig(project.status)
  const Icon = config.icon
  const deadline = formatDeadline(project.deadline)
  const payout = project.price ?? project.doer_payout ?? 0
  const isUrgent = project.is_urgent

  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: index * 0.1 }}
      className="relative flex shrink-0 flex-col items-center"
    >
      {/* Connecting line (except for last item) */}
      {index < total - 1 && (
        <div
          className={cn(
            'absolute left-1/2 top-12 h-1 w-32 -translate-x-1/2 md:w-40 lg:w-48',
            config.lineColor
          )}
        />
      )}

      {/* Node container */}
      <div className="flex w-32 flex-col items-center gap-3 md:w-40 lg:w-48">
        {/* Icon with pulse animation */}
        <div className="relative">
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => onClick?.(project.id)}
            className={cn(
              'relative flex h-10 w-10 items-center justify-center rounded-full shadow-lg transition-all hover:shadow-xl',
              config.iconBg,
              'focus:outline-none focus:ring-2 focus:ring-[#5A7CFF] focus:ring-offset-2'
            )}
            aria-label={`View ${project.title}`}
          >
            {/* Pulse animation for active states */}
            {config.pulseColor && (
              <span className="absolute flex h-full w-full">
                <span
                  className={cn(
                    'absolute inline-flex h-full w-full animate-ping rounded-full opacity-75',
                    config.pulseColor
                  )}
                />
              </span>
            )}
            <Icon className={cn('relative h-5 w-5', config.iconColor)} />
          </motion.button>

          {/* Urgent indicator */}
          {isUrgent && (
            <div className="absolute -right-1 -top-1 flex h-4 w-4 items-center justify-center rounded-full bg-rose-500 shadow-md">
              <span className="text-[10px] font-bold text-white">!</span>
            </div>
          )}
        </div>

        {/* Project info card */}
        <motion.div
          whileHover={{ y: -2 }}
          onClick={() => onClick?.(project.id)}
          className={cn(
            'group cursor-pointer space-y-2 rounded-xl border border-border/70 bg-white/80 p-3 shadow-[0_8px_20px_rgba(148,163,184,0.08)] backdrop-blur-sm transition-all hover:shadow-[0_16px_35px_rgba(30,58,138,0.12)]',
            'w-full'
          )}
          role="button"
          tabIndex={0}
          onKeyDown={(event) => {
            if (event.key === 'Enter' || event.key === ' ') {
              event.preventDefault()
              onClick?.(project.id)
            }
          }}
        >
          {/* Project title */}
          <h4 className="line-clamp-2 text-xs font-semibold text-slate-800 leading-tight">
            {project.title}
          </h4>

          {/* Metadata */}
          <div className="space-y-1.5">
            {/* Deadline */}
            <div className="flex items-center gap-1.5 text-[10px] text-slate-500">
              <Calendar className="h-3 w-3" />
              <span className="font-medium">{deadline}</span>
            </div>

            {/* Payout */}
            <div className="flex items-center justify-between">
              <span className="text-[10px] font-medium text-slate-500">Payout</span>
              <span className="text-xs font-bold text-emerald-600">
                ₹{payout.toLocaleString('en-IN', { notation: 'compact' })}
              </span>
            </div>

            {/* Subject tag */}
            {project.subject_name && (
              <Badge
                variant="secondary"
                className="w-full justify-center truncate rounded-full px-2 py-0.5 text-[10px] font-medium bg-[#EEF2FF] text-[#4F6CF7]"
              >
                {project.subject_name}
              </Badge>
            )}
          </div>
        </motion.div>
      </div>
    </motion.div>
  )
}

/**
 * TimelineView Component
 *
 * Horizontal timeline view displaying projects as connected nodes.
 * Features:
 * - Horizontal scrollable timeline
 * - Status-based node styling with icons
 * - Pulse animations for active states
 * - Connecting lines between nodes
 * - Responsive design
 * - Smooth animations with Framer Motion
 *
 * @example
 * ```tsx
 * <TimelineView
 *   projects={projectsList}
 *   onProjectClick={(id) => router.push(`/projects/${id}`)}
 * />
 * ```
 */
export function TimelineView({ projects, onProjectClick, className }: TimelineViewProps) {
  // Sort projects by deadline
  const sortedProjects = [...projects].sort(
    (a, b) => new Date(a.deadline).getTime() - new Date(b.deadline).getTime()
  )

  if (projects.length === 0) {
    return (
      <div className={cn('rounded-2xl border border-dashed border-slate-300 bg-slate-50/50 p-12', className)}>
        <div className="flex flex-col items-center justify-center text-center">
          <div className="mb-3 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
            <Calendar className="h-8 w-8 text-slate-400" />
          </div>
          <h3 className="text-base font-semibold text-slate-700">No projects in timeline</h3>
          <p className="mt-1 max-w-sm text-sm text-slate-500">
            Projects you accept will appear here in chronological order.
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className={cn('relative', className)}>
      {/* Timeline header */}
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(91,124,255,0.25)]">
          <Calendar className="h-5 w-5" />
        </div>
        <div>
          <h3 className="text-base font-semibold text-slate-900">Project Timeline</h3>
          <p className="text-xs text-slate-500">
            {sortedProjects.length} {sortedProjects.length === 1 ? 'project' : 'projects'} in progress
          </p>
        </div>
      </div>

      {/* Scrollable timeline container */}
      <div className="relative overflow-x-auto pb-4">
        <div className="flex items-start gap-4 px-2 py-6">
          {sortedProjects.map((project, index) => (
            <TimelineNode
              key={project.id}
              project={project}
              index={index}
              total={sortedProjects.length}
              onClick={onProjectClick}
            />
          ))}
        </div>

        {/* Gradient fade on edges for scroll indication */}
        <div className="pointer-events-none absolute inset-y-0 left-0 w-8 bg-gradient-to-r from-white to-transparent" />
        <div className="pointer-events-none absolute inset-y-0 right-0 w-8 bg-gradient-to-l from-white to-transparent" />
      </div>

      {/* Legend */}
      <div className="mt-4 flex flex-wrap items-center gap-4 rounded-xl bg-slate-50/80 p-3">
        <span className="text-xs font-medium text-slate-600">Status:</span>
        <div className="flex items-center gap-1.5">
          <div className="h-2 w-2 rounded-full bg-emerald-500" />
          <span className="text-xs text-slate-600">Completed</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="h-2 w-2 rounded-full bg-sky-500" />
          <span className="text-xs text-slate-600">In Progress</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="h-2 w-2 rounded-full bg-rose-500" />
          <span className="text-xs text-slate-600">Needs Attention</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="h-2 w-2 rounded-full bg-amber-500" />
          <span className="text-xs text-slate-600">Not Started</span>
        </div>
      </div>
    </div>
  )
}
