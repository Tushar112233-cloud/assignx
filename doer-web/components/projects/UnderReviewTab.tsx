'use client'

import { motion, AnimatePresence } from 'framer-motion'
import type { Variants } from 'framer-motion'
import {
  Clock,
  Eye,
  CheckCircle2,
  FileSearch,
  Loader2,
  ExternalLink,
  Sparkles,
  Timer,
  Award,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import type { Project, ProjectStatus } from '@/types/database'

interface UnderReviewTabProps {
  /** List of projects under review */
  projects: Project[]
  /** Loading state */
  isLoading?: boolean
  /** Callback when project card is clicked */
  onProjectClick?: (projectId: string) => void
}

/** Get status display for review states with enhanced visuals */
function getReviewStatusDisplay(status: ProjectStatus): {
  label: string
  color: string
  icon: React.ReactNode
  description: string
  gradient: string
  dotColor: string
} {
  switch (status) {
    case 'submitted':
      return {
        label: 'Submitted',
        color: 'bg-[#5B86FF]/10 text-[#4F6CF7] border-[#5B86FF]/20',
        icon: <CheckCircle2 className="h-4 w-4" />,
        description: 'Awaiting supervisor review',
        gradient: 'from-[#5B86FF]/20 to-[#5B86FF]/5',
        dotColor: 'bg-[#5B86FF]',
      }
    case 'submitted_for_qc':
    case 'qc_in_progress':
      return {
        label: 'QC in Progress',
        color: 'bg-[#49C5FF]/10 text-[#43D1C5] border-[#49C5FF]/20',
        icon: <Loader2 className="h-4 w-4 animate-spin" />,
        description: 'Quality check in progress',
        gradient: 'from-[#49C5FF]/20 to-[#49C5FF]/5',
        dotColor: 'bg-[#49C5FF]',
      }
    default:
      return {
        label: 'Under Review',
        color: 'bg-violet-500/10 text-violet-600 border-violet-500/20',
        icon: <Eye className="h-4 w-4" />,
        description: 'Being reviewed',
        gradient: 'from-violet-500/20 to-violet-500/5',
        dotColor: 'bg-violet-500',
      }
  }
}

/** Format relative time */
function formatRelativeTime(dateString: string | null | undefined): string {
  if (!dateString) return 'Unknown'

  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffDays = Math.floor(diffHours / 24)

  if (diffDays > 0) {
    return `${diffDays}d ago`
  }
  if (diffHours > 0) {
    return `${diffHours}h ago`
  }
  const diffMinutes = Math.floor(diffMs / (1000 * 60))
  return `${diffMinutes}m ago`
}

/** Animation variants */
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, x: -20, scale: 0.98 },
  visible: {
    opacity: 1,
    x: 0,
    scale: 1,
    transition: {
      type: 'spring' as const,
      stiffness: 300,
      damping: 24,
    },
  },
  exit: {
    opacity: 0,
    x: 20,
    scale: 0.96,
    transition: { duration: 0.2 },
  },
}

/**
 * Under review tab component
 * Shows submitted projects awaiting QC approval with enhanced visuals
 */
