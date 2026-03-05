'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { CheckCircle2, PlayCircle, Loader2, ArrowRight, BookOpen } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { apiClient, getAccessToken } from '@/lib/api/client'
import { getTrainingModules, getTrainingProgress, markModuleComplete, isTrainingComplete } from '@/lib/services/training'

interface TrainingModule {
  id: string
  title: string
  description: string
  content_type: string
  content_url: string | null
  duration_minutes: number
  sequence_order: number
  is_mandatory: boolean
}

interface TrainingProgressRecord {
  module_id: string
  status: string
  progress_percentage: number
}

export default function TrainingPage() {
  const router = useRouter()
  const [modules, setModules] = useState<TrainingModule[]>([])
  const [progress, setProgress] = useState<TrainingProgressRecord[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [completingId, setCompletingId] = useState<string | null>(null)
  const [userId, setUserId] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [allDone, setAllDone] = useState(false)

  const loadData = useCallback(async () => {
    try {
      const token = getAccessToken()
      if (!token) {
        router.push('/login')
        return
      }

      const user = await apiClient<{ id: string }>('/api/auth/me')
      if (!user) {
        router.push('/login')
        return
      }

      setUserId(user.id)

      const [mods, prog] = await Promise.all([
        getTrainingModules('doer'),
        getTrainingProgress(),
      ])

      setModules(mods)
      setProgress(prog)

      // Check if all training is complete
      const done = await isTrainingComplete('doer')
      setAllDone(done)
    } catch (err) {
      console.error('Error loading training data:', err)
      setError('Failed to load training modules. Please refresh the page.')
    } finally {
      setIsLoading(false)
    }
  }, [router])

  useEffect(() => {
    loadData()
  }, [loadData])

  const handleMarkComplete = async (moduleId: string) => {
    if (!userId || completingId) return
    setCompletingId(moduleId)
    setError(null)

    try {
      await markModuleComplete(moduleId)

      // Refresh progress
      const updatedProgress = await getTrainingProgress()
      setProgress(updatedProgress)

      // Check if all done
      const done = await isTrainingComplete('doer')
      setAllDone(done)
    } catch (err) {
      console.error('Error marking module complete:', err)
      setError('Failed to mark module as complete. Please try again.')
    } finally {
      setCompletingId(null)
    }
  }

  const getModuleStatus = (moduleId: string) => {
    const p = progress.find(pr => pr.module_id === moduleId)
    return p?.status || 'not_started'
  }

  const completedCount = progress.filter(p => p.status === 'completed').length
  const totalMandatory = modules.filter(m => m.is_mandatory).length
  const progressPercent = totalMandatory > 0 ? Math.round((completedCount / totalMandatory) * 100) : 0

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <Loader2 className="h-8 w-8 animate-spin text-[#5A7CFF]" />
          <p className="text-sm text-slate-500">Loading training modules...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-[#F5F8FF]">
      <div className="max-w-2xl mx-auto px-4 py-8 space-y-6">
        {/* Header */}
        <div className="space-y-2">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] flex items-center justify-center shadow-lg shadow-[#5A7CFF]/20">
              <BookOpen className="h-6 w-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold tracking-tight text-slate-900">Training</h1>
              <p className="text-sm text-slate-500">Complete all mandatory modules to get started</p>
            </div>
          </div>
        </div>

        {/* Progress bar */}
        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm font-semibold text-slate-700">Overall progress</span>
            <span className="text-sm font-bold text-[#5A7CFF]">{progressPercent}%</span>
          </div>
          <div className="w-full h-2.5 bg-slate-100 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF] rounded-full transition-all duration-500"
              style={{ width: `${progressPercent}%` }}
            />
          </div>
          <p className="mt-2 text-xs text-slate-400">
            {completedCount} of {totalMandatory} mandatory modules completed
          </p>
        </div>

        {/* Error */}
        {error && (
          <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            {error}
          </div>
        )}

        {/* Module cards */}
        <div className="space-y-3">
          {modules.map((mod, index) => {
            const status = getModuleStatus(mod.id)
            const isCompleted = status === 'completed'
            const isCompleting = completingId === mod.id

            return (
              <div
                key={mod.id}
                className={`rounded-2xl border bg-white p-5 shadow-sm transition-all ${
                  isCompleted ? 'border-emerald-200' : 'border-slate-200'
                }`}
              >
                <div className="flex items-start gap-4">
                  <div
                    className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
                      isCompleted
                        ? 'bg-emerald-100'
                        : 'bg-[#5A7CFF]/10'
                    }`}
                  >
                    {isCompleted ? (
                      <CheckCircle2 className="h-5 w-5 text-emerald-600" />
                    ) : (
                      <PlayCircle className="h-5 w-5 text-[#5A7CFF]" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-medium text-slate-400">Module {index + 1}</span>
                      {mod.is_mandatory && (
                        <span className="text-[10px] font-semibold text-[#5A7CFF] bg-[#EEF2FF] px-1.5 py-0.5 rounded-full">
                          Required
                        </span>
                      )}
                      {isCompleted && (
                        <span className="text-[10px] font-semibold text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded-full">
                          Completed
                        </span>
                      )}
                    </div>
                    <h3 className="text-sm font-semibold text-slate-900 mt-0.5">{mod.title}</h3>
                    <p className="text-xs text-slate-500 mt-1 leading-relaxed">{mod.description}</p>
                    {mod.duration_minutes > 0 && (
                      <p className="text-[11px] text-slate-400 mt-1">
                        ~{mod.duration_minutes} min
                      </p>
                    )}

                    {mod.content_url && !isCompleted && (
                      <a
                        href={mod.content_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 mt-2 text-xs font-semibold text-[#5A7CFF] hover:underline underline-offset-4"
                      >
                        <PlayCircle className="h-3.5 w-3.5" />
                        View content
                      </a>
                    )}

                    {!isCompleted && (
                      <Button
                        onClick={() => handleMarkComplete(mod.id)}
                        disabled={isCompleting}
                        size="sm"
                        className="mt-3 h-8 rounded-lg bg-[#5A7CFF] text-white text-xs font-semibold hover:bg-[#4A6CE8]"
                      >
                        {isCompleting ? (
                          <>
                            <Loader2 className="h-3 w-3 animate-spin mr-1" />
                            Saving...
                          </>
                        ) : (
                          'Mark as Complete'
                        )}
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            )
          })}
        </div>

        {/* No modules state */}
        {modules.length === 0 && (
          <div className="rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-sm">
            <BookOpen className="h-10 w-10 text-slate-300 mx-auto" />
            <p className="mt-3 text-sm text-slate-500">No training modules available yet.</p>
            <Button
              onClick={() => router.push('/dashboard')}
              className="mt-4 h-10 rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white font-semibold"
            >
              Continue to Dashboard
              <ArrowRight className="h-4 w-4 ml-2" />
            </Button>
          </div>
        )}

        {/* All done */}
        {allDone && modules.length > 0 && (
          <div className="rounded-2xl border border-emerald-200 bg-gradient-to-br from-emerald-50 to-white p-6 text-center shadow-sm">
            <div className="w-14 h-14 rounded-full bg-emerald-100 flex items-center justify-center mx-auto">
              <CheckCircle2 className="h-7 w-7 text-emerald-600" />
            </div>
            <h3 className="mt-3 text-lg font-bold text-slate-900">Training Complete!</h3>
            <p className="mt-1 text-sm text-slate-500">
              You have completed all mandatory training modules.
            </p>
            <Button
              onClick={() => router.push('/dashboard')}
              size="lg"
              className="mt-4 h-11 rounded-xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white font-semibold shadow-[0_8px_24px_rgba(90,124,255,0.30)] hover:shadow-[0_12px_32px_rgba(90,124,255,0.40)] hover:opacity-95"
            >
              Continue to Dashboard
              <ArrowRight className="h-4 w-4 ml-2" />
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}
