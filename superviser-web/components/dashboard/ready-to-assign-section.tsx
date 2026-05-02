/**
 * @fileoverview Section displaying paid projects ready for doer assignment.
 * @module components/dashboard/ready-to-assign-section
 */

"use client"

import { useState } from "react"
import { Users, RefreshCw } from "lucide-react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Skeleton } from "@/components/ui/skeleton"
import { ScrollArea } from "@/components/ui/scroll-area"
import { ReadyToAssignCard, type PaidProject } from "./ready-to-assign-card"
import { AssignDoerModal } from "./assign-doer-modal"

interface ReadyToAssignSectionProps {
  projects: PaidProject[]
  isLoading?: boolean
  onRefresh?: () => void
  onAssign?: (projectId: string, doerId: string) => void
}

export function ReadyToAssignSection({
  projects,
  isLoading = false,
  onRefresh,
  onAssign,
}: ReadyToAssignSectionProps) {
  const [selectedProject, setSelectedProject] = useState<PaidProject | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const handleAssign = (project: PaidProject) => {
    setSelectedProject(project)
    setIsModalOpen(true)
  }

  const handleDoerAssign = (projectId: string, doerId: string) => {
    onAssign?.(projectId, doerId)
    setIsModalOpen(false)
    setSelectedProject(null)
  }

  return (
    <>
      <Card className="border border-[#E7DED0] bg-white/85 p-6 shadow-sm">
        <CardHeader className="p-0 pb-4 border-b border-[#E7DED0]">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="h-2 w-2 rounded-full bg-[#1B6F6A]" />
              <CardTitle className="text-lg text-[#122022]">Ready to Assign</CardTitle>
              {projects.length > 0 && (
                <span className="text-sm text-[#6B7B78]">
                  ({projects.length})
                </span>
              )}
            </div>
            {onRefresh && (
              <Button
                variant="ghost"
                size="sm"
                onClick={onRefresh}
                disabled={isLoading}
              >
                <RefreshCw className={`h-4 w-4 ${isLoading ? "animate-spin" : ""}`} />
              </Button>
            )}
          </div>
          <CardDescription className="mt-1 text-[#5A6B68]">
            Paid projects ready for expert assignment
          </CardDescription>
        </CardHeader>
        <CardContent className="p-0 pt-4">
          {isLoading ? (
            <div className="space-y-4">
              {[1, 2].map((i) => (
                <div
                  key={i}
                  className="p-4 rounded-lg border"
                >
                  <div className="flex items-start gap-4">
                    <div className="flex-1 space-y-2">
                      <div className="flex gap-2">
                        <Skeleton className="h-5 w-20" />
                        <Skeleton className="h-5 w-16" />
                      </div>
                      <Skeleton className="h-5 w-3/4" />
                      <Skeleton className="h-4 w-1/2" />
                      <div className="flex gap-4">
                        <Skeleton className="h-3 w-24" />
                        <Skeleton className="h-3 w-20" />
                        <Skeleton className="h-3 w-24" />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Skeleton className="h-4 w-20" />
                      <Skeleton className="h-9 w-28" />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : projects.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center">
              <Users className="h-12 w-12 text-[#8FA3A0] mb-3" />
              <p className="text-[#5A6B68]">No projects to assign</p>
              <p className="text-sm text-[#7A8B87]">
                Paid projects will appear here for assignment
              </p>
            </div>
          ) : (
            <ScrollArea className="max-h-[420px]">
              <div className="space-y-3 pr-4">
                {projects.map((project) => (
                  <ReadyToAssignCard
                    key={project.id}
                    project={project}
                    onAssign={handleAssign}
                  />
                ))}
              </div>
            </ScrollArea>
          )}
        </CardContent>
      </Card>

      <AssignDoerModal
        project={selectedProject}
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false)
          setSelectedProject(null)
        }}
        onAssign={handleDoerAssign}
      />
    </>
  )
}
