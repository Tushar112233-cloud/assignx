'use client'

import { useState, memo } from 'react'
import { motion, AnimatePresence, useSpring, useTransform } from 'framer-motion'
import type { Variants } from 'framer-motion'
import {
  Clock,
  IndianRupee,
  User,
  Calendar,
  TrendingUp,
  ExternalLink,
  CheckCircle2,
  AlertCircle,
  RefreshCw,
  Sparkles,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import type { Project } from '@/components/dashboard'

interface ProjectGridCardProps {
  /** Project data */
  project: Project
  /** Callback when card is clicked */
  onClick: () => void
  /** Callback to open workspace */
  onOpenWorkspace: (id: string) => void
}

/**
 * Calculate days until deadline
 */
function getDaysUntilDeadline(deadline: Date): number {
  const now = new Date()
  const diff = deadline.getTime() - now.getTime()
  return Math.ceil(diff / (1000 * 60 * 60 * 24))
}

/**
 * Get urgency level based on days remaining
 */
function getUrgencyLevel(days: number): 'critical' | 'urgent' | 'normal' {
  if (days <= 2) return 'critical'
  if (days <= 7) return 'urgent'
  return 'normal'
}

/**
 * Calculate mock completion percentage (based on status)
 */
function getCompletionPercentage(status: Project['status']): number {
  switch (status) {
    case 'completed':
      return 100
    case 'in_progress':
      return 65
    case 'revision_requested':
      return 80
    case 'assigned':
      return 15
    default:
      return 0
  }
}

/**
 * Get status border color
 */
function getStatusBorderColor(status: Project['status']): string {
  switch (status) {
    case 'completed':
      return 'border-l-emerald-500'
    case 'in_progress':
      return 'border-l-blue-500'
    case 'revision_requested':
      return 'border-l-orange-500'
    case 'assigned':
      return 'border-l-purple-500'
    default:
      return 'border-l-slate-300'
  }
}

/**
 * Get status icon and color
 */
function getStatusIcon(status: Project['status']) {
  switch (status) {
    case 'completed':
      return { Icon: CheckCircle2, color: 'text-emerald-600', bg: 'bg-emerald-50' }
    case 'in_progress':
      return { Icon: TrendingUp, color: 'text-blue-600', bg: 'bg-blue-50' }
    case 'revision_requested':
      return { Icon: RefreshCw, color: 'text-orange-600', bg: 'bg-orange-50' }
    case 'assigned':
      return { Icon: AlertCircle, color: 'text-purple-600', bg: 'bg-purple-50' }
    default:
      return { Icon: Clock, color: 'text-slate-600', bg: 'bg-slate-50' }
  }
}

/**
 * Get status label
 */
function getStatusLabel(status: Project['status']): string {
  switch (status) {
    case 'completed':
      return 'Completed'
    case 'in_progress':
      return 'In Progress'
    case 'revision_requested':
      return 'Revision Needed'
    case 'assigned':
      return 'Assigned'
    default:
      return 'Open'
  }
}

/**
 * Framer Motion animation variants for stagger effects
 */
const cardVariants = {
  hidden: { opacity: 0, y: 20, scale: 0.95 },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      type: 'spring' as const,
      stiffness: 260,
      damping: 20,
      mass: 0.8,
    },
  },
  exit: {
    opacity: 0,
    scale: 0.98,
    transition: {
      duration: 0.2,
    },
  },
}

const hoverVariants = {
  rest: { scale: 1, y: 0 },
  hover: {
    scale: 1.02,
    y: -8,
    transition: {
      type: 'spring' as const,
      stiffness: 400,
      damping: 17,
    },
  },
  tap: {
    scale: 0.98,
    transition: {
      duration: 0.1,
    },
  },
}

const glowVariants = {
  rest: { opacity: 0, scale: 0.8 },
  hover: {
    opacity: 0.15,
    scale: 1.1,
    transition: {
      duration: 0.4,
      ease: 'easeOut' as const,
    },
  },
}

const shimmerVariants = {
  animate: {
    backgroundPosition: ['200% 0', '-200% 0'],
    transition: {
      duration: 8,
      ease: 'linear' as const,
      repeat: Infinity,
    },
  },
}

