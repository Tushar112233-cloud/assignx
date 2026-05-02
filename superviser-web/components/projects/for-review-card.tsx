/**
 * @fileoverview Card for projects awaiting quality control review.
 * @module components/projects/for-review-card
 */

"use client"

import { useState } from "react"
import { format, formatDistanceToNow } from "date-fns"
import {
  FileText,
  Download,
  Eye,
  CheckCircle2,
  XCircle,
  Clock,
  AlertCircle,
  User,
  BarChart3,
  Shield,
} from "lucide-react"

import { Card, CardContent, CardHeader } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"
import { ActiveProject, ProjectFile, QCReport, STATUS_CONFIG } from "./types"

interface ForReviewCardProps {
  project: ActiveProject
  files?: ProjectFile[]
  qcReport?: QCReport
  onApprove?: (projectId: string) => void
  onReject?: (projectId: string) => void
  onPreviewFile?: (file: ProjectFile) => void
  onDownloadFile?: (file: ProjectFile) => void
  onRunQC?: (projectId: string) => void
}

function QualityIndicator({
  label,
  score,
  icon: Icon,
}: {
  label: string
  score?: number
  icon: React.ComponentType<{ className?: string }>
}) {
  if (score === undefined) return null

  const getColor = (s: number) => {
    if (s >= 90) return "text-green-600"
    if (s >= 70) return "text-amber-600"
    return "text-red-600"
  }

  const getBgColor = (s: number) => {
    if (s >= 90) return "bg-green-500"
    if (s >= 70) return "bg-amber-500"
    return "bg-red-500"
  }

  return (
    <div className="flex items-center gap-2">
      <Icon className={cn("h-4 w-4", getColor(score))} />
      <div className="flex-1">
        <div className="flex items-center justify-between mb-1">
          <span className="text-xs text-muted-foreground">{label}</span>
          <span className={cn("text-xs font-medium", getColor(score))}>
            {score}%
          </span>
        </div>
        <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden">
          <div
            className={cn("h-full transition-all rounded-full", getBgColor(score))}
            style={{ width: `${score}%` }}
          />
        </div>
      </div>
    </div>
  )
}

