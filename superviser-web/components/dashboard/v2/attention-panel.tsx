/**
 * @fileoverview Attention Panel - Project cards requiring action.
 * Clean, functional design with subtle status indicators.
 * @module components/dashboard/v2/attention-panel
 */

"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import {
  Clock,
  FileText,
  ChevronRight,
  AlertCircle,
  CheckCircle2,
  User,
  Calendar,
  Zap,
  ArrowRight,
  Inbox
} from "lucide-react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import Link from "next/link"
import { formatDistanceToNow } from "date-fns"

interface ProjectItem {
  id: string
  project_number: string
  title: string
  subject: string
  service_type: string
  user_name: string
  deadline: string
  word_count?: number
  page_count?: number
  created_at: string
  quoted_amount?: number
  doer_payout?: number
  paid_at?: string
}

interface AttentionPanelProps {
  newRequests: ProjectItem[]
  readyToAssign: ProjectItem[]
  onAnalyze: (project: ProjectItem) => void
  onAssign: (project: ProjectItem) => void
  isLoading?: boolean
  className?: string
}

type TabId = "requests" | "ready"

function TabNav({
  activeTab,
  onTabChange,
  requestsCount,
  readyCount
}: {
  activeTab: TabId
  onTabChange: (tab: TabId) => void
  requestsCount: number
  readyCount: number
}) {
  const tabs = [
    { id: "requests" as TabId, label: "New Requests", count: requestsCount },
    { id: "ready" as TabId, label: "Ready to Assign", count: readyCount },
  ]

  return (
    <div className="flex items-center gap-1 p-1 bg-stone-100/70 rounded-lg">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => onTabChange(tab.id)}
          className={cn(
            "relative flex items-center gap-2 px-4 py-2 rounded-md text-sm font-medium transition-all duration-200",
            activeTab === tab.id
              ? "bg-white text-stone-900 shadow-sm"
              : "text-stone-500 hover:text-stone-700"
          )}
        >
          {tab.label}
          {tab.count > 0 && (
            <span className={cn(
              "min-w-[20px] h-5 px-1.5 flex items-center justify-center text-[11px] font-semibold rounded-full tabular-nums",
              activeTab === tab.id
                ? tab.id === "requests" ? "bg-amber-100 text-amber-700" : "bg-emerald-100 text-emerald-700"
                : "bg-stone-200/70 text-stone-500"
            )}>
              {tab.count}
            </span>
          )}
        </button>
      ))}
    </div>
  )
}

function ProjectCard({
  project,
  type,
  onAction,
  isLoading
}: {
  project: ProjectItem
  type: "request" | "ready"
  onAction: (project: ProjectItem) => void
  isLoading?: boolean
}) {
  const isUrgent = project.deadline && new Date(project.deadline) < new Date(Date.now() + 24 * 60 * 60 * 1000)

  return (
    <motion.div
      initial={{ opacity: 0, y: 4 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -4 }}
      className={cn(
        "group rounded-xl p-4",
        "bg-white border border-stone-200/60",
        "hover:border-stone-300/80 hover:shadow-sm",
        "transition-all duration-200"
      )}
    >
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1 min-w-0 space-y-2.5">
          {/* Header */}
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-xs font-mono text-stone-400">
              #{project.project_number}
            </span>
            <Badge
              variant="outline"
              className="text-[10px] px-1.5 py-0 h-5 bg-stone-50 border-stone-200 text-stone-600 font-medium"
            >
              {project.service_type.replace(/_/g, ' ')}
            </Badge>
            {isUrgent && (
              <span className="inline-flex items-center gap-1 text-[10px] font-medium text-amber-600">
                <AlertCircle className="h-3 w-3" />
                Urgent
              </span>
            )}
          </div>

          {/* Title */}
          <h4 className="text-sm font-medium text-stone-800 leading-snug line-clamp-2">
            {project.title}
          </h4>

          {/* Meta */}
          <div className="flex items-center gap-3 text-xs text-stone-500">
            <span className="flex items-center gap-1">
              <User className="h-3 w-3 text-stone-400" />
              {project.user_name}
            </span>
            <span className="text-stone-300">•</span>
            <span>{project.subject}</span>
            {project.word_count && (
              <>
                <span className="text-stone-300">•</span>
                <span>{project.word_count.toLocaleString()} words</span>
              </>
            )}
          </div>

          {/* Deadline */}
          <div className="flex items-center gap-1.5 text-xs">
            <Calendar className={cn("h-3 w-3", isUrgent ? "text-amber-500" : "text-stone-400")} />
            <span className={isUrgent ? "text-amber-600 font-medium" : "text-stone-500"}>
              Due {formatDistanceToNow(new Date(project.deadline), { addSuffix: true })}
            </span>
          </div>

          {/* Amount for ready to assign */}
          {type === "ready" && project.quoted_amount && (
            <div className="flex items-center gap-4 pt-1">
              <span className="text-sm">
                <span className="text-stone-400 text-xs">Quote: </span>
                <span className="font-semibold text-stone-700">₹{project.quoted_amount.toLocaleString()}</span>
              </span>
              {project.doer_payout && (
                <span className="text-sm">
                  <span className="text-stone-400 text-xs">Payout: </span>
                  <span className="font-medium text-stone-600">₹{project.doer_payout.toLocaleString()}</span>
                </span>
              )}
            </div>
          )}
        </div>

        {/* Action */}
        <Button
          size="sm"
          onClick={() => onAction(project)}
          disabled={isLoading}
          className={cn(
            "h-9 px-3 rounded-lg font-medium text-xs shrink-0",
            type === "request"
              ? "bg-stone-900 text-white hover:bg-stone-800"
              : "bg-emerald-600 text-white hover:bg-emerald-700"
          )}
        >
          {type === "request" ? (
            <>
              <Zap className="h-3.5 w-3.5 mr-1.5" />
              Analyze
            </>
          ) : (
            <>
              <ArrowRight className="h-3.5 w-3.5 mr-1.5" />
              Assign
            </>
          )}
        </Button>
      </div>
    </motion.div>
  )
}

