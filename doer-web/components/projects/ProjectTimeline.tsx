'use client'

/**
 * ProjectTimeline component
 * Horizontal scrollable timeline showing project deadlines over next 30 days
 * @module components/projects/ProjectTimeline
 */

import { useRef, useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Calendar, Clock } from 'lucide-react'
import { cn } from '@/lib/utils'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import type { Project } from '@/types/project.types'

/**
 * Props for ProjectTimeline component
 */
interface ProjectTimelineProps {
  /** Array of projects to display */
  projects: Project[]
  /** Callback when a project is clicked */
  onProjectClick?: (id: string) => void
  /** Optional CSS class name */
  className?: string
}

/**
 * Project with deadline information
 */
interface TimelineProject {
  id: string
  title: string
  deadline: Date
  daysRemaining: number
  color: string
  position: number
}

/**
 * Date marker for timeline
 */
interface DateMarker {
  date: Date
  label: string
  position: number
  isToday: boolean
}

/**
 * Calculate days remaining until deadline
 */
function getDaysRemaining(deadline: string | Date): number {
  const now = new Date()
  now.setHours(0, 0, 0, 0)
  const deadlineDate = new Date(deadline)
  deadlineDate.setHours(0, 0, 0, 0)
  const diff = deadlineDate.getTime() - now.getTime()
  return Math.ceil(diff / (1000 * 60 * 60 * 24))
}

/**
 * Get color based on days remaining
 * - Red: < 2 days (urgent)
 * - Orange: 2-5 days (soon)
 * - Blue: 5-10 days (upcoming)
 * - Teal: > 10 days (on-track)
 */
function getDeadlineColor(daysRemaining: number): string {
  if (daysRemaining < 2) return 'bg-red-500 border-red-600'
  if (daysRemaining < 5) return 'bg-orange-500 border-orange-600'
  if (daysRemaining < 10) return 'bg-blue-500 border-blue-600'
  return 'bg-teal-500 border-teal-600'
}

/**
 * Generate date markers for next 30 days
 */
function generateDateMarkers(): DateMarker[] {
  const markers: DateMarker[] = []
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  for (let i = 0; i <= 30; i++) {
    const date = new Date(today)
    date.setDate(date.getDate() + i)

    const isToday = i === 0
    const label =
      i === 0
        ? 'Today'
        : i === 1
        ? 'Tomorrow'
        : date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })

    markers.push({
      date,
      label,
      position: (i / 30) * 100,
      isToday,
    })
  }

  return markers
}

/**
 * ProjectTimeline component
 * Displays a horizontal scrollable timeline with project deadlines
 */
