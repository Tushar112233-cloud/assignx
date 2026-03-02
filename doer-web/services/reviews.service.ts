/**
 * Reviews Service
 * Handles doer reviews and ratings operations via API
 * @module services/reviews.service
 */

import { apiClient } from '@/lib/api/client'
import type { DoerReview } from '@/types/database'

interface RatingBreakdown {
  overall: number
  quality: number
  timeliness: number
  communication: number
  totalReviews: number
  ratingDistribution: Record<number, number>
}

export async function getDoerReviews(doerId: string): Promise<DoerReview[]> {
  try {
    const data = await apiClient<{ reviews: DoerReview[] }>(`/api/doers/${doerId}/reviews`)
    return data.reviews || []
  } catch {
    return []
  }
}

export async function getRatingBreakdown(doerId: string): Promise<RatingBreakdown> {
  try {
    return await apiClient<RatingBreakdown>(`/api/doers/${doerId}/ratings`)
  } catch {
    return {
      overall: 0,
      quality: 0,
      timeliness: 0,
      communication: 0,
      totalReviews: 0,
      ratingDistribution: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 },
    }
  }
}
