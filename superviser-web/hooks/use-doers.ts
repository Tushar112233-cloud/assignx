/**
 * @fileoverview Custom hooks for doer/expert data management.
 * Uses Express API instead of Supabase.
 * @module hooks/use-doers
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import type { DoerWithProfile, Subject } from "@/types/database"

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
    try {
      setIsLoading(true)
      setError(null)

      const params = new URLSearchParams()
      params.set("limit", String(limit))
      params.set("offset", String(offset))
      params.set("activated", "true")

      if (subjectId) params.set("subjectId", subjectId)
      if (isAvailable !== undefined) params.set("available", String(isAvailable))
      if (searchQuery) params.set("search", searchQuery)

      const data = await apiFetch<{ doers: DoerWithProfile[]; total: number }>(
        `/api/doers?${params.toString()}`
      )

      setDoers(data.doers || [])
      setTotalCount(data.total || 0)
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

    try {
      setIsLoading(true)
      setError(null)

      const data = await apiFetch<{ doer: DoerWithProfile; subjects: Subject[] }>(
        `/api/doers/${doerId}`
      )

      setDoer(data.doer)
      setSubjects(data.subjects || [])
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch doer"))
    } finally {
      setIsLoading(false)
    }
  }, [doerId])

  const blacklistDoer = useCallback(async (reason: string) => {
    if (!doerId) return

    await apiFetch("/api/supervisors/me/blacklist", {
      method: "POST",
      body: JSON.stringify({ doerId, reason }),
    })

    await fetchDoer()
  }, [doerId, fetchDoer])

  const unblacklistDoer = useCallback(async () => {
    if (!doerId) return

    await apiFetch(`/api/supervisors/me/blacklist/${doerId}`, {
      method: "DELETE",
    })

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
      try {
        const data = await apiFetch<UseDoerStatsReturn["stats"]>(
          `/api/doers/${doerId}/stats`
        )
        setStats(data)
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
    try {
      setIsLoading(true)

      const user = getStoredUser()
      if (!user) {
        setDoers([])
        return
      }

      const data = await apiFetch<{ doers: (DoerWithProfile & { blacklistReason?: string })[] }>(
        "/api/supervisors/me/blacklist"
      )

      setDoers(data.doers || [])
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
