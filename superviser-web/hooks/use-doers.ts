/**
 * @fileoverview Custom hooks for doer/expert data management.
 * @module hooks/use-doers
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { createClient, getAuthUser } from "@/lib/supabase/client"
import type { Doer, DoerWithProfile, Subject } from "@/types/database"

interface UseDoersOptions {
  subjectId?: string
  isAvailable?: boolean
  limit?: number
  offset?: number
  searchQuery?: string
}

interface UseDoersReturn {
  doers: DoerWithProfile[]
  isLoading: boolean
  error: Error | null
  totalCount: number
  refetch: () => Promise<void>
}

export function useDoers(options: UseDoersOptions = {}): UseDoersReturn {
  const { subjectId, isAvailable, limit = 50, offset = 0, searchQuery } = options
  const [doers, setDoers] = useState<DoerWithProfile[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [totalCount, setTotalCount] = useState(0)

  const fetchDoers = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      // Build the query based on whether we need to filter by subject
      let query

      if (subjectId) {
        // When filtering by subject, use inner join with doer_subjects
        query = supabase
          .from("doers")
          .select(`
            *,
            profiles!profile_id (*),
            doer_subjects!inner (
              subject_id,
              subjects (*)
            )
          `, { count: "exact" })
          .eq("is_activated", true)
          .eq("doer_subjects.subject_id", subjectId)
          .order("average_rating", { ascending: false, nullsFirst: false })
          .range(offset, offset + limit - 1)
      } else {
        // Without subject filter, use regular query
        query = supabase
          .from("doers")
          .select(`
            *,
            profiles!profile_id (*)
          `, { count: "exact" })
          .eq("is_activated", true)
          .order("average_rating", { ascending: false, nullsFirst: false })
          .range(offset, offset + limit - 1)
      }

      // Filter by availability
      if (isAvailable !== undefined) {
        query = query.eq("is_available", isAvailable)
      }

      const { data, error: queryError, count } = await query

      if (queryError) throw queryError

      // Filter by search query on the client side (for name search)
      let filteredData = data || []
      if (searchQuery) {
        const lowerQuery = searchQuery.toLowerCase()
        filteredData = filteredData.filter((doer) =>
          doer.profiles?.full_name?.toLowerCase().includes(lowerQuery) ||
          doer.profiles?.email?.toLowerCase().includes(lowerQuery)
        )
      }

      setDoers(filteredData as DoerWithProfile[])
      setTotalCount(count || 0)
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch doers"))
    } finally {
      setIsLoading(false)
    }
  }, [subjectId, isAvailable, limit, offset, searchQuery])

  useEffect(() => {
    fetchDoers()
  }, [fetchDoers])

  return {
    doers,
    isLoading,
    error,
    totalCount,
    refetch: fetchDoers,
  }
}

interface UseDoerReturn {
  doer: DoerWithProfile | null
  subjects: Subject[]
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
  blacklistDoer: (reason: string) => Promise<void>
  unblacklistDoer: () => Promise<void>
}

export function useDoer(doerId: string): UseDoerReturn {
  const [doer, setDoer] = useState<DoerWithProfile | null>(null)
  const [subjects, setSubjects] = useState<Subject[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchDoer = useCallback(async () => {
    if (!doerId) return

    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      // Fetch doer with profile
      const { data: doerData, error: doerError } = await supabase
        .from("doers")
        .select(`
          *,
          profiles!profile_id (*)
        `)
        .eq("id", doerId)
        .single()

      if (doerError) throw doerError
      setDoer(doerData)

      // Fetch doer's subjects
      const { data: doerSubjects, error: subjectsError } = await supabase
        .from("doer_subjects")
        .select(`
          subjects (*)
        `)
        .eq("doer_id", doerId)

      if (!subjectsError && doerSubjects) {
        setSubjects(doerSubjects.map(ds => ds.subjects).filter(Boolean) as Subject[])
      }
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch doer"))
    } finally {
      setIsLoading(false)
    }
  }, [doerId])

  const blacklistDoer = useCallback(async (reason: string) => {
    if (!doerId) return

    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) throw new Error("Not authenticated")

    // Get supervisor ID
    const { data: supervisor } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .single()

    if (!supervisor) throw new Error("Supervisor not found")

    // Add to blacklist
    const { error: blacklistError } = await supabase
      .from("supervisor_blacklisted_doers")
      .insert({
        supervisor_id: supervisor.id,
        doer_id: doerId,
        reason,
      })

    if (blacklistError) throw blacklistError
    await fetchDoer()
  }, [doerId, fetchDoer])

  const unblacklistDoer = useCallback(async () => {
    if (!doerId) return

    const supabase = createClient()
    const user = await getAuthUser()
    if (!user) throw new Error("Not authenticated")

    // Get supervisor ID
    const { data: supervisor } = await supabase
      .from("supervisors")
      .select("id")
      .eq("profile_id", user.id)
      .single()

    if (!supervisor) throw new Error("Supervisor not found")

    // Remove from blacklist
    const { error: unblacklistError } = await supabase
      .from("supervisor_blacklisted_doers")
      .delete()
      .eq("supervisor_id", supervisor.id)
      .eq("doer_id", doerId)

    if (unblacklistError) throw unblacklistError
    await fetchDoer()
  }, [doerId, fetchDoer])

  useEffect(() => {
    fetchDoer()
  }, [fetchDoer])

  return {
    doer,
    subjects,
    isLoading,
    error,
    refetch: fetchDoer,
    blacklistDoer,
    unblacklistDoer,
  }
}

interface UseDoerStatsReturn {
  stats: {
    totalProjects: number
    completedProjects: number
    averageRating: number
    onTimeDeliveryRate: number
  } | null
  isLoading: boolean
  error: Error | null
}

export function useDoerStats(doerId: string): UseDoerStatsReturn {
  const [stats, setStats] = useState<UseDoerStatsReturn["stats"]>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    if (!doerId) return

    async function fetchStats() {
      const supabase = createClient()

      try {
        // Get doer data
        const { data: doer } = await supabase
          .from("doers")
          .select("total_projects_completed, average_rating")
          .eq("id", doerId)
          .single()

        if (!doer) return

        // Get project stats
        const { data: projects } = await supabase
          .from("projects")
          .select("id, status, deadline, delivered_at")
          .eq("doer_id", doerId)

        const completedStatuses = ["completed", "auto_approved", "delivered", "qc_approved"]
        const completedProjects = projects?.filter(p =>
          completedStatuses.includes(p.status)
        ) || []

        // Calculate on-time delivery rate
        const onTimeProjects = completedProjects.filter(p => {
          if (!p.deadline || !p.delivered_at) return true
          return new Date(p.delivered_at) <= new Date(p.deadline)
        })

        const onTimeRate = completedProjects.length > 0
          ? (onTimeProjects.length / completedProjects.length) * 100
          : 100

        setStats({
          totalProjects: projects?.length || 0,
          completedProjects: completedProjects.length,
          averageRating: doer.average_rating || 0,
          onTimeDeliveryRate: Math.round(onTimeRate),
        })
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Failed to fetch doer stats"))
      } finally {
        setIsLoading(false)
      }
    }

    fetchStats()
  }, [doerId])

  return { stats, isLoading, error }
}

export function useBlacklistedDoers() {
  const [doers, setDoers] = useState<(DoerWithProfile & { blacklistReason?: string })[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchBlacklistedDoers = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)

      const user = await getAuthUser()
      if (!user) throw new Error("Not authenticated")

      // Get supervisor ID
      const { data: supervisor } = await supabase
        .from("supervisors")
        .select("id")
        .eq("profile_id", user.id)
        .single()

      if (!supervisor) {
        setDoers([])
        return
      }

      // Get blacklisted doers
      const { data: blacklist, error: blacklistError } = await supabase
        .from("supervisor_blacklisted_doers")
        .select(`
          reason,
          doers (
            *,
            profiles!profile_id (*)
          )
        `)
        .eq("supervisor_id", supervisor.id)

      if (blacklistError) throw blacklistError

      const blacklistedDoers = blacklist?.map(item => ({
        ...item.doers,
        profiles: item.doers?.profiles || undefined,
        blacklistReason: item.reason,
      })).filter(Boolean) as (DoerWithProfile & { blacklistReason?: string })[]

      setDoers(blacklistedDoers || [])
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch blacklisted doers"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchBlacklistedDoers()
  }, [fetchBlacklistedDoers])

  return {
    doers,
    isLoading,
    error,
    refetch: fetchBlacklistedDoers,
  }
}
