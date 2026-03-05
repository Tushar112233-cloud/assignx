/**
 * @fileoverview Training page -- displays modules and handles auto-creation of supervisor record.
 * @module app/training/page
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import { useRouter } from "next/navigation"
import {
  Loader2,
  CheckCircle2,
  PlayCircle,
  FileText,
  BookOpen,
  Clock,
  ArrowRight,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { getAccessToken } from "@/lib/api/client"
import { getStoredUser } from "@/lib/api/auth"
import { apiFetch } from "@/lib/api/client"
import {
  getTrainingModules,
  getTrainingProgress,
  markModuleComplete,
} from "@/lib/services/training"

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
}

const contentTypeIcon: Record<string, typeof PlayCircle> = {
  video: PlayCircle,
  pdf: FileText,
  article: BookOpen,
}

export default function TrainingPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [modules, setModules] = useState<TrainingModule[]>([])
  const [progress, setProgress] = useState<TrainingProgressRecord[]>([])
  const [userId, setUserId] = useState<string | null>(null)
  const [completing, setCompleting] = useState<string | null>(null)

  const completedIds = new Set(
    progress.filter((p) => p.status === "completed").map((p) => p.module_id)
  )
  const mandatoryModules = modules.filter((m) => m.is_mandatory)
  const completedCount = mandatoryModules.filter((m) => completedIds.has(m.id)).length
  const allComplete = mandatoryModules.length > 0 && completedCount === mandatoryModules.length

  const loadData = useCallback(async (profileId: string) => {
    const [mods, prog] = await Promise.all([
      getTrainingModules("supervisor"),
      getTrainingProgress(profileId),
    ])
    setModules(mods as TrainingModule[])
    setProgress(prog as TrainingProgressRecord[])
  }, [])

  useEffect(() => {
    const init = async () => {
      try {
        const token = getAccessToken()
        const user = getStoredUser()

        if (!token || !user) {
          router.replace("/login")
          return
        }

        setUserId(user.id)

        // Check if supervisor record exists (created on admin approval)
        try {
          await apiFetch("/api/supervisors/me")
        } catch {
          // Supervisor record not found -- not yet approved
          router.replace("/pending-approval")
          return
        }

        await loadData(user.id)
      } catch (err) {
        console.error("Training init error:", err)
      } finally {
        setLoading(false)
      }
    }

    init()
  }, [router, loadData])

  const handleMarkComplete = async (moduleId: string) => {
    if (!userId) return
    setCompleting(moduleId)
    try {
      await markModuleComplete(userId, moduleId)
      await loadData(userId)
    } catch (err) {
      console.error("Failed to mark module complete:", err)
    } finally {
      setCompleting(null)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-24">
        <Loader2 className="h-8 w-8 animate-spin text-[#F97316]" />
      </div>
    )
  }

  if (modules.length === 0) {
    return (
      <div className="text-center py-24 space-y-4">
        <CheckCircle2 className="h-12 w-12 text-emerald-500 mx-auto" />
        <h2 className="text-xl font-semibold text-[#1C1C1C]">No training required</h2>
        <p className="text-sm text-gray-400">You are ready to start.</p>
        <Button
          onClick={() => router.push("/dashboard")}
          className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-xl"
        >
          Go to Dashboard
          <ArrowRight className="h-4 w-4 ml-2" />
        </Button>
      </div>
    )
  }

  const progressPercent =
    mandatoryModules.length > 0
      ? Math.round((completedCount / mandatoryModules.length) * 100)
      : 100

  return (
    <div className="space-y-6">
      {/* Progress header */}
      <div>
        <h1 className="text-2xl font-bold text-[#1C1C1C]">Supervisor Training</h1>
        <p className="text-sm text-gray-400 mt-1">
          Complete all mandatory modules to access your dashboard.
        </p>
      </div>

      {/* Progress bar */}
      <div className="rounded-xl border border-gray-200/60 bg-white p-5 space-y-3">
        <div className="flex items-center justify-between text-sm">
          <span className="font-medium text-[#1C1C1C]">
            {completedCount} of {mandatoryModules.length} modules completed
          </span>
          <span className="text-[#F97316] font-semibold">{progressPercent}%</span>
        </div>
        <div className="h-2 rounded-full bg-gray-100 overflow-hidden">
          <div
            className="h-full rounded-full bg-[#F97316] transition-all duration-500"
            style={{ width: `${progressPercent}%` }}
          />
        </div>
      </div>

      {/* Module list */}
      <div className="space-y-3">
        {modules.map((mod) => {
          const isCompleted = completedIds.has(mod.id)
          const Icon = contentTypeIcon[mod.content_type] || BookOpen

          return (
            <div
              key={mod.id}
              className={`rounded-xl border bg-white p-5 flex items-start gap-4 transition-all ${
                isCompleted ? "border-emerald-200/60" : "border-gray-200/60"
              }`}
            >
              {/* Icon */}
              <div
                className={`h-10 w-10 rounded-lg flex items-center justify-center shrink-0 ${
                  isCompleted ? "bg-emerald-50" : "bg-[#F97316]/10"
                }`}
              >
                {isCompleted ? (
                  <CheckCircle2 className="h-5 w-5 text-emerald-500" />
                ) : (
                  <Icon className="h-5 w-5 text-[#F97316]" />
                )}
              </div>

              {/* Content */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-[10px] font-semibold uppercase tracking-wider text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">
                    {mod.content_type}
                  </span>
                  <span className="flex items-center gap-1 text-[10px] text-gray-400">
                    <Clock className="h-3 w-3" />
                    {mod.duration_minutes} min
                  </span>
                  {mod.is_mandatory && (
                    <span className="text-[10px] font-semibold text-[#F97316] bg-[#F97316]/10 px-2 py-0.5 rounded-full">
                      Required
                    </span>
                  )}
                </div>
                <h3 className="text-sm font-semibold text-[#1C1C1C]">{mod.title}</h3>
                {mod.description && (
                  <p className="text-xs text-gray-400 mt-0.5 line-clamp-2">{mod.description}</p>
                )}
              </div>

              {/* Action */}
              <div className="shrink-0">
                {isCompleted ? (
                  <span className="text-xs font-medium text-emerald-600">Completed</span>
                ) : (
                  <Button
                    size="sm"
                    onClick={() => handleMarkComplete(mod.id)}
                    disabled={completing === mod.id}
                    className="rounded-lg bg-[#F97316] hover:bg-[#EA580C] text-white text-xs h-8 px-3"
                  >
                    {completing === mod.id ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      "Mark as Complete"
                    )}
                  </Button>
                )}
              </div>
            </div>
          )
        })}
      </div>

      {/* Continue button */}
      {allComplete && (
        <div className="text-center pt-4">
          <Button
            onClick={() => router.push("/dashboard")}
            size="lg"
            className="rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold px-8"
          >
            Continue to Dashboard
            <ArrowRight className="h-4 w-4 ml-2" />
          </Button>
        </div>
      )}
    </div>
  )
}
