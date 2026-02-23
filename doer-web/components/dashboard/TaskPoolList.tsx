'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, Filter, RefreshCw, Inbox } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { ProjectCard } from './ProjectCard'
import type { ProjectStatus } from '@/types/database'
import { cn } from '@/lib/utils'

/** Project data interface */
export interface Project {
  id: string
  title: string
  subject: string
  description?: string
  price: number
  deadline: Date
  status: ProjectStatus
  supervisorName?: string
  isUrgent?: boolean
}

interface TaskPoolListProps {
  /** List of available projects */
  projects: Project[]
  /** Whether data is loading */
  isLoading?: boolean
  /** Callback when a task is accepted */
  onAcceptTask?: (projectId: string) => void
  /** Callback when a project card is clicked */
  onProjectClick?: (projectId: string) => void
  /** Callback to refresh the list */
  onRefresh?: () => void
}

/**
 * Task pool list component
 * Shows available tasks that can be grabbed
 */
export function TaskPoolList({
  projects,
  isLoading = false,
  onAcceptTask,
  onProjectClick,
  onRefresh,
}: TaskPoolListProps) {
  const [searchQuery, setSearchQuery] = useState('')
  const [sortBy, setSortBy] = useState<'deadline' | 'price'>('deadline')
  const [filterSubject, setFilterSubject] = useState<string>('all')

  /** Get unique subjects for filter */
  const subjects = Array.from(new Set(projects.map(p => p.subject)))

  /** Filter and sort projects */
  const filteredProjects = projects
    .filter(project => {
      // Search filter
      if (searchQuery) {
        const query = searchQuery.toLowerCase()
        return (
          project.title.toLowerCase().includes(query) ||
          project.subject.toLowerCase().includes(query) ||
          project.description?.toLowerCase().includes(query)
        )
      }
      return true
    })
    .filter(project => {
      // Subject filter
      if (filterSubject !== 'all') {
        return project.subject === filterSubject
      }
      return true
    })
    .sort((a, b) => {
      // Sort
      if (sortBy === 'deadline') {
        return a.deadline.getTime() - b.deadline.getTime()
      }
      return b.price - a.price
    })

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        {/* Search */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search tasks..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9"
          />
        </div>

        {/* Subject filter */}
        <Select value={filterSubject} onValueChange={setFilterSubject}>
          <SelectTrigger className="w-full sm:w-40">
            <Filter className="h-4 w-4 mr-2" />
            <SelectValue placeholder="Subject" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Subjects</SelectItem>
            {subjects.map(subject => (
              <SelectItem key={subject} value={subject}>
                {subject}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        {/* Sort */}
        <Select value={sortBy} onValueChange={(v) => setSortBy(v as 'deadline' | 'price')}>
          <SelectTrigger className="w-full sm:w-36">
            <SelectValue placeholder="Sort by" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="deadline">Deadline</SelectItem>
            <SelectItem value="price">Price</SelectItem>
          </SelectContent>
        </Select>

        {/* Refresh button */}
        {onRefresh && (
          <Button
            variant="outline"
            size="icon"
            onClick={onRefresh}
            disabled={isLoading}
          >
            <RefreshCw className={cn('h-4 w-4', isLoading && 'animate-spin')} />
          </Button>
        )}
      </div>

      {/* Results count */}
      <p className="text-sm text-muted-foreground">
        {filteredProjects.length} task{filteredProjects.length !== 1 ? 's' : ''} available
      </p>

      {/* Project list */}
      <AnimatePresence mode="popLayout">
        {filteredProjects.length > 0 ? (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {filteredProjects.map((project, index) => (
              <motion.div
                key={project.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95 }}
                transition={{ delay: index * 0.05 }}
              >
                <ProjectCard
                  {...project}
                  onAccept={onAcceptTask}
                  onClick={onProjectClick}
                />
              </motion.div>
            ))}
          </div>
        ) : (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="flex flex-col items-center justify-center py-12 text-center"
          >
            <Inbox className="h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="font-medium text-lg">No tasks available</h3>
            <p className="text-sm text-muted-foreground mt-1">
              {searchQuery || filterSubject !== 'all'
                ? 'Try adjusting your filters'
                : 'Check back later for new opportunities'}
            </p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
