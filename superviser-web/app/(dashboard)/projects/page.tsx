/**
 * @fileoverview Projects Page - Redesigned with dashboard aesthetics
 * Charcoal + Orange accent palette with modern minimal design
 * @module app/(dashboard)/projects/page
 */

"use client"

import { Suspense, useState, useMemo, useCallback, useEffect, useRef } from "react"
import { motion } from "framer-motion"
import { useRouter, useSearchParams } from "next/navigation"
import {
  FileText,
  Zap,
  Clock,
  FileSearch,
  CheckCircle2,
  LayoutGrid,
  TrendingUp,
  ArrowRight,
  Calendar,
} from "lucide-react"
import { toast } from "sonner"
import { formatDistanceToNow } from "date-fns"

import { useProjectsByStatus, useSupervisor, claimProject } from "@/hooks"
import { useAuth } from "@/hooks"
import type { ProjectWithRelations } from "@/types/database"
import { apiFetch } from "@/lib/api/client"
import { Button } from "@/components/ui/button"
import { Skeleton } from "@/components/ui/skeleton"
import {
  ProjectsIllustration,
  ProjectStatusPills,
  ProjectStatCard,
  ProjectsSearchBar,
  ProjectCardV2,
  ProjectsEmptyState,
} from "@/components/projects/v2"
import type { ProjectCardV2Data } from "@/components/projects/v2"
import { QCReviewModal, type ActiveProject } from "@/components/projects"
import { AssignDoerModal } from "@/components/dashboard/assign-doer-modal"
import type { PaidProject } from "@/components/dashboard/ready-to-assign-card"

// Subject list for filter
const SUBJECTS = [
  "Computer Science",
  "Business Administration",
  "Environmental Science",
  "Finance",
  "Psychology",
  "Marketing",
  "Nursing",
  "Engineering",
  "Mathematics",
  "Literature",
]

export default function ProjectsPageWrapper() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-gray-50 flex items-center justify-center"><div className="animate-pulse text-gray-400">Loading projects...</div></div>}>
      <ProjectsPage />
    </Suspense>
  )
}

function ProjectsPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const { user } = useAuth()
  const firstName = user?.full_name?.split(" ")[0] || "Supervisor"
  const highlightedProjectRef = useRef<string | null>(null)

  // Active filter state
  const [activeFilter, setActiveFilter] = useState<string>("new")
  const [highlightedProject, setHighlightedProject] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedSubject, setSelectedSubject] = useState("all")
  const [sortBy, setSortBy] = useState<"deadline" | "created" | "amount">("deadline")

  // QC Modal state
  const [qcModalState, setQcModalState] = useState<{
    open: boolean
    project: ActiveProject | null
    mode: "approve" | "reject" | null
  }>({ open: false, project: null, mode: null })

  // Assign Doer Modal state
  const [assignModalState, setAssignModalState] = useState<{
    open: boolean
    project: PaidProject | null
  }>({ open: false, project: null })

  // Handle query parameters for filter and highlight
  // Support both ?tab= (used by dashboard links) and ?filter= (used by direct links)
  useEffect(() => {
    const filter = searchParams.get("tab") || searchParams.get("filter")
    const highlight = searchParams.get("highlight")

    if (filter && ["new", "ready", "ongoing", "review", "completed"].includes(filter)) {
      setActiveFilter(filter)
    }

    if (highlight) {
      setHighlightedProject(highlight)
      highlightedProjectRef.current = highlight
      // Clear highlight after 3 seconds
      setTimeout(() => {
        setHighlightedProject(null)
      }, 3000)
    }
  }, [searchParams])

  // Fetch projects data
  const {
    needsQuote,
    readyToAssign,
    inProgress,
    needsQC,
    completed,
    isLoading,
    error: projectsError,
    refetch,
  } = useProjectsByStatus()
  const { supervisor } = useSupervisor()

  // Helper to extract client name from project (handles both Supabase and MongoDB API shapes)
  const getClientName = (project: ProjectWithRelations, fallback = "Unknown User"): string => {
    const p = project as unknown as Record<string, unknown>
    const userId = p.userId as Record<string, unknown> | undefined
    const user = p.user as Record<string, unknown> | undefined
    return (userId?.fullName as string) || (userId?.full_name as string) || project.user?.full_name || (user?.fullName as string) || fallback
  }

  // Helper to extract user quote amount
  const getQuoteAmount = (project: ProjectWithRelations): number => {
    const p = project as unknown as Record<string, unknown>
    return (p.userQuote as number) || project.user_quote || 0
  }

  // Transform project to card format
  const transformToCardData = (project: ProjectWithRelations): ProjectCardV2Data => ({
    id: project.id,
    project_number: project.project_number,
    title: project.title,
    subject: project.subjects?.name || "General",
    service_type: project.service_type,
    status: project.status,
    deadline: project.deadline || new Date(Date.now() + 72 * 60 * 60 * 1000).toISOString(),
    user_name: getClientName(project),
    doer_name: project.doers?.full_name || undefined,
    quoted_amount: getQuoteAmount(project),
    supervisor_commission: project.supervisor_commission || 0,
    has_unread_messages: false,
    revision_count: (project as ProjectWithRelations & { revision_count?: number }).revision_count || 0,
    created_at: project.created_at || new Date().toISOString(),
  })

  // Transform to ActiveProject for QC modal
  const transformToActiveProject = (project: ProjectWithRelations): ActiveProject => ({
    id: project.id,
    project_number: project.project_number,
    title: project.title,
    subject: project.subjects?.name || "General",
    service_type: project.service_type,
    status: project.status,
    user_name: getClientName(project),
    user_id: project.user_id || "",
    doer_name: project.doers?.full_name || "Unassigned",
    doer_id: project.doer_id || "",
    deadline: project.deadline || new Date(Date.now() + 72 * 60 * 60 * 1000).toISOString(),
    word_count: project.word_count ?? undefined,
    page_count: project.page_count ?? undefined,
    quoted_amount: getQuoteAmount(project),
    doer_payout: project.doer_payout || 0,
    supervisor_commission: project.supervisor_commission || 0,
    assigned_at: project.doer_assigned_at || undefined,
    submitted_for_qc_at: project.status_updated_at || undefined,
    delivered_at: project.delivered_at || undefined,
    completed_at: project.completed_at || undefined,
    created_at: project.created_at || new Date().toISOString(),
    revision_count: 0,
    has_unread_messages: false,
  })

  // Calculate stats
  const stats = useMemo(() => {
    const totalActive = inProgress.length + needsQC.length
    const completedThisMonth = completed.filter(p => {
      const completedDate = p.completed_at ? new Date(p.completed_at) : null
      if (!completedDate) return false
      const now = new Date()
      return completedDate.getMonth() === now.getMonth() && completedDate.getFullYear() === now.getFullYear()
    }).length

    return {
      total: needsQuote.length + readyToAssign.length + inProgress.length + needsQC.length + completed.length,
      active: totalActive,
      forReview: needsQC.length,
      completedThisMonth,
    }
  }, [needsQuote, readyToAssign, inProgress, needsQC, completed])

  // Status pills configuration
  const statusPills = useMemo(() => [
    {
      id: "new",
      label: "New Requests",
      count: needsQuote.length,
      icon: FileText,
      badgeColor: needsQuote.length > 0 ? "#10B981" : undefined,
    },
    {
      id: "ready",
      label: "Ready to Assign",
      count: readyToAssign.length,
      icon: Zap,
      badgeColor: readyToAssign.length > 0 ? "#3B82F6" : undefined,
    },
    {
      id: "ongoing",
      label: "In Progress",
      count: inProgress.length,
      icon: Clock,
    },
    {
      id: "review",
      label: "For Review",
      count: needsQC.length,
      icon: FileSearch,
      badgeColor: needsQC.length > 0 ? "#F59E0B" : undefined,
    },
    {
      id: "completed",
      label: "Completed",
      count: completed.length,
      icon: CheckCircle2,
    },
  ], [needsQuote.length, readyToAssign.length, inProgress.length, needsQC.length, completed.length])

  const pipelineStages = useMemo(() => {
    const totalCount = stats.total || 1
    return [
      { label: "New Requests", count: needsQuote.length, color: "bg-emerald-500" },
      { label: "Ready to Assign", count: readyToAssign.length, color: "bg-blue-500" },
      { label: "In Progress", count: inProgress.length, color: "bg-orange-500" },
      { label: "For Review", count: needsQC.length, color: "bg-amber-500" },
    ].map((stage) => ({
      ...stage,
      percent: Math.round((stage.count / totalCount) * 100),
    }))
  }, [stats.total, needsQuote.length, readyToAssign.length, inProgress.length, needsQC.length])

  const upcomingProjects = useMemo(() => {
    const projects = [...inProgress, ...needsQC]

    // Deduplicate by ID using Map
    const uniqueProjects = Array.from(
      new Map(projects.map(p => [p.id, p])).values()
    )

    return uniqueProjects
      .filter((project) => project.deadline)
      .sort((a, b) => new Date(a.deadline || 0).getTime() - new Date(b.deadline || 0).getTime())
      .slice(0, 3)
  }, [inProgress, needsQC])

  // Filter projects
  const filterProjects = useCallback((projects: ProjectCardV2Data[]) => {
    return projects.filter((project) => {
      const matchesSearch =
        searchQuery === "" ||
        project.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        project.project_number.toLowerCase().includes(searchQuery.toLowerCase()) ||
        project.user_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (project.doer_name?.toLowerCase().includes(searchQuery.toLowerCase()) ?? false)

      const matchesSubject =
        selectedSubject === "all" || project.subject === selectedSubject

      return matchesSearch && matchesSubject
    })
  }, [searchQuery, selectedSubject])

  // Sort projects
  const sortProjects = useCallback((projects: ProjectCardV2Data[]) => {
    return [...projects].sort((a, b) => {
      switch (sortBy) {
        case "deadline":
          return new Date(a.deadline).getTime() - new Date(b.deadline).getTime()
        case "created":
          return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        case "amount":
          return (b.quoted_amount || 0) - (a.quoted_amount || 0)
        default:
          return 0
      }
    })
  }, [sortBy])

  // Get filtered projects based on active filter
  const filteredProjects = useMemo(() => {
    let sourceProjects: ProjectWithRelations[] = []

    switch (activeFilter) {
      case "new":
        sourceProjects = needsQuote
        break
      case "ready":
        sourceProjects = readyToAssign
        break
      case "ongoing":
        sourceProjects = inProgress
        break
      case "review":
        sourceProjects = needsQC
        break
      case "completed":
        sourceProjects = completed
        break
      default:
        sourceProjects = needsQuote
    }

    const transformed = sourceProjects.map(transformToCardData)
    return sortProjects(filterProjects(transformed))
  }, [activeFilter, needsQuote, readyToAssign, inProgress, needsQC, completed, filterProjects, sortProjects])

  // Check if search/filter is active with no results
  const hasActiveFilters = searchQuery !== "" || selectedSubject !== "all"
  const showNoResults = filteredProjects.length === 0 && hasActiveFilters

  const handleClearFilters = useCallback(() => {
    setSearchQuery("")
    setSelectedSubject("all")
  }, [])

  const focusNewRequests = useCallback(() => {
    setActiveFilter("new")
    setSearchQuery("")
    setSelectedSubject("all")
  }, [])

  // Handle claim project (or navigate directly if already assigned)
  const handleClaimProject = useCallback(async (projectId: string) => {
    try {
      // Check if this project is already assigned to the current supervisor
      const project = needsQuote.find(p => p.id === projectId)
      const alreadyAssigned = project?.supervisor_id || (project as any)?.supervisorId

      if (alreadyAssigned) {
        // Already assigned to us — go straight to analyze/quote
        router.push(`/projects/${projectId}`)
        return
      }

      await claimProject(projectId)
      toast.success("Project claimed successfully!")
      await refetch()
      router.push(`/projects/${projectId}`)
    } catch (error) {
      console.error("Failed to claim project:", error)
      toast.error("Failed to claim project. It may have been claimed by another supervisor.")
      await refetch()
    }
  }, [refetch, router, needsQuote])

  // Handle QC approve
  const handleApprove = useCallback(async (projectId: string, message?: string) => {
    try {
      await apiFetch(`/api/projects/${projectId}`, {
        method: "PUT",
        body: JSON.stringify({
          status: "qc_approved",
          status_updated_at: new Date().toISOString(),
          completion_notes: message || null,
        }),
      })
      toast.success("Project approved successfully")
      setQcModalState({ open: false, project: null, mode: null })
      await refetch()
    } catch (err) {
      console.error("Failed to approve project:", err)
      toast.error("Failed to approve project. Please try again.")
    }
  }, [refetch])

  // Handle QC reject
  const handleReject = useCallback(async (
    projectId: string,
    feedback: string,
    severity: "minor" | "major" | "critical"
  ) => {
    if (!supervisor?.id) {
      toast.error("Supervisor data not found")
      return
    }
    try {
      await apiFetch(`/api/projects/${projectId}/revisions`, {
        method: "POST",
        body: JSON.stringify({
          feedback,
          specificChanges: severity,
        }),
      })

      toast.success("Revision requested successfully")
      setQcModalState({ open: false, project: null, mode: null })
      await refetch()
    } catch (err) {
      console.error("Failed to reject project:", err)
      toast.error("Failed to request revision. Please try again.")
    }
  }, [supervisor, refetch])

  // Open QC Modal
  const openQCModal = (project: ProjectWithRelations, mode: "approve" | "reject") => {
    setQcModalState({
      open: true,
      project: transformToActiveProject(project),
      mode,
    })
  }

  // Get variant for card based on filter
  const getCardVariant = (): "new" | "ready" | "ongoing" | "review" | "completed" => {
    return activeFilter as "new" | "ready" | "ongoing" | "review" | "completed"
  }

  // Find original project for QC modal
  const findOriginalProject = (id: string): ProjectWithRelations | undefined => {
    return needsQC.find(p => p.id === id)
  }

  // Find project for assign modal
  const findProjectForAssign = (id: string): PaidProject | null => {
    const project = readyToAssign.find(p => p.id === id)
    if (!project) return null

    return {
      id: project.id,
      project_number: project.project_number,
      title: project.title,
      subject: project.subjects?.name || "General",
      service_type: project.service_type,
      user_name: getClientName(project),
      deadline: project.deadline || new Date(Date.now() + 72 * 60 * 60 * 1000).toISOString(),
      word_count: project.word_count ?? undefined,
      page_count: project.page_count ?? undefined,
      quoted_amount: getQuoteAmount(project),
      doer_payout: project.doer_payout || 0,
      paid_at: project.status_updated_at || project.created_at || new Date().toISOString(),
      created_at: project.created_at || new Date().toISOString(),
    }
  }

  // Handle assign doer
  const handleAssignDoer = useCallback(async (projectId: string, doerId: string) => {
    await refetch()
    setAssignModalState({ open: false, project: null })
  }, [refetch])

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="relative">
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-24 right-0 h-64 w-64 rounded-full bg-orange-100/60 blur-3xl" />
          <div className="absolute top-40 left-10 h-56 w-56 rounded-full bg-amber-100/50 blur-3xl" />
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4 }}
          className="relative max-w-[1400px] mx-auto p-6 lg:p-10"
        >
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.5 }}
            className="relative overflow-hidden rounded-3xl border border-gray-200 bg-white p-6 lg:p-8 mb-10"
          >
            <div className="absolute -top-16 left-1/3 h-44 w-44 rounded-full bg-orange-100/50 blur-3xl" />
            <div className="absolute -bottom-16 right-10 h-44 w-44 rounded-full bg-amber-100/50 blur-3xl" />

            <div className="relative grid lg:grid-cols-[1.1fr_0.9fr] gap-8 items-center">
              <div className="space-y-6">
                <div>
                  <p className="text-xs uppercase tracking-[0.2em] text-gray-400">Projects Studio</p>
                  <h1 className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight mt-2">
                    Projects, {firstName}
                  </h1>
                  <p className="text-lg text-gray-500 mt-3">
                    {needsQuote.length > 0
                      ? `${needsQuote.length} new request${needsQuote.length > 1 ? "s" : ""} waiting for you`
                      : needsQC.length > 0
                        ? `${needsQC.length} project${needsQC.length > 1 ? "s" : ""} ready for review`
                        : "Everything looks steady. Your queue is under control."}
                  </p>
                </div>

                <div className="flex flex-wrap items-center gap-3">
                  <Button
                    onClick={focusNewRequests}
                    className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
                  >
                    Review New Requests
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                  <Button
                    variant="outline"
                    onClick={() => setActiveFilter("ongoing")}
                    className="rounded-full h-11 px-5 border-gray-200 text-gray-700"
                  >
                    Active Queue
                  </Button>
                </div>

                <div className="flex flex-wrap items-center gap-2 text-xs text-gray-500">
                  <span className="px-3 py-1 rounded-full bg-gray-100">Total {stats.total}</span>
                  <span className="px-3 py-1 rounded-full bg-orange-50 text-orange-700">Active {stats.active}</span>
                  <span className="px-3 py-1 rounded-full bg-emerald-50 text-emerald-700">Completed {stats.completedThisMonth}</span>
                </div>
              </div>

              <div className="space-y-4">
                <div className="w-full h-[220px]">
                  <ProjectsIllustration />
                </div>
                <div className="rounded-2xl border border-gray-200 bg-gray-50/80 p-4">
                  <div className="flex items-center justify-between">
                    <h3 className="text-sm font-semibold text-[#1C1C1C]">Pipeline Snapshot</h3>
                    <span className="text-xs text-gray-400">{stats.total} total</span>
                  </div>
                  <div className="mt-4 space-y-3">
                    {pipelineStages.map((stage) => (
                      <div key={stage.label} className="space-y-1">
                        <div className="flex items-center justify-between text-xs text-gray-500">
                          <span>{stage.label}</span>
                          <span>{stage.count}</span>
                        </div>
                        <div className="h-2 rounded-full bg-white border border-gray-200 overflow-hidden">
                          <div
                            className={stage.color}
                            style={{ width: `${stage.percent}%`, height: "100%" }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </motion.section>

          <div className="grid lg:grid-cols-[320px_1fr] gap-8">
            <aside className="space-y-6">
              <div className="space-y-3">
                <div>
                  <h2 className="text-sm font-semibold text-[#1C1C1C]">Status Rail</h2>
                  <p className="text-xs text-gray-500">Track projects by stage and jump in.</p>
                </div>
                <ProjectStatusPills
                  pills={statusPills}
                  activeId={activeFilter}
                  onSelect={setActiveFilter}
                />
              </div>


              <div className="rounded-2xl border border-gray-200 bg-white p-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-semibold text-[#1C1C1C]">Due Soon</h3>
                  <span className="text-xs text-gray-400">{upcomingProjects.length} items</span>
                </div>
                {upcomingProjects.length === 0 ? (
                  <p className="text-xs text-gray-500 mt-3">No upcoming deadlines in your active queue.</p>
                ) : (
                  <div className="mt-3 space-y-3">
                    {upcomingProjects.map((project) => (
                      <div key={project.id} className="flex items-start justify-between gap-3">
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium text-gray-900 line-clamp-1">{project.title}</p>
                          <p className="text-xs text-gray-500 mt-1">
                            #{project.project_number} • {getClientName(project, "Client")}
                          </p>
                        </div>
                        <div className="text-xs text-gray-500 flex items-center gap-1 flex-shrink-0 whitespace-nowrap">
                          <Calendar className="h-3.5 w-3.5 flex-shrink-0" />
                          <span>
                            {project.deadline
                              ? formatDistanceToNow(new Date(project.deadline), { addSuffix: true })
                              : "No deadline"}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </aside>

            <section className="space-y-6">
              <ProjectsSearchBar
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
                selectedSubject={selectedSubject}
                onSubjectChange={setSelectedSubject}
                sortBy={sortBy}
                onSortChange={setSortBy}
                subjects={SUBJECTS}
                hasActiveFilters={hasActiveFilters}
                onClearFilters={handleClearFilters}
              />

              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.35, duration: 0.5 }}
                className="bg-white rounded-2xl border border-gray-200 p-6"
              >
                <div className="flex items-center justify-between mb-6">
                  <div>
                    <h2 className="text-lg font-semibold text-[#1C1C1C]">
                      {statusPills.find(p => p.id === activeFilter)?.label || "Projects"}
                    </h2>
                    <p className="text-sm text-gray-500">
                      {filteredProjects.length} project{filteredProjects.length !== 1 ? "s" : ""}
                      {hasActiveFilters && " matching filters"}
                    </p>
                  </div>
                </div>

                {isLoading && (
                  <div className="grid gap-4 sm:grid-cols-2 2xl:grid-cols-3">
                    {[1, 2, 3, 4, 5, 6].map((i) => (
                      <div key={i} className="bg-white rounded-2xl border border-gray-200 p-5 space-y-4">
                        <div className="flex items-center justify-between">
                          <Skeleton className="h-4 w-20" />
                          <Skeleton className="h-5 w-16" />
                        </div>
                        <div className="space-y-2">
                          <Skeleton className="h-5 w-full" />
                          <Skeleton className="h-4 w-2/3" />
                        </div>
                        <div className="flex items-center justify-between py-3 border-y border-gray-100">
                          <div className="flex items-center gap-2">
                            <Skeleton className="h-8 w-8 rounded-full" />
                            <Skeleton className="h-4 w-24" />
                          </div>
                          <Skeleton className="h-4 w-16" />
                        </div>
                        <div className="flex gap-2">
                          <Skeleton className="h-10 flex-1 rounded-xl" />
                          <Skeleton className="h-10 w-10 rounded-xl" />
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                {!isLoading && projectsError && (
                  <div className="text-center py-12">
                    <p className="text-red-600 font-medium mb-2">Failed to load projects</p>
                    <p className="text-sm text-gray-500 mb-4">{projectsError.message}</p>
                    <Button
                      onClick={() => refetch()}
                      variant="outline"
                      className="rounded-full"
                    >
                      Retry
                    </Button>
                  </div>
                )}

                {!isLoading && !projectsError && showNoResults && (
                  <ProjectsEmptyState
                    variant="search"
                    searchQuery={searchQuery}
                    onClearSearch={handleClearFilters}
                  />
                )}

                {!isLoading && !projectsError && !showNoResults && filteredProjects.length === 0 && (
                  <ProjectsEmptyState variant={getCardVariant()} />
                )}

                {!isLoading && filteredProjects.length > 0 && (
                  <div className="grid gap-4 sm:grid-cols-2 2xl:grid-cols-3">
                    {filteredProjects.map((project) => (
                      <ProjectCardV2
                        key={project.id}
                        project={project}
                        variant={getCardVariant()}
                        highlighted={highlightedProject === project.id}
                        onClaim={() => handleClaimProject(project.id)}
                        onAssign={() => {
                          const paidProject = findProjectForAssign(project.id)
                          if (paidProject) {
                            setAssignModalState({ open: true, project: paidProject })
                          }
                        }}
                        onApprove={() => {
                          const original = findOriginalProject(project.id)
                          if (original) openQCModal(original, "approve")
                        }}
                        onReject={() => {
                          const original = findOriginalProject(project.id)
                          if (original) openQCModal(original, "reject")
                        }}
                      />
                    ))}
                  </div>
                )}
              </motion.div>
            </section>
          </div>
        </motion.div>
      </div>

      {/* QC Review Modal */}
      <QCReviewModal
        project={qcModalState.project}
        mode={qcModalState.mode}
        open={qcModalState.open}
        onOpenChange={(open) =>
          setQcModalState({ ...qcModalState, open, mode: open ? qcModalState.mode : null })
        }
        onApprove={handleApprove}
        onReject={handleReject}
      />

      {/* Assign Doer Modal */}
      <AssignDoerModal
        project={assignModalState.project}
        isOpen={assignModalState.open}
        onClose={() => setAssignModalState({ open: false, project: null })}
        onAssign={handleAssignDoer}
      />
    </div>
  )
}
