'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import {
  Clock,
  Flame,
  IndianRupee,
  User,
  Calendar,
  CheckCircle2,
  Loader2,
  ArrowRight,
  AlertTriangle,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'

import type { ProjectStatus } from '@/types/database'

interface ProjectCardProps {
  /** Project ID */
  id: string
  /** Project title */
  title: string
  /** Subject/category */
  subject: string
  /** Project description */
  description?: string
  /** Price in INR */
  price: number
  /** Deadline timestamp */
  deadline: Date
  /** Project status */
  status: ProjectStatus
  /** Supervisor name (for assigned tasks) */
  supervisorName?: string
  /** Whether this is an urgent task */
  isUrgent?: boolean
  /** Callback when accept button is clicked */
  onAccept?: (id: string) => void
  /** Callback when card is clicked */
  onClick?: (id: string) => void
}

/**
 * Professional project card component
 * Modern design with gradients and better visual hierarchy
 */
export function ProjectCard({
  id,
  title,
  subject,
  description,
  price,
  deadline,
  status,
  supervisorName,
  isUrgent,
  onAccept,
  onClick,
}: ProjectCardProps) {
  const [isAccepting, setIsAccepting] = useState(false)

  /** Calculate time remaining */
  const getTimeRemaining = () => {
    const now = new Date()
    const diff = deadline.getTime() - now.getTime()

    if (diff <= 0) return 'Overdue'

    const hours = Math.floor(diff / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))

    if (hours >= 24) {
      const days = Math.floor(hours / 24)
      return `${days}d ${hours % 24}h`
    }

    return `${hours}h ${minutes}m`
  }

  /** Check if deadline is within 6 hours */
  const isDeadlineSoon = () => {
    const now = new Date()
    const diff = deadline.getTime() - now.getTime()
    return diff > 0 && diff <= 6 * 60 * 60 * 1000
  }

  const timeRemaining = getTimeRemaining()
  const showUrgent = isUrgent || isDeadlineSoon()
  const isOverdue = timeRemaining === 'Overdue'

  /** Handle accept click */
  const handleAccept = async (e: React.MouseEvent) => {
    e.stopPropagation()
    if (!onAccept) return

    setIsAccepting(true)
    try {
      await onAccept(id)
    } finally {
      setIsAccepting(false)
    }
  }

  /** Handle card click */
  const handleClick = () => {
    onClick?.(id)
  }

  /** Get status badge config */
  const getStatusBadge = () => {
    const statusConfig: Record<string, { label: string; className: string }> = {
      paid: { label: '', className: '' },
      assigned: { label: 'Assigned', className: 'bg-cyan-100 text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-400' },
      in_progress: { label: 'In Progress', className: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400' },
      submitted_for_qc: { label: 'Submitted', className: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400' },
      qc_in_progress: { label: 'Under Review', className: 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400' },
      revision_requested: { label: 'Revision Needed', className: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400' },
      in_revision: { label: 'In Revision', className: 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400' },
      completed: { label: 'Completed', className: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' },
      auto_approved: { label: 'Completed', className: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' },
      delivered: { label: 'Delivered', className: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400' },
    }

    const config = statusConfig[status]
    if (!config || !config.label) return null

    return (
      <Badge variant="secondary" className={cn("text-xs font-medium", config.className)}>
        {config.label}
      </Badge>
    )
  }

  return (
    <motion.div
      whileHover={{ y: -4 }}
      whileTap={{ scale: 0.98 }}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
    >
      <Card
        className={cn(
          'cursor-pointer transition-all duration-300 overflow-hidden group',
          'border border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]',
          'hover:shadow-[0_22px_50px_rgba(91,124,255,0.18)] hover:border-[#B8C4FF]'
        )}
        onClick={handleClick}
      >
        {/* Urgency indicator bar */}
        {(showUrgent || status === 'revision_requested') && (
          <div className={cn(
            "h-1 w-full",
            isOverdue ? "bg-[#FF8B6A]" :
            status === 'revision_requested' ? "bg-[#FF8B6A]" :
            "bg-gradient-to-r from-[#FFB39A] to-[#FF8B6A]"
          )} />
        )}

        <CardHeader className="pb-3">
          <div className="flex items-start justify-between gap-3">
            <div className="flex-1 min-w-0 space-y-2">
              {/* Subject badge */}
              <Badge variant="outline" className="text-xs font-normal border-[#DDE5FF] text-[#4F6CF7]">
                {subject}
              </Badge>

              {/* Title */}
              <h3 className="font-semibold text-base leading-tight line-clamp-2 group-hover:text-[#4F6CF7] transition-colors">
                {title}
              </h3>
            </div>

            {/* Urgent indicator */}
            {showUrgent && (
              <div className={cn(
                "flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium shrink-0",
                isOverdue
                  ? "bg-[#FFE7E1] text-[#FF8B6A]"
                  : "bg-[#FFF1EC] text-[#FF8B6A]"
              )}>
                {isOverdue ? (
                  <AlertTriangle className="h-3 w-3" />
                ) : (
                  <Flame className="h-3 w-3 animate-pulse" />
                )}
                <span>{isOverdue ? 'Overdue' : 'Urgent'}</span>
              </div>
            )}
          </div>

          {/* Status badge */}
          <div className="flex items-center gap-2 mt-2">
            {getStatusBadge()}
          </div>
        </CardHeader>

        <CardContent className="pb-3">
          {/* Description */}
          {description && (
            <p className="text-sm text-muted-foreground line-clamp-2 mb-4">
              {description}
            </p>
          )}

          {/* Meta info grid */}
          <div className="grid grid-cols-2 gap-3">
            {/* Price */}
            <div className="flex items-center gap-2 p-2 rounded-lg bg-[#EEF2FF]">
              <IndianRupee className="h-4 w-4 text-[#4F6CF7]" />
              <span className="text-sm font-semibold text-[#3E5BEA]">
                {price.toLocaleString('en-IN')}
              </span>
            </div>

            {/* Deadline */}
            <div className={cn(
              "flex items-center gap-2 p-2 rounded-lg",
              isOverdue
                ? "bg-[#FFE7E1]"
                : showUrgent
                  ? "bg-[#FFF1EC]"
                  : "bg-[#F5F7FF]"
            )}>
              <Clock className={cn(
                "h-4 w-4",
                isOverdue
                  ? "text-[#FF8B6A]"
                  : showUrgent
                    ? "text-[#FF8B6A]"
                    : "text-slate-500"
              )} />
              <span className={cn(
                "text-sm font-medium",
                isOverdue
                  ? "text-[#FF8B6A]"
                  : showUrgent
                    ? "text-[#FF8B6A]"
                    : "text-slate-500"
              )}>
                {timeRemaining}
              </span>
            </div>

            {/* Due date */}
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <Calendar className="h-4 w-4" />
              <span>
                {deadline.toLocaleDateString('en-IN', {
                  day: 'numeric',
                  month: 'short',
                })}
              </span>
            </div>

            {/* Supervisor */}
            {supervisorName && (
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <User className="h-4 w-4" />
                <span className="truncate">{supervisorName}</span>
              </div>
            )}
          </div>
        </CardContent>

        {/* Action footer */}
        {status === 'paid' && onAccept ? (
          <CardFooter className="pt-3 border-t border-white/70">
            <Button
              className="w-full gap-2 rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_14px_28px_rgba(91,124,255,0.25)] hover:opacity-90"
              onClick={handleAccept}
              disabled={isAccepting}
            >
              {isAccepting ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Accepting...
                </>
              ) : (
                <>
                  <CheckCircle2 className="h-4 w-4" />
                  Accept Task
                </>
              )}
            </Button>
          </CardFooter>
        ) : (
          <CardFooter className="pt-3 border-t border-white/70">
            <div className="w-full flex items-center justify-between text-sm">
              <span className="text-slate-500">View details</span>
              <ArrowRight className="h-4 w-4 text-slate-400 group-hover:text-[#4F6CF7] group-hover:translate-x-1 transition-all" />
            </div>
          </CardFooter>
        )}
      </Card>
    </motion.div>
  )
}
