'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { ProfileSetupForm } from '@/components/onboarding/ProfileSetupForm'
import { ROUTES } from '@/lib/constants'
import { createClient } from '@/lib/supabase/client'
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
    const supabase = createClient()

    try {
      const { data: { session } } = await supabase.auth.getSession()
      const authUser = session?.user ?? null
      const authError = !authUser ? new Error('No session') : null

      if (authError || !authUser) {
        throw new Error('You must be logged in to complete profile setup')
      }

      // Check if doer record already exists
      let { data: doerRecord } = await supabase
        .from('doers')
        .select('id')
        .eq('profile_id', authUser.id)
        .single()

      if (!doerRecord) {
        // CREATE new doer record with the form data
        const { data: newDoer, error: createError } = await supabase
          .from('doers')
          .insert({
            profile_id: authUser.id,
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
          })
          .select('id')
          .single()

        if (createError) {
          throw new Error(`Failed to create doer profile: ${createError.message}`)
        }

        doerRecord = newDoer

        // Create activation record for new doer
        const { error: activationError } = await supabase
          .from('doer_activation')
          .insert({
            doer_id: doerRecord.id,
            training_completed: false,
            quiz_passed: false,
            total_quiz_attempts: 0,
            bank_details_added: false,
            is_fully_activated: false,
          })

        if (activationError) {
          console.error('Failed to create activation record:', activationError)
        }
      } else {
        // UPDATE existing doer record
        const { error: updateError } = await supabase
          .from('doers')
          .update({
            qualification: data.qualification,
            experience_level: data.experienceLevel,
            university_name: data.universityName || null,
          })
          .eq('id', doerRecord.id)

        if (updateError) {
          throw new Error(`Failed to update profile: ${updateError.message}`)
        }
      }

      // Insert skills (if any selected)
      if (data.skills.length > 0) {
        await supabase
          .from('doer_skills')
          .delete()
          .eq('doer_id', doerRecord.id)

        const skillInserts = data.skills.map(skillId => ({
          doer_id: doerRecord.id,
          skill_id: skillId,
          proficiency_level: 'intermediate',
        }))

        const { error: skillsError } = await supabase
          .from('doer_skills')
          .insert(skillInserts)

        if (skillsError) {
          console.error('Skills insert error:', skillsError)
        }
      }

      // Insert subjects (if any selected)
      if (data.subjects.length > 0) {
        await supabase
          .from('doer_subjects')
          .delete()
          .eq('doer_id', doerRecord.id)

        const subjectInserts = data.subjects.map((subjectId, index) => ({
          doer_id: doerRecord.id,
          subject_id: subjectId,
          is_primary: index === 0,
        }))

        const { error: subjectsError } = await supabase
          .from('doer_subjects')
          .insert(subjectInserts)

        if (subjectsError) {
          console.error('Subjects insert error:', subjectsError)
        }
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
