"use client";

import { format } from "date-fns";
import { ProjectStatusBadge } from "./project-status-badge";

interface StatusHistoryEntry {
  id: string;
  old_status: string;
  new_status: string;
  reason?: string;
  created_at: string;
  changed_by_profile?: { full_name: string } | null;
}

export function ProjectTimeline({
  history,
}: {
  history: StatusHistoryEntry[];
}) {
  if (history.length === 0) {
    return (
      <p className="text-sm text-muted-foreground py-8 text-center">
        No status history available.
      </p>
    );
  }

  return (
    <div className="relative space-y-0">
      {history.map((entry, index) => (
        <div key={entry.id} className="relative flex gap-4 pb-8 last:pb-0">
          {/* Vertical line */}
          {index < history.length - 1 && (
            <div className="absolute left-[11px] top-6 h-full w-px bg-border" />
          )}

          {/* Dot */}
          <div className="relative z-10 mt-1.5 size-[9px] shrink-0 rounded-full border-2 border-primary bg-background ring-4 ring-background" />

          {/* Content */}
          <div className="flex-1 space-y-1">
            <div className="flex flex-wrap items-center gap-2">
              <ProjectStatusBadge status={entry.old_status} />
              <span className="text-muted-foreground text-xs">to</span>
              <ProjectStatusBadge status={entry.new_status} />
            </div>
            {entry.reason && (
              <p className="text-sm text-muted-foreground">{entry.reason}</p>
            )}
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <span>
                {format(new Date(entry.created_at), "dd MMM yyyy, HH:mm")}
              </span>
              {entry.changed_by_profile?.full_name && (
                <>
                  <span>by</span>
                  <span className="font-medium text-foreground">
                    {entry.changed_by_profile.full_name}
                  </span>
                </>
              )}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
