'use client'

import { useState, useEffect, useCallback, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import {
  Bell,
  Search,
  Briefcase,
  Sparkles,
  Clock,
  IndianRupee,
  RefreshCw,
  Target,
  Layers,
  AlertTriangle,
} from 'lucide-react'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { TaskPoolList, AssignedTaskList } from '@/components/dashboard'
import type { Project } from '@/components/dashboard'
import { ROUTES } from '@/lib/constants'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import {
  getOpenPoolTasks,
  getAssignedTasks,
  acceptPoolTask,
  isDeadlineUrgent,
  type ProjectWithSupervisor,
} from '@/services/project.service'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { useProjectSubscription, useNewProjectsSubscription } from '@/hooks/useProjectSubscription'
import { useAuth } from '@/hooks/useAuth'

type HeroStackCardProps = {
  label: string
  value: string
  highlight?: boolean
}

type SummaryStatCardProps = {
  label: string
  value: string
  icon: React.ElementType
  iconBg: string
  iconColor: string
}

type QuickStatCardProps = {
  title: string
  value: string | number
  subtitle: string
  icon: React.ElementType
  gradient: string
  iconBg: string
  iconColor: string
}

type PriorityTask = Project & {
  priorityLabel: string
}

/**
 * Transform database project to component project format.
 */
function transformProject(dbProject: ProjectWithSupervisor): Project {
  return {
    id: dbProject.id,
    title: dbProject.title,
    subject: dbProject.topic || dbProject.service_type || 'General',
    description: dbProject.description || undefined,
    price: Number(dbProject.doer_payout) || 0,
    deadline: new Date(dbProject.deadline),
    status: dbProject.status as Project['status'],
    supervisorName: dbProject.supervisor?.profile?.full_name,
    isUrgent: isDeadlineUrgent(dbProject.deadline),
  }
}

/**
 * Format a deadline date for priority list display.
 */
function formatDeadline(date: Date) {
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  })
}

/**
 * Top greeting bar with search and quick actions.
 * Premium design with transparent background and enhanced visual hierarchy.
 */
