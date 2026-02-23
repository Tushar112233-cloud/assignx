/**
 * @fileoverview Modal for quality control review and approval of deliverables.
 * @module components/projects/qc-review-modal
 */

"use client"

import { useState } from "react"
import {
  CheckCircle2,
  XCircle,
  Send,
  FileText,
  AlertTriangle,
  Loader2,
} from "lucide-react"

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Checkbox } from "@/components/ui/checkbox"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import { ActiveProject } from "./types"

interface QCReviewModalProps {
  project: ActiveProject | null
  mode: "approve" | "reject" | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onApprove?: (projectId: string, message?: string) => Promise<void>
  onReject?: (
    projectId: string,
    feedback: string,
    severity: "minor" | "major" | "critical"
  ) => Promise<void>
}

const REVISION_REASONS = [
  "Plagiarism issues detected",
  "AI-generated content detected",
  "Grammar and spelling errors",
  "Does not meet requirements",
  "Incorrect formatting",
  "Missing sections or content",
  "Incorrect references/citations",
  "Quality below standard",
]

export function QCReviewModal({
  project,
  mode,
  open,
  onOpenChange,
  onApprove,
  onReject,
}: QCReviewModalProps) {
  const [isLoading, setIsLoading] = useState(false)
  const [approvalMessage, setApprovalMessage] = useState("")
  const [revisionFeedback, setRevisionFeedback] = useState("")
  const [severity, setSeverity] = useState<"minor" | "major" | "critical">(
    "minor"
  )
  const [selectedReasons, setSelectedReasons] = useState<string[]>([])
  const [confirmDelivery, setConfirmDelivery] = useState(false)

  const handleApprove = async () => {
    if (!project || !confirmDelivery) return
    setIsLoading(true)
    try {
      await onApprove?.(project.id, approvalMessage)
      onOpenChange(false)
      resetForm()
    } catch (error) {
      console.error("Failed to approve:", error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleReject = async () => {
    if (!project || !revisionFeedback.trim()) return
    setIsLoading(true)
    try {
      const fullFeedback = selectedReasons.length
        ? `Issues:\n${selectedReasons.map((r) => `- ${r}`).join("\n")}\n\nDetails:\n${revisionFeedback}`
        : revisionFeedback
      await onReject?.(project.id, fullFeedback, severity)
      onOpenChange(false)
      resetForm()
    } catch (error) {
      console.error("Failed to reject:", error)
    } finally {
      setIsLoading(false)
    }
  }

  const resetForm = () => {
    setApprovalMessage("")
    setRevisionFeedback("")
    setSeverity("minor")
    setSelectedReasons([])
    setConfirmDelivery(false)
  }

  const toggleReason = (reason: string) => {
    setSelectedReasons((prev) =>
      prev.includes(reason)
        ? prev.filter((r) => r !== reason)
        : [...prev, reason]
    )
  }

  if (!project) return null

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-lg p-0 overflow-hidden">
        {mode === "approve" ? (
          <>
            <DialogHeader className="p-6 pb-4">
              <DialogTitle className="flex items-center gap-2 text-green-600">
                <CheckCircle2 className="h-5 w-5" />
                Approve & Deliver
              </DialogTitle>
              <DialogDescription>
                Confirm that you have reviewed the deliverable and it meets
                quality standards.
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-6 px-6 pb-6">
              {/* Project Summary */}
              <div className="p-4 rounded-xl bg-muted/50 space-y-2">
                <div className="flex items-center gap-2">
                  <FileText className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm font-medium font-mono">
                    {project.project_number}
                  </span>
                </div>
                <p className="text-sm font-medium">{project.title}</p>
                <div className="flex items-center gap-4 text-xs text-muted-foreground">
                  <span>Client: {project.user_name}</span>
                  <span>Expert: {project.doer_name}</span>
                </div>
              </div>

              {/* Delivery Message */}
              <div className="space-y-2">
                <Label htmlFor="approval-message">
                  Message for Client (Optional)
                </Label>
                <Textarea
                  id="approval-message"
                  placeholder="Add a personal note to the client..."
                  value={approvalMessage}
                  onChange={(e) => setApprovalMessage(e.target.value)}
                  rows={3}
                  className="rounded-xl"
                />
              </div>

              {/* Confirmation */}
              <div className="flex items-start gap-3 p-4 rounded-xl border bg-green-50/50 dark:bg-green-950/20">
                <Checkbox
                  id="confirm-delivery"
                  checked={confirmDelivery}
                  onCheckedChange={(checked) =>
                    setConfirmDelivery(checked === true)
                  }
                  className="mt-0.5"
                />
                <div className="space-y-1">
                  <Label
                    htmlFor="confirm-delivery"
                    className="text-sm font-medium cursor-pointer"
                  >
                    I confirm this deliverable is ready
                  </Label>
                  <p className="text-xs text-muted-foreground">
                    The work will be sent to the client immediately upon
                    approval.
                  </p>
                </div>
              </div>

              {/* Commission Info */}
              <div className="flex items-center justify-between p-4 rounded-xl bg-primary/5">
                <span className="text-sm">Your commission on delivery:</span>
                <Badge className="bg-green-600 text-white">
                  ${project.supervisor_commission.toFixed(2)}
                </Badge>
              </div>
            </div>

            <DialogFooter className="p-6 pt-0 gap-3">
              <Button
                variant="outline"
                onClick={() => onOpenChange(false)}
                disabled={isLoading}
                className="rounded-xl"
              >
                Cancel
              </Button>
              <Button
                className="bg-green-600 hover:bg-green-700 rounded-xl"
                onClick={handleApprove}
                disabled={!confirmDelivery || isLoading}
              >
                {isLoading ? (
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                ) : (
                  <Send className="h-4 w-4 mr-2" />
                )}
                Deliver to Client
              </Button>
            </DialogFooter>
          </>
        ) : (
          <>
            <DialogHeader className="p-6 pb-4">
              <DialogTitle className="flex items-center gap-2 text-destructive">
                <XCircle className="h-5 w-5" />
                Request Revision
              </DialogTitle>
              <DialogDescription>
                Provide feedback for the expert to improve the deliverable.
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-6 px-6 pb-6">
              {/* Project Summary */}
              <div className="p-4 rounded-xl bg-muted/50 space-y-2">
                <div className="flex items-center gap-2">
                  <FileText className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm font-medium font-mono">
                    {project.project_number}
                  </span>
                </div>
                <p className="text-sm font-medium">{project.title}</p>
                {project.revision_count && project.revision_count > 0 && (
                  <Badge variant="destructive" className="text-xs">
                    Revision #{project.revision_count + 1}
                  </Badge>
                )}
              </div>

              {/* Severity */}
              <div className="space-y-3">
                <Label>Revision Severity</Label>
                <RadioGroup
                  value={severity}
                  onValueChange={(v) =>
                    setSeverity(v as "minor" | "major" | "critical")
                  }
                  className="flex gap-6"
                >
                  <div className="flex items-center gap-2">
                    <RadioGroupItem value="minor" id="minor" />
                    <Label
                      htmlFor="minor"
                      className="text-sm cursor-pointer text-amber-600 font-medium"
                    >
                      Minor
                    </Label>
                  </div>
                  <div className="flex items-center gap-2">
                    <RadioGroupItem value="major" id="major" />
                    <Label
                      htmlFor="major"
                      className="text-sm cursor-pointer text-orange-600 font-medium"
                    >
                      Major
                    </Label>
                  </div>
                  <div className="flex items-center gap-2">
                    <RadioGroupItem value="critical" id="critical" />
                    <Label
                      htmlFor="critical"
                      className="text-sm cursor-pointer text-red-600 font-medium"
                    >
                      Critical
                    </Label>
                  </div>
                </RadioGroup>
              </div>

              {/* Quick Reasons */}
              <div className="space-y-3">
                <Label>Common Issues (Select all that apply)</Label>
                <div className="flex flex-wrap gap-2">
                  {REVISION_REASONS.map((reason) => (
                    <Badge
                      key={reason}
                      variant={
                        selectedReasons.includes(reason)
                          ? "default"
                          : "outline"
                      }
                      className={cn(
                        "cursor-pointer transition-colors",
                        selectedReasons.includes(reason)
                          ? "bg-destructive hover:bg-destructive/90"
                          : "hover:bg-destructive/10"
                      )}
                      onClick={() => toggleReason(reason)}
                    >
                      {reason}
                    </Badge>
                  ))}
                </div>
              </div>

              {/* Detailed Feedback */}
              <div className="space-y-2">
                <Label htmlFor="revision-feedback">
                  Detailed Feedback <span className="text-destructive">*</span>
                </Label>
                <Textarea
                  id="revision-feedback"
                  placeholder="Describe what needs to be fixed and how..."
                  value={revisionFeedback}
                  onChange={(e) => setRevisionFeedback(e.target.value)}
                  rows={4}
                  required
                  className="rounded-xl"
                />
                <p className="text-xs text-muted-foreground">
                  Be specific about what needs to change for approval.
                </p>
              </div>

              {/* Warning */}
              <div className="flex items-start gap-3 p-4 rounded-xl bg-amber-50 dark:bg-amber-950/20 text-amber-800 dark:text-amber-200">
                <AlertTriangle className="h-4 w-4 shrink-0 mt-0.5" />
                <p className="text-xs">
                  The expert will be notified immediately and must resubmit
                  within the original deadline.
                </p>
              </div>
            </div>

            <DialogFooter className="p-6 pt-0 gap-3">
              <Button
                variant="outline"
                onClick={() => onOpenChange(false)}
                disabled={isLoading}
                className="rounded-xl"
              >
                Cancel
              </Button>
              <Button
                variant="destructive"
                onClick={handleReject}
                disabled={!revisionFeedback.trim() || isLoading}
                className="rounded-xl"
              >
                {isLoading ? (
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                ) : (
                  <XCircle className="h-4 w-4 mr-2" />
                )}
                Send Revision Request
              </Button>
            </DialogFooter>
          </>
        )}
      </DialogContent>
    </Dialog>
  )
}
