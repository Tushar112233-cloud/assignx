"use client"

import { useMemo } from "react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Search, Clock, AlertCircle, FolderKanban } from "lucide-react"
import { cn } from "@/lib/utils"

interface FilterState {
  myFieldOnly: boolean
  selectedFields: string[]
  urgentOnly: boolean
}

interface HeroSectionProps {
  supervisorName?: string
  filters: FilterState
  onFilterChange: (filters: FilterState) => void
  liveStats: {
    activeProjects: number
    needsReview: number
    newRequests: number
  }
  onCommandPaletteOpen?: () => void
}

export function HeroSection({
  supervisorName = "Supervisor",
  filters,
  onFilterChange,
  liveStats,
  onCommandPaletteOpen,
}: HeroSectionProps) {
  const greeting = useMemo(() => {
    const hour = new Date().getHours()
    if (hour < 12) return "Good morning"
    if (hour < 17) return "Good afternoon"
    return "Good evening"
  }, [])

  const toggleFilter = (key: keyof FilterState) => {
    if (key === "selectedFields") return
    onFilterChange({
      ...filters,
      [key]: !filters[key],
    })
  }

  return (
    <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[var(--dash-bg)] via-[var(--dash-bg-secondary)] to-[var(--dash-bg)] border border-[var(--dash-border)] p-6 lg:p-8">
      {/* Background Effects */}
      <div className="absolute inset-0 corner-gradient-br pointer-events-none" />
      <div className="absolute inset-0 corner-gradient-tl pointer-events-none" />

      <div className="relative z-10">
        {/* Top Row - Greeting and Live Stats */}
        <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4 mb-6">
          <div>
            <h1 className="text-3xl lg:text-4xl font-bold text-white tracking-tight">
              {greeting}, {supervisorName.split(" ")[0]} 👋
            </h1>
            <p className="text-[var(--dash-text-secondary)] mt-2">
              Here's what's happening with your projects today.
            </p>
          </div>

          {/* Live Stats Pills */}
          <div className="flex flex-wrap items-center gap-2">
            {liveStats.activeProjects > 0 && (
              <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-[var(--dash-accent)]/10 border border-[var(--dash-accent)]/30">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--dash-accent)] opacity-75" />
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-[var(--dash-accent)]" />
                </span>
                <FolderKanban className="h-3.5 w-3.5 text-[var(--dash-accent)]" />
                <span className="text-xs font-medium text-[var(--dash-accent)]">
                  {liveStats.activeProjects} Active
                </span>
              </div>
            )}

            {liveStats.needsReview > 0 && (
              <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-[var(--dash-highlight)]/10 border border-[var(--dash-highlight)]/30">
                <AlertCircle className="h-3.5 w-3.5 text-[var(--dash-highlight)]" />
                <span className="text-xs font-medium text-[var(--dash-highlight)]">
                  {liveStats.needsReview} Need Review
                </span>
              </div>
            )}

            {liveStats.newRequests > 0 && (
              <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-blue-500/10 border border-blue-500/30">
                <Clock className="h-3.5 w-3.5 text-blue-400" />
                <span className="text-xs font-medium text-blue-400">
                  {liveStats.newRequests} New
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Bottom Row - Filter Chips and Search */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          {/* Filter Chips */}
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-xs text-[var(--dash-text-muted)] mr-2">Filter by:</span>
            
            <button
              onClick={() => toggleFilter("myFieldOnly")}
              className={cn(
                "px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200",
                filters.myFieldOnly
                  ? "bg-[var(--dash-accent)] text-[var(--dash-bg)]"
                  : "bg-[var(--dash-surface)] text-[var(--dash-text-secondary)] border border-[var(--dash-border)] hover:border-[var(--dash-accent)]/50"
              )}
            >
              My Field
            </button>

            <button
              onClick={() => toggleFilter("urgentOnly")}
              className={cn(
                "px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200",
                filters.urgentOnly
                  ? "bg-[var(--dash-highlight)] text-white"
                  : "bg-[var(--dash-surface)] text-[var(--dash-text-secondary)] border border-[var(--dash-border)] hover:border-[var(--dash-highlight)]/50"
              )}
            >
              Urgent Only
            </button>

            <button
              onClick={() => onFilterChange({ ...filters, myFieldOnly: false, urgentOnly: false })}
              className={cn(
                "px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200",
                !filters.myFieldOnly && !filters.urgentOnly
                  ? "bg-white text-[var(--dash-bg)]"
                  : "bg-[var(--dash-surface)] text-[var(--dash-text-secondary)] border border-[var(--dash-border)] hover:border-white/50"
              )}
            >
              All Projects
            </button>
          </div>

          {/* Command Palette Trigger */}
          <Button
            variant="outline"
            size="sm"
            onClick={onCommandPaletteOpen}
            className="hidden md:flex items-center gap-2 bg-[var(--dash-surface)]/50 border-[var(--dash-border)] text-[var(--dash-text-secondary)] hover:bg-[var(--dash-surface)] hover:text-white"
          >
            <Search className="h-4 w-4" />
            <span className="text-xs">Search</span>
            <kbd className="hidden lg:inline-flex h-5 items-center gap-1 rounded border border-[var(--dash-border)] bg-[var(--dash-bg)] px-1.5 font-mono text-[10px] font-medium text-[var(--dash-text-muted)]">
              ⌘K
            </kbd>
          </Button>
        </div>
      </div>
    </div>
  )
}
