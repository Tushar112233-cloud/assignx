"use client"

import { useState } from "react"
import { formatDistanceToNow, format, differenceInHours } from "date-fns"
import {
  Clock,
  FileText,
  AlertCircle,
  User,
  ChevronRight,
  Eye,
  BookOpen,
  Zap,
  ArrowUpRight,
} from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"

export interface ProjectRequest {
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
  priority?: "normal" | "urgent" | "critical"
  attachments_count?: number
}

interface RequestCardV2Props {
  request: ProjectRequest
  onAnalyze: (request: ProjectRequest) => void
  isLoading?: boolean
  variant?: "default" | "compact"
}

export function RequestCardV2({ 
  request, 
  onAnalyze, 
  isLoading,
  variant = "default" 
}: RequestCardV2Props) {
  const [isExpanded, setIsExpanded] = useState(false)

  const deadlineDate = new Date(request.deadline)
  const hoursUntilDeadline = differenceInHours(deadlineDate, new Date())
  const isUrgent = hoursUntilDeadline <= 24
  const isCritical = hoursUntilDeadline <= 6

  const getPriorityStyles = () => {
    if (isCritical) return "priority-critical"
    if (isUrgent) return "priority-urgent"
    return "priority-normal"
  }

  const getPriorityIcon = () => {
    if (isCritical) return <AlertCircle className="h-3.5 w-3.5" />
    if (isUrgent) return <Zap className="h-3.5 w-3.5" />
    return <Clock className="h-3.5 w-3.5" />
  }

  if (variant === "compact") {
    return (
      <Card 
        className={cn(
          "dash-card-hover cursor-pointer group overflow-hidden",
          isCritical && "border-l-4 border-l-red-500",
          isUrgent && !isCritical && "border-l-4 border-l-orange-500"
        )}
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <CardContent className="p-4">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-3 flex-1 min-w-0">
              {/* Priority Indicator */}
              <div className={cn(
                "h-10 w-10 rounded-lg flex items-center justify-center flex-shrink-0",
                getPriorityStyles()
              )}>
                {getPriorityIcon()}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-mono text-[var(--dash-text-muted)]">
                    {request.project_number}
                  </span>
                  <span className="text-[10px] px-1.5 py-0.5 rounded bg-[var(--dash-surface)] text-[var(--dash-text-muted)]">
                    {request.subject}
                  </span>
                </div>
                <h3 className="font-medium text-sm text-white truncate group-hover:text-[var(--dash-accent)] transition-colors">
                  {request.title}
                </h3>
                <div className="flex items-center gap-3 mt-1 text-xs text-[var(--dash-text-muted)]">
                  <span>{request.user_name}</span>
                  <span>•</span>
                  <span className={cn(
                    isCritical && "text-red-400",
                    isUrgent && !isCritical && "text-orange-400"
                  )}>
                    Due {formatDistanceToNow(deadlineDate, { addSuffix: true })}
                  </span>
                </div>
              </div>
            </div>

            <Button
              size="sm"
              onClick={(e) => {
                e.stopPropagation()
                onAnalyze(request)
              }}
              disabled={isLoading}
              className="flex-shrink-0 bg-[var(--dash-accent)] text-[var(--dash-bg)] hover:bg-[var(--dash-accent-hover)]"
            >
              <span className="text-xs">Quote</span>
              <ArrowUpRight className="h-3.5 w-3.5 ml-1" />
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card
      className={cn(
        "dash-card-hover cursor-pointer group overflow-hidden",
        isCritical && "border-l-4 border-l-red-500",
        isUrgent && !isCritical && "border-l-4 border-l-orange-500"
      )}
      onClick={() => setIsExpanded(!isExpanded)}
    >
      <CardContent className="p-5">
        <div className="flex items-start justify-between gap-4">
          {/* Left Section */}
          <div className="flex-1 min-w-0">
            {/* Header Row */}
            <div className="flex items-center gap-2 mb-3">
              <Badge 
                variant="outline" 
                className="text-xs font-mono border-[var(--dash-border)] bg-[var(--dash-surface)] text-[var(--dash-text-muted)]"
              >
                {request.project_number}
              </Badge>
              <Badge 
                className="text-xs bg-[var(--dash-surface)] text-[var(--dash-text-secondary)] border border-[var(--dash-border)]"
              >
                {request.service_type.replace(/_/g, " ")}
              </Badge>
              {(isUrgent || isCritical) && (
                <Badge
                  className={cn(
                    "text-xs gap-1 border-0",
                    isCritical 
                      ? "bg-red-500/20 text-red-400" 
                      : "bg-orange-500/20 text-orange-400"
                  )}
                >
                  {getPriorityIcon()}
                  {isCritical ? "Critical" : "Urgent"}
                </Badge>
              )}
            </div>

            {/* Title */}
            <h3 className="font-semibold text-base text-white truncate mb-1 group-hover:text-[var(--dash-accent)] transition-colors">
              {request.title}
            </h3>

            {/* Subject */}
            <div className="flex items-center gap-2 text-sm text-[var(--dash-text-muted)] mb-3">
              <BookOpen className="h-3.5 w-3.5" />
              <span>{request.subject}</span>
            </div>

            {/* Meta Info Row */}
            <div className="flex flex-wrap items-center gap-3 text-xs text-[var(--dash-text-muted)]">
              <div className="flex items-center gap-1">
                <User className="h-3.5 w-3.5" />
                <span className="truncate max-w-[120px]">
                  {request.user_name}
                </span>
              </div>

              <div
                className={cn(
                  "flex items-center gap-1",
                  isCritical && "text-red-400 font-medium",
                  isUrgent && !isCritical && "text-orange-400 font-medium"
                )}
              >
                <Clock className="h-3.5 w-3.5" />
                <span>{formatDistanceToNow(deadlineDate, { addSuffix: true })}</span>
              </div>

              {request.word_count && (
                <div className="flex items-center gap-1">
                  <FileText className="h-3.5 w-3.5" />
                  <span>{request.word_count.toLocaleString()} words</span>
                </div>
              )}
            </div>
          </div>

          {/* Right Section - Action Button */}
          <div className="flex items-center gap-2">
            <Button
              size="sm"
              onClick={(e) => {
                e.stopPropagation()
                onAnalyze(request)
              }}
              disabled={isLoading}
              className="bg-[var(--dash-accent)] text-[var(--dash-bg)] hover:bg-[var(--dash-accent-hover)]"
            >
              <Eye className="h-4 w-4 mr-1.5" />
              Analyze
              <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>

        {/* Expanded Details */}
        {isExpanded && (
          <div className="mt-4 pt-4 border-t border-[var(--dash-border)] space-y-2">
            <div className="grid grid-cols-2 gap-4 text-sm text-[var(--dash-text-secondary)]">
              <div>
                <span className="text-[var(--dash-text-muted)]">Submitted:</span>
                <span className="ml-2">
                  {format(new Date(request.created_at), "PPp")}
                </span>
              </div>
              <div>
                <span className="text-[var(--dash-text-muted)]">Deadline:</span>
                <span className="ml-2">{format(deadlineDate, "PPp")}</span>
              </div>
              {request.attachments_count !== undefined && (
                <div>
                  <span className="text-[var(--dash-text-muted)]">Attachments:</span>
                  <span className="ml-2">{request.attachments_count} file(s)</span>
                </div>
              )}
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
