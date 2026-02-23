"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { formatDistanceToNow, format, differenceInHours } from "date-fns"
import Link from "next/link"
import {
  Clock,
  Calendar,
  MessageSquare,
  Eye,
  CheckCircle2,
  XCircle,
  Zap,
  AlertCircle,
  User,
  UserPlus,
  IndianRupee,
  RotateCcw,
  ChevronRight,
} from "lucide-react"

import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { cn } from "@/lib/utils"

/**
 * Project data for the card component
 */
export interface ProjectCardV2Data {
  id: string
  project_number: string
  title: string
  subject: string
  service_type: string
  status: string
  deadline: string
  user_name: string
  doer_name?: string
  quoted_amount?: number
  supervisor_commission?: number
  has_unread_messages?: boolean
  revision_count?: number
  created_at: string
}

/**
 * Props for the ProjectCardV2 component
 */
export interface ProjectCardV2Props {
  project: ProjectCardV2Data
  variant: "new" | "ready" | "ongoing" | "review" | "completed"
  highlighted?: boolean
  onClaim?: () => void
  onApprove?: () => void
  onReject?: () => void
  onAssign?: () => void
  isLoading?: boolean
}

/**
 * Status badge configuration per variant
 */
const VARIANT_CONFIG = {
  new: {
    label: "New Request",
    bgColor: "bg-emerald-100",
    textColor: "text-emerald-700",
    borderColor: "border-emerald-200",
  },
  ready: {
    label: "Ready to Assign",
    bgColor: "bg-blue-100",
    textColor: "text-blue-700",
    borderColor: "border-blue-200",
  },
  ongoing: {
    label: "In Progress",
    bgColor: "bg-orange-100",
    textColor: "text-orange-700",
    borderColor: "border-orange-200",
  },
  review: {
    label: "For Review",
    bgColor: "bg-amber-100",
    textColor: "text-amber-700",
    borderColor: "border-amber-200",
  },
  completed: {
    label: "Completed",
    bgColor: "bg-gray-100",
    textColor: "text-gray-600",
    borderColor: "border-gray-200",
  },
}

/**
 * Status badge component for displaying project status
 */
function StatusBadge({
  status,
  variant,
}: {
  status: string
  variant: ProjectCardV2Props["variant"]
}) {
  const config = VARIANT_CONFIG[variant]

  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium",
        config.bgColor,
        config.textColor
      )}
    >
      {variant === "ongoing" && <Zap className="h-3 w-3" />}
      {variant === "review" && <AlertCircle className="h-3 w-3" />}
      {variant === "completed" && <CheckCircle2 className="h-3 w-3" />}
      {config.label}
    </span>
  )
}

/**
 * Get initials from a name
 */
