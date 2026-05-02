"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { moderateContent } from "@/lib/admin/actions/moderation";
import { toast } from "sonner";

const actionLabels: Record<string, { title: string; description: string; confirmLabel: string; variant: "default" | "destructive" }> = {
  approve: {
    title: "Approve Content",
    description: "This will remove the flagged status and the content will remain visible.",
    confirmLabel: "Approve",
    variant: "default",
  },
  remove: {
    title: "Remove Content",
    description: "This will permanently delete the content. This action cannot be undone.",
    confirmLabel: "Remove",
    variant: "destructive",
  },
  warn: {
    title: "Warn User",
    description: "This will approve the content but send a warning to the user.",
    confirmLabel: "Warn & Approve",
    variant: "default",
  },
};

export function ModerationActionDialog({
  open,
  onOpenChange,
  contentType,
  contentId,
  action,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  contentType: string;
  contentId: string;
  action: string;
}) {
  const router = useRouter();
  const [reason, setReason] = useState("");
  const [loading, setLoading] = useState(false);

  const config = actionLabels[action] || actionLabels.approve;

  async function handleConfirm() {
    if (!reason.trim()) {
      toast.error("Please provide a reason");
      return;
    }

    setLoading(true);
    try {
      await moderateContent(contentType, contentId, action, reason);
      toast.success(`Content ${action === "remove" ? "removed" : "moderated"} successfully`);
      onOpenChange(false);
      setReason("");
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Action failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{config.title}</DialogTitle>
          <DialogDescription>{config.description}</DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-2">
          <Label htmlFor="reason">Reason</Label>
          <Textarea
            id="reason"
            placeholder="Provide a reason for this action..."
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            rows={3}
          />
        </div>
        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => onOpenChange(false)}
            disabled={loading}
          >
            Cancel
          </Button>
          <Button
            variant={config.variant}
            onClick={handleConfirm}
            disabled={loading}
          >
            {loading ? "Processing..." : config.confirmLabel}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
