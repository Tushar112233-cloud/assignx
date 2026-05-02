'use client'

import { motion, AnimatePresence, type Variants } from 'framer-motion'
import {
  CheckCircle2,
  IndianRupee,
  Star,
  Calendar,
  Download,
  Trophy,
  Award,
  Sparkles,
  TrendingUp,
  CircleDollarSign,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import type { Project, ProjectStatus } from '@/types/database'
import { formatDate } from './utils'

interface CompletedProjectsTabProps {
  /** List of completed projects */
  projects: Project[]
  /** Loading state */
  isLoading?: boolean
  /** Callback when project card is clicked */
  onProjectClick?: (projectId: string) => void
  /** Callback to download invoice */
  onDownloadInvoice?: (projectId: string) => void
}

/** Get payment status display with enhanced visuals */
function getPaymentStatus(status: ProjectStatus): {
  label: string
  color: string
  icon: React.ReactNode
  gradient: string
  celebration: boolean
} {
  switch (status) {
    case 'delivered':
      return {
        label: 'Delivered',
        color: 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20',
        icon: <CircleDollarSign className="h-3.5 w-3.5" />,
        gradient: 'from-emerald-500/20 to-emerald-500/5',
        celebration: true,
      }
    case 'qc_approved':
    case 'auto_approved':
      return {
        label: 'Approved',
        color: 'bg-[#5B86FF]/10 text-[#4F6CF7] border-[#5B86FF]/20',
        icon: <CheckCircle2 className="h-3.5 w-3.5" />,
        gradient: 'from-[#5B86FF]/20 to-[#5B86FF]/5',
        celebration: true,
      }
    case 'completed':
      return {
        label: 'Completed',
        color: 'bg-violet-500/10 text-violet-600 border-violet-500/20',
        icon: <Trophy className="h-3.5 w-3.5" />,
        gradient: 'from-violet-500/20 to-violet-500/5',
        celebration: true,
      }
    default:
      return {
        label: status,
        color: 'bg-muted text-muted-foreground',
        icon: <CheckCircle2 className="h-3.5 w-3.5" />,
        gradient: 'from-muted/20 to-muted/5',
        celebration: false,
      }
  }
}

/** Animation variants */
const containerVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05,
    },
  },
}

