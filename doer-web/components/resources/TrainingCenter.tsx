'use client'

/**
 * Training Center component
 * Displays training modules with video/PDF viewer and progress tracking
 * @module components/resources/TrainingCenter
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Play,
  FileText,
  CheckCircle2,
  Clock,
  BookOpen,
  ChevronRight,
  X,
  Bookmark,
  BookmarkCheck,
  ArrowLeft,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'
import { formatDuration } from './constants'
import type { TrainingModule, TrainingProgress } from '@/types/database'

/**
 * TrainingCenter component props
 */
interface TrainingCenterProps {
  /** Training modules */
  modules: TrainingModule[]
  /** User's progress */
  progress: TrainingProgress[]
  /** Loading state */
  isLoading?: boolean
  /** Callback when module is completed */
  onModuleComplete?: (moduleId: string) => void
  /** Callback to go back */
  onBack?: () => void
  /** Additional class name */
  className?: string
}

type LearningStatCardProps = {
  label: string
  value: string
  tone: 'cool' | 'fresh' | 'warm'
}

/**
 * Small stat card used in the Training Center header.
 */
function LearningStatCard({ label, value, tone }: LearningStatCardProps) {
  const toneStyles = {
    cool: 'bg-[#E3E9FF] text-[#4F6CF7]',
    fresh: 'bg-[#E6F4FF] text-[#4B9BFF]',
    warm: 'bg-[#FFE7E1] text-[#FF8B6A]',
  }

  return (
    <div className="rounded-2xl bg-white/85 p-4 shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
      <div className={cn('h-9 w-9 rounded-2xl', toneStyles[tone])} />
      <p className="mt-3 text-xs font-semibold uppercase tracking-wide text-slate-500">{label}</p>
      <p className="mt-1 text-lg font-semibold text-slate-900">{value}</p>
    </div>
  )
}

/**
 * Training Center component
 * Displays training modules with video/PDF viewer and progress tracking
 */
