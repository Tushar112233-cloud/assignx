/**
 * @fileoverview Training library component for supervisor training videos.
 * @module components/resources/training-library
 */

"use client"

import { useState, useMemo, useEffect, useCallback } from "react"
import { Play, Clock, CheckCircle2, Filter, Search, BookOpen, Award, Loader2 } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"
import { TrainingVideo, TrainingCategory, TrainingProgress, TRAINING_CATEGORIES } from "./types"
import { createClient } from "@/lib/supabase/client"

const DIFFICULTY_COLORS = {
  beginner: "bg-green-100 text-green-700",
  intermediate: "bg-amber-100 text-amber-700",
  advanced: "bg-red-100 text-red-700",
}

/** Map content_type to TrainingCategory */
function mapContentTypeToCategory(contentType: string, sequenceOrder: number): TrainingCategory {
  const typeMap: Record<string, TrainingCategory> = {
    video: "onboarding",
    document: "tools",
    pdf: "qc_process",
    interactive: "communication",
  }

  if (sequenceOrder <= 2) return "onboarding"
  if (sequenceOrder <= 4) return "qc_process"
  if (sequenceOrder <= 6) return "communication"
  if (sequenceOrder <= 8) return "tools"
  return typeMap[contentType] || "advanced"
}

/** Get difficulty based on sequence order */
function getDifficulty(sequenceOrder: number): "beginner" | "intermediate" | "advanced" {
  if (sequenceOrder <= 3) return "beginner"
  if (sequenceOrder <= 6) return "intermediate"
  return "advanced"
}

/** Format duration from minutes to display string */
function formatDuration(minutes: number | null): string {
  if (!minutes) return "0:00"
  const mins = Math.floor(minutes)
  const secs = Math.round((minutes - mins) * 60)
  return `${mins}:${secs.toString().padStart(2, "0")}`
}

