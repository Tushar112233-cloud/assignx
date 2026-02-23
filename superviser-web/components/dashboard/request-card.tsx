/**
 * @fileoverview Card component displaying individual project request details.
 * @module components/dashboard/request-card
 */

"use client"

import { useState } from "react"
import { formatDistanceToNow, format, differenceInHours } from "date-fns"
import {
  Clock,
  FileText,
  AlertTriangle,
  User,
  ChevronRight,
  Eye,
  BookOpen,
} from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
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

interface RequestCardProps {
  request: ProjectRequest
  onAnalyze: (request: ProjectRequest) => void
  isLoading?: boolean
}

export function RequestCard({ request, onAnalyze, isLoading }: RequestCardProps) {
  const [isExpanded, setIsExpanded] = useState(false)

  const deadlineDate = new Date(request.deadline)
  const hoursUntilDeadline = differenceInHours(deadlineDate, new Date())
  const isUrgent = hoursUntilDeadline <= 24
  const isCritical = hoursUntilDeadline <= 6

  const getServiceLabel = (type: string) => {
    const labels: Record<string, string> = {
      new_project: "New Project",
      proofreading: "Proofreading",
      plagiarism_check: "Plagiarism Check",
      ai_detection: "AI Detection",
      expert_opinion: "Expert Opinion",
    }
    return labels[type] || type
  }

  const getPriorityStyles = () => {
    if (isCritical) return "border-l-4 border-l-red-500 bg-red-50 dark:bg-red-950/20"
    if (isUrgent) return "border-l-4 border-l-orange-400 bg-orange-50 dark:bg-orange-950/20"
    return "border-l-4 border-l-blue-400"
  }

  return (
    <Card
      className={cn(
        "hover:shadow-md transition-all duration-200 cursor-pointer group",
        getPriorityStyles()
      )}
      onClick={() => setIsExpanded(!isExpanded)}
    >
      <CardContent className="p-5">
        <div className="flex items-start justify-between gap-4">
          {/* Left Section */}
          <div className="flex-1 min-w-0">
            {/* Header Row */}
            <div className="flex items-center gap-2 mb-3">
              <Badge variant="outline" className="text-xs font-mono">
                {request.project_number}
              </Badge>
              <Badge variant="secondary" className="text-xs">
                {getServiceLabel(request.service_type)}
              </Badge>
              {(isUrgent || isCritical) && (
                <Badge
                  variant="destructive"
                  className={cn(
                    "text-xs gap-2",
                    isCritical ? "bg-red-600" : "bg-orange-500"
                  )}
                >
                  <AlertTriangle className="h-3 w-3" />
                  {isCritical ? "Critical" : "Urgent"}
                </Badge>
              )}
            </div>

            {/* Title */}
            <h3 className="font-semibold text-base truncate mb-1 group-hover:text-primary transition-colors">
              {request.title}
            </h3>

            {/* Subject */}
            <div className="flex items-center gap-2 text-sm text-muted-foreground mb-2">
              <BookOpen className="h-3.5 w-3.5" />
              <span>{request.subject}</span>
            </div>

            {/* Meta Info Row */}
            <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <div className="flex items-center gap-1">
                      <User className="h-3.5 w-3.5" />
                      <span className="truncate max-w-[100px]">
                        {request.user_name}
                      </span>
                    </div>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p>Client: {request.user_name}</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <div
                      className={cn(
                        "flex items-center gap-1",
                        isCritical && "text-red-600 font-medium",
                        isUrgent && !isCritical && "text-orange-600 font-medium"
                      )}
                    >
                      <Clock className="h-3.5 w-3.5" />
                      <span>{formatDistanceToNow(deadlineDate, { addSuffix: true })}</span>
                    </div>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p>Deadline: {format(deadlineDate, "PPpp")}</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              {request.word_count && (
                <div className="flex items-center gap-1">
                  <FileText className="h-3.5 w-3.5" />
                  <span>{request.word_count.toLocaleString()} words</span>
                </div>
              )}

              {request.page_count && (
                <div className="flex items-center gap-1">
                  <FileText className="h-3.5 w-3.5" />
                  <span>{request.page_count} pages</span>
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
              className="whitespace-nowrap"
            >
              <Eye className="h-4 w-4 mr-1.5" />
              Analyze & Quote
              <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>

        {/* Expanded Details */}
        {isExpanded && (
          <div className="mt-4 pt-4 border-t space-y-2">
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-muted-foreground">Submitted:</span>
                <span className="ml-2">
                  {format(new Date(request.created_at), "PPp")}
                </span>
              </div>
              <div>
                <span className="text-muted-foreground">Deadline:</span>
                <span className="ml-2">{format(deadlineDate, "PPp")}</span>
              </div>
              {request.attachments_count !== undefined && (
                <div>
                  <span className="text-muted-foreground">Attachments:</span>
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
