"use client";

import {
  Star,
  BadgeCheck,
  Clock,
  MessageSquare,
  Globe,
  GraduationCap,
  Calendar,
} from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
  SheetFooter,
} from "@/components/ui/sheet";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { ScrollArea } from "@/components/ui/scroll-area";
import { cn } from "@/lib/utils";
import type { Tutor } from "@/types/connect";

interface TutorProfileSheetProps {
  tutor: Tutor | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onBook: (tutor: Tutor) => void;
  onMessage?: (tutor: Tutor) => void;
}

/**
 * Sheet component displaying detailed tutor profile
 */
export function TutorProfileSheet({
  tutor,
  open,
  onOpenChange,
  onBook,
  onMessage,
}: TutorProfileSheetProps) {
  if (!tutor) return null;

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

  const getAvailabilityLabel = (status: Tutor["availability"]) => {
    switch (status) {
      case "available":
        return "Available Now";
      case "busy":
        return "Busy";
      case "offline":
        return "Offline";
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

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[85vh] rounded-t-xl p-0">
        <ScrollArea className="h-full">
          {/* Header with Avatar */}
          <SheetHeader className="p-6 pb-4">
            <div className="flex items-start gap-4">
              <div className="relative">
                <Avatar className="h-20 w-20 border-2 border-muted">
                  <AvatarImage src={tutor.avatar} alt={tutor.name} />
                  <AvatarFallback className="text-xl">
                    {getInitials(tutor.name)}
                  </AvatarFallback>
                </Avatar>
                <span
                  className={cn(
                    "absolute -bottom-1 -right-1 h-5 w-5 rounded-full border-2 border-background",
                    getAvailabilityColor(tutor.availability)
                  )}
                />
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-1.5 mb-1">
                  <SheetTitle className="text-xl truncate">{tutor.name}</SheetTitle>
                  {tutor.verified && (
                    <BadgeCheck className="h-5 w-5 text-blue-500 shrink-0" />
                  )}
                </div>
                <SheetDescription className="flex items-center gap-2 text-sm">
                  <span
                    className={cn(
                      "inline-flex h-2 w-2 rounded-full",
                      getAvailabilityColor(tutor.availability)
                    )}
                  />
                  {getAvailabilityLabel(tutor.availability)}
                </SheetDescription>
              </div>
            </div>
          </SheetHeader>

          {/* Stats Row */}
          <div className="grid grid-cols-3 gap-4 px-6 pb-4">
            <div className="text-center">
              <div className="flex items-center justify-center gap-1">
                <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                <span className="font-bold text-lg">{tutor.rating}</span>
              </div>
              <p className="text-xs text-muted-foreground">{tutor.reviewCount} reviews</p>
            </div>
            <div className="text-center">
              <div className="font-bold text-lg">{tutor.completedSessions}</div>
              <p className="text-xs text-muted-foreground">Sessions</p>
            </div>
            <div className="text-center">
              <div className="font-bold text-lg">${tutor.hourlyRate}</div>
              <p className="text-xs text-muted-foreground">per hour</p>
            </div>
          </div>

          <Separator />

          {/* Bio */}
          <div className="p-6">
            <h3 className="font-semibold mb-2">About</h3>
            <p className="text-sm text-muted-foreground">{tutor.bio}</p>
          </div>

          {/* Subjects */}
          <div className="px-6 pb-4">
            <h3 className="font-semibold mb-2">Subjects</h3>
            <div className="flex flex-wrap gap-2">
              {tutor.subjects.map((subject) => (
                <Badge key={subject} variant="secondary">
                  {subject}
                </Badge>
              ))}
            </div>
          </div>

          {/* Details */}
          <div className="px-6 pb-4 space-y-3">
            <h3 className="font-semibold">Details</h3>

            <div className="flex items-center gap-3 text-sm">
              <GraduationCap className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Expertise:</span>
              <Badge variant="outline">{getExpertiseLabel(tutor.expertise)}</Badge>
            </div>

            {tutor.education && (
              <div className="flex items-center gap-3 text-sm">
                <GraduationCap className="h-4 w-4 text-muted-foreground" />
                <span className="text-muted-foreground">Education:</span>
                <span>{tutor.education}</span>
              </div>
            )}

            <div className="flex items-center gap-3 text-sm">
              <Clock className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Response time:</span>
              <span>{tutor.responseTime}</span>
            </div>

            <div className="flex items-center gap-3 text-sm">
              <Globe className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Languages:</span>
              <span>{tutor.languages.join(", ")}</span>
            </div>
          </div>

          {/* Spacer for footer */}
          <div className="h-24" />
        </ScrollArea>

        {/* Fixed Footer */}
        <SheetFooter className="absolute bottom-0 left-0 right-0 flex-row gap-3 border-t bg-background p-4">
          {onMessage && (
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => onMessage(tutor)}
            >
              <MessageSquare className="mr-2 h-4 w-4" />
              Message
            </Button>
          )}
          <Button className="flex-1" onClick={() => onBook(tutor)}>
            <Calendar className="mr-2 h-4 w-4" />
            Book Session
          </Button>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
}
