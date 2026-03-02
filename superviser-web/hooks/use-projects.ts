/**
 * @fileoverview Custom hooks for project data management.
 * Uses Express API + Socket.IO instead of Supabase.
 * @module hooks/use-projects
 */

"use client"

import { useEffect, useState, useCallback, useMemo } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { getSocket } from "@/lib/socket/client"
import type {
  Project,
  ProjectWithRelations,
  ProjectStatus
} from "@/types/database"

interface UseProjectsOptions {
  status?: ProjectStatus | ProjectStatus[]
  limit?: number
  offset?: number
}

interface UseProjectsReturn {
  projects: ProjectWithRelations[]
  isLoading: boolean
  error: Error | null
  totalCount: number
  refetch: () => Promise<void>
}

export function useProjects(options: UseProjectsOptions = {}): UseProjectsReturn {
  const { status, limit = 50, offset = 0 } = options
  const [projects, setProjects] = useState<ProjectWithRelations[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [totalCount, setTotalCount] = useState(0)

  const fetchProjects = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const user = getStoredUser()
      if (!user) {
        setProjects([])
        setTotalCount(0)
        return
      }

      const params = new URLSearchParams()
      params.set("supervisorId", "me")
      params.set("limit", String(limit))
      params.set("offset", String(offset))

      if (status) {
        const statuses = Array.isArray(status) ? status.join(",") : status
        params.set("status", statuses)
      }

      const data = await apiFetch<{ projects: ProjectWithRelations[]; total: number }>(
        `/api/projects?${params.toString()}`
      )

      setProjects(data.projects || [])
      setTotalCount(data.total || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch projects"))
    } finally {
      setIsLoading(false)
    }
  }, [status, limit, offset])

  useEffect(() => {
    fetchProjects()
  }, [fetchProjects])

  return {
    projects,
    isLoading,
    error,
    totalCount,
    refetch: fetchProjects,
  }
}

interface UseProjectReturn {
  project: ProjectWithRelations | null
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
  updateProject: (data: Partial<Project>) => Promise<void>
  updateStatus: (status: ProjectStatus) => Promise<void>
  assignDoer: (doerId: string) => Promise<void>
  submitQuote: (quote: number, doerPayout: number) => Promise<void>
}

export function useProject(projectId: string): UseProjectReturn {
  const [project, setProject] = useState<ProjectWithRelations | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchProject = useCallback(async () => {
    if (!projectId) return

    try {
      setIsLoading(true)
      setError(null)

      const data = await apiFetch<{ project: ProjectWithRelations } | ProjectWithRelations>(`/api/projects/${projectId}`)
      // API wraps response in { project: ... }
      setProject((data as { project: ProjectWithRelations }).project || data as ProjectWithRelations)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch project"))
    } finally {
      setIsLoading(false)
    }
  }, [projectId])

  const updateProject = useCallback(async (data: Partial<Project>) => {
    if (!projectId) return

    await apiFetch(`/api/projects/${projectId}`, {
      method: "PUT",
      body: JSON.stringify(data),
    })
    await fetchProject()
  }, [projectId, fetchProject])

  const updateStatus = useCallback(async (status: ProjectStatus) => {
    await apiFetch(`/api/projects/${projectId}/status`, {
      method: "PUT",
      body: JSON.stringify({ status }),
    })
    await fetchProject()
  }, [projectId, fetchProject])

  const assignDoer = useCallback(async (doerId: string) => {
    await apiFetch(`/api/projects/${projectId}/assign`, {
      method: "PUT",
      body: JSON.stringify({ doerId }),
    })
    await fetchProject()
  }, [projectId, fetchProject])

  const submitQuote = useCallback(async (quote: number, doerPayout: number) => {
    const platformFee = quote * 0.20
    const supervisorCommission = quote * 0.15

    await apiFetch(`/api/projects/${projectId}`, {
      method: "PUT",
      body: JSON.stringify({
        user_quote: quote,
        doer_payout: doerPayout,
        supervisor_commission: supervisorCommission,
        platform_fee: platformFee,
        status: "quoted",
        status_updated_at: new Date().toISOString(),
      }),
    })
    await fetchProject()
  }, [projectId, fetchProject])

  useEffect(() => {
    fetchProject()
  }, [fetchProject])

  return {
    project,
    isLoading,
    error,
    refetch: fetchProject,
    updateProject,
    updateStatus,
    assignDoer,
    submitQuote,
  }
}

