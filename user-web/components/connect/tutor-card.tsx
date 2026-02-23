"use client";

import { memo } from "react";
import { Star, BadgeCheck, Clock, MessageSquare } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import type { Tutor } from "@/types/connect";

interface TutorCardProps {
  tutor: Tutor;
  onClick?: () => void;
  onBook?: () => void;
  variant?: "default" | "compact" | "featured";
  className?: string;
}

/**
 * Tutor card component displaying tutor information
 * Supports default, compact, and featured variants
 * Memoized to prevent unnecessary re-renders in lists
 */
export const TutorCard = memo(function TutorCard({
  tutor,
  onClick,
  onBook,
  variant = "default",
  className,
}: TutorCardProps) {
  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  const getAvailabilityColor = (status: Tutor["availability"]) => {
    switch (status) {
      case "available":
        return "bg-green-500";
      case "busy":
        return "bg-yellow-500";
      case "offline":
        return "bg-gray-400";
    }
  };

  const getExpertiseLabel = (level: Tutor["expertise"]) => {
    switch (level) {
      case "beginner":
        return "Beginner";
      case "intermediate":
        return "Intermediate";
      case "expert":
        return "Expert";
      case "master":
        return "Master";
    }
  };

  if (variant === "compact") {
    return (
      <Card
        className={cn("cursor-pointer transition-shadow hover:shadow-md", className)}
        onClick={onClick}
      >
        <CardContent className="flex items-center gap-3 p-3">
          <div className="relative">
            <Avatar className="h-10 w-10">
              <AvatarImage src={tutor.avatar} alt={tutor.name} />
              <AvatarFallback>{getInitials(tutor.name)}</AvatarFallback>
            </Avatar>
            <span
              className={cn(
                "absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full border-2 border-background",
                getAvailabilityColor(tutor.availability)
              )}
            />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1">
              <span className="font-medium truncate">{tutor.name}</span>
              {tutor.verified && <BadgeCheck className="h-4 w-4 text-blue-500 shrink-0" />}
            </div>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <div className="flex items-center gap-1">
                <Star className="h-3 w-3 fill-yellow-400 text-yellow-400" />
                <span>{tutor.rating}</span>
              </div>
              <span>•</span>
              <span>${tutor.hourlyRate}/hr</span>
            </div>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (variant === "featured") {
    return (
      <Card
        className={cn(
          "cursor-pointer overflow-hidden transition-all hover:shadow-lg",
          "bg-gradient-to-br from-primary/5 to-primary/10 border-primary/20",
          className
        )}
        onClick={onClick}
      >
        <CardContent className="p-4">
          <div className="flex items-start gap-4">
            <div className="relative">
              <Avatar className="h-16 w-16 border-2 border-primary/20">
                <AvatarImage src={tutor.avatar} alt={tutor.name} />
                <AvatarFallback className="text-lg">{getInitials(tutor.name)}</AvatarFallback>
              </Avatar>
              <span
                className={cn(
                  "absolute -bottom-0.5 -right-0.5 h-4 w-4 rounded-full border-2 border-background",
                  getAvailabilityColor(tutor.availability)
                )}
              />
            </div>

            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1.5 mb-1">
                <h3 className="font-semibold truncate">{tutor.name}</h3>
                {tutor.verified && <BadgeCheck className="h-4 w-4 text-blue-500 shrink-0" />}
              </div>

              <div className="flex items-center gap-2 text-sm mb-2">
                <div className="flex items-center gap-1">
                  <Star className="h-3.5 w-3.5 fill-yellow-400 text-yellow-400" />
                  <span className="font-medium">{tutor.rating}</span>
                  <span className="text-muted-foreground">({tutor.reviewCount})</span>
                </div>
              </div>

              <div className="flex flex-wrap gap-1 mb-3">
                {tutor.subjects.slice(0, 2).map((subject) => (
                  <Badge key={subject} variant="secondary" className="text-xs">
                    {subject}
                  </Badge>
                ))}
                {tutor.subjects.length > 2 && (
                  <Badge variant="outline" className="text-xs">
                    +{tutor.subjects.length - 2}
                  </Badge>
                )}
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <span className="text-lg font-bold">${tutor.hourlyRate}</span>
                  <span className="text-sm text-muted-foreground">/hour</span>
                </div>
                <Button size="sm" onClick={(e) => { e.stopPropagation(); onBook?.(); }}>
                  Book Now
                </Button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    );
  }

  // Default variant
  return (
    <Card
      className={cn("cursor-pointer transition-shadow hover:shadow-md", className)}
      onClick={onClick}
    >
      <CardContent className="p-4">
        <div className="flex items-start gap-4">
          <div className="relative">
            <Avatar className="h-14 w-14">
              <AvatarImage src={tutor.avatar} alt={tutor.name} />
              <AvatarFallback>{getInitials(tutor.name)}</AvatarFallback>
            </Avatar>
            <span
              className={cn(
                "absolute -bottom-0.5 -right-0.5 h-3.5 w-3.5 rounded-full border-2 border-background",
                getAvailabilityColor(tutor.availability)
              )}
            />
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5 mb-0.5">
              <h3 className="font-medium truncate">{tutor.name}</h3>
              {tutor.verified && <BadgeCheck className="h-4 w-4 text-blue-500 shrink-0" />}
            </div>

            <div className="flex items-center gap-2 text-sm text-muted-foreground mb-2">
              <div className="flex items-center gap-1">
                <Star className="h-3.5 w-3.5 fill-yellow-400 text-yellow-400" />
                <span>{tutor.rating}</span>
                <span>({tutor.reviewCount})</span>
              </div>
              <span>•</span>
              <Badge variant="outline" className="text-xs">
                {getExpertiseLabel(tutor.expertise)}
              </Badge>
            </div>

            <div className="flex flex-wrap gap-1 mb-3">
              {tutor.subjects.slice(0, 3).map((subject) => (
                <Badge key={subject} variant="secondary" className="text-xs">
                  {subject}
                </Badge>
              ))}
            </div>

            <div className="flex items-center gap-4 text-xs text-muted-foreground">
              <div className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                <span>{tutor.responseTime}</span>
              </div>
              <div className="flex items-center gap-1">
                <MessageSquare className="h-3 w-3" />
                <span>{tutor.completedSessions} sessions</span>
              </div>
            </div>
          </div>

          <div className="text-right">
            <div className="mb-2">
              <span className="text-lg font-bold">${tutor.hourlyRate}</span>
              <span className="text-xs text-muted-foreground">/hr</span>
            </div>
            <Button size="sm" onClick={(e) => { e.stopPropagation(); onBook?.(); }}>
              Book
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
});
