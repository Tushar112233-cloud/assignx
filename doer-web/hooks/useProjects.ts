/**
 * Projects management hook using Zustand
 * Manages project state and operations
 */

import { create } from 'zustand'
import type {
  Project,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
  ProjectStatus,
} from '@/types/database'
import {
  getDoerProjects,
  getProjectById,
  getProjectFiles,
  getProjectDeliverables,
  getProjectRevisions,
  getProjectsByCategory,
  updateProjectStatus,
  submitProject as submitProjectService,
  uploadDeliverable as uploadDeliverableService,
} from '@/services/project.service'

interface ProjectsState {
  /** All doer projects */
  projects: Project[]
  /** Current project being viewed */
  currentProject: Project | null
  /** Files for current project */
  currentFiles: ProjectFile[]
  /** Deliverables for current project */
  currentDeliverables: ProjectDeliverable[]
  /** Revisions for current project */
  currentRevisions: ProjectRevision[]
  /** Active projects (in_progress, assigned, revision_requested) */
  activeProjects: Project[]
  /** Projects under review */
  reviewProjects: Project[]
  /** Completed projects */
  completedProjects: Project[]
  /** Loading state */
  isLoading: boolean
  /** Error state */
  error: string | null

  /** Fetch all projects for a doer */
  fetchProjects: (doerId: string) => Promise<void>
  /** Fetch projects by category */
  fetchProjectsByCategory: (
    doerId: string,
    category: 'active' | 'review' | 'completed'
  ) => Promise<void>
  /** Fetch a single project with all related data */
  fetchProject: (projectId: string) => Promise<void>
  /** Start working on a project */
  startProject: (projectId: string) => Promise<void>
  /** Submit project for review */
  submitProject: (projectId: string) => Promise<void>
  /** Upload a deliverable */
  uploadDeliverable: (
    projectId: string,
    doerId: string,
    file: File
  ) => Promise<ProjectDeliverable>
  /** Update project status */
  updateStatus: (projectId: string, status: ProjectStatus) => Promise<void>
  /** Clear current project */
  clearCurrentProject: () => void
  /** Reset error */
  clearError: () => void
}

export const useProjects = create<ProjectsState>((set, get) => ({
  projects: [],
  currentProject: null,
  currentFiles: [],
  currentDeliverables: [],
  currentRevisions: [],
  activeProjects: [],
  reviewProjects: [],
  completedProjects: [],
  isLoading: false,
  error: null,

  fetchProjects: async (doerId: string) => {
    set({ isLoading: true, error: null })
    try {
      const projects = await getDoerProjects(doerId)
      set({ projects, isLoading: false })
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch projects',
        isLoading: false,
      })
    }
  },

  fetchProjectsByCategory: async (
    doerId: string,
    category: 'active' | 'review' | 'completed'
  ) => {
    set({ isLoading: true, error: null })
    try {
      const projects = await getProjectsByCategory(doerId, category)

      switch (category) {
        case 'active':
          set({ activeProjects: projects, isLoading: false })
          break
        case 'review':
          set({ reviewProjects: projects, isLoading: false })
          break
        case 'completed':
          set({ completedProjects: projects, isLoading: false })
          break
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch projects',
        isLoading: false,
      })
    }
  },

  fetchProject: async (projectId: string) => {
    set({ isLoading: true, error: null })
    try {
      const [project, files, deliverables, revisions] = await Promise.all([
        getProjectById(projectId),
        getProjectFiles(projectId),
        getProjectDeliverables(projectId),
        getProjectRevisions(projectId),
      ])

      set({
        currentProject: project,
        currentFiles: files,
        currentDeliverables: deliverables,
        currentRevisions: revisions,
        isLoading: false,
      })
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch project',
        isLoading: false,
      })
    }
  },

  startProject: async (projectId: string) => {
    set({ isLoading: true, error: null })
    try {
      const updated = await updateProjectStatus(projectId, 'in_progress')

      // Update in all relevant lists
      const updateProjectInList = (projects: Project[]) =>
        projects.map((p) => (p.id === projectId ? updated : p))

      set((state) => ({
        projects: updateProjectInList(state.projects),
        activeProjects: updateProjectInList(state.activeProjects),
        currentProject:
          state.currentProject?.id === projectId ? updated : state.currentProject,
        isLoading: false,
      }))
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to start project',
        isLoading: false,
      })
    }
  },

  submitProject: async (projectId: string) => {
    set({ isLoading: true, error: null })
    try {
      const updated = await submitProjectService(projectId)

      // Update in all relevant lists
      const updateProjectInList = (projects: Project[]) =>
        projects.map((p) => (p.id === projectId ? updated : p))

      // Move from active to review
      set((state) => ({
        projects: updateProjectInList(state.projects),
        activeProjects: state.activeProjects.filter((p) => p.id !== projectId),
        reviewProjects: [...state.reviewProjects, updated],
        currentProject:
          state.currentProject?.id === projectId ? updated : state.currentProject,
        isLoading: false,
      }))
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to submit project',
        isLoading: false,
      })
    }
  },

  uploadDeliverable: async (
    projectId: string,
    doerId: string,
    file: File
  ) => {
    set({ isLoading: true, error: null })
    try {
      const deliverable = await uploadDeliverableService(projectId, doerId, file)

      set((state) => ({
        currentDeliverables: [deliverable, ...state.currentDeliverables],
        isLoading: false,
      }))

      return deliverable
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to upload deliverable',
        isLoading: false,
      })
      throw error
    }
  },

  updateStatus: async (projectId: string, status: ProjectStatus) => {
    set({ isLoading: true, error: null })
    try {
      const updated = await updateProjectStatus(projectId, status)

      const updateProjectInList = (projects: Project[]) =>
        projects.map((p) => (p.id === projectId ? updated : p))

      set((state) => ({
        projects: updateProjectInList(state.projects),
        activeProjects: updateProjectInList(state.activeProjects),
        reviewProjects: updateProjectInList(state.reviewProjects),
        completedProjects: updateProjectInList(state.completedProjects),
        currentProject:
          state.currentProject?.id === projectId ? updated : state.currentProject,
        isLoading: false,
      }))
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to update status',
        isLoading: false,
      })
    }
  },

  clearCurrentProject: () => {
    set({
      currentProject: null,
      currentFiles: [],
      currentDeliverables: [],
      currentRevisions: [],
    })
  },

  clearError: () => {
    set({ error: null })
  },
}))
