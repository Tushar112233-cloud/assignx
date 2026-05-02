"use client";

import * as React from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { processRefund } from "@/lib/admin/actions/wallets";
import { toast } from "sonner";

export function RefundDialog({
  projectId,
  maxAmount,
  children,
}: {
  projectId: string;
  maxAmount?: number;
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [open, setOpen] = React.useState(false);
  const [amount, setAmount] = React.useState("");
  const [reason, setReason] = React.useState("");
  const [processing, setProcessing] = React.useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const numAmount = parseFloat(amount);
    if (isNaN(numAmount) || numAmount <= 0) {
      toast.error("Please enter a valid amount");
      return;
    }
    if (maxAmount && numAmount > maxAmount) {
      toast.error(`Amount cannot exceed ${maxAmount}`);
      return;
    }
    if (!reason.trim()) {
      toast.error("Please provide a reason for the refund");
      return;
    }

    setProcessing(true);
    try {
      await processRefund(projectId, numAmount, reason.trim());
      toast.success("Refund processed successfully");
      setOpen(false);
      setAmount("");
      setReason("");
      router.refresh();
    } catch (err) {
      toast.error(
        err instanceof Error ? err.message : "Failed to process refund"
      );
    } finally {
      setProcessing(false);
    }
  }

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>{children}</SheetTrigger>
      <SheetContent>
        <SheetHeader>
          <SheetTitle>Process Refund</SheetTitle>
          <SheetDescription>
            Issue a refund for project {projectId.slice(0, 8)}...
          </SheetDescription>
        </SheetHeader>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4 px-4 pt-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="refund-amount">
              Amount (INR){maxAmount ? ` - Max: ${maxAmount}` : ""}
            </Label>
            <Input
              id="refund-amount"
              type="number"
              step="0.01"
              min="0"
              max={maxAmount}
              placeholder="Enter refund amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              required
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="refund-reason">Reason</Label>
            <Textarea
              id="refund-reason"
              placeholder="Explain the reason for this refund"
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              rows={4}
              required
            />
          </div>
          <Button type="submit" disabled={processing}>
            {processing ? "Processing..." : "Process Refund"}
          </Button>
        </form>
      </SheetContent>
    </Sheet>
  );
}