export function UnderReviewTab({
  projects,
  isLoading: _isLoading = false,
  onProjectClick,
}: UnderReviewTabProps) {
  // Sort by submission time (most recent first)
  const sortedProjects = [...projects].sort((a, b) => {
    const aTime = a.submitted_at ? new Date(a.submitted_at).getTime() : 0
    const bTime = b.submitted_at ? new Date(b.submitted_at).getTime() : 0
    return bTime - aTime
  })

  // Calculate total pending earnings
  const totalPendingEarnings = sortedProjects.reduce(
    (sum, p) => sum + (p.price ?? p.doer_payout ?? 0),
    0
  )

  return (
    <Card className="border-none bg-white/85 shadow-[0_20px_50px_rgba(30,58,138,0.1)] backdrop-blur">
      <CardHeader className="space-y-4">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="space-y-1.5">
            <CardTitle className="text-2xl font-semibold tracking-tight text-slate-900">
              Review queue
            </CardTitle>
            <CardDescription className="text-sm text-slate-600">
              Projects waiting for QC approval and supervisor feedback.
            </CardDescription>
          </div>
          <Badge
            variant="secondary"
            className="rounded-full bg-gradient-to-r from-[#E6F4FF] to-[#E3E9FF] px-4 py-1.5 text-[#4F6CF7] shadow-[0_4px_12px_rgba(79,108,247,0.1)]"
          >
            <Eye className="mr-1.5 h-3.5 w-3.5" />
            {projects.length} in review
          </Badge>
        </div>

        {/* Stats */}
        {projects.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="grid grid-cols-2 gap-3"
          >
            <div className="rounded-2xl bg-gradient-to-br from-[#F0FDF4] to-[#DCFCE7] p-4 shadow-[0_8px_20px_rgba(34,197,94,0.08)]">
              <p className="text-xs font-medium text-emerald-700">Pending Earnings</p>
              <p className="mt-1 text-2xl font-bold text-emerald-700">
                ₹{totalPendingEarnings.toLocaleString('en-IN')}
              </p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-[#EEF2FF] to-[#E3E9FF] p-4 shadow-[0_8px_20px_rgba(79,108,247,0.08)]">
              <p className="text-xs font-medium text-[#4F6CF7]">Avg. Review Time</p>
              <p className="mt-1 text-2xl font-bold text-[#4F6CF7]">~24h</p>
            </div>
          </motion.div>
        )}
      </CardHeader>

      <CardContent className="space-y-4">
        {projects.length === 0 ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.3 }}
            className="flex flex-col items-center justify-center rounded-3xl border-2 border-dashed border-slate-200 bg-gradient-to-br from-slate-50 to-white p-12 text-center"
          >
            <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-[#E6F4FF] to-[#E3E9FF]">
              <FileSearch className="h-8 w-8 text-[#4F6CF7]" />
            </div>
            <h3 className="text-lg font-semibold text-slate-900">No projects under review</h3>
            <p className="mt-2 max-w-sm text-sm text-slate-500">
              Submit your completed work to see it in the review queue and track approval progress.
            </p>
          </motion.div>
        ) : (
          <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="space-y-3"
          >
            <AnimatePresence mode="popLayout">
              {sortedProjects.map((project) => {
                const statusInfo = getReviewStatusDisplay(project.status)
                const payout = project.price ?? project.doer_payout ?? 0

                return (
                  <motion.div
                    key={project.id}
                    variants={itemVariants}
                    layout
                    whileHover={{ x: 4, transition: { duration: 0.2 } }}
                    className="group"
                  >
                    <div
                      className="relative overflow-hidden rounded-3xl border border-slate-200/80 bg-white p-5 shadow-[0_8px_24px_rgba(148,163,184,0.12)] transition-all duration-300 hover:shadow-[0_16px_48px_rgba(30,58,138,0.16)] cursor-pointer"
                      onClick={() => onProjectClick?.(project.id)}
                      role="button"
                      tabIndex={0}
                      onKeyDown={(event) => {
                        if (event.key === 'Enter') onProjectClick?.(project.id)
                      }}
                    >
                      {/* Gradient overlay */}
                      <div
                        className={cn(
                          'absolute inset-0 bg-gradient-to-br opacity-0 transition-opacity duration-300 group-hover:opacity-100',
                          statusInfo.gradient
                        )}
                      />

                      <div className="relative flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                        {/* Content */}
                        <div className="flex-1 space-y-3">
                          <div className="flex items-start gap-3">
                            {/* Pulsing status dot */}
                            <motion.span
                              className={cn('mt-1.5 h-2.5 w-2.5 rounded-full', statusInfo.dotColor)}
                              animate={{ scale: [1, 1.3, 1], opacity: [1, 0.7, 1] }}
                              transition={{ repeat: Infinity, duration: 2 }}
                            />
                            <div className="flex-1 space-y-2">
                              <h3 className="text-base font-semibold text-slate-900 line-clamp-1">
                                {project.title}
                              </h3>
                              <Badge
                                variant="outline"
                                className={cn(
                                  'rounded-full border-none px-3 py-1 text-xs font-medium shadow-sm',
                                  statusInfo.color
                                )}
                              >
                                {statusInfo.icon}
                                <span className="ml-1.5">{statusInfo.label}</span>
                              </Badge>
                            </div>
                          </div>

                          {/* Meta info */}
                          <div className="ml-5 space-y-2">
                            <div className="flex flex-wrap items-center gap-2 text-xs text-slate-600">
                              {project.subject_name && (
                                <span className="rounded-full bg-slate-100 px-2.5 py-1">
                                  {project.subject_name}
                                </span>
                              )}
                              {project.supervisor_name && (
                                <span className="flex items-center gap-1.5">
                                  <Award className="h-3.5 w-3.5 text-slate-400" />
                                  <span>Reviewer: {project.supervisor_name}</span>
                                </span>
                              )}
                            </div>
                            <div className="flex items-center gap-2 text-xs text-slate-500">
                              <Timer className="h-3.5 w-3.5" />
                              <span>Submitted {formatRelativeTime(project.submitted_at)}</span>
                            </div>
                            <p className="text-xs italic text-slate-500">{statusInfo.description}</p>
                          </div>
                        </div>

                        {/* Actions */}
                        <div className="flex items-center gap-4 sm:flex-col sm:items-end">
                          <motion.div
                            whileHover={{ scale: 1.05 }}
                            className="text-right"
                          >
                            <p className="text-xs font-medium uppercase tracking-wide text-slate-500">
                              Earnings
                            </p>
                            <p className="mt-1 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-xl font-bold text-transparent">
                              ₹{payout.toLocaleString('en-IN')}
                            </p>
                          </motion.div>
                          <Button
                            variant="outline"
                            size="sm"
                            className="group/btn rounded-full border-[#5B86FF]/30 bg-gradient-to-r from-white to-[#F7F9FF] px-5 shadow-sm transition-all hover:shadow-[0_8px_16px_rgba(91,124,255,0.2)]"
                            onClick={(event) => {
                              event.stopPropagation()
                              onProjectClick?.(project.id)
                            }}
                          >
                            <ExternalLink className="mr-1.5 h-3.5 w-3.5 transition-transform group-hover/btn:rotate-12" />
                            View Details
                          </Button>
                        </div>
                      </div>

                      {/* Progress indicator for QC */}
                      {(project.status === 'qc_in_progress' || project.status === 'submitted_for_qc') && (
                        <motion.div
                          className="mt-4 rounded-2xl bg-gradient-to-r from-[#E6F4FF] to-[#E9FAFA] p-3"
                          initial={{ opacity: 0, height: 0 }}
                          animate={{ opacity: 1, height: 'auto' }}
                          transition={{ delay: 0.2 }}
                        >
                          <div className="flex items-center gap-3">
                            <Sparkles className="h-4 w-4 text-[#4F6CF7]" />
                            <div className="flex-1">
                              <p className="text-xs font-medium text-[#4F6CF7]">
                                Quality check in progress
                              </p>
                              <p className="mt-0.5 text-xs text-slate-600">
                                Usually takes 12-24 hours
                              </p>
                            </div>
                            <div className="h-2 flex-1 overflow-hidden rounded-full bg-white/80">
                              <motion.div
                                className="h-full rounded-full bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF]"
                                animate={{ width: ['0%', '60%'] }}
                                transition={{ duration: 2, ease: 'easeInOut' as const }}
                              />
                            </div>
                          </div>
                        </motion.div>
                      )}
                    </div>
                  </motion.div>
                )
              })}
            </AnimatePresence>
          </motion.div>
        )}
      </CardContent>
    </Card>
  )
}
