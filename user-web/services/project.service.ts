import { createClient } from '@/lib/supabase/client'
import type { Database } from '@/types/database'
import {
  validateBrowserFile,
  sanitizeFileName,
  type AllowedMimeType,
} from '@/lib/validations/file-upload'

/**
 * Type aliases for project-related tables
 */
type Project = Database['public']['Tables']['projects']['Row']
type ProjectInsert = Database['public']['Tables']['projects']['Insert']
type ProjectUpdate = Database['public']['Tables']['projects']['Update']
type ProjectFile = Database['public']['Tables']['project_files']['Row']
type ProjectDeliverable = Database['public']['Tables']['project_deliverables']['Row']
type ProjectRevision = Database['public']['Tables']['project_revisions']['Row']
type ProjectStatusHistory = Database['public']['Tables']['project_status_history']['Row']
type Subject = Database['public']['Tables']['subjects']['Row']
type ReferenceStyle = Database['public']['Tables']['reference_styles']['Row']

/**
 * Project status type
 */
type ProjectStatus = Database['public']['Enums']['project_status']

/**
 * Service type
 */
type ServiceType = Database['public']['Enums']['service_type']

/**
 * Project with related data
 */
interface ProjectWithDetails extends Project {
  subject?: Subject | null
  reference_style?: ReferenceStyle | null
  files?: ProjectFile[]
  deliverables?: ProjectDeliverable[]
}

/**
 * Filter options for fetching projects
 */
interface ProjectFilters {
  status?: ProjectStatus | ProjectStatus[]
  serviceType?: ServiceType
  fromDate?: string
  toDate?: string
  searchTerm?: string
}

const supabase = createClient()

/**
 * Project service for managing user projects.
 * Provides methods for CRUD operations on projects and related data.
 */
