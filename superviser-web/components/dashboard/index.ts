/**
 * @fileoverview Barrel exports for the dashboard components module.
 * @module components/dashboard
 */

export { StatsCards } from "./stats-cards"
export { AvailabilityToggle } from "./availability-toggle"
export { RequestFilter, type FilterState } from "./request-filter"
export { RequestCard, type ProjectRequest } from "./request-card"
export { ReadyToAssignCard, type PaidProject } from "./ready-to-assign-card"
export { AnalyzeQuoteModal } from "./analyze-quote-modal"
export { AssignDoerModal, type Doer } from "./assign-doer-modal"
export { DoerReviews, DoerReviewsBadge } from "./doer-reviews"
export { NewRequestsSection } from "./new-requests-section"
export { ReadyToAssignSection } from "./ready-to-assign-section"

// New V2 Components (Modern Dark Theme)
export { HeroSection } from "./hero-section"
export { KPICards } from "./kpi-cards"
export { ActivityFeed, generateSampleActivities } from "./activity-feed"
export { RequestCardV2 } from "./request-card-v2"
export { ReadyToAssignCardV2 } from "./ready-to-assign-card-v2"

// Light Theme Components
export { StatsGrid } from "./stats-grid"
export { QuickActions } from "./quick-actions"
export { RecentActivity } from "./recent-activity"
export { DashboardHeader } from "./dashboard-header"

// UI Components
export { AnimatedTabs } from "@/components/ui/animated-tabs"
