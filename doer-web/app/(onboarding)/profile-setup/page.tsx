'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { ProfileSetupForm } from '@/components/onboarding/ProfileSetupForm'
import { ROUTES } from '@/lib/constants'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { useAuth } from '@/hooks/useAuth'

/**
 * Profile setup page
 * Collects user qualification, skills, and experience after registration
 * Creates the doer record with user-provided values
 */
export default function ProfileSetupPage() {
  const router = useRouter()
  const { user } = useAuth()
  const [error, setError] = useState<string | null>(null)

  /**
   * Handle profile setup completion
   * Creates doer record and saves qualification, skills, and subjects
   */
  const handleComplete = async (data: {
    qualification: string
    universityName?: string
    skills: string[]
    subjects: string[]
    experienceLevel: string
  }) => {
    setError(null)

    try {
      const token = getAccessToken()
      if (!token || !user?.id) {
        throw new Error('You must be logged in to complete profile setup')
      }

      // Check if doer record already exists
      let doerRecord: { id: string } | null = null
      try {
        doerRecord = await apiClient<{ id: string }>(`/api/doers/me`)
      } catch {
        // No doer record yet
      }

      if (!doerRecord) {
        // Doer record should have been created during signup (doer-signup flow).
        // If it doesn't exist, the user may need to re-register.
        throw new Error('Doer profile not found. Please sign up again.')
      }

      // UPDATE existing doer record with profile setup data
      await apiClient(`/api/doers/${doerRecord.id}`, {
        method: 'PUT',
        body: JSON.stringify({
          qualification: data.qualification,
          experienceLevel: data.experienceLevel,
          universityName: data.universityName || null,
        }),
      })

      // Insert skills (if any selected)
      if (data.skills.length > 0) {
        await apiClient(`/api/doers/${doerRecord.id}/skills`, {
          method: 'POST',
          body: JSON.stringify({
            skills: data.skills.map(skillId => ({
              skillId,
              proficiencyLevel: 'intermediate',
            })),
          }),
        })
      }

      // Insert subjects (if any selected)
      if (data.subjects.length > 0) {
        await apiClient(`/api/doers/${doerRecord.id}/subjects`, {
          method: 'POST',
          body: JSON.stringify({
            subjects: data.subjects.map((subjectId, index) => ({
              subjectId,
              isPrimary: index === 0,
            })),
          }),
        })
      }

      // Navigate to training
      router.push(ROUTES.training)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred'
      setError(errorMessage)
      console.error('Profile setup error:', err)
    }
  }

  return (
    <>
      {error && (
        <div className="fixed top-4 left-4 right-4 z-50 rounded-md bg-destructive/10 p-3 text-sm text-destructive">
          {error}
        </div>
      )}
      <ProfileSetupForm
        onComplete={handleComplete}
        userName={user?.full_name || 'User'}
      />
    </>
  )
}
