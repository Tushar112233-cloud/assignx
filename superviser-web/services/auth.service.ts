import { apiFetch, setTokens, clearTokens, getAccessToken } from "@/lib/api/client"
import { getStoredUser, storeUser, clearStoredUser } from "@/lib/api/auth"
import type { Supervisor, SupervisorActivation } from "@/types"

/**
 * Authentication service for managing user auth operations.
 * Backed by Express API at /api/auth/*.
 */
export const authService = {
  /**
   * Get current session (checks if access token exists)
   */
  async getSession() {
    const token = getAccessToken()
    if (!token) return null
    try {
      const data = await apiFetch<{ user: any; token: string }>("/api/auth/me")
      return { user: data.user, access_token: token }
    } catch {
      return null
    }
  },

  /**
   * Get current user from stored data or API
   */
  async getUser() {
    const stored = getStoredUser()
    if (stored) return stored
    try {
      const data = await apiFetch<{ user: any }>("/api/auth/me")
      if (data?.user) {
        storeUser(data.user)
        return data.user
      }
      return null
    } catch {
      return null
    }
  },

  /**
   * Sign up with email and password
   */
  async signUp(email: string, password: string, fullName: string, phone: string) {
    const data = await apiFetch<{ user: any; access_token: string; refresh_token: string }>(
      "/api/auth/signup",
      {
        method: "POST",
        body: JSON.stringify({ email, password, full_name: fullName, phone, role: "supervisor" }),
      }
    )

    if (data?.access_token) {
      setTokens(data.access_token, data.refresh_token)
      if (data.user) storeUser(data.user)
    }

    return data
  },

  /**
   * Sign in with email and password
   */
  async signIn(email: string, password: string) {
    const data = await apiFetch<{ user: any; access_token: string; refresh_token: string }>(
      "/api/auth/login",
      {
        method: "POST",
        body: JSON.stringify({ email, password }),
      }
    )

    if (data?.access_token) {
      setTokens(data.access_token, data.refresh_token)
      if (data.user) storeUser(data.user)
    }

    return data
  },

  /**
   * Sign in with Google OAuth
   */
  async signInWithGoogle() {
    // Redirect to the Express API OAuth endpoint
    window.location.href = `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"}/api/auth/google?redirect=${encodeURIComponent(window.location.origin + "/auth/callback")}`
    return { url: "" }
  },

  /**
   * Sign out
   */
  async signOut() {
    try {
      await apiFetch("/api/auth/logout", { method: "POST" })
    } catch {
      // Ignore - clear tokens anyway
    }
    clearTokens()
    clearStoredUser()
  },

  /**
   * Reset password
   */
  async resetPassword(email: string) {
    const data = await apiFetch("/api/auth/reset-password", {
      method: "POST",
      body: JSON.stringify({ email }),
    })
    return data
  },

  /**
   * Update password
   */
  async updatePassword(newPassword: string) {
    const data = await apiFetch("/api/auth/update-password", {
      method: "POST",
      body: JSON.stringify({ password: newPassword }),
    })
    return data
  },
}

/**
 * Supervisor service for managing supervisor-specific operations
 */
export const supervisorService = {
  /**
   * Get current supervisor profile
   */
  async getSupervisor(): Promise<Supervisor | null> {
    try {
      const data = await apiFetch<Supervisor>("/api/supervisors/me")
      return data
    } catch {
      return null
    }
  },

  /**
   * Get supervisor activation record by supervisor ID
   */
  async getSupervisorActivation(supervisorId: string): Promise<SupervisorActivation | null> {
    try {
      const data = await apiFetch<SupervisorActivation>(
        `/api/supervisors/${supervisorId}/activation`
      )
      return data
    } catch {
      return null
    }
  },

  /**
   * Create supervisor profile with required values
   * Called from profile-setup page after user provides qualification/experience
   */
  async createSupervisor(data: {
    qualification: string
    years_of_experience: number
    cv_url?: string
  }): Promise<Supervisor> {
    const supervisor = await apiFetch<Supervisor>("/api/supervisors", {
      method: "POST",
      body: JSON.stringify({
        qualification: data.qualification,
        years_of_experience: data.years_of_experience,
        cv_url: data.cv_url || null,
      }),
    })
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
    const supervisor = await apiFetch<Supervisor>(`/api/supervisors/${supervisorId}`, {
      method: "PATCH",
      body: JSON.stringify(data),
    })
    return supervisor
  },

  /**
   * Create supervisor activation record
   * Called after supervisor record is created
   */
  async createSupervisorActivation(supervisorId: string): Promise<void> {
    await apiFetch(`/api/supervisors/${supervisorId}/activation`, {
      method: "POST",
      body: JSON.stringify({
        training_completed: false,
        quiz_passed: false,
        total_quiz_attempts: 0,
        cv_submitted: false,
        cv_verified: false,
        bank_details_added: false,
        is_fully_activated: false,
      }),
    })
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
    const activation = await apiFetch<SupervisorActivation>(
      `/api/supervisors/${supervisorId}/activation`,
      {
        method: "PATCH",
        body: JSON.stringify(data),
      }
    )
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
