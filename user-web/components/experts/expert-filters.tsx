"use client";

import { useState } from "react";
import { Search, Filter, X, SlidersHorizontal } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
  SheetFooter,
} from "@/components/ui/sheet";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { Slider } from "@/components/ui/slider";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import type { ExpertFilters, ExpertSpecialization } from "@/types/expert";

interface ExpertFiltersProps {
  filters: ExpertFilters;
  onFiltersChange: (filters: ExpertFilters) => void;
  onSearch: (query: string) => void;
  searchQuery: string;
  className?: string;
}

/**
 * Specialization options
 */
const SPECIALIZATION_OPTIONS: { value: ExpertSpecialization; label: string }[] = [
  { value: "academic_writing", label: "Academic Writing" },
  { value: "research_methodology", label: "Research Methodology" },
  { value: "data_analysis", label: "Data Analysis" },
  { value: "programming", label: "Programming" },
  { value: "mathematics", label: "Mathematics" },
  { value: "science", label: "Science" },
  { value: "business", label: "Business" },
  { value: "engineering", label: "Engineering" },
  { value: "law", label: "Law" },
  { value: "medicine", label: "Medicine" },
  { value: "arts", label: "Arts" },
];

/**
 * Sort options
 */
const SORT_OPTIONS = [
  { value: "rating", label: "Highest Rated" },
  { value: "price_low", label: "Price: Low to High" },
  { value: "price_high", label: "Price: High to Low" },
  { value: "sessions", label: "Most Sessions" },
  { value: "newest", label: "Newest" },
] as const;

/**
 * Default filter values
 */
const DEFAULT_FILTERS: ExpertFilters = {
  specializations: [],
  minRating: 0,
  maxPrice: 5000,
  availability: [],
  languages: [],
  sortBy: "rating",
};

/**
 * Expert filters component with search, filter sheet, and sort
 */
