'use client'

import { memo, useMemo } from 'react'
import { motion } from 'framer-motion'
import type { Variants } from 'framer-motion'
import {
  Clock,
  Flame,
  FolderOpen,
  ExternalLink,
  AlertCircle,
  Zap,
  TrendingUp,
  Sparkles,
  IndianRupee,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'
import type { Project, ProjectStatus } from '@/types/database'
import { getTimeRemaining } from './utils'

interface ActiveProjectsTabProps {
  /** List of active projects */
  projects: Project[]
  /** Loading state */
  isLoading?: boolean
  /** Callback when project card is clicked */
  onProjectClick?: (projectId: string) => void
  /** Callback when open workspace is clicked */
  onOpenWorkspace?: (projectId: string) => void
}

/** Get status display with pastel gradient theme */
function getStatusDisplay(status: ProjectStatus): {
  label: string
  color: string
  dot: string
  icon: React.ReactNode
  gradient: string
  progressGradient: string
} {
  switch (status) {
    case 'assigned':
      return {
        label: 'Not Started',
        color: 'bg-amber-100/60 text-amber-700 border-amber-200/50',
        dot: 'bg-gradient-to-br from-amber-400 to-amber-500',
        icon: <AlertCircle className="h-3.5 w-3.5" />,
        gradient: 'from-amber-100/30 via-amber-50/20 to-transparent',
        progressGradient: 'from-amber-300 via-amber-400 to-orange-400',
      }
    case 'in_progress':
      return {
        label: 'In Progress',
        color: 'bg-sky-100/60 text-sky-700 border-sky-200/50',
        dot: 'bg-gradient-to-br from-sky-400 to-blue-500',
        icon: <Sparkles className="h-3.5 w-3.5" />,
        gradient: 'from-sky-100/30 via-sky-50/20 to-transparent',
        progressGradient: 'from-sky-300 via-blue-400 to-indigo-400',
      }
    case 'revision_requested':
      return {
        label: 'Revision Needed',
        color: 'bg-orange-100/60 text-orange-700 border-orange-200/50',
        dot: 'bg-gradient-to-br from-orange-400 to-coral-500',
        icon: <Zap className="h-3.5 w-3.5" />,
        gradient: 'from-orange-100/30 via-orange-50/20 to-transparent',
        progressGradient: 'from-orange-300 via-coral-400 to-rose-300',
      }
    case 'in_revision':
      return {
        label: 'In Revision',
        color: 'bg-violet-100/60 text-violet-700 border-violet-200/50',
        dot: 'bg-gradient-to-br from-violet-400 to-purple-500',
        icon: <TrendingUp className="h-3.5 w-3.5" />,
        gradient: 'from-violet-100/30 via-violet-50/20 to-transparent',
        progressGradient: 'from-violet-300 via-purple-400 to-fuchsia-400',
      }
    default:
      return {
        label: status,
        color: 'bg-slate-100/60 text-slate-600 border-slate-200/50',
        dot: 'bg-gradient-to-br from-slate-400 to-slate-500',
        icon: <AlertCircle className="h-3.5 w-3.5" />,
        gradient: 'from-slate-100/30 via-slate-50/20 to-transparent',
        progressGradient: 'from-slate-300 via-slate-400 to-slate-500',
      }
  }
}

/** Animation variants */
const containerVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
    },
  },
  exit: { opacity: 0 },
}

const cardVariants: Variants = {
  hidden: { opacity: 0, y: 20, scale: 0.95 },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      type: 'spring' as const,
      stiffness: 300,
      damping: 24,
    },
  },
  exit: {
    opacity: 0,
    scale: 0.92,
    transition: { duration: 0.2 },
  },
}

const emptyStateVariants: Variants = {
  hidden: { opacity: 0, scale: 0.9 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: {
      type: 'spring' as const,
      stiffness: 200,
      damping: 20,
    },
  },
}

/** Loading skeleton for bento grid */
function BentoSkeleton() {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3 auto-rows-fr">
      {[1, 2, 3].map((i) => (
        <div
          key={i}
          className={cn(
            'rounded-3xl border border-border/50 bg-background/60 p-5 space-y-3',
            i === 1 && 'md:col-span-2'
          )}
        >
          <div className="flex items-start justify-between gap-3">
            <div className="space-y-2 flex-1">
              <Skeleton className="h-5 w-3/4" />
              <Skeleton className="h-4 w-1/2" />
            </div>
            <Skeleton className="h-8 w-24" />
          </div>
          <Skeleton className="h-3 w-full" />
          <div className="flex items-center justify-between gap-3">
            <Skeleton className="h-4 w-32" />
            <Skeleton className="h-9 w-24 rounded-full" />
          </div>
        </div>
      ))}
    </div>
  )
}

/**
 * Active projects tab component with bento grid layout
 * Elite design with pastel gradients and proper spacing
 */
