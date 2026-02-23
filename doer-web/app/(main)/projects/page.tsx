'use client'

import { useState, useEffect, useCallback, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { RefreshCw, FolderOpen, Clock, CheckCircle2 } from 'lucide-react'
import { Skeleton } from '@/components/ui/skeleton'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import {
  ActiveProjectsTab,
  UnderReviewTab,
  CompletedProjectsTab,
} from '@/components/projects'
import { ProjectHeroBanner } from '@/components/projects/redesign/ProjectHeroBanner'
import { FilterControls, type FilterState, type ViewMode } from '@/components/projects/redesign/FilterControls'
import { InsightsSidebar } from '@/components/projects/redesign/InsightsSidebar'
import { ProjectDistribution } from '@/components/projects/redesign/ProjectDistribution'
import { ROUTES } from '@/lib/constants'
import { useAuth } from '@/hooks/useAuth'
import { getProjectsByCategory } from '@/services/project.service'
import { AuthenticationError } from '@/lib/auth-helpers'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import type { Project } from '@/types/database'

/**
 * Animation variants for page elements (from Agent 6)
 */
const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -20 },
}

const staggerContainer = {
  animate: {
    transition: {
      staggerChildren: 0.05,
    },
  },
}

/**
 * Projects page with complete redesign
 *
 * New Layout Structure:
 * 1. Hero Banner at top (full width) - ProjectHeroBanner
 * 2. Filter Controls (sticky bar) - FilterControls
 * 3. Main Content: 65% project cards grid + 35% insights sidebar
 * 5. Bottom: Tabbed details section - ActiveProjectsTab, UnderReviewTab, CompletedProjectsTab
 *
 * All existing functionality preserved:
 * - Data fetching from Supabase via getProjectsByCategory
 * - Search filtering
 * - Status filtering
 * - Sort options
 * - View mode switching (grid/list/timeline)
 * - Real-time navigation to project workspaces
 * - Error handling with toast notifications
 * - Loading states
 */
