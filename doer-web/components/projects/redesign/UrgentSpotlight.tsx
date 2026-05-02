'use client'

import { AlertTriangle, Clock, ArrowRight } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { motion } from 'framer-motion'
import type { Project } from '@/types/database'
import { cn } from '@/lib/utils'

/**
 * Props for UrgentSpotlight component
 */
export interface UrgentSpotlightProps {
  /** The urgent project to spotlight */
  project: Project
  /** Callback when project is clicked */
  onProjectClick?: (projectId: string) => void
}

/**
 * Calculate time remaining until deadline
 */
function getTimeRemaining(deadline: string): {
  value: number
  unit: string
  isUrgent: boolean
} {
  const now = new Date()
  const deadlineDate = new Date(deadline)
  const diffMs = deadlineDate.getTime() - now.getTime()
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffDays = Math.floor(diffHours / 24)

  if (diffHours < 0) {
    return { value: 0, unit: 'overdue', isUrgent: true }
  } else if (diffHours < 24) {
    return { value: diffHours, unit: diffHours === 1 ? 'hour' : 'hours', isUrgent: true }
  } else if (diffDays < 7) {
    return { value: diffDays, unit: diffDays === 1 ? 'day' : 'days', isUrgent: true }
  } else {
    return { value: diffDays, unit: 'days', isUrgent: false }
  }
}

/**
 * Urgent Spotlight Component
 *
 * Highlights the most urgent project requiring immediate attention.
 * Features pulse animation, priority badge, and quick action button.
 * Displays deadline countdown with color-coded urgency levels.
 *
 * @component
 * @example
 * ```tsx
 * <UrgentSpotlight
 *   project={urgentProject}
 *   onProjectClick={(id) => router.push(`/projects/${id}`)}
 * />
 * ```
 */
export function UrgentSpotlight({ project, onProjectClick }: UrgentSpotlightProps) {
  const timeRemaining = getTimeRemaining(project.deadline)
  const isRevision = project.status === 'revision_requested'

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
    >
      <Card className="relative overflow-hidden border-white/70 bg-gradient-to-br from-[#FFF4F0] via-[#FFF7F4] to-[#FFEFE9] shadow-[0_16px_35px_rgba(255,139,106,0.15)]">
        {/* Animated background pulse */}
        <motion.div
          className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(255,139,106,0.2),transparent_60%)]"
          animate={{
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            ease: 'easeInOut',
          }}
        />

        <CardContent className="relative space-y-4 p-5">
          {/* Header */}
          <div className="flex items-start justify-between gap-2">
            <div className="flex items-center gap-2">
              <motion.div
                className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#FFE7E1]"
                animate={{
                  scale: [1, 1.1, 1],
                }}
                transition={{
                  duration: 2,
                  repeat: Infinity,
                  ease: 'easeInOut',
                }}
              >
                <AlertTriangle className="h-5 w-5 text-[#FF8B6A]" />
              </motion.div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">
                  {isRevision ? 'Needs Revision' : 'Most Urgent'}
                </p>
                <p className="text-sm text-slate-500">Requires immediate action</p>
              </div>
            </div>

            {isRevision && (
              <Badge
                variant="secondary"
                className="animate-pulse bg-[#FF8B6A] text-white"
              >
                Revision
              </Badge>
            )}
          </div>

          {/* Project Info */}
          <div className="space-y-2">
            <h3 className="line-clamp-2 text-base font-semibold text-slate-900">
              {project.title}
            </h3>

            <div className="flex flex-wrap items-center gap-2 text-xs text-slate-600">
              {project.subject_name && (
                <span className="rounded-full bg-white/60 px-2 py-1">
                  {project.subject_name}
                </span>
              )}
              {project.supervisor_name && (
                <span className="rounded-full bg-white/60 px-2 py-1">
                  {project.supervisor_name}
                </span>
              )}
            </div>
          </div>

          {/* Deadline and Earnings */}
          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-2xl bg-white/80 p-3 shadow-[0_8px_16px_rgba(148,163,184,0.08)]">
              <div className="flex items-center gap-1.5 text-xs text-slate-500">
                <Clock className="h-3.5 w-3.5" />
                <span>Deadline</span>
              </div>
              <p
                className={cn(
                  'mt-1 text-base font-semibold',
                  timeRemaining.isUrgent ? 'text-[#FF8B6A]' : 'text-slate-900'
                )}
              >
                {timeRemaining.value === 0
                  ? 'Overdue!'
                  : `${timeRemaining.value} ${timeRemaining.unit}`}
              </p>
            </div>

            <div className="rounded-2xl bg-white/80 p-3 shadow-[0_8px_16px_rgba(148,163,184,0.08)]">
              <div className="flex items-center gap-1.5 text-xs text-slate-500">
                <span>Payout</span>
              </div>
              <p className="mt-1 text-base font-semibold text-slate-900">
                ₹{(project.doer_payout || 0).toLocaleString('en-IN')}
              </p>
            </div>
          </div>

          {/* Action Button */}
          <Button
            onClick={() => onProjectClick?.(project.id)}
            className="group w-full rounded-full bg-gradient-to-r from-[#FF9B7A] to-[#FF8B6A] text-white shadow-[0_12px_28px_rgba(255,139,106,0.3)] transition-all hover:shadow-[0_16px_32px_rgba(255,139,106,0.4)]"
          >
            <span className="font-semibold">
              {isRevision ? 'Start Revision' : 'Work on This'}
            </span>
            <ArrowRight className="ml-2 h-4 w-4 transition-transform group-hover:translate-x-1" />
          </Button>

          {/* Progress Bar (if available) */}
          {project.progress_percentage !== null &&
            project.progress_percentage !== undefined && (
              <div className="space-y-1.5">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-slate-500">Progress</span>
                  <span className="font-semibold text-slate-900">
                    {project.progress_percentage}%
                  </span>
                </div>
                <div className="h-1.5 overflow-hidden rounded-full bg-white/60">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${project.progress_percentage}%` }}
                    transition={{ duration: 0.5, ease: 'easeOut' }}
                    className="h-full bg-gradient-to-r from-[#FF9B7A] to-[#FF8B6A]"
                  />
                </div>
              </div>
            )}
        </CardContent>
      </Card>
    </motion.div>
  )
}
