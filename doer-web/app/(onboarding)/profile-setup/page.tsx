'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { ProfileSetupForm } from '@/components/onboarding/ProfileSetupForm'
import { ROUTES } from '@/lib/constants'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { useAuth } from '@/hooks/useAuth'
import type { Qualification, ExperienceLevel } from '@/types/common.types'

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
        // CREATE new doer record with the form data
        const newDoer = await apiClient<{ id: string }>('/api/doers', {
          method: 'POST',
          body: JSON.stringify({
            qualification: data.qualification as Qualification,
            experience_level: data.experienceLevel as ExperienceLevel,
            university_name: data.universityName || null,
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
          }),
        })

        doerRecord = newDoer

        // Create activation record for new doer
        try {
          await apiClient(`/api/doers/${doerRecord.id}/activation`, {
            method: 'POST',
            body: JSON.stringify({
              training_completed: false,
              quiz_passed: false,
              total_quiz_attempts: 0,
              bank_details_added: false,
              is_fully_activated: false,
            }),
          })
        } catch (activationError) {
          console.error('Failed to create activation record:', activationError)
        }
      } else {
        // UPDATE existing doer record
        await apiClient(`/api/doers/${doerRecord.id}`, {
          method: 'PUT',
          body: JSON.stringify({
            qualification: data.qualification,
            experience_level: data.experienceLevel,
            university_name: data.universityName || null,
          }),
        })
      }

      // Insert skills (if any selected)
      if (data.skills.length > 0) {
        await apiClient(`/api/doers/${doerRecord.id}/skills`, {
          method: 'POST',
          body: JSON.stringify({
            skills: data.skills.map(skillId => ({
              skill_id: skillId,
              proficiency_level: 'intermediate',
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
              subject_id: subjectId,
              is_primary: index === 0,
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
