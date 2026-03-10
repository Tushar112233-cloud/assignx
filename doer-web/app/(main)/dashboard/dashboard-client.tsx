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
  ArrowRight,
  TrendingUp,
  Zap,
} from 'lucide-react'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { Card, CardContent } from '@/components/ui/card'
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
    supervisorName: dbProject.supervisor?.full_name,
    isUrgent: isDeadlineUrgent(dbProject.deadline),
  }
}

/**
 * Format a deadline date for priority list display.
 */
function formatDeadline(date: Date) {
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

/* ─────────────────────────────────────────────────────────────────
   1. TOP UTILITY BAR
   Search + bell + quick action — sits above everything
   ───────────────────────────────────────────────────────────── */
function UtilityBar() {
  return (
    <div className="flex items-center gap-2.5">
      <div className="relative flex-1 max-w-md">
        <Search className="absolute left-3.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-slate-400" />
        <input
          className="h-10 w-full rounded-xl border border-slate-200/80 bg-white/90 pl-10 pr-4 text-sm text-slate-700 shadow-sm outline-none transition placeholder:text-slate-400 hover:border-slate-300 focus:border-[#5A7CFF] focus:ring-2 focus:ring-[#E7ECFF]"
          placeholder="Search tasks, projects, or messages..."
          type="search"
        />
      </div>
      <button
        className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-slate-200/80 bg-white/90 text-slate-500 shadow-sm transition hover:border-[#5A7CFF]/40 hover:text-[#4F6CF7]"
        type="button"
        aria-label="View notifications"
      >
        <Bell className="h-4 w-4" />
      </button>
      <button
        className="hidden sm:flex h-10 shrink-0 items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-5 text-sm font-semibold text-white shadow-[0_4px_16px_rgba(90,124,255,0.3)] transition hover:-translate-y-0.5 hover:shadow-[0_8px_24px_rgba(90,124,255,0.4)]"
        type="button"
      >
        <span className="text-lg leading-none">+</span>
        <span>Quick</span>
      </button>
    </div>
  )
}

/* ─────────────────────────────────────────────────────────────────
   2. HERO BANNER
   Gradient mesh background (from landing page), greeting on left,
   inline stat strip, CTA buttons. RIGHT side: 2 stacked stat cards.
   ───────────────────────────────────────────────────────────── */
function HeroBanner({
  userName,
  assignedCount,
  activeCount,
  poolCount,
  urgentCount,
  totalEarnings,
  completionRate,
  onExploreProjects,
  onViewInsights,
}: {
  userName: string
  assignedCount: number
  activeCount: number
  poolCount: number
  urgentCount: number
  totalEarnings: number
  completionRate: number
  onExploreProjects: () => void
  onViewInsights: () => void
}) {
  const hour = new Date().getHours()
  const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening'

  return (
    <div className="grid gap-4 xl:grid-cols-[1fr_320px]">
      {/* ── Left: Greeting + stats + CTAs ── */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-6 shadow-[0_2px_12px_rgba(30,58,138,0.06)]">
        {/* Mesh gradient orbs (from landing hero-section) */}
        <div className="pointer-events-none absolute -top-16 -right-16 h-48 w-48 rounded-full bg-[#5A7CFF]/[0.07] blur-3xl" />
        <div className="pointer-events-none absolute -bottom-12 -left-12 h-36 w-36 rounded-full bg-[#49C5FF]/[0.06] blur-3xl" />

        <div className="relative">
          {/* Active badge (from landing hero pulsing dot) */}
          <div className="mb-3 inline-flex items-center gap-2 rounded-full border border-[#5A7CFF]/15 bg-white/70 px-3 py-1">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-[#5A7CFF] opacity-50" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-[#5A7CFF]" />
            </span>
            <span className="text-[11px] font-semibold text-[#4F6CF7]">Workspace active</span>
          </div>

          {/* Greeting */}
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            {greeting},{' '}
            <span className="bg-gradient-to-r from-[#4F46E5] via-[#5A7CFF] to-[#818CF8] bg-clip-text text-transparent">
              {userName}
            </span>
          </h1>
          <p className="mt-1 text-sm text-slate-500 max-w-lg leading-relaxed">
            {urgentCount > 0
              ? `You have ${urgentCount} urgent task${urgentCount !== 1 ? 's' : ''} that need${urgentCount === 1 ? 's' : ''} attention. Stay on track and keep delivering.`
              : 'Your workspace is ready. Explore new opportunities and keep your momentum going.'}
          </p>

          {/* Inline stat strip (from landing hero stats pattern) */}
          <div className="mt-4 flex flex-wrap items-center gap-x-5 gap-y-2 border-t border-[#5A7CFF]/10 pt-4">
            <div>
              <span className="text-lg font-bold text-slate-900">{activeCount}</span>
              <span className="ml-1.5 text-xs text-slate-400">active</span>
            </div>
            <div className="h-4 w-px bg-slate-200/80" />
            <div>
              <span className="text-lg font-bold text-slate-900">{poolCount}</span>
              <span className="ml-1.5 text-xs text-slate-400">available</span>
            </div>
            <div className="h-4 w-px bg-slate-200/80" />
            <div>
              <span className={cn('text-lg font-bold', urgentCount > 0 ? 'text-[#FF8B6A]' : 'text-slate-900')}>{urgentCount}</span>
              <span className="ml-1.5 text-xs text-slate-400">urgent</span>
            </div>
            <div className="h-4 w-px bg-slate-200/80" />
            <div>
              <span className="text-lg font-bold text-[#5A7CFF]">{completionRate.toFixed(0)}%</span>
              <span className="ml-1.5 text-xs text-slate-400">completion</span>
            </div>
          </div>

          {/* CTAs */}
          <div className="mt-4 flex flex-wrap items-center gap-2.5">
            <button
              onClick={onExploreProjects}
              className="h-9 rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-5 text-xs font-semibold text-white shadow-[0_4px_14px_rgba(90,124,255,0.3)] transition hover:-translate-y-0.5 hover:shadow-[0_6px_20px_rgba(90,124,255,0.4)]"
              type="button"
            >
              Explore projects
              <ArrowRight className="ml-1.5 inline h-3.5 w-3.5" />
            </button>
            <button
              onClick={onViewInsights}
              className="h-9 rounded-full border border-slate-200/80 bg-white/80 px-5 text-xs font-semibold text-slate-600 shadow-sm transition hover:border-slate-300 hover:text-slate-800"
              type="button"
            >
              View insights
            </button>
          </div>
        </div>
      </div>

      {/* ── Right: 2 stacked highlight cards ── */}
      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-1">
        {/* Earnings card — gradient hero treatment */}
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] p-5 text-white shadow-[0_8px_30px_rgba(90,124,255,0.25)]">
          <div className="pointer-events-none absolute top-0 right-0 h-20 w-20 rounded-full bg-white/10 -translate-y-6 translate-x-6" />
          <div className="pointer-events-none absolute bottom-0 left-0 h-14 w-14 rounded-full bg-white/5 translate-y-5 -translate-x-5" />
          <div className="relative">
            <div className="flex items-center justify-between mb-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-white/20">
                <IndianRupee className="h-4 w-4" />
              </div>
              {poolCount > 0 && (
                <span className="rounded-full bg-white/20 px-2 py-0.5 text-[10px] font-semibold">
                  +{poolCount} tasks
                </span>
              )}
            </div>
            <p className="text-[11px] font-medium text-white/60 uppercase tracking-wider">Potential earnings</p>
            <p className="text-2xl font-bold mt-0.5 leading-tight tabular-nums">
              ₹{totalEarnings.toLocaleString('en-IN')}
            </p>
            <p className="text-[11px] text-white/50 mt-1">From all available tasks</p>
          </div>
        </div>

        {/* Completion rate card with ring */}
        <div className="relative overflow-hidden rounded-2xl border border-slate-200/60 bg-white/90 p-5 shadow-[0_2px_8px_rgba(30,58,138,0.04)]">
          <div className="flex items-center gap-3.5">
            <div className="relative h-14 w-14 shrink-0">
              <svg className="h-14 w-14 -rotate-90" viewBox="0 0 36 36">
                <path
                  className="text-slate-100"
                  d="M18 2.0845a 15.9155 15.9155 0 0 1 0 31.831 15.9155 15.9155 0 0 1 0 -31.831"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="3.5"
                />
                <path
                  className="text-[#5A7CFF]"
                  d="M18 2.0845a 15.9155 15.9155 0 0 1 0 31.831 15.9155 15.9155 0 0 1 0 -31.831"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="3.5"
                  strokeDasharray={`${completionRate}, 100`}
                  strokeLinecap="round"
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center">
                <span className="text-xs font-bold text-slate-800">{completionRate.toFixed(0)}%</span>
              </div>
            </div>
            <div>
              <p className="text-sm font-semibold text-slate-800">On track</p>
              <p className="text-[11px] text-slate-400 mt-0.5">{assignedCount} assigned · {activeCount} active</p>
              <p className="text-[11px] text-slate-400">{urgentCount > 0 ? `${urgentCount} need attention` : 'All clear'}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

/* ─────────────────────────────────────────────────────────────────
   3. QUICK STAT CARDS ROW
   4 cards — Assigned, Available, Urgent, Earnings
   ───────────────────────────────────────────────────────────── */
function QuickStatCard({
  label,
  value,
  subtitle,
  icon: Icon,
  iconBg,
  iconColor,
  hoverGradient,
  accent,
  onClick,
}: {
  label: string
  value: string | number
  subtitle: string
  icon: React.ElementType
  iconBg: string
  iconColor: string
  hoverGradient: string
  accent?: boolean
  onClick?: () => void
}) {
  const Wrapper = onClick ? 'button' : 'div'
  return (
    <Wrapper
      type={onClick ? 'button' : undefined}
      onClick={onClick}
      className={cn(
        'group relative overflow-hidden rounded-2xl border bg-white/90 p-4 text-left transition-all',
        'shadow-[0_2px_8px_rgba(30,58,138,0.04)]',
        'hover:shadow-[0_8px_24px_rgba(30,58,138,0.1)] hover:-translate-y-0.5',
        accent ? 'border-[#FF8B6A]/25' : 'border-slate-200/60',
        onClick && 'cursor-pointer'
      )}
    >
      {/* Bento hover gradient reveal (from landing benefits-section) */}
      <div className={cn('absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-300', hoverGradient)} />
      <div className="relative">
        <div className="flex items-center justify-between mb-2.5">
          <div className={cn('flex h-9 w-9 items-center justify-center rounded-xl transition-transform duration-300 group-hover:scale-110', iconBg)}>
            <Icon className={cn('h-4 w-4', iconColor)} />
          </div>
          {accent && (
            <span className="flex items-center gap-1 rounded-full bg-[#FFE7E1] px-2 py-0.5 text-[10px] font-semibold text-[#E8704A]">
              <Zap className="h-2.5 w-2.5" />
              Action
            </span>
          )}
        </div>
        <p className="text-[11px] font-medium text-slate-400 uppercase tracking-wider">{label}</p>
        <p className="text-2xl font-bold text-slate-900 mt-0.5 leading-tight tabular-nums">{value}</p>
        <p className="text-[11px] text-slate-400 mt-0.5">{subtitle}</p>
      </div>
    </Wrapper>
  )
}

/* ─────────────────────────────────────────────────────────────────
   4. ANALYSIS CARDS ROW
   Performance, Task Mix, Priority Tasks — with bento hover effect
   ───────────────────────────────────────────────────────────── */
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
    <div className="group relative overflow-hidden rounded-2xl border border-slate-200/60 bg-white/90 p-5 shadow-[0_2px_8px_rgba(30,58,138,0.04)] transition-all hover:shadow-[0_6px_20px_rgba(30,58,138,0.08)] hover:-translate-y-0.5">
      <div className="absolute inset-0 bg-gradient-to-br from-blue-500/[0.03] to-indigo-500/[0.02] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
      <div className="relative">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#E3E9FF] transition-transform duration-300 group-hover:scale-110">
            <Target className="h-4 w-4 text-[#4F6CF7]" />
          </div>
          <div>
            <p className="text-sm font-semibold text-slate-800">Performance</p>
            <p className="text-[11px] text-slate-400">Delivery health</p>
          </div>
        </div>
        <div className="mt-3.5 space-y-2">
          <div className="flex items-center justify-between rounded-xl bg-slate-50/80 px-3 py-2">
            <span className="text-xs text-slate-500">Completion rate</span>
            <span className="text-sm font-semibold text-slate-800">{completionRate.toFixed(0)}%</span>
          </div>
          <div className="flex items-center justify-between rounded-xl bg-slate-50/80 px-3 py-2">
            <span className="text-xs text-slate-500">Active tasks</span>
            <span className="text-sm font-semibold text-slate-800">{activeCount}</span>
          </div>
          <div className="flex items-center justify-between rounded-xl bg-slate-50/80 px-3 py-2">
            <span className="text-xs text-slate-500">Urgent tasks</span>
            <span className={cn('text-sm font-semibold', urgentCount > 0 ? 'text-[#FF8B6A]' : 'text-slate-800')}>{urgentCount}</span>
          </div>
        </div>
      </div>
    </div>
  )
}

function TaskMixCard({ assignedCount, poolCount }: { assignedCount: number; poolCount: number }) {
  const total = assignedCount + poolCount
  const assignedPercent = total ? (assignedCount / total) * 100 : 0
  const poolPercent = total ? (poolCount / total) * 100 : 0

  return (
    <div className="group relative overflow-hidden rounded-2xl border border-slate-200/60 bg-white/90 p-5 shadow-[0_2px_8px_rgba(30,58,138,0.04)] transition-all hover:shadow-[0_6px_20px_rgba(30,58,138,0.08)] hover:-translate-y-0.5">
      <div className="absolute inset-0 bg-gradient-to-br from-sky-500/[0.03] to-blue-500/[0.02] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
      <div className="relative">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#E6F4FF] transition-transform duration-300 group-hover:scale-110">
            <Layers className="h-4 w-4 text-[#4B9BFF]" />
          </div>
          <div>
            <p className="text-sm font-semibold text-slate-800">Task mix</p>
            <p className="text-[11px] text-slate-400">Assigned vs pool</p>
          </div>
        </div>
        <div className="mt-3.5">
          <div className="flex h-2.5 overflow-hidden rounded-full bg-slate-100">
            <div className="bg-[#5B7CFF] rounded-l-full transition-all duration-500" style={{ width: `${assignedPercent}%` }} />
            <div className="bg-[#45C7F3] rounded-r-full transition-all duration-500" style={{ width: `${poolPercent}%` }} />
          </div>
          <div className="mt-3 flex items-center justify-between text-xs text-slate-500">
            <div className="flex items-center gap-1.5">
              <div className="h-2 w-2 rounded-full bg-[#5B7CFF]" />
              <span>Assigned</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="h-2 w-2 rounded-full bg-[#45C7F3]" />
              <span>Open pool</span>
            </div>
          </div>
          <div className="mt-1.5 flex items-center justify-between text-sm font-bold text-slate-800">
            <span>{assignedCount}</span>
            <span>{poolCount}</span>
          </div>
        </div>
      </div>
    </div>
  )
}

function PriorityTasksCard({
  tasks,
  onTaskClick,
}: {
  tasks: PriorityTask[]
  onTaskClick: (id: string) => void
}) {
  return (
    <div className="group relative overflow-hidden rounded-2xl border border-slate-200/60 bg-white/90 p-5 shadow-[0_2px_8px_rgba(30,58,138,0.04)] transition-all hover:shadow-[0_6px_20px_rgba(30,58,138,0.08)] hover:-translate-y-0.5">
      <div className="absolute inset-0 bg-gradient-to-br from-orange-500/[0.03] to-red-500/[0.02] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
      <div className="relative">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#FFE7E1] transition-transform duration-300 group-hover:scale-110">
            <AlertTriangle className="h-4 w-4 text-[#FF8B6A]" />
          </div>
          <div>
            <p className="text-sm font-semibold text-slate-800">Priority tasks</p>
            <p className="text-[11px] text-slate-400">Needs attention</p>
          </div>
        </div>
        <div className="mt-3.5 space-y-2">
          {tasks.length === 0 ? (
            <div className="rounded-xl bg-emerald-50/60 border border-emerald-100/60 px-3 py-3 text-center">
              <p className="text-xs font-medium text-emerald-600">All clear — no priority tasks</p>
            </div>
          ) : (
            tasks.map((task) => (
              <button
                key={task.id}
                type="button"
                onClick={() => onTaskClick(task.id)}
                className="w-full rounded-xl bg-slate-50/80 px-3 py-2.5 text-left transition hover:bg-slate-100/80"
              >
                <div className="flex items-center justify-between gap-2">
                  <p className="text-xs font-semibold text-slate-700 line-clamp-1">{task.title}</p>
                  <Badge className="shrink-0 bg-[#FFE7E1] text-[#FF8B6A] hover:bg-[#FFE7E1]" variant="secondary">
                    {task.priorityLabel}
                  </Badge>
                </div>
                <p className="mt-0.5 text-[11px] text-slate-400">Due {formatDeadline(task.deadline)}</p>
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  )
}

/* ─────────────────────────────────────────────────────────────────
   MAIN DASHBOARD CLIENT
   ───────────────────────────────────────────────────────────── */
export function DashboardClient() {
  const router = useRouter()
  const { user, doer: authDoer, isLoading: authLoading } = useAuth()
  const [isLoading, setIsLoading] = useState(true)
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [assignedTasks, setAssignedTasks] = useState<Project[]>([])
  const [poolTasks, setPoolTasks] = useState<Project[]>([])
  const [activeTab, setActiveTab] = useState('assigned')

  const loadTasks = useCallback(async (showRefresh = false) => {
    if (!authDoer?.id) return
    if (showRefresh) setIsRefreshing(true)
    else setIsLoading(true)

    try {
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

  useEffect(() => {
    if (authDoer?.id) loadTasks()
    else if (!authLoading) setIsLoading(false)
  }, [authDoer?.id, authLoading, loadTasks])

  useProjectSubscription({
    doerId: authDoer?.id,
    onProjectAssigned: (project) => {
      setAssignedTasks((prev) => [...prev, transformProject(project as ProjectWithSupervisor)])
      toast.success('New project assigned to you!')
    },
    onProjectUpdate: (project) => {
      const t = transformProject(project as ProjectWithSupervisor)
      setAssignedTasks((prev) => prev.map((p) => (p.id === t.id ? t : p)))
    },
    onStatusChange: (project, _old, newStatus) => {
      setAssignedTasks((prev) =>
        prev.map((p) => p.id === project.id ? { ...p, status: newStatus as Project['status'] } : p)
      )
      if (newStatus === 'revision_requested') toast.warning('Revision requested for a project')
    },
    enabled: !!authDoer?.id,
  })

  useNewProjectsSubscription({
    enabled: true,
    onNewProject: (project) => {
      setPoolTasks((prev) => [...prev, transformProject(project as ProjectWithSupervisor)])
      toast.info('New project available in the pool!')
    },
  })

  const handleAcceptTask = useCallback(async (projectId: string) => {
    if (!authDoer?.id) { toast.error('Please log in to accept tasks'); return }
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

  const handleProjectClick = useCallback((projectId: string) => {
    router.push(`${ROUTES.projects}/${projectId}`)
  }, [router])

  const handleRefresh = useCallback(async () => { await loadTasks(true) }, [loadTasks])
  const handleExploreProjects = useCallback(() => { router.push(ROUTES.projects) }, [router])
  const handleViewInsights = useCallback(() => { router.push(ROUTES.statistics) }, [router])

  /** Derived metrics */
  const urgentCount = useMemo(() =>
    assignedTasks.filter(t => t.isUrgent || t.status === 'revision_requested').length,
    [assignedTasks]
  )
  const totalEarningsPotential = useMemo(() =>
    [...assignedTasks, ...poolTasks].reduce((sum, t) => sum + t.price, 0),
    [assignedTasks, poolTasks]
  )
  const activeCount = assignedTasks.filter(t => t.status === 'in_progress' || t.status === 'assigned').length
  const completedCount = assignedTasks.filter(t => t.status === 'completed').length
  const completionRate = assignedTasks.length ? (completedCount / assignedTasks.length) * 100 : 0

  const priorityTasks: PriorityTask[] = useMemo(() => {
    return assignedTasks
      .filter(t => t.isUrgent || t.status === 'revision_requested')
      .sort((a, b) => a.deadline.getTime() - b.deadline.getTime())
      .slice(0, 3)
      .map(task => ({
        ...task,
        priorityLabel: task.status === 'revision_requested' ? 'Revision' : 'Urgent',
      }))
  }, [assignedTasks])

  /** Loading skeleton */
  if (authLoading) {
    return (
      <div className="space-y-5">
        <Skeleton className="h-10 w-full max-w-md rounded-xl" />
        <div className="grid gap-4 xl:grid-cols-[1fr_320px]">
          <Skeleton className="h-[220px] rounded-2xl" />
          <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-1">
            <Skeleton className="h-[104px] rounded-2xl" />
            <Skeleton className="h-[104px] rounded-2xl" />
          </div>
        </div>
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {[1, 2, 3, 4].map(i => <Skeleton key={i} className="h-[110px] rounded-2xl" />)}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-5">
      {/* Row 1: Utility bar */}
      <UtilityBar />

      {/* Row 2: Hero banner with greeting + right stat cards */}
      <HeroBanner
        userName={user?.full_name || 'Doer'}
        assignedCount={assignedTasks.length}
        activeCount={activeCount}
        poolCount={poolTasks.length}
        urgentCount={urgentCount}
        totalEarnings={totalEarningsPotential}
        completionRate={completionRate}
        onExploreProjects={handleExploreProjects}
        onViewInsights={handleViewInsights}
      />

      {/* Row 3: Quick stat cards */}
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        <QuickStatCard
          label="Assigned Tasks"
          value={assignedTasks.length}
          subtitle={`${activeCount} in progress`}
          icon={Briefcase}
          iconBg="bg-[#EFEBFF]"
          iconColor="text-[#7C3AED]"
          hoverGradient="from-purple-500/[0.04] to-indigo-500/[0.02]"
          onClick={() => setActiveTab('assigned')}
        />
        <QuickStatCard
          label="Available Tasks"
          value={poolTasks.length}
          subtitle="In open pool"
          icon={Sparkles}
          iconBg="bg-[#E6F4FF]"
          iconColor="text-[#4B9BFF]"
          hoverGradient="from-sky-500/[0.04] to-blue-500/[0.02]"
          onClick={() => setActiveTab('pool')}
        />
        <QuickStatCard
          label="Urgent"
          value={urgentCount}
          subtitle="Need attention"
          icon={Clock}
          iconBg="bg-[#FFE7E1]"
          iconColor="text-[#FF8B6A]"
          hoverGradient="from-orange-500/[0.04] to-red-500/[0.02]"
          accent={urgentCount > 0}
          onClick={() => setActiveTab('assigned')}
        />
        <QuickStatCard
          label="Potential Earnings"
          value={`₹${totalEarningsPotential.toLocaleString('en-IN')}`}
          subtitle="Total available"
          icon={IndianRupee}
          iconBg="bg-[#E3E9FF]"
          iconColor="text-[#5B7CFF]"
          hoverGradient="from-blue-500/[0.04] to-indigo-500/[0.02]"
        />
      </div>

      {/* Row 4: Analysis cards */}
      <div className="grid gap-3 lg:grid-cols-3">
        <PerformanceAnalysisCard activeCount={activeCount} urgentCount={urgentCount} completionRate={completionRate} />
        <TaskMixCard assignedCount={assignedTasks.length} poolCount={poolTasks.length} />
        <PriorityTasksCard tasks={priorityTasks} onTaskClick={handleProjectClick} />
      </div>

      {/* Row 5: Task workspace */}
      <div>
        <div className="flex items-center justify-between gap-4 mb-4">
          <div>
            <h2 className="text-base font-semibold text-slate-800">Your tasks</h2>
            <p className="text-xs text-slate-400">Review assigned work and pick from the pool</p>
          </div>
          <button
            type="button"
            onClick={handleRefresh}
            disabled={isRefreshing}
            className="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200/70 bg-white/80 text-slate-500 shadow-sm transition hover:border-slate-300 hover:text-slate-700 disabled:opacity-50"
            aria-label="Refresh tasks"
          >
            <RefreshCw className={cn('h-3.5 w-3.5', isRefreshing && 'animate-spin')} />
          </button>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-2 max-w-sm h-11 rounded-full bg-white/90 border border-slate-200/70 p-1 shadow-[0_2px_8px_rgba(30,58,138,0.04)]">
            <TabsTrigger
              value="assigned"
              className="relative gap-2 rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:via-[#5B86FF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white data-[state=active]:shadow-sm"
            >
              <Briefcase className="h-4 w-4" />
              Assigned to Me
              {urgentCount > 0 && (
                <Badge variant="secondary" className="ml-1 h-5 w-5 rounded-full bg-white/80 p-0 text-xs font-semibold text-[#FF8B6A]">
                  {urgentCount}
                </Badge>
              )}
            </TabsTrigger>
            <TabsTrigger
              value="pool"
              className="gap-2 rounded-full text-sm data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:via-[#5B86FF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white data-[state=active]:shadow-sm"
            >
              <Sparkles className="h-4 w-4" />
              Open Pool
              <Badge variant="secondary" className="ml-1 rounded-full bg-[#EEF2FF] text-xs font-semibold text-[#4F6CF7]">
                {poolTasks.length}
              </Badge>
            </TabsTrigger>
          </TabsList>

          <TabsContent value="assigned" className="mt-5">
            <AssignedTaskList projects={assignedTasks} isLoading={isLoading} onProjectClick={handleProjectClick} />
          </TabsContent>

          <TabsContent value="pool" className="mt-5">
            <TaskPoolList projects={poolTasks} isLoading={isLoading} onAcceptTask={handleAcceptTask} onProjectClick={handleProjectClick} onRefresh={handleRefresh} />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
