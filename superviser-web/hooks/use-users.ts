/**
 * @fileoverview Custom hooks for fetching users (clients) associated with supervisor's projects.
 * Uses Express API instead of Supabase.
 * @module hooks/use-users
 */

"use client"

import { useEffect, useState, useCallback, useMemo } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"

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
    try {
      setIsLoading(true)
      setError(null)

      const user = getStoredUser()
      if (!user) {
        setUsers([])
        return
      }

      const params = new URLSearchParams()
      params.set("limit", String(limit))
      params.set("offset", String(offset))

      const data = await apiFetch<{ users: UserWithStats[]; total: number }>(
        `/api/supervisors/me/users?${params.toString()}`
      )

      setUsers(data.users || [])
      setTotalCount(data.total || 0)
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

    try {
      setIsLoading(true)
      setError(null)

      const params = new URLSearchParams()
      params.set("limit", String(limit))

      const data = await apiFetch<{ projects: UserProject[] }>(
        `/api/supervisors/me/users/${userId}/projects?${params.toString()}`
      )

      setProjects(data.projects || [])
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
