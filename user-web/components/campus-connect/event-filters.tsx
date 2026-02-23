"use client";

/**
 * Event Filters Component
 *
 * Provides filtering options for events in Campus Connect:
 * - Event type selection (Academic, Social, Career, Sports, Cultural)
 * - Date range picker
 * - Location filter
 * - Free/Paid toggle
 */

import { useState, useCallback } from "react";
import { motion } from "framer-motion";
import {
  Calendar,
  MapPin,
  GraduationCap,
  Users,
  Briefcase,
  Trophy,
  Music,
  Sparkles,
  PartyPopper,
  Mic,
  Code,
  HeartHandshake,
  X,
  IndianRupee,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
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
 * Event filter state interface
 */
export interface EventFilters {
  eventType: string[];
  dateRange?: {
    from: Date | undefined;
    to: Date | undefined;
  };
  location?: string;
  isFree?: boolean;
}

/**
 * Default event filters
 */
export const defaultEventFilters: EventFilters = {
  eventType: [],
  dateRange: undefined,
  location: undefined,
  isFree: undefined,
};

/**
 * Event type options with icons
 */
const eventTypes = [
  { id: "academic", label: "Academic", icon: GraduationCap, color: "from-blue-400 to-cyan-500" },
  { id: "social", label: "Social", icon: Users, color: "from-pink-400 to-rose-500" },
  { id: "career", label: "Career", icon: Briefcase, color: "from-purple-400 to-violet-500" },
  { id: "sports", label: "Sports", icon: Trophy, color: "from-green-400 to-emerald-500" },
  { id: "cultural", label: "Cultural", icon: Music, color: "from-amber-400 to-orange-500" },
  { id: "workshop", label: "Workshop", icon: Code, color: "from-indigo-400 to-blue-500" },
  { id: "fest", label: "Fest", icon: PartyPopper, color: "from-red-400 to-pink-500" },
  { id: "seminar", label: "Seminar", icon: Mic, color: "from-teal-400 to-cyan-500" },
  { id: "networking", label: "Networking", icon: HeartHandshake, color: "from-violet-400 to-purple-500" },
];

/**
 * Date range presets
 */
const datePresets = [
  { id: "today", label: "Today" },
  { id: "tomorrow", label: "Tomorrow" },
  { id: "this-week", label: "This Week" },
  { id: "this-weekend", label: "This Weekend" },
  { id: "next-week", label: "Next Week" },
  { id: "this-month", label: "This Month" },
];

/**
 * Location options
 */
const locationOptions = [
  { value: "on-campus", label: "On Campus" },
  { value: "off-campus", label: "Off Campus" },
  { value: "online", label: "Online/Virtual" },
  { value: "hybrid", label: "Hybrid" },
];

interface EventFiltersProps {
  filters: EventFilters;
  onFiltersChange: (filters: EventFilters) => void;
  className?: string;
}

/**
 * Event Filters Component
 * Provides comprehensive filtering options for events
 */
export function EventFiltersPanel({
  filters,
  onFiltersChange,
  className,
}: EventFiltersProps) {
  const [selectedDatePreset, setSelectedDatePreset] = useState<string | null>(null);

  /**
   * Update a single filter field
   */
  const updateFilter = useCallback(
    <K extends keyof EventFilters>(key: K, value: EventFilters[K]) => {
      onFiltersChange({ ...filters, [key]: value });
    },
    [filters, onFiltersChange]
  );

  /**
   * Toggle event type selection
   */
  const toggleEventType = useCallback(
    (typeId: string) => {
      const current = filters.eventType;
      const updated = current.includes(typeId)
        ? current.filter((t) => t !== typeId)
        : [...current, typeId];
      updateFilter("eventType", updated);
    },
    [filters.eventType, updateFilter]
  );

  /**
   * Handle date preset selection
   */
  const handleDatePreset = useCallback(
    (presetId: string) => {
      const now = new Date();
      let from: Date | undefined;
      let to: Date | undefined;

      switch (presetId) {
        case "today":
          from = new Date(now.setHours(0, 0, 0, 0));
          to = new Date(now.setHours(23, 59, 59, 999));
          break;
        case "tomorrow":
          const tomorrow = new Date(now);
          tomorrow.setDate(tomorrow.getDate() + 1);
          from = new Date(tomorrow.setHours(0, 0, 0, 0));
          to = new Date(tomorrow.setHours(23, 59, 59, 999));
          break;
        case "this-week":
          const dayOfWeek = now.getDay();
          from = new Date(now);
          from.setDate(now.getDate() - dayOfWeek);
          from.setHours(0, 0, 0, 0);
          to = new Date(from);
          to.setDate(from.getDate() + 6);
          to.setHours(23, 59, 59, 999);
          break;
        case "this-weekend":
          const daysUntilSaturday = (6 - now.getDay() + 7) % 7;
          from = new Date(now);
          from.setDate(now.getDate() + daysUntilSaturday);
          from.setHours(0, 0, 0, 0);
          to = new Date(from);
          to.setDate(from.getDate() + 1);
          to.setHours(23, 59, 59, 999);
          break;
        case "next-week":
          const nextWeekStart = new Date(now);
          nextWeekStart.setDate(now.getDate() + (7 - now.getDay()));
          nextWeekStart.setHours(0, 0, 0, 0);
          from = nextWeekStart;
          to = new Date(nextWeekStart);
          to.setDate(nextWeekStart.getDate() + 6);
          to.setHours(23, 59, 59, 999);
          break;
        case "this-month":
          from = new Date(now.getFullYear(), now.getMonth(), 1);
          to = new Date(now.getFullYear(), now.getMonth() + 1, 0);
          to.setHours(23, 59, 59, 999);
          break;
      }

      setSelectedDatePreset(presetId);
      updateFilter("dateRange", { from, to });
    },
    [updateFilter]
  );

  /**
   * Count active filters
   */
  const activeFilterCount =
    filters.eventType.length +
    (filters.dateRange?.from ? 1 : 0) +
    (filters.location ? 1 : 0) +
    (filters.isFree !== undefined ? 1 : 0);

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
            onClick={() => {
              onFiltersChange(defaultEventFilters);
              setSelectedDatePreset(null);
            }}
            className="text-xs text-muted-foreground hover:text-foreground"
          >
            Clear all
          </Button>
        </div>
      )}

      {/* Event Type Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Sparkles className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Event Type</Label>
        </div>
        <div className="flex flex-wrap gap-2">
          {eventTypes.map((type) => {
            const Icon = type.icon;
            const isSelected = filters.eventType.includes(type.id);
            return (
              <motion.button
                key={type.id}
                onClick={() => toggleEventType(type.id)}
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
                {type.label}
                {isSelected && <X className="h-3 w-3" />}
              </motion.button>
            );
          })}
        </div>
      </div>

      {/* Date Range Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Calendar className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">When</Label>
        </div>
        <div className="flex flex-wrap gap-2">
          {datePresets.map((preset) => (
            <motion.button
              key={preset.id}
              onClick={() => handleDatePreset(preset.id)}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className={cn(
                "px-3 py-2 rounded-xl text-sm font-medium transition-all border",
                selectedDatePreset === preset.id
                  ? "bg-foreground text-background border-foreground"
                  : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
              )}
            >
              {preset.label}
            </motion.button>
          ))}
        </div>
        {filters.dateRange?.from && (
          <p className="text-xs text-muted-foreground">
            {filters.dateRange.from.toLocaleDateString()} -{" "}
            {filters.dateRange.to?.toLocaleDateString() || "..."}
          </p>
        )}
      </div>

      {/* Location Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <MapPin className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Location</Label>
        </div>
        <Select
          value={filters.location || ""}
          onValueChange={(value) => updateFilter("location", value || undefined)}
        >
          <SelectTrigger className="h-10 rounded-xl">
            <SelectValue placeholder="Any location" />
          </SelectTrigger>
          <SelectContent>
            {locationOptions.map((opt) => (
              <SelectItem key={opt.value} value={opt.value}>
                {opt.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Free/Paid Toggle */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <IndianRupee className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Entry</Label>
        </div>
        <div className="flex gap-2">
          <motion.button
            onClick={() =>
              updateFilter("isFree", filters.isFree === true ? undefined : true)
            }
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className={cn(
              "flex-1 px-4 py-3 rounded-xl text-sm font-medium transition-all border",
              filters.isFree === true
                ? "bg-green-500 text-white border-green-500"
                : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
            )}
          >
            Free
          </motion.button>
          <motion.button
            onClick={() =>
              updateFilter("isFree", filters.isFree === false ? undefined : false)
            }
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className={cn(
              "flex-1 px-4 py-3 rounded-xl text-sm font-medium transition-all border",
              filters.isFree === false
                ? "bg-foreground text-background border-foreground"
                : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
            )}
          >
            Paid
          </motion.button>
        </div>
      </div>
    </div>
  );
}

export default EventFiltersPanel;
