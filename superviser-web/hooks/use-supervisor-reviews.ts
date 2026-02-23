/**
 * @fileoverview Custom hook for supervisor reviews management.
 * @module hooks/use-supervisor-reviews
 */

"use client"

import { useEffect, useState, useCallback } from "react"
import { createClient, getAuthUser } from "@/lib/supabase/client"

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
      const supabase = createClient()

      try {
        const user = await getAuthUser()
        if (!user) {
          setIsLoading(false)
          return
        }

        // Get supervisor ID
        const { data: supervisor } = await supabase
          .from("supervisors")
          .select("id, average_rating, total_reviews")
          .eq("profile_id", user.id)
          .single()

        if (!supervisor) {
          setIsLoading(false)
          return
        }

        // Fetch reviews with project and reviewer info
        const { data: reviewsData, error: reviewsError } = await supabase
          .from("supervisor_reviews")
          .select(`
            id,
            project_id,
            overall_rating,
            review_text,
            created_at,
            reviewer_id,
            projects (
              id,
              title
            ),
            profiles:reviewer_id (
              id,
              full_name,
              avatar_url
            )
          `)
          .eq("supervisor_id", supervisor.id)
          .eq("is_public", true)
          .order("created_at", { ascending: false })

        if (reviewsError) throw reviewsError

        // Transform reviews data
        type ReviewRow = {
          id: string
          project_id: string | null
          overall_rating: number
          review_text: string | null
          created_at: string | null
          projects: { id: string; title: string } | null
          profiles: { id: string; full_name: string; avatar_url: string | null } | null
        }

        const formattedReviews: SupervisorReviewData[] = (reviewsData || []).map((review: ReviewRow) => ({
          id: review.id,
          project_id: review.project_id || "",
          project_title: review.projects?.title || "Unknown Project",
          client_name: review.profiles?.full_name || "Anonymous",
          client_avatar: review.profiles?.avatar_url || undefined,
          rating: review.overall_rating,
          comment: review.review_text || "",
          created_at: review.created_at || new Date().toISOString(),
        }))

        setReviews(formattedReviews)

        // Calculate rating distribution
        const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
        formattedReviews.forEach(r => {
          const rating = Math.min(5, Math.max(1, Math.round(r.rating))) as 1 | 2 | 3 | 4 | 5
          distribution[rating]++
        })

        setStats({
          average_rating: supervisor.average_rating || 0,
          total_reviews: supervisor.total_reviews || formattedReviews.length,
          rating_distribution: distribution,
        })
      } catch (err) {
        setError(err instanceof Error ? err : new Error("Failed to fetch reviews"))
      } finally {
        setIsLoading(false)
      }
    }

    fetchReviews()
  }, [])

  const respondToReview = useCallback(async (reviewId: string, response: string) => {
    // Note: This would require a supervisor_review_responses table or a response column
    // For now, we update local state as a placeholder
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
