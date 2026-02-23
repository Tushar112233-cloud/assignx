/**
 * @fileoverview Individual doer profile page showing doer details, stats, projects, and performance metrics.
 * @module app/(dashboard)/doers/[doerId]/page
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import { useParams, useRouter } from "next/navigation"
import {
  ArrowLeft,
  Star,
  TrendingUp,
  Clock,
  CheckCircle2,
  AlertCircle,
  Award,
  Briefcase,
  Mail,
  Phone,
  MapPin,
  Calendar,
  Ban,
  UserCheck,
} from "lucide-react"
import { createClient } from "@/lib/supabase/client"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Progress } from "@/components/ui/progress"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"

import type { DoerWithProfile, ProjectWithRelations } from "@/types/database"
import { useSupervisor } from "@/hooks"

export default function DoerDetailPage() {
  const params = useParams()
  const router = useRouter()
  const doerId = params.doerId as string

  const { supervisor } = useSupervisor()
  const [doer, setDoer] = useState<DoerWithProfile | null>(null)
  const [projects, setProjects] = useState<ProjectWithRelations[]>([])
  const [doerSubjects, setDoerSubjects] = useState<{ id: string; name: string }[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const [isBlacklisted, setIsBlacklisted] = useState(false)
  const [showBlacklistDialog, setShowBlacklistDialog] = useState(false)

  const fetchDoer = useCallback(async () => {
    const supabase = createClient()

    try {
      setIsLoading(true)
      setError(null)

      // Fetch doer details
      const { data: doerData, error: doerError } = await supabase
        .from("doers")
        .select(`
          *,
          profiles!profile_id (*)
        `)
        .eq("id", doerId)
        .single()

      if (doerError) throw doerError
      if (!doerData) throw new Error("Doer not found")

      setDoer(doerData as DoerWithProfile)

      // Fetch doer's subjects/expertise
      const { data: subjectsData } = await supabase
        .from("doer_subjects")
        .select("subjects (id, name)")
        .eq("doer_id", doerId)

      if (subjectsData) {
        setDoerSubjects(
          subjectsData
            .map((ds: { subjects: { id: string; name: string } | null }) => ds.subjects)
            .filter(Boolean) as { id: string; name: string }[]
        )
      }

      // Fetch projects for this doer
      if (supervisor?.id) {
        const { data: projectsData } = await supabase
          .from("projects")
          .select(`
            *,
            profiles!projects_user_id_fkey (*),
            subjects (*)
          `)
          .eq("doer_id", doerId)
          .eq("supervisor_id", supervisor.id)
          .order("created_at", { ascending: false })
          .limit(10)

        setProjects((projectsData as ProjectWithRelations[]) || [])

        // Check if doer is blacklisted
        const { data: blacklistData } = await supabase
          .from("supervisor_blacklisted_doers")
          .select("id")
          .eq("supervisor_id", supervisor.id)
          .eq("doer_id", doerId)
          .maybeSingle()

        setIsBlacklisted(!!blacklistData)
      }
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch doer"))
    } finally {
      setIsLoading(false)
    }
  }, [doerId, supervisor?.id])

  useEffect(() => {
    fetchDoer()
  }, [fetchDoer])

  const handleToggleBlacklist = useCallback(async () => {
    if (!supervisor?.id) {
      toast.error("Supervisor data not found")
      return
    }

    const supabase = createClient()

    try {
      if (isBlacklisted) {
        // Remove from blacklist
        const { error } = await supabase
          .from("supervisor_blacklisted_doers")
          .delete()
          .eq("supervisor_id", supervisor.id)
          .eq("doer_id", doerId)

        if (error) throw error
        toast.success("Doer removed from blacklist")
        setIsBlacklisted(false)
      } else {
        // Add to blacklist
        const { error } = await supabase
          .from("supervisor_blacklisted_doers")
          .insert({
            supervisor_id: supervisor.id,
            doer_id: doerId,
            reason: "Manually blacklisted by supervisor",
          })

        if (error) throw error
        toast.success("Doer added to blacklist")
        setIsBlacklisted(true)
      }
      setShowBlacklistDialog(false)
    } catch (err) {
      console.error("Failed to toggle blacklist:", err)
      toast.error("Failed to update blacklist status")
    }
  }, [supervisor?.id, doerId, isBlacklisted])

  const formatDate = (dateString: string | null | undefined) => {
    if (!dateString) return "N/A"
    return new Date(dateString).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
    })
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-64" />
        <div className="grid gap-6 md:grid-cols-3">
          <Skeleton className="h-48" />
          <Skeleton className="h-48" />
          <Skeleton className="h-48" />
        </div>
        <Skeleton className="h-96" />
      </div>
    )
  }

  if (error || !doer) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <AlertCircle className="h-12 w-12 text-destructive mb-4" />
        <h3 className="text-lg font-semibold">Doer Not Found</h3>
        <p className="text-sm text-muted-foreground mt-2">
          {error?.message || "The doer you're looking for doesn't exist or you don't have access."}
        </p>
        <Button onClick={() => router.push("/doers")} className="mt-4">
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to Doers
        </Button>
      </div>
    )
  }

  const completionRate = doer.total_projects_completed && doer.total_projects_completed > 0
    ? Math.round((doer.success_rate ?? 1) * 100)
    : 0

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="sm" onClick={() => router.push("/doers")}>
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back
        </Button>
        <div className="flex-1">
          <h2 className="text-2xl font-bold tracking-tight">Doer Profile</h2>
        </div>
        <Button
          variant={isBlacklisted ? "outline" : "destructive"}
          onClick={() => setShowBlacklistDialog(true)}
        >
          {isBlacklisted ? (
            <>
              <UserCheck className="h-4 w-4 mr-2" />
              Remove from Blacklist
            </>
          ) : (
            <>
              <Ban className="h-4 w-4 mr-2" />
              Add to Blacklist
            </>
          )}
        </Button>
      </div>

      {/* Profile Card */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-6">
            <Avatar className="h-24 w-24">
              <AvatarImage src={doer.profiles?.avatar_url || undefined} />
              <AvatarFallback className="text-2xl">
                {doer.profiles?.full_name?.charAt(0) || "D"}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 space-y-4">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="text-2xl font-bold">
                    {doer.profiles?.full_name || "Unknown Doer"}
                  </h3>
                  {isBlacklisted && (
                    <Badge variant="destructive">Blacklisted</Badge>
                  )}
                  {doer.is_activated ? (
                    <Badge variant="default" className="bg-green-100 text-green-700">
                      <CheckCircle2 className="h-3 w-3 mr-1" />
                      Active
                    </Badge>
                  ) : (
                    <Badge variant="secondary">Inactive</Badge>
                  )}
                  {doer.is_available && (
                    <Badge variant="outline" className="border-green-500 text-green-700">
                      Available
                    </Badge>
                  )}
                </div>
                <div className="flex items-center gap-4 text-sm text-muted-foreground">
                  {doer.profiles?.email && (
                    <span className="flex items-center gap-1">
                      <Mail className="h-3 w-3" />
                      {doer.profiles.email}
                    </span>
                  )}
                  {doer.profiles?.phone && (
                    <span className="flex items-center gap-1">
                      <Phone className="h-3 w-3" />
                      {doer.profiles.phone}
                    </span>
                  )}
                </div>
              </div>

              <div className="flex flex-wrap gap-6">
                <div className="flex items-center gap-2">
                  <Star className="h-5 w-5 text-yellow-500" />
                  <div>
                    <p className="text-2xl font-bold">
                      {doer.average_rating?.toFixed(1) || "N/A"}
                    </p>
                    <p className="text-xs text-muted-foreground">Average Rating</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Briefcase className="h-5 w-5 text-blue-500" />
                  <div>
                    <p className="text-2xl font-bold">
                      {doer.total_projects_completed || 0}
                    </p>
                    <p className="text-xs text-muted-foreground">Projects Completed</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Award className="h-5 w-5 text-purple-500" />
                  <div>
                    <p className="text-2xl font-bold">
                      ₹{doer.total_earnings?.toLocaleString("en-IN") || "0"}
                    </p>
                    <p className="text-xs text-muted-foreground">Total Earnings</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Completion Rate</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{completionRate.toFixed(0)}%</div>
            <Progress value={completionRate} className="mt-2" />
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">On-Time Delivery</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {doer.on_time_delivery_rate ? `${doer.on_time_delivery_rate.toFixed(0)}%` : "N/A"}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Based on delivery history
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Joined</CardTitle>
            <Calendar className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatDate(doer.created_at)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              Member since
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Tabs for Projects and Details */}
      <Tabs defaultValue="projects" className="space-y-4">
        <TabsList>
          <TabsTrigger value="projects">
            <Briefcase className="h-4 w-4 mr-2" />
            Projects ({projects.length})
          </TabsTrigger>
          <TabsTrigger value="skills">
            <Award className="h-4 w-4 mr-2" />
            Skills & Expertise
          </TabsTrigger>
        </TabsList>

        <TabsContent value="projects" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Recent Projects</CardTitle>
              <CardDescription>Projects assigned to this doer</CardDescription>
            </CardHeader>
            <CardContent>
              {projects.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-8 text-center">
                  <Briefcase className="h-12 w-12 text-muted-foreground/50 mb-4" />
                  <p className="text-sm text-muted-foreground">
                    No projects assigned to this doer yet
                  </p>
                </div>
              ) : (
                <div className="space-y-3">
                  {projects.map((project) => (
                    <div
                      key={project.id}
                      className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors cursor-pointer"
                      onClick={() => router.push(`/projects/${project.id}`)}
                    >
                      <div className="flex-1">
                        <p className="font-medium">{project.title}</p>
                        <p className="text-sm text-muted-foreground">
                          {project.project_number} • {project.subjects?.name || "General"}
                        </p>
                      </div>
                      <Badge className="ml-4">
                        {project.status.replace(/_/g, " ")}
                      </Badge>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="skills" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Skills & Expertise</CardTitle>
              <CardDescription>Areas of specialization</CardDescription>
            </CardHeader>
            <CardContent>
              {doerSubjects.length > 0 ? (
                <div className="flex flex-wrap gap-2">
                  {doerSubjects.map((subject) => (
                    <Badge key={subject.id} variant="secondary" className="px-3 py-1.5 text-sm">
                      <Award className="h-3.5 w-3.5 mr-1.5" />
                      {subject.name}
                    </Badge>
                  ))}
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center py-8 text-center">
                  <Award className="h-12 w-12 text-muted-foreground/50 mb-4" />
                  <p className="text-sm text-muted-foreground">
                    No subjects registered for this doer
                  </p>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Blacklist Confirmation Dialog */}
      <AlertDialog open={showBlacklistDialog} onOpenChange={setShowBlacklistDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>
              {isBlacklisted ? "Remove from Blacklist?" : "Add to Blacklist?"}
            </AlertDialogTitle>
            <AlertDialogDescription>
              {isBlacklisted
                ? "This doer will become available for project assignments again."
                : "This doer will no longer be available for your project assignments."}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleToggleBlacklist}>
              {isBlacklisted ? "Remove" : "Add"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
