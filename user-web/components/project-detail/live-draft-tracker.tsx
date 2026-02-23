"use client";

import { FileText, ExternalLink, Clock } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import type { ProjectStatus } from "@/types/project";

interface LiveDraftTrackerProps {
  status: ProjectStatus;
  liveDocUrl?: string;
  className?: string;
}

/**
 * Check if live tracking should be available
 */
function isTrackingAvailable(status: ProjectStatus): boolean {
  const trackableStatuses: ProjectStatus[] = [
    "in_progress",
    "delivered",
    "qc_approved",
    "completed",
  ];
  return trackableStatuses.includes(status);
}

/**
 * Live draft tracking card with Google Docs placeholder
 */
export function LiveDraftTracker({
  status,
  liveDocUrl,
  className,
}: LiveDraftTrackerProps) {
  const isAvailable = isTrackingAvailable(status);
  const hasUrl = Boolean(liveDocUrl);

  const handleOpenDoc = () => {
    if (liveDocUrl) {
      window.open(liveDocUrl, "_blank", "noopener,noreferrer");
    }
  };

  return (
    <Card className={cn(className)}>
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center gap-2 text-base">
          <FileText className="h-5 w-5 text-primary" />
          Track Progress Live
        </CardTitle>
      </CardHeader>
      <CardContent>
        {!isAvailable ? (
          // Not yet available state
          <div className="flex flex-col items-center justify-center rounded-lg border border-dashed bg-muted/50 p-6 text-center">
            <Clock className="mb-2 h-8 w-8 text-muted-foreground/50" />
            <p className="text-sm text-muted-foreground">
              Available when expert starts working
            </p>
            <p className="mt-1 text-xs text-muted-foreground/70">
              You&apos;ll be able to track progress in real-time
            </p>
          </div>
        ) : (
          // Available state
          <div className="space-y-4">
            {/* Document preview placeholder */}
            <div className="relative aspect-[4/3] overflow-hidden rounded-lg border bg-gradient-to-br from-muted/50 to-muted">
              <div className="absolute inset-0 flex flex-col items-center justify-center p-4">
                <FileText className="mb-2 h-12 w-12 text-muted-foreground/30" />
                <p className="text-center text-sm text-muted-foreground">
                  Document Preview
                </p>
                <p className="mt-1 text-center text-xs text-muted-foreground/70">
                  {hasUrl
                    ? "Click below to view the live document"
                    : "Live document link not available yet"}
                </p>
              </div>

              {/* Decorative lines to simulate document */}
              <div className="absolute inset-x-4 top-8 space-y-2">
                <div className="h-2 w-3/4 rounded bg-muted-foreground/10" />
                <div className="h-2 w-full rounded bg-muted-foreground/10" />
                <div className="h-2 w-5/6 rounded bg-muted-foreground/10" />
                <div className="h-2 w-2/3 rounded bg-muted-foreground/10" />
              </div>
            </div>

            {/* View button */}
            <Button
              onClick={handleOpenDoc}
              disabled={!hasUrl}
              className="w-full gap-2"
              variant={hasUrl ? "default" : "secondary"}
            >
              <ExternalLink className="h-4 w-4" />
              {hasUrl ? "View Live Draft" : "Link Not Available"}
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
