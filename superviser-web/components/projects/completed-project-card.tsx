/**
 * @fileoverview Card displaying completed project summary and details.
 * @module components/projects/completed-project-card
 */

"use client"

import { format } from "date-fns"
import {
  CheckCircle2,
  Star,
  FileText,
  Clock,
  User,
  DollarSign,
  Eye,
  RotateCcw,
  MessageSquare,
  CalendarCheck,
} from "lucide-react"
import Link from "next/link"

import { Card, CardContent, CardHeader } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible"
import { cn } from "@/lib/utils"
import { ActiveProject, STATUS_CONFIG } from "./types"

interface CompletedProjectCardProps {
  project: ActiveProject
  rating?: number
  feedback?: string
  onViewDetails?: (projectId: string) => void
  onViewChat?: (projectId: string) => void
}

function TimelineItem({
  label,
  date,
  icon: Icon,
  isLast = false,
}: {
  label: string
  date?: string
  icon: React.ComponentType<{ className?: string }>
  isLast?: boolean
}) {
  if (!date) return null
  return (
    <div className="flex items-start gap-3">
      <div className="flex flex-col items-center">
        <div className="h-6 w-6 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
          <Icon className="h-3.5 w-3.5 text-primary" />
        </div>
        {!isLast && <div className="w-px h-full bg-border flex-1 min-h-[1rem]" />}
      </div>
      <div className="pb-3">
        <p className="text-sm font-medium">{label}</p>
        <p className="text-xs text-muted-foreground">
          {format(new Date(date), "MMM d, yyyy 'at' h:mm a")}
        </p>
      </div>
    </div>
  )
}

function StarRating({ rating }: { rating: number }) {
  return (
    <div className="flex items-center gap-1 bg-amber-50 dark:bg-amber-950/30 px-3 py-1.5 rounded-lg">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={cn(
            "h-4 w-4",
            star <= rating
              ? "fill-amber-400 text-amber-400"
              : "text-muted-foreground/30"
          )}
        />
      ))}
      <span className="ml-1.5 text-sm font-semibold text-amber-700 dark:text-amber-400">
        {rating.toFixed(1)}
      </span>
    </div>
  )
}

export function CompletedProjectCard({
  project,
  rating,
  feedback,
  onViewDetails,
  onViewChat,
}: CompletedProjectCardProps) {
  const statusConfig = STATUS_CONFIG[project.status]

  return (
    <Card className="group rounded-xl transition-all duration-200 hover:shadow-lg hover:border-primary/30">
      <CardHeader className="pb-4">
        <div className="flex items-start justify-between gap-4">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1.5 flex-wrap">
              <span className="text-xs font-medium bg-muted px-2 py-0.5 rounded font-mono">
                {project.project_number}
              </span>
              <Badge
                variant="outline"
                className={cn(
                  "text-xs",
                  statusConfig.bgColor,
                  statusConfig.color
                )}
              >
                <CheckCircle2 className="h-3 w-3 mr-1" />
                {statusConfig.label}
              </Badge>
              {project.revision_count && project.revision_count > 0 && (
                <Badge variant="secondary" className="text-xs">
                  <RotateCcw className="h-3 w-3 mr-1" />
                  {project.revision_count} revision
                  {project.revision_count > 1 ? "s" : ""}
                </Badge>
              )}
            </div>
            <h3 className="font-semibold text-base leading-tight line-clamp-1">
              {project.title}
            </h3>
          </div>
          {rating && <StarRating rating={rating} />}
        </div>
      </CardHeader>

      <CardContent className="pt-0 space-y-5">
        {/* Project Meta */}
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <span>{project.subject}</span>
          <span className="text-border">|</span>
          <span>{project.service_type}</span>
        </div>

        {/* Completed Date - Prominent Display */}
        {project.completed_at && (
          <div className="flex items-center gap-2 p-3 rounded-xl bg-green-50 dark:bg-green-950/20">
            <CalendarCheck className="h-4 w-4 text-green-600" />
            <div>
              <p className="text-xs text-muted-foreground">Completed</p>
              <p className="text-sm font-medium text-green-700 dark:text-green-400">
                {format(new Date(project.completed_at), "MMMM d, yyyy 'at' h:mm a")}
              </p>
            </div>
          </div>
        )}

        {/* Participants */}
        <div className="grid grid-cols-2 gap-3">
          <div className="flex items-center gap-3 p-3 rounded-xl bg-muted/50">
            <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
              <User className="h-4 w-4 text-primary" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Client</p>
              <p className="text-sm font-medium">{project.user_name}</p>
            </div>
          </div>
          <div className="flex items-center gap-3 p-3 rounded-xl bg-muted/50">
            <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
              <User className="h-4 w-4 text-primary" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Expert</p>
              <p className="text-sm font-medium">
                {project.doer_name || "N/A"}
              </p>
            </div>
          </div>
        </div>

        {/* Client Feedback */}
        {feedback && (
          <div className="p-4 rounded-xl bg-muted/30 border-l-4 border-primary">
            <p className="text-xs text-muted-foreground mb-1.5 font-medium">
              Client Feedback
            </p>
            <p className="text-sm italic text-foreground/80">&ldquo;{feedback}&rdquo;</p>
          </div>
        )}

        {/* Timeline Collapsible */}
        <Collapsible>
          <CollapsibleTrigger asChild>
            <Button variant="ghost" size="sm" className="w-full justify-start rounded-xl">
              <Clock className="h-4 w-4 mr-2" />
              View Project Timeline
            </Button>
          </CollapsibleTrigger>
          <CollapsibleContent className="pt-4">
            <div className="pl-2 border-l-2 border-muted ml-3">
              <TimelineItem
                label="Project Submitted"
                date={project.created_at}
                icon={FileText}
              />
              <TimelineItem
                label="Assigned to Expert"
                date={project.assigned_at}
                icon={User}
              />
              <TimelineItem
                label="Submitted for Review"
                date={project.submitted_for_qc_at}
                icon={FileText}
              />
              <TimelineItem
                label="Delivered to Client"
                date={project.delivered_at}
                icon={CheckCircle2}
              />
              <TimelineItem
                label="Project Completed"
                date={project.completed_at}
                icon={CheckCircle2}
                isLast
              />
            </div>
          </CollapsibleContent>
        </Collapsible>

        {/* Earnings */}
        <div className="flex items-center justify-between p-4 rounded-xl bg-green-50 dark:bg-green-950/20">
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-full bg-green-100 dark:bg-green-900/50 flex items-center justify-center">
              <DollarSign className="h-4 w-4 text-green-600" />
            </div>
            <span className="text-sm font-medium">Commission Earned</span>
          </div>
          <span className="font-bold text-lg text-green-600">
            ${project.supervisor_commission.toFixed(2)}
          </span>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-3 pt-4 mt-4 border-t">
          <Button
            variant="outline"
            size="sm"
            onClick={() => onViewChat?.(project.id)}
            asChild
          >
            <Link href={`/chat/${project.id}`}>
              <MessageSquare className="h-4 w-4 mr-1.5" />
              View Chat
            </Link>
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className="ml-auto group-hover:bg-primary group-hover:text-primary-foreground transition-colors"
            onClick={() => onViewDetails?.(project.id)}
            asChild
          >
            <Link href={`/projects/${project.id}`}>
              <Eye className="h-4 w-4 mr-1.5" />
              View Details
            </Link>
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
