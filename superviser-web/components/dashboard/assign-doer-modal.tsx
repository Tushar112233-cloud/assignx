/**
 * @fileoverview Modal for selecting and assigning doers to projects.
 * Supports two modes: selecting a specific expert or sending to the open pool.
 * @module components/dashboard/assign-doer-modal
 */

"use client"

import { useState, useEffect, useMemo } from "react"
import {
  Search,
  Star,
  Clock,
  CheckCircle2,
  Loader2,
  User,
  BookOpen,
  Filter,
  X,
  AlertCircle,
  Users,
  Globe,
  Info,
} from "lucide-react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { ScrollArea } from "@/components/ui/scroll-area"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"
import { apiFetch } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { toast } from "sonner"
import { cn } from "@/lib/utils"
import type { PaidProject } from "./ready-to-assign-card"

export interface Doer {
  id: string
  full_name: string
  avatar_url?: string | null
  email: string
  rating: number
  total_projects: number
  success_rate: number
  is_available: boolean
  skills: string[]
  subjects: string[]
  response_time_hours: number
  last_active: string
}

type AssignMode = "select-expert" | "open-pool"

interface AssignDoerModalProps {
  project: PaidProject | null
  isOpen: boolean
  onClose: () => void
  onAssign: (projectId: string, doerId: string) => void
}

