import { apiClient } from '@/lib/api/client'

export async function getTrainingModules(role: string) {
  const data = await apiClient<{ modules: any[] }>(`/api/training/modules?role=${role}`)
  return data.modules || []
}

export async function getTrainingProgress(profileId: string) {
  const data = await apiClient<{ progress: any[] }>(`/api/training/progress?profile_id=${profileId}`)
  return data.progress || []
}

export async function markModuleComplete(profileId: string, moduleId: string) {
  await apiClient(`/api/training/progress/${moduleId}`, {
    method: 'PUT',
    body: JSON.stringify({
      profile_id: profileId,
      status: 'completed',
      progress_percentage: 100,
      completed_at: new Date().toISOString(),
    }),
  })
}

export async function isTrainingComplete(profileId: string, role: string) {
  try {
    const data = await apiClient<{ complete: boolean }>(`/api/training/status?profile_id=${profileId}&role=${role}`)
    return data.complete ?? false
  } catch {
    return false
  }
}