export const ActiveProjectsTab = memo(function ActiveProjectsTab({
  projects,
  isLoading = false,
  onProjectClick,
  onOpenWorkspace,
}: ActiveProjectsTabProps) {
  // Sort by urgency and status
  const sortedProjects = useMemo(
    () =>
      [...projects].sort((a, b) => {
        // Revision requested first
        if (a.status === 'revision_requested' && b.status !== 'revision_requested')
          return -1
        if (b.status === 'revision_requested' && a.status !== 'revision_requested')
          return 1

        // Then by deadline
        return new Date(a.deadline).getTime() - new Date(b.deadline).getTime()
      }),
    [projects]
  )

  // Calculate stats
  const stats = useMemo(() => {
    const inProgress = projects.filter((p) => p.status === 'in_progress').length
    const urgent = projects.filter((p) => {
      const timeInfo = getTimeRemaining(p.deadline)
      return timeInfo.isUrgent || p.is_urgent
    }).length
    const totalEarnings = projects.reduce((sum, p) => sum + (p.price ?? p.doer_payout ?? 0), 0)

    return { inProgress, urgent, totalEarnings }
  }, [projects])

  return (
    <div className="space-y-6">
      {/* Header with stats */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-semibold tracking-tight text-slate-900">Active pipeline</h2>
          <p className="text-sm text-slate-500">Keep momentum on active work and revisions.</p>
        </div>
        <Badge
          variant="secondary"
          className="rounded-full bg-gradient-to-r from-[#EEF2FF] to-[#E3E9FF] px-4 py-1.5 text-[#4F6CF7] shadow-[0_4px_12px_rgba(79,108,247,0.15)]"
        >
          {projects.length} active
        </Badge>
      </div>

      {/* Quick stats mini cards */}
      {projects.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="grid gap-3 sm:grid-cols-3"
        >
          <div className="rounded-2xl border border-slate-200/60 bg-gradient-to-br from-slate-50/80 to-white/90 p-3.5 shadow-[0_8px_16px_rgba(148,163,184,0.08)]">
            <p className="text-xs font-medium uppercase tracking-wider text-slate-500">In Progress</p>
            <p className="mt-1 text-2xl font-bold bg-gradient-to-r from-slate-700 to-slate-900 bg-clip-text text-transparent">
              {stats.inProgress}
            </p>
          </div>
          <div className="rounded-2xl border border-amber-200/60 bg-gradient-to-br from-amber-50/80 to-orange-50/90 p-3.5 shadow-[0_8px_16px_rgba(251,191,36,0.12)]">
            <p className="text-xs font-medium uppercase tracking-wider text-amber-700">Urgent</p>
            <p className="mt-1 text-2xl font-bold bg-gradient-to-r from-amber-600 to-orange-600 bg-clip-text text-transparent">
              {stats.urgent}
            </p>
          </div>
          <div className="rounded-2xl border border-emerald-200/60 bg-gradient-to-br from-emerald-50/80 to-teal-50/90 p-3.5 shadow-[0_8px_16px_rgba(16,185,129,0.12)]">
            <p className="text-xs font-medium uppercase tracking-wider text-emerald-700">Pipeline Value</p>
            <p className="mt-1 text-xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
              ₹{stats.totalEarnings.toLocaleString('en-IN')}
            </p>
          </div>
        </motion.div>
      )}

      {/* Loading state */}
      {isLoading ? (
        <BentoSkeleton />
      ) : projects.length === 0 ? (
        /* Empty state */
        <motion.div
          variants={emptyStateVariants}
          initial="hidden"
          animate="visible"
          className="flex flex-col items-center justify-center rounded-3xl border-2 border-dashed border-slate-200 bg-gradient-to-br from-slate-50/50 to-white p-12 text-center"
        >
          <motion.div
            animate={{
              y: [0, -10, 0],
            }}
            transition={{
              duration: 2,
              ease: 'easeInOut' as const,
              repeat: Infinity,
            }}
          >
            <FolderOpen className="h-16 w-16 text-slate-300 mb-4" />
          </motion.div>
          <h3 className="text-lg font-semibold text-slate-900">No active projects</h3>
          <p className="text-sm text-slate-500 mt-2 max-w-sm">
            Accept tasks from the open pool to start working on projects.
          </p>
        </motion.div>
      ) : (
        /* Vertical list layout */
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
          className="space-y-4"
        >
          {sortedProjects.map((project, index) => {
            const timeInfo = getTimeRemaining(project.deadline)
            const statusInfo = getStatusDisplay(project.status)
            const isUrgent = timeInfo.isUrgent || project.is_urgent
            const payout = project.price ?? project.doer_payout ?? 0

            return (
              <motion.div
                key={project.id}
                variants={cardVariants}
                className={cn(
                  'group relative overflow-hidden rounded-3xl border cursor-pointer',
                  'bg-white/80 backdrop-blur-sm',
                  'shadow-[0_8px_24px_rgba(148,163,184,0.12)]',
                  'hover:shadow-[0_20px_48px_rgba(148,163,184,0.2)]',
                  'transition-all duration-300',
                  // Pastel border colors
                  project.status === 'revision_requested'
                    ? 'border-orange-200/60'
                    : isUrgent
                    ? 'border-amber-200/60'
                    : 'border-slate-200/60'
                )}
                onClick={() => onProjectClick?.(project.id)}
                role="button"
                tabIndex={0}
                onKeyDown={(event) => {
                  if (event.key === 'Enter') onProjectClick?.(project.id)
                }}
              >
                {/* Subtle gradient overlay */}
                <div
                  className={cn(
                    'absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300',
                    `bg-gradient-to-br ${statusInfo.gradient}`
                  )}
                />

                {/* Content */}
                <div className="relative p-5 space-y-4">
                  {/* Header */}
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex-1 space-y-2.5">
                      {/* Status badge and title */}
                      <div className="flex items-start gap-2.5">
                        <span
                          className={cn(
                            'mt-1 h-2.5 w-2.5 rounded-full shrink-0',
                            statusInfo.dot
                          )}
                        />
                        <div className="flex-1 min-w-0">
                          <h3 className="text-base font-semibold text-slate-900 line-clamp-2 leading-snug">
                            {project.title}
                          </h3>
                          <div className="flex flex-wrap items-center gap-2 mt-2">
                            <Badge
                              variant="outline"
                              className={cn(
                                'rounded-full px-2.5 py-0.5 text-xs font-medium border',
                                statusInfo.color
                              )}
                            >
                              {statusInfo.icon}
                              <span className="ml-1.5">{statusInfo.label}</span>
                            </Badge>
                            {isUrgent && (
                              <Badge
                                variant="secondary"
                                className="rounded-full px-2.5 py-0.5 text-xs font-medium bg-amber-100/60 text-amber-700 border border-amber-200/50"
                              >
                                <Flame className="h-3 w-3 mr-1" />
                                Urgent
                              </Badge>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Project details */}
                      <div className="flex flex-wrap items-center gap-2 text-xs text-slate-500 ml-5">
                        {project.subject_name && (
                          <span className="rounded-full bg-slate-100/80 px-2.5 py-1">
                            {project.subject_name}
                          </span>
                        )}
                        {project.supervisor_name && (
                          <>
                            <span className="text-slate-300">•</span>
                            <span>{project.supervisor_name}</span>
                          </>
                        )}
                      </div>
                    </div>

                    {/* Payout - pastel gradient */}
                    <div className="text-right shrink-0">
                      <p className="text-xs font-medium text-slate-500 uppercase tracking-wider">
                        Payout
                      </p>
                      <p className="mt-1 text-xl font-bold bg-gradient-to-r from-emerald-500 via-teal-500 to-cyan-500 bg-clip-text text-transparent">
                        ₹{payout.toLocaleString('en-IN')}
                      </p>
                    </div>
                  </div>

                  {/* Progress and actions */}
                  <div className="space-y-3">
                    {/* Deadline and button */}
                    <div className="flex items-center justify-between gap-3">
                      <div className="flex items-center gap-2 text-xs text-slate-600">
                        <Clock className="h-3.5 w-3.5 text-slate-400" />
                        <span className="font-medium">Due {timeInfo.text}</span>
                      </div>
                      <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
                        <Button
                          size="sm"
                          className={cn(
                            'rounded-full gap-2 shadow-[0_4px_12px_rgba(79,108,247,0.25)]',
                            'bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF]',
                            'hover:shadow-[0_8px_20px_rgba(79,108,247,0.35)]',
                            'transition-all duration-200'
                          )}
                          onClick={(event) => {
                            event.stopPropagation()
                            onOpenWorkspace?.(project.id)
                          }}
                        >
                          <ExternalLink className="h-3.5 w-3.5" />
                          {project.status === 'revision_requested' ? 'Review' : 'Open'}
                        </Button>
                      </motion.div>
                    </div>

                    {/* Progress bar with pastel gradient */}
                    <div className="relative h-2 rounded-full bg-slate-100/80 overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${timeInfo.percentage}%` }}
                        transition={{ duration: 0.8, ease: 'easeOut' as const }}
                        className={cn(
                          'h-full rounded-full',
                          `bg-gradient-to-r ${statusInfo.progressGradient}`
                        )}
                      />
                      {/* Shimmer effect */}
                      <motion.div
                        animate={{
                          x: ['-100%', '200%'],
                        }}
                        transition={{
                          duration: 2,
                          ease: 'easeInOut' as const,
                          repeat: Infinity,
                          repeatDelay: 1,
                        }}
                        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/40 to-transparent pointer-events-none"
                      />
                    </div>
                  </div>
                </div>
              </motion.div>
            )
          })}
        </motion.div>
      )}
    </div>
  )
})