export function ProjectTimeline({
  projects,
  onProjectClick,
  className,
}: ProjectTimelineProps) {
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  const [isDragging, setIsDragging] = useState(false)
  const [startX, setStartX] = useState(0)
  const [scrollLeft, setScrollLeft] = useState(0)

  // Generate date markers
  const dateMarkers = generateDateMarkers()

  // Process projects into timeline items
  const timelineProjects: TimelineProject[] = projects
    .map((project) => {
      const daysRemaining = getDaysRemaining(project.deadline)

      // Only show projects with deadlines in next 30 days
      if (daysRemaining < 0 || daysRemaining > 30) return null

      return {
        id: project.id,
        title: project.title,
        deadline: new Date(project.deadline),
        daysRemaining,
        color: getDeadlineColor(daysRemaining),
        position: (daysRemaining / 30) * 100,
      }
    })
    .filter((p): p is TimelineProject => p !== null)
    .sort((a, b) => a.daysRemaining - b.daysRemaining)

  // Mouse drag handlers for smooth scroll
  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true)
    setStartX(e.pageX - (scrollContainerRef.current?.offsetLeft || 0))
    setScrollLeft(scrollContainerRef.current?.scrollLeft || 0)
  }

  const handleMouseUp = () => {
    setIsDragging(false)
  }

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging) return
    e.preventDefault()
    const x = e.pageX - (scrollContainerRef.current?.offsetLeft || 0)
    const walk = (x - startX) * 2
    if (scrollContainerRef.current) {
      scrollContainerRef.current.scrollLeft = scrollLeft - walk
    }
  }

  // Add/remove global mouse event listeners
  useEffect(() => {
    const handleGlobalMouseUp = () => setIsDragging(false)

    if (isDragging) {
      document.addEventListener('mouseup', handleGlobalMouseUp)
      document.addEventListener('mouseleave', handleGlobalMouseUp)
    }

    return () => {
      document.removeEventListener('mouseup', handleGlobalMouseUp)
      document.removeEventListener('mouseleave', handleGlobalMouseUp)
    }
  }, [isDragging])

  return (
    <div
      className={cn(
        'relative rounded-xl border border-border/40 bg-gradient-to-br from-background/95 via-background/90 to-background/95 backdrop-blur-md shadow-lg',
        className
      )}
    >
      {/* Header */}
      <div className="flex items-center justify-between px-6 py-4 border-b border-border/40">
        <div className="flex items-center gap-2">
          <Calendar className="h-5 w-5 text-primary" />
          <h3 className="font-semibold text-lg">Project Timeline</h3>
        </div>
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Clock className="h-4 w-4" />
          <span>Next 30 days</span>
        </div>
      </div>

      {/* Timeline Container */}
      <div
        ref={scrollContainerRef}
        onMouseDown={handleMouseDown}
        onMouseUp={handleMouseUp}
        onMouseMove={handleMouseMove}
        className={cn(
          'relative overflow-x-auto overflow-y-hidden',
          'scrollbar-thin scrollbar-thumb-primary/20 scrollbar-track-transparent',
          isDragging ? 'cursor-grabbing select-none' : 'cursor-grab'
        )}
        style={{ userSelect: isDragging ? 'none' : 'auto' }}
      >
        <div className="relative min-w-[800px] w-full px-6 py-8">
          {/* Timeline Bar */}
          <div className="relative h-24 mb-8">
            {/* Base line */}
            <div className="absolute top-1/2 left-0 right-0 h-1 bg-gradient-to-r from-border/20 via-border/40 to-border/20 rounded-full -translate-y-1/2" />

            {/* Current date indicator */}
            <motion.div
              initial={{ opacity: 0, scaleY: 0 }}
              animate={{ opacity: 1, scaleY: 1 }}
              transition={{ delay: 0.2, duration: 0.4 }}
              className="absolute top-0 bottom-0 w-0.5 bg-primary z-20"
              style={{ left: '0%' }}
            >
              <div className="absolute -top-2 left-1/2 -translate-x-1/2 w-3 h-3 bg-primary rounded-full shadow-lg shadow-primary/50" />
              <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 text-xs font-semibold text-primary whitespace-nowrap">
                Today
              </div>
            </motion.div>

            {/* Project markers */}
            <TooltipProvider delayDuration={200}>
              {timelineProjects.map((project, index) => (
                <Tooltip key={project.id}>
                  <TooltipTrigger asChild>
                    <motion.button
                      initial={{ opacity: 0, scale: 0 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: 0.3 + index * 0.05, duration: 0.3 }}
                      whileHover={{ scale: 1.2, y: -4 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => onProjectClick?.(project.id)}
                      className={cn(
                        'absolute top-1/2 -translate-x-1/2 -translate-y-1/2',
                        'w-4 h-4 rounded-full border-2 shadow-lg z-10',
                        'transition-all duration-200',
                        'hover:shadow-xl hover:z-30',
                        project.color
                      )}
                      style={{ left: `${project.position}%` }}
                    >
                      <span className="sr-only">{project.title}</span>
                    </motion.button>
                  </TooltipTrigger>
                  <TooltipContent
                    side="top"
                    className="max-w-xs bg-popover/95 backdrop-blur-sm border-border/50"
                  >
                    <div className="space-y-1">
                      <p className="font-semibold text-sm">{project.title}</p>
                      <p className="text-xs text-muted-foreground">
                        Due: {project.deadline.toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </p>
                      <p className="text-xs font-medium">
                        {project.daysRemaining === 0
                          ? 'Due today'
                          : project.daysRemaining === 1
                          ? 'Due tomorrow'
                          : `${project.daysRemaining} days remaining`}
                      </p>
                    </div>
                  </TooltipContent>
                </Tooltip>
              ))}
            </TooltipProvider>
          </div>

          {/* Date markers at bottom */}
          <div className="relative h-12">
            <div className="flex justify-between items-start">
              {dateMarkers
                .filter((_, i) => i % 3 === 0) // Show every 3rd day
                .map((marker, index) => (
                  <motion.div
                    key={marker.label}
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.4 + index * 0.05 }}
                    className="flex flex-col items-center gap-1"
                  >
                    <div
                      className={cn(
                        'w-px h-3',
                        marker.isToday ? 'bg-primary' : 'bg-border/40'
                      )}
                    />
                    <span
                      className={cn(
                        'text-xs whitespace-nowrap',
                        marker.isToday
                          ? 'font-semibold text-primary'
                          : 'text-muted-foreground'
                      )}
                    >
                      {marker.label}
                    </span>
                  </motion.div>
                ))}
            </div>
          </div>

          {/* Color legend */}
          <div className="mt-8 flex items-center justify-center gap-6 text-xs">
            {[
              { color: 'bg-red-500', label: 'Urgent (<2 days)', border: 'border-red-600' },
              { color: 'bg-orange-500', label: 'Soon (2-5 days)', border: 'border-orange-600' },
              { color: 'bg-blue-500', label: 'Upcoming (5-10 days)', border: 'border-blue-600' },
              { color: 'bg-teal-500', label: 'On-track (>10 days)', border: 'border-teal-600' },
            ].map((item) => (
              <div key={item.label} className="flex items-center gap-2">
                <div className={cn('w-3 h-3 rounded-full border-2', item.color, item.border)} />
                <span className="text-muted-foreground">{item.label}</span>
              </div>
            ))}
          </div>

          {/* Empty state */}
          {timelineProjects.length === 0 && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="absolute inset-0 flex items-center justify-center"
            >
              <div className="text-center text-muted-foreground">
                <Calendar className="h-12 w-12 mx-auto mb-3 opacity-50" />
                <p className="text-sm">No upcoming deadlines in the next 30 days</p>
              </div>
            </motion.div>
          )}
        </div>
      </div>
    </div>
  )
}
