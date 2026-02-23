
'use client'

import { useState, useEffect } from 'react'
import type React from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Sparkles, BookOpen, Search, ArrowRight, Layers, Target } from 'lucide-react'
import { cn } from '@/lib/utils'
import { toast } from 'sonner'
import {
  ResourcesGrid,
  TrainingCenter,
  CitationBuilder,
  FormatTemplates,
} from '@/components/resources'
import { getTrainingModules, getTrainingProgress, getCitationHistory } from '@/services/resources.service'
import { useAuth } from '@/hooks/useAuth'
import type { TrainingModule, TrainingProgress, Citation } from '@/types/database'

/** Resource view types */
type ResourceView = 'grid' | 'training-center' | 'ai-report' | 'citation-builder' | 'templates'

type ResourceStatCardProps = {
  label: string
  value: string
  icon: React.ElementType
  tone: 'cool' | 'fresh' | 'warm'
}

type SimpleToolProps = {
  onBack: () => void
}

/**
 * Small stat card for the resources hero.
 */
function ResourceStatCard({ label, value, icon: Icon, tone }: ResourceStatCardProps) {
  const toneStyles = {
    cool: 'bg-[#E3E9FF] text-[#4F6CF7]',
    fresh: 'bg-[#E6F4FF] text-[#4B9BFF]',
    warm: 'bg-[#ECE9FF] text-[#6B5BFF]',
  }

  return (
    <div className="rounded-2xl bg-white/85 p-4 shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
      <div className={cn('h-9 w-9 rounded-2xl flex items-center justify-center', toneStyles[tone])}>
        <Icon className="h-5 w-5" />
      </div>
      <p className="mt-3 text-xs font-semibold uppercase tracking-wide text-slate-500">{label}</p>
      <p className="mt-1 text-lg font-semibold text-slate-900">{value}</p>
    </div>
  )
}

/**
 * Summary panel for learning progress - Horizontal full-width card.
 */
