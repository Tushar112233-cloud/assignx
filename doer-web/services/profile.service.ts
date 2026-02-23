/**
 * Profile Service
 * Core profile operations and barrel exports for domain services
 * @module services/profile.service
 */

import { createClient } from '@/lib/supabase/client'
import type {
  Profile,
  Doer,
  DoerStats,
  Qualification,
  ExperienceLevel,
} from '@/types/database'

// Re-export domain services
export * from './skills.service'
export * from './wallet.service'
export * from './payouts.service'
export * from './reviews.service'
export * from './support.service'

/**
 * Profile update payload
 */
interface ProfileUpdatePayload {
  /** Full name */
  full_name?: string
  /** Phone number */
  phone?: string
  /** Avatar URL */
  avatar_url?: string
  /** Qualification level */
  qualification?: Qualification
  /** University ID */
  university_id?: string
  /** Experience level */
  experience_level?: ExperienceLevel
  /** Bio/about text */
  bio?: string
}

/**
 * Get doer profile with stats
 * @param profileId - The profile ID
 * @returns Profile, doer data, and calculated stats
 */
export async function getDoerProfile(profileId: string): Promise<{
  profile: Profile | null
  doer: Doer | null
  stats: DoerStats | null
}> {
  const supabase = createClient()

  // Fetch profile and doer in parallel
  const [profileResult, doerResult] = await Promise.all([
    supabase.from('profiles').select('*').eq('id', profileId).single(),
    supabase.from('doers').select('*').eq('profile_id', profileId).single(),
  ])

  const profile = profileResult.data as Profile | null
  const doer = doerResult.data as Doer | null

  if (!doer) {
    return { profile, doer: null, stats: null }
  }

  // Fetch stats in parallel
  const [activeResult, reviewsResult, walletResult] = await Promise.all([
    supabase
      .from('projects')
      .select('*', { count: 'exact', head: true })
      .eq('doer_id', doer.id)
      .in('status', ['assigned', 'in_progress', 'in_revision', 'revision_requested']),
    supabase
      .from('doer_reviews')
      .select('quality_rating, timeliness_rating, communication_rating')
      .eq('doer_id', doer.id),
    supabase
      .from('wallets')
      .select('locked_amount')
      .eq('profile_id', profileId)
      .eq('wallet_type', 'doer')
      .maybeSingle(),
  ])

  const reviews = reviewsResult.data

  // Calculate average ratings
  let qualityRating = 0
  let timelinessRating = 0
  let communicationRating = 0

  if (reviews && reviews.length > 0) {
    const totalReviews = reviews.length
    qualityRating = reviews.reduce((sum, r) => sum + (r.quality_rating || 0), 0) / totalReviews
    timelinessRating = reviews.reduce((sum, r) => sum + (r.timeliness_rating || 0), 0) / totalReviews
    communicationRating = reviews.reduce((sum, r) => sum + (r.communication_rating || 0), 0) / totalReviews
  }

  // Build stats object
  const stats: DoerStats = {
    activeAssignments: activeResult.count || 0,
    completedProjects: doer.total_projects_completed || 0,
    totalEarnings: Number(doer.total_earnings) || 0,
    pendingEarnings: Number(walletResult.data?.locked_amount) || 0,
    averageRating: Number(doer.average_rating) || 0,
    totalReviews: doer.total_reviews || 0,
    successRate: Number(doer.success_rate) || 0,
    onTimeDeliveryRate: Number(doer.on_time_delivery_rate) || 0,
    qualityRating: Number(qualityRating.toFixed(1)) || 0,
    timelinessRating: Number(timelinessRating.toFixed(1)) || 0,
    communicationRating: Number(communicationRating.toFixed(1)) || 0,
  }

  return { profile, doer, stats }
}

/**
 * Update doer profile
 * @param doerId - The doer ID
 * @param updates - Profile updates
 * @returns Success status and optional error
 */
export async function updateDoerProfile(
  doerId: string,
  updates: ProfileUpdatePayload
): Promise<{ success: boolean; error?: string }> {
  const supabase = createClient()

  // Update profile table
  if (updates.full_name || updates.phone || updates.avatar_url) {
    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        full_name: updates.full_name,
        phone: updates.phone,
        avatar_url: updates.avatar_url,
      })
      .eq('id', doerId)

    if (profileError) {
      return { success: false, error: profileError.message }
    }
  }

  // Update doer table
  if (updates.qualification || updates.university_id || updates.experience_level || updates.bio) {
    const { error: doerError } = await supabase
      .from('doers')
      .update({
        qualification: updates.qualification,
        university_id: updates.university_id,
        experience_level: updates.experience_level,
        bio: updates.bio,
      })
      .eq('profile_id', doerId)

    if (doerError) {
      return { success: false, error: doerError.message }
    }
  }

  return { success: true }
}

/**
 * Upload profile avatar
 * @param doerId - The doer ID
 * @param file - The image file to upload
 * @returns Success status with URL or error
 */
export async function uploadAvatar(
  doerId: string,
  file: File
): Promise<{ success: boolean; url?: string; error?: string }> {
  const supabase = createClient()

  const fileExt = file.name.split('.').pop()
  const fileName = `${doerId}-${Date.now()}.${fileExt}`

  const { error: uploadError } = await supabase.storage
    .from('avatars')
    .upload(fileName, file)

  if (uploadError) {
    return { success: false, error: uploadError.message }
  }

  const { data } = supabase.storage.from('avatars').getPublicUrl(fileName)

  // Update profile with new avatar URL
  await supabase
    .from('profiles')
    .update({ avatar_url: data.publicUrl })
    .eq('id', doerId)

  return { success: true, url: data.publicUrl }
}
