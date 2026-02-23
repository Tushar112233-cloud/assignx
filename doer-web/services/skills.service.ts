/**
 * Skills Service
 * Handles skill-related operations for doers
 * @module services/skills.service
 */

import { createClient } from '@/lib/supabase/client'
import type { Skill, SkillWithVerification, ExperienceLevel } from '@/types/database'

/**
 * Get doer skills with verification status
 * @param doerId - The doer ID
 * @returns Array of skills with verification status
 */
export async function getDoerSkills(doerId: string): Promise<SkillWithVerification[]> {
  const supabase = createClient()

  const { data } = await supabase
    .from('doer_skills')
    .select(`
      *,
      skill:skills(*)
    `)
    .eq('doer_id', doerId)

  if (!data) return []

  return data.map((item) => ({
    ...((item.skill as unknown as Skill) || {}),
    proficiency_level: item.proficiency_level,
    is_verified: item.is_verified,
    verified_at: null,
  })) as SkillWithVerification[]
}

/**
 * Add skill to doer
 * @param doerId - The doer ID
 * @param skillId - The skill ID
 * @param proficiencyLevel - Proficiency level
 * @returns Success status and optional error
 */
export async function addDoerSkill(
  doerId: string,
  skillId: string,
  proficiencyLevel: ExperienceLevel
): Promise<{ success: boolean; error?: string }> {
  const supabase = createClient()

  const { error } = await supabase.from('doer_skills').insert({
    doer_id: doerId,
    skill_id: skillId,
    proficiency_level: proficiencyLevel,
    is_verified: false,
  })

  if (error) {
    return { success: false, error: error.message }
  }

  return { success: true }
}

/**
 * Remove skill from doer
 * @param doerId - The doer ID
 * @param skillId - The skill ID
 * @returns Success status and optional error
 */
export async function removeDoerSkill(
  doerId: string,
  skillId: string
): Promise<{ success: boolean; error?: string }> {
  const supabase = createClient()

  const { error } = await supabase
    .from('doer_skills')
    .delete()
    .eq('doer_id', doerId)
    .eq('skill_id', skillId)

  if (error) {
    return { success: false, error: error.message }
  }

  return { success: true }
}

/**
 * Request skill verification
 * @param doerId - The doer ID
 * @param skillId - The skill ID
 * @returns Success status and optional error
 */
export async function requestSkillVerification(
  doerId: string,
  skillId: string
): Promise<{ success: boolean; error?: string }> {
  // In production, this would create a verification request
  return { success: true }
}
