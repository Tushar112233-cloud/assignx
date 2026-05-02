'use client'

import { motion } from 'framer-motion'
import {
  Grid3x3,
  List,
  Calendar,
  SlidersHorizontal,
  X,
  Clock,
  DollarSign,
  Flag,
  Filter,
} from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { cn } from '@/lib/utils'
import type { ProjectStatus } from '@/types/database'

/**
 * View mode type
 */
export type ViewMode = 'grid' | 'list' | 'timeline'

/**
 * Sort option type
 */
export type SortOption = 'deadline' | 'price' | 'status' | 'created'

/**
 * Filter state interface
 */
export interface FilterState {
  /** Selected statuses */
  statuses: ProjectStatus[]
  /** Urgency filter */
  urgent: boolean | null
  /** Sort option */
  sortBy: SortOption
  /** Sort direction */
  sortDirection: 'asc' | 'desc'
}

/**
 * Props for FilterControls component
 */
interface FilterControlsProps {
  /** Current view mode */
  viewMode: ViewMode
  /** Callback when view mode changes */
  onViewModeChange: (mode: ViewMode) => void
  /** Current filter state */
  filters: FilterState
  /** Callback when filters change */
  onFiltersChange: (filters: FilterState) => void
  /** Total number of projects */
  totalProjects: number
  /** Number of filtered projects */
  filteredProjects: number
  /** Additional CSS classes */
  className?: string
}

/**
 * Status filter options
 */
const STATUS_FILTERS: Array<{ value: ProjectStatus; label: string; color: string }> = [
  { value: 'assigned', label: 'Not Started', color: 'bg-amber-100 text-amber-700 border-amber-200' },
  { value: 'in_progress', label: 'In Progress', color: 'bg-sky-100 text-sky-700 border-sky-200' },
  { value: 'revision_requested', label: 'Revision', color: 'bg-rose-100 text-rose-700 border-rose-200' },
  { value: 'in_revision', label: 'Revising', color: 'bg-violet-100 text-violet-700 border-violet-200' },
  { value: 'submitted_for_qc', label: 'Under Review', color: 'bg-indigo-100 text-indigo-700 border-indigo-200' },
  { value: 'completed', label: 'Completed', color: 'bg-emerald-100 text-emerald-700 border-emerald-200' },
]

/**
 * Sort options
 */
const SORT_OPTIONS: Array<{ value: SortOption; label: string; icon: React.ElementType }> = [
  { value: 'deadline', label: 'Deadline', icon: Clock },
  { value: 'price', label: 'Price', icon: DollarSign },
  { value: 'status', label: 'Status', icon: Flag },
  { value: 'created', label: 'Created Date', icon: Calendar },
]

/**
 * FilterControls Component
 *
 * Advanced filtering and view controls for projects page.
 * Features:
 * - Pill-style filter buttons with gradient on active
 * - View mode toggle (Grid/List/Timeline)
 * - Status filters with color coding
 * - Urgency filter
 * - Sort options with direction toggle
 * - Active filter count badge
 * - Clear all filters button
 * - Smooth animations
 * - Fully responsive design
 *
 * @example
 * ```tsx
 * const [filters, setFilters] = useState<FilterState>({
 *   statuses: [],
 *   urgent: null,
 *   sortBy: 'deadline',
 *   sortDirection: 'asc'
 * })
 *
 * <FilterControls
 *   viewMode={viewMode}
 *   onViewModeChange={setViewMode}
 *   filters={filters}
 *   onFiltersChange={setFilters}
 *   totalProjects={50}
 *   filteredProjects={12}
 * />
 * ```
 */
