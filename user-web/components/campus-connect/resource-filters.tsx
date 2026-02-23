"use client";

/**
 * Resource Filters Component
 *
 * Provides filtering options for resources/study materials in Campus Connect:
 * - Subject dropdown (Math, Science, Language, etc.)
 * - Resource type (Notes, Books, Tools, Software)
 * - Difficulty level (Beginner, Intermediate, Advanced)
 * - Rating filter
 */

import { useState, useCallback } from "react";
import { motion } from "framer-motion";
import {
  BookOpen,
  FileText,
  Laptop,
  Package,
  Star,
  GraduationCap,
  Calculator,
  Atom,
  Globe,
  Code,
  Palette,
  Music,
  Stethoscope,
  Scale,
  TrendingUp,
  History,
  X,
  Sparkles,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";

/**
 * Resource filter state interface
 */
export interface ResourceFilters {
  subject: string[];
  resourceType: string[];
  difficulty?: string;
  minRating?: number;
}

/**
 * Default resource filters
 */
export const defaultResourceFilters: ResourceFilters = {
  subject: [],
  resourceType: [],
  difficulty: undefined,
  minRating: undefined,
};

/**
 * Subject options with icons
 */
const subjects = [
  { id: "mathematics", label: "Mathematics", icon: Calculator },
  { id: "physics", label: "Physics", icon: Atom },
  { id: "chemistry", label: "Chemistry", icon: Atom },
  { id: "biology", label: "Biology", icon: Stethoscope },
  { id: "computer-science", label: "Computer Science", icon: Code },
  { id: "english", label: "English", icon: Globe },
  { id: "economics", label: "Economics", icon: TrendingUp },
  { id: "history", label: "History", icon: History },
  { id: "law", label: "Law", icon: Scale },
  { id: "arts", label: "Arts & Design", icon: Palette },
  { id: "music", label: "Music", icon: Music },
  { id: "engineering", label: "Engineering", icon: Code },
];

/**
 * Resource type options
 */
const resourceTypes = [
  { id: "notes", label: "Notes", icon: FileText, description: "Class notes & summaries" },
  { id: "books", label: "Books", icon: BookOpen, description: "Textbooks & references" },
  { id: "tools", label: "Tools", icon: Package, description: "Study tools & utilities" },
  { id: "software", label: "Software", icon: Laptop, description: "Apps & programs" },
  { id: "videos", label: "Videos", icon: Laptop, description: "Video tutorials" },
  { id: "papers", label: "Papers", icon: FileText, description: "Research papers" },
  { id: "projects", label: "Projects", icon: Package, description: "Sample projects" },
];

/**
 * Difficulty levels
 */
const difficultyLevels = [
  { id: "beginner", label: "Beginner", color: "bg-green-500" },
  { id: "intermediate", label: "Intermediate", color: "bg-yellow-500" },
  { id: "advanced", label: "Advanced", color: "bg-red-500" },
];

/**
 * Rating options
 */
const ratingOptions = [
  { value: 4, label: "4+ Stars" },
  { value: 3, label: "3+ Stars" },
  { value: 2, label: "2+ Stars" },
];

interface ResourceFiltersProps {
  filters: ResourceFilters;
  onFiltersChange: (filters: ResourceFilters) => void;
  className?: string;
}

/**
 * Resource Filters Component
 * Provides comprehensive filtering options for study resources
 */
export function ResourceFiltersPanel({
  filters,
  onFiltersChange,
  className,
}: ResourceFiltersProps) {
  /**
   * Update a single filter field
   */
  const updateFilter = useCallback(
    <K extends keyof ResourceFilters>(key: K, value: ResourceFilters[K]) => {
      onFiltersChange({ ...filters, [key]: value });
    },
    [filters, onFiltersChange]
  );

  /**
   * Toggle subject selection
   */
  const toggleSubject = useCallback(
    (subjectId: string) => {
      const current = filters.subject;
      const updated = current.includes(subjectId)
        ? current.filter((s) => s !== subjectId)
        : [...current, subjectId];
      updateFilter("subject", updated);
    },
    [filters.subject, updateFilter]
  );

  /**
   * Toggle resource type selection
   */
  const toggleResourceType = useCallback(
    (typeId: string) => {
      const current = filters.resourceType;
      const updated = current.includes(typeId)
        ? current.filter((t) => t !== typeId)
        : [...current, typeId];
      updateFilter("resourceType", updated);
    },
    [filters.resourceType, updateFilter]
  );

  /**
   * Count active filters
   */
  const activeFilterCount =
    filters.subject.length +
    filters.resourceType.length +
    (filters.difficulty ? 1 : 0) +
    (filters.minRating ? 1 : 0);

  return (
    <div className={cn("space-y-6", className)}>
      {/* Active Filters Count */}
      {activeFilterCount > 0 && (
        <div className="flex items-center justify-between">
          <Badge variant="secondary" className="gap-1">
            {activeFilterCount} filter{activeFilterCount > 1 ? "s" : ""} active
          </Badge>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onFiltersChange(defaultResourceFilters)}
            className="text-xs text-muted-foreground hover:text-foreground"
          >
            Clear all
          </Button>
        </div>
      )}

      {/* Subject Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <GraduationCap className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Subject</Label>
        </div>
        <div className="flex flex-wrap gap-2">
          {subjects.map((subject) => {
            const Icon = subject.icon;
            const isSelected = filters.subject.includes(subject.id);
            return (
              <motion.button
                key={subject.id}
                onClick={() => toggleSubject(subject.id)}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className={cn(
                  "flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-medium transition-all border",
                  isSelected
                    ? "bg-foreground text-background border-foreground"
                    : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
                )}
              >
                <Icon className="h-4 w-4" />
                {subject.label}
                {isSelected && <X className="h-3 w-3" />}
              </motion.button>
            );
          })}
        </div>
      </div>

      {/* Resource Type Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Package className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Resource Type</Label>
        </div>
        <div className="grid grid-cols-2 gap-2">
          {resourceTypes.map((type) => {
            const Icon = type.icon;
            const isSelected = filters.resourceType.includes(type.id);
            return (
              <motion.button
                key={type.id}
                onClick={() => toggleResourceType(type.id)}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className={cn(
                  "flex flex-col items-start gap-1 p-3 rounded-xl text-left transition-all border",
                  isSelected
                    ? "bg-foreground text-background border-foreground"
                    : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
                )}
              >
                <div className="flex items-center gap-2">
                  <Icon className="h-4 w-4" />
                  <span className="text-sm font-medium">{type.label}</span>
                </div>
                <span
                  className={cn(
                    "text-xs",
                    isSelected ? "text-background/70" : "text-muted-foreground"
                  )}
                >
                  {type.description}
                </span>
              </motion.button>
            );
          })}
        </div>
      </div>

      {/* Difficulty Level Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Sparkles className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Difficulty Level</Label>
        </div>
        <div className="flex gap-2">
          {difficultyLevels.map((level) => (
            <motion.button
              key={level.id}
              onClick={() =>
                updateFilter(
                  "difficulty",
                  filters.difficulty === level.id ? undefined : level.id
                )
              }
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className={cn(
                "flex-1 flex items-center justify-center gap-2 px-3 py-3 rounded-xl text-sm font-medium transition-all border",
                filters.difficulty === level.id
                  ? "bg-foreground text-background border-foreground"
                  : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
              )}
            >
              <span
                className={cn(
                  "h-2 w-2 rounded-full",
                  level.color,
                  filters.difficulty === level.id && "bg-background"
                )}
              />
              {level.label}
            </motion.button>
          ))}
        </div>
      </div>

      {/* Rating Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Star className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Minimum Rating</Label>
        </div>
        <div className="flex gap-2">
          {ratingOptions.map((option) => (
            <motion.button
              key={option.value}
              onClick={() =>
                updateFilter(
                  "minRating",
                  filters.minRating === option.value ? undefined : option.value
                )
              }
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className={cn(
                "flex-1 flex items-center justify-center gap-1 px-3 py-3 rounded-xl text-sm font-medium transition-all border",
                filters.minRating === option.value
                  ? "bg-foreground text-background border-foreground"
                  : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
              )}
            >
              <Star
                className={cn(
                  "h-4 w-4",
                  filters.minRating === option.value
                    ? "fill-background text-background"
                    : "fill-yellow-400 text-yellow-400"
                )}
              />
              {option.label}
            </motion.button>
          ))}
        </div>
      </div>
    </div>
  );
}

export default ResourceFiltersPanel;