export const projectService = {
  /**
   * Fetches all projects for a user with optional filters.
   * @param userId - The user's profile ID
   * @param filters - Optional filters to apply
   * @returns Array of projects with related data
   */
  async getProjects(userId: string, filters?: ProjectFilters): Promise<ProjectWithDetails[]> {
    let query = supabase
      .from('projects')
      .select(`
        *,
        subject:subjects(*),
        reference_style:reference_styles(*)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false })

    // Apply status filter
    if (filters?.status) {
      if (Array.isArray(filters.status)) {
        query = query.in('status', filters.status)
      } else {
        query = query.eq('status', filters.status)
      }
    }

    // Apply service type filter
    if (filters?.serviceType) {
      query = query.eq('service_type', filters.serviceType)
    }

    // Apply date range filter
    if (filters?.fromDate) {
      query = query.gte('created_at', filters.fromDate)
    }
    if (filters?.toDate) {
      query = query.lte('created_at', filters.toDate)
    }

    // Apply search filter
    if (filters?.searchTerm) {
      query = query.or(`title.ilike.%${filters.searchTerm}%,project_number.ilike.%${filters.searchTerm}%`)
    }

    const { data, error } = await query

    if (error) throw error
    return data as ProjectWithDetails[]
  },

  /**
   * Fetches a single project by ID with full details.
   * @param projectId - The project UUID
   * @param userId - The user's profile ID (for authorization)
   * @returns Project with all related data or null
   */
  async getProjectById(projectId: string, userId: string): Promise<ProjectWithDetails | null> {
    const { data, error } = await supabase
      .from('projects')
      .select(`
        *,
        subject:subjects(*),
        reference_style:reference_styles(*)
      `)
      .eq('id', projectId)
      .eq('user_id', userId)
      .single()

    if (error) {
      if (error.code === 'PGRST116') return null
      throw error
    }

    // Fetch files and deliverables separately
    const [filesResult, deliverablesResult] = await Promise.all([
      supabase.from('project_files').select('*').eq('project_id', projectId),
      supabase.from('project_deliverables').select('*').eq('project_id', projectId),
    ])

    return {
      ...data,
      files: filesResult.data || [],
      deliverables: deliverablesResult.data || [],
    } as ProjectWithDetails
  },

  /**
   * Creates a new project.
   * @param projectData - The project data to insert
   * @returns The created project
   */
  async createProject(projectData: ProjectInsert): Promise<Project> {
    const { data, error } = await supabase
      .from('projects')
      .insert(projectData)
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Updates an existing project.
   * @param projectId - The project UUID
   * @param updates - The fields to update
   * @returns The updated project
   */
  async updateProject(projectId: string, updates: ProjectUpdate): Promise<Project> {
    const { data, error } = await supabase
      .from('projects')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', projectId)
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Uploads a file for a project with comprehensive validation.
   * @param projectId - The project UUID
   * @param file - The file to upload
   * @param fileType - The type of file (reference, attachment, etc.)
   * @param allowedTypes - Optional list of allowed MIME types
   * @returns The created file record
   * @throws Error if file validation fails
   */
  async uploadProjectFile(
    projectId: string,
    file: File,
    fileType: string = 'reference',
    allowedTypes?: AllowedMimeType[]
  ): Promise<ProjectFile> {
    // Validate file (type, size, extension, magic bytes)
    const validation = await validateBrowserFile(file, { allowedTypes })
    if (!validation.valid) {
      throw new Error(validation.error || 'File validation failed')
    }

    // Sanitize file name to prevent path traversal
    const safeFileName = sanitizeFileName(file.name)
    const storagePath = `${projectId}/${Date.now()}_${safeFileName}`

    // Upload to storage
    const { error: uploadError } = await supabase.storage
      .from('project-files')
      .upload(storagePath, file, {
        contentType: file.type,
        upsert: false,
      })

    if (uploadError) throw uploadError

    // Get public URL
    const { data: urlData } = supabase.storage
      .from('project-files')
      .getPublicUrl(storagePath)

    // Create file record
    const { data, error } = await supabase
      .from('project_files')
      .insert({
        project_id: projectId,
        file_name: safeFileName,
        file_url: urlData.publicUrl,
        file_type: fileType,
        file_size: file.size,
        mime_type: file.type,
      })
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Approves a delivered project.
   * @param projectId - The project UUID
   * @param feedback - Optional feedback
   * @param grade - Optional grade received
   */
  async approveProject(projectId: string, feedback?: string, grade?: string): Promise<Project> {
    const { data, error } = await supabase
      .from('projects')
      .update({
        status: 'completed',
        user_approved: true,
        user_approved_at: new Date().toISOString(),
        user_feedback: feedback,
        user_grade: grade,
        completed_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('id', projectId)
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Requests revision for a project.
   * @param projectId - The project UUID
   * @param feedback - The revision feedback/instructions
   */
  async requestRevision(projectId: string, feedback: string): Promise<ProjectRevision> {
    // Update project status
    await supabase
      .from('projects')
      .update({
        status: 'revision_requested',
        updated_at: new Date().toISOString(),
      })
      .eq('id', projectId)

    // Create revision record
    const { data, error } = await supabase
      .from('project_revisions')
      .insert({
        project_id: projectId,
        revision_notes: feedback,
        requested_by: 'user',
      })
      .select()
      .single()

    if (error) throw error
    return data
  },

  /**
   * Gets project status history.
   * @param projectId - The project UUID
   * @returns Array of status history records
   */
  async getProjectTimeline(projectId: string): Promise<ProjectStatusHistory[]> {
    const { data, error } = await supabase
      .from('project_status_history')
      .select('*')
      .eq('project_id', projectId)
      .order('created_at', { ascending: true })

    if (error) throw error
    return data
  },

  /**
   * Gets all available subjects.
   * @returns Array of subjects
   */
  async getSubjects(): Promise<Subject[]> {
    const { data, error } = await supabase
      .from('subjects')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return data
  },

  /**
   * Gets all available reference styles.
   * @returns Array of reference styles
   */
  async getReferenceStyles(): Promise<ReferenceStyle[]> {
    const { data, error } = await supabase
      .from('reference_styles')
      .select('*')
      .eq('is_active', true)
      .order('name')

    if (error) throw error
    return data
  },

  /**
   * Gets projects count by status.
   * @param userId - The user's profile ID
   * @returns Object with counts per status
   */
  async getProjectCounts(userId: string): Promise<Record<string, number>> {
    const { data, error } = await supabase
      .from('projects')
      .select('status')
      .eq('user_id', userId)

    if (error) throw error

    const counts: Record<string, number> = {
      total: data.length,
      analyzing: 0,
      quoted: 0,
      payment_pending: 0,
      in_progress: 0,
      delivered: 0,
      completed: 0,
    }

    data.forEach((project: any) => {
      if (counts[project.status] !== undefined) {
        counts[project.status]++
      }
    })

    return counts
  },

  /**
   * Gets projects pending payment.
   * @param userId - The user's profile ID
   * @returns Array of projects pending payment
   */
  async getPendingPaymentProjects(userId: string): Promise<Project[]> {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .eq('user_id', userId)
      .in('status', ['quoted', 'payment_pending'])
      .eq('is_paid', false)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data
  },

  /**
   * Gets project quotes.
   * @param projectId - The project UUID
   * @returns Array of quote records
   */
  async getProjectQuotes(projectId: string): Promise<ProjectQuote[]> {
    const { data, error } = await supabase
      .from('project_quotes')
      .select('*')
      .eq('project_id', projectId)
      .order('created_at', { ascending: true })

    if (error) throw error
    return data || []
  },

  /**
   * Gets combined timeline with status changes and quotes.
   * @param projectId - The project UUID
   * @returns Combined timeline events sorted by date
   */
  async getChatTimeline(projectId: string): Promise<TimelineEvent[]> {
    const [statusHistory, quotes] = await Promise.all([
      this.getProjectTimeline(projectId),
      this.getProjectQuotes(projectId),
    ])

    const events: TimelineEvent[] = []

    // Add status change events
    statusHistory.forEach((status) => {
      events.push({
        id: status.id,
        type: 'status_change',
        timestamp: status.created_at || new Date().toISOString(),
        data: {
          from_status: status.from_status,
          to_status: status.to_status,
          notes: status.notes,
        },
      })
    })

    // Add quote events
    quotes.forEach((quote) => {
      events.push({
        id: quote.id,
        type: 'quote',
        timestamp: quote.created_at || new Date().toISOString(),
        data: {
          amount: quote.user_amount,
          status: quote.status,
          valid_until: quote.valid_until,
        },
      })
    })

    // Sort by timestamp
    return events.sort((a, b) =>
      new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
    )
  },
}

/**
 * Project quote type
 */
interface ProjectQuote {
  id: string
  project_id: string
  user_amount: number | null
  status: string | null
  valid_until: string | null
  created_at: string | null
}

/**
 * Timeline event type for chat display
 */
interface TimelineEvent {
  id: string
  type: 'status_change' | 'quote'
  timestamp: string
  data: {
    from_status?: string | null
    to_status?: string | null
    notes?: string | null
    amount?: number | null
    status?: string | null
    valid_until?: string | null
  }
}

// Re-export types
export type {
  Project,
  ProjectInsert,
  ProjectUpdate,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
  ProjectStatusHistory,
  ProjectWithDetails,
  ProjectFilters,
  ProjectStatus,
  ServiceType,
  ProjectQuote,
  TimelineEvent,
}
