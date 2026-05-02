import { apiClient } from '@/lib/api/client'

export async function getTrainingModules(role: string) {
  const data = await apiClient<{ modules: any[] }>(`/api/training/modules?role=${role}`)
  // Normalize API response (camelCase MongoDB) to frontend format (snake_case)
  return (data.modules || []).map((m: any) => ({
    id: (m._id || m.id || '').toString(),
    title: m.title || '',
    description: m.description || '',
    content_type: m.category || m.content_type || 'video',
    content_url: m.videoUrl || m.content_url || null,
    duration_minutes: m.duration ? Math.round(m.duration / 60) : (m.duration_minutes || 0),
    sequence_order: m.order ?? m.sequence_order ?? 0,
    is_mandatory: m.is_mandatory ?? true,
  }))
}

export async function getTrainingProgress() {
  const data = await apiClient<{ progress: any[] }>('/api/training/progress')
  // Normalize API response to frontend format
  return (data.progress || []).map((p: any) => ({
    module_id: (p.moduleId?._id || p.moduleId || p.module_id || '').toString(),
    status: p.completed ? 'completed' : (p.progress > 0 ? 'in_progress' : 'not_started'),
    progress_percentage: p.progress ?? p.progress_percentage ?? 0,
  }))
}

export async function markModuleComplete(moduleId: string) {
  await apiClient(`/api/training/progress/${moduleId}`, {
    method: 'PUT',
    body: JSON.stringify({
      progress: 100,
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
