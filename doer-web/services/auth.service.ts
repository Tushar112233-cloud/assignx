import { apiClient } from '@/lib/api/client'
import { sendMagicLink, verifyOTP, logout as apiLogout, getCurrentUser } from '@/lib/api/auth'
import type { Doer, Qualification, ExperienceLevel } from '@/types/database'

/**
 * Authentication service for managing user auth operations.
 */
export const authService = {
  async getSession() {
    const user = await getCurrentUser()
    if (!user) return null
    return { user }
  },

  async getUser() {
    const user = await getCurrentUser()
    if (!user) throw new Error('No session')
    return user
  },

  async signUp(email: string, _password: string, fullName: string, phone: string) {
    return apiClient('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, fullName, phone, role: 'doer' }),
      skipAuth: true,
    })
  },

  async signIn(email: string, _password: string) {
    return sendMagicLink(email, 'doer')
  },

  async signInWithGoogle() {
    throw new Error('Google OAuth not supported with API. Use magic link.')
  },

  async signOut() {
    await apiLogout()
  },

  async resetPassword(_email: string) {
    throw new Error('Password reset not supported. Use magic link.')
  },

  async updatePassword(_newPassword: string) {
    throw new Error('Password update not supported. Use magic link.')
  },
}

/**
 * Doer service for managing doer-specific operations
 */
export const doerService = {
  async getDoerByProfileId(profileId: string): Promise<Doer | null> {
    try {
      const data = await apiClient<Doer>(`/api/doers/by-profile/${profileId}`)
      return data
    } catch {
      return null
    }
  },

  async createDoer(
    profileId: string,
    data: {
      qualification: Qualification
      experience_level: ExperienceLevel
      university_name?: string
      bio?: string
    }
  ): Promise<Doer> {
    return apiClient<Doer>('/api/doers', {
      method: 'POST',
      body: JSON.stringify({
        profile_id: profileId,
        qualification: data.qualification,
        experience_level: data.experience_level,
        university_name: data.university_name || null,
        bio: data.bio || null,
      }),
    })
  },

  async createDoerActivation(doerId: string): Promise<void> {
    await apiClient(`/api/doers/${doerId}/activation`, {
      method: 'POST',
    })
  },

  async updateProfileSetup(
    doerId: string,
    data: {
      qualification?: Qualification
      university_name?: string
      experience_level?: ExperienceLevel
      bio?: string
    }
  ): Promise<Doer> {
    return apiClient<Doer>(`/api/doers/${doerId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  },

  async updateSkills(doerId: string, skillIds: string[]): Promise<void> {
    await apiClient(`/api/doers/${doerId}/skills`, {
      method: 'PUT',
      body: JSON.stringify({ skillIds }),
    })
  },

  async updateSubjects(doerId: string, subjectIds: string[]): Promise<void> {
    await apiClient(`/api/doers/${doerId}/subjects`, {
      method: 'PUT',
      body: JSON.stringify({ subjectIds }),
    })
  },

  async getSkills() {
    return apiClient<Array<{ id: string; name: string; is_active: boolean }>>('/api/skills')
  },

  async getSubjects() {
    return apiClient<Array<{ id: string; name: string; is_active: boolean }>>('/api/subjects')
  },

  async getUniversities() {
    return apiClient<Array<{ id: string; name: string; is_active: boolean }>>('/api/universities')
  },
}

export async function signOut(): Promise<void> {
  await authService.signOut()
}
