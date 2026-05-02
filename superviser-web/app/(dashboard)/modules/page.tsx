/**
 * @fileoverview Training modules page -- displays required training and tracks completion.
 * Redirects to dashboard once all modules are completed.
 * @module app/(dashboard)/modules/page
 */

"use client"

import { useState, useEffect, useCallback } from "react"
import { useRouter } from "next/navigation"
import { Loader2, CheckCircle2, Circle, BookOpen, ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import { apiFetch } from "@/lib/api/client"

interface TrainingModule {
  _id: string
  title: string
  description: string
  duration: number
  category: string
  order: number
  isCompleted: boolean
}

interface ModulesResponse {
  modules: TrainingModule[]
  totalRequired: number
  totalCompleted: number
  allCompleted: boolean
}

export default function ModulesPage() {
  const router = useRouter()
  const [data, setData] = useState<ModulesResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [completing, setCompleting] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const fetchModules = useCallback(async () => {
    try {
      const result = await apiFetch<ModulesResponse>("/api/supervisors/me/modules")
      setData(result)

      if (result.allCompleted) {
        // Small delay then redirect
        setTimeout(() => router.push("/dashboard"), 1500)
      }
    } catch {
      setError("Failed to load training modules.")
    } finally {
      setLoading(false)
    }
  }, [router])

  useEffect(() => {
    fetchModules()
  }, [fetchModules])

  const handleComplete = async (moduleId: string) => {
    setCompleting(moduleId)
    try {
      const result = await apiFetch<{ success: boolean; allCompleted: boolean; isActivated: boolean }>(
        `/api/supervisors/me/modules/${moduleId}/complete`,
        { method: "PUT" }
      )

      // Refresh the module list
      await fetchModules()

      if (result.allCompleted) {
        router.push("/dashboard")
      }
    } catch {
      setError("Failed to mark module as complete.")
    } finally {
      setCompleting(null)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FAFAFA]">
        <div className="flex flex-col items-center gap-3">
          <Loader2 className="h-8 w-8 animate-spin text-[#F97316]" />
          <p className="text-sm text-gray-500">Loading training modules...</p>
        </div>
      </div>
    )
  }

  if (error && !data) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FAFAFA]">
        <div className="text-center space-y-3">
          <p className="text-sm text-red-600">{error}</p>
          <Button variant="outline" onClick={() => { setError(null); setLoading(true); fetchModules() }}>
            Try again
          </Button>
        </div>
      </div>
    )
  }

  const modules = data?.modules || []
  const progress = data ? Math.round((data.totalCompleted / Math.max(data.totalRequired, 1)) * 100) : 0

  return (
    <div className="min-h-screen bg-[#FAFAFA]">
      <div className="max-w-2xl mx-auto px-4 py-12">
        {/* Header */}
        <div className="mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-[#F97316]/15 bg-[#F97316]/[0.06] px-3 py-1 text-[11px] font-semibold text-[#F97316] uppercase tracking-wider mb-4">
            <BookOpen className="h-3 w-3" />
            Training Required
          </div>
          <h1 className="text-[28px] font-bold tracking-tight text-[#1C1C1C]">
            Complete your training
          </h1>
          <p className="mt-2 text-sm text-gray-500 leading-relaxed">
            Complete all training modules before accessing the dashboard.
          </p>
        </div>

        {/* Progress bar */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-semibold text-gray-500">Progress</span>
            <span className="text-xs font-semibold text-[#F97316]">
              {data?.totalCompleted || 0} / {data?.totalRequired || 0} completed
            </span>
          </div>
          <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
            <div
              className="h-full bg-[#F97316] rounded-full transition-all duration-500"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Module list */}
        <div className="space-y-3">
          {modules.map((mod) => (
            <div
              key={mod._id}
              className={`rounded-2xl border p-5 transition-all ${
                mod.isCompleted
                  ? "border-emerald-200 bg-emerald-50/50"
                  : "border-gray-200 bg-white shadow-sm"
              }`}
            >
              <div className="flex items-start gap-4">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
                  mod.isCompleted ? "bg-emerald-100" : "bg-gray-100"
                }`}>
                  {mod.isCompleted ? (
                    <CheckCircle2 className="h-5 w-5 text-emerald-600" />
                  ) : (
                    <Circle className="h-5 w-5 text-gray-400" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className={`text-sm font-semibold ${
                    mod.isCompleted ? "text-emerald-700" : "text-[#1C1C1C]"
                  }`}>
                    {mod.title}
                  </h3>
                  <p className="text-xs text-gray-500 mt-1 leading-relaxed">
                    {mod.description}
                  </p>
                  <div className="flex items-center gap-3 mt-2">
                    <span className="text-[10px] font-medium text-gray-400 uppercase tracking-wider">
                      {mod.category}
                    </span>
                    {mod.duration > 0 && (
                      <span className="text-[10px] text-gray-400">
                        ~{mod.duration} min
                      </span>
                    )}
                  </div>
                </div>
                {!mod.isCompleted && (
                  <Button
                    size="sm"
                    onClick={() => handleComplete(mod._id)}
                    disabled={completing === mod._id}
                    className="shrink-0 rounded-xl bg-[#F97316] hover:bg-[#EA580C] text-white font-semibold text-xs"
                  >
                    {completing === mod._id ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      "Mark Complete"
                    )}
                  </Button>
                )}
                {mod.isCompleted && (
                  <span className="text-[11px] font-semibold text-emerald-600 bg-emerald-100 px-2.5 py-1 rounded-full shrink-0">
                    Done
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>

        {/* All completed message */}
        {data?.allCompleted && (
          <div className="mt-8 text-center space-y-4">
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-4 py-2 text-sm font-semibold text-emerald-700">
              <CheckCircle2 className="h-4 w-4" />
              All modules completed!
            </div>
            <div>
              <Button
                onClick={() => router.push("/dashboard")}
                className="rounded-xl bg-[#1C1C1C] hover:bg-[#2D2D2D] text-white font-semibold"
              >
                Continue to Dashboard
                <ArrowRight className="h-4 w-4 ml-2" />
              </Button>
            </div>
          </div>
        )}

        {error && (
          <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            {error}
          </div>
        )}
      </div>
    </div>
  )
}
