"use client";

import {
  IconAlertTriangle,
  IconClock,
  IconMessageCircle,
  IconProgressCheck,
} from "@tabler/icons-react";
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

interface TicketStats {
  open_count: number;
  in_progress_count: number;
  avg_resolution_time?: number;
  resolved_count?: number;
  closed_count?: number;
  total_count?: number;
  by_priority?: {
    low: number;
    medium: number;
    high: number;
    urgent: number;
  };
}

export function TicketStatsCards({ stats }: { stats: TicketStats }) {
  const urgentCount = stats.by_priority?.urgent || 0;

  return (
    <div className="*:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card dark:*:data-[slot=card]:bg-card grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-4">
      <Card className="@container/card">
        <CardHeader>
          <CardDescription>Open Tickets</CardDescription>
          <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
            {stats.open_count}
          </CardTitle>
        </CardHeader>
        <CardFooter className="text-sm text-muted-foreground">
          <IconMessageCircle className="size-4 mr-2" />
          Awaiting response
        </CardFooter>
      </Card>

      <Card className="@container/card">
        <CardHeader>
          <CardDescription>In Progress</CardDescription>
          <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
            {stats.in_progress_count}
          </CardTitle>
        </CardHeader>
        <CardFooter className="text-sm text-muted-foreground">
          <IconProgressCheck className="size-4 mr-2" />
          Being handled
        </CardFooter>
      </Card>

      <Card className="@container/card">
        <CardHeader>
          <CardDescription>Avg Resolution Time</CardDescription>
          <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
            {(stats.avg_resolution_time ?? 0) > 0
              ? `${stats.avg_resolution_time}h`
              : "N/A"}
          </CardTitle>
        </CardHeader>
        <CardFooter className="text-sm text-muted-foreground">
          <IconClock className="size-4 mr-2" />
          Average hours to resolve
        </CardFooter>
      </Card>

      <Card className="@container/card">
        <CardHeader>
          <CardDescription>Urgent Tickets</CardDescription>
          <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
            {urgentCount}
          </CardTitle>
        </CardHeader>
        <CardFooter className="text-sm text-muted-foreground">
          <IconAlertTriangle className="size-4 mr-2" />
          Needs immediate attention
        </CardFooter>
      </Card>
    </div>
  );
}