export function AssignDoerModal({
  project,
  isOpen,
  onClose,
  onAssign,
}: AssignDoerModalProps) {
  const [assignMode, setAssignMode] = useState<AssignMode>("select-expert")
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedDoer, setSelectedDoer] = useState<Doer | null>(null)
  const [isAssigning, setIsAssigning] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [doers, setDoers] = useState<Doer[]>([])
  const [filterAvailable, setFilterAvailable] = useState<string>("all")
  const [sortBy, setSortBy] = useState<string>("rating")

  useEffect(() => {
    if (isOpen) {
      loadDoers()
    } else {
      setSelectedDoer(null)
      setSearchQuery("")
      setAssignMode("select-expert")
    }
  }, [isOpen])

  const loadDoers = async () => {
    setIsLoading(true)
    try {
      const data = await apiFetch<{ doers?: Doer[]; data?: Doer[] }>("/api/doers?activated=true&limit=50")
      const doersList = (data as any)?.doers || (data as any)?.data || (Array.isArray(data) ? data : [])

      const formattedDoers: Doer[] = doersList.map((doer: any) => ({
        id: doer.id,
        full_name: doer.full_name || "Unknown",
        email: doer.email || "",
        avatar_url: doer.avatar_url || null,
        rating: doer.average_rating || doer.rating || 0,
        total_projects: doer.total_projects_completed || doer.total_projects || 0,
        success_rate: doer.success_rate || 95,
        is_available: doer.is_available ?? true,
        skills: doer.skills || [],
        subjects: doer.subjects || [],
        response_time_hours: doer.response_time_hours || 2,
        last_active: doer.last_active || new Date().toISOString(),
      }))

      setDoers(formattedDoers)
    } catch (error) {
      console.error("Error loading doers:", error)
      toast.error("Failed to load doers")
    } finally {
      setIsLoading(false)
    }
  }

  const filteredDoers = useMemo(() => {
    let result = [...doers]

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      result = result.filter(
        (doer) =>
          doer.full_name.toLowerCase().includes(query) ||
          doer.skills.some((s) => s.toLowerCase().includes(query)) ||
          doer.subjects.some((s) => s.toLowerCase().includes(query))
      )
    }

    if (filterAvailable === "available") {
      result = result.filter((doer) => doer.is_available)
    } else if (filterAvailable === "busy") {
      result = result.filter((doer) => !doer.is_available)
    }

    switch (sortBy) {
      case "rating":
        result.sort((a, b) => b.rating - a.rating)
        break
      case "projects":
        result.sort((a, b) => b.total_projects - a.total_projects)
        break
      case "success_rate":
        result.sort((a, b) => b.success_rate - a.success_rate)
        break
      case "response_time":
        result.sort((a, b) => a.response_time_hours - b.response_time_hours)
        break
    }

    return result
  }, [doers, searchQuery, filterAvailable, sortBy])

  const handleAssign = async () => {
    if (!project || !selectedDoer) return

    setIsAssigning(true)
    try {
      await apiFetch(`/api/projects/${project.id}/assign-doer`, {
        method: "PUT",
        body: JSON.stringify({ doerId: selectedDoer.id }),
      })

      toast.success(`Project assigned to ${selectedDoer.full_name}`)
      onAssign(project.id, selectedDoer.id)
      onClose()
    } catch (error) {
      console.error("Error assigning doer:", error)
      toast.error("Failed to assign doer")
    } finally {
      setIsAssigning(false)
    }
  }

  const handleSendToOpenPool = async () => {
    if (!project) return

    setIsAssigning(true)
    try {
      await apiFetch(`/api/projects/${project.id}/open-pool`, {
        method: "POST",
      })

      toast.success("Project sent to the open pool successfully")
      onAssign(project.id, "")
      onClose()
    } catch (error) {
      console.error("Error sending to open pool:", error)
      toast.error("Failed to send project to open pool")
    } finally {
      setIsAssigning(false)
    }
  }

  if (!project) return null

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[90vh] p-0 bg-white">
        <DialogHeader className="p-6 pb-4 border-b border-gray-200 bg-white">
          <DialogTitle className="flex items-center gap-3 text-2xl font-bold text-[#1C1C1C]">
            <div className="h-10 w-10 rounded-xl bg-orange-100 flex items-center justify-center">
              <User className="h-5 w-5 text-[#F97316]" />
            </div>
            Assign Expert
          </DialogTitle>
          <DialogDescription className="text-gray-600 mt-2">
            Select an expert for{" "}
            <span className="font-semibold text-[#1C1C1C]">#{project.project_number}</span> - {project.title}
          </DialogDescription>
        </DialogHeader>

        <div className="p-6 space-y-4">
          {/* Project Info Bar */}
          <div className="bg-gradient-to-br from-orange-50 to-amber-50 rounded-xl border border-orange-200 p-4 shadow-sm">
            <div className="flex items-center justify-between flex-wrap gap-3">
              <div className="flex items-center gap-4 text-sm">
                <div className="flex items-center gap-2">
                  <div className="h-8 w-8 rounded-lg bg-orange-100 flex items-center justify-center">
                    <BookOpen className="h-4 w-4 text-[#F97316]" />
                  </div>
                  <span className="font-semibold text-[#1C1C1C]">{project.subject}</span>
                </div>
                <div className="flex items-center gap-1 text-emerald-600 font-semibold">
                  <span>Payout: ₹{project.doer_payout.toLocaleString("en-IN")}</span>
                </div>
              </div>
              <Badge variant="outline" className="text-xs bg-white border-gray-300 text-gray-700">
                Deadline: {new Date(project.deadline).toLocaleDateString()}
              </Badge>
            </div>
          </div>

          {/* Assignment Mode Tabs */}
          <Tabs
            value={assignMode}
            onValueChange={(value) => {
              setAssignMode(value as AssignMode)
              setSelectedDoer(null)
            }}
            className="w-full"
          >
            <TabsList className="w-full grid grid-cols-2 bg-gray-100 rounded-xl h-11 p-1">
              <TabsTrigger
                value="select-expert"
                className={cn(
                  "rounded-lg text-sm font-medium transition-all data-[state=active]:bg-white data-[state=active]:shadow-sm",
                  "data-[state=active]:text-[#F97316]"
                )}
              >
                <User className="h-4 w-4 mr-2" />
                Select Expert
              </TabsTrigger>
              <TabsTrigger
                value="open-pool"
                className={cn(
                  "rounded-lg text-sm font-medium transition-all data-[state=active]:bg-white data-[state=active]:shadow-sm",
                  "data-[state=active]:text-[#F97316]"
                )}
              >
                <Globe className="h-4 w-4 mr-2" />
                Open Pool
              </TabsTrigger>
            </TabsList>

            {/* Select Expert Tab Content */}
            <TabsContent value="select-expert" className="mt-4 space-y-4">
              <div className="flex flex-wrap gap-3">
                <div className="relative flex-1 min-w-[200px]">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    placeholder="Search by name, skills, or subject..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-9 border-gray-200 focus:border-orange-300 focus:ring-orange-200 rounded-lg"
                  />
                  {searchQuery && (
                    <button
                      onClick={() => setSearchQuery("")}
                      className="absolute right-3 top-1/2 -translate-y-1/2"
                    >
                      <X className="h-4 w-4 text-gray-400 hover:text-[#1C1C1C]" />
                    </button>
                  )}
                </div>

                <Select value={filterAvailable} onValueChange={setFilterAvailable}>
                  <SelectTrigger className="w-[140px] border-gray-200 rounded-lg">
                    <Filter className="h-4 w-4 mr-2" />
                    <SelectValue placeholder="Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Status</SelectItem>
                    <SelectItem value="available">Available</SelectItem>
                    <SelectItem value="busy">Busy</SelectItem>
                  </SelectContent>
                </Select>

                <Select value={sortBy} onValueChange={setSortBy}>
                  <SelectTrigger className="w-[160px] border-gray-200 rounded-lg">
                    <SelectValue placeholder="Sort by" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="rating">Rating (High to Low)</SelectItem>
                    <SelectItem value="projects">Most Projects</SelectItem>
                    <SelectItem value="success_rate">Success Rate</SelectItem>
                    <SelectItem value="response_time">Fastest Response</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <ScrollArea className="h-[350px] pr-4">
                {isLoading ? (
                  <div className="flex items-center justify-center py-12">
                    <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
                  </div>
                ) : filteredDoers.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-12 text-center">
                    <AlertCircle className="h-12 w-12 text-muted-foreground mb-3" />
                    <p className="text-muted-foreground">No doers found</p>
                    <p className="text-sm text-muted-foreground">
                      Try adjusting your search or filters
                    </p>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {filteredDoers.map((doer) => (
                      <Card
                        key={doer.id}
                        className={cn(
                          "cursor-pointer transition-all hover:shadow-md hover:border-orange-200 rounded-xl",
                          selectedDoer?.id === doer.id &&
                            "border-orange-500 ring-2 ring-orange-200 shadow-md",
                          !doer.is_available && "opacity-60"
                        )}
                        onClick={() => setSelectedDoer(doer)}
                      >
                        <CardContent className="p-4">
                          <div className="flex items-start gap-4">
                            <Avatar className="h-12 w-12">
                              <AvatarImage src={doer.avatar_url || undefined} />
                              <AvatarFallback>
                                {doer.full_name
                                  .split(" ")
                                  .map((n) => n[0])
                                  .join("")
                                  .toUpperCase()}
                              </AvatarFallback>
                            </Avatar>

                            <div className="flex-1 min-w-0">
                              <div className="flex items-center gap-2 mb-1">
                                <h4 className="font-semibold truncate">
                                  {doer.full_name}
                                </h4>
                                <Badge
                                  variant={doer.is_available ? "default" : "secondary"}
                                  className={cn(
                                    "text-xs",
                                    doer.is_available
                                      ? "bg-green-500 hover:bg-green-600"
                                      : ""
                                  )}
                                >
                                  {doer.is_available ? "Available" : "Busy"}
                                </Badge>
                              </div>

                              <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground mb-2">
                                <div className="flex items-center gap-1">
                                  <Star className="h-3.5 w-3.5 fill-yellow-400 text-yellow-400" />
                                  <span className="font-medium text-foreground">
                                    {doer.rating}
                                  </span>
                                </div>
                                <div className="flex items-center gap-1">
                                  <CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
                                  <span>{doer.success_rate}% success</span>
                                </div>
                                <div className="flex items-center gap-1">
                                  <Clock className="h-3.5 w-3.5" />
                                  <span>~{doer.response_time_hours}h response</span>
                                </div>
                                <span>{doer.total_projects} projects</span>
                              </div>

                              <div className="flex flex-wrap gap-1.5">
                                {doer.subjects.slice(0, 2).map((subject) => (
                                  <Badge
                                    key={subject}
                                    variant="outline"
                                    className="text-xs"
                                  >
                                    {subject}
                                  </Badge>
                                ))}
                                {doer.skills.slice(0, 2).map((skill) => (
                                  <Badge
                                    key={skill}
                                    variant="secondary"
                                    className="text-xs"
                                  >
                                    {skill}
                                  </Badge>
                                ))}
                                {doer.skills.length + doer.subjects.length > 4 && (
                                  <Badge variant="secondary" className="text-xs">
                                    +{doer.skills.length + doer.subjects.length - 4} more
                                  </Badge>
                                )}
                              </div>
                            </div>

                            {selectedDoer?.id === doer.id && (
                              <div className="flex-shrink-0">
                                <CheckCircle2 className="h-6 w-6 text-primary" />
                              </div>
                            )}
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                  </div>
                )}
              </ScrollArea>
            </TabsContent>

            {/* Open Pool Tab Content */}
            <TabsContent value="open-pool" className="mt-4">
              <div className="space-y-4">
                <Card className="border-orange-200 bg-gradient-to-br from-orange-50 to-amber-50 rounded-xl shadow-sm">
                  <CardContent className="p-6">
                    <div className="flex items-start gap-4">
                      <div className="h-12 w-12 rounded-xl bg-orange-100 flex items-center justify-center flex-shrink-0">
                        <Globe className="h-6 w-6 text-[#F97316]" />
                      </div>
                      <div className="flex-1">
                        <h3 className="text-lg font-semibold text-[#1C1C1C] mb-2">
                          Send to Open Pool
                        </h3>
                        <p className="text-sm text-gray-600 leading-relaxed">
                          Make this project available to all qualified experts on the platform.
                          The first expert to accept the project will be automatically assigned.
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                <Card className="rounded-xl border-gray-200 shadow-sm">
                  <CardContent className="p-6">
                    <h4 className="text-sm font-semibold text-[#1C1C1C] mb-4 flex items-center gap-2">
                      <Info className="h-4 w-4 text-[#F97316]" />
                      How it works
                    </h4>
                    <div className="space-y-4">
                      <div className="flex items-start gap-3">
                        <div className="h-7 w-7 rounded-full bg-orange-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                          <span className="text-xs font-bold text-[#F97316]">1</span>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-[#1C1C1C]">Project goes live</p>
                          <p className="text-xs text-gray-500 mt-0.5">
                            The project appears in the open pool visible to all activated experts.
                          </p>
                        </div>
                      </div>
                      <div className="flex items-start gap-3">
                        <div className="h-7 w-7 rounded-full bg-orange-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                          <span className="text-xs font-bold text-[#F97316]">2</span>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-[#1C1C1C]">Experts review and accept</p>
                          <p className="text-xs text-gray-500 mt-0.5">
                            Qualified experts can view the project details and choose to accept it.
                          </p>
                        </div>
                      </div>
                      <div className="flex items-start gap-3">
                        <div className="h-7 w-7 rounded-full bg-orange-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                          <span className="text-xs font-bold text-[#F97316]">3</span>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-[#1C1C1C]">First to accept gets assigned</p>
                          <p className="text-xs text-gray-500 mt-0.5">
                            The first expert who accepts the project is automatically assigned and can start working.
                          </p>
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                <div className="flex items-center gap-3 bg-blue-50 border border-blue-200 rounded-xl p-4">
                  <Users className="h-5 w-5 text-blue-600 flex-shrink-0" />
                  <p className="text-sm text-blue-800">
                    <span className="font-medium">
                      {doers.filter(d => d.is_available).length} expert{doers.filter(d => d.is_available).length !== 1 ? "s" : ""}
                    </span>{" "}
                    currently available on the platform. You will be notified once an expert accepts the project.
                  </p>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </div>

        <DialogFooter className="gap-3 p-6 border-t border-gray-200 bg-white">
          <Button
            variant="outline"
            onClick={onClose}
            disabled={isAssigning}
            className="rounded-xl border-gray-200 hover:bg-gray-50"
          >
            Cancel
          </Button>

          {assignMode === "select-expert" ? (
            <Button
              onClick={handleAssign}
              disabled={!selectedDoer || isAssigning || !selectedDoer?.is_available}
              className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl shadow-sm"
            >
              {isAssigning ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Assigning Expert...
                </>
              ) : (
                <>
                  <CheckCircle2 className="h-4 w-4 mr-2" />
                  Assign {selectedDoer?.full_name?.split(" ")[0] || "Expert"}
                </>
              )}
            </Button>
          ) : (
            <Button
              onClick={handleSendToOpenPool}
              disabled={isAssigning}
              className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl shadow-sm"
            >
              {isAssigning ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Sending to Pool...
                </>
              ) : (
                <>
                  <Globe className="h-4 w-4 mr-2" />
                  Send to Open Pool
                </>
              )}
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
