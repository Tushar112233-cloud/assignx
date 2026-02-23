/**
 * @fileoverview Individual project detail page showing full project information, timeline, participants, and QC interface.
 * @module app/(dashboard)/projects/[projectId]/page
 */

"use client"

import { useState, useCallback, useEffect, useRef, useMemo } from "react"
import { useParams, useRouter } from "next/navigation"
import {
  ArrowLeft,
  Clock,
  User,
  UserCircle,
  FileText,
  MessageSquare,
  CheckCircle2,
  XCircle,
  Download,
  ExternalLink,
  Calendar,
  DollarSign,
  TrendingUp,
  AlertCircle,
  Send,
  Paperclip,
  Loader2,
} from "lucide-react"
import Link from "next/link"
import { createClient, getAuthUser } from "@/lib/supabase/client"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { QCReviewModal } from "@/components/projects"
import { AnalyzeQuoteModal } from "@/components/dashboard/analyze-quote-modal"
import { AssignDoerModal } from "@/components/dashboard/assign-doer-modal"
import type { ProjectRequest } from "@/components/dashboard/request-card"

// Import the useProject hook
import { useProject } from "@/hooks/use-projects"
import { useChatRooms, useChatMessages } from "@/hooks/use-chat"
import type { ProjectWithRelations } from "@/types/database"