function EmptyState({ type }: { type: "requests" | "ready" }) {
  return (
    <div className="flex flex-col items-center justify-center py-12 text-center">
      <div className="w-12 h-12 rounded-xl bg-stone-100 flex items-center justify-center mb-3">
        {type === "requests" ? (
          <Inbox className="h-5 w-5 text-stone-400" />
        ) : (
          <CheckCircle2 className="h-5 w-5 text-emerald-500" />
        )}
      </div>
      <p className="text-sm font-medium text-stone-600">
        {type === "requests" ? "No new requests" : "No projects ready"}
      </p>
      <p className="text-xs text-stone-400 mt-1">
        {type === "requests" ? "You're all caught up!" : "Projects appear here after payment"}
      </p>
    </div>
  )
}

function LoadingSkeleton() {
  return (
    <div className="space-y-3 p-4">
      {[1, 2, 3].map((i) => (
        <div key={i} className="h-28 bg-stone-100/50 rounded-xl animate-pulse" />
      ))}
    </div>
  )
}

export function AttentionPanel({
  newRequests,
  readyToAssign,
  onAnalyze,
  onAssign,
  isLoading = false,
  className,
}: AttentionPanelProps) {
  const [activeTab, setActiveTab] = useState<TabId>("requests")
  const totalCount = newRequests.length + readyToAssign.length

  return (
    <div className={cn(
      "rounded-2xl overflow-hidden",
      "bg-white",
      "border border-stone-200/60",
      "shadow-sm shadow-stone-100/50",
      className
    )}>
      {/* Header */}
      <div className="p-5 border-b border-stone-100">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <h3 className="text-[15px] font-semibold text-stone-900">
              Requires Attention
            </h3>
            {totalCount > 0 && (
              <span className="px-2 py-0.5 text-xs font-semibold rounded-full bg-amber-100 text-amber-700 tabular-nums">
                {totalCount}
              </span>
            )}
          </div>
          <Link
            href="/projects"
            className="text-xs text-stone-500 hover:text-stone-700 flex items-center gap-1 transition-colors"
          >
            View all
            <ChevronRight className="h-3 w-3" />
          </Link>
        </div>

        <TabNav
          activeTab={activeTab}
          onTabChange={setActiveTab}
          requestsCount={newRequests.length}
          readyCount={readyToAssign.length}
        />
      </div>

      {/* Content */}
      <div className="p-4 max-h-[480px] overflow-y-auto bg-stone-50/30">
        <AnimatePresence mode="wait">
          {isLoading ? (
            <LoadingSkeleton />
          ) : activeTab === "requests" ? (
            <motion.div
              key="requests"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="space-y-3"
            >
              {newRequests.length === 0 ? (
                <EmptyState type="requests" />
              ) : (
                newRequests.slice(0, 5).map((project) => (
                  <ProjectCard
                    key={project.id}
                    project={project}
                    type="request"
                    onAction={onAnalyze}
                    isLoading={isLoading}
                  />
                ))
              )}
            </motion.div>
          ) : (
            <motion.div
              key="ready"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="space-y-3"
            >
              {readyToAssign.length === 0 ? (
                <EmptyState type="ready" />
              ) : (
                readyToAssign.slice(0, 5).map((project) => (
                  <ProjectCard
                    key={project.id}
                    project={project}
                    type="ready"
                    onAction={onAssign}
                    isLoading={isLoading}
                  />
                ))
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}
