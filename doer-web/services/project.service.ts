/**
 * Project service using API client
 */

import { apiClient, apiUpload } from '@/lib/api/client'
import { logger } from '@/lib/logger'
import type {
  Project,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
  ProjectStatus,
} from '@/types/database'

export interface ProjectFilters {
  status?: ProjectStatus | ProjectStatus[]
  subject?: string
  search?: string
}

export interface ProjectSort {
  field: 'deadline' | 'doer_payout' | 'created_at' | 'title'
  direction: 'asc' | 'desc'
}

export interface ProjectWithSupervisor extends Project {
  supervisor?: {
    id: string
    full_name: string
    avatar_url?: string
  }
}

export async function getDoerProjects(
  doerId: string,
  filters?: ProjectFilters,
  sort?: ProjectSort
): Promise<Project[]> {
  const params = new URLSearchParams()
  params.set('doer_id', doerId)

  if (filters?.status) {
    if (Array.isArray(filters.status)) {
      params.set('status', filters.status.join(','))
    } else {
      params.set('status', filters.status)
    }
  }
  if (filters?.subject) params.set('subject_id', filters.subject)
  if (filters?.search) params.set('search', filters.search)
  if (sort) {
    params.set('sort_by', sort.field)
    params.set('sort_dir', sort.direction)
  }

  try {
    const data = await apiClient<{ projects: Project[] }>(`/api/projects?${params}`)
    return data.projects || []
  } catch (err) {
    logger.error('Project', 'Error fetching projects:', err)
    throw err
  }
}

export async function getProjectById(projectId: string): Promise<Project | null> {
  try {
    return await apiClient<Project>(`/api/projects/${projectId}`)
  } catch (err) {
    logger.error('Project', 'Error fetching project:', err)
    throw err
  }
}

export async function getProjectFiles(projectId: string): Promise<ProjectFile[]> {
  try {
    const data = await apiClient<{ files: ProjectFile[] }>(`/api/projects/${projectId}/files`)
    return data.files || []
  } catch (err) {
    logger.error('Project', 'Error fetching project files:', err)
    throw err
  }
}

export async function getProjectDeliverables(
  projectId: string
): Promise<ProjectDeliverable[]> {
  try {
    const data = await apiClient<{ deliverables: ProjectDeliverable[] }>(`/api/projects/${projectId}/deliverables`)
    return data.deliverables || []
  } catch (err) {
    logger.error('Project', 'Error fetching deliverables:', err)
    throw err
  }
}

export async function getProjectRevisions(
  projectId: string
): Promise<ProjectRevision[]> {
  try {
    const data = await apiClient<{ revisions: ProjectRevision[] }>(`/api/projects/${projectId}/revisions`)
    return data.revisions || []
  } catch (err) {
    logger.error('Project', 'Error fetching revisions:', err)
    throw err
  }
}

export async function updateProjectStatus(
  projectId: string,
  status: ProjectStatus
): Promise<Project> {
  try {
    return await apiClient<Project>(`/api/projects/${projectId}/status`, {
      method: 'PUT',
      body: JSON.stringify({ status }),
    })
  } catch (err) {
    logger.error('Project', 'Error updating project status:', err)
    throw err
  }
}

export async function acceptTask(
  projectId: string,
  doerId: string
): Promise<Project> {
  try {
    return await apiClient<Project>(`/api/projects/${projectId}/accept`, {
      method: 'POST',
      body: JSON.stringify({ doer_id: doerId }),
    })
  } catch (err) {
    logger.error('Project', 'Error accepting task:', err)
    throw err
  }
}

export async function startProject(projectId: string): Promise<Project> {
  return updateProjectStatus(projectId, 'in_progress')
}

export async function submitProject(projectId: string): Promise<Project> {
  return updateProjectStatus(projectId, 'submitted_for_qc')
}

export async function uploadDeliverable(
  projectId: string,
  _doerId: string,
  file: File
): Promise<ProjectDeliverable> {
  try {
    return await apiUpload<ProjectDeliverable>(
      `/api/projects/${projectId}/deliverables`,
      file,
      'deliverables'
    )
  } catch (err) {
    logger.error('Project', 'Error uploading deliverable:', err)
    throw err
  }
}

export async function getActiveProjectsCount(doerId: string): Promise<number> {
  try {
    const data = await apiClient<{ count: number }>(`/api/projects/count?doer_id=${doerId}&status=assigned,in_progress,revision_requested`)
    return data.count || 0
  } catch (err) {
    logger.error('Project', 'Error getting active projects count:', err)
    throw err
  }
}

export async function getProjectsByCategory(
  doerId: string,
  category: 'active' | 'review' | 'completed'
): Promise<Project[]> {
  const statusMap: Record<string, ProjectStatus[]> = {
    active: ['assigned', 'in_progress', 'in_revision', 'revision_requested'],
    review: ['submitted_for_qc', 'qc_in_progress', 'qc_approved', 'delivered'],
    completed: ['completed', 'auto_approved'],
  }

  return getDoerProjects(doerId, { status: statusMap[category] })
}

export async function getOpenPoolTasks(
  sort?: ProjectSort
): Promise<ProjectWithSupervisor[]> {
  const params = new URLSearchParams()
  params.set('status', 'paid')
  params.set('unassigned', 'true')
  if (sort) {
    params.set('sort_by', sort.field)
    params.set('sort_dir', sort.direction)
  }

  try {
    const data = await apiClient<{ projects: ProjectWithSupervisor[] }>(`/api/projects?${params}`)
    return data.projects || []
  } catch (err) {
    logger.error('Project', 'Error fetching open pool tasks:', err)
    throw err
  }
}

export async function getAssignedTasks(
  doerId: string
): Promise<ProjectWithSupervisor[]> {
  const params = new URLSearchParams()
  params.set('doer_id', doerId)
  params.set('status', 'assigned,in_progress,in_revision,revision_requested')

  try {
    const data = await apiClient<{ projects: ProjectWithSupervisor[] }>(`/api/projects?${params}`)
    return data.projects || []
  } catch (err) {
    logger.error('Project', 'Error fetching assigned tasks:', err)
    throw err
  }
}

export async function acceptPoolTask(
  projectId: string,
  doerId: string
): Promise<Project> {
  return acceptTask(projectId, doerId)
}

export async function getDoerStats(doerId: string): Promise<{
  activeCount: number
  completedCount: number
  totalEarnings: number
  averageRating: number
}> {
  try {
    return await apiClient<{
      activeCount: number
      completedCount: number
      totalEarnings: number
      averageRating: number
    }>(`/api/doers/${doerId}/stats`)
  } catch (err) {
    logger.error('Project', 'Error getting doer stats:', err)
    return { activeCount: 0, completedCount: 0, totalEarnings: 0, averageRating: 0 }
  }
}

export function isDeadlineUrgent(deadline: string | Date): boolean {
  const deadlineDate = new Date(deadline)
  const now = new Date()
  const hoursUntilDeadline = (deadlineDate.getTime() - now.getTime()) / (1000 * 60 * 60)
  return hoursUntilDeadline < 24 && hoursUntilDeadline > 0
}
