"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { IconCheck, IconTrash, IconAlertTriangle } from "@tabler/icons-react";
import { ModerationActionDialog } from "./moderation-action-dialog";

type FlaggedItem = {
  id: string;
  content: string;
  content_type: string;
  is_flagged: boolean;
  created_at: string;
  author_id?: string;
  seller_id?: string;
  author_name?: string | null;
  author_email?: string | null;
};

const contentTypeLabels: Record<string, string> = {
  campus_post: "Campus Post",
  listing: "Marketplace Listing",
  chat: "Chat Message",
};

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function ContentReviewCard({ item }: { item: FlaggedItem }) {
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    action: string;
  }>({ open: false, action: "" });

  const authorName = item.author_name || "Unknown User";
  const authorEmail = item.author_email || "";

  return (
    <>
      <Card>
        <CardHeader className="pb-3">
          <div className="flex items-start justify-between">
            <div className="flex flex-col gap-1">
              <div className="flex items-center gap-2">
                <Badge
                  variant="outline"
                  className="text-orange-600 border-orange-200 bg-orange-50 dark:bg-orange-900/20"
                >
                  {contentTypeLabels[item.content_type] || item.content_type}
                </Badge>
                <Badge variant="destructive">Flagged</Badge>
              </div>
              <CardTitle className="text-sm font-normal text-muted-foreground">
                By {authorName}
                {authorEmail && ` (${authorEmail})`} &middot;{" "}
                {formatDate(item.created_at)}
              </CardTitle>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <p className="mb-4 rounded-md bg-muted p-3 text-sm leading-relaxed">
            {item.content || "No content available"}
          </p>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              className="text-green-600"
              onClick={() => setActionDialog({ open: true, action: "approve" })}
            >
              <IconCheck className="size-4" />
              Approve
            </Button>
            <Button
              variant="outline"
              size="sm"
              className="text-red-600"
              onClick={() => setActionDialog({ open: true, action: "remove" })}
            >
              <IconTrash className="size-4" />
              Remove
            </Button>
            <Button
              variant="outline"
              size="sm"
              className="text-yellow-600"
              onClick={() => setActionDialog({ open: true, action: "warn" })}
            >
              <IconAlertTriangle className="size-4" />
              Warn
            </Button>
          </div>
        </CardContent>
      </Card>

      <ModerationActionDialog
        open={actionDialog.open}
        onOpenChange={(open) => setActionDialog({ ...actionDialog, open })}
        contentType={item.content_type}
        contentId={item.id}
        action={actionDialog.action}
      />
    </>
  );
}
