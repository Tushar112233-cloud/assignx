'use client'

import { useState } from 'react'
import { ChevronRight, TrendingUp, AlertCircle, DollarSign, ChevronDown } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { motion, AnimatePresence } from 'framer-motion'
import { cn } from '@/lib/utils'
import type { Project } from '@/types/database'
import { UrgentSpotlight } from './UrgentSpotlight'
import { EarningsForecast } from './EarningsForecast'
import { ProjectDistribution } from './ProjectDistribution'

/**
 * Props for InsightsSidebar component
 */
export interface InsightsSidebarProps {
  /** All active projects */
  activeProjects: Project[]
  /** Projects under review */
  reviewProjects: Project[]
  /** Completed projects */
  completedProjects: Project[]
  /** Callback when a project is clicked */
  onProjectClick?: (projectId: string) => void
  /** Whether sidebar is initially collapsed on mobile */
  initiallyCollapsed?: boolean
  /** Show only quick insights (without distribution and activity summary) */
  showOnlyQuickInsights?: boolean
}

/**
 * Quick action card for common tasks
 */
interface QuickActionProps {
  label: string
  count: number
  icon: React.ElementType
  onClick?: () => void
  variant?: 'default' | 'warning' | 'success'
}

/**
 * Quick action button component
 */
function QuickAction({ label, count, icon: Icon, onClick, variant = 'default' }: QuickActionProps) {
  const variantStyles = {
    default: 'bg-[#E3E9FF] text-[#4F6CF7] hover:bg-[#D5DFFF]',
    warning: 'bg-[#FFE7E1] text-[#FF8B6A] hover:bg-[#FFD9CF]',
    success: 'bg-[#E6F4FF] text-[#4B9BFF] hover:bg-[#D5ECFF]',
  }

  return (
    <motion.button
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className={cn(
        'flex w-full items-center justify-between rounded-2xl p-3 transition-colors',
        variantStyles[variant]
      )}
    >
      <div className="flex items-center gap-3">
        <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-white/40">
          <Icon className="h-4 w-4" />
        </div>
        <div className="text-left">
          <p className="text-sm font-semibold">{label}</p>
          <p className="text-xs opacity-75">{count} items</p>
        </div>
      </div>
      <ChevronRight className="h-4 w-4 opacity-50" />
    </motion.button>
  )
}

/**
 * Insights Sidebar Component
 *
 * Displays quick actions panel and analytics cards in a right sidebar.
 * Includes urgent project spotlight, earnings forecast, and project distribution.
 * Responsive with collapse functionality on mobile devices.
 *
 * @component
 * @example
 * ```tsx
 * <InsightsSidebar
 *   activeProjects={activeProjects}
 *   reviewProjects={reviewProjects}
 *   completedProjects={completedProjects}
 *   onProjectClick={(id) => router.push(`/projects/${id}`)}
 * />
 * ```
 */
export function InsightsSidebar({
  activeProjects,
  reviewProjects,
  completedProjects,
  onProjectClick,
  initiallyCollapsed = false,
  showOnlyQuickInsights = false,
}: InsightsSidebarProps) {
  const [isCollapsed, setIsCollapsed] = useState(initiallyCollapsed)

  // Calculate metrics
  const urgentCount = activeProjects.filter(
    (p) => p.status === 'revision_requested' || p.is_urgent
  ).length

  const inProgressCount = activeProjects.filter(
    (p) => p.status === 'in_progress' || p.status === 'assigned'
  ).length

  const totalEarnings = completedProjects.reduce(
    (sum, p) => sum + (p.doer_payout || 0),
    0
  )

  const pendingEarnings = [...activeProjects, ...reviewProjects].reduce(
    (sum, p) => sum + (p.doer_payout || 0),
    0
  )

  // Find most urgent project
  const mostUrgentProject = activeProjects
    .filter((p) => p.status === 'revision_requested' || p.is_urgent)
    .sort((a, b) => {
      // Prioritize revision requests
      if (a.status === 'revision_requested' && b.status !== 'revision_requested') return -1
      if (b.status === 'revision_requested' && a.status !== 'revision_requested') return 1
      // Then by deadline
      return new Date(a.deadline).getTime() - new Date(b.deadline).getTime()
    })[0]

  return (
    <div className="space-y-4">
      {/* Mobile collapse toggle */}
      <div className="lg:hidden">
        <Button
          variant="outline"
          size="sm"
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="w-full justify-between border-white/70 bg-white/80 shadow-[0_10px_22px_rgba(30,58,138,0.08)]"
        >
          <span className="text-sm font-semibold text-slate-900">
            {isCollapsed ? 'Show Insights' : 'Hide Insights'}
          </span>
          <ChevronDown
            className={cn(
              'h-4 w-4 transition-transform',
              !isCollapsed && 'rotate-180'
            )}
          />
        </Button>
      </div>

      <AnimatePresence>
        {!isCollapsed && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="space-y-4"
          >
            {/* Quick Actions Panel */}
            <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
              <CardContent className="space-y-4 p-5">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">
                      Quick Actions
                    </p>
                    <p className="text-sm text-slate-500">Navigate faster</p>
                  </div>
                </div>

                <div className="space-y-2">
                  <QuickAction
                    label="In Progress"
                    count={inProgressCount}
                    icon={TrendingUp}
                    variant="default"
                  />
                  <QuickAction
                    label="Need Attention"
                    count={urgentCount}
                    icon={AlertCircle}
                    variant="warning"
                  />
                  <QuickAction
                    label="Under Review"
                    count={reviewProjects.length}
                    icon={DollarSign}
                    variant="success"
                  />
                </div>

                <div className="rounded-2xl bg-slate-50/80 px-3 py-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-slate-500">Pipeline Value</span>
                    <span className="font-semibold text-slate-900">
                      ₹{pendingEarnings.toLocaleString('en-IN')}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Urgent Spotlight */}
            {mostUrgentProject && (
              <UrgentSpotlight
                project={mostUrgentProject}
                onProjectClick={onProjectClick}
              />
            )}

            {/* Earnings Forecast */}
            <EarningsForecast
              completedProjects={completedProjects}
              activeProjects={activeProjects}
              reviewProjects={reviewProjects}
            />

            {/* Only show these cards if not in quick insights mode */}
            {!showOnlyQuickInsights && (
              <>
                {/* Project Distribution */}
                <ProjectDistribution
                  activeCount={activeProjects.length}
                  reviewCount={reviewProjects.length}
                  completedCount={completedProjects.length}
                />

                {/* Activity Summary */}
                <Card className="border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
                  <CardContent className="space-y-3 p-5">
                    <div>
                      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">
                        Activity Summary
                      </p>
                      <p className="text-sm text-slate-500">Recent highlights</p>
                    </div>

                    <div className="space-y-2">
                      <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2 text-xs">
                        <span className="text-slate-600">Total Earnings</span>
                        <Badge variant="secondary" className="bg-[#E6F4FF] text-[#4B9BFF]">
                          ₹{totalEarnings.toLocaleString('en-IN')}
                        </Badge>
                      </div>
                      <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2 text-xs">
                        <span className="text-slate-600">Active Projects</span>
                        <Badge variant="secondary" className="bg-[#E3E9FF] text-[#4F6CF7]">
                          {activeProjects.length}
                        </Badge>
                      </div>
                      <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2 text-xs">
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
              </>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
