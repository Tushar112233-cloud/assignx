/**
 * @fileoverview Doer details sheet component for viewing full doer profile.
 * @module components/doers/doer-details
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import { Star, Mail, Phone, Calendar, AlertTriangle, Ban, Flag, ChevronDown, ChevronUp, CheckCircle2, Loader2 } from "lucide-react"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { Progress } from "@/components/ui/progress"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from "@/components/ui/alert-dialog"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import { createClient } from "@/lib/supabase/client"
import { Doer, DoerReview, DoerProject } from "./types"

interface DoerDetailsProps {
  doer: Doer | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onBlacklistChange?: (doerId: string, blacklisted: boolean, reason?: string) => void
}

/** Format date to readable string */
const formatDate = (dateString: string) => new Date(dateString).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })

/** Get status badge color */
const getStatusColor = (status: string) => ({
  in_progress: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
  completed: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
  submitted_for_qc: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
}[status] || "bg-gray-100 text-gray-700")

/** Project card component */
function ProjectCard({ project }: { project: DoerProject }) {
  return (
    <div className="p-3 border rounded-lg space-y-2 hover:bg-muted/30 transition-colors">
      <div className="flex items-start justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-mono text-muted-foreground">{project.project_number}</span>
            <Badge className={cn("text-xs", getStatusColor(project.status))}>{project.status.replace(/_/g, " ")}</Badge>
          </div>
          <p className="font-medium mt-1">{project.title}</p>
          <p className="text-sm text-muted-foreground">{project.subject}</p>
        </div>
        {project.rating && (
          <div className="flex items-center gap-1">
            <Star className="h-4 w-4 fill-amber-400 text-amber-400" />
            <span className="text-sm font-medium">{project.rating}</span>
          </div>
        )}
      </div>
      <div className="flex items-center justify-between text-sm">
        <span className="text-muted-foreground">{project.status === "completed" ? `Completed ${formatDate(project.completed_at!)}` : `Due ${formatDate(project.deadline)}`}</span>
        <span className="font-medium text-green-600">+{project.doer_payout?.toLocaleString("en-IN", { style: "currency", currency: "INR", maximumFractionDigits: 0 })}</span>
      </div>
    </div>
  )
}

/** Review card component */
function ReviewCard({ review }: { review: DoerReview }) {
  return (
    <div className="p-3 border rounded-lg space-y-2">
      <div className="flex items-start justify-between">
        <div>
          <p className="font-medium">{review.reviewer_name}</p>
          <p className="text-xs text-muted-foreground">{review.reviewer_type === "supervisor" ? "Supervisor" : "Client"} | {formatDate(review.created_at)}</p>
        </div>
        <div className="flex items-center gap-1">
          {Array.from({ length: 5 }).map((_, i) => (
            <Star key={i} className={cn("h-4 w-4", i < review.rating ? "fill-amber-400 text-amber-400" : "text-gray-300")} />
          ))}
        </div>
      </div>
      <p className="text-sm text-muted-foreground">{review.comment}</p>
      <p className="text-xs text-muted-foreground">Project: {review.project_title}</p>
    </div>
  )
}

/**
 * Doer details sheet displaying full profile, projects and reviews.
 */