const itemVariants: Variants = {
  hidden: { opacity: 0, scale: 0.95 },
  visible: {
    opacity: 1,
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

const celebrationVariants: Variants = {
  initial: { scale: 1 },
  animate: {
    scale: [1, 1.05, 1],
    transition: {
      duration: 2,
      repeat: Infinity,
    },
  },
}

/**
 * Completed projects tab component
 * Shows historical completed projects with earnings and achievements
 */
export function CompletedProjectsTab({
  projects,
  isLoading: _isLoading = false,
  onProjectClick,
  onDownloadInvoice,
}: CompletedProjectsTabProps) {
  // Sort by completion time (most recent first)
  const sortedProjects = [...projects].sort((a, b) => {
    const aTime = a.completed_at ? new Date(a.completed_at).getTime() : 0
    const bTime = b.completed_at ? new Date(b.completed_at).getTime() : 0
    return bTime - aTime
  })

  // Calculate total earnings
  const totalEarnings = projects.reduce((sum, p) => sum + (p.price ?? p.doer_payout ?? 0), 0)

  // Calculate average rating (mocked for now)
  const avgRating = 4.2

  return (
    <Card className="border-none bg-white/85 shadow-[0_20px_50px_rgba(30,58,138,0.1)] backdrop-blur">
      <CardHeader className="space-y-4">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="space-y-1.5">
            <CardTitle className="text-2xl font-semibold tracking-tight text-slate-900">
              Completed highlights
            </CardTitle>
            <CardDescription className="text-sm text-slate-600">
              Celebrate delivered work and track your achievements.
            </CardDescription>
          </div>
          <Badge
            variant="secondary"
            className="rounded-full bg-gradient-to-r from-emerald-50 to-teal-50 px-4 py-1.5 text-emerald-700 shadow-[0_4px_12px_rgba(34,197,94,0.1)]"
          >
            <Trophy className="mr-1.5 h-3.5 w-3.5" />
            {projects.length} completed
          </Badge>
        </div>

        {/* Stats cards */}
        <div className="grid gap-3 sm:grid-cols-3">
          <motion.div
            whileHover={{ y: -2 }}
            className="relative overflow-hidden rounded-3xl border-2 border-emerald-200/50 bg-gradient-to-br from-emerald-50 via-emerald-50/80 to-teal-50 p-4 shadow-[0_12px_28px_rgba(34,197,94,0.12)]"
          >
            <div className="absolute right-2 top-2 opacity-10">
              <IndianRupee className="h-16 w-16 text-emerald-600" />
            </div>
            <div className="relative">
              <p className="text-xs font-semibold uppercase tracking-wide text-emerald-700">
                Total Earnings
              </p>
              <p className="mt-2 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-3xl font-bold text-transparent">
                ₹{totalEarnings.toLocaleString('en-IN')}
              </p>
              <div className="mt-2 flex items-center gap-1 text-xs text-emerald-600">
                <TrendingUp className="h-3 w-3" />
                <span>+12% this month</span>
              </div>
            </div>
          </motion.div>

          <motion.div
            whileHover={{ y: -2 }}
            className="rounded-3xl border border-slate-200/80 bg-gradient-to-br from-[#EEF2FF] to-[#E3E9FF] p-4 shadow-[0_12px_28px_rgba(79,108,247,0.12)]"
          >
            <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">
              Projects Delivered
            </p>
            <p className="mt-2 text-3xl font-bold text-[#4F6CF7]">{projects.length}</p>
            <div className="mt-2 flex items-center gap-1 text-xs text-[#4F6CF7]">
              <Sparkles className="h-3 w-3" />
              <span>Keep going!</span>
            </div>
          </motion.div>

          <motion.div
            whileHover={{ y: -2 }}
            className="rounded-3xl border border-amber-200/80 bg-gradient-to-br from-amber-50 to-yellow-50 p-4 shadow-[0_12px_28px_rgba(251,191,36,0.12)]"
          >
            <p className="text-xs font-semibold uppercase tracking-wide text-amber-700">
              Avg. Rating
            </p>
            <div className="mt-2 flex items-center gap-2">
              <p className="text-3xl font-bold text-amber-700">{avgRating}</p>
              <div className="flex">
                {[1, 2, 3, 4, 5].map((star) => (
                  <Star
                    key={star}
                    className={cn(
                      'h-4 w-4',
                      star <= Math.floor(avgRating)
                        ? 'fill-amber-400 text-amber-400'
                        : star === Math.ceil(avgRating)
                        ? 'fill-amber-400/50 text-amber-400'
                        : 'text-amber-300'
                    )}
                  />
                ))}
              </div>
            </div>
            <div className="mt-2 flex items-center gap-1 text-xs text-amber-600">
              <Award className="h-3 w-3" />
              <span>Excellent work!</span>
            </div>
          </motion.div>
        </div>
      </CardHeader>

      <CardContent className="space-y-4">
        {projects.length === 0 ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.3 }}
            className="flex flex-col items-center justify-center rounded-3xl border-2 border-dashed border-slate-200 bg-gradient-to-br from-slate-50 to-white p-12 text-center"
          >
            <motion.div
              variants={celebrationVariants}
              initial="initial"
              animate="animate"
              className="mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-amber-50 to-yellow-50"
            >
              <Trophy className="h-8 w-8 text-amber-600" />
            </motion.div>
            <h3 className="text-lg font-semibold text-slate-900">No completed projects yet</h3>
            <p className="mt-2 max-w-sm text-sm text-slate-500">
              Complete your first project to see achievements here and start building your success story.
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
                const paymentInfo = getPaymentStatus(project.status)
                const payout = project.price ?? project.doer_payout ?? 0

                return (
                  <motion.div
                    key={project.id}
                    variants={itemVariants}
                    layout
                    whileHover={{ scale: 1.01, transition: { duration: 0.2 } }}
                    className="group"
                  >
                    <div
                      className="relative overflow-hidden rounded-3xl border border-slate-200/80 bg-white shadow-[0_8px_24px_rgba(148,163,184,0.12)] transition-all duration-300 hover:shadow-[0_16px_48px_rgba(30,58,138,0.16)] cursor-pointer"
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
                          paymentInfo.gradient
                        )}
                      />

                      <div className="relative p-5">
                        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                          {/* Content */}
                          <div className="flex-1 space-y-3">
                            <div className="flex items-start gap-3">
                              <motion.div
                                animate={paymentInfo.celebration ? { rotate: [0, 10, -10, 0] } : {}}
                                transition={{ duration: 0.5, repeat: Infinity, repeatDelay: 3 }}
                              >
                                <CheckCircle2 className="mt-0.5 h-5 w-5 text-emerald-600" />
                              </motion.div>
                              <div className="flex-1 space-y-2">
                                <h3 className="text-base font-semibold text-slate-900 line-clamp-1">
                                  {project.title}
                                </h3>
                                <Badge
                                  variant="outline"
                                  className={cn(
                                    'rounded-full border-none px-3 py-1 text-xs font-medium shadow-sm',
                                    paymentInfo.color
                                  )}
                                >
                                  {paymentInfo.icon}
                                  <span className="ml-1.5">{paymentInfo.label}</span>
                                </Badge>
                              </div>
                            </div>

                            {/* Meta info */}
                            <div className="ml-8 space-y-2">
                              <div className="flex flex-wrap items-center gap-2 text-xs text-slate-600">
                                {project.subject_name && (
                                  <span className="rounded-full bg-slate-100 px-2.5 py-1">
                                    {project.subject_name}
                                  </span>
                                )}
                                {project.supervisor_name && (
                                  <span className="flex items-center gap-1">
                                    <span className="text-slate-400">•</span>
                                    <span>{project.supervisor_name}</span>
                                  </span>
                                )}
                              </div>
                              <div className="flex items-center gap-2 text-xs text-slate-500">
                                <Calendar className="h-3.5 w-3.5" />
                                Completed {project.completed_at ? formatDate(project.completed_at) : 'Unknown'}
                              </div>
                            </div>
                          </div>

                          {/* Actions */}
                          <div className="flex items-center gap-3 sm:flex-col sm:items-end">
                            <motion.div
                              whileHover={{ scale: 1.05 }}
                              className="text-right"
                            >
                              <p className="text-xs font-medium uppercase tracking-wide text-slate-500">
                                Earned
                              </p>
                              <p className="mt-1 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-2xl font-bold text-transparent">
                                ₹{payout.toLocaleString('en-IN')}
                              </p>
                            </motion.div>
                            {(project.status === 'delivered' || project.status === 'completed') &&
                              onDownloadInvoice && (
                                <Button
                                  variant="outline"
                                  size="sm"
                                  className="group/btn rounded-full border-emerald-300/50 bg-gradient-to-r from-white to-emerald-50 px-5 shadow-sm transition-all hover:shadow-[0_8px_16px_rgba(34,197,94,0.2)]"
                                  onClick={(event) => {
                                    event.stopPropagation()
                                    onDownloadInvoice(project.id)
                                  }}
                                >
                                  <Download className="mr-1.5 h-3.5 w-3.5 transition-transform group-hover/btn:-translate-y-0.5" />
                                  Invoice
                                </Button>
                              )}
                          </div>
                        </div>

                        {/* Quality score section */}
                        <motion.div
                          initial={{ opacity: 0, height: 0 }}
                          animate={{ opacity: 1, height: 'auto' }}
                          transition={{ delay: 0.2 }}
                          className="mt-4 flex items-center justify-between rounded-2xl bg-gradient-to-r from-amber-50 to-yellow-50 px-4 py-3"
                        >
                          <span className="flex items-center gap-2 text-xs font-medium text-amber-700">
                            <Award className="h-4 w-4" />
                            Quality score
                          </span>
                          <span className="flex items-center gap-2">
                            {[1, 2, 3, 4, 5].map((star) => (
                              <motion.div
                                key={star}
                                initial={{ scale: 0 }}
                                animate={{ scale: 1 }}
                                transition={{ delay: 0.3 + star * 0.05 }}
                              >
                                <Star
                                  className={cn(
                                    'h-4 w-4',
                                    star <= 4
                                      ? 'fill-amber-400 text-amber-400'
                                      : 'text-amber-300'
                                  )}
                                />
                              </motion.div>
                            ))}
                            <span className="ml-2 text-sm font-semibold text-amber-700">4.0</span>
                          </span>
                        </motion.div>
                      </div>
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
