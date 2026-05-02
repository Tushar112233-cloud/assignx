import { apiClient } from '@/lib/api/client'
import { sendOTP, verifyOTP, logout as apiLogout, getCurrentUser } from '@/lib/api/auth'
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

  async signUp(email: string, _password: string, _fullName: string, _phone: string) {
    // Registration is handled via send-otp -> doer-signup flow
    return sendOTP(email, 'signup', 'doer')
  },

  async signIn(email: string, _password: string) {
    return sendOTP(email, 'login', 'doer')
  },

  async signInWithGoogle() {
    throw new Error('Google OAuth not supported with API. Use OTP.')
  },

  async signOut() {
    await apiLogout()
  },

  async resetPassword(_email: string) {
    throw new Error('Password reset not supported. Use OTP.')
  },

  async updatePassword(_newPassword: string) {
    throw new Error('Password update not supported. Use OTP.')
  },
}

/**
 * Doer service for managing doer-specific operations
 */
export const doerService = {
  async getDoer(): Promise<Doer | null> {
    try {
      const data = await apiClient<Doer>('/api/doers/me')
      return data
    } catch {
      return null
    }
  },

  async createDoer(
    _data: {
      qualification: Qualification
      experience_level: ExperienceLevel
      university_name?: string
      bio?: string
    }
  ): Promise<Doer> {
    // Doer records are created server-side during the doer-signup flow.
    // This should not be called directly. Return existing doer profile.
    return apiClient<Doer>('/api/doers/me')
  },

  async createDoerActivation(_doerId: string): Promise<void> {
    // Activation record is created server-side during doer signup.
    // This is a no-op.
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
    // API uses camelCase field names (Mongoose schema)
    return apiClient<Doer>(`/api/doers/${doerId}`, {
      method: 'PUT',
      body: JSON.stringify({
        qualification: data.qualification,
        universityName: data.university_name,
        experienceLevel: data.experience_level,
        bio: data.bio,
      }),
    })
  },

  async updateSkills(doerId: string, skillIds: string[]): Promise<void> {
    await apiClient(`/api/doers/${doerId}/skills`, {
      method: 'POST',
      body: JSON.stringify({ skills: skillIds.map(id => ({ skillId: id })) }),
    })
  },

  async updateSubjects(doerId: string, subjectIds: string[]): Promise<void> {
    await apiClient(`/api/doers/${doerId}/subjects`, {
      method: 'POST',
      body: JSON.stringify({ subjects: subjectIds.map((id, i) => ({ subjectId: id, isPrimary: i === 0 })) }),
    })
  },

  async getSkills() {
    const data = await apiClient<{ skills: Array<{ _id: string; name: string; isActive: boolean }> }>('/api/skills')
    return (data.skills || []).map(s => ({ id: s._id, name: s.name, is_active: s.isActive }))
  },

  async getSubjects() {
    const data = await apiClient<{ subjects: Array<{ _id: string; name: string; isActive: boolean }> }>('/api/subjects')
    return (data.subjects || []).map(s => ({ id: s._id, name: s.name, is_active: s.isActive }))
  },

  async getUniversities() {
    const data = await apiClient<{ universities: Array<{ _id: string; name: string; isActive: boolean }> }>('/api/universities')
    return (data.universities || []).map(u => ({ id: u._id, name: u.name, is_active: u.isActive }))
  },
}

export async function signOut(): Promise<void> {
  await authService.signOut()
}