/**
 * Beautiful project grid card with glassmorphism and advanced animations
 * Memoized for performance optimization
 */
export const ProjectGridCard = memo(function ProjectGridCard({
  project,
  onClick,
  onOpenWorkspace
}: ProjectGridCardProps) {
  const [isHovered, setIsHovered] = useState(false)

  // Memoized calculations for performance
  const daysUntilDeadline = getDaysUntilDeadline(project.deadline)
  const urgencyLevel = getUrgencyLevel(daysUntilDeadline)
  const completionPercent = getCompletionPercentage(project.status)
  const statusBorder = getStatusBorderColor(project.status)
  const { Icon: StatusIcon, color: statusColor, bg: statusBg } = getStatusIcon(project.status)
  const statusLabel = getStatusLabel(project.status)

  // Spring animations for smooth interactions
  const springConfig = { stiffness: 300, damping: 30 }
  const rotateX = useSpring(0, springConfig)
  const rotateY = useSpring(0, springConfig)

  /** Format deadline */
  const formattedDeadline = project.deadline.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })

  /** Get urgency badge color */
  const urgencyBadgeClass = cn({
    'bg-red-100 text-red-700 border-red-200': urgencyLevel === 'critical',
    'bg-orange-100 text-orange-700 border-orange-200': urgencyLevel === 'urgent',
    'bg-teal-100 text-teal-700 border-teal-200': urgencyLevel === 'normal',
  })

  /** Get urgency text */
  const urgencyText =
    daysUntilDeadline < 0
      ? 'Overdue'
      : daysUntilDeadline === 0
        ? 'Due today'
        : daysUntilDeadline === 1
          ? '1 day left'
          : `${daysUntilDeadline} days left`

  /**
   * Handle mouse move for 3D tilt effect
   */
  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect()
    const x = e.clientX - rect.left
    const y = e.clientY - rect.top
    const centerX = rect.width / 2
    const centerY = rect.height / 2
    const rotateXValue = ((y - centerY) / centerY) * -5
    const rotateYValue = ((x - centerX) / centerX) * 5

    rotateX.set(rotateXValue)
    rotateY.set(rotateYValue)
  }

  /**
   * Reset tilt on mouse leave
   */
  const handleMouseLeave = () => {
    setIsHovered(false)
    rotateX.set(0)
    rotateY.set(0)
  }

  return (
    <motion.div
      variants={cardVariants}
      initial="hidden"
      animate="visible"
      exit="exit"
      whileHover="hover"
      whileTap="tap"
      onMouseEnter={() => setIsHovered(true)}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      onClick={onClick}
      style={{
        rotateX,
        rotateY,
        transformStyle: 'preserve-3d',
      }}
      className={cn(
        'group relative cursor-pointer overflow-hidden rounded-3xl border-l-4 bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)] backdrop-blur-lg will-change-transform',
        statusBorder
      )}
    >
      {/* Animated gradient glow on hover */}
      <motion.div
        variants={glowVariants}
        initial="rest"
        animate={isHovered ? 'hover' : 'rest'}
        className="pointer-events-none absolute inset-0 bg-gradient-to-br from-[#5B7CFF] via-transparent to-[#43D1C5]"
      />

      {/* Shimmer effect on urgent cards */}
      {urgencyLevel === 'critical' && (
        <motion.div
          variants={shimmerVariants}
          animate="animate"
          className="pointer-events-none absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent bg-[length:200%_100%]"
        />
      )}

      <div className="relative space-y-4">
        {/* Header: Status badge and Price */}
        <div className="flex items-start justify-between gap-3">
          <div className={cn('flex items-center gap-2 rounded-full px-3 py-1.5 text-xs font-semibold', statusBg)}>
            <StatusIcon className={cn('h-3.5 w-3.5', statusColor)} />
            <span className={statusColor}>{statusLabel}</span>
          </div>

          <div className="flex items-center gap-1 rounded-full bg-gradient-to-r from-[#5B7CFF] to-[#43D1C5] px-3 py-1.5 text-sm font-bold text-white shadow-[0_8px_16px_rgba(91,124,255,0.3)]">
            <IndianRupee className="h-4 w-4" />
            <span>{project.price.toLocaleString('en-IN')}</span>
          </div>
        </div>

        {/* Title and Subject */}
        <div className="space-y-2">
          <h3 className="line-clamp-2 text-lg font-semibold text-slate-900 transition-colors group-hover:text-[#4F6CF7]">
            {project.title}
          </h3>
          <Badge
            variant="secondary"
            className="rounded-full bg-[#EEF2FF] px-3 py-1 text-xs font-medium text-[#4F6CF7]"
          >
            {project.subject}
          </Badge>
        </div>

        {/* Supervisor */}
        {project.supervisorName && (
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <div className="flex h-7 w-7 items-center justify-center rounded-full bg-[#E3E9FF] text-[#4F6CF7]">
              <User className="h-4 w-4" />
            </div>
            <span className="font-medium">{project.supervisorName}</span>
          </div>
        )}

        {/* Deadline countdown */}
        <div className="flex items-center gap-2">
          <Calendar className="h-4 w-4 text-slate-500" />
          <span className="text-sm text-slate-600">{formattedDeadline}</span>
          <div
            className={cn(
              'ml-auto rounded-full border px-2.5 py-1 text-xs font-semibold',
              urgencyBadgeClass
            )}
          >
            {urgencyText}
          </div>
        </div>

        {/* Animated progress bar with shimmer */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-xs">
            <span className="font-medium text-slate-600">Progress</span>
            <motion.span
              key={completionPercent}
              initial={{ scale: 1.2, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="font-semibold text-[#4F6CF7]"
            >
              {completionPercent}%
            </motion.span>
          </div>
          <div className="relative h-2 overflow-hidden rounded-full bg-slate-100">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${completionPercent}%` }}
              transition={{
                duration: 1.2,
                ease: [0.43, 0.13, 0.23, 0.96],
                delay: 0.1,
              }}
              className="relative h-full rounded-full bg-gradient-to-r from-[#5B7CFF] via-[#5B86FF] to-[#43D1C5]"
            >
              {/* Progress bar shimmer */}
              <motion.div
                animate={{
                  x: ['-100%', '200%'],
                }}
                transition={{
                  duration: 1.5,
                  ease: 'easeInOut' as const,
                  repeat: Infinity,
                  repeatDelay: 1,
                }}
                className="absolute inset-0 bg-gradient-to-r from-transparent via-white/40 to-transparent"
              />
            </motion.div>
          </div>
        </div>

        {/* Animated action button with ripple effect */}
        <motion.div
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          transition={{ type: 'spring' as const, stiffness: 400, damping: 17 }}
        >
          <Button
            onClick={(e) => {
              e.stopPropagation()
              onOpenWorkspace(project.id)
            }}
            className={cn(
              'group/btn relative w-full overflow-hidden rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] py-2.5 text-sm font-semibold text-white shadow-[0_12px_24px_rgba(91,124,255,0.3)]'
            )}
          >
            {/* Button shimmer effect */}
            <motion.div
              animate={{
                x: ['-100%', '200%'],
              }}
              transition={{
                duration: 2,
                ease: 'easeInOut' as const,
                repeat: Infinity,
                repeatDelay: 2,
              }}
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
            />

            <span className="relative z-10 flex items-center justify-center gap-2">
              Open Workspace
              <motion.div
                animate={{ x: [0, 2, 0] }}
                transition={{
                  duration: 1.5,
                  ease: 'easeInOut' as const,
                  repeat: Infinity,
                }}
              >
                <ExternalLink className="h-4 w-4" />
              </motion.div>
            </span>

            {/* Hover gradient overlay */}
            <motion.div
              initial={{ opacity: 0 }}
              whileHover={{ opacity: 1 }}
              transition={{ duration: 0.3 }}
              className="absolute inset-0 bg-gradient-to-r from-[#4F6CF7] via-[#4B9BFF] to-[#3BC5B8]"
            />
          </Button>
        </motion.div>

      {/* Sparkle effect on hover for high-priority projects */}
      <AnimatePresence>
        {isHovered && urgencyLevel === 'urgent' && (
          <motion.div
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0 }}
            className="absolute top-4 right-4"
          >
            <Sparkles className="h-5 w-5 text-amber-400 animate-pulse" />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  </motion.div>
  )
})
