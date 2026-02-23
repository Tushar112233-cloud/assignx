"use client";

import * as React from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { replyToTicket } from "@/lib/admin/actions/support";
import { toast } from "sonner";

export function TicketReplyForm({ ticketId }: { ticketId: string }) {
  const router = useRouter();
  const [message, setMessage] = React.useState("");
  const [isInternal, setIsInternal] = React.useState(false);
  const [sending, setSending] = React.useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!message.trim()) {
      toast.error("Please enter a message");
      return;
    }

    setSending(true);
    try {
      await replyToTicket(ticketId, message.trim(), isInternal);
      toast.success(isInternal ? "Internal note added" : "Reply sent");
      setMessage("");
      setIsInternal(false);
      router.refresh();
    } catch (err) {
      toast.error(
        err instanceof Error ? err.message : "Failed to send reply"
      );
    } finally {
      setSending(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3">
      <Textarea
        placeholder="Type your reply..."
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        rows={4}
      />
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Checkbox
            id="internal-note"
            checked={isInternal}
            onCheckedChange={(checked) => setIsInternal(checked === true)}
          />
          <Label htmlFor="internal-note" className="text-sm">
            Internal note (not visible to requester)
          </Label>
        </div>
        <Button type="submit" disabled={sending}>
          {sending ? "Sending..." : isInternal ? "Add Note" : "Send Reply"}
        </Button>
      </div>
    </form>
  );
}
