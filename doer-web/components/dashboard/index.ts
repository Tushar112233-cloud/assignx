/**
 * Dashboard components barrel export
 */

export { ProjectCard } from './ProjectCard'
export { TaskPoolList } from './TaskPoolList'
export type { Project } from './TaskPoolList'
export { AssignedTaskList } from './AssignedTaskList'

// Re-export ProjectStatus from types for backwards compatibility
export type { ProjectStatus } from '@/types/database'
