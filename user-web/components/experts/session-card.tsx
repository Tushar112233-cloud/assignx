"use client";

import { memo } from "react";
import { format, isPast, isFuture, differenceInMinutes } from "date-fns";
import {
  Video,
  Calendar,
  Clock,
  Star,
  MessageSquare,
  AlertTriangle,
  CheckCircle2,
  XCircle,
} from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import type { ConsultationBooking, SessionStatus, Expert } from "@/types/expert";

interface SessionCardProps {
  booking: ConsultationBooking;
  expert: Pick<Expert, "id" | "name" | "avatar" | "designation">;
  onJoinMeet?: () => void;
  onLeaveReview?: () => void;
  onCancel?: () => void;
  onReport?: () => void;
  className?: string;
}

/**
 * Status badge configuration
 */
const STATUS_CONFIG: Record<
  SessionStatus,
  { label: string; variant: "default" | "secondary" | "outline" | "destructive"; icon: React.ComponentType<{ className?: string }> }
> = {
  upcoming: {
    label: "Upcoming",
    variant: "default",
    icon: Calendar,
  },
  in_progress: {
    label: "In Progress",
    variant: "default",
    icon: Video,
  },
  completed: {
    label: "Completed",
    variant: "secondary",
    icon: CheckCircle2,
  },
  cancelled: {
    label: "Cancelled",
    variant: "destructive",
    icon: XCircle,
  },
  no_show: {
    label: "No Show",
    variant: "outline",
    icon: AlertTriangle,
  },
};

/**
 * Session card component for displaying consultation sessions
 * Shows expert info, date/time, meet link, and actions based on status
 */
export const SessionCard = memo(function SessionCard({
  booking,
  expert,
  onJoinMeet,
  onLeaveReview,
  onCancel,
  onReport,
  className,
}: SessionCardProps) {
  const statusConfig = STATUS_CONFIG[booking.status];
  const StatusIcon = statusConfig.icon;

  /**
   * Get initials from name for avatar fallback
   */
  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  /**
   * Check if session is starting soon (within 30 minutes)
   */
  const isStartingSoon = () => {
    if (booking.status !== "upcoming") return false;
    const sessionDateTime = new Date(
      `${format(new Date(booking.date), "yyyy-MM-dd")}T${booking.startTime}`
    );
    const minutesUntilStart = differenceInMinutes(sessionDateTime, new Date());
    return minutesUntilStart <= 30 && minutesUntilStart > 0;
  };

  /**
   * Check if join button should be enabled
   */
  const canJoinMeet = () => {
    if (!booking.meetLink) return false;
    if (booking.status === "in_progress") return true;
    if (booking.status === "upcoming" && isStartingSoon()) return true;
    return false;
  };

  /**
   * Check if review can be left
   */
  const canLeaveReview = () => {
    return booking.status === "completed";
  };

  /**
   * Check if session can be cancelled
   */
  const canCancel = () => {
    if (booking.status !== "upcoming") return false;
    const sessionDateTime = new Date(
      `${format(new Date(booking.date), "yyyy-MM-dd")}T${booking.startTime}`
    );
    // Can only cancel at least 24 hours in advance
    const hoursUntilStart = differenceInMinutes(sessionDateTime, new Date()) / 60;
    return hoursUntilStart >= 24;
  };

  return (
    <Card className={cn("overflow-hidden", className)}>
      <CardContent className="p-4">
        <div className="flex items-start gap-4">
          {/* Expert Avatar */}
          <Avatar className="h-12 w-12">
            <AvatarImage src={expert.avatar} alt={expert.name} />
            <AvatarFallback>{getInitials(expert.name)}</AvatarFallback>
          </Avatar>

          {/* Session Details */}
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2 mb-1">
              <div>
                <h3 className="font-medium truncate">{expert.name}</h3>
                <p className="text-sm text-muted-foreground truncate">
                  {expert.designation}
                </p>
              </div>
              <Badge variant={statusConfig.variant} className="shrink-0">
                <StatusIcon className="h-3 w-3 mr-1" />
                {statusConfig.label}
              </Badge>
            </div>

            {/* Date and Time */}
            <div className="flex items-center gap-4 text-sm text-muted-foreground mt-2">
              <div className="flex items-center gap-1">
                <Calendar className="h-4 w-4" />
                <span>{format(new Date(booking.date), "EEE, MMM d, yyyy")}</span>
              </div>
              <div className="flex items-center gap-1">
                <Clock className="h-4 w-4" />
                <span>
                  {format(new Date(`2000-01-01T${booking.startTime}`), "h:mm a")}
                </span>
              </div>
            </div>

            {/* Topic */}
            {booking.topic && (
              <p className="text-sm mt-2 text-muted-foreground line-clamp-1">
                <span className="font-medium text-foreground">Topic:</span> {booking.topic}
              </p>
            )}

            {/* Starting Soon Alert */}
            {isStartingSoon() && (
              <div className="mt-2 flex items-center gap-1.5 text-sm text-orange-600 dark:text-orange-400">
                <AlertTriangle className="h-4 w-4" />
                <span>Session starts soon!</span>
              </div>
            )}

            {/* Price */}
            <div className="mt-2 text-sm">
              <span className="text-muted-foreground">Amount: </span>
              <span className="font-medium">{formatINR(booking.totalAmount)}</span>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-2 mt-4 pt-4 border-t border-border/50">
          {/* Join Meet Button */}
          {canJoinMeet() && booking.meetLink && (
            <Button
              size="sm"
              onClick={onJoinMeet}
              className="flex-1 sm:flex-none"
            >
              <Video className="h-4 w-4 mr-1" />
              Join Meet
            </Button>
          )}

          {/* Leave Review Button */}
          {canLeaveReview() && (
            <Button
              size="sm"
              variant="outline"
              onClick={onLeaveReview}
              className="flex-1 sm:flex-none"
            >
              <Star className="h-4 w-4 mr-1" />
              Leave Review
            </Button>
          )}

          {/* Cancel Button */}
          {canCancel() && (
            <Button
              size="sm"
              variant="outline"
              onClick={onCancel}
              className="text-destructive hover:text-destructive"
            >
              Cancel
            </Button>
          )}

          {/* Report Button */}
          {booking.status === "completed" && (
            <Button
              size="sm"
              variant="ghost"
              onClick={onReport}
              className="text-muted-foreground hover:text-foreground ml-auto"
            >
              <MessageSquare className="h-4 w-4 mr-1" />
              Report Issue
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
});
