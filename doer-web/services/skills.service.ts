/**
 * Skills Service
 * Handles skill-related operations for doers via API
 * @module services/skills.service
 */

import { apiClient } from '@/lib/api/client'
import type { Skill, SkillWithVerification, ExperienceLevel } from '@/types/database'

export async function getDoerSkills(doerId: string): Promise<SkillWithVerification[]> {
  try {
    // Doer skills are embedded in the doer document; fetch via doer profile
    const doer = await apiClient<{ skills: SkillWithVerification[] }>(`/api/doers/me`)
    return doer.skills || []
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
    // The API expects { skills: [...] } to replace the full skills array
    // First get existing skills, then add the new one
    const doer = await apiClient<{ skills: any[] }>(`/api/doers/me`)
    const existingSkills = doer.skills || []
    const newSkills = [...existingSkills, { skillId, proficiencyLevel }]
    await apiClient(`/api/doers/${doerId}/skills`, {
      method: 'POST',
      body: JSON.stringify({ skills: newSkills }),
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
    // The API replaces skills entirely; fetch current, remove target, re-post
    const doer = await apiClient<{ skills: any[] }>(`/api/doers/me`)
    const existingSkills = (doer.skills || []).filter(
      (s: any) => (s.skillId || s.skill_id || s.id) !== skillId
    )
    await apiClient(`/api/doers/${doerId}/skills`, {
      method: 'POST',
      body: JSON.stringify({ skills: existingSkills }),
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
