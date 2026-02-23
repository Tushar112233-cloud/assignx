"use client";

import { Users, Calendar, Lock, CheckCircle } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import type { StudyGroup } from "@/types/connect";

interface StudyGroupCardProps {
  group: StudyGroup;
  onClick?: () => void;
  onJoin?: () => void;
  className?: string;
}

/**
 * Study group card component displaying group information
 */
export function StudyGroupCard({
  group,
  onClick,
  onJoin,
  className,
}: StudyGroupCardProps) {
  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  const getStatusBadge = () => {
    switch (group.status) {
      case "open":
        return (
          <Badge variant="secondary" className="bg-green-500/10 text-green-600">
            Open
          </Badge>
        );
      case "full":
        return (
          <Badge variant="secondary" className="bg-yellow-500/10 text-yellow-600">
            Full
          </Badge>
        );
      case "private":
        return (
          <Badge variant="secondary" className="bg-gray-500/10 text-gray-600">
            <Lock className="mr-1 h-3 w-3" />
            Private
          </Badge>
        );
    }
  };

  const formatNextSession = (date?: Date) => {
    if (!date) return null;

    const now = new Date();
    const diff = date.getTime() - now.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) {
      return "Today";
    } else if (days === 1) {
      return "Tomorrow";
    } else if (days < 7) {
      return `In ${days} days`;
    } else {
      return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
    }
  };

  const memberPercentage = (group.memberCount / group.maxMembers) * 100;

  return (
    <Card
      className={cn(
        "cursor-pointer transition-shadow hover:shadow-md",
        group.isJoined && "border-primary/30 bg-primary/5",
        className
      )}
      onClick={onClick}
    >
      <CardContent className="p-4">
        <div className="flex items-start justify-between gap-3 mb-3">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <h3 className="font-medium truncate">{group.name}</h3>
              {group.isJoined && (
                <CheckCircle className="h-4 w-4 text-primary shrink-0" />
              )}
            </div>
            <p className="text-sm text-muted-foreground line-clamp-2">
              {group.description}
            </p>
          </div>
          {getStatusBadge()}
        </div>

        {/* Topics */}
        <div className="flex flex-wrap gap-1 mb-3">
          {group.topics.slice(0, 3).map((topic) => (
            <Badge key={topic} variant="outline" className="text-xs">
              {topic}
            </Badge>
          ))}
          {group.topics.length > 3 && (
            <Badge variant="outline" className="text-xs">
              +{group.topics.length - 3}
            </Badge>
          )}
        </div>

        {/* Members Progress */}
        <div className="mb-3">
          <div className="flex items-center justify-between text-sm mb-1">
            <div className="flex items-center gap-1 text-muted-foreground">
              <Users className="h-3.5 w-3.5" />
              <span>
                {group.memberCount}/{group.maxMembers} members
              </span>
            </div>
            {group.nextSession && (
              <div className="flex items-center gap-1 text-muted-foreground">
                <Calendar className="h-3.5 w-3.5" />
                <span>{formatNextSession(group.nextSession)}</span>
              </div>
            )}
          </div>
          <div className="h-1.5 bg-muted rounded-full overflow-hidden">
            <div
              className={cn(
                "h-full rounded-full transition-all",
                memberPercentage >= 90 ? "bg-yellow-500" : "bg-primary"
              )}
              style={{ width: `${memberPercentage}%` }}
            />
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Avatar className="h-6 w-6">
              <AvatarImage src={group.createdBy.avatar} alt={group.createdBy.name} />
              <AvatarFallback className="text-xs">
                {getInitials(group.createdBy.name)}
              </AvatarFallback>
            </Avatar>
            <span className="text-sm text-muted-foreground truncate max-w-[120px]">
              by {group.createdBy.name}
            </span>
          </div>

          {group.isJoined ? (
            <Button size="sm" variant="outline">
              View Group
            </Button>
          ) : group.status === "full" ? (
            <Button size="sm" variant="outline" disabled>
              Group Full
            </Button>
          ) : (
            <Button
              size="sm"
              onClick={(e) => {
                e.stopPropagation();
                onJoin?.();
              }}
            >
              Join
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
