/**
 * @fileoverview Training service -- CRUD operations for training modules and progress.
 * Uses Express API instead of Supabase.
 * @module lib/services/training
 */

import { apiFetch } from "@/lib/api/client"

export async function getTrainingModules(role: string) {
  const data = await apiFetch<{ modules: unknown[] }>(
    `/api/training/modules?role=${role}`
  )
  return data.modules || []
}

export async function getTrainingProgress(profileId: string) {
  const data = await apiFetch<{ progress: unknown[] }>(
    `/api/training/progress?profileId=${profileId}`
  )
  return data.progress || []
}

export async function markModuleComplete(profileId: string, moduleId: string) {
  await apiFetch("/api/training/progress", {
    method: "POST",
    body: JSON.stringify({
      profileId,
      moduleId,
      status: "completed",
      progressPercentage: 100,
    }),
  })
}

export async function isTrainingComplete(profileId: string, role: string) {
  const data = await apiFetch<{ complete: boolean }>(
    `/api/training/status?profileId=${profileId}&role=${role}`
  )
  return data.complete
}
