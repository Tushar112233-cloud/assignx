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

export async function getTrainingProgress() {
  const data = await apiFetch<{ progress: unknown[] }>("/api/training/progress")
  return data.progress || []
}

export async function markModuleComplete(moduleId: string) {
  await apiFetch(`/api/training/progress/${moduleId}`, {
    method: "PUT",
    body: JSON.stringify({
      progress: 100,
    }),
  })
}

export async function isTrainingComplete(role: string) {
  const data = await apiFetch<{ complete: boolean }>(`/api/training/status?role=${role}`)
  return data.complete
}
