"use client";

import { SlidersHorizontal, RotateCcw } from "lucide-react";
import { motion } from "framer-motion";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
  SheetFooter,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Slider } from "@/components/ui/slider";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { subjectFilters } from "@/lib/data/connect";
import type { TutorFilters, ExpertiseLevel, AvailabilityStatus } from "@/types/connect";

interface FilterSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  filters: TutorFilters;
  onFiltersChange: (filters: TutorFilters) => void;
  onApply: () => void;
}

const expertiseLevels: { value: ExpertiseLevel; label: string }[] = [
  { value: "beginner", label: "Beginner" },
  { value: "intermediate", label: "Intermediate" },
  { value: "expert", label: "Expert" },
  { value: "master", label: "Master" },
];

const availabilityOptions: { value: AvailabilityStatus; label: string }[] = [
  { value: "available", label: "Available Now" },
  { value: "busy", label: "Busy" },
  { value: "offline", label: "Offline" },
];

const defaultFilters: TutorFilters = {
  subjects: [],
  minRating: 0,
  maxHourlyRate: 100,
  availability: [],
  expertise: [],
  languages: [],
};

/**
 * Sheet component for advanced filtering options
 */
export function FilterSheet({
  open,
  onOpenChange,
  filters,
  onFiltersChange,
  onApply,
}: FilterSheetProps) {
  const handleReset = () => {
    onFiltersChange(defaultFilters);
  };

  const toggleSubject = (subject: string) => {
    const newSubjects = filters.subjects.includes(subject)
      ? filters.subjects.filter((s) => s !== subject)
      : [...filters.subjects, subject];
    onFiltersChange({ ...filters, subjects: newSubjects });
  };

  const toggleExpertise = (level: ExpertiseLevel) => {
    const newExpertise = filters.expertise.includes(level)
      ? filters.expertise.filter((e) => e !== level)
      : [...filters.expertise, level];
    onFiltersChange({ ...filters, expertise: newExpertise });
  };

  const toggleAvailability = (status: AvailabilityStatus) => {
    const newAvailability = filters.availability.includes(status)
      ? filters.availability.filter((a) => a !== status)
      : [...filters.availability, status];
    onFiltersChange({ ...filters, availability: newAvailability });
  };

  const activeFilterCount =
    filters.subjects.length +
    filters.expertise.length +
    filters.availability.length +
    (filters.minRating > 0 ? 1 : 0) +
    (filters.maxHourlyRate < 100 ? 1 : 0);

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[80vh] rounded-t-xl flex flex-col">
        <SheetHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <SlidersHorizontal className="h-5 w-5" />
              <SheetTitle>Filters</SheetTitle>
              {activeFilterCount > 0 && (
                <Badge variant="secondary" className="ml-2">
                  {activeFilterCount}
                </Badge>
              )}
            </div>
            <Button variant="ghost" size="sm" onClick={handleReset}>
              <RotateCcw className="mr-2 h-4 w-4" />
              Reset
            </Button>
          </div>
          <SheetDescription>
            Refine your search to find the perfect tutor
          </SheetDescription>
        </SheetHeader>

        <div className="flex-1 overflow-y-auto px-4 space-y-6">
          {/* Subjects */}
          <div className="space-y-3">
            <Label className="text-base font-semibold">Subjects</Label>
            <div className="flex flex-wrap gap-2">
              {subjectFilters.slice(1).map((subject) => (
                <motion.button
                  key={subject}
                  type="button"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => toggleSubject(subject)}
                  className={`rounded-full px-3 py-1.5 text-sm transition-all ${
                    filters.subjects.includes(subject)
                      ? "bg-primary text-primary-foreground"
                      : "bg-muted text-muted-foreground hover:bg-muted/80"
                  }`}
                >
                  {subject}
                </motion.button>
              ))}
            </div>
          </div>

          <Separator />

          {/* Rating */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <Label className="text-base font-semibold">Minimum Rating</Label>
              <span className="text-sm text-muted-foreground">
                {filters.minRating > 0 ? `${filters.minRating}+ stars` : "Any"}
              </span>
            </div>
            <Slider
              value={[filters.minRating]}
              onValueChange={([value]) =>
                onFiltersChange({ ...filters, minRating: value })
              }
              max={5}
              step={0.5}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>Any</span>
              <span>5 stars</span>
            </div>
          </div>

          <Separator />

          {/* Hourly Rate */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <Label className="text-base font-semibold">Max Hourly Rate</Label>
              <span className="text-sm text-muted-foreground">
                ${filters.maxHourlyRate}
                {filters.maxHourlyRate >= 100 ? "+" : ""}/hr
              </span>
            </div>
            <Slider
              value={[filters.maxHourlyRate]}
              onValueChange={([value]) =>
                onFiltersChange({ ...filters, maxHourlyRate: value })
              }
              min={10}
              max={100}
              step={5}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>$10/hr</span>
              <span>$100+/hr</span>
            </div>
          </div>

          <Separator />

          {/* Expertise Level */}
          <div className="space-y-3">
            <Label className="text-base font-semibold">Expertise Level</Label>
            <div className="space-y-2">
              {expertiseLevels.map((level) => (
                <div key={level.value} className="flex items-center space-x-2">
                  <Checkbox
                    id={level.value}
                    checked={filters.expertise.includes(level.value)}
                    onCheckedChange={() => toggleExpertise(level.value)}
                  />
                  <label
                    htmlFor={level.value}
                    className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
                  >
                    {level.label}
                  </label>
                </div>
              ))}
            </div>
          </div>

          <Separator />

          {/* Availability */}
          <div className="space-y-3">
            <Label className="text-base font-semibold">Availability</Label>
            <div className="space-y-2">
              {availabilityOptions.map((option) => (
                <div key={option.value} className="flex items-center space-x-2">
                  <Checkbox
                    id={option.value}
                    checked={filters.availability.includes(option.value)}
                    onCheckedChange={() => toggleAvailability(option.value)}
                  />
                  <label
                    htmlFor={option.value}
                    className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
                  >
                    {option.label}
                  </label>
                </div>
              ))}
            </div>
          </div>
        </div>

        <SheetFooter>
          <motion.div whileTap={{ scale: 0.98 }} className="w-full">
            <Button className="w-full" size="lg" onClick={onApply}>
              Apply Filters
              {activeFilterCount > 0 && ` (${activeFilterCount})`}
            </Button>
          </motion.div>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
}