// Project status groups for filtering
export const PROJECT_STATUS_GROUPS = {
  needsQuote: ["submitted", "analyzing"] as ProjectStatus[],
  readyToAssign: ["paid"] as ProjectStatus[],
  inProgress: [
    "analyzing",
    "quoted",
    "payment_pending",
    "assigned",
    "in_progress",
    "submitted_for_qc",
    "qc_in_progress",
    "revision_requested",
    "in_revision"
  ] as ProjectStatus[],
  needsQC: ["submitted_for_qc"] as ProjectStatus[],
  completed: ["completed", "auto_approved", "delivered", "qc_approved"] as ProjectStatus[],
  cancelled: ["cancelled", "refunded"] as ProjectStatus[],
}

/**
 * Claim a project - assign it to the current supervisor.
 */
export async function claimProject(projectId: string): Promise<void> {
  await apiFetch(`/api/projects/${projectId}/claim`, {
    method: "POST",
  })
}

/**
 * Hook to fetch NEW/UNASSIGNED projects that need a supervisor.
 */
export function useNewRequests() {
  const [projects, setProjects] = useState<ProjectWithRelations[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchNewRequests = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const user = getStoredUser()
      if (!user) {
        setProjects([])
        return
      }

      const data = await apiFetch<{ projects: ProjectWithRelations[] }>(
        "/api/projects?unassigned=true&status=submitted,analyzing"
      )

      setProjects(data.projects || [])
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch new requests"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchNewRequests()
  }, [fetchNewRequests])

  return {
    newRequests: projects,
    isLoading,
    error,
    refetch: fetchNewRequests,
  }
}

/**
 * Hook to fetch projects that are PAID and ready to assign to a doer.
 */
export function useReadyToAssign() {
  const [projects, setProjects] = useState<ProjectWithRelations[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchReadyToAssign = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const user = getStoredUser()
      if (!user) {
        setProjects([])
        return
      }

      const data = await apiFetch<{ projects: ProjectWithRelations[] }>(
        "/api/projects?supervisorId=me&status=paid&needsDoer=true"
      )

      setProjects(data.projects || [])
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch ready-to-assign projects"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchReadyToAssign()
  }, [fetchReadyToAssign])

  return {
    readyToAssign: projects,
    isLoading,
    error,
    refetch: fetchReadyToAssign,
  }
}

export function useProjectsByStatus() {
  const { projects: allProjects, isLoading: projectsLoading, error: projectsError, refetch: refetchProjects } = useProjects()
  const { newRequests, isLoading: newReqLoading, error: newReqError, refetch: refetchNewReq } = useNewRequests()
  const { readyToAssign: readyProjects, isLoading: readyLoading, error: readyError, refetch: refetchReady } = useReadyToAssign()

  const isLoading = projectsLoading || newReqLoading || readyLoading
  const error = projectsError || newReqError || readyError

  const refetch = useCallback(async () => {
    await Promise.all([refetchProjects(), refetchNewReq(), refetchReady()])
  }, [refetchProjects, refetchNewReq, refetchReady])

  const groupedProjects = useMemo(() => {
    return {
      needsQuote: newRequests,
      readyToAssign: readyProjects,
      inProgress: allProjects.filter(p =>
        PROJECT_STATUS_GROUPS.inProgress.includes(p.status as ProjectStatus)
      ),
      needsQC: allProjects.filter(p =>
        PROJECT_STATUS_GROUPS.needsQC.includes(p.status as ProjectStatus)
      ),
      completed: allProjects.filter(p =>
        PROJECT_STATUS_GROUPS.completed.includes(p.status as ProjectStatus)
      ),
      cancelled: allProjects.filter(p =>
        PROJECT_STATUS_GROUPS.cancelled.includes(p.status as ProjectStatus)
      ),
    }
  }, [allProjects, newRequests, readyProjects])

  // Real-time subscription via Socket.IO
  useEffect(() => {
    const user = getStoredUser()
    if (!user) return

    let mounted = true

    try {
      const socket = getSocket()

      const handleProjectUpdate = () => {
        if (mounted) refetch()
      }

      socket.on(`projects:${user.id}`, handleProjectUpdate)
      socket.on("projects:new", handleProjectUpdate)

      return () => {
        mounted = false
        socket.off(`projects:${user.id}`, handleProjectUpdate)
        socket.off("projects:new", handleProjectUpdate)
      }
    } catch {
      // Socket not available
      return () => { mounted = false }
    }
  }, [refetch])

  return {
    ...groupedProjects,
    allProjects,
    isLoading,
    error,
    refetch,
  }
}
