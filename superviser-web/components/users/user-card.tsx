/**
 * @fileoverview Card component displaying user profile summary.
 * @module components/users/user-card
 */

"use client"

import { useMemo, useState } from "react"
import {
  Briefcase,
  CheckCircle2,
  ChevronRight,
  GraduationCap,
  IndianRupee,
} from "lucide-react"

import { Card, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"
import { User } from "./types"

// Calculate once at module load to avoid impure function in render
const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000

interface UserCardProps {
  user: User
  onClick?: () => void
}

export function UserCard({ user, onClick }: UserCardProps) {
  // useState with initializer is pure (runs once)
  const [thirtyDaysAgo] = useState(() => Date.now() - THIRTY_DAYS_MS)

  const isActive = useMemo(() => {
    return user.active_projects > 0 ||
      (user.last_active_at &&
        new Date(user.last_active_at).getTime() > thirtyDaysAgo)
  }, [user.active_projects, user.last_active_at, thirtyDaysAgo])

  return (
    <Card
      className="transition-all duration-200 hover:shadow-lg hover:border-primary/20 cursor-pointer group rounded-xl"
      onClick={onClick}
    >
      <CardContent className="p-5">
        <div className="flex items-start gap-4">
          {/* Avatar */}
          <div className="relative shrink-0">
            <Avatar className="h-12 w-12 ring-2 ring-background shadow-sm">
              <AvatarImage src={user.avatar_url} alt={user.full_name} />
              <AvatarFallback>
                {user.full_name
                  .split(" ")
                  .map((n) => n[0])
                  .join("")}
              </AvatarFallback>
            </Avatar>
            {isActive && (
              <span className="absolute -bottom-0.5 -right-0.5 h-3.5 w-3.5 rounded-full bg-green-500 border-2 border-background" />
            )}
          </div>

          {/* Info */}
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="font-medium truncate group-hover:text-primary transition-colors">
                    {user.full_name}
                  </h3>
                  {user.is_verified && (
                    <CheckCircle2 className="h-4 w-4 text-blue-500 shrink-0" />
                  )}
                </div>
                {(user.college || user.course) && (
                  <div className="flex items-center gap-1 text-sm text-muted-foreground mt-0.5">
                    <GraduationCap className="h-3.5 w-3.5" />
                    <span className="truncate">
                      {user.course && user.year
                        ? `${user.course} - ${user.year}`
                        : user.college || user.course}
                    </span>
                  </div>
                )}
              </div>
              <ChevronRight className="h-5 w-5 text-muted-foreground shrink-0" />
            </div>

            {/* Stats */}
            <div className="flex flex-wrap items-center gap-4 mt-3 text-sm">
              <div className="flex items-center gap-1.5 text-muted-foreground">
                <Briefcase className="h-4 w-4" />
                <span>{user.total_projects} projects</span>
              </div>
              <div className="flex items-center gap-1.5 text-muted-foreground">
                <IndianRupee className="h-4 w-4" />
                <span className="font-medium">
                  {user.total_spent.toLocaleString("en-IN", {
                    maximumFractionDigits: 0,
                  })}
                </span>
                <span>spent</span>
              </div>
            </div>

            {/* Status Badges */}
            <div className="flex flex-wrap gap-2 mt-4 pt-3 border-t">
              {user.active_projects > 0 ? (
                <Badge className="bg-blue-600 hover:bg-blue-700 gap-1">
                  {user.active_projects} Active
                </Badge>
              ) : isActive ? (
                <Badge variant="secondary" className="gap-1">
                  Recently Active
                </Badge>
              ) : (
                <Badge variant="outline" className="gap-1">
                  Inactive
                </Badge>
              )}
              {user.completed_projects > 0 && (
                <Badge variant="outline">
                  {user.completed_projects} completed
                </Badge>
              )}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
