/**
 * @fileoverview Custom hooks for project data management.
 * @module hooks/use-projects
 */

"use client"

import { useEffect, useState, useCallback, useMemo } from "react"
import { createClient, getSessionUser } from "@/lib/supabase/client"
import type {
  Project,
  ProjectWithRelations,
  ProjectStatus
} from "@/types/database"
import type { RealtimeChannel } from "@supabase/supabase-js"

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
  const [retryCount, setRetryCount] = useState(0)

  const fetchProjects = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getSessionUser()

      if (!user) {
        setProjects([])
        setTotalCount(0)
        return
      }

      // Get supervisor ID
      const { data: supervisor, error: supError } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (supError) {
        console.error("[useProjects] Supervisor lookup failed:", supError.message)
        throw new Error(`Supervisor lookup failed: ${supError.message}`)
      }

      if (!supervisor) {
        setProjects([])
        setTotalCount(0)
        return
      }

      // Build query
      let query = supabase
        .from("projects")
        .select(`
          *,
          profiles!projects_user_id_fkey (*),
          subjects (*),
          doers (
            *,
            profiles!profile_id (*)
          )
        `, { count: "exact" })
        .eq("supervisor_id", supervisor.id)
        .order("created_at", { ascending: false })
        .range(offset, offset + limit - 1)

      // Filter by status
      if (status) {
        if (Array.isArray(status)) {
          query = query.in("status", status)
        } else {
          query = query.eq("status", status)
        }
      }

      const { data, error: queryError, count } = await query

      if (queryError) throw queryError

      // Transform null to undefined for type compatibility
      const transformedData = (data || []).map(project => ({
        ...project,
        profiles: project.profiles || undefined,
        subjects: Array.isArray(project.subjects) ? undefined : (project.subjects || undefined),
        doers: project.doers && !Array.isArray(project.doers) ? {
          ...project.doers,
          profiles: project.doers.profiles || undefined,
        } : undefined,
      })) as ProjectWithRelations[]

      setProjects(transformedData)
      setTotalCount(count || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch projects"))
    } finally {
      setIsLoading(false)
    }
  }, [status, limit, offset, retryCount])

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

    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getSessionUser()
      if (!user) throw new Error("Not authenticated")

      const { data: supervisor } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (!supervisor) throw new Error("Supervisor not found")

      const { data, error: queryError } = await supabase
        .from("projects")
        .select(`
          *,
          profiles!projects_user_id_fkey (*),
          subjects (*),
          doers (
            *,
            profiles!profile_id (*)
          ),
          supervisors (
            *,
            profiles!profile_id (*)
          )
        `)
        .eq("id", projectId)
        .eq("supervisor_id", supervisor.id)
        .single()

      if (queryError) throw queryError

      // Transform null to undefined for type compatibility
      const transformedProject = data ? {
        ...data,
        profiles: data.profiles || undefined,
        subjects: data.subjects || undefined,
        doers: data.doers ? {
          ...data.doers,
          profiles: data.doers.profiles || undefined,
        } : undefined,
        supervisors: data.supervisors ? {
          ...data.supervisors,
          profiles: data.supervisors.profiles || undefined,
        } : undefined,
      } : null

      setProject(transformedProject as ProjectWithRelations | null)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch project"))
    } finally {
      setIsLoading(false)
    }
  }, [projectId])

  const updateProject = useCallback(async (data: Partial<Project>) => {
    if (!projectId) return

    const supabase = createClient()
    const user = await getSessionUser()
    if (!user) throw new Error("Not authenticated")

    const { data: supervisor } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .single()

    if (!supervisor) throw new Error("Supervisor not found")

    const { error: updateError } = await supabase
      .from("projects")
      .update({ ...data, updated_at: new Date().toISOString() })
      .eq("id", projectId)
      .eq("supervisor_id", supervisor.id)

    if (updateError) throw updateError
    await fetchProject()
  }, [projectId, fetchProject])

  const updateStatus = useCallback(async (status: ProjectStatus) => {
    await updateProject({ status })
  }, [updateProject])

  const assignDoer = useCallback(async (doerId: string) => {
    await updateProject({ doer_id: doerId, status: "assigned" })
  }, [updateProject])

  const submitQuote = useCallback(async (quote: number, doerPayout: number) => {
    const platformFee = quote * 0.20 // 20% platform fee
    const supervisorCommission = quote * 0.15 // 15% supervisor commission

    await updateProject({
      user_quote: quote,
      doer_payout: doerPayout,
      supervisor_commission: supervisorCommission,
      platform_fee: platformFee,
      status: "quoted",
      status_updated_at: new Date().toISOString(),
    })
  }, [updateProject])

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
  completed: ["completed", "auto_approved", "delivered"] as ProjectStatus[],
  cancelled: ["cancelled", "refunded"] as ProjectStatus[],
}

/**
 * Claim a project - assign it to the current supervisor.
 * Uses browser client directly (RLS is disabled on projects table).
 * @param projectId - The project UUID to claim
 * @returns Promise that resolves when the project is claimed
 */
