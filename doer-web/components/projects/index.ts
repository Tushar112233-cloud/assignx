/**
 * Projects components barrel export
 * All project-related components with animations and enhanced UX
 */

// Core workspace components
export { FileUpload } from './FileUpload'
export { ChatPanel } from './ChatPanel'
export { RevisionBanner, RevisionList } from './RevisionBanner'
export { WorkspaceView } from './WorkspaceView'

// Enhanced tab components with framer-motion animations
export { ActiveProjectsTab } from './ActiveProjectsTab'
export { UnderReviewTab } from './UnderReviewTab'
export { CompletedProjectsTab } from './CompletedTab'

// Beautiful project grid card with glassmorphism and 3D effects
export { ProjectGridCard } from './ProjectGridCard'

// Quick filters with smooth animations and badges
export { QuickFilters } from './QuickFilters'
export type { ActiveFilters, FilterCounts } from './QuickFilters'

// Utility functions
export * from './utils'
