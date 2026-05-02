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
    // Rating breakdown is included in the full profile stats
    const data = await apiClient<{
      doer: any
      stats: {
        averageRating: number
        totalReviews: number
        qualityRating: number
        timelinessRating: number
        communicationRating: number
      } | null
    }>(`/api/doers/by-id/${doerId}/full`)
    const stats = data.stats
    return {
      overall: stats?.averageRating || 0,
      quality: stats?.qualityRating || 0,
      timeliness: stats?.timelinessRating || 0,
      communication: stats?.communicationRating || 0,
      totalReviews: stats?.totalReviews || 0,
      ratingDistribution: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 },
    }
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