export function ForReviewCard({
  project,
  files = [],
  qcReport,
  onApprove,
  onReject,
  onPreviewFile,
  onDownloadFile,
  onRunQC,
}: ForReviewCardProps) {
  const [isExpanded, setIsExpanded] = useState(false)
  const statusConfig = STATUS_CONFIG[project.status]
  const doerFiles = files.filter((f) => f.uploaded_by === "doer")

  const getQualityBadge = () => {
    if (!qcReport?.overall_quality) return null
    const config = {
      excellent: {
        label: "Excellent Quality",
        className: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400",
      },
      good: {
        label: "Good Quality",
        className: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
      },
      acceptable: {
        label: "Acceptable",
        className: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400",
      },
      needs_revision: {
        label: "Needs Revision",
        className: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400",
      },
    }
    const { label, className } = config[qcReport.overall_quality]
    return (
      <Badge variant="outline" className={className}>
        {label}
      </Badge>
    )
  }

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
                {statusConfig.label}
              </Badge>
              {getQualityBadge()}
            </div>
            <h3 className="font-semibold text-base leading-tight line-clamp-1">
              {project.title}
            </h3>
          </div>
          {project.submitted_for_qc_at && (
            <div className="text-xs text-muted-foreground flex items-center gap-1.5 bg-muted/50 px-3 py-1.5 rounded-lg">
              <Clock className="h-3.5 w-3.5" />
              Submitted{" "}
              {formatDistanceToNow(new Date(project.submitted_for_qc_at), {
                addSuffix: true,
              })}
            </div>
          )}
        </div>
      </CardHeader>

      <CardContent className="pt-0 space-y-5">
        {/* Project Meta */}
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <span>{project.subject}</span>
          <span className="text-border">|</span>
          <span>{project.service_type}</span>
          {project.word_count && (
            <>
              <span className="text-border">|</span>
              <span>{project.word_count.toLocaleString()} words</span>
            </>
          )}
        </div>

        {/* Doer Info */}
        {project.doer_name && (
          <div className="flex items-center gap-3 p-4 rounded-xl bg-muted/50">
            <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center">
              <User className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="text-sm font-medium">{project.doer_name}</p>
              <p className="text-xs text-muted-foreground">Expert Submission</p>
            </div>
          </div>
        )}

        {/* Deliverable Files */}
        {doerFiles.length > 0 && (
          <div className="space-y-3">
            <p className="text-sm font-medium">Deliverable Files</p>
            <div className="space-y-2">
              {doerFiles.map((file) => (
                <div
                  key={file.id}
                  className="flex items-center justify-between p-3 rounded-xl bg-muted/30 hover:bg-muted/50 transition-colors"
                >
                  <div className="flex items-center gap-2 min-w-0">
                    <FileText className="h-4 w-4 text-muted-foreground shrink-0" />
                    <span className="text-sm truncate">{file.name}</span>
                    <span className="text-xs text-muted-foreground">
                      ({(file.size / 1024).toFixed(1)} KB)
                    </span>
                  </div>
                  <div className="flex items-center gap-1">
                    <TooltipProvider>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="h-8 w-8"
                            onClick={() => onPreviewFile?.(file)}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                        </TooltipTrigger>
                        <TooltipContent>Preview</TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                    <TooltipProvider>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="h-8 w-8"
                            onClick={() => onDownloadFile?.(file)}
                          >
                            <Download className="h-4 w-4" />
                          </Button>
                        </TooltipTrigger>
                        <TooltipContent>Download</TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* QC Report */}
        {qcReport && (
          <div className="space-y-3 p-4 rounded-xl bg-muted/30">
            <div className="flex items-center justify-between">
              <p className="text-sm font-medium flex items-center gap-2">
                <Shield className="h-4 w-4" />
                Quality Check Report
              </p>
              {qcReport.checked_at && (
                <span className="text-xs text-muted-foreground">
                  {format(new Date(qcReport.checked_at), "MMM d, h:mm a")}
                </span>
              )}
            </div>
            <div className="grid grid-cols-2 gap-4">
              <QualityIndicator
                label="Plagiarism Free"
                score={
                  qcReport.plagiarism_score !== undefined
                    ? 100 - qcReport.plagiarism_score
                    : undefined
                }
                icon={BarChart3}
              />
              <QualityIndicator
                label="Human Written"
                score={
                  qcReport.ai_score !== undefined
                    ? 100 - qcReport.ai_score
                    : undefined
                }
                icon={Shield}
              />
              <QualityIndicator
                label="Grammar"
                score={qcReport.grammar_score}
                icon={FileText}
              />
              <QualityIndicator
                label="Formatting"
                score={qcReport.formatting_score}
                icon={FileText}
              />
            </div>
            {qcReport.notes && (
              <p className="text-xs text-muted-foreground italic pt-2 border-t">
                {qcReport.notes}
              </p>
            )}
          </div>
        )}

        {/* Run QC Button if no report */}
        {!qcReport && (
          <Button
            variant="outline"
            className="w-full rounded-xl"
            onClick={() => onRunQC?.(project.id)}
          >
            <Shield className="h-4 w-4 mr-2" />
            Run Quality Check
          </Button>
        )}

        {/* Actions */}
        <div className="flex items-center gap-3 pt-4 mt-4 border-t">
          <Button
            variant="destructive"
            size="default"
            className="flex-1"
            onClick={() => onReject?.(project.id)}
          >
            <XCircle className="h-4 w-4 mr-1.5" />
            Reject & Revise
          </Button>
          <Button
            size="default"
            className="flex-1 bg-green-600 hover:bg-green-700"
            onClick={() => onApprove?.(project.id)}
          >
            <CheckCircle2 className="h-4 w-4 mr-1.5" />
            Approve & Deliver
          </Button>
        </div>

        {/* Commission Info */}
        <div className="flex items-center justify-between text-sm p-3 rounded-xl bg-green-50 dark:bg-green-950/20">
          <span className="text-muted-foreground">Your commission:</span>
          <span className="font-semibold text-green-600">
            ${project.supervisor_commission.toFixed(2)}
          </span>
        </div>
      </CardContent>
    </Card>
  )
}
