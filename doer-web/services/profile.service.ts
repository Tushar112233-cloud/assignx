/**
 * Profile Service
 * Core profile operations and barrel exports for domain services
 * @module services/profile.service
 */

import { apiClient, apiUpload } from '@/lib/api/client'
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

interface ProfileUpdatePayload {
  full_name?: string
  phone?: string
  avatar_url?: string
  qualification?: Qualification
  university_name?: string
  experience_level?: ExperienceLevel
  bio?: string
}

export async function getDoerProfile(profileId: string): Promise<{
  profile: Profile | null
  doer: Doer | null
  stats: DoerStats | null
}> {
  try {
    const data = await apiClient<{
      profile: Profile | null
      doer: Doer | null
      stats: DoerStats | null
    }>(`/api/doers/by-profile/${profileId}/full`)
    return data
  } catch {
    return { profile: null, doer: null, stats: null }
  }
}

export async function updateDoerProfile(
  doerId: string,
  updates: ProfileUpdatePayload
): Promise<{ success: boolean; error?: string }> {
  try {
    await apiClient(`/api/profiles/me`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    })
    return { success: true }
  } catch (err) {
    return { success: false, error: (err as Error).message }
  }
}

export async function uploadAvatar(
  doerId: string,
  file: File
): Promise<{ success: boolean; url?: string; error?: string }> {
  try {
    const data = await apiUpload<{ url: string }>('/api/upload', file, 'avatars')

    // Update profile with new avatar URL
    await apiClient('/api/profiles/me', {
      method: 'PUT',
      body: JSON.stringify({ avatar_url: data.url }),
    })

    return { success: true, url: data.url }
  } catch (err) {
    return { success: false, error: (err as Error).message }
  }
}