/** Video card component */
function VideoCard({ video, onPlay }: { video: TrainingVideo; onPlay: (v: TrainingVideo) => void }) {
  return (
    <Card className={cn("transition-all hover:shadow-md cursor-pointer group", video.is_completed && "border-green-500/30 bg-green-50/30")} onClick={() => onPlay(video)}>
      <CardContent className="p-4">
        <div className="flex gap-4">
          <div className="relative shrink-0 w-32 h-20 rounded-lg bg-muted overflow-hidden">
            <div className="absolute inset-0 flex items-center justify-center bg-black/30 group-hover:bg-black/50 transition-colors">
              {video.is_completed ? <CheckCircle2 className="h-8 w-8 text-green-500" /> : <Play className="h-8 w-8 text-white" />}
            </div>
            <div className="absolute bottom-1 right-1 px-1.5 py-0.5 rounded text-[10px] font-medium bg-black/70 text-white">{video.duration}</div>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2 mb-1">
              <h4 className="font-medium text-sm line-clamp-1">{video.title}</h4>
              {video.is_required && <Badge variant="outline" className="shrink-0 text-[10px]">Required</Badge>}
            </div>
            <p className="text-xs text-muted-foreground line-clamp-2 mb-2">{video.description}</p>
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className={cn("text-[10px]", DIFFICULTY_COLORS[video.difficulty])}>{video.difficulty}</Badge>
              <Badge variant="outline" className="text-[10px]">{TRAINING_CATEGORIES[video.category].label}</Badge>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

/** Video player dialog */
function VideoPlayerDialog({
  video,
  open,
  onOpenChange,
  onMarkComplete,
  isMarkingComplete
}: {
  video: TrainingVideo | null
  open: boolean
  onOpenChange: (o: boolean) => void
  onMarkComplete: (id: string) => void
  isMarkingComplete?: boolean
}) {
  if (!video) return null
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl">
        <DialogHeader><DialogTitle>{video.title}</DialogTitle></DialogHeader>
        <div className="space-y-4">
          <div className="relative aspect-video bg-black rounded-lg overflow-hidden flex items-center justify-center">
            {video.video_url ? (
              <iframe
                src={video.video_url}
                className="absolute inset-0 w-full h-full"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              />
            ) : (
              <div className="text-center text-white">
                <Play className="h-16 w-16 mx-auto mb-2 opacity-50" />
                <p className="text-sm opacity-70">Video Player Placeholder</p>
                <p className="text-xs opacity-50">Duration: {video.duration}</p>
              </div>
            )}
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">{video.description}</p>
              <div className="flex items-center gap-2 mt-2">
                <Badge variant="secondary">{TRAINING_CATEGORIES[video.category].label}</Badge>
                <Badge variant="outline">{video.difficulty}</Badge>
                <div className="flex items-center gap-1 text-xs text-muted-foreground"><Clock className="h-3 w-3" />{video.duration}</div>
              </div>
            </div>
            {!video.is_completed && (
              <Button onClick={() => onMarkComplete(video.id)} disabled={isMarkingComplete}>
                {isMarkingComplete ? (
                  <><Loader2 className="h-4 w-4 mr-2 animate-spin" />Saving...</>
                ) : (
                  <><CheckCircle2 className="h-4 w-4 mr-2" />Mark as Complete</>
                )}
              </Button>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}

/** Progress stats cards */
function ProgressCards({ progress, isLoading }: { progress: TrainingProgress; isLoading?: boolean }) {
  return (
    <div className="grid gap-4 md:grid-cols-3">
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center"><BookOpen className="h-6 w-6 text-primary" /></div>
            <div className="flex-1">
              <p className="text-sm text-muted-foreground">Total Progress</p>
              <div className="flex items-center gap-2">
                <Progress value={isLoading ? 0 : progress.completion_percentage} className="flex-1 h-2" />
                <span className="text-sm font-medium">{isLoading ? "-" : `${progress.completion_percentage}%`}</span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-full bg-green-100 flex items-center justify-center"><CheckCircle2 className="h-6 w-6 text-green-600" /></div>
            <div>
              <p className="text-sm text-muted-foreground">Completed</p>
              <p className="text-2xl font-bold">
                {isLoading ? "-" : progress.completed_videos}
                <span className="text-sm font-normal text-muted-foreground">/{isLoading ? "-" : progress.total_videos}</span>
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-full bg-amber-100 flex items-center justify-center"><Award className="h-6 w-6 text-amber-600" /></div>
            <div>
              <p className="text-sm text-muted-foreground">Required</p>
              <p className="text-2xl font-bold">
                {isLoading ? "-" : progress.required_completed}
                <span className="text-sm font-normal text-muted-foreground">/{isLoading ? "-" : progress.required_videos}</span>
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

/**
 * Training library component displaying training videos for supervisors.
 */
export function TrainingLibrary() {
  const [videos, setVideos] = useState<TrainingVideo[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [isMarkingComplete, setIsMarkingComplete] = useState(false)
  const [selectedCategory, setSelectedCategory] = useState<string>("all")
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedVideo, setSelectedVideo] = useState<TrainingVideo | null>(null)
  const [playerOpen, setPlayerOpen] = useState(false)

  const fetchTrainingData = useCallback(async () => {
    const supabase = createClient()

    try {
      // Get current user
      const { data: { user } } = await supabase.auth.getUser()

      // Fetch training modules
      const { data: modules, error: modulesError } = await supabase
        .from("training_modules")
        .select("*")
        .eq("is_active", true)
        .order("sequence_order", { ascending: true })

      if (modulesError) {
        console.error("Error fetching training modules:", modulesError)
        return
      }

      // Fetch user's progress if logged in
      let progressMap: Record<string, { status: string; completed_at: string | null }> = {}

      if (user) {
        const { data: progressData, error: progressError } = await supabase
          .from("training_progress")
          .select("module_id, status, completed_at")
          .eq("profile_id", user.id)

        if (!progressError && progressData) {
          progressMap = progressData.reduce((acc, p) => {
            acc[p.module_id] = { status: p.status || "not_started", completed_at: p.completed_at }
            return acc
          }, {} as Record<string, { status: string; completed_at: string | null }>)
        }
      }

      // Transform to TrainingVideo format
      const transformedVideos: TrainingVideo[] = (modules || []).map((module) => ({
        id: module.id,
        title: module.title,
        description: module.description || "",
        duration: formatDuration(module.duration_minutes),
        thumbnail_url: undefined,
        video_url: module.content_url || "",
        category: mapContentTypeToCategory(module.content_type, module.sequence_order),
        difficulty: getDifficulty(module.sequence_order),
        is_required: module.is_mandatory || false,
        is_completed: progressMap[module.id]?.status === "completed",
        completed_at: progressMap[module.id]?.completed_at || undefined,
        order: module.sequence_order,
      }))

      setVideos(transformedVideos)
    } catch (error) {
      console.error("Error fetching training data:", error)
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchTrainingData()
  }, [fetchTrainingData])

  const progress: TrainingProgress = useMemo(() => {
    if (videos.length === 0) {
      return {
        total_videos: 0,
        completed_videos: 0,
        required_videos: 0,
        required_completed: 0,
        completion_percentage: 0,
      }
    }
    return {
      total_videos: videos.length,
      completed_videos: videos.filter((v) => v.is_completed).length,
      required_videos: videos.filter((v) => v.is_required).length,
      required_completed: videos.filter((v) => v.is_required && v.is_completed).length,
      completion_percentage: Math.round((videos.filter((v) => v.is_completed).length / videos.length) * 100),
    }
  }, [videos])

  const filteredVideos = useMemo(() => {
    return videos.filter((video) => {
      const matchesCategory = selectedCategory === "all" || video.category === selectedCategory
      const matchesSearch = !searchQuery || video.title.toLowerCase().includes(searchQuery.toLowerCase()) || video.description.toLowerCase().includes(searchQuery.toLowerCase())
      return matchesCategory && matchesSearch
    })
  }, [videos, selectedCategory, searchQuery])

  const groupedVideos = useMemo(() => {
    return filteredVideos.reduce((acc, video) => {
      if (!acc[video.category]) acc[video.category] = []
      acc[video.category].push(video)
      return acc
    }, {} as Record<TrainingCategory, TrainingVideo[]>)
  }, [filteredVideos])

  const handlePlayVideo = (video: TrainingVideo) => {
    setSelectedVideo(video)
    setPlayerOpen(true)
  }

  const handleMarkComplete = async (videoId: string) => {
    const supabase = createClient()
    setIsMarkingComplete(true)

    try {
      const { data: { user } } = await supabase.auth.getUser()

      if (!user) {
        console.error("User not authenticated")
        return
      }

      // Upsert training progress
      const { error } = await supabase
        .from("training_progress")
        .upsert({
          profile_id: user.id,
          module_id: videoId,
          status: "completed",
          progress_percentage: 100,
          completed_at: new Date().toISOString(),
        }, {
          onConflict: "profile_id,module_id"
        })

      if (error) {
        console.error("Error updating training progress:", error)
        return
      }

      // Update local state
      setVideos((prev) => prev.map((v) =>
        v.id === videoId
          ? { ...v, is_completed: true, completed_at: new Date().toISOString() }
          : v
      ))
      setPlayerOpen(false)
    } catch (error) {
      console.error("Error marking video as complete:", error)
    } finally {
      setIsMarkingComplete(false)
    }
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        <ProgressCards progress={{ total_videos: 0, completed_videos: 0, required_videos: 0, required_completed: 0, completion_percentage: 0 }} isLoading />
        <div className="flex items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
          <span className="ml-2 text-muted-foreground">Loading training modules...</span>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <ProgressCards progress={progress} />
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input placeholder="Search training videos..." value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} className="pl-9" />
            </div>
            <Select value={selectedCategory} onValueChange={setSelectedCategory}>
              <SelectTrigger className="w-[200px]"><Filter className="h-4 w-4 mr-2" /><SelectValue placeholder="Filter by category" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Categories</SelectItem>
                {Object.entries(TRAINING_CATEGORIES).map(([key, config]) => <SelectItem key={key} value={key}>{config.label}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      <ScrollArea className="h-[calc(100vh-24rem)]">
        {selectedCategory === "all" ? (
          <div className="space-y-6">
            {Object.entries(groupedVideos).map(([category, categoryVideos]) => (
              <div key={category}>
                <div className="flex items-center gap-2 mb-3">
                  <h3 className="font-semibold">{TRAINING_CATEGORIES[category as TrainingCategory].label}</h3>
                  <Badge variant="secondary" className="text-xs">{categoryVideos.length}</Badge>
                </div>
                <div className="grid gap-3 md:grid-cols-2">{categoryVideos.map((video) => <VideoCard key={video.id} video={video} onPlay={handlePlayVideo} />)}</div>
              </div>
            ))}
          </div>
        ) : (
          <div className="grid gap-3 md:grid-cols-2">{filteredVideos.map((video) => <VideoCard key={video.id} video={video} onPlay={handlePlayVideo} />)}</div>
        )}
        {filteredVideos.length === 0 && (
          <div className="flex flex-col items-center justify-center py-12 text-center">
            <BookOpen className="h-12 w-12 text-muted-foreground/50 mb-4" />
            <h3 className="text-lg font-medium">No videos found</h3>
            <p className="text-sm text-muted-foreground mt-1">Try adjusting your search or filter</p>
          </div>
        )}
      </ScrollArea>

      <VideoPlayerDialog
        video={selectedVideo}
        open={playerOpen}
        onOpenChange={setPlayerOpen}
        onMarkComplete={handleMarkComplete}
        isMarkingComplete={isMarkingComplete}
      />
    </div>
  )
}