export function ExpertFiltersComponent({
  filters,
  onFiltersChange,
  onSearch,
  searchQuery,
  className,
}: ExpertFiltersProps) {
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [localFilters, setLocalFilters] = useState<ExpertFilters>(filters);

  /**
   * Check if any filters are active
   */
  const hasActiveFilters = () => {
    return (
      filters.specializations.length > 0 ||
      filters.minRating > 0 ||
      filters.maxPrice < 5000 ||
      filters.availability.length > 0
    );
  };

  /**
   * Get active filter count
   */
  const getActiveFilterCount = () => {
    let count = 0;
    if (filters.specializations.length > 0) count++;
    if (filters.minRating > 0) count++;
    if (filters.maxPrice < 5000) count++;
    if (filters.availability.length > 0) count++;
    return count;
  };

  /**
   * Apply filters
   */
  const handleApplyFilters = () => {
    onFiltersChange(localFilters);
    setIsFilterOpen(false);
  };

  /**
   * Reset filters
   */
  const handleResetFilters = () => {
    setLocalFilters(DEFAULT_FILTERS);
    onFiltersChange(DEFAULT_FILTERS);
    setIsFilterOpen(false);
  };

  /**
   * Toggle specialization filter
   */
  const toggleSpecialization = (spec: ExpertSpecialization) => {
    setLocalFilters((prev) => ({
      ...prev,
      specializations: prev.specializations.includes(spec)
        ? prev.specializations.filter((s) => s !== spec)
        : [...prev.specializations, spec],
    }));
  };

  return (
    <div className={cn("space-y-3", className)}>
      {/* Search and Filter Row */}
      <div className="flex items-center gap-2">
        {/* Search Input */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            type="search"
            placeholder="Search experts by name..."
            value={searchQuery}
            onChange={(e) => onSearch(e.target.value)}
            className="pl-9"
          />
        </div>

        {/* Filter Sheet Trigger */}
        <Sheet open={isFilterOpen} onOpenChange={setIsFilterOpen}>
          <SheetTrigger asChild>
            <Button variant="outline" className="shrink-0 relative">
              <SlidersHorizontal className="h-4 w-4 mr-2" />
              Filters
              {hasActiveFilters() && (
                <Badge
                  variant="default"
                  className="absolute -top-2 -right-2 h-5 w-5 p-0 flex items-center justify-center text-xs"
                >
                  {getActiveFilterCount()}
                </Badge>
              )}
            </Button>
          </SheetTrigger>
          <SheetContent side="bottom" className="h-auto max-h-[85vh] rounded-t-xl overflow-y-auto">
            <SheetHeader>
              <SheetTitle>Filter Experts</SheetTitle>
              <SheetDescription>
                Narrow down experts based on your preferences
              </SheetDescription>
            </SheetHeader>

            <div className="py-6 space-y-6">
              {/* Specializations */}
              <div className="space-y-3">
                <Label>Specializations</Label>
                <div className="grid grid-cols-2 gap-2">
                  {SPECIALIZATION_OPTIONS.map((spec) => (
                    <div
                      key={spec.value}
                      className="flex items-center space-x-2"
                    >
                      <Checkbox
                        id={`spec-${spec.value}`}
                        checked={localFilters.specializations.includes(spec.value)}
                        onCheckedChange={() => toggleSpecialization(spec.value)}
                      />
                      <Label
                        htmlFor={`spec-${spec.value}`}
                        className="text-sm font-normal cursor-pointer"
                      >
                        {spec.label}
                      </Label>
                    </div>
                  ))}
                </div>
              </div>

              {/* Minimum Rating */}
              <div className="space-y-3">
                <Label>Minimum Rating: {localFilters.minRating} stars</Label>
                <Slider
                  value={[localFilters.minRating]}
                  onValueChange={([value]) =>
                    setLocalFilters((prev) => ({ ...prev, minRating: value }))
                  }
                  min={0}
                  max={5}
                  step={0.5}
                  className="w-full"
                />
              </div>

              {/* Maximum Price */}
              <div className="space-y-3">
                <Label>
                  Maximum Price: {formatINR(localFilters.maxPrice)}/session
                </Label>
                <Slider
                  value={[localFilters.maxPrice]}
                  onValueChange={([value]) =>
                    setLocalFilters((prev) => ({ ...prev, maxPrice: value }))
                  }
                  min={500}
                  max={5000}
                  step={100}
                  className="w-full"
                />
              </div>

              {/* Availability */}
              <div className="space-y-3">
                <Label>Availability</Label>
                <div className="flex flex-wrap gap-2">
                  {(["available", "busy"] as const).map((status) => (
                    <Badge
                      key={status}
                      variant={
                        localFilters.availability.includes(status)
                          ? "default"
                          : "outline"
                      }
                      className="cursor-pointer capitalize"
                      onClick={() =>
                        setLocalFilters((prev) => ({
                          ...prev,
                          availability: prev.availability.includes(status)
                            ? prev.availability.filter((s) => s !== status)
                            : [...prev.availability, status],
                        }))
                      }
                    >
                      {status}
                    </Badge>
                  ))}
                </div>
              </div>
            </div>

            <SheetFooter className="flex-row gap-2">
              <Button
                variant="outline"
                onClick={handleResetFilters}
                className="flex-1"
              >
                Reset
              </Button>
              <Button onClick={handleApplyFilters} className="flex-1">
                Apply Filters
              </Button>
            </SheetFooter>
          </SheetContent>
        </Sheet>

        {/* Sort Select */}
        <Select
          value={filters.sortBy}
          onValueChange={(value: ExpertFilters["sortBy"]) =>
            onFiltersChange({ ...filters, sortBy: value })
          }
        >
          <SelectTrigger className="w-[160px] shrink-0">
            <SelectValue placeholder="Sort by" />
          </SelectTrigger>
          <SelectContent>
            {SORT_OPTIONS.map((option) => (
              <SelectItem key={option.value} value={option.value}>
                {option.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Active Filter Pills */}
      {hasActiveFilters() && (
        <div className="flex flex-wrap gap-2">
          {filters.specializations.map((spec) => (
            <Badge
              key={spec}
              variant="secondary"
              className="gap-1 cursor-pointer"
              onClick={() =>
                onFiltersChange({
                  ...filters,
                  specializations: filters.specializations.filter((s) => s !== spec),
                })
              }
            >
              {SPECIALIZATION_OPTIONS.find((s) => s.value === spec)?.label}
              <X className="h-3 w-3" />
            </Badge>
          ))}
          {filters.minRating > 0 && (
            <Badge
              variant="secondary"
              className="gap-1 cursor-pointer"
              onClick={() => onFiltersChange({ ...filters, minRating: 0 })}
            >
              {filters.minRating}+ stars
              <X className="h-3 w-3" />
            </Badge>
          )}
          {filters.maxPrice < 5000 && (
            <Badge
              variant="secondary"
              className="gap-1 cursor-pointer"
              onClick={() => onFiltersChange({ ...filters, maxPrice: 5000 })}
            >
              Under {formatINR(filters.maxPrice)}
              <X className="h-3 w-3" />
            </Badge>
          )}
          <Button
            variant="ghost"
            size="sm"
            className="h-6 px-2 text-xs"
            onClick={handleResetFilters}
          >
            Clear all
          </Button>
        </div>
      )}
    </div>
  );
}
