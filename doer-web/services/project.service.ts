/**
 * Project service for Supabase operations
 */

import { createClient } from '@/lib/supabase/client'
import { verifyDoerOwnership, verifyProjectAccess } from '@/lib/auth-helpers'
import { logger } from '@/lib/logger'
import { validateFile, generateSafeFileName } from '@/lib/file-validation'
import type {
  Project,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
  ProjectStatus,
} from '@/types/database'

/** Filter options for projects */
export interface ProjectFilters {
  status?: ProjectStatus | ProjectStatus[]
  subject?: string
  isUrgent?: boolean
  search?: string
}

/** Sort options for projects */
export interface ProjectSort {
  field: 'deadline' | 'doer_payout' | 'created_at' | 'title'
  direction: 'asc' | 'desc'
}

/** Extended project with supervisor info */
export interface ProjectWithSupervisor extends Project {
  supervisor?: {
    id: string
    profile: {
      full_name: string
      avatar_url?: string
    }
  }
}

/**
 * Fetch projects for the current doer with filters
 * @security Verifies ownership before returning data
 */
export async function getDoerProjects(
  doerId: string,
  filters?: ProjectFilters,
  sort?: ProjectSort
): Promise<Project[]> {
  // SECURITY: Verify the authenticated user owns this doer record
  await verifyDoerOwnership(doerId)

  const supabase = createClient()

  let query = supabase
    .from('projects')
    .select('*')
    .eq('doer_id', doerId)

  // Apply status filter
  if (filters?.status) {
    if (Array.isArray(filters.status)) {
      query = query.in('status', filters.status)
    } else {
      query = query.eq('status', filters.status)
    }
  }

  // Apply subject filter
  if (filters?.subject) {
    query = query.eq('subject_id', filters.subject)
  }

  // Apply urgency filter
  if (filters?.isUrgent !== undefined) {
    query = query.eq('is_urgent', filters.isUrgent)
  }

  // Apply search filter
  if (filters?.search) {
    query = query.ilike('title', `%${filters.search}%`)
  }

  // Apply sorting
  if (sort) {
    query = query.order(sort.field, { ascending: sort.direction === 'asc' })
  } else {
    query = query.order('deadline', { ascending: true })
  }

  const { data, error } = await query

  if (error) {
    logger.error('Project', 'Error fetching projects:', error)
    throw error
  }

  return data || []
}

/**
 * Fetch a single project by ID
 * @security Verifies project access before returning data
 */