function LearningPulseCard({ completed, total, mandatory }: { completed: number; total: number; mandatory: number }) {
  const progressValue = total ? Math.round((completed / total) * 100) : 0

  return (
    <Card className="relative overflow-hidden border-none bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)]">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_left,rgba(79,108,247,0.08),transparent_50%)]" />
      <CardContent className="relative p-6 lg:p-8">
        <div className="grid gap-6 lg:grid-cols-[1fr_auto_auto] lg:items-center">
          {/* Left section - Title and progress */}
          <div className="space-y-4">
            <div className="flex items-start gap-4">
              <div className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-2xl bg-[#EEF2FF] text-[#4F6CF7] shadow-lg">
                <Target className="h-6 w-6" />
              </div>
              <div className="flex-1 space-y-2">
                <div className="flex items-center gap-3">
                  <h3 className="text-xl font-semibold text-slate-900">Learning Pulse</h3>
                  <Badge className="bg-[#E6F4FF] text-[#4B9BFF] border-0">
                    {progressValue}% Complete
                  </Badge>
                </div>
                <p className="text-sm text-slate-500">Track your training progress and complete mandatory modules</p>
              </div>
            </div>

            {/* Progress bar */}
            <div className="space-y-2">
              <div className="flex items-center justify-between text-sm">
                <span className="font-medium text-slate-700">{completed} of {total} modules completed</span>
                <span className="text-slate-500">{mandatory} mandatory remaining</span>
              </div>
              <Progress value={progressValue} className="h-3" />
            </div>
          </div>

          {/* Middle section - Focus card */}
          <div className="rounded-2xl bg-gradient-to-br from-[#EEF2FF] to-[#E6F4FF] p-5 lg:w-80">
            <div className="space-y-2">
              <div className="flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-[#4F6CF7]" />
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[#4F6CF7]">Focus Today</p>
              </div>
              <p className="text-base font-semibold text-slate-900">Complete the mandatory checklist</p>
              <p className="text-xs text-slate-600">Stay on track with required training modules</p>
            </div>
          </div>

          {/* Right section - CTA button */}
          <div className="flex flex-col gap-3 lg:w-48">
            <Button className="h-11 rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_14px_28px_rgba(91,124,255,0.25)] hover:-translate-y-0.5 transition-all">
              <span className="flex items-center gap-2">
                Resume training
                <ArrowRight className="h-4 w-4" />
              </span>
            </Button>
            <p className="text-center text-xs text-slate-400">Pick up where you left off</p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

/**
 * Temporary AI report generator panel.
 */
function AIReportGenerator({ onBack }: SimpleToolProps) {
  return (
    <div className="rounded-[28px] bg-white/85 p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">AI Report</p>
          <h2 className="text-2xl font-semibold text-slate-900">AI Report Generator</h2>
          <p className="text-sm text-slate-500">This tool is temporarily unavailable.</p>
        </div>
        <Button
          variant="outline"
          onClick={onBack}
          className="rounded-full border-white/80 bg-white/85"
        >
          Back to resources
        </Button>
      </div>
    </div>
  )
}

/**
 * Resources page
 * Professional hub for all doer tools and resources
 */
export default function ResourcesPage() {
  const { doer, isLoading: authLoading } = useAuth()
  const [isLoading, setIsLoading] = useState(true)
  const [currentView, setCurrentView] = useState<ResourceView>('grid')
  const [trainingModules, setTrainingModules] = useState<TrainingModule[]>([])
  const [trainingProgress, setTrainingProgress] = useState<TrainingProgress[]>([])
  const [citationHistory, setCitationHistory] = useState<Citation[]>([])

  /**
   * Load initial data.
   * Training modules are public (no doer needed), but progress/citations require doer.
   * Wait for auth to finish before clearing isLoading so we don't flash incomplete data.
   */
  useEffect(() => {
    const loadData = async () => {
      setIsLoading(true)
      try {
        const modules = await getTrainingModules()
        setTrainingModules(modules)

        if (doer?.id) {
          try {
            const progress = await getTrainingProgress(doer.id)
            setTrainingProgress(progress)
          } catch (progressError) {
            console.error('Error loading training progress:', progressError)
            toast.error('Failed to load training progress')
          }

          // Citations are loaded separately - won't fail if table doesn't exist
          try {
            const citations = await getCitationHistory(doer.id)
            setCitationHistory(citations)
          } catch (citationsError) {
            console.error('Error loading citations:', citationsError)
            // Silently fail for citations as it's not critical
          }
        }
      } catch (error) {
        console.error('Error loading resources data:', error)
        toast.error('Failed to load training modules')
      } finally {
        setIsLoading(false)
      }
    }

    if (doer?.id || !authLoading) {
      // Either doer is available (fetch everything) or auth finished with no doer
      // (fetch public modules only). Don't run while auth is still loading to avoid
      // fetching twice and flashing incomplete data.
      loadData()
    }
  }, [doer?.id, authLoading])

  /** Handle resource click */
  const handleResourceClick = (resourceId: string) => {
    switch (resourceId) {
      case 'training-center':
        setCurrentView('training-center')
        break
      case 'ai-report':
        setCurrentView('ai-report')
        break
      case 'citation-builder':
        setCurrentView('citation-builder')
        break
      case 'templates':
        setCurrentView('templates')
        break
      default:
        setCurrentView('grid')
    }
  }

  /** Handle module complete */
  const handleModuleComplete = (moduleId: string) => {
    setTrainingProgress((prev) => {
      const existing = prev.find((p) => p.module_id === moduleId)
      if (existing) {
        return prev.map((p) =>
          p.module_id === moduleId
            ? { ...p, is_completed: true, progress_percentage: 100, completed_at: new Date().toISOString() }
            : p
        )
      }
      return [
        ...prev,
        {
          id: `new-${Date.now()}`,
          profile_id: doer?.profile_id || '',
          module_id: moduleId,
          started_at: new Date().toISOString(),
          completed_at: new Date().toISOString(),
          progress_percentage: 100,
          is_completed: true,
        },
      ]
    })
  }

  /** Handle template download */
  const handleTemplateDownload = async (templateId: string) => {
    try {
      const { incrementTemplateDownload } = await import('@/services/resources.service')
      await incrementTemplateDownload(templateId)
      toast.success('Template download started')
    } catch {
      toast.error('Failed to download template')
    }
  }

  /** Back to grid */
  const handleBack = () => {
    setCurrentView('grid')
  }

  // Calculate training progress
  const completedModules = trainingProgress.filter((p) => p.is_completed).length
  const totalMandatory = trainingModules.filter((m) => m.is_mandatory).length

  // Skeleton gate removed — show page content immediately while loading

  return (
    <div className="relative">
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%),radial-gradient(circle_at_85%_15%,rgba(109,99,255,0.14),transparent_50%)]" />
      <div className="space-y-12">
        <AnimatePresence mode="wait">
          {currentView === 'grid' && (
            <motion.div
              key="hero"
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="rounded-[32px] bg-gradient-to-br from-[#F7F9FF] via-[#F2F6FF] to-[#EEF2FF] p-8 shadow-[0_28px_70px_rgba(30,58,138,0.12)]"
            >
              <div className="grid gap-8 lg:grid-cols-[minmax(0,1fr)_320px]">
                <div className="space-y-6">
                  <Badge className="w-fit bg-[#E6F4FF] text-[#4B9BFF]">Resource Studio</Badge>
                  <div className="space-y-3">
                    <h1 className="text-3xl font-semibold tracking-tight text-slate-900">Resources & Tools</h1>
                    <p className="text-sm text-slate-500">
                      Everything you need to learn faster, check quality, and deliver with confidence.
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-3">
                    <Button className="h-11 rounded-full bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#6B5BFF] px-5 text-sm font-semibold text-white shadow-[0_16px_35px_rgba(91,124,255,0.35)]">
                      Start training
                    </Button>
                    <Button
                      variant="outline"
                      className="h-11 rounded-full border-white/80 bg-white/85 px-5 text-sm font-semibold text-slate-600 shadow-[0_10px_22px_rgba(30,58,138,0.1)]"
                    >
                      Explore tools
                    </Button>
                  </div>
                  <div className="relative w-full max-w-md">
                    <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                    <input
                      className="h-11 w-full rounded-full border border-white/80 bg-white/85 pl-10 pr-4 text-sm text-slate-700 shadow-[0_10px_20px_rgba(148,163,184,0.12)] outline-none transition focus:border-[#B8C4FF] focus:ring-4 focus:ring-[#E7ECFF]"
                      placeholder="Search training, templates, tools"
                      type="search"
                    />
                  </div>
                  <div className="flex flex-wrap gap-2 text-xs text-slate-500">
                    <span className="inline-flex items-center gap-1 rounded-full bg-white/85 px-3 py-1">
                      <BookOpen className="h-3 w-3 text-[#4F6CF7]" />
                      {completedModules}/{totalMandatory} mandatory modules done
                    </span>
                    <span className="inline-flex items-center gap-1 rounded-full bg-white/85 px-3 py-1">
                      <Sparkles className="h-3 w-3 text-[#6B5BFF]" />
                      4 tools active
                    </span>
                  </div>
                </div>
                <div className="relative overflow-hidden rounded-[28px] bg-white/80 p-5 shadow-[0_20px_50px_rgba(30,58,138,0.12)]">
                  <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(90,124,255,0.2),transparent_60%)]" />
                  <div className="absolute -right-12 -top-12 h-40 w-40 rounded-full bg-[#E7ECFF] blur-3xl" />
                  <div className="relative space-y-6">
                    <div className="space-y-2">
                      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">Today</p>
                      <h2 className="text-xl font-semibold text-slate-900">Creative Toolkit</h2>
                      <p className="text-sm text-slate-500">Pick one tool and ship something new.</p>
                    </div>
                    <div className="flex items-center justify-between rounded-2xl bg-white/85 px-4 py-3 shadow-[0_10px_22px_rgba(148,163,184,0.12)]">
                      <div>
                        <p className="text-xs text-slate-400">Tool ready</p>
                        <p className="text-sm font-semibold text-slate-900">AI Outline Builder</p>
                      </div>
                      <span className="text-xs font-semibold text-[#5A7CFF]">Launch</span>
                    </div>
                    <div className="grid gap-3">
                      <ResourceStatCard
                        label="Modules Complete"
                        value={`${completedModules}/${trainingModules.length || totalMandatory || 0}`}
                        icon={BookOpen}
                        tone="cool"
                      />
                      <ResourceStatCard
                        label="Citations Built"
                        value={`${citationHistory.length}`}
                        icon={Layers}
                        tone="fresh"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        <AnimatePresence mode="wait">
          {currentView === 'grid' && (
            <motion.div
              key="grid"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="space-y-8"
            >
              <ResourcesGrid onResourceClick={handleResourceClick} />
              <LearningPulseCard completed={completedModules} total={trainingModules.length} mandatory={totalMandatory} />
            </motion.div>
          )}

          {currentView === 'training-center' && (
            <motion.div
              key="training"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
            >
              <TrainingCenter
                modules={trainingModules}
                progress={trainingProgress}
                onModuleComplete={handleModuleComplete}
                onBack={handleBack}
              />
            </motion.div>
          )}

          {currentView === 'ai-report' && (
            <motion.div
              key="ai-report"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
            >
              <AIReportGenerator onBack={handleBack} />
            </motion.div>
          )}

          {currentView === 'citation-builder' && (
            <motion.div
              key="citation"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
            >
              <CitationBuilder
                history={citationHistory}
                onBack={handleBack}
              />
            </motion.div>
          )}

          {currentView === 'templates' && (
            <motion.div
              key="templates"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
            >
              <FormatTemplates
                onDownload={handleTemplateDownload}
                onBack={handleBack}
              />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}
