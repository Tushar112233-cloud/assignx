"use client";

import { useState } from "react";
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

export function ExpertVerificationDialog({
  open,
  onOpenChange,
  action,
  onConfirm,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  action: "verify" | "reject";
  onConfirm: (action: "verify" | "reject", notes?: string) => Promise<void>;
}) {
  const [notes, setNotes] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleConfirm() {
    setLoading(true);
    try {
      await onConfirm(action, notes);
      onOpenChange(false);
      setNotes("");
    } finally {
      setLoading(false);
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {action === "verify" ? "Verify Expert" : "Reject Expert"}
          </DialogTitle>
          <DialogDescription>
            {action === "verify"
              ? "Confirm that this expert meets verification requirements."
              : "Provide a reason for rejecting this expert application."}
          </DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-2">
          <Label htmlFor="notes">
            {action === "verify" ? "Notes (optional)" : "Reason"}
          </Label>
          <Textarea
            id="notes"
            placeholder={
              action === "verify"
                ? "Add any verification notes..."
                : "Provide a reason for rejection..."
            }
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
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
            variant={action === "reject" ? "destructive" : "default"}
            onClick={handleConfirm}
            disabled={loading || (action === "reject" && !notes.trim())}
          >
            {loading
              ? "Processing..."
              : action === "verify"
                ? "Verify"
                : "Reject"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
