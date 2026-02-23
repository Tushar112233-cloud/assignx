"use client"

import { useState, useCallback } from "react"
import { Check, X, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"
import { toast } from "sonner"
import { createClient } from "@/lib/supabase/client"

/**
 * Props for SupervisorMessageActions component
 */
interface SupervisorMessageActionsProps {
  /** The message ID to act upon */
  messageId: string
  /** The supervisor's profile ID */
  supervisorId: string
  /** Callback when message is approved */
  onApprove?: (messageId: string) => void
  /** Callback when message is rejected */
  onReject?: (messageId: string, reason: string) => void
  /** Additional CSS classes */
  className?: string
  /** Whether actions are disabled */
  disabled?: boolean
}

/**
 * SupervisorMessageActions component
 *
 * Provides approve and reject buttons for supervisors to moderate messages.
 * Includes a dialog for entering rejection reasons.
 *
 * @example
 * ```tsx
 * <SupervisorMessageActions
 *   messageId="msg-123"
 *   supervisorId="sup-456"
 *   onApprove={(id) => console.log("Approved:", id)}
 *   onReject={(id, reason) => console.log("Rejected:", id, reason)}
 * />
 * ```
 */
export function SupervisorMessageActions({
  messageId,
  supervisorId,
  onApprove,
  onReject,
  className,
  disabled = false,
}: SupervisorMessageActionsProps) {
  const [isApproving, setIsApproving] = useState(false)
  const [isRejecting, setIsRejecting] = useState(false)
  const [showRejectDialog, setShowRejectDialog] = useState(false)
  const [rejectReason, setRejectReason] = useState("")

  const supabase = createClient()

  /**
   * Handle message approval
   */
  const handleApprove = useCallback(async () => {
    if (disabled || isApproving) return

    setIsApproving(true)

    try {
      const { error } = await supabase
        .from("chat_messages")
        .update({
          approval_status: "approved",
          approved_by: supervisorId,
          approved_at: new Date().toISOString(),
        })
        .eq("id", messageId)

      if (error) throw error

      toast.success("Message approved")
      onApprove?.(messageId)
    } catch (error: any) {
      console.error("Failed to approve message:", error)
      toast.error(error.message || "Failed to approve message")
    } finally {
      setIsApproving(false)
    }
  }, [messageId, supervisorId, disabled, isApproving, onApprove, supabase])

  /**
   * Handle message rejection
   */
  const handleReject = useCallback(async () => {
    if (disabled || isRejecting || !rejectReason.trim()) return

    setIsRejecting(true)

    try {
      const { error } = await supabase
        .from("chat_messages")
        .update({
          approval_status: "rejected",
          approved_by: supervisorId,
          approved_at: new Date().toISOString(),
          rejection_reason: rejectReason.trim(),
        })
        .eq("id", messageId)

      if (error) throw error

      toast.success("Message rejected")
      onReject?.(messageId, rejectReason.trim())
      setShowRejectDialog(false)
      setRejectReason("")
    } catch (error: any) {
      console.error("Failed to reject message:", error)
      toast.error(error.message || "Failed to reject message")
    } finally {
      setIsRejecting(false)
    }
  }, [messageId, supervisorId, rejectReason, disabled, isRejecting, onReject, supabase])

  /**
   * Open rejection dialog
   */
  const openRejectDialog = useCallback(() => {
    setShowRejectDialog(true)
  }, [])

  /**
   * Close rejection dialog and reset state
   */
  const closeRejectDialog = useCallback(() => {
    setShowRejectDialog(false)
    setRejectReason("")
  }, [])

  return (
    <>
      <div className={cn("flex items-center gap-1", className)}>
        {/* Approve Button */}
        <Tooltip>
          <TooltipTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className={cn(
                "h-6 w-6 rounded-full",
                "bg-emerald-100 hover:bg-emerald-200 dark:bg-emerald-900/30 dark:hover:bg-emerald-900/50",
                "text-emerald-600 dark:text-emerald-400"
              )}
              onClick={handleApprove}
              disabled={disabled || isApproving}
              aria-label="Approve message"
            >
              {isApproving ? (
                <Loader2 className="h-3.5 w-3.5 animate-spin" />
              ) : (
                <Check className="h-3.5 w-3.5" />
              )}
            </Button>
          </TooltipTrigger>
          <TooltipContent side="top">
            <p>Approve message</p>
          </TooltipContent>
        </Tooltip>

        {/* Reject Button */}
        <Tooltip>
          <TooltipTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className={cn(
                "h-6 w-6 rounded-full",
                "bg-red-100 hover:bg-red-200 dark:bg-red-900/30 dark:hover:bg-red-900/50",
                "text-red-600 dark:text-red-400"
              )}
              onClick={openRejectDialog}
              disabled={disabled || isRejecting}
              aria-label="Reject message"
            >
              <X className="h-3.5 w-3.5" />
            </Button>
          </TooltipTrigger>
          <TooltipContent side="top">
            <p>Reject message</p>
          </TooltipContent>
        </Tooltip>
      </div>

      {/* Rejection Reason Dialog */}
      <Dialog open={showRejectDialog} onOpenChange={setShowRejectDialog}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Reject Message</DialogTitle>
            <DialogDescription>
              Please provide a reason for rejecting this message. The sender
              will be notified of this decision.
            </DialogDescription>
          </DialogHeader>

          <div className="py-4">
            <Textarea
              placeholder="Enter rejection reason..."
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              className="min-h-[100px] resize-none"
              maxLength={500}
            />
            <p className="mt-1 text-right text-xs text-muted-foreground">
              {rejectReason.length}/500
            </p>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              variant="outline"
              onClick={closeRejectDialog}
              disabled={isRejecting}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleReject}
              disabled={isRejecting || !rejectReason.trim()}
            >
              {isRejecting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Rejecting...
                </>
              ) : (
                "Reject Message"
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  )
}

/**
 * SupervisorMessageActionsCompact component
 *
 * Compact version for inline use within message bubbles.
 * Shows actions as small icons without labels.
 */
export function SupervisorMessageActionsCompact({
  messageId,
  supervisorId,
  onApprove,
  onReject,
  className,
  disabled = false,
}: SupervisorMessageActionsProps) {
  const [isApproving, setIsApproving] = useState(false)
  const [isRejecting, setIsRejecting] = useState(false)
  const [showRejectDialog, setShowRejectDialog] = useState(false)
  const [rejectReason, setRejectReason] = useState("")

  const supabase = createClient()

  const handleApprove = async () => {
    if (disabled || isApproving) return
    setIsApproving(true)

    try {
      const { error } = await supabase
        .from("chat_messages")
        .update({
          approval_status: "approved",
          approved_by: supervisorId,
          approved_at: new Date().toISOString(),
        })
        .eq("id", messageId)

      if (error) throw error
      toast.success("Message approved")
      onApprove?.(messageId)
    } catch (error: any) {
      toast.error(error.message || "Failed to approve")
    } finally {
      setIsApproving(false)
    }
  }

  const handleReject = async () => {
    if (disabled || isRejecting || !rejectReason.trim()) return
    setIsRejecting(true)

    try {
      const { error } = await supabase
        .from("chat_messages")
        .update({
          approval_status: "rejected",
          approved_by: supervisorId,
          approved_at: new Date().toISOString(),
          rejection_reason: rejectReason.trim(),
        })
        .eq("id", messageId)

      if (error) throw error
      toast.success("Message rejected")
      onReject?.(messageId, rejectReason.trim())
      setShowRejectDialog(false)
      setRejectReason("")
    } catch (error: any) {
      toast.error(error.message || "Failed to reject")
    } finally {
      setIsRejecting(false)
    }
  }

  return (
    <>
      <div className={cn("flex items-center gap-0.5", className)}>
        <button
          type="button"
          onClick={handleApprove}
          disabled={disabled || isApproving}
          className={cn(
            "rounded p-0.5 transition-colors",
            "text-emerald-600 hover:bg-emerald-100 dark:text-emerald-400 dark:hover:bg-emerald-900/30",
            "disabled:opacity-50 disabled:cursor-not-allowed"
          )}
          aria-label="Approve"
        >
          {isApproving ? (
            <Loader2 className="h-3 w-3 animate-spin" />
          ) : (
            <Check className="h-3 w-3" />
          )}
        </button>
        <button
          type="button"
          onClick={() => setShowRejectDialog(true)}
          disabled={disabled}
          className={cn(
            "rounded p-0.5 transition-colors",
            "text-red-600 hover:bg-red-100 dark:text-red-400 dark:hover:bg-red-900/30",
            "disabled:opacity-50 disabled:cursor-not-allowed"
          )}
          aria-label="Reject"
        >
          <X className="h-3 w-3" />
        </button>
      </div>

      <Dialog open={showRejectDialog} onOpenChange={setShowRejectDialog}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Reject Message</DialogTitle>
            <DialogDescription>
              Provide a reason for rejection.
            </DialogDescription>
          </DialogHeader>
          <Textarea
            placeholder="Rejection reason..."
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
            className="min-h-[80px]"
            maxLength={500}
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowRejectDialog(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleReject}
              disabled={isRejecting || !rejectReason.trim()}
            >
              {isRejecting ? "Rejecting..." : "Reject"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  )
}

export default SupervisorMessageActions
