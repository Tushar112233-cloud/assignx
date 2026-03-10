'use client'

import { motion, AnimatePresence } from 'framer-motion'
import { ClipboardList, AlertTriangle } from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { ProjectCard } from './ProjectCard'
import type { Project } from './TaskPoolList'

interface AssignedTaskListProps {
  /** List of assigned projects */
  projects: Project[]
  /** Whether data is loading */
  isLoading?: boolean
  /** Callback when a project card is clicked */
  onProjectClick?: (projectId: string) => void
}

/**
 * Assigned task list component
 * Shows tasks specifically assigned by supervisor
 */
export function AssignedTaskList({
  projects,
  isLoading = false,
  onProjectClick,
}: AssignedTaskListProps) {
  /** Check for tasks needing revision */
  const revisionTasks = projects.filter(p => p.status === 'revision_requested')
  const hasRevisions = revisionTasks.length > 0

  /** Sort projects by priority (revisions first, then by deadline) */
  const sortedProjects = [...projects].sort((a, b) => {
    // Revision requested tasks first
    if (a.status === 'revision_requested' && b.status !== 'revision_requested') return -1
    if (b.status === 'revision_requested' && a.status !== 'revision_requested') return 1
    // Then by deadline
    return a.deadline.getTime() - b.deadline.getTime()
  })

  return (
    <div className="space-y-4">
      {/* Revision alert */}
      {hasRevisions && (
        <Alert variant="destructive">
          <AlertTriangle className="h-4 w-4" />
          <AlertTitle>Revision Requested</AlertTitle>
          <AlertDescription>
            You have {revisionTasks.length} task{revisionTasks.length > 1 ? 's' : ''} that
            require{revisionTasks.length === 1 ? 's' : ''} revision. Please address the feedback promptly.
          </AlertDescription>
        </Alert>
      )}

      {/* Tasks count */}
      <p className="text-sm text-muted-foreground">
        {projects.length} assigned task{projects.length !== 1 ? 's' : ''}
      </p>

      {/* Project list */}
      <AnimatePresence mode="popLayout">
        {sortedProjects.length > 0 ? (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {sortedProjects.map((project, index) => (
              <motion.div
                key={project.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95 }}
                transition={{ delay: index * 0.05 }}
              >
                <ProjectCard
                  {...project}
                  onClick={onProjectClick}
                />
              </motion.div>
            ))}
          </div>
        ) : (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white/60 py-10 text-center"
          >
            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#EFEBFF] mb-3">
              <ClipboardList className="h-5 w-5 text-[#7C3AED]" />
            </div>
            <h3 className="font-semibold text-sm text-slate-700">No assigned tasks yet</h3>
            <p className="text-xs text-slate-400 mt-1 max-w-[260px]">
              Your supervisor will assign tasks here. In the meantime, check the Open Pool for available work.
            </p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