export async function claimProject(projectId: string): Promise<void> {
  const supabase = createClient()

  const user = await getSessionUser()
  if (!user) throw new Error("Not authenticated")

  const { data: supervisor } = await supabase
    .from("supervisors")
    .select("id")
    .eq("profile_id", user.id)
    .single()

  if (!supervisor) throw new Error("Supervisor not found")

  // Get project details for notification
  const { data: project } = await supabase
    .from("projects")
    .select("project_number, user_id")
    .eq("id", projectId)
    .single()

  const { error } = await supabase
    .from("projects")
    .update({
      supervisor_id: supervisor.id,
      status: "analyzing",
      updated_at: new Date().toISOString(),
    })
    .eq("id", projectId)
    .is("supervisor_id", null)

  if (error) throw new Error("Failed to claim project")

  // Create notification for the supervisor
  await supabase.from("notifications").insert({
    profile_id: user.id,
    notification_type: "project_assigned",
    title: "Project Claimed",
    body: `You claimed project${project?.project_number ? ` ${project.project_number}` : ""}. Review the requirements and submit a quote.`,
    reference_type: "project",
    reference_id: projectId,
    action_url: `/projects/${projectId}`,
    target_role: "supervisor",
  })
}

/**
 * Hook to fetch NEW/UNASSIGNED projects that need a supervisor.
 * Uses browser client directly (RLS is disabled on projects table).
 */
export function useNewRequests() {
  const [projects, setProjects] = useState<ProjectWithRelations[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchNewRequests = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getSessionUser()
      if (!user) {
        setProjects([])
        return
      }

      // Fetch projects with no supervisor assigned (new requests)
      const { data, error: queryError } = await supabase
        .from("projects")
        .select(`
          *,
          profiles!projects_user_id_fkey (*),
          subjects (*),
          doers (
            *,
            profiles!profile_id (*)
          )
        `)
        .is("supervisor_id", null)
        .in("status", ["submitted", "analyzing"])
        .order("created_at", { ascending: false })

      if (queryError) throw queryError

      // Transform null to undefined for type compatibility
      const transformedData = (data || []).map(project => ({
        ...project,
        profiles: project.profiles || undefined,
        subjects: Array.isArray(project.subjects) ? undefined : (project.subjects || undefined),
        doers: project.doers && !Array.isArray(project.doers) ? {
          ...project.doers,
          profiles: project.doers.profiles || undefined,
        } : undefined,
      })) as ProjectWithRelations[]

      setProjects(transformedData)
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
 * These are projects where supervisor_id = current supervisor, status = 'paid', and doer_id IS NULL.
 */
export function useReadyToAssign() {
  const [projects, setProjects] = useState<ProjectWithRelations[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchReadyToAssign = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getSessionUser()

      if (!user) {
        setProjects([])
        return
      }

      // Get supervisor ID
      const { data: supervisor, error: supError } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (supError) {
        console.error("[useReadyToAssign] Supervisor lookup failed:", supError.message)
        throw new Error(`Supervisor lookup failed: ${supError.message}`)
      }

      if (!supervisor) {
        setProjects([])
        return
      }

      // Fetch projects assigned to this supervisor that are paid and need doer assignment
      const { data, error: queryError } = await supabase
        .from("projects")
        .select(`
          *,
          profiles!projects_user_id_fkey (*),
          subjects (*),
          doers (
            *,
            profiles!profile_id (*)
          )
        `)
        .eq("supervisor_id", supervisor.id)
        .eq("status", "paid")
        .is("doer_id", null)
        .order("created_at", { ascending: false })

      if (queryError) throw queryError

      // Transform null to undefined for type compatibility
      const transformedData = (data || []).map(project => ({
        ...project,
        profiles: project.profiles || undefined,
        subjects: Array.isArray(project.subjects) ? undefined : (project.subjects || undefined),
        doers: project.doers && !Array.isArray(project.doers) ? {
          ...project.doers,
          profiles: project.doers.profiles || undefined,
        } : undefined,
      })) as ProjectWithRelations[]

      setProjects(transformedData)
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
      // NEW: Unassigned projects needing supervisor
      needsQuote: newRequests,
      // NEW: Projects paid and needing doer assignment
      readyToAssign: readyProjects,
      // Projects assigned to this supervisor that are in progress
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

  // Real-time subscription for project updates
  useEffect(() => {
    const supabase = createClient()
    let supervisorChannel: RealtimeChannel | null = null
    let newRequestsChannel: RealtimeChannel | null = null
    let cancelled = false

    const setupSubscriptions = async () => {
      const user = await getSessionUser()
      if (!user || cancelled) return

      const { data: supervisor } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (!supervisor || cancelled) return

      // Subscribe to this supervisor's projects
      supervisorChannel = supabase
        .channel(`supervisor_projects_${supervisor.id}`)
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'projects',
            filter: `supervisor_id=eq.${supervisor.id}`,
          },
          () => {
            // Refetch all project data on any change
            refetch()
          }
        )
        .subscribe()

      // Subscribe to new unassigned projects
      newRequestsChannel = supabase
        .channel('new_project_requests')
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'projects',
          },
          (payload) => {
            const project = payload.new as { supervisor_id: string | null; status: string }
            // Only refetch if it's a new unassigned project
            if (!project.supervisor_id && ['submitted', 'analyzing'].includes(project.status)) {
              refetch()
            }
          }
        )
        .subscribe()
    }

    setupSubscriptions().catch(() => {})

    return () => {
      cancelled = true
      if (supervisorChannel) supabase.removeChannel(supervisorChannel)
      if (newRequestsChannel) supabase.removeChannel(newRequestsChannel)
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
