'use client'

/**
 * Workspace View component - Modern minimal design
 * Full project workspace with details, chat, and file upload
 * Charcoal + Orange accent palette matching dashboard aesthetic
 * @module components/projects/WorkspaceView
 */

import { useState } from 'react'
import { motion } from 'framer-motion'
import {
  Clock,
  FileText,
  Upload,
  MessageSquare,
  Flame,
  IndianRupee,
  Send,
  File,
  Download,
  AlertCircle,
  CheckCircle2,
  Link2,
  ExternalLink,
  Loader2,
} from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion'
import { Separator } from '@/components/ui/separator'
import { cn } from '@/lib/utils'
import { FileUpload } from './FileUpload'
import { ChatPanel } from './ChatPanel'
import { RevisionList } from './RevisionBanner'
import { getTimeRemaining, formatFileSize, getStatusColor, getQCStatusColor } from './utils'
import type {
  Project,
  ProjectFile,
  ProjectDeliverable,
  ProjectRevision,
  ChatMessage,
} from '@/types/database'

/**
 * WorkspaceView component props
 */
interface WorkspaceViewProps {
  /** Project data */
  project: Project
  /** Reference files */
  files: ProjectFile[]
  /** Deliverables */
  deliverables: ProjectDeliverable[]
  /** Revisions */
  revisions: ProjectRevision[]
  /** Chat messages */
  messages: ChatMessage[]
  /** Chat room ID */
  chatRoomId?: string
  /** Current user ID */
  currentUserId: string
  /** Current user name */
  currentUserName: string
  /** Current user avatar */
  currentUserAvatar?: string
  /** Loading state */
  isLoading?: boolean
  /** Whether chat is loading */
  isChatLoading?: boolean
  /** Whether chat is sending */
  isChatSending?: boolean
  /** Callback to upload deliverable */
  onUploadDeliverable?: (files: File[]) => Promise<void>
  /** Callback to submit project */
  onSubmitProject?: () => Promise<void>
  /** Callback to start project */
  onStartProject?: () => Promise<void>
  /** Callback to send chat message */
  onSendMessage?: (content: string) => Promise<void>
  /** Callback to send chat file */
  onSendFile?: (file: File) => Promise<void>
  /** Callback to start revision */
  onStartRevision?: (revisionId: string) => void
  /** Callback to update live document URL */
  onUpdateLiveDocUrl?: (url: string) => Promise<void>
}

/**
 * Workspace view component
 * Full project workspace with details, chat, and file upload
 */
