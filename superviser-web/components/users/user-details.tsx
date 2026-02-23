/**
 * @fileoverview User details sheet component for viewing full user profile.
 * @module components/users/user-details
 */

"use client"

import { useState, useEffect, useMemo } from "react"
import { useRouter } from "next/navigation"
import {
  Star,
  Briefcase,
  Mail,
  Phone,
  Calendar,
  GraduationCap,
  Building2,
  IndianRupee,
  CheckCircle2,
  MessageSquare,
  Loader2,
} from "lucide-react"

import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { cn } from "@/lib/utils"
import { User } from "./types"
import { useUserProjects } from "@/hooks/use-users"
import { Skeleton } from "@/components/ui/skeleton"

interface UserDetailsProps {
  user: User
  open: boolean
  onOpenChange: (open: boolean) => void
  onChat?: (userId: string) => void
}

export function UserDetails({
  user,
  open,
  onOpenChange,
  onChat,
}: UserDetailsProps) {
  const router = useRouter()
  const [activeTab, setActiveTab] = useState("overview")

  // Fetch real projects data from Supabase
  const { projects, isLoading: isLoadingProjects } = useUserProjects({ userId: user.id })

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-IN", {
      day: "numeric",
      month: "short",
      year: "numeric",
    })
  }

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      analyzing: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300",
      quoted: "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300",
      payment_pending: "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300",
      paid: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
      in_progress: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
      submitted_for_qc: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
      completed: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
      delivered: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
    }
    return colors[status] || "bg-gray-100 text-gray-700"
  }

  const getServiceTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      new_project: "New Project",
      proofreading: "Proofreading",
      plagiarism_check: "Plagiarism Check",
      ai_detection: "AI Detection",
      expert_opinion: "Expert Opinion",
    }
    return labels[type] || type
  }

  // useState with initializer is pure (runs once)
  const [thirtyDaysAgo] = useState(() => Date.now() - 30 * 24 * 60 * 60 * 1000)

  const isActive = useMemo(() => {
    return user.active_projects > 0 ||
      (user.last_active_at &&
        new Date(user.last_active_at).getTime() > thirtyDaysAgo)
  }, [user.active_projects, user.last_active_at, thirtyDaysAgo])

  // Map project status to projects page filter
  const getFilterFromStatus = (status: string): string => {
    const statusMap: Record<string, string> = {
      analyzing: "new",
      quoted: "ready",
      payment_pending: "ready",
      paid: "ready",
      in_progress: "ongoing",
      submitted_for_qc: "review",
      qc_approved: "review",
      qc_rejected: "ongoing",
      completed: "completed",
      delivered: "completed",
    }
    return statusMap[status] || "new"
  }

  // Navigate to projects page with specific project highlighted
  const handleProjectClick = (projectId: string, status: string) => {
    const filter = getFilterFromStatus(status)
    router.push(`/projects?filter=${filter}&highlight=${projectId}`)
    onOpenChange(false) // Close the side panel
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="w-full sm:max-w-xl overflow-hidden flex flex-col p-0">
        <SheetHeader className="space-y-5 p-6 bg-gradient-to-br from-gray-50 to-orange-50/30 border-b border-gray-200">
          {/* Profile Header */}
          <div className="flex items-start gap-4">
            <div className="relative">
              <Avatar className="h-20 w-20 ring-4 ring-white shadow-lg">
                <AvatarImage src={user.avatar_url} alt={user.full_name} />
                <AvatarFallback className="text-xl bg-gradient-to-br from-orange-400 to-orange-600 text-white font-semibold">
                  {user.full_name
                    .split(" ")
                    .map((n) => n[0])
                    .join("")}
                </AvatarFallback>
              </Avatar>
              {isActive && (
                <span className="absolute -bottom-1 -right-1 h-5 w-5 rounded-full bg-green-500 border-4 border-white shadow-sm animate-pulse" />
              )}
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <SheetTitle className="text-left text-[#1C1C1C] text-xl">{user.full_name}</SheetTitle>
                {user.is_verified && (
                  <CheckCircle2 className="h-5 w-5 text-[#F97316]" />
                )}
              </div>
              <SheetDescription className="text-left text-gray-600 mt-1">
                {user.course ? `${user.course}${user.year ? ` - ${user.year}` : ""}` : "Client"}
              </SheetDescription>
              {onChat && (
                <Button
                  variant="outline"
                  size="sm"
                  className="mt-3 rounded-full border-[#F97316] text-[#F97316] hover:bg-orange-50"
                  onClick={() => onChat(user.id)}
                >
                  <MessageSquare className="h-3.5 w-3.5 mr-1.5" />
                  Message
                </Button>
              )}
            </div>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-4 gap-3">
            <div className="text-center p-3 bg-white rounded-xl shadow-sm border border-gray-200">
              <p className="font-bold text-lg text-[#1C1C1C]">{user.total_projects}</p>
              <p className="text-[10px] uppercase tracking-wide text-gray-500 font-medium mt-1">Projects</p>
            </div>
            <div className="text-center p-3 bg-white rounded-xl shadow-sm border border-gray-200">
              <p className="font-bold text-lg text-[#1C1C1C]">{user.active_projects}</p>
              <p className="text-[10px] uppercase tracking-wide text-gray-500 font-medium mt-1">Active</p>
            </div>
            <div className="text-center p-3 bg-white rounded-xl shadow-sm border border-gray-200">
              <p className="font-bold text-lg text-[#1C1C1C]">{user.completed_projects}</p>
              <p className="text-[10px] uppercase tracking-wide text-gray-500 font-medium mt-1">Completed</p>
            </div>
            <div className="text-center p-3 bg-gradient-to-br from-orange-50 to-amber-50 rounded-xl shadow-sm border border-orange-200">
              <p className="font-bold text-base text-[#1C1C1C]">
                {user.average_project_value.toLocaleString("en-IN", {
                  style: "currency",
                  currency: "INR",
                  maximumFractionDigits: 0,
                }).replace("₹", "₹")}
              </p>
              <p className="text-[10px] uppercase tracking-wide text-orange-600 font-medium mt-1">Avg Value</p>
            </div>
          </div>
        </SheetHeader>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="flex-1 flex flex-col overflow-hidden min-h-0">
          <div className="px-6 flex-shrink-0">
            <TabsList className="grid w-full grid-cols-2 mt-4 bg-gray-100 p-1">
              <TabsTrigger
                value="overview"
                className="data-[state=active]:bg-white data-[state=active]:text-[#F97316] data-[state=active]:shadow-sm"
              >
                Overview
              </TabsTrigger>
              <TabsTrigger
                value="projects"
                className="data-[state=active]:bg-white data-[state=active]:text-[#F97316] data-[state=active]:shadow-sm"
              >
                Projects
              </TabsTrigger>
            </TabsList>
          </div>

          <ScrollArea className="flex-1 mt-4 min-h-0" type="auto">
            <div className="px-6">
            <TabsContent value="overview" className="m-0 space-y-5 pb-6 pt-0">
              {/* Contact Info */}
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                <div className="flex items-center gap-2">
                  <div className="h-7 w-7 rounded-lg bg-orange-100 flex items-center justify-center">
                    <Mail className="h-3.5 w-3.5 text-[#F97316]" />
                  </div>
                  <h4 className="text-sm font-semibold text-[#1C1C1C]">Contact</h4>
                </div>
                <div className="space-y-2.5 ml-9">
                  <div className="flex items-center gap-2 text-sm text-gray-700">
                    <Mail className="h-4 w-4 text-gray-400" />
                    <span>{user.email}</span>
                  </div>
                  {user.phone && (
                    <div className="flex items-center gap-2 text-sm text-gray-700">
                      <Phone className="h-4 w-4 text-gray-400" />
                      <span>{user.phone}</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Academic Info */}
              {(user.college || user.course) && (
                <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                  <div className="flex items-center gap-2">
                    <div className="h-7 w-7 rounded-lg bg-blue-100 flex items-center justify-center">
                      <GraduationCap className="h-3.5 w-3.5 text-blue-600" />
                    </div>
                    <h4 className="text-sm font-semibold text-[#1C1C1C]">Academic Details</h4>
                  </div>
                  <div className="space-y-2.5 ml-9">
                    {user.college && (
                      <div className="flex items-center gap-2 text-sm text-gray-700">
                        <Building2 className="h-4 w-4 text-gray-400" />
                        <span>{user.college}</span>
                      </div>
                    )}
                    {user.course && (
                      <div className="flex items-center gap-2 text-sm text-gray-700">
                        <GraduationCap className="h-4 w-4 text-gray-400" />
                        <span>
                          {user.course}
                          {user.year && ` - ${user.year}`}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Account Info */}
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                <div className="flex items-center gap-2">
                  <div className="h-7 w-7 rounded-lg bg-purple-100 flex items-center justify-center">
                    <Calendar className="h-3.5 w-3.5 text-purple-600" />
                  </div>
                  <h4 className="text-sm font-semibold text-[#1C1C1C]">Account</h4>
                </div>
                <div className="space-y-2.5 ml-9">
                  <div className="flex items-center gap-2 text-sm text-gray-700">
                    <Calendar className="h-4 w-4 text-gray-400" />
                    <span>Joined {formatDate(user.joined_at)}</span>
                  </div>
                  {user.last_active_at && (
                    <div className="flex items-center gap-2 text-sm text-gray-700">
                      <Calendar className="h-4 w-4 text-gray-400" />
                      <span>Last active {formatDate(user.last_active_at)}</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Spending Summary */}
              <div className="bg-gradient-to-br from-orange-50 to-amber-50 rounded-xl border border-orange-200 p-4 space-y-4">
                <div className="flex items-center gap-2">
                  <div className="h-7 w-7 rounded-lg bg-orange-100 flex items-center justify-center">
                    <IndianRupee className="h-3.5 w-3.5 text-[#F97316]" />
                  </div>
                  <h4 className="text-sm font-semibold text-[#1C1C1C]">Spending Summary</h4>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="p-3.5 bg-white rounded-xl border border-orange-100 shadow-sm">
                    <div className="flex items-center gap-1.5 text-gray-500 mb-2">
                      <IndianRupee className="h-3.5 w-3.5" />
                      <span className="text-[10px] uppercase tracking-wide font-medium">Total Spent</span>
                    </div>
                    <p className="text-xl font-bold text-[#1C1C1C]">
                      {user.total_spent.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                    </p>
                  </div>
                  <div className="p-3.5 bg-white rounded-xl border border-orange-100 shadow-sm">
                    <div className="flex items-center gap-1.5 text-gray-500 mb-2">
                      <Briefcase className="h-3.5 w-3.5" />
                      <span className="text-[10px] uppercase tracking-wide font-medium">Avg Project</span>
                    </div>
                    <p className="text-xl font-bold text-[#1C1C1C]">
                      {user.average_project_value.toLocaleString("en-IN", {
                        style: "currency",
                        currency: "INR",
                        maximumFractionDigits: 0,
                      })}
                    </p>
                  </div>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="projects" className="m-0 space-y-3 pb-6 pt-0">
              {isLoadingProjects ? (
                <div className="space-y-3">
                  {[...Array(3)].map((_, i) => (
                    <div key={i} className="p-4 border border-gray-200 rounded-xl bg-white space-y-3">
                      <Skeleton className="h-4 w-24" />
                      <Skeleton className="h-5 w-48" />
                      <Skeleton className="h-3 w-32" />
                    </div>
                  ))}
                </div>
              ) : projects.length === 0 ? (
                <div className="text-center py-12 bg-white rounded-xl border border-gray-200">
                  <div className="h-16 w-16 rounded-2xl bg-orange-50 flex items-center justify-center mx-auto mb-4">
                    <Briefcase className="h-8 w-8 text-orange-500" />
                  </div>
                  <p className="text-sm text-gray-500 font-medium">No projects yet</p>
                  <p className="text-xs text-gray-400 mt-1">Projects will appear here once created</p>
                </div>
              ) : (
                projects.map((project) => (
                  <div
                    key={project.id}
                    onClick={() => handleProjectClick(project.id, project.status)}
                    className="p-4 border border-gray-200 rounded-xl bg-white space-y-3 hover:border-orange-200 hover:shadow-md transition-all cursor-pointer group"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="text-xs font-mono text-gray-400 bg-gray-100 px-2 py-0.5 rounded">
                            #{project.project_number}
                          </span>
                          <Badge className={cn("text-xs font-medium", getStatusColor(project.status))}>
                            {project.status.replace(/_/g, " ")}
                          </Badge>
                        </div>
                        <p className="font-semibold text-[#1C1C1C] mt-2 group-hover:text-[#F97316] transition-colors">
                          {project.title}
                        </p>
                        <div className="flex items-center gap-2 mt-2 flex-wrap">
                          <Badge variant="outline" className="text-xs bg-blue-50 text-blue-700 border-blue-200">
                            {project.subject}
                          </Badge>
                          <span className="text-xs text-gray-500">
                            {getServiceTypeLabel(project.service_type)}
                          </span>
                        </div>
                      </div>
                      {project.rating && (
                        <div className="flex items-center gap-1 bg-amber-50 px-2 py-1 rounded-lg">
                          <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                          <span className="text-sm font-semibold text-amber-700">{project.rating}</span>
                        </div>
                      )}
                    </div>
                    <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                      <div className="text-sm text-gray-600">
                        {project.doer_name && (
                          <span className="flex items-center gap-1.5">
                            <span className="text-gray-400">Doer:</span>
                            <span className="font-medium">{project.doer_name}</span>
                          </span>
                        )}
                      </div>
                      <span className="text-base font-bold text-[#1C1C1C]">
                        {project.user_amount.toLocaleString("en-IN", {
                          style: "currency",
                          currency: "INR",
                          maximumFractionDigits: 0,
                        })}
                      </span>
                    </div>
                    <div className="flex items-center gap-1.5 text-xs text-gray-500">
                      <Calendar className="h-3.5 w-3.5" />
                      <span>
                        {project.status === "completed"
                          ? `Completed ${formatDate(project.completed_at!)}`
                          : `Due ${formatDate(project.deadline)}`}
                      </span>
                    </div>
                  </div>
                ))
              )}
            </TabsContent>
            </div>
          </ScrollArea>
        </Tabs>
      </SheetContent>
    </Sheet>
  )
}
