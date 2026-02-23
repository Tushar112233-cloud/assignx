import { createClient } from '@/lib/supabase/client'
import type { Doer, Qualification, ExperienceLevel } from '@/types/database'

/**
 * Get a Supabase client instance.
 * Called per-method instead of at module level to avoid
 * browser API access during SSR/build.
 */
function getSupabase() {
  return createClient()
}

/**
 * Authentication service for managing user auth operations.
 */
export const authService = {
  /**
   * Get current session
   */
  async getSession() {
    const supabase = getSupabase()
    const { data: { session }, error } = await supabase.auth.getSession()
    if (error) throw error
    return session
  },

  /**
   * Get current user
   */
  async getUser() {
    const supabase = getSupabase()
    const { data: { session } } = await supabase.auth.getSession()
    if (!session?.user) throw new Error('No session')
    return session.user
  },

  /**
   * Sign up with email and password
   */
  async signUp(email: string, password: string, fullName: string, phone: string) {
    const supabase = getSupabase()
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
    const supabase = getSupabase()
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
    const supabase = getSupabase()
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
    const supabase = getSupabase()
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  },

  /**
   * Reset password
   */
  async resetPassword(email: string) {
    const supabase = getSupabase()
    const { data, error } = await supabase.auth.resetPasswordForEmail(email)
    if (error) throw error
    return data
  },

  /**
   * Update password
   */
  async updatePassword(newPassword: string) {
    const supabase = getSupabase()
    const { data, error } = await supabase.auth.updateUser({
      password: newPassword,
    })
    if (error) throw error
    return data
  },
}

/**
 * Doer service for managing doer-specific operations
 */
export const doerService = {
  /**
   * Get doer profile by profile ID
   */
  async getDoerByProfileId(profileId: string): Promise<Doer | null> {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('doers')
      .select('*')
      .eq('profile_id', profileId)
      .single()

    if (error && error.code !== 'PGRST116') throw error
    return data
  },

  /**
   * Create doer profile with required values
   * Called from profile-setup page after user provides qualification/experience
   */
  async createDoer(
    profileId: string,
    data: {
      qualification: Qualification
      experience_level: ExperienceLevel
      university_id?: string
      bio?: string
    }
  ): Promise<Doer> {
    const supabase = getSupabase()
    const { data: doer, error } = await supabase
      .from('doers')
      .insert({
        profile_id: profileId,
        qualification: data.qualification,
        experience_level: data.experience_level,
        university_id: data.university_id || null,
        bio: data.bio || null,
        is_available: false,
        max_concurrent_projects: 3,
        is_activated: false,
        total_earnings: 0,
        total_projects_completed: 0,
        average_rating: 0,
        total_reviews: 0,
        success_rate: 0,
        on_time_delivery_rate: 0,
        bank_verified: false,
        is_flagged: false,
      })
      .select()
      .single()

    if (error) throw error
    return doer
  },

  /**
   * Create doer activation record
   * Called after doer record is created
   */
  async createDoerActivation(doerId: string): Promise<void> {
    const supabase = getSupabase()
    const { error } = await supabase
      .from('doer_activation')
      .insert({
        doer_id: doerId,
        training_completed: false,
        quiz_passed: false,
        total_quiz_attempts: 0,
        bank_details_added: false,
        is_fully_activated: false,
      })

    if (error) throw error
  },

  /**
   * Update doer profile setup (qualification, skills, experience)
   */
  async updateProfileSetup(
    doerId: string,
    data: {
      qualification?: Qualification
      university_id?: string
      experience_level?: ExperienceLevel
      bio?: string
    }
  ): Promise<Doer> {
    const supabase = getSupabase()
    const { data: doer, error } = await supabase
      .from('doers')
      .update(data)
      .eq('id', doerId)
      .select()
      .single()

    if (error) throw error
    return doer
  },

  /**
   * Update doer skills
   */
  async updateSkills(doerId: string, skillIds: string[]): Promise<void> {
    const supabase = getSupabase()
    // First, remove existing skills
    await supabase
      .from('doer_skills')
      .delete()
      .eq('doer_id', doerId)

    // Then, add new skills
    if (skillIds.length > 0) {
      const { error } = await supabase
        .from('doer_skills')
        .insert(
          skillIds.map((skillId) => ({
            doer_id: doerId,
            skill_id: skillId,
            proficiency_level: 'beginner' as ExperienceLevel,
            is_verified: false,
          }))
        )

      if (error) throw error
    }
  },

  /**
   * Update doer subjects
   */
  async updateSubjects(doerId: string, subjectIds: string[]): Promise<void> {
    const supabase = getSupabase()
    // First, remove existing subjects
    await supabase
      .from('doer_subjects')
      .delete()
      .eq('doer_id', doerId)

    // Then, add new subjects
    if (subjectIds.length > 0) {
      const { error } = await supabase
        .from('doer_subjects')
        .insert(
          subjectIds.map((subjectId) => ({
            doer_id: doerId,
            subject_id: subjectId,
          }))
        )

      if (error) throw error
    }
  },

  /**
   * Get all available skills
   */
  async getSkills() {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('skills')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return data
  },

  /**
   * Get all available subjects
   */
  async getSubjects() {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('subjects')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return data
  },

  /**
   * Get all universities
   */
  async getUniversities() {
    const supabase = getSupabase()
    const { data, error } = await supabase
      .from('universities')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return data
  },
}

/**
 * Sign out the current user
 * Standalone export for convenience
 */
export async function signOut(): Promise<void> {
  await authService.signOut()
}
