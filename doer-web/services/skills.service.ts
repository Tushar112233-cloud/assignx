/**
 * Skills Service
 * Handles skill-related operations for doers via API
 * @module services/skills.service
 */

import { apiClient } from '@/lib/api/client'
import type { Skill, SkillWithVerification, ExperienceLevel } from '@/types/database'

export async function getDoerSkills(doerId: string): Promise<SkillWithVerification[]> {
  try {
    const data = await apiClient<{ skills: SkillWithVerification[] }>(`/api/doers/${doerId}/skills`)
    return data.skills || []
  } catch {
    return []
  }
}

export async function addDoerSkill(
  doerId: string,
  skillId: string,
  proficiencyLevel: ExperienceLevel
): Promise<{ success: boolean; error?: string }> {
  try {
    await apiClient(`/api/doers/${doerId}/skills`, {
      method: 'POST',
      body: JSON.stringify({ skill_id: skillId, proficiency_level: proficiencyLevel }),
    })
    return { success: true }
  } catch (err) {
    return { success: false, error: (err as Error).message }
  }
}

export async function removeDoerSkill(
  doerId: string,
  skillId: string
): Promise<{ success: boolean; error?: string }> {
  try {
    await apiClient(`/api/doers/${doerId}/skills/${skillId}`, {
      method: 'DELETE',
    })
    return { success: true }
  } catch (err) {
    return { success: false, error: (err as Error).message }
  }
}

export async function requestSkillVerification(
  _doerId: string,
  _skillId: string
): Promise<{ success: boolean; error?: string }> {
  return { success: true }
}
