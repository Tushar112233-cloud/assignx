"use client"

import { useState } from "react"
import { formatDistanceToNow, format, differenceInHours } from "date-fns"
import {
  Clock,
  FileText,
  AlertCircle,
  User,
  ChevronRight,
  UserPlus,
  BookOpen,
  IndianRupee,
  BadgeCheck,
  Zap,
  ArrowUpRight,
} from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
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

interface ReadyToAssignCardV2Props {
  project: PaidProject
  onAssign: (project: PaidProject) => void
  isLoading?: boolean
  variant?: "default" | "compact"
}

export function ReadyToAssignCardV2({
  project,
  onAssign,
  isLoading,
  variant = "default",
}: ReadyToAssignCardV2Props) {
  const [isExpanded, setIsExpanded] = useState(false)

  const deadlineDate = new Date(project.deadline)
  const hoursUntilDeadline = differenceInHours(deadlineDate, new Date())
  const isUrgent = hoursUntilDeadline <= 24
  const isCritical = hoursUntilDeadline <= 6

  const getPriorityStyles = () => {
    if (isCritical) return "priority-critical"
    if (isUrgent) return "priority-urgent"
    return "bg-emerald-500/20 border-emerald-500/50 text-emerald-400"
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
              {/* Paid Indicator */}
              <div className={cn(
                "h-10 w-10 rounded-lg flex items-center justify-center flex-shrink-0",
                getPriorityStyles()
              )}>
                <BadgeCheck className="h-5 w-5" />
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-mono text-[var(--dash-text-muted)]">
                    {project.project_number}
                  </span>
                  <span className="text-[10px] px-1.5 py-0.5 rounded bg-emerald-500/20 text-emerald-400 font-medium">
                    PAID
                  </span>
                </div>
                <h3 className="font-medium text-sm text-white truncate group-hover:text-[var(--dash-accent)] transition-colors">
                  {project.title}
                </h3>
                <div className="flex items-center gap-3 mt-1 text-xs text-[var(--dash-text-muted)]">
                  <span className="text-emerald-400 font-medium">
                    ₹{project.doer_payout.toLocaleString("en-IN")} payout
                  </span>
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
                onAssign(project)
              }}
              disabled={isLoading}
              className="flex-shrink-0 bg-[var(--dash-highlight)] text-white hover:bg-[var(--dash-highlight)]/90"
            >
              <span className="text-xs">Assign</span>
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
                {project.project_number}
              </Badge>
              <Badge
                className="text-xs gap-1 bg-emerald-500/20 text-emerald-400 border-0"
              >
                <BadgeCheck className="h-3 w-3" />
                PAID
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
                  <AlertCircle className="h-3 w-3" />
                  {isCritical ? "Critical" : "Urgent"}
                </Badge>
              )}
            </div>

            {/* Title */}
            <h3 className="font-semibold text-base text-white truncate mb-1 group-hover:text-[var(--dash-accent)] transition-colors">
              {project.title}
            </h3>

            {/* Subject */}
            <div className="flex items-center gap-2 text-sm text-[var(--dash-text-muted)] mb-3">
              <BookOpen className="h-3.5 w-3.5" />
              <span>{project.subject}</span>
            </div>

            {/* Meta Info Row */}
            <div className="flex flex-wrap items-center gap-3 text-xs text-[var(--dash-text-muted)]">
              <div className="flex items-center gap-1 text-emerald-400">
                <IndianRupee className="h-3.5 w-3.5" />
                <span className="font-medium">
                  {project.quoted_amount.toLocaleString("en-IN")} paid
                </span>
              </div>

              <div className="flex items-center gap-1">
                <User className="h-3.5 w-3.5" />
                <span className="truncate max-w-[120px]">
                  {project.user_name}
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
                <span>
                  {formatDistanceToNow(deadlineDate, { addSuffix: true })}
                </span>
              </div>

              {project.word_count && (
                <div className="flex items-center gap-1">
                  <FileText className="h-3.5 w-3.5" />
                  <span>{project.word_count.toLocaleString()} words</span>
                </div>
              )}
            </div>
          </div>

          {/* Right Section */}
          <div className="flex flex-col items-end gap-2">
            <div className="text-right">
              <p className="text-xs text-[var(--dash-text-muted)]">Doer Payout</p>
              <p className="font-semibold text-emerald-400">
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
              className="bg-[var(--dash-highlight)] text-white hover:bg-[var(--dash-highlight)]/90"
            >
              <UserPlus className="h-4 w-4 mr-1.5" />
              Assign Doer
              <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>

        {/* Expanded Details */}
        {isExpanded && (
          <div className="mt-4 pt-4 border-t border-[var(--dash-border)] space-y-2">
            <div className="grid grid-cols-2 gap-4 text-sm text-[var(--dash-text-secondary)]">
              <div>
                <span className="text-[var(--dash-text-muted)]">Paid at:</span>
                <span className="ml-2">
                  {format(new Date(project.paid_at), "PPp")}
                </span>
              </div>
              <div>
                <span className="text-[var(--dash-text-muted)]">Deadline:</span>
                <span className="ml-2">{format(deadlineDate, "PPp")}</span>
              </div>
              <div>
                <span className="text-[var(--dash-text-muted)]">Your Commission:</span>
                <span className="ml-2 text-emerald-400 font-medium">
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
