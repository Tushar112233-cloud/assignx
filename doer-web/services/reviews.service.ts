/**
 * Reviews Service
 * Handles doer reviews and ratings operations
 * @module services/reviews.service
 */

import { createClient } from '@/lib/supabase/client'
import type { DoerReview } from '@/types/database'

/**
 * Rating breakdown result
 */
interface RatingBreakdown {
  /** Overall rating */
  overall: number
  /** Quality rating */
  quality: number
  /** Timeliness rating */
  timeliness: number
  /** Communication rating */
  communication: number
  /** Total number of reviews */
  totalReviews: number
  /** Distribution of ratings by star count */
  ratingDistribution: Record<number, number>
}

/**
 * Get reviews for doer
 * @param doerId - The doer ID
 * @returns Array of doer reviews
 */
export async function getDoerReviews(doerId: string): Promise<DoerReview[]> {
  const supabase = createClient()

  const { data } = await supabase
    .from('doer_reviews')
    .select('*')
    .eq('doer_id', doerId)
    .order('created_at', { ascending: false })

  return data || []
}

/**
 * Get rating breakdown for doer
 * Calculates average ratings across different categories
 * @param doerId - The doer ID
 * @returns Rating breakdown with overall and category-specific ratings
 */
export async function getRatingBreakdown(doerId: string): Promise<RatingBreakdown> {
  const supabase = createClient()

  const { data: reviews, error } = await supabase
    .from('doer_reviews')
    .select('quality_rating, timeliness_rating, communication_rating, overall_rating')
    .eq('doer_id', doerId)

  if (error || !reviews || reviews.length === 0) {
    return {
      overall: 0,
      quality: 0,
      timeliness: 0,
      communication: 0,
      totalReviews: 0,
      ratingDistribution: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 },
    }
  }

  const totalReviews = reviews.length
  const quality = reviews.reduce((sum, r) => sum + (Number(r.quality_rating) || 0), 0) / totalReviews
  const timeliness = reviews.reduce((sum, r) => sum + (Number(r.timeliness_rating) || 0), 0) / totalReviews
  const communication = reviews.reduce((sum, r) => sum + (Number(r.communication_rating) || 0), 0) / totalReviews
  const overall = reviews.reduce((sum, r) => sum + (Number(r.overall_rating) || 0), 0) / totalReviews

  const ratingDistribution: Record<number, number> = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 }
  for (const r of reviews) {
    const rounded = Math.round(Number(r.overall_rating) || 0)
    if (rounded >= 1 && rounded <= 5) {
      ratingDistribution[rounded]++
    }
  }

  return {
    overall,
    quality,
    timeliness,
    communication,
    totalReviews,
    ratingDistribution,
  }
}
