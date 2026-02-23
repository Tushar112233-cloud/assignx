"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  CheckCircle2,
  Clock,
  FileText,
  CreditCard,
  Users,
  Pencil,
  Upload,
  MessageSquare,
  Star,
  Loader2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";
import { getProjectById } from "@/lib/actions/data";

/**
 * Timeline event interface
 */
interface TimelineEvent {
  id: string;
  type: string;
  title: string;
  description: string;
  timestamp: string;
  status: "completed" | "current" | "pending";
  icon: React.ReactNode;
  metadata?: Record<string, string | number | boolean>;
}

/**
 * Event icons mapping
 */
const eventIcons: Record<string, React.ReactNode> = {
  submitted: <FileText className="h-4 w-4" />,
  quoted: <CreditCard className="h-4 w-4" />,
  payment_received: <CreditCard className="h-4 w-4" />,
  assigned: <Users className="h-4 w-4" />,
  work_started: <Pencil className="h-4 w-4" />,
  progress_update: <Clock className="h-4 w-4" />,
  delivered: <Upload className="h-4 w-4" />,
  revision_requested: <MessageSquare className="h-4 w-4" />,
  approved: <CheckCircle2 className="h-4 w-4" />,
  completed: <Star className="h-4 w-4" />,
};

/**
 * Format timestamp for display
 */
function formatTimestamp(timestamp: string): string {
  const date = new Date(timestamp);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
  const diffDays = Math.floor(diffHours / 24);

  if (diffHours < 1) {
    return "Just now";
  } else if (diffHours < 24) {
    return `${diffHours}h ago`;
  } else if (diffDays < 7) {
    return `${diffDays}d ago`;
  }

  return date.toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: date.getFullYear() !== now.getFullYear() ? "numeric" : undefined,
    hour: "2-digit",
    minute: "2-digit",
  });
}

/**
 * Project Timeline Page
 * Shows detailed progress timeline for a project
 * Implements U41 from feature spec
 */
