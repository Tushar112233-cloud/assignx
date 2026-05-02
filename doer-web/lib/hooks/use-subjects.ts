"use client"

import { useState, useEffect, useCallback } from "react"
import { apiClient } from "@/lib/api/client"

export interface ApiSubject {
  _id: string
  name: string
  slug: string
  category: string
  isActive: boolean
}

interface UseSubjectsReturn {
  subjects: ApiSubject[]
  isLoading: boolean
  error: string | null
  retry: () => void
}

export function useSubjects(): UseSubjectsReturn {
  const [subjects, setSubjects] = useState<ApiSubject[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [retryCount, setRetryCount] = useState(0)

  const retry = useCallback(() => {
    setRetryCount((c) => c + 1)
  }, [])

  useEffect(() => {
    let cancelled = false

    async function fetchSubjects() {
      setIsLoading(true)
      setError(null)

      try {
        const data = await apiClient<{ subjects: ApiSubject[] }>("/api/subjects", { skipAuth: true })
        if (!cancelled) {
          setSubjects(data.subjects ?? [])
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Failed to fetch subjects")
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false)
        }
      }
    }

    fetchSubjects()

    return () => {
      cancelled = true
    }
  }, [retryCount])

  return { subjects, isLoading, error, retry }
}
