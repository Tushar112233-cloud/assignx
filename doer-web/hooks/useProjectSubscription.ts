/**
 * @fileoverview Real-time subscription hook for project updates
 * @module hooks/useProjectSubscription
 */

"use client"

import { useEffect, useRef, useCallback, useMemo } from 'react'
import { createClient } from '@/lib/supabase/client'
import type { RealtimeChannel } from '@supabase/supabase-js'
import type { Project } from '@/types/database'

interface UseProjectSubscriptionOptions {
  /** The doer ID to subscribe to project updates for */
  doerId: string | undefined
  /** Callback when a project is assigned to this doer */
  onProjectAssigned?: (project: Project) => void
  /** Callback when any project update occurs */
  onProjectUpdate?: (project: Project) => void
  /** Callback when project status changes */
  onStatusChange?: (project: Project, oldStatus: string, newStatus: string) => void
  /** Whether the subscription is enabled */
  enabled?: boolean
}

/**
 * Hook to subscribe to real-time project updates for a doer.
 * Uses refs for callbacks to prevent subscription recreation on every render.
 */
export function useProjectSubscription({
  doerId,
  onProjectAssigned,
  onProjectUpdate,
  onStatusChange,
  enabled = true,
}: UseProjectSubscriptionOptions) {
  const channelRef = useRef<RealtimeChannel | null>(null)
  const previousProjectsRef = useRef<Map<string, Project>>(new Map())

  // Store callbacks in refs to prevent effect re-runs
  const onProjectAssignedRef = useRef(onProjectAssigned)
  onProjectAssignedRef.current = onProjectAssigned
  const onProjectUpdateRef = useRef(onProjectUpdate)
  onProjectUpdateRef.current = onProjectUpdate
  const onStatusChangeRef = useRef(onStatusChange)
  onStatusChangeRef.current = onStatusChange

  const supabase = useMemo(() => createClient(), [])

  useEffect(() => {
    if (!doerId || !enabled) {
      return
    }

    // Create channel for this doer's project updates
    const channel = supabase
      .channel(`doer_projects_${doerId}`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'projects',
          filter: `doer_id=eq.${doerId}`,
        },
        (payload) => {
          const { eventType, new: newProject, old: oldProject } = payload as unknown as {
            eventType: 'INSERT' | 'UPDATE' | 'DELETE'
            new: Project
            old: Partial<Project>
          }

          if (eventType === 'UPDATE') {
            if (!oldProject.doer_id && newProject.doer_id === doerId) {
              onProjectAssignedRef.current?.(newProject)
            }
            if (oldProject.status && oldProject.status !== newProject.status) {
              onStatusChangeRef.current?.(newProject, oldProject.status, newProject.status)
            }
            onProjectUpdateRef.current?.(newProject)
          } else if (eventType === 'INSERT' && newProject.doer_id === doerId) {
            onProjectAssignedRef.current?.(newProject)
            onProjectUpdateRef.current?.(newProject)
          }

          previousProjectsRef.current.set(newProject.id, newProject)
        }
      )
      .subscribe()

    channelRef.current = channel

    return () => {
      if (channelRef.current) {
        channelRef.current.unsubscribe()
        channelRef.current = null
      }
    }
  }, [doerId, enabled, supabase])

  return {
    unsubscribe: useCallback(() => {
      if (channelRef.current) {
        channelRef.current.unsubscribe()
        channelRef.current = null
      }
    }, []),
  }
}

/**
 * Hook to subscribe to NEW project assignments (for pool/available projects).
 * Uses refs for callbacks to prevent subscription recreation on every render.
 */
export function useNewProjectsSubscription({
  enabled = true,
  onNewProject,
}: {
  enabled?: boolean
  onNewProject?: (project: Project) => void
}) {
  const channelRef = useRef<RealtimeChannel | null>(null)
  const onNewProjectRef = useRef(onNewProject)
  onNewProjectRef.current = onNewProject

  const supabase = useMemo(() => createClient(), [])

  useEffect(() => {
    if (!enabled) return

    const channel = supabase
      .channel('available_projects')
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'projects',
          filter: 'status=eq.paid',
        },
        (payload) => {
          const project = payload.new as Project
          if (!project.doer_id) {
            onNewProjectRef.current?.(project)
          }
        }
      )
      .subscribe()

    channelRef.current = channel

    return () => {
      channelRef.current?.unsubscribe()
      channelRef.current = null
    }
  }, [enabled, supabase])
}
