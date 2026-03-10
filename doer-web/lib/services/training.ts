import { apiClient } from '@/lib/api/client'

export async function getTrainingModules(role: string) {
  const data = await apiClient<{ modules: any[] }>(`/api/training/modules?role=${role}`)
  return data.modules || []
}

export async function getTrainingProgress() {
  const data = await apiClient<{ progress: any[] }>('/api/training/progress')
  return data.progress || []
}

export async function markModuleComplete(moduleId: string) {
  await apiClient(`/api/training/progress/${moduleId}`, {
    method: 'PUT',
    body: JSON.stringify({
      status: 'completed',
      progress_percentage: 100,
      completed_at: new Date().toISOString(),
    }),
  })
}

export async function isTrainingComplete(role: string) {
  try {
    const data = await apiClient<{ trainingCompleted: boolean; complete: boolean }>(`/api/training/status?role=${role}`)
    return data.trainingCompleted ?? data.complete ?? false
  } catch {
    return false
  }
}

export async function completeTraining() {
  await apiClient('/api/training/complete', { method: 'POST' })
}
