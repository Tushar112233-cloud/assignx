import { apiClient } from '@/lib/api/client'

/**
 * Project type
 */
interface Project {
  id: string
  user_id: string
  title: string
  status: string
  service_type: string | null
  project_number: string | null
  is_paid: boolean | null
  created_at: string | null
  updated_at: string | null
  [key: string]: any
}

/**
 * Project insert type
 */
type ProjectInsert = Partial<Project>

/**
 * Project update type
 */
type ProjectUpdate = Partial<Project>

/**
 * Project file type
 */
interface ProjectFile {
  id: string
  project_id: string
  file_name: string | null
  file_url: string | null
  file_type: string | null
  file_size: number | null
  mime_type: string | null
  created_at: string | null
  [key: string]: any
}

/**
 * Project deliverable type
 */
interface ProjectDeliverable {
  id: string
  project_id: string
  [key: string]: any
}

/**
 * Project revision type
 */
interface ProjectRevision {
  id: string
  project_id: string
  revision_notes: string | null
  requested_by: string | null
  created_at: string | null
  [key: string]: any
}

/**
 * Project status history type
 */
interface ProjectStatusHistory {
  id: string
  project_id: string
  from_status: string | null
  to_status: string | null
  notes: string | null
  created_at: string | null
  [key: string]: any
}

/**
 * Project status type
 */
type ProjectStatus = string

/**
 * Service type
 */
type ServiceType = string

/**
 * Project with related data
 */
interface ProjectWithDetails extends Project {
  subject?: any
  reference_style?: any
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

/**
 * Project service for managing user projects.
 * Uses API client instead of API.
 */
export const projectService = {
  /**
   * Fetches all projects for a user with optional filters.
   */
  async getProjects(userId: string, filters?: ProjectFilters): Promise<ProjectWithDetails[]> {
    const params = new URLSearchParams({ userId })

    if (filters?.status) {
      if (Array.isArray(filters.status)) {
        params.set('status', filters.status.join(','))
      } else {
        params.set('status', filters.status)
      }
    }
    if (filters?.serviceType) params.set('serviceType', filters.serviceType)
    if (filters?.fromDate) params.set('fromDate', filters.fromDate)
    if (filters?.toDate) params.set('toDate', filters.toDate)
    if (filters?.searchTerm) params.set('search', filters.searchTerm)

    const result = await apiClient<{ projects: ProjectWithDetails[] }>(
      `/api/projects?${params.toString()}`
    )
    return result.projects || result as any
  },

  /**
   * Fetches a single project by ID with full details.
   */
  async getProjectById(projectId: string, _userId: string): Promise<ProjectWithDetails | null> {
    try {
      const result = await apiClient<{ project: ProjectWithDetails }>(
        `/api/projects/${projectId}`
      )
      return result.project || result as any
    } catch {
      return null
    }
  },

  /**
   * Creates a new project.
   */
  async createProject(projectData: ProjectInsert): Promise<Project> {
    const result = await apiClient<{ project: Project }>('/api/projects', {
      method: 'POST',
      body: JSON.stringify(projectData),
    })
    return result.project || result as any
  },

  /**
   * Updates an existing project.
   */
  async updateProject(projectId: string, updates: ProjectUpdate): Promise<Project> {
    const result = await apiClient<{ project: Project }>(`/api/projects/${projectId}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    })
    return result.project || result as any
  },

  /**
   * Uploads a file for a project via Cloudinary.
   */
  async uploadProjectFile(
    projectId: string,
    file: File,
    fileType: string = 'reference',
  ): Promise<ProjectFile> {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('folder', 'project-files')
    formData.append('projectId', projectId)
    formData.append('fileType', fileType)

    const result = await apiClient<{ file: ProjectFile }>(`/api/projects/${projectId}/files`, {
      method: 'POST',
      body: formData,
      isFormData: true,
    })
    return result.file || result as any
  },

  /**
   * Approves a delivered project.
   */
  async approveProject(projectId: string, feedback?: string, grade?: string): Promise<Project> {
    const result = await apiClient<{ project: Project }>(`/api/projects/${projectId}/approve`, {
      method: 'PUT',
      body: JSON.stringify({ feedback, grade }),
    })
    return result.project || result as any
  },

  /**
   * Requests revision for a project.
   */
  async requestRevision(projectId: string, feedback: string): Promise<ProjectRevision> {
    const result = await apiClient<{ revision: ProjectRevision }>(`/api/projects/${projectId}/revisions`, {
      method: 'POST',
      body: JSON.stringify({ feedback }),
    })
    return result.revision || result as any
  },

  /**
   * Gets project status history.
   */
  async getProjectTimeline(projectId: string): Promise<ProjectStatusHistory[]> {
    const result = await apiClient<{ timeline: ProjectStatusHistory[] }>(
      `/api/projects/${projectId}/timeline`
    )
    return result.timeline || result as any
  },

  /**
   * Gets all available subjects.
   */
  async getSubjects(): Promise<any[]> {
    const result = await apiClient<{ subjects: any[] }>('/api/subjects')
    return result.subjects || result as any
  },

  /**
   * Gets all available reference styles.
   */
  async getReferenceStyles(): Promise<any[]> {
    const result = await apiClient<{ styles: any[] }>('/api/reference-styles')
    return result.styles || result as any
  },

  /**
   * Gets projects count by status.
   * Derives total from GET /api/projects since /counts endpoint does not exist.
   */
  async getProjectCounts(userId: string): Promise<Record<string, number>> {
    try {
      const result = await apiClient<{ projects: ProjectWithDetails[]; total: number }>(
        `/api/projects?userId=${userId}&limit=1`
      )
      return { total: result.total ?? 0 }
    } catch {
      return { total: 0 }
    }
  },

  /**
   * Gets projects pending payment.
   */
  async getPendingPaymentProjects(userId: string): Promise<Project[]> {
    const result = await apiClient<{ projects: Project[] }>(
      `/api/projects?userId=${userId}&status=quoted,payment_pending&isPaid=false`
    )
    return result.projects || result as any
  },

  /**
   * Gets project quotes.
   */
  async getProjectQuotes(projectId: string): Promise<ProjectQuote[]> {
    const result = await apiClient<{ quotes: ProjectQuote[] }>(
      `/api/projects/${projectId}/quotes`
    )
    return result.quotes || result as any || []
  },

  /**
   * Gets combined timeline with status changes and quotes.
   */
  async getChatTimeline(projectId: string): Promise<TimelineEvent[]> {
    const [statusHistory, quotes] = await Promise.all([
      this.getProjectTimeline(projectId),
      this.getProjectQuotes(projectId),
    ])

    const events: TimelineEvent[] = []

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

    return events.sort((a, b) =>
      new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
    )
  },
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