function getInitials(name: string): string {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

/**
 * ProjectCardV2 - A redesigned project card component matching dashboard aesthetics
 */
export function ProjectCardV2({
  project,
  variant,
  highlighted = false,
  onClaim,
  onApprove,
  onReject,
  onAssign,
  isLoading = false,
}: ProjectCardV2Props) {
  const [isHovered, setIsHovered] = useState(false)

  const deadlineDate = new Date(project.deadline)
  const hoursUntilDeadline = differenceInHours(deadlineDate, new Date())
  const isUrgent = hoursUntilDeadline <= 24 && hoursUntilDeadline > 6
  const isCritical = hoursUntilDeadline <= 6 && hoursUntilDeadline > 0
  const isOverdue = hoursUntilDeadline <= 0
  const dueLabel = isOverdue
    ? "Overdue"
    : formatDistanceToNow(deadlineDate, { addSuffix: true })
  const urgencyBand = cn(
    "rounded-xl border px-3 py-2",
    isCritical && "bg-red-50 border-red-200 text-red-700",
    isUrgent && !isCritical && "bg-orange-50 border-orange-200 text-orange-700",
    isOverdue && "bg-red-100 border-red-200 text-red-800",
    !isCritical && !isUrgent && !isOverdue && "bg-gray-50 border-gray-200 text-gray-600"
  )

  // Display name based on variant
  const displayName = variant === "ready" || variant === "new"
    ? project.user_name
    : project.doer_name || project.user_name

  const displayRole = variant === "ready" || variant === "new"
    ? "Client"
    : project.doer_name
      ? "Expert"
      : "Client"

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{
        opacity: 1,
        y: 0,
        scale: highlighted ? 1.02 : 1
      }}
      transition={{ duration: 0.3 }}
      whileHover={{ y: -2 }}
      onHoverStart={() => setIsHovered(true)}
      onHoverEnd={() => setIsHovered(false)}
      className={cn(
        "group bg-white rounded-2xl border overflow-hidden transition-all duration-300",
        highlighted && "border-orange-500 shadow-lg shadow-orange-200 ring-2 ring-orange-200",
        !highlighted && "border-gray-200",
        isHovered && !highlighted && "shadow-lg border-orange-200"
      )}
    >
      <div className="p-4 space-y-3">
        {/* Header: status badge + project number + amount */}
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-1.5 min-w-0 flex-wrap">
            <StatusBadge status={project.status} variant={variant} />
            <span className="text-xs font-mono text-gray-400 shrink-0">#{project.project_number}</span>
            {project.revision_count && project.revision_count > 0 && (
              <span className="inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded-full text-[10px] font-medium bg-red-100 text-red-700">
                <RotateCcw className="h-2.5 w-2.5" />
                Rev {project.revision_count}
              </span>
            )}
          </div>

          {(variant === "ready" || variant === "completed") && project.quoted_amount ? (
            <span className="text-sm font-semibold text-emerald-600 flex items-center shrink-0">
              <IndianRupee className="h-3.5 w-3.5" />
              {project.quoted_amount.toLocaleString("en-IN")}
            </span>
          ) : null}
        </div>

        {/* Subject + Title + Service Type */}
        <div>
          <p className="text-[11px] uppercase tracking-wide text-gray-400">{project.subject}</p>
          <h3 className="text-sm font-semibold text-[#1C1C1C] mt-1 line-clamp-2 leading-snug group-hover:text-orange-600 transition-colors">
            {project.title}
          </h3>
          <p className="text-xs text-gray-500 mt-0.5">
            {project.service_type.replace(/_/g, " ")}
          </p>
        </div>

        {/* Deadline band */}
        <div className={urgencyBand}>
          <div className="flex items-center justify-between gap-2 text-xs">
            <span className="flex items-center gap-1 min-w-0 truncate">
              <Calendar className="h-3.5 w-3.5 shrink-0" />
              {format(deadlineDate, "MMM d, h:mm a")}
            </span>
            {project.quoted_amount ? (
              <span className="flex items-center gap-0.5 font-semibold shrink-0">
                <IndianRupee className="h-3 w-3" />
                {project.quoted_amount.toLocaleString("en-IN")}
              </span>
            ) : null}
          </div>
        </div>

        {/* User info + due label */}
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-2 min-w-0">
            <Avatar className="h-7 w-7 shrink-0">
              <AvatarImage src="" alt={displayName} />
              <AvatarFallback className="bg-orange-100 text-orange-700 text-[10px]">
                {getInitials(displayName)}
              </AvatarFallback>
            </Avatar>
            <div className="min-w-0">
              <p className="text-sm font-medium text-gray-900 truncate">{displayName}</p>
              <p className="text-[11px] text-gray-500">{displayRole}</p>
            </div>
          </div>

          <div
            className={cn(
              "flex items-center gap-1 text-xs shrink-0",
              isCritical && "text-red-600 font-medium",
              isUrgent && !isCritical && "text-orange-600 font-medium",
              isOverdue && "text-red-700 font-semibold",
              !isCritical && !isUrgent && !isOverdue && "text-gray-500"
            )}
          >
            <Clock className="h-3.5 w-3.5" />
            <span className="whitespace-nowrap">{dueLabel}</span>
          </div>
        </div>

        {/* Commission row */}
        {(variant === "ongoing" || variant === "review" || variant === "completed") &&
          project.supervisor_commission ? (
            <div className="flex items-center justify-between py-1.5 px-2.5 rounded-lg border border-emerald-100 bg-emerald-50">
              <span className="text-xs text-gray-600">Commission</span>
              <span className="text-sm font-semibold text-emerald-600 flex items-center">
                <IndianRupee className="h-3.5 w-3.5" />
                {project.supervisor_commission.toLocaleString("en-IN")}
              </span>
            </div>
          ) : null}

        {/* Unread messages */}
        {project.has_unread_messages && (
          <div className="flex items-center gap-1.5 py-1.5 px-2.5 rounded-lg bg-blue-50 text-blue-700 text-xs font-medium">
            <MessageSquare className="h-3.5 w-3.5 shrink-0" />
            New messages
          </div>
        )}
      </div>

      <div className="border-t border-gray-100 px-4 py-3 bg-gray-50/40">
        <div className="flex items-center gap-2">
          {variant === "new" && (
            <Button
              className="flex-1 bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl text-sm"
              onClick={onClaim}
              disabled={isLoading}
            >
              <Zap className="h-4 w-4 mr-1 shrink-0" />
              <span className="truncate">Claim & Analyze</span>
            </Button>
          )}

          {variant === "ready" && (
            <>
              <Button
                variant="outline"
                className="flex-1 rounded-xl border-gray-200 hover:border-orange-300 hover:bg-orange-50"
                onClick={onAssign}
                disabled={isLoading}
              >
                <UserPlus className="h-4 w-4 mr-1.5" />
                Assign Doer
              </Button>
              <Button
                variant="ghost"
                size="icon"
                className="rounded-xl"
                asChild
              >
                <Link href={`/projects/${project.id}`}>
                  <Eye className="h-4 w-4" />
                </Link>
              </Button>
            </>
          )}

          {variant === "ongoing" && (
            <>
              <Button
                variant="outline"
                className="flex-1 rounded-xl border-gray-200"
                asChild
              >
                <Link href={`/projects/${project.id}`}>
                  <Eye className="h-4 w-4 mr-1.5" />
                  View
                </Link>
              </Button>
              <Button
                variant="outline"
                className={cn(
                  "flex-1 rounded-xl border-gray-200 relative",
                  project.has_unread_messages && "border-blue-300 bg-blue-50"
                )}
                asChild
              >
                <Link href={`/chat/${project.id}`}>
                  <MessageSquare className="h-4 w-4 mr-1.5" />
                  Chat
                  {project.has_unread_messages && (
                    <span className="absolute -top-1 -right-1 h-2.5 w-2.5 rounded-full bg-blue-500" />
                  )}
                </Link>
              </Button>
            </>
          )}

          {variant === "review" && (
            <>
              <Button
                className="flex-[1_1_0%] bg-emerald-500 hover:bg-emerald-600 text-white rounded-xl min-w-0"
                onClick={onApprove}
                disabled={isLoading}
              >
                Approve
              </Button>
              <Button
                variant="destructive"
                className="flex-[1_1_0%] rounded-xl min-w-0"
                onClick={onReject}
                disabled={isLoading}
              >
                Reject
              </Button>
              <Button
                variant="ghost"
                size="icon"
                className="rounded-xl shrink-0"
                asChild
              >
                <Link href={`/projects/${project.id}`}>
                  <Eye className="h-4 w-4" />
                </Link>
              </Button>
            </>
          )}

          {variant === "completed" && (
            <>
              <Button
                variant="outline"
                className="flex-[1.2_1_0%] rounded-xl border-gray-200 min-w-0"
                asChild
              >
                <Link href={`/projects/${project.id}`} className="flex items-center gap-1.5">
                  <Eye className="h-4 w-4 shrink-0" />
                  <span className="truncate">View Details</span>
                </Link>
              </Button>
              <Button
                variant="ghost"
                className="flex-[0.8_1_0%] rounded-xl min-w-0"
                asChild
              >
                <Link href={`/chat/${project.id}`} className="flex items-center gap-1.5">
                  <MessageSquare className="h-4 w-4 shrink-0" />
                  <span className="truncate">Chat</span>
                </Link>
              </Button>
            </>
          )}
        </div>
      </div>
    </motion.div>
  )
}

export default ProjectCardV2