export function TrainingCenter({
  modules,
  progress,
  isLoading,
  onModuleComplete,
  onBack,
  className,
}: TrainingCenterProps) {
  const [selectedModule, setSelectedModule] = useState<TrainingModule | null>(null)
  const [bookmarkedModules, setBookmarkedModules] = useState<string[]>([])

  /**
   * Get progress record for a specific module
   * @param moduleId - Module ID to look up
   * @returns Training progress for the module, if exists
   */
  const getModuleProgress = (moduleId: string): TrainingProgress | undefined => {
    return progress.find((p) => p.module_id === moduleId)
  }

  /** Calculate overall progress percentage */
  const overallProgress = modules.length > 0
    ? Math.round(
        (progress.filter((p) => p.is_completed).length / modules.length) * 100
      )
    : 0

  const completedCount = progress.filter((p) => p.is_completed).length
  const mandatoryCount = modules.filter((m) => m.is_mandatory).length
  const bookmarkCount = bookmarkedModules.length

  /**
   * Toggle bookmark state for a module
   * @param moduleId - Module ID to toggle
   */
  const toggleBookmark = (moduleId: string) => {
    setBookmarkedModules((prev) =>
      prev.includes(moduleId)
        ? prev.filter((id) => id !== moduleId)
        : [...prev, moduleId]
    )
  }

  /**
   * Get icon component for module type
   * @param type - Module content type
   * @returns Lucide icon component
   */
  const getTypeIcon = (contentType: TrainingModule['content_type']) => {
    switch (contentType) {
      case 'video':
        return <Play className="h-4 w-4" />
      case 'pdf':
        return <FileText className="h-4 w-4" />
      case 'article':
        return <BookOpen className="h-4 w-4" />
      case 'html':
        return <BookOpen className="h-4 w-4" />
      default:
        return <FileText className="h-4 w-4" />
    }
  }

  if (isLoading) {
    return (
      <div className={cn('space-y-6', className)}>
        <Skeleton className="h-28 w-full rounded-[28px]" />
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-32 rounded-2xl" />
          ))}
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <Skeleton key={i} className="h-48 rounded-2xl" />
          ))}
        </div>
      </div>
    )
  }

  // Module viewer
  if (selectedModule) {
    return (
      <div className={cn('space-y-6', className)}>
        <div className="rounded-[28px] bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setSelectedModule(null)}
                className="bg-white/70"
              >
                <ArrowLeft className="h-5 w-5" />
              </Button>
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">Module Viewer</p>
                <h2 className="text-2xl font-semibold text-slate-900">{selectedModule.title}</h2>
                <p className="text-sm text-slate-500">{selectedModule.description}</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Button
                variant="ghost"
                size="icon"
                onClick={() => toggleBookmark(selectedModule.id)}
                className="bg-white/70"
              >
                {bookmarkedModules.includes(selectedModule.id) ? (
                  <BookmarkCheck className="h-5 w-5 text-[#4F6CF7]" />
                ) : (
                  <Bookmark className="h-5 w-5" />
                )}
              </Button>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setSelectedModule(null)}
                className="bg-white/70"
              >
                <X className="h-5 w-5" />
              </Button>
            </div>
          </div>
        </div>

        <Card className="overflow-hidden border-none bg-white/85 shadow-[0_20px_50px_rgba(30,58,138,0.1)]">
          <CardContent className="p-0">
            {selectedModule.content_type === 'video' ? (
              <div className="aspect-video bg-black">
                <iframe
                  src={selectedModule.content_url || ''}
                  className="w-full h-full"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  title={selectedModule.title}
                />
              </div>
            ) : selectedModule.content_type === 'pdf' ? (
              <div className="aspect-[3/4] md:aspect-video">
                <iframe
                  src={selectedModule.content_url || ''}
                  className="w-full h-full"
                  title={selectedModule.title}
                />
              </div>
            ) : (
              <div className="p-6">
                <ScrollArea className="h-[500px]">
                  <div className="prose prose-sm dark:prose-invert max-w-none">
                    <p className="text-slate-500">
                      Article content loading...
                    </p>
                  </div>
                </ScrollArea>
              </div>
            )}
          </CardContent>
        </Card>

        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4 text-sm text-slate-500">
            <span className="flex items-center gap-1">
              {getTypeIcon(selectedModule.content_type)}
              <span className="capitalize">{selectedModule.content_type}</span>
            </span>
            <span className="flex items-center gap-1">
              <Clock className="h-4 w-4" />
              {formatDuration(selectedModule.duration_minutes)}
            </span>
          </div>

          {!getModuleProgress(selectedModule.id)?.is_completed && (
            <Button
              onClick={() => {
                onModuleComplete?.(selectedModule.id)
                setSelectedModule(null)
              }}
              className="gap-2 rounded-full bg-[#FF9B7A] px-5 text-sm font-semibold text-white shadow-[0_12px_28px_rgba(255,155,122,0.35)]"
            >
              <CheckCircle2 className="h-4 w-4" />
              Mark as Complete
            </Button>
          )}

          {getModuleProgress(selectedModule.id)?.is_completed && (
            <Badge variant="outline" className="gap-1 bg-[#E3E9FF] text-[#4F6CF7]">
              <CheckCircle2 className="h-3 w-3" />
              Completed
            </Badge>
          )}
        </div>
      </div>
    )
  }

  return (
    <div className={cn('space-y-6', className)}>
      <div className="rounded-[28px] bg-white/85 p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
        <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_280px]">
          <div className="space-y-4">
            <div className="flex items-center gap-4">
              {onBack && (
                <Button variant="ghost" size="icon" onClick={onBack} className="bg-white/70">
                  <ArrowLeft className="h-5 w-5" />
                </Button>
              )}
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-[#4F6CF7]">Training Center</p>
                <h2 className="text-2xl font-semibold text-slate-900">Grow your delivery mastery</h2>
                <p className="text-sm text-slate-500">
                  Learn best practices and quality standards at your pace.
                </p>
              </div>
            </div>
            <div className="rounded-2xl bg-slate-50/80 p-4">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-slate-700">Overall Progress</span>
                <span className="text-sm text-slate-500">
                  {completedCount} / {modules.length} modules
                </span>
              </div>
              <Progress value={overallProgress} className="mt-3 h-2" />
              <p className="mt-2 text-xs text-slate-500">{overallProgress}% complete</p>
            </div>
          </div>
          <div className="grid gap-3">
            <LearningStatCard label="Completed" value={String(completedCount)} tone="cool" />
            <LearningStatCard label="Mandatory" value={String(mandatoryCount)} tone="fresh" />
            <LearningStatCard label="Bookmarked" value={String(bookmarkCount)} tone="warm" />
          </div>
        </div>
      </div>

      {bookmarkedModules.length > 0 && (
        <div className="space-y-3">
          <h3 className="text-base font-semibold text-slate-900 flex items-center gap-2">
            <BookmarkCheck className="h-4 w-4 text-[#4F6CF7]" />
            Bookmarked
          </h3>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {modules
              .filter((m) => bookmarkedModules.includes(m.id))
              .map((module) => (
                <ModuleCard
                  key={module.id}
                  module={module}
                  progress={getModuleProgress(module.id)}
                  isBookmarked
                  onBookmark={() => toggleBookmark(module.id)}
                  onClick={() => setSelectedModule(module)}
                />
              ))}
          </div>
        </div>
      )}

      <div className="space-y-3">
        <h3 className="text-base font-semibold text-slate-900">All Modules</h3>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <AnimatePresence>
            {modules.map((module, index) => (
              <motion.div
                key={module.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
              >
                <ModuleCard
                  module={module}
                  progress={getModuleProgress(module.id)}
                  isBookmarked={bookmarkedModules.includes(module.id)}
                  onBookmark={() => toggleBookmark(module.id)}
                  onClick={() => setSelectedModule(module)}
                />
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      </div>

      {modules.length === 0 && (
        <Card className="p-8 text-center border-none bg-white/85">
          <BookOpen className="h-12 w-12 mx-auto text-slate-400 mb-4" />
          <h3 className="font-medium text-slate-900">No Training Modules</h3>
          <p className="text-sm text-slate-500 mt-1">
            Training modules will appear here when available.
          </p>
        </Card>
      )}
    </div>
  )
}

/**
 * ModuleCard component props
 */
interface ModuleCardProps {
  /** Training module data */
  module: TrainingModule
  /** User's progress on this module */
  progress?: TrainingProgress
  /** Whether module is bookmarked */
  isBookmarked?: boolean
  /** Callback when bookmark is toggled */
  onBookmark: () => void
  /** Callback when card is clicked */
  onClick: () => void
}

/**
 * Module Card sub-component
 * Displays individual training module as a card
 */
function ModuleCard({
  module,
  progress,
  isBookmarked,
  onBookmark,
  onClick,
}: ModuleCardProps) {
  const isCompleted = progress?.is_completed ?? false
  const progressPercent = progress?.progress_percentage ?? 0

  /**
   * Get icon for module type
   * @param type - Module content type
   * @returns JSX element with icon
   */
  const getTypeIcon = (contentType: TrainingModule['content_type']) => {
    switch (contentType) {
      case 'video':
        return <Play className="h-4 w-4" />
      case 'pdf':
        return <FileText className="h-4 w-4" />
      case 'article':
        return <BookOpen className="h-4 w-4" />
      case 'html':
        return <BookOpen className="h-4 w-4" />
      default:
        return <FileText className="h-4 w-4" />
    }
  }

  return (
    <Card
      className={cn(
        'group cursor-pointer border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] transition-all hover:-translate-y-1',
        isCompleted && 'bg-[#EEF2FF]/70'
      )}
      onClick={onClick}
    >
      {module.thumbnail_url && (
        <div className="aspect-video bg-muted relative overflow-hidden rounded-t-2xl">
          <img
            src={module.thumbnail_url}
            alt={module.title}
            className="object-cover w-full h-full"
          />
          {module.content_type === 'video' && (
            <div className="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 group-hover:opacity-100 transition-opacity">
              <div className="w-12 h-12 rounded-full bg-white/90 flex items-center justify-center">
                <Play className="h-6 w-6 text-[#4F6CF7] ml-1" />
              </div>
            </div>
          )}
        </div>
      )}

      <CardHeader className="pb-2">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <CardTitle className="text-base line-clamp-1 text-slate-900 group-hover:text-[#4F6CF7] transition-colors">
              {module.title}
            </CardTitle>
            <CardDescription className="line-clamp-2 mt-1 text-slate-500">
              {module.description}
            </CardDescription>
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 -mt-1 -mr-2"
            onClick={(e) => {
              e.stopPropagation()
              onBookmark()
            }}
          >
            {isBookmarked ? (
              <BookmarkCheck className="h-4 w-4 text-[#4F6CF7]" />
            ) : (
              <Bookmark className="h-4 w-4 text-slate-400" />
            )}
          </Button>
        </div>
      </CardHeader>

      <CardContent className="pt-0">
        <div className="flex items-center justify-between text-xs text-slate-500 mb-2">
          <span className="flex items-center gap-1">
            {getTypeIcon(module.content_type)}
            <span className="capitalize">{module.content_type}</span>
          </span>
          <span className="flex items-center gap-1">
            <Clock className="h-3 w-3" />
            {formatDuration(module.duration_minutes)}
          </span>
        </div>

        {isCompleted ? (
          <div className="flex items-center gap-1 text-[#4F6CF7]">
            <CheckCircle2 className="h-4 w-4" />
            <span className="text-xs font-medium">Completed</span>
          </div>
        ) : progressPercent > 0 ? (
          <div className="space-y-1">
            <Progress value={progressPercent} className="h-1.5" />
            <p className="text-xs text-slate-500">{progressPercent}% complete</p>
          </div>
        ) : (
          <div className="flex items-center justify-between">
            <Badge variant="outline" className="text-xs border-white/70">
              {module.is_mandatory ? 'Required' : 'Optional'}
            </Badge>
            <ChevronRight className="h-4 w-4 text-slate-400 group-hover:text-[#4F6CF7] group-hover:translate-x-1 transition-all" />
          </div>
        )}
      </CardContent>
    </Card>
  )
}
