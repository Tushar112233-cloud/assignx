/**
 * @fileoverview Custom hook for supervisor data and profile management.
 * Uses Express API instead of Supabase.
 * @module hooks/use-supervisor
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import type { SupervisorWithProfile } from "@/types/database"

interface UseSupervisorReturn {
  supervisor: SupervisorWithProfile | null
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
  updateAvailability: (isAvailable: boolean) => Promise<void>
  updateProfile: (data: Partial<{ full_name: string; phone: string }>) => Promise<void>
}

export function useSupervisor(): UseSupervisorReturn {
  const [supervisor, setSupervisor] = useState<SupervisorWithProfile | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchSupervisor = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      const user = getStoredUser()
      if (!user) {
        setSupervisor(null)
        return
      }

      // Get supervisor data (now includes auth fields directly)
      try {
        const supervisorData = await apiFetch<SupervisorWithProfile>("/api/supervisors/me")
        setSupervisor(supervisorData)
      } catch (err) {
        const apiErr = err as { status?: number }
        if (apiErr.status === 404) {
          setSupervisor(null)
        } else {
          throw err
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch supervisor"))
    } finally {
      setIsLoading(false)
    }
  }, [])

  const updateAvailability = useCallback(async (isAvailable: boolean) => {
    if (!supervisor) return

    await apiFetch("/api/supervisors/me", {
      method: "PUT",
      body: JSON.stringify({ is_available: isAvailable }),
    })

    setSupervisor(prev => prev ? { ...prev, is_available: isAvailable } : null)
  }, [supervisor])

  const updateProfile = useCallback(async (data: Partial<{ full_name: string; phone: string }>) => {
    if (!supervisor) return

    await apiFetch("/api/supervisors/me", {
      method: "PUT",
      body: JSON.stringify(data),
    })

    setSupervisor(prev => prev ? { ...prev, ...data } : null)
  }, [supervisor])

  useEffect(() => {
    fetchSupervisor()
  }, [fetchSupervisor])

  return {
    supervisor,
    isLoading,
    error,
    refetch: fetchSupervisor,
    updateAvailability,
    updateProfile,
  }
}

interface UseSupervisorStatsReturn {
  stats: {
    totalProjects: number
    activeProjects: number
    completedProjects: number
    pendingQuotes: number
    totalEarnings: number
    pendingEarnings: number
    averageRating: number
    totalDoers: number
  } | null
  isLoading: boolean
  error: Error | null
}

export function useSupervisorStats(): UseSupervisorStatsReturn {
  const [stats, setStats] = useState<UseSupervisorStatsReturn["stats"]>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    async function fetchStats() {
      try {
        const user = getStoredUser()
        if (!user) {
          setStats(null)
          return
        }

        const data = await apiFetch<UseSupervisorStatsReturn["stats"]>(
          "/api/supervisors/me/stats"
        )

        setStats(data)
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Failed to fetch supervisor stats"))
      } finally {
        setIsLoading(false)
      }
    }

    fetchStats()
  }, [])

  return { stats, isLoading, error }
}

interface UseSupervisorExpertiseReturn {
  expertise: { id: string; name: string; isPrimary: boolean }[]
  subjectIds: string[]
  subjectNames: string[]
  isLoading: boolean
  error: Error | null
}

export function useSupervisorExpertise(): UseSupervisorExpertiseReturn {
  const [expertise, setExpertise] = useState<UseSupervisorExpertiseReturn["expertise"]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    async function fetchExpertise() {
      try {
        const user = getStoredUser()
        if (!user) {
          setExpertise([])
          setIsLoading(false)
          return
        }

        const data = await apiFetch<{ expertise: UseSupervisorExpertiseReturn["expertise"] }>(
          "/api/supervisors/me/expertise"
        )

        setExpertise(data.expertise || [])
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Failed to fetch expertise"))
      } finally {
        setIsLoading(false)
      }
    }

    fetchExpertise()
  }, [])

  return {
    expertise,
    subjectIds: expertise.map(e => e.id),
    subjectNames: expertise.map(e => e.name),
    isLoading,
    error,
  }
}
