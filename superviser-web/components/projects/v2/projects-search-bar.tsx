"use client"

import { Search, Filter, SlidersHorizontal, X, Sparkles } from "lucide-react"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"

interface ProjectsSearchBarProps {
  searchQuery: string
  onSearchChange: (value: string) => void
  selectedSubject: string
  onSubjectChange: (value: string) => void
  sortBy: "deadline" | "created" | "amount"
  onSortChange: (value: "deadline" | "created" | "amount") => void
  subjects: string[]
  hasActiveFilters?: boolean
  onClearFilters?: () => void
}

const sortOptions = [
  { value: "deadline", label: "Deadline (Nearest)" },
  { value: "created", label: "Recently Created" },
  { value: "amount", label: "Highest Value" },
] as const

export function ProjectsSearchBar({
  searchQuery,
  onSearchChange,
  selectedSubject,
  onSubjectChange,
  sortBy,
  onSortChange,
  subjects,
  hasActiveFilters = false,
  onClearFilters,
}: ProjectsSearchBarProps) {
  const currentSortLabel = sortOptions.find((opt) => opt.value === sortBy)?.label || "Sort"
  const activeChips = [
    ...(searchQuery ? [`Search: ${searchQuery}`] : []),
    ...(selectedSubject !== "all" ? [selectedSubject] : []),
  ]

  return (
    <div className="bg-white rounded-2xl border border-gray-200 p-5">
      <div className="flex items-center justify-between gap-3 mb-4">
        <div className="flex items-center gap-2 text-xs font-medium text-gray-500">
          <Sparkles className="h-3.5 w-3.5" />
          Control Deck
        </div>
        {hasActiveFilters && onClearFilters && (
          <Button
            variant="ghost"
            onClick={onClearFilters}
            className="h-8 px-3 rounded-full text-xs text-gray-500 hover:text-orange-600"
          >
            Clear filters
          </Button>
        )}
      </div>

      <div className="space-y-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <Input
            type="text"
            placeholder="Search projects by title, number, or owner..."
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            className="pl-9 pr-9 rounded-2xl border-gray-200 bg-gray-50 focus:border-orange-300 focus:ring-orange-200"
          />
          {searchQuery && (
            <button
              onClick={() => onSearchChange("")}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>

        <div className="flex flex-col sm:flex-row gap-3">
          <Select value={selectedSubject} onValueChange={onSubjectChange}>
            <SelectTrigger className="w-full sm:w-[200px] rounded-xl border-gray-200 bg-white">
              <div className="flex items-center gap-2">
                <Filter className="h-4 w-4 text-gray-400" />
                <SelectValue placeholder="All Subjects" />
              </div>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Subjects</SelectItem>
              {subjects.map((subject) => (
                <SelectItem key={subject} value={subject}>
                  {subject}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="outline"
                className="w-full sm:w-auto rounded-xl border-gray-200 gap-2"
              >
                <SlidersHorizontal className="h-4 w-4" />
                <span className="hidden sm:inline">{currentSortLabel}</span>
                <span className="sm:hidden">Sort</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48">
              {sortOptions.map((option) => (
                <DropdownMenuItem
                  key={option.value}
                  onClick={() => onSortChange(option.value)}
                  className={sortBy === option.value ? "bg-orange-50 text-orange-600" : ""}
                >
                  {option.label}
                </DropdownMenuItem>
              ))}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {activeChips.length > 0 && (
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-xs text-gray-400">Active filters</span>
            {activeChips.map((chip) => (
              <span
                key={chip}
                className="text-xs px-2.5 py-1 rounded-full bg-orange-50 text-orange-700 border border-orange-100"
              >
                {chip}
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
