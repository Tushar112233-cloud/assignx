/**
 * @fileoverview Filter controls for project request listings.
 * @module components/dashboard/request-filter
 */

"use client"

import { useState } from "react"
import { Check, ChevronsUpDown, Filter, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { cn } from "@/lib/utils"
import { EXPERTISE_AREAS } from "@/lib/constants"

interface RequestFilterProps {
  supervisorFields?: string[]
  onFilterChange: (filters: FilterState) => void
}

export interface FilterState {
  myFieldOnly: boolean
  selectedFields: string[]
  urgentOnly: boolean
}

export function RequestFilter({
  supervisorFields = [],
  onFilterChange,
}: RequestFilterProps) {
  const [open, setOpen] = useState(false)
  const [filters, setFilters] = useState<FilterState>({
    myFieldOnly: true,
    selectedFields: supervisorFields,
    urgentOnly: false,
  })

  const updateFilters = (newFilters: Partial<FilterState>) => {
    const updated = { ...filters, ...newFilters }
    setFilters(updated)
    onFilterChange(updated)
  }

  const handleFieldSelect = (fieldValue: string) => {
    const isSelected = filters.selectedFields.includes(fieldValue)
    const newFields = isSelected
      ? filters.selectedFields.filter((f) => f !== fieldValue)
      : [...filters.selectedFields, fieldValue]
    updateFilters({ selectedFields: newFields, myFieldOnly: false })
  }

  const handleMyFieldToggle = (checked: boolean) => {
    updateFilters({
      myFieldOnly: checked,
      selectedFields: checked ? supervisorFields : [],
    })
  }

  const clearFilters = () => {
    updateFilters({
      myFieldOnly: false,
      selectedFields: [],
      urgentOnly: false,
    })
  }

  const activeFilterCount =
    (filters.myFieldOnly ? 1 : 0) +
    (filters.selectedFields.length > 0 && !filters.myFieldOnly ? 1 : 0) +
    (filters.urgentOnly ? 1 : 0)

  return (
    <div className="flex flex-wrap items-center gap-3">
      {/* My Field Only Toggle */}
      <div className="flex items-center gap-2 rounded-xl border border-[#E7DED0] bg-[#F7F1E8] px-3 py-2">
        <Switch
          id="my-field-only"
          checked={filters.myFieldOnly}
          onCheckedChange={handleMyFieldToggle}
          className="data-[state=checked]:bg-[#1B6F6A]"
        />
        <Label htmlFor="my-field-only" className="text-sm cursor-pointer text-[#122022]">
          My Field Only
        </Label>
      </div>

      {/* Field Selector */}
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className="justify-between min-w-[200px] border-[#E7DED0] bg-white/80 text-[#122022] hover:bg-[#F7F1E8]"
          >
            <div className="flex items-center gap-2">
              <Filter className="h-4 w-4" />
              <span>
                {filters.selectedFields.length > 0
                  ? `${filters.selectedFields.length} field(s) selected`
                  : "All Fields"}
              </span>
            </div>
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-[300px] p-0" align="start">
          <Command>
            <CommandInput placeholder="Search fields..." />
            <CommandList>
              <CommandEmpty>No field found.</CommandEmpty>
              <CommandGroup>
                {EXPERTISE_AREAS.map((area) => (
                  <CommandItem
                    key={area.value}
                    value={area.value}
                    onSelect={() => handleFieldSelect(area.value)}
                  >
                    <Check
                      className={cn(
                        "mr-2 h-4 w-4",
                        filters.selectedFields.includes(area.value)
                          ? "opacity-100"
                          : "opacity-0"
                      )}
                    />
                    {area.label}
                  </CommandItem>
                ))}
              </CommandGroup>
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>

      {/* Urgent Only Toggle */}
        <Button
          variant={filters.urgentOnly ? "default" : "outline"}
          size="sm"
          onClick={() => updateFilters({ urgentOnly: !filters.urgentOnly })}
          className={cn(
            filters.urgentOnly && "bg-[#E48B6A] hover:bg-[#D97757] text-white"
          )}
        >
          <span
            className={cn(
              "h-2 w-2 rounded-full mr-2",
              filters.urgentOnly ? "bg-white" : "bg-[#E48B6A]"
            )}
          />
          Urgent
        </Button>

      {/* Active Filters Display */}
      {activeFilterCount > 0 && (
        <div className="flex items-center gap-2">
          <Badge className="gap-1 border border-[#9FD6CC]/60 bg-[#E7F2EF] text-[#0F4C4A]">
            {activeFilterCount} filter{activeFilterCount > 1 ? "s" : ""} active
            <button
              onClick={clearFilters}
              className="ml-1 hover:bg-[#E7F2EF] rounded-full p-0.5"
            >
              <X className="h-3 w-3" />
            </button>
          </Badge>
        </div>
      )}
    </div>
  )
}
