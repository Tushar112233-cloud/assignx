/**
 * Profile Service
 * Core profile operations and barrel exports for domain services
 * @module services/profile.service
 */

import { apiClient, apiUpload } from '@/lib/api/client'
import type {
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

interface DoerUpdatePayload {
  full_name?: string
  phone?: string
  avatar_url?: string
  qualification?: Qualification
  university_name?: string
  experience_level?: ExperienceLevel
  bio?: string
}

export async function getDoerProfile(): Promise<{
  doer: Doer | null
  stats: DoerStats | null
}> {
  try {
    // First get the doer record (which includes the doer's id)
    const doer = await apiClient<Doer>('/api/doers/me')
    if (!doer?.id) return { doer: null, stats: null }

    // Then fetch the full profile with stats using the doer's id
    const data = await apiClient<{
      doer: Doer | null
      stats: DoerStats | null
    }>(`/api/doers/by-id/${doer.id}/full`)
    return data
  } catch {
    return { doer: null, stats: null }
  }
}

export async function updateDoerProfile(
  _doerId: string,
  updates: DoerUpdatePayload
): Promise<{ success: boolean; error?: string }> {
  try {
    // Get the doer's ID since PUT requires /doers/:id
    const doer = await apiClient<{ id: string }>('/api/doers/me')
    if (!doer?.id) throw new Error('Doer profile not found')

    // Map snake_case field names to camelCase for the API
    const apiUpdates: Record<string, unknown> = {}
    if (updates.full_name !== undefined) apiUpdates.fullName = updates.full_name
    if (updates.phone !== undefined) apiUpdates.phone = updates.phone
    if (updates.avatar_url !== undefined) apiUpdates.avatarUrl = updates.avatar_url
    if (updates.qualification !== undefined) apiUpdates.qualification = updates.qualification
    if (updates.university_name !== undefined) apiUpdates.universityName = updates.university_name
    if (updates.experience_level !== undefined) apiUpdates.experienceLevel = updates.experience_level
    if (updates.bio !== undefined) apiUpdates.bio = updates.bio

    await apiClient(`/api/doers/${doer.id}`, {
      method: 'PUT',
      body: JSON.stringify(apiUpdates),
    })
    return { success: true }
  } catch (err) {
    return { success: false, error: (err as Error).message }
  }
}

export async function uploadAvatar(
  _doerId: string,
  file: File
): Promise<{ success: boolean; url?: string; error?: string }> {
  try {
    const data = await apiUpload<{ url: string }>('/api/upload', file, 'avatars')

    // Get doer ID, then update profile with new avatar URL
    const doer = await apiClient<{ id: string }>('/api/doers/me')
    if (!doer?.id) throw new Error('Doer profile not found')

    await apiClient(`/api/doers/${doer.id}`, {
      method: 'PUT',
      body: JSON.stringify({ avatarUrl: data.url }),
    })

    return { success: true, url: data.url }
  } catch (err) {
    return { success: false, error: (err as Error).message }
  }
}
