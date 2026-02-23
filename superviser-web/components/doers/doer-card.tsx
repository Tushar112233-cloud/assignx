/**
 * @fileoverview Card component displaying doer profile summary and stats.
 * @module components/doers/doer-card
 */

"use client"

import {
  Star,
  Briefcase,
  Clock,
  CheckCircle2,
  AlertTriangle,
  ChevronRight,
  Ban,
} from "lucide-react"

import { Card, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import { Doer } from "./types"

interface DoerCardProps {
  doer: Doer
  onClick?: () => void
}

export function DoerCard({ doer, onClick }: DoerCardProps) {
  return (
    <Card
      className={cn(
        "transition-all duration-200 hover:shadow-lg hover:border-primary/20 cursor-pointer group rounded-xl",
        doer.is_blacklisted && "border-destructive/50 bg-destructive/5"
      )}
      onClick={onClick}
    >
      <CardContent className="p-5">
        <div className="flex items-start gap-4">
          {/* Avatar */}
          <div className="relative shrink-0">
            <Avatar className="h-12 w-12 ring-2 ring-background shadow-sm">
              <AvatarImage src={doer.avatar_url} alt={doer.full_name} />
              <AvatarFallback>
                {doer.full_name
                  .split(" ")
                  .map((n) => n[0])
                  .join("")}
              </AvatarFallback>
            </Avatar>
            {doer.is_available && !doer.is_blacklisted && (
              <span className="absolute -bottom-0.5 -right-0.5 h-3.5 w-3.5 rounded-full bg-green-500 border-2 border-background" />
            )}
            {!doer.is_available && !doer.is_blacklisted && (
              <span className="absolute -bottom-0.5 -right-0.5 h-3.5 w-3.5 rounded-full bg-gray-400 border-2 border-background" />
            )}
            {doer.is_blacklisted && (
              <span className="absolute -bottom-0.5 -right-0.5 h-3.5 w-3.5 rounded-full bg-red-500 border-2 border-background" />
            )}
          </div>

          {/* Info */}
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="font-medium truncate group-hover:text-primary transition-colors">
                    {doer.full_name}
                  </h3>
                  {doer.is_verified && (
                    <CheckCircle2 className="h-4 w-4 text-blue-500 shrink-0" />
                  )}
                  {doer.is_blacklisted && (
                    <Ban className="h-4 w-4 text-destructive shrink-0" />
                  )}
                </div>
                <p className="text-sm text-muted-foreground">{doer.qualification}</p>
              </div>
              <ChevronRight className="h-5 w-5 text-muted-foreground shrink-0" />
            </div>

            {/* Stats */}
            <div className="flex flex-wrap items-center gap-4 mt-3 text-sm">
              <div className="flex items-center gap-1.5">
                <div className="flex">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <Star
                      key={star}
                      className={cn(
                        "h-3.5 w-3.5",
                        star <= Math.round(doer.rating)
                          ? "fill-amber-400 text-amber-400"
                          : "fill-muted text-muted"
                      )}
                    />
                  ))}
                </div>
                <span className="font-semibold">{doer.rating.toFixed(1)}</span>
                <span className="text-muted-foreground text-xs">({doer.total_reviews})</span>
              </div>
              <div className="flex items-center gap-1.5 text-muted-foreground">
                <Briefcase className="h-4 w-4" />
                <span>{doer.completed_projects} done</span>
              </div>
              {doer.average_response_time && (
                <div className="flex items-center gap-1.5 text-muted-foreground">
                  <Clock className="h-4 w-4" />
                  <span>{doer.average_response_time}</span>
                </div>
              )}
            </div>

            {/* Skills */}
            <div className="flex flex-wrap gap-1.5 mt-3">
              {doer.skills.slice(0, 3).map((skill) => (
                <Badge key={skill} variant="secondary" className="text-xs font-normal px-2 py-0.5">
                  {skill}
                </Badge>
              ))}
              {doer.skills.length > 3 && (
                <Badge variant="outline" className="text-xs font-normal px-2 py-0.5">
                  +{doer.skills.length - 3}
                </Badge>
              )}
            </div>

            {/* Status Badges */}
            <div className="flex flex-wrap gap-2 mt-4 pt-3 border-t">
              {doer.is_blacklisted ? (
                <Badge variant="destructive" className="gap-1">
                  <AlertTriangle className="h-3 w-3" />
                  Blacklisted
                </Badge>
              ) : doer.is_available ? (
                <Badge className="bg-green-600 hover:bg-green-700 gap-1">
                  Available
                </Badge>
              ) : (
                <Badge variant="secondary" className="gap-1">
                  Busy
                </Badge>
              )}
              {doer.active_projects > 0 && (
                <Badge variant="outline">
                  {doer.active_projects} active project{doer.active_projects > 1 ? "s" : ""}
                </Badge>
              )}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
