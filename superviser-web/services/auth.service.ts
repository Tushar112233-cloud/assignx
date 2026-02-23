import { createClient } from '@/lib/supabase/client'
import type { Supervisor, SupervisorActivation } from '@/types'

const supabase = createClient()

/**
 * Authentication service for managing user auth operations
 */
export const authService = {
  /**
   * Get current session
   */
  async getSession() {
    const { data: { session }, error } = await supabase.auth.getSession()
    if (error) throw error
    return session
  },

  /**
   * Get current user
   */
  async getUser() {
    const { data: { user }, error } = await supabase.auth.getUser()
    if (error) throw error
    return user
  },

  /**
   * Sign up with email and password
   */
  async signUp(email: string, password: string, fullName: string, phone: string) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
          phone,
        },
      },
    })

    if (error) throw error
    return data
  },

  /**
   * Sign in with email and password
   */
  async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) throw error
    return data
  },

  /**
   * Sign in with Google OAuth
   */
  async signInWithGoogle() {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    })

    if (error) throw error
    return data
  },

  /**
   * Sign out
   */
  async signOut() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  },

  /**
   * Reset password
   */
  async resetPassword(email: string) {
    const { data, error } = await supabase.auth.resetPasswordForEmail(email)
    if (error) throw error
    return data
  },

  /**
   * Update password
   */
  async updatePassword(newPassword: string) {
    const { data, error } = await supabase.auth.updateUser({
      password: newPassword,
    })
    if (error) throw error
    return data
  },
}

/**
 * Supervisor service for managing supervisor-specific operations
 */
export const supervisorService = {
  /**
   * Get supervisor profile by profile ID
   */
  async getSupervisorByProfileId(profileId: string): Promise<Supervisor | null> {
    const { data, error } = await supabase
      .from('supervisors')
      .select('*')
      .eq('profile_id', profileId)
      .single()

    if (error && error.code !== 'PGRST116') throw error
    return data
  },

  /**
   * Get supervisor activation record by supervisor ID
   */
  async getSupervisorActivation(supervisorId: string): Promise<SupervisorActivation | null> {
    const { data, error } = await supabase
      .from('supervisor_activation')
      .select('*')
      .eq('supervisor_id', supervisorId)
      .single()

    if (error && error.code !== 'PGRST116') throw error
    return data
  },

  /**
   * Create supervisor profile with required values
   * Called from profile-setup page after user provides qualification/experience
   */
  async createSupervisor(
    profileId: string,
    data: {
      qualification: string
      years_of_experience: number
      cv_url?: string
    }
  ): Promise<Supervisor> {
    const { data: supervisor, error } = await supabase
      .from('supervisors')
      .insert({
        profile_id: profileId,
        qualification: data.qualification,
        years_of_experience: data.years_of_experience,
        cv_url: data.cv_url || null,
        is_available: false,
        max_concurrent_projects: 5,
        is_activated: false,
        total_earnings: 0,
        total_projects_managed: 0,
        average_rating: 0,
        total_reviews: 0,
        success_rate: 0,
        average_response_time_hours: 0,
        bank_verified: false,
        cv_verified: false,
      })
      .select()
      .single()

    if (error) throw error
    return supervisor
  },

  /**
   * Update supervisor profile
   */
  async updateSupervisor(
    supervisorId: string,
    data: {
      qualification?: string
      years_of_experience?: number
      cv_url?: string
      is_available?: boolean
      max_concurrent_projects?: number
      bank_name?: string
      bank_account_number?: string
      bank_account_name?: string
      bank_ifsc_code?: string
      upi_id?: string
    }
  ): Promise<Supervisor> {
    const { data: supervisor, error } = await supabase
      .from('supervisors')
      .update(data)
      .eq('id', supervisorId)
      .select()
      .single()

    if (error) throw error
    return supervisor
  },

  /**
   * Create supervisor activation record
   * Called after supervisor record is created
   */
  async createSupervisorActivation(supervisorId: string): Promise<void> {
    const { error } = await supabase
      .from('supervisor_activation')
      .insert({
        supervisor_id: supervisorId,
        training_completed: false,
        quiz_passed: false,
        total_quiz_attempts: 0,
        cv_submitted: false,
        cv_verified: false,
        bank_details_added: false,
        is_fully_activated: false,
      })

    if (error) throw error
  },

  /**
   * Update supervisor activation record
   */
  async updateSupervisorActivation(
    supervisorId: string,
    data: {
      training_completed?: boolean
      training_completed_at?: string
      quiz_passed?: boolean
      quiz_passed_at?: string
      quiz_attempt_id?: string
      total_quiz_attempts?: number
      cv_submitted?: boolean
      cv_submitted_at?: string
      cv_verified?: boolean
      cv_verified_at?: string
      cv_verified_by?: string
      cv_rejection_reason?: string
      bank_details_added?: boolean
      bank_details_added_at?: string
      is_fully_activated?: boolean
      activated_at?: string
    }
  ): Promise<SupervisorActivation> {
    const { data: activation, error } = await supabase
      .from('supervisor_activation')
      .update(data)
      .eq('supervisor_id', supervisorId)
      .select()
      .single()

    if (error) throw error
    return activation
  },
}

/**
 * Sign out the current user
 * Standalone export for convenience
 */
export async function signOut(): Promise<void> {
  await authService.signOut()
}
