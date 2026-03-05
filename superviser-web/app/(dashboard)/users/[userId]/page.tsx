/**
 * @fileoverview Individual user/client profile page showing user details, project history, and account information.
 * @module app/(dashboard)/users/[userId]/page
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import { useParams, useRouter } from "next/navigation"
import {
  ArrowLeft,
  User,
  Mail,
  Phone,
  MapPin,
  Calendar,
  Briefcase,
  DollarSign,
  TrendingUp,
  AlertCircle,
  FileText,
  Clock,
} from "lucide-react"
import { apiFetch } from "@/lib/api/client"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

import type { ProjectWithRelations } from "@/types/database"
import { useSupervisor } from "@/hooks"

export default function UserDetailPage() {
  const params = useParams()
  const router = useRouter()
  const userId = params.userId as string

  const { supervisor } = useSupervisor()
  const [user, setUser] = useState<any | null>(null)
  const [projects, setProjects] = useState<ProjectWithRelations[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchUser = useCallback(async () => {
    try {
      setIsLoading(true)
      setError(null)

      // Fetch user profile
      const rawUser = await apiFetch<any>(`/api/users/${userId}`)
      const userData = rawUser?.user || rawUser
      if (!userData) throw new Error("User not found")
      setUser(userData)

      // Fetch projects for this user
      if (supervisor?.id) {
        const projectsData = await apiFetch<{ projects: ProjectWithRelations[] }>(
          `/api/projects?userId=${userId}&supervisorId=me&sort=-created_at`
        )

        setProjects(projectsData.projects || [])
      }
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Failed to fetch user"))
    } finally {
      setIsLoading(false)
    }
  }, [userId, supervisor?.id])

  useEffect(() => {
    fetchUser()
  }, [fetchUser])

  const formatDate = (dateString: string | null | undefined) => {
    if (!dateString) return "N/A"
    return new Date(dateString).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
    })
  }

  const getStatusColor = (status: string) => {
    const statusColors: Record<string, string> = {
      submitted: "bg-blue-100 text-blue-700",
      analyzing: "bg-purple-100 text-purple-700",
      quoted: "bg-indigo-100 text-indigo-700",
      paid: "bg-green-100 text-green-700",
      assigned: "bg-cyan-100 text-cyan-700",
      in_progress: "bg-yellow-100 text-yellow-700",
      submitted_for_qc: "bg-orange-100 text-orange-700",
      qc_approved: "bg-emerald-100 text-emerald-700",
      completed: "bg-green-100 text-green-700",
    }
    return statusColors[status] || "bg-gray-100 text-gray-700"
  }

  // Calculate user stats
  const totalSpent = projects.reduce((sum, p) => {
    const proj = p as Record<string, unknown>
    const pricing = proj.pricing as Record<string, unknown> | undefined
    return sum + ((proj.userQuote as number) || p.user_quote || (pricing?.userQuote as number) || 0)
  }, 0)
  const completedProjects = projects.filter(p =>
    p.status === "completed" || p.status === "auto_approved"
  ).length
  const activeProjects = projects.filter(p =>
    p.status === "in_progress" || p.status === "assigned" || p.status === "submitted_for_qc"
  ).length

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

  if (error || !user) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <AlertCircle className="h-12 w-12 text-destructive mb-4" />
        <h3 className="text-lg font-semibold">User Not Found</h3>
        <p className="text-sm text-muted-foreground mt-2">
          {error?.message || "The user you're looking for doesn't exist or you don't have access."}
        </p>
        <Button onClick={() => router.push("/users")} className="mt-4">
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to Users
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="sm" onClick={() => router.push("/users")}>
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back
        </Button>
        <div className="flex-1">
          <h2 className="text-2xl font-bold tracking-tight">Client Profile</h2>
        </div>
      </div>

      {/* Profile Card */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-6">
            <Avatar className="h-24 w-24">
              <AvatarImage src={user.avatar_url || undefined} />
              <AvatarFallback className="text-2xl">
                {user.full_name?.charAt(0) || "U"}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 space-y-4">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="text-2xl font-bold">
                    {user.full_name || "Unknown User"}
                  </h3>
                  <Badge variant="outline" className="capitalize">
                    {user.user_type || "User"}
                  </Badge>
                </div>
                <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
                  {user.email && (
                    <span className="flex items-center gap-1">
                      <Mail className="h-3 w-3" />
                      {user.email}
                    </span>
                  )}
                  {user.phone && (
                    <span className="flex items-center gap-1">
                      <Phone className="h-3 w-3" />
                      {user.phone}
                    </span>
                  )}
                  {(user.city || user.country) && (
                    <span className="flex items-center gap-1">
                      <MapPin className="h-3 w-3" />
                      {[user.city, user.country].filter(Boolean).join(", ")}
                    </span>
                  )}
                </div>
              </div>

              <div className="flex flex-wrap gap-6">
                <div className="flex items-center gap-2">
                  <Briefcase className="h-5 w-5 text-blue-500" />
                  <div>
                    <p className="text-2xl font-bold">{projects.length}</p>
                    <p className="text-xs text-muted-foreground">Total Projects</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <TrendingUp className="h-5 w-5 text-green-500" />
                  <div>
                    <p className="text-2xl font-bold">{completedProjects}</p>
                    <p className="text-xs text-muted-foreground">Completed</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Clock className="h-5 w-5 text-orange-500" />
                  <div>
                    <p className="text-2xl font-bold">{activeProjects}</p>
                    <p className="text-xs text-muted-foreground">Active</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <DollarSign className="h-5 w-5 text-purple-500" />
                  <div>
                    <p className="text-2xl font-bold">₹{totalSpent.toLocaleString("en-IN")}</p>
                    <p className="text-xs text-muted-foreground">Total Spent</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Account Details */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Member Since</CardTitle>
            <Calendar className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatDate(user.created_at)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              Account creation date
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Last Active</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatDate(user.updated_at)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              Last profile update
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Account Type</CardTitle>
            <User className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold capitalize">
              {user.user_type || "Standard"}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              User account type
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Projects Tab */}
      <Tabs defaultValue="all" className="space-y-4">
        <TabsList>
          <TabsTrigger value="all">
            <FileText className="h-4 w-4 mr-2" />
            All Projects ({projects.length})
          </TabsTrigger>
          <TabsTrigger value="active">
            <Clock className="h-4 w-4 mr-2" />
            Active ({activeProjects})
          </TabsTrigger>
          <TabsTrigger value="completed">
            <TrendingUp className="h-4 w-4 mr-2" />
            Completed ({completedProjects})
          </TabsTrigger>
        </TabsList>

        <TabsContent value="all" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Project History</CardTitle>
              <CardDescription>All projects for this client</CardDescription>
            </CardHeader>
            <CardContent>
              {projects.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-8 text-center">
                  <FileText className="h-12 w-12 text-muted-foreground/50 mb-4" />
                  <p className="text-sm text-muted-foreground">
                    No projects found for this client
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
                          {project.project_number} • {project.subjects?.name || "General"} •
                          {project.doers?.full_name ? ` Assigned to ${project.doers.full_name}` : " Unassigned"}
                        </p>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-sm font-medium">₹{(project.user_quote || 0).toLocaleString("en-IN")}</span>
                        <Badge className={getStatusColor(project.status)}>
                          {project.status.replace(/_/g, " ")}
                        </Badge>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="active" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Active Projects</CardTitle>
              <CardDescription>Projects currently in progress</CardDescription>
            </CardHeader>
            <CardContent>
              {activeProjects === 0 ? (
                <div className="flex flex-col items-center justify-center py-8 text-center">
                  <Clock className="h-12 w-12 text-muted-foreground/50 mb-4" />
                  <p className="text-sm text-muted-foreground">
                    No active projects
                  </p>
                </div>
              ) : (
                <div className="space-y-3">
                  {projects
                    .filter(p =>
                      p.status === "in_progress" || p.status === "assigned" || p.status === "submitted_for_qc"
                    )
                    .map((project) => (
                      <div
                        key={project.id}
                        className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors cursor-pointer"
                        onClick={() => router.push(`/projects/${project.id}`)}
                      >
                        <div className="flex-1">
                          <p className="font-medium">{project.title}</p>
                          <p className="text-sm text-muted-foreground">
                            {project.project_number} • Deadline: {formatDate(project.deadline)}
                          </p>
                        </div>
                        <Badge className={getStatusColor(project.status)}>
                          {project.status.replace(/_/g, " ")}
                        </Badge>
                      </div>
                    ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="completed" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Completed Projects</CardTitle>
              <CardDescription>Successfully completed projects</CardDescription>
            </CardHeader>
            <CardContent>
              {completedProjects === 0 ? (
                <div className="flex flex-col items-center justify-center py-8 text-center">
                  <TrendingUp className="h-12 w-12 text-muted-foreground/50 mb-4" />
                  <p className="text-sm text-muted-foreground">
                    No completed projects yet
                  </p>
                </div>
              ) : (
                <div className="space-y-3">
                  {projects
                    .filter(p => p.status === "completed" || p.status === "auto_approved")
                    .map((project) => (
                      <div
                        key={project.id}
                        className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors cursor-pointer"
                        onClick={() => router.push(`/projects/${project.id}`)}
                      >
                        <div className="flex-1">
                          <p className="font-medium">{project.title}</p>
                          <p className="text-sm text-muted-foreground">
                            {project.project_number} • Completed: {formatDate(project.completed_at)}
                          </p>
                        </div>
                        <span className="text-sm font-medium">₹{(project.user_quote || 0).toLocaleString("en-IN")}</span>
                      </div>
                    ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
