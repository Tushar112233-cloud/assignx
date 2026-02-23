"use client"

import { Search, LayoutGrid, List, SlidersHorizontal, Download, X } from "lucide-react"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"

interface AdvancedFilterBarProps {
  searchQuery: string
  onSearchChange: (query: string) => void
  viewMode: 'grid' | 'table'
  onViewModeChange: (mode: 'grid' | 'table') => void
  statusFilter: string
  onStatusFilterChange: (status: string) => void
  projectsFilter?: string
  onProjectsFilterChange?: (filter: string) => void
  spendingFilter?: string
  onSpendingFilterChange?: (filter: string) => void
  sortBy: string
  onSortByChange: (sort: string) => void
  onExport?: () => void
  onClearAll?: () => void
  extraFilters?: Array<{ id: string; label: string }>
  onExtraFilterClear?: (id: string) => void
}

export function AdvancedFilterBar({
  searchQuery,
  onSearchChange,
  viewMode,
  onViewModeChange,
  statusFilter,
  onStatusFilterChange,
  projectsFilter = 'all',
  onProjectsFilterChange,
  spendingFilter = 'all',
  onSpendingFilterChange,
  sortBy,
  onSortByChange,
  onExport,
  onClearAll,
  extraFilters = [],
  onExtraFilterClear,
}: AdvancedFilterBarProps) {
  // Calculate active filters
  const activeFilters = [
    searchQuery && { type: 'search', label: `Search: ${searchQuery}`, value: searchQuery },
    statusFilter !== 'all' && { type: 'status', label: `Status: ${statusFilter}`, value: statusFilter },
    projectsFilter !== 'all' && { type: 'projects', label: `Projects: ${projectsFilter}`, value: projectsFilter },
    spendingFilter !== 'all' && { type: 'spending', label: `Spending: ${spendingFilter}`, value: spendingFilter },
    ...extraFilters.map((filter) => ({ type: filter.id, label: filter.label, value: filter.id })),
  ].filter(Boolean) as Array<{ type: string; label: string; value: string }>

  const handleClearFilter = (type: string) => {
    switch (type) {
      case 'search':
        onSearchChange('')
        break
      case 'status':
        onStatusFilterChange('all')
        break
      case 'projects':
        onProjectsFilterChange?.('all')
        break
      case 'spending':
        onSpendingFilterChange?.('all')
        break
      default:
        onExtraFilterClear?.(type)
        break
    }
  }

  const handleClearAll = () => {
    onStatusFilterChange('all')
    onProjectsFilterChange?.('all')
    onSpendingFilterChange?.('all')
    onSearchChange('')
    extraFilters.forEach((filter) => onExtraFilterClear?.(filter.id))
    onClearAll?.()
  }

  return (
    <div className="bg-white/90 border border-gray-200 rounded-2xl p-6 shadow-sm">
      {/* Main Filter Row */}
      <div className="flex flex-col lg:flex-row lg:flex-wrap gap-4 items-start lg:items-center">
        {/* Search Input */}
        <div className="relative flex-1 w-full lg:max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <Input
            type="text"
            placeholder="Search by name, email, college..."
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            className="pl-10 bg-gray-50 border border-gray-200 rounded-xl focus-visible:ring-orange-500 focus-visible:bg-white"
          />
        </div>

        {/* View Mode Toggle */}
        <div className="flex items-center bg-gray-50 border border-gray-200 rounded-xl p-1">
          <button
            onClick={() => onViewModeChange('grid')}
            className={cn(
              "flex items-center gap-2 px-4 py-2 rounded-lg transition-all",
              viewMode === 'grid'
                ? "bg-orange-500 text-white shadow-sm"
                : "text-gray-600 hover:text-gray-900"
            )}
          >
            <LayoutGrid className="h-4 w-4" />
            <span className="text-sm font-medium hidden sm:inline">Grid</span>
          </button>
          <button
            onClick={() => onViewModeChange('table')}
            className={cn(
              "flex items-center gap-2 px-4 py-2 rounded-lg transition-all",
              viewMode === 'table'
                ? "bg-orange-500 text-white shadow-sm"
                : "text-gray-600 hover:text-gray-900"
            )}
          >
            <List className="h-4 w-4" />
            <span className="text-sm font-medium hidden sm:inline">Table</span>
          </button>
        </div>

        {/* Filter Dropdowns */}
        <div className="flex flex-wrap gap-2 items-center">
          {/* Status Filter */}
          <Select value={statusFilter} onValueChange={onStatusFilterChange}>
            <SelectTrigger className="w-[140px] bg-gray-50 border border-gray-200 rounded-xl focus:ring-orange-500">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value="active">Active</SelectItem>
              <SelectItem value="inactive">Inactive</SelectItem>
            </SelectContent>
          </Select>

          {/* Projects Filter */}
          <Select value={projectsFilter} onValueChange={onProjectsFilterChange}>
            <SelectTrigger className="w-[160px] bg-gray-50 border border-gray-200 rounded-xl focus:ring-orange-500">
              <SelectValue placeholder="Projects" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Projects</SelectItem>
              <SelectItem value="has-projects">Has Projects</SelectItem>
              <SelectItem value="no-projects">No Projects</SelectItem>
            </SelectContent>
          </Select>

          {/* Spending Filter */}
          <Select value={spendingFilter} onValueChange={onSpendingFilterChange}>
            <SelectTrigger className="w-[160px] bg-gray-50 border border-gray-200 rounded-xl focus:ring-orange-500">
              <SelectValue placeholder="Spending" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Spending</SelectItem>
              <SelectItem value="high">High Value (&gt;50k)</SelectItem>
              <SelectItem value="medium">Medium (10k-50k)</SelectItem>
              <SelectItem value="low">Low (&lt;10k)</SelectItem>
            </SelectContent>
          </Select>

          {/* Sort Dropdown */}
          <Select value={sortBy} onValueChange={onSortByChange}>
            <SelectTrigger className="w-[180px] bg-gray-50 border border-gray-200 rounded-xl focus:ring-orange-500">
              <div className="flex items-center gap-2">
                <SlidersHorizontal className="h-4 w-4" />
                <SelectValue placeholder="Sort by" />
              </div>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="recent">Recent First</SelectItem>
              <SelectItem value="name-asc">Name A-Z</SelectItem>
              <SelectItem value="name-desc">Name Z-A</SelectItem>
              <SelectItem value="projects-high">Projects High-Low</SelectItem>
              <SelectItem value="projects-low">Projects Low-High</SelectItem>
              <SelectItem value="revenue-high">Revenue High-Low</SelectItem>
              <SelectItem value="revenue-low">Revenue Low-High</SelectItem>
            </SelectContent>
          </Select>

          {/* Export Button */}
          {onExport && (
            <Button
              variant="outline"
              onClick={onExport}
              className="rounded-xl border-gray-300 hover:border-orange-500 hover:text-orange-500"
            >
              <Download className="h-4 w-4 mr-2" />
              Export
            </Button>
          )}
        </div>
      </div>

      {/* Active Filter Badges */}
      {activeFilters.length > 0 && (
        <div className="flex flex-wrap gap-2 items-center mt-4 pt-4 border-t border-gray-200">
          <span className="text-sm text-gray-600 font-medium">Active Filters:</span>
          {activeFilters.map((filter) => (
            <Badge
              key={filter.type}
              variant="secondary"
              className="bg-orange-50 text-orange-700 hover:bg-orange-100 rounded-lg pl-3 pr-2 py-1.5 gap-2"
            >
              <span className="text-sm">{filter.label}</span>
              <button
                onClick={() => handleClearFilter(filter.type)}
                className="hover:bg-orange-200 rounded-full p-0.5 transition-colors"
                aria-label={`Remove ${filter.type} filter`}
              >
                <X className="h-3 w-3" />
              </button>
            </Badge>
          ))}
          <Button
            variant="ghost"
            size="sm"
            onClick={handleClearAll}
            className="text-orange-600 hover:text-orange-700 hover:bg-orange-50 rounded-lg"
          >
            Clear All
          </Button>
        </div>
      )}
    </div>
  )
}