export function DoerDetails({ doer, open, onOpenChange, onBlacklistChange }: DoerDetailsProps) {
  const [blacklistReason, setBlacklistReason] = useState("")
  const [showAllSkills, setShowAllSkills] = useState(false)
  const [activeTab, setActiveTab] = useState("overview")
  const [reviews, setReviews] = useState<DoerReview[]>([])
  const [projects, setProjects] = useState<DoerProject[]>([])
  const [isLoadingReviews, setIsLoadingReviews] = useState(false)
  const [isLoadingProjects, setIsLoadingProjects] = useState(false)

  // Fetch doer reviews from Supabase
  const fetchReviews = useCallback(async (doerId: string) => {
    const supabase = createClient()
    setIsLoadingReviews(true)
    try {
      const { data, error } = await supabase
        .from("doer_reviews")
        .select(`
          id,
          overall_rating,
          review_text,
          reviewer_type,
          created_at,
          project_id,
          projects (
            project_number,
            title
          ),
          profiles:reviewer_id (
            full_name
          )
        `)
        .eq("doer_id", doerId)
        .eq("is_public", true)
        .order("created_at", { ascending: false })
        .limit(20)

      if (error) throw error

      const formattedReviews: DoerReview[] = (data || []).map((review) => ({
        id: review.id,
        doer_id: doerId,
        project_id: review.project_id || "",
        project_number: (review.projects as { project_number?: string })?.project_number || "",
        project_title: (review.projects as { title?: string })?.title || "Unknown Project",
        reviewer_name: (review.profiles as { full_name?: string })?.full_name || "Anonymous",
        reviewer_type: review.reviewer_type as "user" | "supervisor",
        rating: review.overall_rating,
        comment: review.review_text || "",
        created_at: review.created_at || new Date().toISOString(),
      }))

      setReviews(formattedReviews)
    } catch (error) {
      console.error("Error fetching doer reviews:", error)
      setReviews([])
    } finally {
      setIsLoadingReviews(false)
    }
  }, [])

  // Fetch doer projects from Supabase
  const fetchProjects = useCallback(async (doerId: string) => {
    const supabase = createClient()
    setIsLoadingProjects(true)
    try {
      const { data, error } = await supabase
        .from("projects")
        .select(`
          id,
          project_number,
          title,
          status,
          deadline,
          doer_assigned_at,
          completed_at,
          doer_payout,
          subjects (
            name
          )
        `)
        .eq("doer_id", doerId)
        .order("created_at", { ascending: false })
        .limit(20)

      if (error) throw error

      // Get ratings for completed projects
      const projectIds = (data || []).filter(p => p.status === "completed").map(p => p.id)
      let ratingsMap: Record<string, number> = {}

      if (projectIds.length > 0) {
        const { data: reviewsData } = await supabase
          .from("doer_reviews")
          .select("project_id, overall_rating")
          .in("project_id", projectIds)

        ratingsMap = (reviewsData || []).reduce((acc, r) => {
          if (r.project_id) acc[r.project_id] = r.overall_rating
          return acc
        }, {} as Record<string, number>)
      }

      const formattedProjects: DoerProject[] = (data || []).map((project) => ({
        id: project.id,
        project_number: project.project_number,
        title: project.title,
        subject: (project.subjects as { name?: string })?.name || "",
        status: project.status,
        deadline: project.deadline,
        assigned_at: project.doer_assigned_at || undefined,
        completed_at: project.completed_at || undefined,
        doer_payout: project.doer_payout || undefined,
        rating: ratingsMap[project.id] || undefined,
      }))

      setProjects(formattedProjects)
    } catch (error) {
      console.error("Error fetching doer projects:", error)
      setProjects([])
    } finally {
      setIsLoadingProjects(false)
    }
  }, [])

  // Fetch data when doer changes or sheet opens
  useEffect(() => {
    if (open && doer?.id) {
      fetchReviews(doer.id)
      fetchProjects(doer.id)
    }
  }, [open, doer?.id, fetchReviews, fetchProjects])

  if (!doer) return null

  const handleBlacklist = () => {
    if (!blacklistReason.trim()) {
      toast.error("Please provide a reason for blacklisting")
      return
    }
    onBlacklistChange?.(doer.id, true, blacklistReason)
    toast.success(`${doer.full_name} has been blacklisted`)
    setBlacklistReason("")
  }

  const handleRemoveBlacklist = () => {
    onBlacklistChange?.(doer.id, false)
    toast.success(`${doer.full_name} has been removed from blacklist`)
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="w-full sm:max-w-xl overflow-hidden flex flex-col">
        <SheetHeader className="space-y-4">
          <div className="flex items-start gap-4">
            <div className="relative">
              <Avatar className="h-16 w-16">
                <AvatarImage src={doer.avatar_url} alt={doer.full_name} />
                <AvatarFallback className="text-lg">{doer.full_name.split(" ").map((n) => n[0]).join("")}</AvatarFallback>
              </Avatar>
              {doer.is_available && !doer.is_blacklisted && <span className="absolute -bottom-1 -right-1 h-4 w-4 rounded-full bg-green-500 border-2 border-background" />}
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <SheetTitle className="text-left">{doer.full_name}</SheetTitle>
                {doer.is_verified && <CheckCircle2 className="h-5 w-5 text-blue-500" />}
                {doer.is_blacklisted && <Badge variant="destructive" className="gap-1"><Ban className="h-3 w-3" />Blacklisted</Badge>}
              </div>
              <SheetDescription className="text-left">{doer.qualification} | {doer.years_of_experience}+ years experience</SheetDescription>
            </div>
          </div>
          <div className="grid grid-cols-4 gap-2">
            <div className="text-center p-2 bg-muted/50 rounded-lg">
              <div className="flex items-center justify-center gap-1"><Star className="h-4 w-4 fill-amber-400 text-amber-400" /><span className="font-bold">{doer.rating.toFixed(1)}</span></div>
              <p className="text-xs text-muted-foreground">Rating</p>
            </div>
            <div className="text-center p-2 bg-muted/50 rounded-lg"><p className="font-bold">{doer.completed_projects}</p><p className="text-xs text-muted-foreground">Completed</p></div>
            <div className="text-center p-2 bg-muted/50 rounded-lg"><p className="font-bold">{doer.success_rate}%</p><p className="text-xs text-muted-foreground">Success</p></div>
            <div className="text-center p-2 bg-muted/50 rounded-lg"><p className="font-bold">{doer.active_projects}</p><p className="text-xs text-muted-foreground">Active</p></div>
          </div>
        </SheetHeader>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="flex-1 flex flex-col overflow-hidden mt-4">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="projects">Projects</TabsTrigger>
            <TabsTrigger value="reviews">Reviews</TabsTrigger>
          </TabsList>

          <ScrollArea className="flex-1 mt-4">
            <TabsContent value="overview" className="m-0 space-y-4">
              {doer.bio && <div className="space-y-2"><h4 className="text-sm font-medium">About</h4><p className="text-sm text-muted-foreground">{doer.bio}</p></div>}
              <div className="space-y-2">
                <h4 className="text-sm font-medium">Contact</h4>
                <div className="space-y-1">
                  <div className="flex items-center gap-2 text-sm"><Mail className="h-4 w-4 text-muted-foreground" /><span>{doer.email}</span></div>
                  {doer.phone && <div className="flex items-center gap-2 text-sm"><Phone className="h-4 w-4 text-muted-foreground" /><span>{doer.phone}</span></div>}
                  <div className="flex items-center gap-2 text-sm"><Calendar className="h-4 w-4 text-muted-foreground" /><span>Joined {formatDate(doer.joined_at)}</span></div>
                </div>
              </div>
              <Separator />
              <Collapsible open={showAllSkills} onOpenChange={setShowAllSkills}>
                <div className="flex items-center justify-between">
                  <h4 className="text-sm font-medium">Skills ({doer.skills.length})</h4>
                  <CollapsibleTrigger asChild>
                    <Button variant="ghost" size="sm">{showAllSkills ? <>Show Less <ChevronUp className="h-4 w-4 ml-1" /></> : <>Show All <ChevronDown className="h-4 w-4 ml-1" /></>}</Button>
                  </CollapsibleTrigger>
                </div>
                <div className="flex flex-wrap gap-1 mt-2">{doer.skills.slice(0, 5).map((skill) => <Badge key={skill} variant="secondary">{skill}</Badge>)}</div>
                <CollapsibleContent><div className="flex flex-wrap gap-1 mt-1">{doer.skills.slice(5).map((skill) => <Badge key={skill} variant="secondary">{skill}</Badge>)}</div></CollapsibleContent>
              </Collapsible>
              <div className="space-y-2">
                <h4 className="text-sm font-medium">Subjects</h4>
                <div className="flex flex-wrap gap-1">{doer.subjects.map((subject) => <Badge key={subject} variant="outline">{subject}</Badge>)}</div>
              </div>
              <Separator />
              <div className="space-y-3">
                <h4 className="text-sm font-medium">Performance</h4>
                <div className="space-y-3">
                  <div>
                    <div className="flex justify-between text-sm mb-1"><span className="text-muted-foreground">Success Rate</span><span className="font-medium">{doer.success_rate}%</span></div>
                    <Progress value={doer.success_rate} className="h-2" />
                  </div>
                  {doer.average_response_time && <div className="flex justify-between text-sm"><span className="text-muted-foreground">Avg Response Time</span><span className="font-medium">{doer.average_response_time}</span></div>}
                </div>
              </div>
              <Separator />
              {doer.is_blacklisted ? (
                <div className="space-y-3 p-3 border border-destructive/50 bg-destructive/5 rounded-lg">
                  <div className="flex items-start gap-2">
                    <AlertTriangle className="h-5 w-5 text-destructive shrink-0 mt-0.5" />
                    <div>
                      <p className="font-medium text-destructive">This doer is blacklisted</p>
                      {doer.blacklist_reason && <p className="text-sm text-muted-foreground mt-1">Reason: {doer.blacklist_reason}</p>}
                    </div>
                  </div>
                  <AlertDialog>
                    <AlertDialogTrigger asChild><Button variant="outline" size="sm" className="w-full">Remove from Blacklist</Button></AlertDialogTrigger>
                    <AlertDialogContent>
                      <AlertDialogHeader>
                        <AlertDialogTitle>Remove from Blacklist?</AlertDialogTitle>
                        <AlertDialogDescription>This will allow {doer.full_name} to be assigned to new projects again.</AlertDialogDescription>
                      </AlertDialogHeader>
                      <AlertDialogFooter>
                        <AlertDialogCancel>Cancel</AlertDialogCancel>
                        <AlertDialogAction onClick={handleRemoveBlacklist}>Remove</AlertDialogAction>
                      </AlertDialogFooter>
                    </AlertDialogContent>
                  </AlertDialog>
                </div>
              ) : (
                <AlertDialog>
                  <AlertDialogTrigger asChild>
                    <Button variant="outline" className="w-full text-destructive hover:text-destructive"><Flag className="h-4 w-4 mr-2" />Add to Blacklist</Button>
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle>Add to Blacklist?</AlertDialogTitle>
                      <AlertDialogDescription>This will prevent {doer.full_name} from being assigned to your projects. Please provide a reason.</AlertDialogDescription>
                    </AlertDialogHeader>
                    <div className="py-4">
                      <Label htmlFor="reason">Reason for blacklisting</Label>
                      <Textarea id="reason" placeholder="e.g., Missed deadlines, poor quality work..." value={blacklistReason} onChange={(e) => setBlacklistReason(e.target.value)} className="mt-2" />
                    </div>
                    <AlertDialogFooter>
                      <AlertDialogCancel onClick={() => setBlacklistReason("")}>Cancel</AlertDialogCancel>
                      <AlertDialogAction onClick={handleBlacklist} className="bg-destructive hover:bg-destructive/90">Add to Blacklist</AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              )}
            </TabsContent>

            <TabsContent value="projects" className="m-0 space-y-3">
              {isLoadingProjects ? (
                <div className="flex items-center justify-center py-8">
                  <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
                </div>
              ) : projects.length > 0 ? (
                projects.map((project) => <ProjectCard key={project.id} project={project} />)
              ) : (
                <div className="text-center py-8 text-muted-foreground">
                  <p>No projects found</p>
                </div>
              )}
            </TabsContent>

            <TabsContent value="reviews" className="m-0 space-y-3">
              {isLoadingReviews ? (
                <div className="flex items-center justify-center py-8">
                  <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
                </div>
              ) : reviews.length > 0 ? (
                reviews.map((review) => <ReviewCard key={review.id} review={review} />)
              ) : (
                <div className="text-center py-8 text-muted-foreground">
                  <p>No reviews yet</p>
                </div>
              )}
            </TabsContent>
          </ScrollArea>
        </Tabs>
      </SheetContent>
    </Sheet>
  )
}
