/**
 * @fileoverview Card for projects ready to be assigned to doers.
 * @module components/dashboard/ready-to-assign-card
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
  UserPlus,
  BookOpen,
  IndianRupee,
  BadgeCheck,
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

export interface PaidProject {
  id: string
  project_number: string
  title: string
  subject: string
  service_type: string
  user_name: string
  deadline: string
  word_count?: number
  page_count?: number
  quoted_amount: number
  doer_payout: number
  paid_at: string
  created_at: string
}

interface ReadyToAssignCardProps {
  project: PaidProject
  onAssign: (project: PaidProject) => void
  isLoading?: boolean
}

export function ReadyToAssignCard({
  project,
  onAssign,
  isLoading,
}: ReadyToAssignCardProps) {
  const [isExpanded, setIsExpanded] = useState(false)

  const deadlineDate = new Date(project.deadline)
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
    if (isCritical) return "border-red-500 bg-red-50 dark:bg-red-950/20"
    if (isUrgent) return "border-orange-400 bg-orange-50 dark:bg-orange-950/20"
    return ""
  }

  return (
    <Card
      className={cn(
        "transition-all hover:shadow-md cursor-pointer group",
        getPriorityStyles()
      )}
      onClick={() => setIsExpanded(!isExpanded)}
    >
      <CardContent className="p-4">
        <div className="flex items-start justify-between gap-4">
          {/* Left Section */}
          <div className="flex-1 min-w-0">
            {/* Header Row */}
            <div className="flex items-center gap-2 mb-2">
              <Badge variant="outline" className="text-xs font-mono">
                {project.project_number}
              </Badge>
              <Badge className="text-xs bg-green-500 hover:bg-green-600 gap-1">
                <BadgeCheck className="h-3 w-3" />
                PAID
              </Badge>
              {(isUrgent || isCritical) && (
                <Badge
                  variant="destructive"
                  className={cn(
                    "text-xs gap-1",
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
              {project.title}
            </h3>

            {/* Subject */}
            <div className="flex items-center gap-2 text-sm text-muted-foreground mb-2">
              <BookOpen className="h-3.5 w-3.5" />
              <span>{project.subject}</span>
            </div>

            {/* Meta Info Row */}
            <div className="flex flex-wrap items-center gap-4 text-xs text-muted-foreground">
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <div className="flex items-center gap-1">
                      <IndianRupee className="h-3.5 w-3.5" />
                      <span className="font-medium text-green-600">
                        ₹{project.quoted_amount.toLocaleString("en-IN")}
                      </span>
                    </div>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p>Client paid amount</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <div className="flex items-center gap-1">
                      <User className="h-3.5 w-3.5" />
                      <span className="truncate max-w-[100px]">
                        {project.user_name}
                      </span>
                    </div>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p>Client: {project.user_name}</p>
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
                      <span>
                        {formatDistanceToNow(deadlineDate, { addSuffix: true })}
                      </span>
                    </div>
                  </TooltipTrigger>
                  <TooltipContent>
                    <p>Deadline: {format(deadlineDate, "PPpp")}</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              {project.word_count && (
                <div className="flex items-center gap-1">
                  <FileText className="h-3.5 w-3.5" />
                  <span>{project.word_count.toLocaleString()} words</span>
                </div>
              )}
            </div>
          </div>

          {/* Right Section - Action Button */}
          <div className="flex flex-col items-end gap-2">
            <div className="text-right">
              <p className="text-xs text-muted-foreground">Doer Payout</p>
              <p className="font-semibold text-primary">
                ₹{project.doer_payout.toLocaleString("en-IN")}
              </p>
            </div>
            <Button
              size="sm"
              onClick={(e) => {
                e.stopPropagation()
                onAssign(project)
              }}
              disabled={isLoading}
              className="whitespace-nowrap"
            >
              <UserPlus className="h-4 w-4 mr-1.5" />
              Assign Doer
              <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>

        {/* Expanded Details */}
        {isExpanded && (
          <div className="mt-4 pt-4 border-t space-y-2">
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-muted-foreground">Paid at:</span>
                <span className="ml-2">
                  {format(new Date(project.paid_at), "PPp")}
                </span>
              </div>
              <div>
                <span className="text-muted-foreground">Deadline:</span>
                <span className="ml-2">{format(deadlineDate, "PPp")}</span>
              </div>
              <div>
                <span className="text-muted-foreground">Service:</span>
                <span className="ml-2">
                  {getServiceLabel(project.service_type)}
                </span>
              </div>
              <div>
                <span className="text-muted-foreground">Your Commission:</span>
                <span className="ml-2 text-green-600 font-medium">
                  ₹
                  {(project.quoted_amount - project.doer_payout).toLocaleString(
                    "en-IN"
                  )}
                </span>
              </div>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
