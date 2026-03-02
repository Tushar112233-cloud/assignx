/**
 * @fileoverview Real-time subscription hook for project updates via Socket.IO
 * @module hooks/useProjectSubscription
 */

"use client"

import { useEffect, useRef, useCallback } from 'react'
import { getSocket } from '@/lib/socket/client'
import type { Project } from '@/types/database'

interface UseProjectSubscriptionOptions {
  doerId: string | undefined
  onProjectAssigned?: (project: Project) => void
  onProjectUpdate?: (project: Project) => void
  onStatusChange?: (project: Project, oldStatus: string, newStatus: string) => void
  enabled?: boolean
}

export function useProjectSubscription({
  doerId,
  onProjectAssigned,
  onProjectUpdate,
  onStatusChange,
  enabled = true,
}: UseProjectSubscriptionOptions) {
  const onProjectAssignedRef = useRef(onProjectAssigned)
  onProjectAssignedRef.current = onProjectAssigned
  const onProjectUpdateRef = useRef(onProjectUpdate)
  onProjectUpdateRef.current = onProjectUpdate
  const onStatusChangeRef = useRef(onStatusChange)
  onStatusChangeRef.current = onStatusChange

  useEffect(() => {
    if (!doerId || !enabled) return

    const socket = getSocket()

    const handleProjectUpdate = (data: { project: Project; oldStatus?: string }) => {
      const { project, oldStatus } = data

      if (oldStatus && oldStatus !== project.status) {
        onStatusChangeRef.current?.(project, oldStatus, project.status)
      }

      onProjectUpdateRef.current?.(project)
    }

    const handleProjectAssigned = (project: Project) => {
      onProjectAssignedRef.current?.(project)
      onProjectUpdateRef.current?.(project)
    }

    socket.on(`projects:${doerId}`, handleProjectUpdate)
    socket.on(`projects:assigned:${doerId}`, handleProjectAssigned)

    return () => {
      socket.off(`projects:${doerId}`, handleProjectUpdate)
      socket.off(`projects:assigned:${doerId}`, handleProjectAssigned)
    }
  }, [doerId, enabled])

  return {
    unsubscribe: useCallback(() => {
      if (!doerId) return
      const socket = getSocket()
      socket.off(`projects:${doerId}`)
      socket.off(`projects:assigned:${doerId}`)
    }, [doerId]),
  }
}

export function useNewProjectsSubscription({
  enabled = true,
  onNewProject,
}: {
  enabled?: boolean
  onNewProject?: (project: Project) => void
}) {
  const onNewProjectRef = useRef(onNewProject)
  onNewProjectRef.current = onNewProject

  useEffect(() => {
    if (!enabled) return

    const socket = getSocket()

    const handleNewProject = (project: Project) => {
      if (!project.doer_id) {
        onNewProjectRef.current?.(project)
      }
    }

    socket.on('available_projects', handleNewProject)

    return () => {
      socket.off('available_projects', handleNewProject)
    }
  }, [enabled])
}
