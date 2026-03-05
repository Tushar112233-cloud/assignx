'use client'

import { useState, useEffect, useCallback } from 'react'
import { useParams, useRouter } from 'next/navigation'
import dynamic from 'next/dynamic'
import { ArrowLeft, Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'

/** Lazy load heavy WorkspaceView component */
const WorkspaceView = dynamic(
  () => import('@/components/projects').then(mod => ({ default: mod.WorkspaceView })),
  {
    loading: () => <Skeleton className="h-96 w-full" />,
    ssr: false
  }
)
import { ROUTES } from '@/lib/constants'
import { useAuth } from '@/hooks/useAuth'
import {
  getProjectById,
  getProjectFiles,
  getProjectDeliverables,
  getProjectRevisions,
  uploadDeliverable,
  updateProjectStatus,
  startProject,
  submitProject,
} from '@/services/project.service'
import { apiClient, getAccessToken } from '@/lib/api/client'
import {
  getOrCreateProjectChatRoom,
  getChatMessages,
  sendMessage,
  sendFileMessage,
  subscribeToMessages,
  unsubscribeFromMessages,
  joinChatRoom,
  markMessagesAsRead,
} from '@/services/chat.service'
import { AuthenticationError } from '@/lib/auth-helpers'
import { toast } from 'sonner'
import type {
  Project,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
  ChatMessage,
} from '@/types/database'
/** Subscription handle returned by subscribeToMessages */
type ChatSubscription = { unsubscribe: () => void }

/**
 * Project workspace page
 * Shows project details, chat, and file upload
 */
export default function ProjectWorkspacePage() {
  const params = useParams()
  const router = useRouter()
  const { user, doer, isLoading: authLoading } = useAuth()
  const projectId = params.id as string

  const [isLoading, setIsLoading] = useState(true)
  const [project, setProject] = useState<Project | null>(null)
  const [files, setFiles] = useState<ProjectFile[]>([])
  const [deliverables, setDeliverables] = useState<ProjectDeliverable[]>([])
  const [revisions, setRevisions] = useState<ProjectRevision[]>([])
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [chatRoomId, setChatRoomId] = useState<string | null>(null)
  const [isChatLoading, setIsChatLoading] = useState(false)
  const [isChatSending, setIsChatSending] = useState(false)
  const [channel, setChannel] = useState<ChatSubscription | null>(null)

  /**
   * Load project data from the API.
   * Gated on auth readiness to avoid AuthenticationError when session
   * hasn't been initialized yet.
   */
  const loadProject = useCallback(async () => {
    if (!projectId || !doer?.id) return

    setIsLoading(true)
    try {
      // Fetch project and related data in parallel
      const [projectData, filesData, deliverablesData, revisionsData] = await Promise.all([
        getProjectById(projectId),
        getProjectFiles(projectId),
        getProjectDeliverables(projectId),
        getProjectRevisions(projectId),
      ])

      if (!projectData) {
        setProject(null)
        return
      }

      setProject(projectData)
      setFiles(filesData)
      setDeliverables(deliverablesData)
      setRevisions(revisionsData)

      // Load chat room and messages
      try {
        setIsChatLoading(true)
        const room = await getOrCreateProjectChatRoom(projectId)
        setChatRoomId(room.id)

        // Join chat room if user is available
        if (user?.id) {
          await joinChatRoom(room.id, user.id, 'doer')
        }

        const chatMessages = await getChatMessages(room.id)
        setMessages(chatMessages)

        // Mark messages as read (uses authenticated user)
        await markMessagesAsRead(room.id)
      } catch (chatError) {
        console.error('Error loading chat:', chatError)
      } finally {
        setIsChatLoading(false)
      }
    } catch (error) {
      // Handle expired/missing session by redirecting to login
      if (error instanceof AuthenticationError) {
        console.warn('[ProjectWorkspace] Auth expired, redirecting to login')
        router.push(ROUTES.login)
        return
      }
      console.error('Error loading project:', error)
      toast.error('Failed to load project')
    } finally {
      setIsLoading(false)
    }
  }, [projectId, doer?.id, user?.id, router])

  /** Load project when auth is ready */
  useEffect(() => {
    if (doer?.id) {
      loadProject()
    } else if (!authLoading) {
      // Auth finished loading but no doer — stop the loading spinner
      setIsLoading(false)
    }
  }, [doer?.id, authLoading, loadProject])

  /** Subscribe to real-time messages */
  useEffect(() => {
    if (!chatRoomId) return

    const newChannel = subscribeToMessages(chatRoomId, (newMessage) => {
      setMessages((prev) => [...prev, newMessage])
      // Mark as read if not from current user
      if (newMessage.sender_id !== user?.id) {
        markMessagesAsRead(chatRoomId)
      }
    })

    setChannel(newChannel)

    return () => {
      if (newChannel) {
        newChannel.unsubscribe()
      }
    }
  }, [chatRoomId, doer?.id])

  /** Handle upload deliverable */
  const handleUploadDeliverable = useCallback(async (uploadedFiles: File[]) => {
    if (!doer?.id) {
      toast.error('Please log in to upload files')
      return
    }

    try {
      for (const file of uploadedFiles) {
        const newDeliverable = await uploadDeliverable(projectId, doer.id, file)
        setDeliverables((prev) => [newDeliverable, ...prev])
      }
      toast.success('File uploaded successfully')
    } catch (error) {
      console.error('Error uploading file:', error)
      toast.error('Failed to upload file')
    }
  }, [doer?.id, projectId])

  /** Handle submit project */
  const handleSubmitProject = useCallback(async () => {
    try {
      await submitProject(projectId)
      // Re-fetch to get fully normalized project data
      const fresh = await getProjectById(projectId)
      if (fresh) setProject(fresh)
      toast.success('Project submitted for review')
    } catch (error) {
      console.error('Error submitting project:', error)
      toast.error('Failed to submit project')
    }
  }, [projectId])

  /** Handle start project */
  const handleStartProject = useCallback(async () => {
    try {
      await startProject(projectId)
      // Re-fetch to get fully normalized project data
      const fresh = await getProjectById(projectId)
      if (fresh) setProject(fresh)
      toast.success('Project started')
    } catch (error) {
      console.error('Error starting project:', error)
      toast.error('Failed to start project')
    }
  }, [projectId])

  /** Handle send message */
  const handleSendMessage = useCallback(async (content: string) => {
    if (!chatRoomId) {
      toast.error('Unable to send message')
      return
    }

    setIsChatSending(true)
    try {
      // sendMessage uses authenticated user's ID internally and returns the message
      const sentMessage = await sendMessage(chatRoomId, content)
      // Add to local state immediately (real-time subscription may also fire)
      setMessages((prev) => {
        // Avoid duplicates if real-time subscription already added it
        if (prev.some((m) => m.id === sentMessage.id)) return prev
        return [...prev, sentMessage]
      })
    } catch (error) {
      console.error('Error sending message:', error)
      toast.error('Failed to send message')
    } finally {
      setIsChatSending(false)
    }
  }, [chatRoomId])

  /** Handle send file */
  const handleSendFile = useCallback(async (file: File) => {
    if (!chatRoomId) {
      toast.error('Unable to send file')
      return
    }

    setIsChatSending(true)
    try {
      // sendFileMessage uses authenticated user's ID internally and returns the message
      const sentMessage = await sendFileMessage(chatRoomId, file)
      setMessages((prev) => {
        if (prev.some((m) => m.id === sentMessage.id)) return prev
        return [...prev, sentMessage]
      })
    } catch (error) {
      console.error('Error sending file:', error)
      toast.error('Failed to send file')
    } finally {
      setIsChatSending(false)
    }
  }, [chatRoomId])

  /** Handle update live document URL */
  const handleUpdateLiveDocUrl = useCallback(async (url: string) => {
    try {
      await apiClient(`/api/projects/${projectId}`, {
        method: 'PUT',
        body: JSON.stringify({ live_document_url: url }),
      })

      setProject((prev) => (prev ? { ...prev, live_document_url: url } : null))
      toast.success(url ? 'Google Docs link saved' : 'Google Docs link removed')
    } catch (error) {
      console.error('Error updating live doc URL:', error)
      toast.error('Failed to save Google Docs link')
    }
  }, [projectId])

  /** Handle start revision */
  const handleStartRevision = useCallback(async (revisionId: string) => {
    try {
      await updateProjectStatus(projectId, 'in_revision')
      setProject((prev) => (prev ? { ...prev, status: 'in_revision' } : null))
      setRevisions((prev) =>
        prev.map((r) => (r.id === revisionId ? { ...r, status: 'in_progress' } : r))
      )
      toast.success('Revision started')
    } catch (error) {
      console.error('Error starting revision:', error)
      toast.error('Failed to start revision')
    }
  }, [projectId])

  // Show loading state
  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-10" />
          <Skeleton className="h-8 w-64" />
        </div>
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    )
  }

  if (!project) {
    return (
      <div className="flex flex-col items-center justify-center py-16">
        <h2 className="text-xl font-semibold">Project not found</h2>
        <p className="text-muted-foreground mt-2">
          The project you are looking for does not exist.
        </p>
        <Button
          variant="outline"
          className="mt-4"
          onClick={() => router.push(ROUTES.projects)}
        >
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to Projects
        </Button>
      </div>
    )
  }

  return (
    <div className="relative min-h-screen">
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%),radial-gradient(circle_at_80%_20%,rgba(67,209,197,0.16),transparent_50%)]" />
      <div className="space-y-6">
        {/* Header - Doer dashboard style */}
        <div className="rounded-[24px] bg-white/85 p-5 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
          <div className="flex items-center gap-4">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => router.push(ROUTES.projects)}
              className="h-10 w-10 rounded-xl hover:bg-[#EEF2FF] hover:text-[#5B7CFF] transition-all duration-200"
            >
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div className="flex-1 min-w-0">
              <h1 className="text-2xl font-semibold text-slate-900 line-clamp-1">{project.title}</h1>
              <p className="text-sm text-slate-500 mt-0.5">Project Workspace</p>
            </div>
          </div>
        </div>

        {/* Workspace */}
        <WorkspaceView
        project={project}
        files={files}
        deliverables={deliverables}
        revisions={revisions}
        messages={messages}
        chatRoomId={chatRoomId || ''}
        currentUserId={user?.id || ''}
        currentUserName={user?.email || 'You'}
        isLoading={isLoading}
        isChatLoading={isChatLoading}
        isChatSending={isChatSending}
        onUploadDeliverable={handleUploadDeliverable}
        onSubmitProject={handleSubmitProject}
        onStartProject={handleStartProject}
        onSendMessage={handleSendMessage}
        onSendFile={handleSendFile}
        onStartRevision={handleStartRevision}
        onUpdateLiveDocUrl={handleUpdateLiveDocUrl}
      />
    </div>
    </div>
  )
}