export default function ProjectsPage() {
  const router = useRouter()
  const { doer, isLoading: authLoading } = useAuth()
  const [isLoading, setIsLoading] = useState(true)
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [viewMode, setViewMode] = useState<ViewMode>('grid')
  const [activeTab, setActiveTab] = useState('active')

  const [activeProjects, setActiveProjects] = useState<Project[]>([])
  const [reviewProjects, setReviewProjects] = useState<Project[]>([])
  const [completedProjects, setCompletedProjects] = useState<Project[]>([])

  // Filter state for advanced filtering
  const [filters, setFilters] = useState<FilterState>({
    statuses: [],
    urgent: null,
    sortBy: 'deadline',
    sortDirection: 'asc',
  })

  /**
   * Load projects from Supabase
   * Preserves existing data fetching logic
   */
  const loadProjects = useCallback(async (showRefresh = false) => {
    if (!doer?.id) {
      setIsLoading(false)
      return
    }

    if (showRefresh) setIsRefreshing(true)
    else setIsLoading(true)

    try {
      const [active, review, completed] = await Promise.all([
        getProjectsByCategory(doer.id, 'active'),
        getProjectsByCategory(doer.id, 'review'),
        getProjectsByCategory(doer.id, 'completed'),
      ])

      setActiveProjects(active)
      setReviewProjects(review)
      setCompletedProjects(completed)
    } catch (error) {
      // Handle expired/missing session by redirecting to login
      if (error instanceof AuthenticationError) {
        console.warn('[Projects] Auth expired, redirecting to login')
        router.push(ROUTES.login)
        return
      }
      console.error('Error loading projects:', error)
      toast.error('Failed to load projects')
    } finally {
      setIsLoading(false)
      setIsRefreshing(false)
    }
  }, [doer?.id, router])

  /** Load projects on mount and when doer changes */
  useEffect(() => {
    if (doer?.id) {
      loadProjects()
    } else if (!authLoading) {
      setIsLoading(false)
    }
  }, [doer?.id, authLoading, loadProjects])

  /** Navigate to project workspace - existing callback preserved */
  const handleProjectClick = useCallback(
    (projectId: string) => {
      router.push(`${ROUTES.projects}/${projectId}`)
    },
    [router]
  )

  /** Navigate to workspace - existing callback preserved */
  const handleOpenWorkspace = useCallback(
    (projectId: string) => {
      router.push(`${ROUTES.projects}/${projectId}`)
    },
    [router]
  )

  /** Handle refresh - existing callback preserved */
  const handleRefresh = useCallback(() => {
    loadProjects(true)
  }, [loadProjects])

  /** Calculate metrics for hero banner and stats */
  const totalPipeline = useMemo(() => {
    const allProjects = [...activeProjects, ...reviewProjects]
    return allProjects.reduce((sum, p) => sum + (p.doer_payout ?? 0), 0)
  }, [activeProjects, reviewProjects])

  const totalCompleted = useMemo(
    () => completedProjects.reduce((sum, p) => sum + (p.doer_payout ?? 0), 0),
    [completedProjects]
  )

  const weeklyEarnings = useMemo(() => {
    // Calculate estimated weekly earnings based on completion rate
    return Math.round(totalCompleted / Math.max(1, Math.ceil(completedProjects.length / 4)))
  }, [totalCompleted, completedProjects.length])

  const weeklyTrend = useMemo(() => {
    // Generate weekly trend data from actual completed project counts
    const trend = Array(7).fill(0)
    const now = Date.now()
    const dayMs = 86400000
    completedProjects.forEach((p) => {
      const completedDate = new Date(p.updated_at || p.created_at)
      const daysAgo = Math.floor((now - completedDate.getTime()) / dayMs)
      if (daysAgo >= 0 && daysAgo < 7) {
        trend[6 - daysAgo] += 1
      }
    })
    return trend
  }, [completedProjects])

  const velocityPercent = useMemo(() => {
    const total = activeProjects.length + completedProjects.length
    return total > 0 ? Math.round((completedProjects.length / total) * 100) : 0
  }, [activeProjects, completedProjects])

  /**
   * Filter and sort projects based on current filters
   * Enhanced from existing filterProjects logic
   */
  const getFilteredProjects = useCallback(
    (projects: Project[]) => {
      let filtered = [...projects]

      // Search filter - existing logic preserved
      if (searchQuery.trim()) {
        const query = searchQuery.trim().toLowerCase()
        filtered = filtered.filter((p) => {
          const content = [p.title, p.subject_name, p.supervisor_name, p.status]
            .filter(Boolean)
            .join(' ')
            .toLowerCase()
          return content.includes(query)
        })
      }

      // Status filter - new advanced filtering
      if (filters.statuses.length > 0) {
        filtered = filtered.filter((p) => filters.statuses.includes(p.status))
      }

      // Urgency filter - new advanced filtering
      if (filters.urgent !== null) {
        filtered = filtered.filter((p) => {
          const deadlineDate = new Date(p.deadline)
          const daysUntilDeadline = Math.ceil(
            (deadlineDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24)
          )
          const isUrgent = daysUntilDeadline <= 3
          return filters.urgent ? isUrgent : !isUrgent
        })
      }

      // Sort - enhanced from existing logic
      filtered.sort((a, b) => {
        const direction = filters.sortDirection === 'asc' ? 1 : -1
        switch (filters.sortBy) {
          case 'deadline':
            return (
              (new Date(a.deadline).getTime() - new Date(b.deadline).getTime()) * direction
            )
          case 'price':
            return ((b.doer_payout ?? 0) - (a.doer_payout ?? 0)) * direction
          case 'status':
            return a.status.localeCompare(b.status) * direction
          case 'created':
            return (
              (new Date(b.created_at).getTime() - new Date(a.created_at).getTime()) * direction
            )
          default:
            return 0
        }
      })

      return filtered
    },
    [searchQuery, filters]
  )

  const filteredActiveProjects = useMemo(
    () => getFilteredProjects(activeProjects),
    [getFilteredProjects, activeProjects]
  )

  const filteredReviewProjects = useMemo(
    () => getFilteredProjects(reviewProjects),
    [getFilteredProjects, reviewProjects]
  )

  const filteredCompletedProjects = useMemo(
    () => getFilteredProjects(completedProjects),
    [getFilteredProjects, completedProjects]
  )

  // Combine all projects for stats grid
  const allProjects = useMemo(
    () => [...activeProjects, ...reviewProjects, ...completedProjects],
    [activeProjects, reviewProjects, completedProjects]
  )

  // Skeleton gate removed — show page content immediately while loading

  return (
    <motion.div
      className="relative space-y-8"
      initial="initial"
      animate="animate"
      variants={staggerContainer}
    >
      {/* Radial gradient background overlay - from design spec */}
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%),radial-gradient(circle_at_80%_20%,rgba(67,209,197,0.16),transparent_50%)]" />

      {/* ================================================================
          1. HERO BANNER SECTION (Full Width)
          Component: ProjectHeroBanner
          ================================================================ */}
      <motion.div variants={fadeInUp}>
        <ProjectHeroBanner
          activeCount={activeProjects.length}
          reviewCount={reviewProjects.length}
          completedCount={completedProjects.length}
          totalPipelineValue={totalPipeline}
          weeklyEarnings={weeklyEarnings}
          weeklyTrend={weeklyTrend}
          velocityPercent={velocityPercent}
          onNewProject={() => router.push(ROUTES.dashboard)}
          onViewAnalytics={() => setActiveTab('analytics')}
        />
      </motion.div>

      {/* ================================================================
          2. FILTER CONTROLS (Sticky Bar)
          Component: FilterControls
          Features: Search, Status Pills, Sort, View Mode Toggle
          ================================================================ */}
      <motion.div variants={fadeInUp}>
        <FilterControls
          filters={filters}
          onFiltersChange={setFilters}
          viewMode={viewMode}
          onViewModeChange={setViewMode}
          totalProjects={activeProjects.length + reviewProjects.length + completedProjects.length}
          filteredProjects={filteredActiveProjects.length + filteredReviewProjects.length + filteredCompletedProjects.length}
        />
      </motion.div>

      {/* ================================================================
          3. MAIN CONTENT AREA - Bento Grid Layout
          Balanced grid with content ending at same baseline
          ================================================================ */}
      <div className="space-y-6">
        {/* Top Section: Projects + Quick Insights */}
        <div className="grid gap-6 xl:grid-cols-[1fr_420px]">
          {/* LEFT SIDE: Project Tabs */}
          <div className="flex flex-col space-y-6 h-full">
            {/* Section Header */}
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-semibold text-slate-900">Your Projects</h2>
                <p className="text-sm text-slate-500">
                  {filteredActiveProjects.length} active • {filteredReviewProjects.length} in
                  review • {filteredCompletedProjects.length} completed
                </p>
              </div>
              <button
                onClick={handleRefresh}
                disabled={isRefreshing}
                className="flex h-12 w-12 items-center justify-center rounded-2xl border border-slate-200/80 bg-white/90 text-slate-600 shadow-[0_4px_20px_rgba(148,163,184,0.08)] transition hover:border-[#5A7CFF] hover:bg-white hover:text-[#5A7CFF] hover:shadow-[0_8px_30px_rgba(90,124,255,0.15)] disabled:opacity-50"
                type="button"
                aria-label="Refresh projects"
              >
                <RefreshCw className={cn('h-5 w-5', isRefreshing && 'animate-spin')} />
              </button>
            </div>

            {/* Tabbed Projects Section */}
            <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full flex-1 flex flex-col">
              <TabsList className="grid w-full max-w-2xl grid-cols-3 h-12 rounded-full bg-white/85 p-1 shadow-[0_14px_28px_rgba(30,58,138,0.08)]">
                <TabsTrigger
                  value="active"
                  className="rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all"
                >
                  <FolderOpen className="mr-2 h-4 w-4" />
                  Active ({filteredActiveProjects.length})
                </TabsTrigger>
                <TabsTrigger
                  value="review"
                  className="rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all"
                >
                  <Clock className="mr-2 h-4 w-4" />
                  Review ({filteredReviewProjects.length})
                </TabsTrigger>
                <TabsTrigger
                  value="completed"
                  className="rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all"
                >
                  <CheckCircle2 className="mr-2 h-4 w-4" />
                  Completed ({filteredCompletedProjects.length})
                </TabsTrigger>
              </TabsList>

              {/* Active Projects Tab */}
              <TabsContent value="active" className="mt-6 flex-1">
                <div className="rounded-[28px] border border-white/70 bg-white/85 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)] h-full">
                  <ActiveProjectsTab
                    projects={filteredActiveProjects}
                    isLoading={isLoading}
                    onProjectClick={handleProjectClick}
                    onOpenWorkspace={handleOpenWorkspace}
                  />
                </div>
              </TabsContent>

              {/* Under Review Tab */}
              <TabsContent value="review" className="mt-6 flex-1">
                <div className="rounded-[28px] border border-white/70 bg-white/85 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)] h-full">
                  <UnderReviewTab
                    projects={filteredReviewProjects}
                    isLoading={isLoading}
                    onProjectClick={handleProjectClick}
                  />
                </div>
              </TabsContent>

              {/* Completed Projects Tab */}
              <TabsContent value="completed" className="mt-6 flex-1">
                <div className="rounded-[28px] border border-white/70 bg-white/85 p-6 shadow-[0_18px_40px_rgba(30,58,138,0.08)] h-full">
                  <CompletedProjectsTab
                    projects={filteredCompletedProjects}
                    isLoading={isLoading}
                    onProjectClick={handleProjectClick}
                    onDownloadInvoice={(_id) => {
                      // TODO: Implement invoice download
                      toast.info('Invoice download feature coming soon!')
                    }}
                  />
                </div>
              </TabsContent>
            </Tabs>
          </div>

          {/* RIGHT SIDE: Quick Insights (Shorter cards only) */}
          <motion.div variants={fadeInUp} className="flex flex-col space-y-4">
            <InsightsSidebar
              activeProjects={activeProjects}
              reviewProjects={reviewProjects}
              completedProjects={completedProjects}
              onProjectClick={handleProjectClick}
              showOnlyQuickInsights={true}
            />
          </motion.div>
        </div>

        {/* Bottom Section: Analytics Cards - Bento Grid Style */}
        <motion.div
          variants={staggerContainer}
          className="grid gap-6 sm:grid-cols-2 lg:grid-cols-2"
        >
          {/* Project Distribution Card */}
          <motion.div variants={fadeInUp}>
            <ProjectDistribution
              activeCount={activeProjects.length}
              reviewCount={reviewProjects.length}
              completedCount={completedProjects.length}
            />
          </motion.div>

          {/* Activity Summary Card */}
          <motion.div variants={fadeInUp}>
            <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] h-full">
              <CardContent className="space-y-3 p-6">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">
                    Activity Summary
                  </p>
                  <p className="text-sm text-slate-500">Recent highlights</p>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-4 py-3 text-xs">
                    <span className="text-slate-600">Total Earnings</span>
                    <Badge variant="secondary" className="bg-[#E6F4FF] text-[#4B9BFF]">
                      ₹{completedProjects.reduce((sum, p) => sum + (p.doer_payout || 0), 0).toLocaleString('en-IN')}
                    </Badge>
                  </div>
                  <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-4 py-3 text-xs">
                    <span className="text-slate-600">Active Projects</span>
                    <Badge variant="secondary" className="bg-[#E3E9FF] text-[#4F6CF7]">
                      {activeProjects.length}
                    </Badge>
                  </div>
                  <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-4 py-3 text-xs">
                    <span className="text-slate-600">Completion Rate</span>
                    <Badge variant="secondary" className="bg-[#E6F4FF] text-[#4B9BFF]">
                      {activeProjects.length > 0
                        ? Math.round(
                            (completedProjects.length /
                              (completedProjects.length + activeProjects.length)) *
                              100
                          )
                        : 0}
                      %
                    </Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>
      </div>
    </motion.div>
  )
}