export function WorkspaceView({
  project,
  files,
  deliverables,
  revisions,
  messages,
  chatRoomId,
  currentUserId,
  currentUserName,
  currentUserAvatar,
  isLoading = false,
  isChatLoading = false,
  isChatSending = false,
  onUploadDeliverable,
  onSubmitProject,
  onStartProject,
  onSendMessage,
  onSendFile,
  onStartRevision,
  onUpdateLiveDocUrl,
}: WorkspaceViewProps) {
  const [activeTab, setActiveTab] = useState('details')
  const [isUploading, setIsUploading] = useState(false)
  const [liveDocUrl, setLiveDocUrl] = useState(project.live_document_url || '')
  const [isSavingDocUrl, setIsSavingDocUrl] = useState(false)
  const [docUrlError, setDocUrlError] = useState<string | null>(null)

  const timeInfo = getTimeRemaining(project.deadline)
  const hasRevision = project.status === 'revision_requested'
  const pendingRevision = revisions.find((r) => r.status === 'pending')

  /**
   * Handle saving the live document URL
   */
  const handleSaveDocUrl = async () => {
    if (!onUpdateLiveDocUrl) return
    const trimmed = liveDocUrl.trim()
    if (trimmed && !trimmed.startsWith('https://')) {
      setDocUrlError('URL must start with https://')
      return
    }
    setDocUrlError(null)
    setIsSavingDocUrl(true)
    try {
      await onUpdateLiveDocUrl(trimmed)
    } finally {
      setIsSavingDocUrl(false)
    }
  }

  /**
   * Handle file upload
   * Wraps the upload callback with loading state management
   */
  const handleUpload = async (uploadedFiles: File[]) => {
    if (!onUploadDeliverable) return
    setIsUploading(true)
    try {
      await onUploadDeliverable(uploadedFiles)
    } finally {
      setIsUploading(false)
    }
  }

  return (
    <div className="space-y-6">
      {/* Revision Banner */}
      {hasRevision && pendingRevision && (
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
        >
          <RevisionList
            revisions={revisions}
            supervisorName={project.supervisor_name || undefined}
            onStartRevision={onStartRevision}
          />
        </motion.div>
      )}

      {/* Header with deadline timer - Doer dashboard style */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className={cn(
          'relative overflow-hidden rounded-[28px] shadow-[0_20px_50px_rgba(30,58,138,0.1)] transition-all duration-300',
          timeInfo.isUrgent
            ? 'bg-gradient-to-br from-[#FFF4F0] via-[#FFF7F4] to-[#FFEFE9]'
            : 'bg-white/85'
        )}
      >
        <div className="p-6">
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
            {/* Deadline */}
            <div className="flex items-center gap-4">
              <div
                className={cn(
                  'h-14 w-14 rounded-2xl flex items-center justify-center transition-colors duration-300',
                  timeInfo.isUrgent
                    ? 'bg-[#FFE7E1]'
                    : 'bg-[#E6F4FF]'
                )}
              >
                {timeInfo.isUrgent ? (
                  <AlertCircle className="h-7 w-7 text-[#FF8B6A]" />
                ) : (
                  <Clock className="h-7 w-7 text-[#4B9BFF]" />
                )}
              </div>

              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-slate-500 mb-1">Time Remaining</p>
                <p
                  className={cn(
                    'text-2xl lg:text-3xl font-semibold transition-colors',
                    timeInfo.isUrgent ? 'text-[#FF8B6A]' : 'text-slate-900'
                  )}
                >
                  {timeInfo.text}
                </p>
              </div>
            </div>

            {/* Countdown boxes */}
            <div className="flex gap-3">
              {[
                { value: timeInfo.days, label: 'Days' },
                { value: timeInfo.hours, label: 'Hours' },
                { value: timeInfo.minutes, label: 'Mins' },
              ].map((item, index) => (
                <motion.div
                  key={item.label}
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: index * 0.1, duration: 0.3 }}
                  className={cn(
                    'px-5 py-3 rounded-2xl text-center min-w-[70px] transition-all duration-300',
                    timeInfo.isUrgent
                      ? 'bg-[#FFE7E1]'
                      : 'bg-slate-50/80'
                  )}
                >
                  <p className={cn(
                    'text-2xl font-semibold',
                    timeInfo.isUrgent ? 'text-[#FF8B6A]' : 'text-slate-900'
                  )}>
                    {item.value}
                  </p>
                  <p className="text-xs text-slate-500 mt-0.5">{item.label}</p>
                </motion.div>
              ))}
            </div>

            {/* Earnings */}
            <div className="bg-gradient-to-br from-[#EEF2FF] via-[#F5F6FF] to-[#E9EDFF] rounded-2xl px-5 py-3 text-right min-w-[140px] shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
              <p className="text-xs font-semibold uppercase tracking-wide text-slate-500 mb-1">Earnings</p>
              <p className="text-2xl lg:text-3xl font-semibold text-[#5B7CFF] flex items-center justify-end gap-1">
                <IndianRupee className="h-6 w-6" />
                {(project.price ?? project.doer_payout ?? 0).toLocaleString('en-IN')}
              </p>
            </div>
          </div>

          {/* Progress bar */}
          <div className="mt-6">
            <div className="flex h-2 overflow-hidden rounded-full bg-slate-100">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${timeInfo.percentage}%` }}
                transition={{ duration: 1, ease: "easeOut" }}
                className={cn(
                  'transition-all duration-500',
                  timeInfo.isUrgent
                    ? 'bg-[#FF8B6A]'
                    : 'bg-[#5B7CFF]'
                )}
                style={{ width: `${timeInfo.percentage}%` }}
              />
            </div>
          </div>
        </div>
      </motion.div>

      {/* Main workspace tabs - Doer dashboard style */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2, duration: 0.5 }}
      >
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="w-full grid grid-cols-3 h-12 rounded-full bg-white/85 p-1 shadow-[0_14px_28px_rgba(30,58,138,0.08)]">
            <TabsTrigger
              value="details"
              className="relative gap-2 rounded-full text-sm font-medium data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:via-[#5B86FF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all duration-300"
            >
              <FileText className="h-4 w-4" />
              Details
            </TabsTrigger>
            <TabsTrigger
              value="submit"
              className="gap-2 rounded-full text-sm font-medium data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:via-[#5B86FF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all duration-300"
            >
              <Upload className="h-4 w-4" />
              Submit
            </TabsTrigger>
            <TabsTrigger
              value="chat"
              className="gap-2 rounded-full text-sm font-medium data-[state=active]:bg-gradient-to-r data-[state=active]:from-[#5A7CFF] data-[state=active]:via-[#5B86FF] data-[state=active]:to-[#49C5FF] data-[state=active]:text-white transition-all duration-300"
            >
              <MessageSquare className="h-4 w-4" />
              Chat
              {messages.filter((m) => !(m.read_by || []).includes(currentUserId) && m.sender_id !== currentUserId)
                .length > 0 && (
                <Badge className="ml-1 h-5 w-5 rounded-full bg-white/80 p-0 text-xs font-semibold text-[#4F6CF7]">
                  {
                    messages.filter(
                      (m) => !(m.read_by || []).includes(currentUserId) && m.sender_id !== currentUserId
                    ).length
                  }
                </Badge>
              )}
            </TabsTrigger>
          </TabsList>

        {/* Details Tab - Doer dashboard style */}
        <TabsContent value="details" className="space-y-6 mt-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
            className="rounded-[24px] bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] overflow-hidden"
          >
            <div className="p-6 border-b border-slate-100">
              <h2 className="text-2xl font-semibold text-slate-900 mb-3">{project.title}</h2>
              <div className="flex items-center gap-2 flex-wrap">
                {project.subject_name && (
                  <Badge className="bg-[#EEF2FF] text-[#5B7CFF] hover:bg-[#E3E9FF] border-0 px-3 py-1 font-medium">
                    {project.subject_name}
                  </Badge>
                )}
                <Badge className="bg-[#E6F4FF] text-[#4B9BFF] hover:bg-[#D6ECFF] border-0 px-3 py-1 font-medium">
                  {project.status.replace(/_/g, ' ')}
                </Badge>
              </div>
            </div>

            <div className="p-6 space-y-4">
              {/* Project Brief - Doer dashboard style */}
              <Accordion type="single" collapsible defaultValue="brief" className="space-y-3">
                <AccordionItem value="brief" className="border-0">
                  <AccordionTrigger className="px-5 py-4 rounded-2xl bg-slate-50/80 hover:bg-slate-100 transition-colors font-semibold text-slate-900 text-base">
                    Project Brief
                  </AccordionTrigger>
                  <AccordionContent className="px-5 py-4">
                    <div className="prose prose-sm max-w-none text-slate-700 leading-relaxed">
                      {project.specific_instructions || project.description || 'No brief provided'}
                    </div>
                  </AccordionContent>
                </AccordionItem>

                <AccordionItem value="requirements" className="border-0">
                  <AccordionTrigger className="px-5 py-4 rounded-2xl bg-slate-50/80 hover:bg-slate-100 transition-colors font-semibold text-slate-900 text-base">
                    Requirements
                  </AccordionTrigger>
                  <AccordionContent className="px-5 py-4">
                    <div className="grid gap-4 sm:grid-cols-2">
                      {project.word_count && (
                        <div className="flex flex-col gap-1">
                          <span className="text-xs font-semibold uppercase tracking-wide text-slate-500">Word Count</span>
                          <span className="text-base font-semibold text-slate-900">{project.word_count}</span>
                        </div>
                      )}
                      {project.page_count && (
                        <div className="flex flex-col gap-1">
                          <span className="text-xs font-semibold uppercase tracking-wide text-slate-500">Page Count</span>
                          <span className="text-base font-semibold text-slate-900">{project.page_count}</span>
                        </div>
                      )}
                      {project.reference_style_id && (
                        <div className="flex flex-col gap-1 sm:col-span-2">
                          <span className="text-xs font-semibold uppercase tracking-wide text-slate-500">Reference Style</span>
                          <span className="text-base font-semibold text-slate-900">{project.reference_style_id}</span>
                        </div>
                      )}
                    </div>
                    {project.specific_instructions && (
                      <div className="mt-4 pt-4 border-t border-slate-100">
                        <span className="text-xs font-semibold uppercase tracking-wide text-slate-500 block mb-2">Special Instructions</span>
                        <p className="text-sm text-slate-700 leading-relaxed">{project.specific_instructions}</p>
                      </div>
                    )}
                  </AccordionContent>
                </AccordionItem>

                <AccordionItem value="files" className="border-0">
                  <AccordionTrigger className="px-5 py-4 rounded-2xl bg-slate-50/80 hover:bg-slate-100 transition-colors font-semibold text-slate-900 text-base">
                    Reference Files ({files.filter((f) => f.file_category === 'reference').length})
                  </AccordionTrigger>
                  <AccordionContent className="px-5 py-4">
                    <div className="space-y-2">
                      {files.filter((f) => f.file_category === 'reference').length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-8 text-center">
                          <div className="h-12 w-12 rounded-xl bg-[#E6F4FF] flex items-center justify-center mb-3">
                            <File className="h-6 w-6 text-[#4B9BFF]" />
                          </div>
                          <p className="text-sm text-slate-500 font-medium">No reference files attached</p>
                        </div>
                      ) : (
                        files
                          .filter((f) => f.file_category === 'reference')
                          .map((file) => (
                            <a
                              key={file.id}
                              href={file.file_url}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="group flex items-center gap-3 p-3 rounded-2xl bg-slate-50/80 hover:bg-[#E6F4FF] transition-all duration-200"
                            >
                              <div className="h-10 w-10 rounded-lg bg-white group-hover:bg-[#D6ECFF] flex items-center justify-center transition-colors">
                                <File className="h-5 w-5 text-slate-600 group-hover:text-[#4B9BFF] transition-colors" />
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="text-sm font-semibold text-slate-900 truncate group-hover:text-[#4B9BFF] transition-colors">
                                  {file.file_name}
                                </p>
                                <p className="text-xs text-slate-500">{formatFileSize(file.file_size_bytes || 0)}</p>
                              </div>
                              <Download className="h-5 w-5 text-slate-400 group-hover:text-[#4B9BFF] transition-colors flex-shrink-0" />
                            </a>
                          ))
                      )}
                    </div>
                  </AccordionContent>
                </AccordionItem>
              </Accordion>

              {/* Start project button */}
              {project.status === 'assigned' && onStartProject && (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: 0.3, duration: 0.3 }}
                >
                  <Button
                    onClick={onStartProject}
                    className="w-full h-11 rounded-full bg-[#FF9B7A] hover:bg-[#FF8B6A] text-white text-sm font-semibold shadow-[0_8px_30px_rgba(255,155,122,0.35)] transition hover:-translate-y-0.5 hover:shadow-[0_12px_40px_rgba(255,155,122,0.45)]"
                    size="lg"
                  >
                    <CheckCircle2 className="h-4 w-4 mr-2" />
                    Start Working on Project
                  </Button>
                </motion.div>
              )}

              {/* Google Docs Link */}
              {onUpdateLiveDocUrl && (
                <div className="rounded-2xl bg-slate-50/80 p-4 space-y-3">
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-lg bg-[#EEF2FF] flex items-center justify-center">
                      <Link2 className="h-4 w-4 text-[#5B7CFF]" />
                    </div>
                    <span className="text-sm font-semibold text-slate-900">Google Docs Link</span>
                  </div>
                  <div className="flex gap-2">
                    <input
                      type="url"
                      placeholder="https://docs.google.com/..."
                      value={liveDocUrl}
                      onChange={(e) => {
                        setLiveDocUrl(e.target.value)
                        setDocUrlError(null)
                      }}
                      className="flex-1 h-10 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#5B7CFF]/30 focus:border-[#5B7CFF] transition-all"
                    />
                    <Button
                      onClick={handleSaveDocUrl}
                      disabled={isSavingDocUrl || liveDocUrl.trim() === (project.live_document_url || '')}
                      size="sm"
                      className="h-10 rounded-xl bg-[#5B7CFF] hover:bg-[#4A6AEE] text-white text-sm font-medium px-4 transition-all disabled:opacity-50"
                    >
                      {isSavingDocUrl ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : (
                        'Save Link'
                      )}
                    </Button>
                  </div>
                  {docUrlError && (
                    <p className="text-xs text-red-500 font-medium">{docUrlError}</p>
                  )}
                  {project.live_document_url && (
                    <a
                      href={project.live_document_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-1.5 text-xs font-medium text-[#5B7CFF] hover:text-[#4A6AEE] transition-colors"
                    >
                      <ExternalLink className="h-3.5 w-3.5" />
                      Open current document
                    </a>
                  )}
                </div>
              )}

              {/* Supervisor info */}
              {project.supervisor_name && (
                <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-4 py-3">
                  <span className="text-sm font-medium text-slate-500">Supervisor</span>
                  <span className="font-semibold text-slate-900">{project.supervisor_name}</span>
                </div>
              )}
            </div>
          </motion.div>
        </TabsContent>

        {/* Submit Tab - Doer dashboard style */}
        <TabsContent value="submit" className="space-y-6 mt-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
            className="rounded-[24px] bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] overflow-hidden"
          >
            <div className="p-6 border-b border-slate-100">
              <h3 className="text-xl font-semibold text-slate-900">Submit Your Work</h3>
              <p className="text-sm text-slate-500 mt-1">Upload your completed work for review</p>
            </div>

            <div className="p-6 space-y-6">
              {/* Previous deliverables */}
              {deliverables.length > 0 && (
                <div className="space-y-3">
                  <h4 className="text-sm font-semibold text-slate-900 uppercase tracking-wide">Previous Submissions</h4>
                  <div className="space-y-2">
                    {deliverables.map((d, index) => (
                      <motion.div
                        key={d.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.1, duration: 0.3 }}
                        className="flex items-center justify-between p-4 rounded-2xl bg-slate-50/80 hover:bg-slate-100 transition-all"
                      >
                        <div className="flex items-center gap-3 flex-1 min-w-0">
                          <div className="h-10 w-10 rounded-lg bg-[#E6F4FF] flex items-center justify-center flex-shrink-0">
                            <FileText className="h-5 w-5 text-[#4B9BFF]" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-semibold text-slate-900 truncate">{d.file_name}</p>
                            <Badge className="bg-[#EEF2FF] text-[#5B7CFF] hover:bg-[#E3E9FF] border-0 text-xs mt-1 px-2 py-0 font-medium">
                              Version {d.version}
                            </Badge>
                          </div>
                        </div>
                        <Badge className={cn(
                          'px-3 py-1 font-semibold',
                          d.qc_status === 'approved' && 'bg-[#D1FAE5] text-[#059669]',
                          d.qc_status === 'pending' && 'bg-[#FFE7E1] text-[#FF8B6A]',
                          d.qc_status === 'rejected' && 'bg-[#FEE2E2] text-[#DC2626]'
                        )}>
                          {d.qc_status}
                        </Badge>
                      </motion.div>
                    ))}
                  </div>
                </div>
              )}

              {/* File upload */}
              <div className="space-y-3">
                <h4 className="text-sm font-semibold text-slate-900 uppercase tracking-wide">Upload Files</h4>
                <FileUpload
                  onFilesSelected={() => {}}
                  onUpload={handleUpload}
                  isUploading={isUploading}
                  maxFiles={5}
                  multiple
                />
              </div>

              {/* Submit button */}
              {deliverables.length > 0 && onSubmitProject && (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: 0.2, duration: 0.3 }}
                >
                  <Button
                    onClick={onSubmitProject}
                    disabled={isLoading}
                    className="w-full h-11 rounded-full bg-[#FF9B7A] hover:bg-[#FF8B6A] text-white text-sm font-semibold shadow-[0_8px_30px_rgba(255,155,122,0.35)] transition hover:-translate-y-0.5 hover:shadow-[0_12px_40px_rgba(255,155,122,0.45)]"
                    size="lg"
                  >
                    <Send className="h-4 w-4 mr-2" />
                    Submit for Review
                  </Button>
                </motion.div>
              )}
            </div>
          </motion.div>
        </TabsContent>

        {/* Chat Tab - Doer dashboard style */}
        <TabsContent value="chat" className="mt-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
            className="rounded-[24px] bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] overflow-hidden"
          >
            <div className="h-[600px]">
              <ChatPanel
                roomId={chatRoomId || ''}
                currentUserId={currentUserId}
                currentUserName={currentUserName}
                currentUserAvatar={currentUserAvatar}
                messages={messages}
                isLoading={isChatLoading}
                isSending={isChatSending}
                onSendMessage={onSendMessage}
                onSendFile={onSendFile}
                className="h-full"
              />
            </div>
          </motion.div>
        </TabsContent>
      </Tabs>
      </motion.div>
    </div>
  )
}
