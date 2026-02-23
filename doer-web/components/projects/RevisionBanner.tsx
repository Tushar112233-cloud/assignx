'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  AlertTriangle,
  ChevronDown,
  ChevronUp,
  Clock,
  MessageSquare,
  FileEdit,
} from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import type { ProjectRevision } from '@/types/database'

interface RevisionBannerProps {
  /** Revision details */
  revision: ProjectRevision
  /** Supervisor name who requested revision */
  supervisorName?: string
  /** Callback when start revision is clicked */
  onStartRevision?: () => void
  /** Callback when view feedback is clicked */
  onViewFeedback?: () => void
  /** Whether revision is being worked on */
  isWorking?: boolean
  /** Additional class name */
  className?: string
}

/**
 * Revision requested banner component
 * Shows when supervisor rejects work and requests changes
 */
export function RevisionBanner({
  revision,
  supervisorName,
  onStartRevision,
  onViewFeedback,
  isWorking = false,
  className,
}: RevisionBannerProps) {
  const [isExpanded, setIsExpanded] = useState(false)

  /** Format timestamp */
  const formatDate = (timestamp: string) => {
    const date = new Date(timestamp)
    return date.toLocaleDateString('en-IN', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  /** Get priority color */
  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'bg-red-500/10 text-red-500 border-red-500/20'
      case 'medium':
        return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20'
      case 'low':
        return 'bg-blue-500/10 text-blue-500 border-blue-500/20'
      default:
        return 'bg-muted text-muted-foreground'
    }
  }

  /** Get status badge */
  const getStatusBadge = () => {
    switch (revision.status) {
      case 'pending':
        return (
          <Badge variant="destructive" className="gap-1">
            <AlertTriangle className="h-3 w-3" />
            Action Required
          </Badge>
        )
      case 'in_progress':
        return (
          <Badge variant="default" className="gap-1">
            <FileEdit className="h-3 w-3" />
            In Progress
          </Badge>
        )
      case 'completed':
        return (
          <Badge variant="secondary" className="gap-1 bg-green-500/10 text-green-600">
            Completed
          </Badge>
        )
      default:
        return null
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      className={className}
    >
      <Alert
        variant="destructive"
        className={cn(
          'border-2',
          revision.status === 'in_progress' && 'border-primary bg-primary/5',
          revision.status === 'completed' && 'border-green-500 bg-green-50'
        )}
      >
        <AlertTriangle className="h-5 w-5" />

        <div className="flex-1">
          <div className="flex items-center justify-between">
            <AlertTitle className="flex items-center gap-2">
              Revision Requested
              {getStatusBadge()}
            </AlertTitle>

            <Button
              variant="ghost"
              size="sm"
              onClick={() => setIsExpanded(!isExpanded)}
              className="h-8 px-2"
            >
              {isExpanded ? (
                <ChevronUp className="h-4 w-4" />
              ) : (
                <ChevronDown className="h-4 w-4" />
              )}
            </Button>
          </div>

          <AlertDescription className="mt-2">
            <div className="flex items-center gap-4 text-sm">
              {supervisorName && (
                <span className="flex items-center gap-1">
                  <MessageSquare className="h-4 w-4" />
                  {supervisorName}
                </span>
              )}
              <span className="flex items-center gap-1">
                <Clock className="h-4 w-4" />
                {formatDate(revision.created_at)}
              </span>
              <Badge
                variant="outline"
                className={cn('capitalize', getPriorityColor(revision.priority))}
              >
                {revision.priority} Priority
              </Badge>
            </div>

            <p className="mt-2 font-medium">{revision.reason}</p>
          </AlertDescription>

          {/* Expanded details */}
          <AnimatePresence>
            {isExpanded && revision.details && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                className="overflow-hidden"
              >
                <div className="mt-4 p-4 bg-background rounded-lg border">
                  <h4 className="font-medium mb-2">Detailed Feedback</h4>
                  <p className="text-sm text-muted-foreground whitespace-pre-wrap">
                    {revision.details}
                  </p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Action buttons */}
          {revision.status === 'pending' && (
            <div className="flex items-center gap-2 mt-4">
              <Button
                onClick={onStartRevision}
                disabled={isWorking}
                className="gap-2"
              >
                <FileEdit className="h-4 w-4" />
                Start Revision
              </Button>

              {onViewFeedback && (
                <Button variant="outline" onClick={onViewFeedback}>
                  View Full Feedback
                </Button>
              )}
            </div>
          )}

          {revision.status === 'in_progress' && (
            <p className="mt-4 text-sm text-muted-foreground">
              You are currently working on this revision. Submit your updated work when ready.
            </p>
          )}
        </div>
      </Alert>
    </motion.div>
  )
}

/**
 * Multiple revisions list component
 * Shows all revisions for a project
 */
interface RevisionListProps {
  revisions: ProjectRevision[]
  supervisorName?: string
  onStartRevision?: (revisionId: string) => void
  onViewFeedback?: (revisionId: string) => void
  className?: string
}

export function RevisionList({
  revisions,
  supervisorName,
  onStartRevision,
  onViewFeedback,
  className,
}: RevisionListProps) {
  if (revisions.length === 0) return null

  // Get the most recent pending revision
  const pendingRevision = revisions.find((r) => r.status === 'pending')
  const otherRevisions = revisions.filter((r) => r.id !== pendingRevision?.id)

  return (
    <div className={cn('space-y-4', className)}>
      {/* Show pending revision prominently */}
      {pendingRevision && (
        <RevisionBanner
          revision={pendingRevision}
          supervisorName={supervisorName}
          onStartRevision={() => onStartRevision?.(pendingRevision.id)}
          onViewFeedback={() => onViewFeedback?.(pendingRevision.id)}
        />
      )}

      {/* Show history of other revisions */}
      {otherRevisions.length > 0 && (
        <div className="space-y-2">
          <h4 className="text-sm font-medium text-muted-foreground">
            Previous Revisions ({otherRevisions.length})
          </h4>
          {otherRevisions.map((revision) => (
            <div
              key={revision.id}
              className="p-3 rounded-lg border bg-muted/30 text-sm"
            >
              <div className="flex items-center justify-between">
                <span className="font-medium">{revision.reason}</span>
                <Badge
                  variant="outline"
                  className={cn(
                    revision.status === 'completed' &&
                      'bg-green-500/10 text-green-600 border-green-500/20',
                    revision.status === 'cancelled' &&
                      'bg-muted text-muted-foreground'
                  )}
                >
                  {revision.status}
                </Badge>
              </div>
              <p className="text-xs text-muted-foreground mt-1">
                {new Date(revision.created_at).toLocaleDateString('en-IN', {
                  day: 'numeric',
                  month: 'short',
                  year: 'numeric',
                })}
                {revision.completed_at &&
                  ` - Completed ${new Date(revision.completed_at).toLocaleDateString('en-IN', {
                    day: 'numeric',
                    month: 'short',
                  })}`}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
