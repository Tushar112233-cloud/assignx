/**
 * @fileoverview Custom hook for supervisor reviews management.
 * Uses Express API instead of Supabase.
 * @module hooks/use-supervisor-reviews
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"

interface SupervisorReviewData {
  id: string
  project_id: string
  project_title: string
  client_name: string
  client_avatar?: string
  rating: number
  comment: string
  created_at: string
  response?: string
  responded_at?: string
}

interface ReviewStatsData {
  average_rating: number
  total_reviews: number
  rating_distribution: {
    1: number
    2: number
    3: number
    4: number
    5: number
  }
}

interface UseSupervisorReviewsReturn {
  reviews: SupervisorReviewData[]
  stats: ReviewStatsData | null
  isLoading: boolean
  error: Error | null
  respondToReview: (reviewId: string, response: string) => Promise<void>
}

export function useSupervisorReviews(): UseSupervisorReviewsReturn {
  const [reviews, setReviews] = useState<SupervisorReviewData[]>([])
  const [stats, setStats] = useState<ReviewStatsData | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    async function fetchReviews() {
      try {
        const user = getStoredUser()
        if (!user) {
          setIsLoading(false)
          return
        }

        const data = await apiFetch<{
          reviews: SupervisorReviewData[]
          stats: ReviewStatsData
        }>("/api/supervisors/me/reviews")

        setReviews(data.reviews || [])
        setStats(data.stats || null)
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Failed to fetch reviews"))
      } finally {
        setIsLoading(false)
      }
    }

    fetchReviews()
  }, [])

  const respondToReview = useCallback(async (reviewId: string, response: string) => {
    // TODO: DB persistence requires adding response columns to supervisor_reviews table.
    // Until then, this only updates local React state.
    setReviews(prev =>
      prev.map(r =>
        r.id === reviewId
          ? { ...r, response, responded_at: new Date().toISOString() }
          : r
      )
    )
  }, [])

  return { reviews, stats, isLoading, error, respondToReview }
}