export default function ProjectDetailPage() {
  const params = useParams()
  const router = useRouter()
  const projectId = params.projectId as string

  const { project, isLoading, error, refetch } = useProject(projectId)

  const [qcModalState, setQcModalState] = useState<{
    open: boolean
    mode: "approve" | "reject" | null
  }>({ open: false, mode: null })

  const [quoteModalOpen, setQuoteModalOpen] = useState(false)
  const [assignModalOpen, setAssignModalOpen] = useState(false)

  const handleApprove = useCallback(async (projectId: string, message?: string) => {
    const supabase = createClient()

    try {
      const { error: updateError } = await supabase
        .from("projects")
        .update({
          status: "delivered",
          delivered_at: new Date().toISOString(),
          status_updated_at: new Date().toISOString(),
          completion_notes: message || null,
        })
        .eq("id", projectId)

      if (updateError) throw updateError

      toast.success("Project delivered to client successfully")
      setQcModalState({ open: false, mode: null })
      await refetch()
    } catch (err) {
      console.error("Failed to deliver project:", err)
      toast.error("Failed to deliver project. Please try again.")
    }
  }, [refetch])

  const handleReject = useCallback(async (
    projectId: string,
    feedback: string,
    severity: "minor" | "major" | "critical"
  ) => {
    const supabase = createClient()

    try {
      // Get current revision count
      const { count: revisionCount, error: countError } = await supabase
        .from("project_revisions")
        .select("*", { count: "exact", head: true })
        .eq("project_id", projectId)

      if (countError) throw countError

      const newRevisionNumber = (revisionCount || 0) + 1

      // Create revision request
      const { error: revisionError } = await supabase
        .from("project_revisions")
        .insert({
          project_id: projectId,
          revision_number: newRevisionNumber,
          requested_by: project?.supervisor_id || "",
          requested_by_type: "supervisor",
          feedback,
          status: "pending",
          severity,
        })

      if (revisionError) throw revisionError

      // Update project status
      const { error: projectError } = await supabase
        .from("projects")
        .update({
          status: "qc_rejected",
          status_updated_at: new Date().toISOString(),
          revision_count: newRevisionNumber,
        })
        .eq("id", projectId)

      if (projectError) throw projectError

      toast.success("Revision requested successfully")
      setQcModalState({ open: false, mode: null })
      await refetch()
    } catch (err) {
      console.error("Failed to reject project:", err)
      toast.error("Failed to request revision. Please try again.")
    }
  }, [project, refetch])

  const formatDate = (dateString: string | null | undefined) => {
    if (!dateString) return "N/A"
    return new Date(dateString).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const getStatusColor = (status: string) => {
    const statusColors: Record<string, string> = {
      submitted: "bg-blue-100 text-blue-700",
      analyzing: "bg-purple-100 text-purple-700",
      quoted: "bg-indigo-100 text-indigo-700",
      paid: "bg-green-100 text-green-700",
      assigned: "bg-cyan-100 text-cyan-700",
      in_progress: "bg-yellow-100 text-yellow-700",
      submitted_for_qc: "bg-orange-100 text-orange-700",
      qc_approved: "bg-emerald-100 text-emerald-700",
      qc_rejected: "bg-red-100 text-red-700",
      completed: "bg-green-100 text-green-700",
    }
    return statusColors[status] || "bg-gray-100 text-gray-700"
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-64" />
        <div className="grid gap-6 md:grid-cols-2">
          <Skeleton className="h-48" />
          <Skeleton className="h-48" />
        </div>
        <Skeleton className="h-96" />
      </div>
    )
  }

  if (error || !project) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <AlertCircle className="h-12 w-12 text-destructive mb-4" />
        <h3 className="text-lg font-semibold">Project Not Found</h3>
        <p className="text-sm text-muted-foreground mt-2">
          {error?.message || "The project you're looking for doesn't exist or you don't have access to it."}
        </p>
        <Button onClick={() => router.push("/projects")} className="mt-4">
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to Projects
        </Button>
      </div>
    )
  }

  const showQCActions = project.status === "submitted_for_qc" || project.status === "qc_in_progress"
  const showDeliverAction = project.status === "qc_approved"

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="relative">
        {/* Background Gradients */}
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-24 right-0 h-64 w-64 rounded-full bg-orange-100/60 blur-3xl" />
          <div className="absolute top-40 left-10 h-56 w-56 rounded-full bg-amber-100/50 blur-3xl" />
        </div>

        <div className="relative max-w-[1400px] mx-auto p-6 lg:p-10 space-y-8">
          {/* Header with Back Button */}
          <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
            <div className="flex items-start gap-4">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => router.push("/projects")}
                className="rounded-full hover:bg-orange-50"
              >
                <ArrowLeft className="h-4 w-4 mr-2" />
                Back
              </Button>
              <div className="flex-1 min-w-0">
                <div className="flex items-start gap-3 flex-wrap">
                  <h2 className="text-3xl font-bold tracking-tight text-[#1C1C1C]">{project.title}</h2>
                  <Badge className={`${getStatusColor(project.status)} text-xs font-medium px-3 py-1`}>
                    {project.status.replace(/_/g, " ")}
                  </Badge>
                </div>
                <p className="text-sm text-gray-500 mt-2 font-mono">
                  Project #{project.project_number}
                </p>
              </div>
              {project.status === "paid" && !project.doer_id && (
                <div className="flex gap-2 flex-shrink-0">
                  <Button
                    onClick={() => setAssignModalOpen(true)}
                    className="rounded-full bg-[#F97316] hover:bg-[#EA580C] text-white"
                  >
                    <UserCircle className="h-4 w-4 mr-2" />
                    Assign Expert
                  </Button>
                </div>
              )}
              {showQCActions && (
                <div className="flex gap-2 flex-shrink-0">
                  <Button
                    variant="outline"
                    onClick={() => setQcModalState({ open: true, mode: "reject" })}
                    className="rounded-full border-red-200 text-red-600 hover:bg-red-50"
                  >
                    <XCircle className="h-4 w-4 mr-2" />
                    Request Revision
                  </Button>
                  <Button
                    onClick={() => setQcModalState({ open: true, mode: "approve" })}
                    className="rounded-full bg-[#F97316] hover:bg-[#EA580C] text-white"
                  >
                    <CheckCircle2 className="h-4 w-4 mr-2" />
                    Approve Project
                  </Button>
                </div>
              )}
              {showDeliverAction && (
                <div className="flex gap-2 flex-shrink-0">
                  <Button
                    onClick={() => setQcModalState({ open: true, mode: "approve" })}
                    className="rounded-full bg-green-600 hover:bg-green-700 text-white"
                  >
                    <Send className="h-4 w-4 mr-2" />
                    Deliver to Client
                  </Button>
                </div>
              )}
            </div>
          </div>

          {/* Key Information Cards */}
          <div className="grid gap-6 md:grid-cols-3">
            {/* Client Card */}
            <div className="bg-white rounded-2xl border border-gray-200 p-6 hover:border-orange-200 hover:shadow-md transition-all">
              <div className="flex items-center gap-3 mb-4">
                <div className="h-10 w-10 rounded-xl bg-blue-100 flex items-center justify-center">
                  <User className="h-5 w-5 text-blue-600" />
                </div>
                <h3 className="text-sm font-semibold text-[#1C1C1C]">Client</h3>
              </div>
              <Link
                href={`/users/${project.user_id}`}
                className="flex items-center gap-3 group"
              >
                <Avatar className="h-12 w-12 ring-2 ring-white shadow-sm">
                  <AvatarImage src={project.profiles?.avatar_url || undefined} />
                  <AvatarFallback className="bg-gradient-to-br from-blue-400 to-blue-600 text-white font-semibold">
                    {project.profiles?.full_name?.charAt(0) || "U"}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-[#1C1C1C] group-hover:text-[#F97316] transition-colors truncate">
                    {project.profiles?.full_name || "Unknown User"}
                  </p>
                  <p className="text-xs text-gray-500 truncate">
                    {project.profiles?.email || "No email"}
                  </p>
                </div>
              </Link>
            </div>

            {/* Expert Card */}
            <div className="bg-white rounded-2xl border border-gray-200 p-6 hover:border-orange-200 hover:shadow-md transition-all">
              <div className="flex items-center gap-3 mb-4">
                <div className="h-10 w-10 rounded-xl bg-purple-100 flex items-center justify-center">
                  <UserCircle className="h-5 w-5 text-purple-600" />
                </div>
                <h3 className="text-sm font-semibold text-[#1C1C1C]">Expert</h3>
              </div>
              {project.doer_id && project.doers ? (
                <Link
                  href={`/doers/${project.doer_id}`}
                  className="flex items-center gap-3 group"
                >
                  <Avatar className="h-12 w-12 ring-2 ring-white shadow-sm">
                    <AvatarImage src={project.doers.profiles?.avatar_url || undefined} />
                    <AvatarFallback className="bg-gradient-to-br from-purple-400 to-purple-600 text-white font-semibold">
                      {project.doers.profiles?.full_name?.charAt(0) || "D"}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-[#1C1C1C] group-hover:text-[#F97316] transition-colors truncate">
                      {project.doers.profiles?.full_name || "Unknown Doer"}
                    </p>
                    <p className="text-xs text-gray-500">
                      Rating: {project.doers.average_rating?.toFixed(1) || "N/A"} ⭐
                    </p>
                  </div>
                </Link>
              ) : (
                <div className="space-y-3">
                  <p className="text-sm text-gray-500">Not assigned yet</p>
                  {project.status === "paid" && (
                    <Button
                      size="sm"
                      className="w-full rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white shadow-lg"
                      onClick={() => setAssignModalOpen(true)}
                    >
                      <UserCircle className="h-4 w-4 mr-2" />
                      Assign Expert
                    </Button>
                  )}
                </div>
              )}
            </div>

            {/* Financials Card */}
            <div className="bg-gradient-to-br from-orange-50 to-amber-50 rounded-2xl border border-orange-200 p-6 shadow-sm">
              <div className="flex items-center gap-3 mb-4">
                <div className="h-10 w-10 rounded-xl bg-orange-100 flex items-center justify-center">
                  <DollarSign className="h-5 w-5 text-[#F97316]" />
                </div>
                <h3 className="text-sm font-semibold text-[#1C1C1C]">Financials</h3>
              </div>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Quote:</span>
                  <span className="text-lg font-bold text-[#1C1C1C]">₹{project.user_quote || 0}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Your Commission:</span>
                  <span className="text-lg font-bold text-green-600">₹{project.supervisor_commission || 0}</span>
                </div>
                {project.status === "analyzing" && (
                  <Button
                    size="sm"
                    className="w-full mt-3 bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl shadow-lg"
                    onClick={() => setQuoteModalOpen(true)}
                  >
                    <DollarSign className="h-4 w-4 mr-2" />
                    Set Quote
                  </Button>
                )}
              </div>
            </div>
          </div>

          {/* Main Content Tabs */}
          <Tabs defaultValue="details" className="space-y-6">
            <TabsList className="bg-white border border-gray-200 p-1 rounded-xl shadow-sm">
              <TabsTrigger
                value="details"
                className="data-[state=active]:bg-[#F97316] data-[state=active]:text-white rounded-lg"
              >
                <FileText className="h-4 w-4 mr-2" />
                Details
              </TabsTrigger>
              <TabsTrigger
                value="timeline"
                className="data-[state=active]:bg-[#F97316] data-[state=active]:text-white rounded-lg"
              >
                <Clock className="h-4 w-4 mr-2" />
                Timeline
              </TabsTrigger>
              <TabsTrigger
                value="communication"
                className="data-[state=active]:bg-[#F97316] data-[state=active]:text-white rounded-lg"
              >
                <MessageSquare className="h-4 w-4 mr-2" />
                Communication
              </TabsTrigger>
            </TabsList>

            <TabsContent value="details" className="space-y-6">
              <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-[#1C1C1C] mb-6">Project Details</h3>
                <div className="grid gap-6 md:grid-cols-2">
                  <div className="space-y-2">
                    <p className="text-xs uppercase tracking-wide text-gray-400 font-medium">Subject</p>
                    <p className="text-base font-semibold text-[#1C1C1C]">{project.subjects?.name || "General"}</p>
                  </div>
                  <div className="space-y-2">
                    <p className="text-xs uppercase tracking-wide text-gray-400 font-medium">Service Type</p>
                    <p className="text-base font-semibold text-[#1C1C1C]">{project.service_type?.replace(/_/g, " ")}</p>
                  </div>
                  <div className="space-y-2">
                    <p className="text-xs uppercase tracking-wide text-gray-400 font-medium">Word Count</p>
                    <p className="text-base font-semibold text-[#1C1C1C]">{project.word_count || "N/A"}</p>
                  </div>
                  <div className="space-y-2">
                    <p className="text-xs uppercase tracking-wide text-gray-400 font-medium">Page Count</p>
                    <p className="text-base font-semibold text-[#1C1C1C]">{project.page_count || "N/A"}</p>
                  </div>
                  <div className="space-y-2">
                    <p className="text-xs uppercase tracking-wide text-gray-400 font-medium">Deadline</p>
                    <p className="text-base font-semibold text-[#1C1C1C]">{formatDate(project.deadline)}</p>
                  </div>
                  <div className="space-y-2">
                    <p className="text-xs uppercase tracking-wide text-gray-400 font-medium">Created</p>
                    <p className="text-base font-semibold text-[#1C1C1C]">{formatDate(project.created_at)}</p>
                  </div>
                </div>

                {project.description && (
                  <>
                    <div className="my-6 border-t border-gray-200" />
                    <div>
                      <p className="text-xs uppercase tracking-wide text-gray-400 font-medium mb-3">Description</p>
                      <p className="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed">{project.description}</p>
                    </div>
                  </>
                )}

                {project.specific_instructions && (
                  <>
                    <div className="my-6 border-t border-gray-200" />
                    <div>
                      <p className="text-xs uppercase tracking-wide text-gray-400 font-medium mb-3">Special Instructions</p>
                      <p className="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed">{project.specific_instructions}</p>
                    </div>
                  </>
                )}
              </div>
            </TabsContent>

            <TabsContent value="timeline" className="space-y-6">
              <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-[#1C1C1C] mb-2">Project Timeline</h3>
                <p className="text-sm text-gray-500 mb-6">Track the progress of this project</p>
                <div className="space-y-4">
                  <TimelineItem
                    icon={<Calendar className="h-4 w-4" />}
                    title="Project Created"
                    timestamp={formatDate(project.created_at)}
                    status="completed"
                  />
                  {project.doer_assigned_at && (
                    <TimelineItem
                      icon={<UserCircle className="h-4 w-4" />}
                      title="Expert Assigned"
                      timestamp={formatDate(project.doer_assigned_at)}
                      status="completed"
                    />
                  )}
                  {project.status_updated_at && (
                    <TimelineItem
                      icon={<TrendingUp className="h-4 w-4" />}
                      title={`Status: ${project.status.replace(/_/g, " ")}`}
                      timestamp={formatDate(project.status_updated_at)}
                      status="current"
                    />
                  )}
                  {project.deadline && (
                    <TimelineItem
                      icon={<Clock className="h-4 w-4" />}
                      title="Deadline"
                      timestamp={formatDate(project.deadline)}
                      status={new Date(project.deadline) < new Date() ? "overdue" : "upcoming"}
                    />
                  )}
                </div>
              </div>
            </TabsContent>

            <TabsContent value="communication" className="space-y-6">
              <ProjectChatPanel projectId={projectId} />
            </TabsContent>
          </Tabs>
        </div>
      </div>

      {/* QC Review Modal */}
      <QCReviewModal
        project={project ? {
          id: project.id,
          project_number: project.project_number,
          title: project.title,
          subject: project.subjects?.name || "General",
          service_type: project.service_type,
          status: project.status,
          user_name: project.profiles?.full_name || "Unknown User",
          user_id: project.user_id,
          doer_name: project.doers?.profiles?.full_name || "Unassigned",
          doer_id: project.doer_id || "",
          deadline: project.deadline || new Date(Date.now() + 72 * 60 * 60 * 1000).toISOString(),
          word_count: project.word_count ?? undefined,
          page_count: project.page_count ?? undefined,
          quoted_amount: project.user_quote || 0,
          doer_payout: project.doer_payout || 0,
          supervisor_commission: project.supervisor_commission || 0,
          assigned_at: project.doer_assigned_at ?? undefined,
          submitted_for_qc_at: project.status_updated_at ?? undefined,
          delivered_at: project.delivered_at ?? undefined,
          completed_at: project.completed_at ?? undefined,
          created_at: project.created_at || new Date().toISOString(),
          revision_count: 0,
          has_unread_messages: false,
        } : null}
        mode={qcModalState.mode}
        open={qcModalState.open}
        onOpenChange={(open) =>
          setQcModalState({ ...qcModalState, open, mode: open ? qcModalState.mode : null })
        }
        onApprove={handleApprove}
        onReject={handleReject}
      />

      {/* Quote Modal */}
      <AnalyzeQuoteModal
        request={project ? {
          id: project.id,
          project_number: project.project_number,
          title: project.title,
          subject: project.subjects?.name || "General",
          service_type: project.service_type,
          user_name: project.profiles?.full_name || "Unknown User",
          deadline: project.deadline || new Date(Date.now() + 72 * 60 * 60 * 1000).toISOString(),
          word_count: project.word_count ?? undefined,
          page_count: project.page_count ?? undefined,
          created_at: project.created_at || new Date().toISOString(),
        } : null}
        isOpen={quoteModalOpen}
        onClose={() => setQuoteModalOpen(false)}
        onQuoteSubmit={async () => {
          setQuoteModalOpen(false)
          await refetch()
        }}
      />

      {/* Assign Expert Modal */}
      <AssignDoerModal
        project={project ? {
          id: project.id,
          project_number: project.project_number,
          title: project.title,
          subject: project.subjects?.name || "General",
          service_type: project.service_type,
          user_name: project.profiles?.full_name || "Unknown User",
          deadline: project.deadline || new Date(Date.now() + 72 * 60 * 60 * 1000).toISOString(),
          word_count: project.word_count ?? undefined,
          page_count: project.page_count ?? undefined,
          quoted_amount: project.user_quote || 0,
          doer_payout: project.doer_payout || 0,
          paid_at: project.status_updated_at || new Date().toISOString(),
          created_at: project.created_at || new Date().toISOString(),
        } : null}
        isOpen={assignModalOpen}
        onClose={() => setAssignModalOpen(false)}
        onAssign={async () => {
          setAssignModalOpen(false)
          await refetch()
        }}
      />
    </div>
  )
}

/**
 * Inline chat panel for the Communication tab.
 * Uses useChatRooms to find the project's chat room and useChatMessages for real-time messaging.
 */
function ProjectChatPanel({ projectId }: { projectId: string }) {
  const { rooms, isLoading: roomsLoading, error: roomsError } = useChatRooms({ projectId })
  const activeRoomId = rooms.length > 0 ? rooms[0].id : ""
  const {
    messages,
    isLoading: messagesLoading,
    error: messagesError,
    sendMessage,
    sendFile,
    hasMore,
    loadMore,
  } = useChatMessages(activeRoomId)

  const [currentUserId, setCurrentUserId] = useState<string | null>(null)
  const [messageText, setMessageText] = useState("")
  const [isSending, setIsSending] = useState(false)
  const scrollRef = useRef<HTMLDivElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    getAuthUser().then((user) => {
      if (user) setCurrentUserId(user.id)
    })
  }, [])

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [messages])

  const handleSend = async () => {
    if (!messageText.trim() || isSending || !activeRoomId) return
    setIsSending(true)
    try {
      await sendMessage(messageText.trim())
      setMessageText("")
      textareaRef.current?.focus()
    } catch (err) {
      console.error("Failed to send message:", err)
      toast.error("Failed to send message. Please try again.")
    } finally {
      setIsSending(false)
    }
  }

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file || !activeRoomId) return
    setIsSending(true)
    try {
      await sendFile(file)
    } catch (err) {
      console.error("Failed to send file:", err)
      toast.error(err instanceof Error ? err.message : "Failed to send file.")
    } finally {
      setIsSending(false)
      if (fileInputRef.current) fileInputRef.current.value = ""
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  const formatMessageTime = (dateString: string | null) => {
    if (!dateString) return ""
    return new Date(dateString).toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    })
  }

  const formatMessageDate = (dateString: string | null) => {
    if (!dateString) return ""
    const date = new Date(dateString)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)

    if (date.toDateString() === today.toDateString()) return "Today"
    if (date.toDateString() === yesterday.toDateString()) return "Yesterday"
    return date.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
  }

  // Group messages by date
  const groupedMessages = useMemo(() => {
    const groups: { date: string; label: string; messages: typeof messages }[] = []
    let currentDateStr = ""

    for (const msg of messages) {
      const dateStr = msg.created_at ? new Date(msg.created_at).toDateString() : ""
      if (dateStr !== currentDateStr) {
        currentDateStr = dateStr
        groups.push({
          date: dateStr,
          label: formatMessageDate(msg.created_at),
          messages: [msg],
        })
      } else {
        groups[groups.length - 1].messages.push(msg)
      }
    }
    return groups
  }, [messages])

  // Loading state
  if (roomsLoading) {
    return (
      <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
        <h3 className="text-lg font-semibold text-[#1C1C1C] mb-2">Communication</h3>
        <p className="text-sm text-gray-500 mb-6">Messages and updates for this project</p>
        <div className="flex flex-col items-center justify-center py-12">
          <Loader2 className="h-8 w-8 text-[#F97316] animate-spin mb-4" />
          <p className="text-sm text-gray-500">Loading chat...</p>
        </div>
      </div>
    )
  }

  // Error state
  if (roomsError) {
    return (
      <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
        <h3 className="text-lg font-semibold text-[#1C1C1C] mb-2">Communication</h3>
        <p className="text-sm text-gray-500 mb-6">Messages and updates for this project</p>
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <div className="h-16 w-16 rounded-2xl bg-red-50 flex items-center justify-center mb-4">
            <AlertCircle className="h-8 w-8 text-red-500" />
          </div>
          <p className="text-sm text-gray-600 font-medium">Failed to load chat</p>
          <p className="text-xs text-gray-400 mt-1">{roomsError.message}</p>
        </div>
      </div>
    )
  }

  // No chat room exists yet
  if (rooms.length === 0) {
    return (
      <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
        <h3 className="text-lg font-semibold text-[#1C1C1C] mb-2">Communication</h3>
        <p className="text-sm text-gray-500 mb-6">Messages and updates for this project</p>
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <div className="h-16 w-16 rounded-2xl bg-orange-50 flex items-center justify-center mb-4">
            <MessageSquare className="h-8 w-8 text-[#F97316]" />
          </div>
          <p className="text-sm text-gray-600 font-medium">No conversations yet</p>
          <p className="text-xs text-gray-400 mt-1">
            A chat room will be created when communication begins for this project
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden flex flex-col" style={{ height: "600px" }}>
      {/* Chat Header */}
      <div className="px-6 py-4 border-b border-gray-200 bg-gradient-to-r from-orange-50/50 to-white flex-shrink-0">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-orange-100 flex items-center justify-center">
            <MessageSquare className="h-5 w-5 text-[#F97316]" />
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="text-lg font-semibold text-[#1C1C1C]">Project Chat</h3>
            <p className="text-xs text-gray-500">
              {rooms[0]?.chat_participants?.length || 0} participants
              {rooms[0]?.room_type && (
                <span className="ml-2 text-gray-400">
                  {rooms[0].room_type === "project_user_supervisor" && "Client Chat"}
                  {rooms[0].room_type === "project_supervisor_doer" && "Expert Chat"}
                  {rooms[0].room_type === "project_all" && "Group Chat"}
                </span>
              )}
            </p>
          </div>
        </div>
      </div>

      {/* Messages Area */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto px-6 py-4 space-y-4 bg-gray-50/50">
        {/* Load More Button */}
        {hasMore && !messagesLoading && (
          <div className="flex justify-center">
            <Button
              variant="ghost"
              size="sm"
              onClick={loadMore}
              className="text-xs text-gray-500 hover:text-[#F97316]"
            >
              Load earlier messages
            </Button>
          </div>
        )}

        {messagesLoading && messages.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full">
            <Loader2 className="h-6 w-6 text-[#F97316] animate-spin mb-3" />
            <p className="text-sm text-gray-400">Loading messages...</p>
          </div>
        ) : messages.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <MessageSquare className="h-10 w-10 text-gray-300 mb-3" />
            <p className="text-sm text-gray-500">No messages yet</p>
            <p className="text-xs text-gray-400 mt-1">Start the conversation!</p>
          </div>
        ) : (
          groupedMessages.map((group) => (
            <div key={group.date} className="space-y-3">
              {/* Date separator */}
              <div className="flex items-center gap-3 my-2">
                <div className="flex-1 h-px bg-gray-200" />
                <span className="text-xs text-gray-400 font-medium">{group.label}</span>
                <div className="flex-1 h-px bg-gray-200" />
              </div>

              {/* Messages in this group */}
              {group.messages.map((msg, idx) => {
                const isOwn = msg.sender_id === currentUserId
                const senderProfile = msg.profiles
                const senderName = senderProfile?.full_name || "Unknown"
                const senderInitial = senderName.charAt(0).toUpperCase()
                const prevMsg = group.messages[idx - 1]
                const showSender = !prevMsg || prevMsg.sender_id !== msg.sender_id

                // System messages
                if (msg.message_type === "system") {
                  return (
                    <div key={msg.id} className="flex justify-center my-2">
                      <span className="text-xs text-gray-400 bg-gray-100 px-3 py-1 rounded-full">
                        {msg.content}
                      </span>
                    </div>
                  )
                }

                return (
                  <div
                    key={msg.id}
                    className={`flex gap-2.5 max-w-[80%] ${isOwn ? "ml-auto flex-row-reverse" : ""}`}
                  >
                    {/* Avatar */}
                    <div className={`shrink-0 ${!showSender ? "invisible" : ""}`}>
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={senderProfile?.avatar_url || undefined} />
                        <AvatarFallback className={`text-xs font-semibold ${isOwn ? "bg-[#F97316] text-white" : "bg-blue-100 text-blue-700"}`}>
                          {senderInitial}
                        </AvatarFallback>
                      </Avatar>
                    </div>

                    <div className={`space-y-1 ${isOwn ? "items-end" : "items-start"}`}>
                      {/* Sender name */}
                      {showSender && (
                        <p className={`text-xs font-medium text-gray-500 ${isOwn ? "text-right" : ""}`}>
                          {isOwn ? "You" : senderName}
                        </p>
                      )}

                      {/* Message bubble */}
                      <div
                        className={`rounded-2xl px-4 py-2.5 text-sm leading-relaxed whitespace-pre-wrap break-words ${
                          isOwn
                            ? "bg-[#F97316] text-white rounded-tr-md"
                            : "bg-white border border-gray-200 text-gray-800 rounded-tl-md shadow-sm"
                        }`}
                      >
                        {/* File attachment */}
                        {(msg.message_type === "file" || msg.message_type === "image") && msg.file_url && (
                          <div className="mb-1">
                            {msg.message_type === "image" ? (
                              <img
                                src={msg.file_url}
                                alt={msg.file_name || "Image"}
                                className="max-w-[250px] rounded-lg mb-1"
                              />
                            ) : (
                              <div className={`flex items-center gap-2 p-2 rounded-lg mb-1 ${isOwn ? "bg-white/10" : "bg-gray-50"}`}>
                                <FileText className="h-4 w-4 shrink-0" />
                                <span className="text-xs truncate">{msg.file_name || "File"}</span>
                                <a
                                  href={msg.file_url}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  className={`ml-auto ${isOwn ? "text-white/80 hover:text-white" : "text-[#F97316] hover:text-[#EA580C]"}`}
                                >
                                  <Download className="h-3.5 w-3.5" />
                                </a>
                              </div>
                            )}
                          </div>
                        )}

                        {/* Text content */}
                        {msg.content && (msg.message_type === "text" || msg.message_type === "action" || !msg.message_type) && (
                          <span>{msg.content}</span>
                        )}
                        {msg.content && (msg.message_type === "file" || msg.message_type === "image") && (
                          <span className="text-xs opacity-80">{msg.file_name !== msg.content ? msg.content : ""}</span>
                        )}
                      </div>

                      {/* Timestamp */}
                      <p className={`text-[10px] text-gray-400 ${isOwn ? "text-right" : ""}`}>
                        {formatMessageTime(msg.created_at)}
                      </p>
                    </div>
                  </div>
                )
              })}
            </div>
          ))
        )}
      </div>

      {/* Message Input Area */}
      <div className="border-t border-gray-200 px-4 py-3 bg-white flex-shrink-0">
        <div className="flex items-end gap-2">
          {/* File upload */}
          <input
            ref={fileInputRef}
            type="file"
            className="hidden"
            accept="image/*,application/pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar"
            onChange={handleFileSelect}
          />
          <Button
            variant="ghost"
            size="icon"
            className="shrink-0 rounded-full hover:bg-orange-50 hover:text-[#F97316]"
            onClick={() => fileInputRef.current?.click()}
            disabled={isSending || !activeRoomId}
          >
            <Paperclip className="h-5 w-5" />
          </Button>

          {/* Text input */}
          <textarea
            ref={textareaRef}
            value={messageText}
            onChange={(e) => setMessageText(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type a message..."
            disabled={isSending || !activeRoomId}
            className="flex-1 resize-none rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-[#F97316]/30 focus:border-[#F97316] disabled:opacity-50 min-h-[44px] max-h-[120px]"
            rows={1}
          />

          {/* Send button */}
          <Button
            size="icon"
            className="shrink-0 rounded-full bg-[#F97316] hover:bg-[#EA580C] text-white shadow-md disabled:opacity-50"
            onClick={handleSend}
            disabled={!messageText.trim() || isSending || !activeRoomId}
          >
            {isSending ? (
              <Loader2 className="h-5 w-5 animate-spin" />
            ) : (
              <Send className="h-5 w-5" />
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}

interface TimelineItemProps {
  icon: React.ReactNode
  title: string
  timestamp: string
  status: "completed" | "current" | "upcoming" | "overdue"
}

function TimelineItem({ icon, title, timestamp, status }: TimelineItemProps) {
  const statusColors = {
    completed: "border-green-500 bg-green-50 text-green-600",
    current: "border-orange-500 bg-orange-50 text-[#F97316]",
    upcoming: "border-gray-300 bg-gray-50 text-gray-600",
    overdue: "border-red-500 bg-red-50 text-red-600",
  }

  return (
    <div className="flex gap-4 items-start">
      <div className={`flex h-10 w-10 items-center justify-center rounded-xl border-2 ${statusColors[status]} flex-shrink-0`}>
        {icon}
      </div>
      <div className="flex-1 min-w-0 pt-1">
        <p className="font-semibold text-sm text-[#1C1C1C]">{title}</p>
        <p className="text-xs text-gray-500 mt-1">{timestamp}</p>
      </div>
    </div>
  )
}