export async function getProjectById(projectId: string): Promise<Project | null> {
  // SECURITY: Verify the authenticated user has access to this project
  await verifyProjectAccess(projectId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('projects')
    .select('*')
    .eq('id', projectId)
    .single()

  if (error) {
    logger.error('Project', 'Error fetching project:', error)
    throw error
  }

  return data
}

/**
 * Fetch project files
 * @security Verifies project access before returning data
 */
export async function getProjectFiles(projectId: string): Promise<ProjectFile[]> {
  // SECURITY: Verify the authenticated user has access to this project
  await verifyProjectAccess(projectId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('project_files')
    .select('*')
    .eq('project_id', projectId)
    .order('created_at', { ascending: false })

  if (error) {
    logger.error('Project', 'Error fetching project files:', error)
    throw error
  }

  return data || []
}

/**
 * Fetch project deliverables
 * @security Verifies project access before returning data
 */
export async function getProjectDeliverables(
  projectId: string
): Promise<ProjectDeliverable[]> {
  // SECURITY: Verify the authenticated user has access to this project
  await verifyProjectAccess(projectId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('project_deliverables')
    .select('*')
    .eq('project_id', projectId)
    .order('version', { ascending: false })

  if (error) {
    logger.error('Project', 'Error fetching deliverables:', error)
    throw error
  }

  return data || []
}

/**
 * Fetch project revisions
 * @security Verifies project access before returning data
 */
export async function getProjectRevisions(
  projectId: string
): Promise<ProjectRevision[]> {
  // SECURITY: Verify the authenticated user has access to this project
  await verifyProjectAccess(projectId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('project_revisions')
    .select('*')
    .eq('project_id', projectId)
    .order('created_at', { ascending: false })

  if (error) {
    logger.error('Project', 'Error fetching revisions:', error)
    throw error
  }

  return data || []
}

/**
 * Update project status
 * @security Verifies project access before updating
 */
export async function updateProjectStatus(
  projectId: string,
  status: ProjectStatus
): Promise<Project> {
  // SECURITY: Verify the authenticated user has access to this project
  await verifyProjectAccess(projectId)

  const supabase = createClient()

  const updateData: Partial<Project> = {
    status,
    updated_at: new Date().toISOString(),
  }

  // Add timestamp based on status
  if (status === 'submitted') {
    updateData.submitted_at = new Date().toISOString()
  } else if (status === 'submitted_for_qc') {
    updateData.status_updated_at = new Date().toISOString()
  } else if (status === 'completed') {
    updateData.completed_at = new Date().toISOString()
  }

  const { data, error } = await supabase
    .from('projects')
    .update(updateData)
    .eq('id', projectId)
    .select()
    .single()

  if (error) {
    logger.error('Project', 'Error updating project status:', error)
    throw error
  }

  return data
}

/**
 * Accept a task from the pool
 * @security Verifies ownership of doer record before accepting
 */
export async function acceptTask(
  projectId: string,
  doerId: string
): Promise<Project> {
  // SECURITY: Verify the authenticated user owns this doer record
  await verifyDoerOwnership(doerId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('projects')
    .update({
      doer_id: doerId,
      status: 'assigned' as ProjectStatus,
      assigned_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', projectId)
    .is('doer_id', null)
    .eq('status', 'paid')
    .select()
    .single()

  if (error) {
    logger.error('Project', 'Error accepting task:', error)
    throw error
  }

  return data
}

/**
 * Start working on a project
 */
export async function startProject(projectId: string): Promise<Project> {
  return updateProjectStatus(projectId, 'in_progress')
}

/**
 * Submit project for review
 */
export async function submitProject(projectId: string): Promise<Project> {
  return updateProjectStatus(projectId, 'submitted_for_qc')
}

/**
 * Upload a deliverable file
 * @security Verifies ownership, project access, and file validity before uploading
 */
export async function uploadDeliverable(
  projectId: string,
  doerId: string,
  file: File
): Promise<ProjectDeliverable> {
  // SECURITY: Verify the authenticated user owns this doer record
  await verifyDoerOwnership(doerId)
  // SECURITY: Verify the authenticated user has access to this project
  await verifyProjectAccess(projectId)

  // SECURITY: Validate file type, size, and extension
  const validation = validateFile(file)
  if (!validation.valid) {
    throw new Error(validation.error || 'Invalid file')
  }

  const supabase = createClient()

  // Get the authenticated user's profile_id for uploaded_by FK (profiles.id)
  const { data: { session: authSession } } = await supabase.auth.getSession()
  const profileId = authSession?.user?.id
  if (!profileId) throw new Error('Authentication required')

  // Generate safe filename to prevent path traversal attacks
  const safeFileName = generateSafeFileName(file.name, projectId)

  const { data: uploadData, error: uploadError } = await supabase.storage
    .from('deliverables')
    .upload(safeFileName, file, {
      contentType: file.type,
      upsert: false,
    })

  if (uploadError) {
    logger.error('Project', 'Error uploading file:', uploadError)
    throw uploadError
  }

  // Get public URL
  const { data: urlData } = supabase.storage
    .from('deliverables')
    .getPublicUrl(uploadData.path)

  // Get the latest version number
  const { data: existingDeliverables } = await supabase
    .from('project_deliverables')
    .select('version')
    .eq('project_id', projectId)
    .order('version', { ascending: false })
    .limit(1)

  const nextVersion = existingDeliverables?.[0]?.version
    ? existingDeliverables[0].version + 1
    : 1

  // Create deliverable record
  const { data, error } = await supabase
    .from('project_deliverables')
    .insert({
      project_id: projectId,
      uploaded_by: profileId,
      file_name: file.name,
      file_url: urlData.publicUrl,
      file_type: file.type,
      file_size_bytes: file.size,
      version: nextVersion,
      qc_status: 'pending',
    })
    .select()
    .single()

  if (error) {
    logger.error('Project', 'Error creating deliverable:', error)
    throw error
  }

  return data
}

/**
 * Get active projects count
 * @security Verifies ownership before returning data
 */
export async function getActiveProjectsCount(doerId: string): Promise<number> {
  // SECURITY: Verify the authenticated user owns this doer record
  await verifyDoerOwnership(doerId)

  const supabase = createClient()

  const { count, error } = await supabase
    .from('projects')
    .select('*', { count: 'exact', head: true })
    .eq('doer_id', doerId)
    .in('status', ['assigned', 'in_progress', 'revision_requested'])

  if (error) {
    logger.error('Project', 'Error getting active projects count:', error)
    throw error
  }

  return count || 0
}

/**
 * Get projects by status category
 */
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

/**
 * Fetch open pool tasks (unassigned projects)
 */
export async function getOpenPoolTasks(
  sort?: ProjectSort
): Promise<ProjectWithSupervisor[]> {
  const supabase = createClient()

  let query = supabase
    .from('projects')
    .select(`
      *,
      supervisor:supervisors!projects_supervisor_id_fkey (
        id,
        profile:profiles!supervisors_profile_id_fkey (
          full_name,
          avatar_url
        )
      )
    `)
    .is('doer_id', null)
    .eq('status', 'paid')

  // Apply sorting
  if (sort) {
    query = query.order(sort.field, { ascending: sort.direction === 'asc' })
  } else {
    query = query.order('deadline', { ascending: true })
  }

  const { data, error } = await query

  if (error) {
    logger.error('Project', 'Error fetching open pool tasks:', error)
    throw error
  }

  return (data || []) as ProjectWithSupervisor[]
}

/**
 * Fetch assigned tasks for a doer with supervisor info
 * @security Verifies ownership before returning data
 */
export async function getAssignedTasks(
  doerId: string
): Promise<ProjectWithSupervisor[]> {
  // SECURITY: Verify the authenticated user owns this doer record
  await verifyDoerOwnership(doerId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      supervisor:supervisors!projects_supervisor_id_fkey (
        id,
        profile:profiles!supervisors_profile_id_fkey (
          full_name,
          avatar_url
        )
      )
    `)
    .eq('doer_id', doerId)
    .in('status', ['assigned', 'in_progress', 'in_revision', 'revision_requested'])
    .order('deadline', { ascending: true })

  if (error) {
    logger.error('Project', 'Error fetching assigned tasks:', error)
    throw error
  }

  return (data || []) as ProjectWithSupervisor[]
}

/**
 * Accept a task from the open pool
 * @security Verifies ownership of doer record before accepting
 */
export async function acceptPoolTask(
  projectId: string,
  doerId: string
): Promise<Project> {
  // SECURITY: Verify the authenticated user owns this doer record
  await verifyDoerOwnership(doerId)

  const supabase = createClient()

  const { data, error } = await supabase
    .from('projects')
    .update({
      doer_id: doerId,
      status: 'assigned' as ProjectStatus,
      doer_assigned_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', projectId)
    .is('doer_id', null)
    .eq('status', 'paid')
    .select()
    .single()

  if (error) {
    logger.error('Project', 'Error accepting pool task:', error)
    throw error
  }

  return data
}

/**
 * Get doer statistics
 * @security Verifies ownership before returning data
 */
export async function getDoerStats(doerId: string): Promise<{
  activeCount: number
  completedCount: number
  totalEarnings: number
  averageRating: number
}> {
  // SECURITY: Verify the authenticated user owns this doer record
  await verifyDoerOwnership(doerId)

  const supabase = createClient()

  // Get active projects count
  const { count: activeCount } = await supabase
    .from('projects')
    .select('*', { count: 'exact', head: true })
    .eq('doer_id', doerId)
    .in('status', ['assigned', 'in_progress', 'in_revision', 'revision_requested'])

  // Get completed projects count
  const { count: completedCount } = await supabase
    .from('projects')
    .select('*', { count: 'exact', head: true })
    .eq('doer_id', doerId)
    .in('status', ['completed', 'auto_approved'])

  // Get doer info for earnings and rating
  const { data: doer } = await supabase
    .from('doers')
    .select('total_earnings, average_rating')
    .eq('id', doerId)
    .single()

  return {
    activeCount: activeCount || 0,
    completedCount: completedCount || 0,
    totalEarnings: doer?.total_earnings || 0,
    averageRating: doer?.average_rating || 0,
  }
}

/**
 * Check if deadline is urgent (less than 24 hours)
 */
export function isDeadlineUrgent(deadline: string | Date): boolean {
  const deadlineDate = new Date(deadline)
  const now = new Date()
  const hoursUntilDeadline = (deadlineDate.getTime() - now.getTime()) / (1000 * 60 * 60)
  return hoursUntilDeadline < 24 && hoursUntilDeadline > 0
}
