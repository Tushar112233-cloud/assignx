/**
 * @fileoverview Custom hooks for fetching users (clients) associated with supervisor's projects.
 * @module hooks/use-users
 */

"use client"

import { useEffect, useState, useCallback, useMemo } from "react"
import { createClient, getAuthUser } from "@/lib/supabase/client"

export interface UserWithStats {
  id: string
  full_name: string
  email: string
  phone?: string
  avatar_url?: string
  college?: string
  course?: string
  year?: string
  joined_at: string
  last_active_at?: string
  is_verified: boolean
  total_projects: number
  active_projects: number
  completed_projects: number
  total_spent: number
  average_project_value: number
}

export interface UserProject {
  id: string
  project_number: string
  title: string
  subject: string
  service_type: string
  status: string
  deadline: string
  created_at: string
  completed_at?: string
  user_amount: number
  doer_name?: string
  supervisor_name?: string
  rating?: number
}

interface UseUsersOptions {
  limit?: number
  offset?: number
}

interface UseUsersReturn {
  users: UserWithStats[]
  isLoading: boolean
  error: Error | null
  totalCount: number
  refetch: () => Promise<void>
}

export function useUsers(options: UseUsersOptions = {}): UseUsersReturn {
  const { limit = 100, offset = 0 } = options
  const [users, setUsers] = useState<UserWithStats[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [totalCount, setTotalCount] = useState(0)

  const fetchUsers = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getAuthUser()
      if (!user) throw new Error("Not authenticated")

      // Get supervisor ID
      const { data: supervisor } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (!supervisor) {
        setUsers([])
        return
      }

      // Get all unique users from supervisor's projects with their project stats
      const { data: projectsData, error: projectsError } = await supabase
        .from("projects")
        .select(`
          user_id,
          status,
          user_quote,
          completed_at,
          profiles!projects_user_id_fkey (
            id,
            full_name,
            email,
            phone,
            avatar_url,
            city,
            state,
            is_active,
            last_login_at,
            created_at
          )
        `)
        .eq("supervisor_id", supervisor.id)

      if (projectsError) throw projectsError

      // Aggregate user stats from projects
      const userMap = new Map<string, {
        profile: {
          id: string
          full_name: string
          email: string
          phone?: string
          avatar_url?: string
          city?: string
          state?: string
          is_active?: boolean
          last_login_at?: string
          created_at?: string
        }
        projects: Array<{
          status: string
          user_quote: number | null
          completed_at: string | null
        }>
      }>()

      projectsData?.forEach((project) => {
        if (!project.profiles) return

        const profile = project.profiles as {
          id: string
          full_name: string
          email: string
          phone?: string
          avatar_url?: string
          city?: string
          state?: string
          is_active?: boolean
          last_login_at?: string
          created_at?: string
        }

        if (!userMap.has(profile.id)) {
          userMap.set(profile.id, {
            profile,
            projects: []
          })
        }

        userMap.get(profile.id)!.projects.push({
          status: project.status,
          user_quote: project.user_quote,
          completed_at: project.completed_at
        })
      })

      // Transform to UserWithStats
      const usersWithStats: UserWithStats[] = Array.from(userMap.values()).map(({ profile, projects }) => {
        const completedStatuses = ["completed", "auto_approved", "delivered"]
        const activeStatuses = ["submitted", "analyzing", "quoted", "paid", "assigned", "in_progress", "submitted_for_qc", "qc_in_progress", "revision_requested", "in_revision"]

        const completedProjects = projects.filter(p => completedStatuses.includes(p.status))
        const activeProjects = projects.filter(p => activeStatuses.includes(p.status))
        const totalSpent = projects
          .filter(p => completedStatuses.includes(p.status) && p.user_quote)
          .reduce((sum, p) => sum + (p.user_quote || 0), 0)

        return {
          id: profile.id,
          full_name: profile.full_name || "Unknown User",
          email: profile.email || "",
          phone: profile.phone,
          avatar_url: profile.avatar_url,
          college: profile.city, // Using city as college for now
          course: profile.state, // Using state as course for now
          year: undefined,
          joined_at: profile.created_at || new Date().toISOString(),
          last_active_at: profile.last_login_at,
          is_verified: profile.is_active || false,
          total_projects: projects.length,
          active_projects: activeProjects.length,
          completed_projects: completedProjects.length,
          total_spent: totalSpent,
          average_project_value: completedProjects.length > 0
            ? totalSpent / completedProjects.length
            : 0,
        }
      })

      // Sort by most recent activity
      usersWithStats.sort((a, b) => {
        const dateA = a.last_active_at ? new Date(a.last_active_at).getTime() : 0
        const dateB = b.last_active_at ? new Date(b.last_active_at).getTime() : 0
        return dateB - dateA
      })

      // Apply pagination
      const paginatedUsers = usersWithStats.slice(offset, offset + limit)

      setUsers(paginatedUsers)
      setTotalCount(usersWithStats.length)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch users"))
    } finally {
      setIsLoading(false)
    }
  }, [limit, offset])

  useEffect(() => {
    fetchUsers()
  }, [fetchUsers])

  return {
    users,
    isLoading,
    error,
    totalCount,
    refetch: fetchUsers,
  }
}