export default function ProjectTimelinePage() {
  const params = useParams();
  const router = useRouter();
  const projectId = params.id as string;

  const [project, setProject] = useState<{
    id: string;
    project_number: string;
    title: string;
    status: string;
    timeline: Array<{
      id: string;
      event_type: string;
      title: string;
      description: string;
      created_at: string;
      metadata: Record<string, string | number | boolean>;
    }>;
  } | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchProject = async () => {
      try {
        const data = await getProjectById(projectId);
        setProject(data);
      } finally {
        setIsLoading(false);
      }
    };
    fetchProject();
  }, [projectId]);

  // Transform project timeline to events
  const getTimelineEvents = (): TimelineEvent[] => {
    if (!project) return [];

    const events: TimelineEvent[] = [];
    const now = new Date();

    // Add events from project timeline
    if (project.timeline && project.timeline.length > 0) {
      project.timeline.forEach((item) => {
        events.push({
          id: item.id,
          type: item.event_type,
          title: item.title,
          description: item.description,
          timestamp: item.created_at,
          status: "completed",
          icon: eventIcons[item.event_type] || <Clock className="h-4 w-4" />,
          metadata: item.metadata,
        });
      });
    }

    // Sort by timestamp (newest first for display, but we'll reverse for timeline)
    events.sort(
      (a, b) =>
        new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
    );

    // Mark current event (last completed one)
    if (events.length > 0 && project.status !== "completed") {
      events[events.length - 1].status = "current";
    }

    // Add pending events based on current status
    const pendingEvents = getPendingEvents(project.status);
    events.push(...pendingEvents);

    return events;
  };

  // Get pending events based on current status
  const getPendingEvents = (status: string): TimelineEvent[] => {
    const pending: TimelineEvent[] = [];
    const futureDate = new Date(Date.now() + 86400000).toISOString();

    const statusOrder = [
      "submitted",
      "quoted",
      "payment_pending",
      "in_progress",
      "delivered",
      "completed",
    ];
    const currentIndex = statusOrder.indexOf(status);

    if (currentIndex < statusOrder.indexOf("completed")) {
      if (currentIndex < statusOrder.indexOf("delivered")) {
        pending.push({
          id: "pending-delivered",
          type: "delivered",
          title: "Delivery",
          description: "Files will be uploaded for your review",
          timestamp: futureDate,
          status: "pending",
          icon: <Upload className="h-4 w-4" />,
        });
      }

      pending.push({
        id: "pending-completed",
        type: "completed",
        title: "Completion",
        description: "Project will be marked as complete",
        timestamp: futureDate,
        status: "pending",
        icon: <Star className="h-4 w-4" />,
      });
    }

    return pending;
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background">
        <div className="sticky top-0 z-10 flex items-center gap-4 border-b bg-background/95 backdrop-blur p-4">
          <Skeleton className="h-10 w-10" />
          <Skeleton className="h-6 w-48" />
        </div>
        <div className="p-4 space-y-4">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} className="h-24 w-full" />
          ))}
        </div>
      </div>
    );
  }

  if (!project) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <p className="text-muted-foreground">Project not found</p>
          <Button variant="link" onClick={() => router.back()}>
            Go back
          </Button>
        </div>
      </div>
    );
  }

  const events = getTimelineEvents();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="sticky top-0 z-10 flex items-center gap-4 border-b bg-background/95 backdrop-blur p-4">
        <Button variant="ghost" size="icon" onClick={() => router.back()}>
          <ArrowLeft className="h-5 w-5" />
        </Button>
        <div>
          <h1 className="font-semibold">Project Timeline</h1>
          <p className="text-sm text-muted-foreground">
            {project.project_number} • {project.title}
          </p>
        </div>
      </div>

      {/* Timeline */}
      <div className="p-4 max-w-2xl mx-auto">
        <div className="relative">
          {/* Timeline line */}
          <div className="absolute left-5 top-0 bottom-0 w-0.5 bg-border" />

          {/* Events */}
          <div className="space-y-6">
            {events.map((event, index) => (
              <div key={event.id} className="relative flex gap-4">
                {/* Icon circle */}
                <div
                  className={cn(
                    "relative z-10 flex h-10 w-10 shrink-0 items-center justify-center rounded-full border-2",
                    event.status === "completed" &&
                      "bg-green-100 border-green-500 text-green-600 dark:bg-green-900/30",
                    event.status === "current" &&
                      "bg-primary/10 border-primary text-primary animate-pulse",
                    event.status === "pending" &&
                      "bg-muted border-muted-foreground/30 text-muted-foreground"
                  )}
                >
                  {event.icon}
                </div>

                {/* Content */}
                <Card
                  className={cn(
                    "flex-1",
                    event.status === "current" && "border-primary shadow-md",
                    event.status === "pending" && "opacity-50"
                  )}
                >
                  <CardContent className="p-4">
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <h3 className="font-medium">{event.title}</h3>
                        <p className="text-sm text-muted-foreground mt-1">
                          {event.description}
                        </p>
                      </div>
                      <Badge
                        variant={
                          event.status === "completed"
                            ? "default"
                            : event.status === "current"
                            ? "secondary"
                            : "outline"
                        }
                        className={cn(
                          "shrink-0",
                          event.status === "completed" &&
                            "bg-green-100 text-green-700 dark:bg-green-900/30"
                        )}
                      >
                        {event.status === "completed"
                          ? "Done"
                          : event.status === "current"
                          ? "Current"
                          : "Upcoming"}
                      </Badge>
                    </div>

                    {event.status !== "pending" && (
                      <p className="text-xs text-muted-foreground mt-2">
                        {formatTimestamp(event.timestamp)}
                      </p>
                    )}

                    {/* Progress indicator for current event */}
                    {event.status === "current" &&
                      event.metadata?.progress !== undefined && (
                        <div className="mt-3">
                          <div className="flex justify-between text-xs mb-1">
                            <span>Progress</span>
                            <span>{event.metadata.progress}%</span>
                          </div>
                          <div className="h-2 bg-muted rounded-full overflow-hidden">
                            <div
                              className="h-full bg-primary transition-all"
                              style={{
                                width: `${event.metadata.progress}%`,
                              }}
                            />
                          </div>
                        </div>
                      )}
                  </CardContent>
                </Card>
              </div>
            ))}
          </div>
        </div>

        {/* Status summary */}
        <Card className="mt-8">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Current Status</p>
                <p className="font-medium capitalize">
                  {project.status.replace("_", " ")}
                </p>
              </div>
              <Badge className="capitalize">
                {events.filter((e) => e.status === "completed").length} of{" "}
                {events.length} steps
              </Badge>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