function DashboardTopBar({ userName }: { userName: string }) {
  const hour = new Date().getHours()
  const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening'

  return (
    <div className="flex flex-col gap-5 py-6 sm:flex-row sm:items-center sm:justify-between">
      <div className="space-y-1">
        <p className="text-lg font-semibold text-slate-800">
          {greeting}, <span className="bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] bg-clip-text text-transparent">{userName}</span>
        </p>
        <p className="text-sm text-slate-500">Welcome back to your workspace</p>
      </div>
      <div className="flex flex-1 flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">
        <div className="relative w-full sm:max-w-md">
          <Search className="absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            className="h-12 w-full rounded-2xl border border-slate-200/80 bg-white/90 pl-11 pr-4 text-sm text-slate-700 shadow-[0_4px_20px_rgba(148,163,184,0.08)] outline-none transition placeholder:text-slate-400 hover:border-slate-300 focus:border-[#5A7CFF] focus:bg-white focus:ring-4 focus:ring-[#E7ECFF]"
            placeholder="Search tasks, projects, or messages"
            type="search"
          />
        </div>
        <button
          className="flex h-12 w-12 items-center justify-center rounded-2xl border border-slate-200/80 bg-white/90 text-[#4F6CF7] shadow-[0_4px_20px_rgba(148,163,184,0.08)] transition hover:border-[#5A7CFF] hover:bg-white hover:text-[#3652F0] hover:shadow-[0_8px_30px_rgba(90,124,255,0.15)]"
          type="button"
          aria-label="View notifications"
        >
          <Bell className="h-5 w-5" />
        </button>
        <button
          className="flex h-12 items-center justify-start gap-2 rounded-2xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-6 text-sm font-semibold text-white shadow-[0_8px_30px_rgba(90,124,255,0.35)] transition hover:-translate-y-0.5 hover:shadow-[0_12px_40px_rgba(90,124,255,0.45)]"
          type="button"
        >
          <span className="text-2xl font-bold">+</span>
          <span>Quick</span>
        </button>
      </div>
    </div>
  )
}

/**
 * Dashboard title block.
 */
function DashboardTitle() {
  return (
    <div className="space-y-1">
      <h1 className="text-3xl font-semibold tracking-tight text-slate-900">Dashboard</h1>
      <p className="text-base text-slate-500">Create, track, and grow your work.</p>
    </div>
  )
}

/**
 * Small stat card inside the hero panel.
 */
function HeroStackCard({ label, value, highlight }: HeroStackCardProps) {
  return (
    <div
      className={cn(
        'rounded-2xl bg-white/85 p-4 shadow-[0_12px_30px_rgba(30,58,138,0.1)]',
        highlight && 'bg-gradient-to-r from-[#5B7CFF] via-[#5B86FF] to-[#43D1C5] text-white'
      )}
    >
      <p className={cn('text-xs font-semibold uppercase tracking-wide', highlight ? 'text-white/80' : 'text-slate-500')}>
        {label}
      </p>
      <p className={cn('mt-2 text-sm font-semibold', highlight ? 'text-white' : 'text-slate-800')}>
        {value}
      </p>
    </div>
  )
}

/**
 * Primary hero workspace card.
 */
function HeroWorkspaceCard({
  onExploreProjects,
  onViewInsights,
  poolCount,
  completionRate,
  assignedCount,
}: {
  onExploreProjects: () => void
  onViewInsights: () => void
  poolCount: number
  completionRate: number
  assignedCount: number
}) {
  return (
    <div className="relative overflow-hidden rounded-[28px] bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(99,102,241,0.18),transparent_55%)]" />
      <div className="relative grid gap-6 lg:grid-cols-[minmax(0,1fr)_240px]">
        <div className="space-y-4">
          <p className="text-sm font-medium text-[#4F6CF7]">Your workspace 👋</p>
          <h2 className="text-3xl font-semibold leading-tight text-slate-900">
            Your workspace is glowing with new opportunities.
          </h2>
          <p className="text-sm leading-relaxed text-slate-500">
            Stay on top of assigned tasks, discover new projects, and keep every deadline in sight
            with a workspace designed to keep you moving forward.
          </p>
          <div className="flex flex-wrap items-center gap-3">
            <button
              className="h-11 rounded-full bg-[#FF9B7A] px-5 text-sm font-semibold text-white transition hover:-translate-y-0.5"
              type="button"
              onClick={onExploreProjects}
            >
              Explore projects
            </button>
            <button
              className="h-11 rounded-full border border-white/80 bg-white/85 px-5 text-sm font-semibold text-slate-600 shadow-[0_10px_22px_rgba(30,58,138,0.1)] transition hover:text-slate-800"
              type="button"
              onClick={onViewInsights}
            >
              View insights
            </button>
          </div>
        </div>
        <div className="flex flex-col gap-3">
          <HeroStackCard label="Assigned Tasks" value={`${assignedCount} active`} />
          <HeroStackCard label="Project Pulse" value={`${completionRate.toFixed(0)}% on track`} highlight />
          <HeroStackCard label="Open Pool" value={`${poolCount} available`} />
        </div>
      </div>
    </div>
  )
}

/**
 * Right-side summary panel stat card with icon.
 */
function SummaryStatCard({ label, value, icon: Icon, iconBg, iconColor }: SummaryStatCardProps) {
  return (
    <div className="rounded-2xl bg-white/85 p-4 shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
      <div className="flex items-center justify-between">
        <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">{label}</p>
        <div className={cn('flex h-8 w-8 items-center justify-center rounded-xl', iconBg)}>
          <Icon className={cn('h-4 w-4', iconColor)} />
        </div>
      </div>
      <p className="mt-2 text-2xl font-semibold text-slate-900">{value}</p>
    </div>
  )
}

/**
 * Summary panel for daily stats.
 */
function RightSummaryPanel({
  assignedCount,
  poolCount,
  urgentCount,
}: {
  assignedCount: number
  poolCount: number
  urgentCount: number
}) {
  return (
    <div className="rounded-[28px] bg-white/85 p-6 shadow-[0_20px_50px_rgba(30,58,138,0.1)]">
      <div className="flex items-center justify-between">
        <h3 className="text-base font-semibold text-slate-900">Today at a glance</h3>
      </div>
      <div className="mt-4 space-y-3">
        <SummaryStatCard
          label="Assigned tasks"
          value={String(assignedCount)}
          icon={Briefcase}
          iconBg="bg-[#E9E3FF]"
          iconColor="text-[#7C3AED]"
        />
        <SummaryStatCard
          label="Open pool"
          value={String(poolCount)}
          icon={Layers}
          iconBg="bg-[#E6F4FF]"
          iconColor="text-[#4B9BFF]"
        />
        <SummaryStatCard
          label="Urgent reviews"
          value={String(urgentCount)}
          icon={Clock}
          iconBg="bg-[#FFE7E1]"
          iconColor="text-[#FF8B6A]"
        />
      </div>
    </div>
  )
}

/**
 * Quick stats card for dashboard.
 */
function QuickStatCard({
  title,
  value,
  subtitle,
  icon: Icon,
  gradient,
  iconBg,
  iconColor,
}: QuickStatCardProps) {
  return (
    <Card className={cn('relative overflow-hidden border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]', gradient)}>
      <CardContent className="p-5">
        <div className="flex items-start justify-between">
          <div className="space-y-1">
            <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">{title}</p>
            <p className="text-2xl font-semibold text-slate-900">{value}</p>
            <p className="text-xs text-slate-500">{subtitle}</p>
          </div>
          <div className={cn('h-11 w-11 rounded-2xl flex items-center justify-center', iconBg)}>
            <Icon className={cn('h-5 w-5', iconColor)} />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * Performance analysis card with derived metrics.
 */
function PerformanceAnalysisCard({
  activeCount,
  urgentCount,
  completionRate,
}: {
  activeCount: number
  urgentCount: number
  completionRate: number
}) {
  return (
    <div className="rounded-[24px] bg-white/85 p-5 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
      <div className="flex items-center gap-2">
        <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#E3E9FF] text-[#4F6CF7]">
          <Target className="h-5 w-5" />
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-900">Performance analysis</p>
          <p className="text-xs text-slate-500">Snapshot of current delivery health</p>
        </div>
      </div>
      <div className="mt-4 space-y-3">
        <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2">
          <span className="text-xs font-medium text-slate-500">Completion rate</span>
          <span className="text-sm font-semibold text-slate-800">{completionRate.toFixed(0)}%</span>
        </div>
        <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2">
          <span className="text-xs font-medium text-slate-500">Active tasks</span>
          <span className="text-sm font-semibold text-slate-800">{activeCount}</span>
        </div>
        <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2">
          <span className="text-xs font-medium text-slate-500">Urgent tasks</span>
          <span className="text-sm font-semibold text-slate-800">{urgentCount}</span>
        </div>
      </div>
    </div>
  )
}

/**
 * Task mix breakdown card.
 */
function TaskMixCard({ assignedCount, poolCount }: { assignedCount: number; poolCount: number }) {
  const total = assignedCount + poolCount
  const assignedPercent = total ? (assignedCount / total) * 100 : 0
  const poolPercent = total ? (poolCount / total) * 100 : 0

  return (
    <div className="rounded-[24px] bg-white/85 p-5 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
      <div className="flex items-center gap-2">
        <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#E6F4FF] text-[#4B9BFF]">
          <Layers className="h-5 w-5" />
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-900">Task mix</p>
          <p className="text-xs text-slate-500">Assigned vs open pool balance</p>
        </div>
      </div>
      <div className="mt-4">
        <div className="flex h-2 overflow-hidden rounded-full bg-slate-100">
          <div className="bg-[#5B7CFF]" style={{ width: `${assignedPercent}%` }} />
          <div className="bg-[#45C7F3]" style={{ width: `${poolPercent}%` }} />
        </div>
        <div className="mt-4 flex items-center justify-between text-xs text-slate-500">
          <span>Assigned</span>
          <span>Open pool</span>
        </div>
        <div className="mt-2 flex items-center justify-between text-sm font-semibold text-slate-800">
          <span>{assignedCount}</span>
          <span>{poolCount}</span>
        </div>
      </div>
    </div>
  )
}

/**
 * Priority tasks list for urgent or revision items.
 */
function PriorityTasksCard({ tasks }: { tasks: PriorityTask[] }) {
  return (
    <div className="rounded-[24px] bg-white/85 p-5 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
      <div className="flex items-center gap-2">
        <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#FFE7E1] text-[#FF8B6A]">
          <AlertTriangle className="h-5 w-5" />
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-900">Priority tasks</p>
          <p className="text-xs text-slate-500">Focus items needing attention</p>
        </div>
      </div>
      <div className="mt-4 space-y-3">
        {tasks.length === 0 ? (
          <p className="text-xs text-slate-500">No priority tasks right now.</p>
        ) : (
          tasks.map((task) => (
            <div key={task.id} className="rounded-2xl bg-slate-50/80 px-3 py-2">
              <div className="flex items-center justify-between">
                <p className="text-sm font-semibold text-slate-800 line-clamp-1">{task.title}</p>
                <Badge className="bg-[#FFE7E1] text-[#FF8B6A]" variant="secondary">
                  {task.priorityLabel}
                </Badge>
              </div>
              <p className="mt-1 text-xs text-slate-500">Due {formatDeadline(task.deadline)}</p>
            </div>
          ))
        )}
      </div>
    </div>
  )
}

/**
 * Dashboard client component with hero-focused layout.
 */
export function DashboardClient() {
  const router = useRouter()
  const { user, doer: authDoer, isLoading: authLoading } = useAuth()
  const [isLoading, setIsLoading] = useState(true)
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [assignedTasks, setAssignedTasks] = useState<Project[]>([])
  const [poolTasks, setPoolTasks] = useState<Project[]>([])
  const [activeTab, setActiveTab] = useState('assigned')

  /**
   * Load tasks from the API.
   */
  const loadTasks = useCallback(async (showRefresh = false) => {
    if (!authDoer?.id) {
      return
    }

    if (showRefresh) setIsRefreshing(true)
    else setIsLoading(true)

    try {
      // Fetch assigned tasks and pool tasks in parallel
      const [assignedData, poolData] = await Promise.all([
        getAssignedTasks(authDoer.id),
        getOpenPoolTasks(),
      ])

      setAssignedTasks((assignedData || []).map(transformProject))
      setPoolTasks(poolData.map(transformProject))
    } catch (error) {
      console.warn('[Dashboard] loadTasks FAILED:', error)
      toast.error('Failed to load tasks')
    } finally {
      setIsLoading(false)
      setIsRefreshing(false)
    }
  }, [authDoer?.id])

  /** Load tasks when doer becomes available after auth. */
  useEffect(() => {
    if (authDoer?.id) {
      loadTasks()
    } else if (!authLoading) {
      setIsLoading(false)
    }
  }, [authDoer?.id, authLoading, loadTasks])

  /**
   * Real-time subscription for assigned project updates.
   */
  useProjectSubscription({
    doerId: authDoer?.id,
    onProjectAssigned: (project) => {
      // Add new project directly to assigned tasks state
      const transformedProject = transformProject(project as ProjectWithSupervisor)
      setAssignedTasks((prev) => [...prev, transformedProject])
      toast.success('New project assigned to you!')
    },
    onProjectUpdate: (project) => {
      // Update specific project in assigned tasks array
      const transformedProject = transformProject(project as ProjectWithSupervisor)
      setAssignedTasks((prev) =>
        prev.map((p) => (p.id === transformedProject.id ? transformedProject : p))
      )
    },
    onStatusChange: (project, oldStatus, newStatus) => {
      // Update specific project status in array
      setAssignedTasks((prev) =>
        prev.map((p) =>
          p.id === project.id ? { ...p, status: newStatus as Project['status'] } : p
        )
      )
      if (newStatus === 'revision_requested') {
        toast.warning('Revision requested for a project')
      }
    },
    enabled: !!authDoer?.id,
  })

  /**
   * Real-time subscription for new available projects in the pool.
   */
  useNewProjectsSubscription({
    enabled: true,
    onNewProject: (project) => {
      // Add new project directly to pool tasks state
      const transformedProject = transformProject(project as ProjectWithSupervisor)
      setPoolTasks((prev) => [...prev, transformedProject])
      toast.info('New project available in the pool!')
    },
  })

  /**
   * Handle accepting a task from the pool.
   */
  const handleAcceptTask = useCallback(async (projectId: string) => {
    if (!authDoer?.id) {
      toast.error('Please log in to accept tasks')
      return
    }

    try {
      await acceptPoolTask(projectId, authDoer.id)

      const task = poolTasks.find(t => t.id === projectId)
      if (task) {
        setPoolTasks(prev => prev.filter(t => t.id !== projectId))
        setAssignedTasks(prev => [...prev, { ...task, status: 'assigned' }])
      }

      toast.success('Task accepted successfully!')
    } catch (error) {
      console.error('Error accepting task:', error)
      toast.error('Failed to accept task')
    }
  }, [authDoer?.id, poolTasks])

  /** Handle project click. */
  const handleProjectClick = useCallback((projectId: string) => {
    router.push(`${ROUTES.projects}/${projectId}`)
  }, [router])

  /** Handle refresh. */
  const handleRefresh = useCallback(async () => {
    await loadTasks(true)
  }, [loadTasks])

  /** Handle navigation to projects page */
  const handleExploreProjects = useCallback(() => {
    router.push(ROUTES.projects)
  }, [router])

  /** Handle navigation to statistics page */
  const handleViewInsights = useCallback(() => {
    router.push(ROUTES.statistics)
  }, [router])

  /** Count of tasks needing attention. */
  const urgentCount = useMemo(() =>
    assignedTasks.filter(t => t.isUrgent || t.status === 'revision_requested').length,
    [assignedTasks]
  )

  /** Calculate quick stats. */
  const totalEarningsPotential = useMemo(() =>
    [...assignedTasks, ...poolTasks].reduce((sum, t) => sum + t.price, 0),
    [assignedTasks, poolTasks]
  )

  const activeCount = assignedTasks.filter(t =>
    t.status === 'in_progress' || t.status === 'assigned'
  ).length

  const completedCount = assignedTasks.filter(t => t.status === 'completed').length
  const completionRate = assignedTasks.length
    ? (completedCount / assignedTasks.length) * 100
    : 0

  const priorityTasks: PriorityTask[] = useMemo(() => {
    const filtered = assignedTasks
      .filter(t => t.isUrgent || t.status === 'revision_requested')
      .sort((a, b) => a.deadline.getTime() - b.deadline.getTime())
      .slice(0, 3)

    return filtered.map(task => ({
      ...task,
      priorityLabel: task.status === 'revision_requested' ? 'Revision' : 'Urgent',
    }))
  }, [assignedTasks])

  if (authLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-10 w-32" />
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[1, 2, 3, 4].map(i => (
            <Skeleton key={i} className="h-28 rounded-xl" />
          ))}
        </div>
        <Skeleton className="h-12 w-full max-w-md" />
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map(i => (
            <Skeleton key={i} className="h-48 rounded-xl" />
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="relative">
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%),radial-gradient(circle_at_80%_20%,rgba(67,209,197,0.16),transparent_50%)]" />
      <div className="space-y-8">
        <DashboardTopBar userName={user?.full_name || 'Doer'} />
        <DashboardTitle />
        <div className="grid gap-6 xl:grid-cols-[minmax(0,1fr)_320px]">
          <HeroWorkspaceCard
            onExploreProjects={handleExploreProjects}
            onViewInsights={handleViewInsights}
            poolCount={poolTasks.length}
            completionRate={completionRate}
            assignedCount={activeCount}
          />
          <RightSummaryPanel
            assignedCount={assignedTasks.length}
            poolCount={poolTasks.length}
            urgentCount={urgentCount}
          />
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <QuickStatCard
            title="Assigned Tasks"
            value={assignedTasks.length}
            subtitle={`${activeCount} in progress`}
            icon={Briefcase}
            gradient="bg-gradient-to-br from-[#F5F3FF] via-[#F8F7FF] to-[#EEE9FF]"
            iconBg="bg-[#E9E3FF]"
            iconColor="text-[#7C3AED]"
          />
          <QuickStatCard
            title="Available Tasks"
            value={poolTasks.length}
            subtitle="In open pool"
            icon={Sparkles}
            gradient="bg-gradient-to-br from-[#F1F7FF] via-[#F6FAFF] to-[#E8F9FF]"
            iconBg="bg-[#E6F4FF]"
            iconColor="text-[#4B9BFF]"
          />
          <QuickStatCard
            title="Urgent"
            value={urgentCount}
            subtitle="Need attention"
            icon={Clock}
            gradient="bg-gradient-to-br from-[#FFF4F0] via-[#FFF7F4] to-[#FFEFE9]"
            iconBg="bg-[#FFE7E1]"
            iconColor="text-[#FF8B6A]"
          />
          <QuickStatCard
            title="Potential Earnings"
            value={`₹${totalEarningsPotential.toLocaleString('en-IN')}`}
            subtitle="Total available"
            icon={IndianRupee}
            gradient="bg-gradient-to-br from-[#EEF2FF] via-[#F5F6FF] to-[#E9EDFF]"
            iconBg="bg-[#E3E9FF]"
            iconColor="text-[#5B7CFF]"
          />
        </div>
        <div className="grid gap-4 lg:grid-cols-3">
          <PerformanceAnalysisCard
            activeCount={activeCount}
            urgentCount={urgentCount}
            completionRate={completionRate}
          />
          <TaskMixCard assignedCount={assignedTasks.length} poolCount={poolTasks.length} />
          <PriorityTasksCard tasks={priorityTasks} />
        </div>
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h2 className="text-lg font-semibold text-slate-900">Open works for doers</h2>
            <p className="text-sm text-slate-500">Review assigned tasks and pick from the pool.</p>
          </div>
          <button
            type="button"
            onClick={handleRefresh}
            disabled={isRefreshing}
            className="flex h-10 w-10 items-center justify-center rounded-full border border-slate-200/70 bg-white/80 text-slate-600 shadow-[0_10px_22px_rgba(30,58,138,0.08)] transition-all duration-300 hover:scale-105 hover:shadow-[0_12px_28px_rgba(30,58,138,0.12)] disabled:opacity-50 disabled:cursor-not-allowed"
            aria-label="Refresh tasks"
          >
            <RefreshCw className={cn('h-4 w-4 transition-transform duration-300', isRefreshing && 'animate-spin')} />
          </button>
        </div>
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-2 max-w-md h-12 rounded-full bg-white/85 p-1 shadow-[0_14px_28px_rgba(30,58,138,0.08)]">
            <TabsTrigger
              value="assigned"
              className="relative gap-2 rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:via-[#5B86FF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white"
            >
              <Briefcase className="h-4 w-4" />
              Assigned to Me
              {urgentCount > 0 && (
                <Badge
                  variant="secondary"
                  className="ml-1 h-5 w-5 rounded-full bg-white/80 p-0 text-xs font-semibold text-[#4F6CF7]"
                >
                  {urgentCount}
                </Badge>
              )}
            </TabsTrigger>
            <TabsTrigger
              value="pool"
              className="gap-2 rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:via-[#5B86FF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white"
            >
              <Sparkles className="h-4 w-4" />
              Open Pool
              <Badge
                variant="secondary"
                className="ml-1 rounded-full bg-[#EEF2FF] text-xs font-semibold text-[#4F6CF7]"
              >
                {poolTasks.length}
              </Badge>
            </TabsTrigger>
          </TabsList>

          <TabsContent value="assigned" className="mt-6">
            <AssignedTaskList
              projects={assignedTasks}
              isLoading={isLoading}
              onProjectClick={handleProjectClick}
            />
          </TabsContent>

          <TabsContent value="pool" className="mt-6">
            <TaskPoolList
              projects={poolTasks}
              isLoading={isLoading}
              onAcceptTask={handleAcceptTask}
              onProjectClick={handleProjectClick}
              onRefresh={handleRefresh}
            />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