export function FilterControls({
  viewMode,
  onViewModeChange,
  filters,
  onFiltersChange,
  totalProjects,
  filteredProjects,
  className,
}: FilterControlsProps) {
  // Calculate active filter count
  const activeFilterCount =
    filters.statuses.length + (filters.urgent !== null ? 1 : 0)

  // Toggle status filter
  const toggleStatus = (status: ProjectStatus) => {
    const newStatuses = filters.statuses.includes(status)
      ? filters.statuses.filter((s) => s !== status)
      : [...filters.statuses, status]

    onFiltersChange({ ...filters, statuses: newStatuses })
  }

  // Toggle urgent filter
  const toggleUrgent = () => {
    onFiltersChange({
      ...filters,
      urgent: filters.urgent === true ? null : true,
    })
  }

  // Change sort option
  const changeSortBy = (sortBy: SortOption) => {
    // If clicking the same sort option, toggle direction
    if (filters.sortBy === sortBy) {
      onFiltersChange({
        ...filters,
        sortDirection: filters.sortDirection === 'asc' ? 'desc' : 'asc',
      })
    } else {
      onFiltersChange({ ...filters, sortBy, sortDirection: 'asc' })
    }
  }

  // Clear all filters
  const clearFilters = () => {
    onFiltersChange({
      statuses: [],
      urgent: null,
      sortBy: 'deadline',
      sortDirection: 'asc',
    })
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      className={cn(
        'sticky top-0 z-10 rounded-2xl border border-border/70 bg-white/95 p-4 shadow-[0_12px_30px_rgba(148,163,184,0.12)] backdrop-blur-md',
        className
      )}
    >
      <div className="space-y-4">
        {/* Top row: View mode, Sort, and Results count */}
        <div className="flex flex-wrap items-center justify-between gap-3">
          {/* View mode toggle */}
          <div className="flex items-center gap-2 rounded-full bg-slate-100 p-1">
            <Button
              size="sm"
              variant="ghost"
              onClick={() => onViewModeChange('grid')}
              className={cn(
                'h-8 w-8 rounded-full p-0 transition-all hover:bg-slate-200 hover:text-slate-900',
                viewMode === 'grid' &&
                  'bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(91,124,255,0.25)] hover:bg-gradient-to-r hover:from-[#4A6CFF] hover:via-[#4B76FF] hover:to-[#39B5FF] hover:text-white'
              )}
              aria-label="Grid view"
            >
              <Grid3x3 className="h-4 w-4" />
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => onViewModeChange('list')}
              className={cn(
                'h-8 w-8 rounded-full p-0 transition-all hover:bg-slate-200 hover:text-slate-900',
                viewMode === 'list' &&
                  'bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(91,124,255,0.25)] hover:bg-gradient-to-r hover:from-[#4A6CFF] hover:via-[#4B76FF] hover:to-[#39B5FF] hover:text-white'
              )}
              aria-label="List view"
            >
              <List className="h-4 w-4" />
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => onViewModeChange('timeline')}
              className={cn(
                'h-8 w-8 rounded-full p-0 transition-all hover:bg-slate-200 hover:text-slate-900',
                viewMode === 'timeline' &&
                  'bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(91,124,255,0.25)] hover:bg-gradient-to-r hover:from-[#4A6CFF] hover:via-[#4B76FF] hover:to-[#39B5FF] hover:text-white'
              )}
              aria-label="Timeline view"
            >
              <Calendar className="h-4 w-4" />
            </Button>
          </div>

          {/* Sort dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                size="sm"
                variant="outline"
                className="gap-2 rounded-full border-slate-200 bg-white hover:bg-slate-50"
              >
                <SlidersHorizontal className="h-4 w-4" />
                <span className="hidden sm:inline">Sort by:</span>
                <span className="font-semibold">
                  {SORT_OPTIONS.find((opt) => opt.value === filters.sortBy)?.label}
                </span>
                <span className="text-slate-400">
                  {filters.sortDirection === 'asc' ? '↑' : '↓'}
                </span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48">
              <DropdownMenuLabel className="text-xs text-slate-500">
                Sort by
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              {SORT_OPTIONS.map((option) => {
                const Icon = option.icon
                return (
                  <DropdownMenuItem
                    key={option.value}
                    onClick={() => changeSortBy(option.value)}
                    className={cn(
                      'gap-2',
                      filters.sortBy === option.value && 'bg-[#EEF2FF] text-[#4F6CF7]'
                    )}
                  >
                    <Icon className="h-4 w-4" />
                    <span>{option.label}</span>
                    {filters.sortBy === option.value && (
                      <span className="ml-auto text-xs text-slate-400">
                        {filters.sortDirection === 'asc' ? '↑' : '↓'}
                      </span>
                    )}
                  </DropdownMenuItem>
                )
              })}
            </DropdownMenuContent>
          </DropdownMenu>

          {/* Results count */}
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <span className="font-semibold text-slate-900">{filteredProjects}</span>
            <span className="text-slate-500">of {totalProjects}</span>
            <span className="hidden sm:inline text-slate-500">projects</span>
          </div>
        </div>

        {/* Filter pills */}
        <div className="flex flex-wrap items-center gap-2">
          <div className="flex items-center gap-1.5 text-xs font-semibold text-slate-600">
            <Filter className="h-4 w-4" />
            <span className="hidden sm:inline">Filters:</span>
          </div>

          {/* Status filters */}
          <div className="flex flex-wrap items-center gap-2">
            {STATUS_FILTERS.map((status) => {
              const isActive = filters.statuses.includes(status.value)
              return (
                <motion.button
                  key={status.value}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => toggleStatus(status.value)}
                  className={cn(
                    'rounded-full border px-3 py-1 text-xs font-medium transition-all',
                    isActive
                      ? 'border-transparent bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] text-white shadow-[0_8px_20px_rgba(91,124,255,0.25)]'
                      : cn('border-border bg-white hover:bg-slate-50', status.color)
                  )}
                >
                  {status.label}
                </motion.button>
              )
            })}
          </div>

          {/* Urgent filter */}
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={toggleUrgent}
            className={cn(
              'rounded-full border px-3 py-1 text-xs font-medium transition-all',
              filters.urgent === true
                ? 'border-transparent bg-gradient-to-r from-rose-500 to-rose-600 text-white shadow-[0_8px_20px_rgba(239,68,68,0.25)]'
                : 'border-border bg-white text-rose-700 hover:bg-rose-50'
            )}
          >
            🔥 Urgent
          </motion.button>

          {/* Clear filters button */}
          {activeFilterCount > 0 && (
            <motion.button
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              onClick={clearFilters}
              className="flex items-center gap-1.5 rounded-full border border-slate-200 bg-white px-3 py-1 text-xs font-medium text-slate-600 transition-all hover:bg-slate-50"
            >
              <X className="h-3 w-3" />
              <span>Clear all</span>
              <Badge
                variant="secondary"
                className="ml-1 h-4 w-4 rounded-full p-0 text-[10px] bg-slate-200 text-slate-700"
              >
                {activeFilterCount}
              </Badge>
            </motion.button>
          )}
        </div>
      </div>
    </motion.div>
  )
}