interface UseUserProjectsOptions {
  userId: string
  limit?: number
}

interface UseUserProjectsReturn {
  projects: UserProject[]
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
}

export function useUserProjects(options: UseUserProjectsOptions): UseUserProjectsReturn {
  const { userId, limit = 50 } = options
  const [projects, setProjects] = useState<UserProject[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchProjects = useCallback(async () => {
    if (!userId) {
      setProjects([])
      setIsLoading(false)
      return
    }

    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      const user = await getAuthUser()
      if (!user) throw new Error("Not authenticated")

      // Get supervisor ID
      const { data: supervisor } = await supabase
        .from("supervisors")
        .select("id, profiles!profile_id (full_name)")
        .eq("profile_id", user.id)
        .single()

      if (!supervisor) {
        setProjects([])
        return
      }

      // Fetch projects for this user under this supervisor
      const { data: projectsData, error: projectsError } = await supabase
        .from("projects")
        .select(`
          id,
          project_number,
          title,
          service_type,
          status,
          deadline,
          created_at,
          completed_at,
          user_quote,
          subjects (name),
          doers (
            profiles!profile_id (full_name)
          ),
          doer_reviews (
            overall_rating
          )
        `)
        .eq("supervisor_id", supervisor.id)
        .eq("user_id", userId)
        .order("created_at", { ascending: false })
        .limit(limit)

      if (projectsError) throw projectsError

      const supervisorName = (supervisor.profiles as { full_name?: string })?.full_name

      const transformedProjects: UserProject[] = (projectsData || []).map((project) => {
        // Get the first review's overall rating if available
        const reviews = project.doer_reviews as Array<{ overall_rating?: number }> | null
        const rating = reviews && reviews.length > 0 ? reviews[0].overall_rating : undefined

        return {
          id: project.id,
          project_number: project.project_number || "",
          title: project.title || "",
          subject: (project.subjects as { name?: string })?.name || "General",
          service_type: project.service_type || "new_project",
          status: project.status || "submitted",
          deadline: project.deadline || new Date().toISOString(),
          created_at: project.created_at || new Date().toISOString(),
          completed_at: project.completed_at ?? undefined,
          user_amount: project.user_quote || 0,
          doer_name: (project.doers as { profiles?: { full_name?: string } })?.profiles?.full_name,
          supervisor_name: supervisorName,
          rating,
        }
      })

      setProjects(transformedProjects)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch user projects"))
    } finally {
      setIsLoading(false)
    }
  }, [userId, limit])

  useEffect(() => {
    fetchProjects()
  }, [fetchProjects])

  return {
    projects,
    isLoading,
    error,
    refetch: fetchProjects,
  }
}

interface UseUserStatsReturn {
  stats: {
    total: number
    active: number
    inactive: number
    totalSpent: number
  }
  isLoading: boolean
}

export function useUserStats(users: UserWithStats[]): UseUserStatsReturn {
  // useState with initializer is pure (runs once)
  const [thirtyDaysAgo] = useState(() => Date.now() - 30 * 24 * 60 * 60 * 1000)

  const stats = useMemo(() => {
    const activeUsers = users.filter(
      (u) => u.active_projects > 0 ||
        (u.last_active_at && new Date(u.last_active_at).getTime() > thirtyDaysAgo)
    )

    return {
      total: users.length,
      active: activeUsers.length,
      inactive: users.length - activeUsers.length,
      totalSpent: users.reduce((sum, u) => sum + u.total_spent, 0),
    }
  }, [users, thirtyDaysAgo])

  return {
    stats,
    isLoading: false,
  }
}
