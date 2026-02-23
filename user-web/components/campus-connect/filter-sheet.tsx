"use client";

/**
 * Filter Sheet Component
 *
 * Mobile-friendly sheet containing all Campus Connect filters:
 * - Tabbed interface for each category (Housing, Events, Resources)
 * - Apply and Reset buttons
 * - Active filter count badge
 * - Responsive design for mobile and desktop
 */

import { useState, useCallback, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Filter,
  X,
  Home,
  Calendar,
  BookOpen,
  Check,
  RotateCcw,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
  SheetFooter,
} from "@/components/ui/sheet";
import { cn } from "@/lib/utils";
import {
  HousingFiltersPanel,
  HousingFilters,
  defaultHousingFilters,
} from "./housing-filters";
import {
  EventFiltersPanel,
  EventFilters,
  defaultEventFilters,
} from "./event-filters";
import {
  ResourceFiltersPanel,
  ResourceFilters,
  defaultResourceFilters,
} from "./resource-filters";

/**
 * Complete filter state interface
 */
export interface CampusConnectFilters {
  category: "housing" | "events" | "resources" | "all";
  housing: HousingFilters;
  events: EventFilters;
  resources: ResourceFilters;
}

/**
 * Default filters
 */
export const defaultCampusConnectFilters: CampusConnectFilters = {
  category: "all",
  housing: defaultHousingFilters,
  events: defaultEventFilters,
  resources: defaultResourceFilters,
};

/**
 * Filter tabs configuration
 */
const filterTabs = [
  { id: "housing", label: "Housing", icon: Home },
  { id: "events", label: "Events", icon: Calendar },
  { id: "resources", label: "Resources", icon: BookOpen },
] as const;

type FilterTabId = (typeof filterTabs)[number]["id"];

interface FilterSheetProps {
  filters: CampusConnectFilters;
  onFiltersChange: (filters: CampusConnectFilters) => void;
  activeCategory?: "housing" | "events" | "resources" | "all";
  className?: string;
  triggerClassName?: string;
}

/**
 * Filter Sheet Component
 * Provides a mobile-friendly sheet with tabbed filter panels
 */
export function FilterSheet({
  filters,
  onFiltersChange,
  activeCategory = "all",
  className,
  triggerClassName,
}: FilterSheetProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [activeTab, setActiveTab] = useState<FilterTabId>(
    activeCategory !== "all" ? activeCategory : "housing"
  );

  // Local state for pending changes
  const [pendingFilters, setPendingFilters] = useState<CampusConnectFilters>(filters);

  /**
   * Calculate total active filter count
   */
  const activeFilterCount = useMemo(() => {
    let count = 0;

    // Housing filters
    const h = filters.housing;
    count += h.location ? 1 : 0;
    count += h.area ? 1 : 0;
    count += h.distanceFromCampus ? 1 : 0;
    count += h.priceRange[0] > 0 || h.priceRange[1] < 50000 ? 1 : 0;
    count += h.propertyType.length;
    count += h.amenities.length;

    // Event filters
    const e = filters.events;
    count += e.eventType.length;
    count += e.dateRange?.from ? 1 : 0;
    count += e.location ? 1 : 0;
    count += e.isFree !== undefined ? 1 : 0;

    // Resource filters
    const r = filters.resources;
    count += r.subject.length;
    count += r.resourceType.length;
    count += r.difficulty ? 1 : 0;
    count += r.minRating ? 1 : 0;

    return count;
  }, [filters]);

  /**
   * Calculate pending filter count
   */
  const pendingFilterCount = useMemo(() => {
    let count = 0;

    // Housing filters
    const h = pendingFilters.housing;
    count += h.location ? 1 : 0;
    count += h.area ? 1 : 0;
    count += h.distanceFromCampus ? 1 : 0;
    count += h.priceRange[0] > 0 || h.priceRange[1] < 50000 ? 1 : 0;
    count += h.propertyType.length;
    count += h.amenities.length;

    // Event filters
    const e = pendingFilters.events;
    count += e.eventType.length;
    count += e.dateRange?.from ? 1 : 0;
    count += e.location ? 1 : 0;
    count += e.isFree !== undefined ? 1 : 0;

    // Resource filters
    const r = pendingFilters.resources;
    count += r.subject.length;
    count += r.resourceType.length;
    count += r.difficulty ? 1 : 0;
    count += r.minRating ? 1 : 0;

    return count;
  }, [pendingFilters]);

  /**
   * Handle sheet open state change
   */
  const handleOpenChange = useCallback(
    (open: boolean) => {
      setIsOpen(open);
      if (open) {
        // Reset pending filters to current filters when opening
        setPendingFilters(filters);
        // Set active tab based on category
        if (activeCategory !== "all") {
          setActiveTab(activeCategory);
        }
      }
    },
    [filters, activeCategory]
  );

  /**
   * Update pending housing filters
   */
  const updateHousingFilters = useCallback((housing: HousingFilters) => {
    setPendingFilters((prev) => ({ ...prev, housing }));
  }, []);

  /**
   * Update pending event filters
   */
  const updateEventFilters = useCallback((events: EventFilters) => {
    setPendingFilters((prev) => ({ ...prev, events }));
  }, []);

  /**
   * Update pending resource filters
   */
  const updateResourceFilters = useCallback((resources: ResourceFilters) => {
    setPendingFilters((prev) => ({ ...prev, resources }));
  }, []);

  /**
   * Apply filters and close sheet
   */
  const handleApply = useCallback(() => {
    onFiltersChange(pendingFilters);
    setIsOpen(false);
  }, [pendingFilters, onFiltersChange]);

  /**
   * Reset all filters
   */
  const handleReset = useCallback(() => {
    setPendingFilters(defaultCampusConnectFilters);
  }, []);

  return (
    <Sheet open={isOpen} onOpenChange={handleOpenChange}>
      <SheetTrigger asChild>
        <button
          className={cn(
            "relative h-12 w-12 flex items-center justify-center rounded-2xl bg-white/80 dark:bg-white/5 backdrop-blur-sm border border-border/50 hover:bg-white dark:hover:bg-white/10 transition-all",
            triggerClassName
          )}
        >
          <Filter className="h-5 w-5 text-muted-foreground" />
          {activeFilterCount > 0 && (
            <Badge
              className="absolute -top-1 -right-1 h-5 w-5 p-0 flex items-center justify-center text-[10px] bg-blue-500 hover:bg-blue-500"
            >
              {activeFilterCount}
            </Badge>
          )}
        </button>
      </SheetTrigger>

      <SheetContent
        side="bottom"
        className={cn(
          "h-[85vh] max-h-[85vh] rounded-t-3xl flex flex-col",
          className
        )}
      >
        {/* Header */}
        <SheetHeader className="pb-4 border-b border-border/50">
          <div className="flex items-center justify-between">
            <SheetTitle className="flex items-center gap-2">
              <Filter className="h-5 w-5" />
              Filters
              {pendingFilterCount > 0 && (
                <Badge variant="secondary" className="ml-2">
                  {pendingFilterCount} active
                </Badge>
              )}
            </SheetTitle>
            <Button
              variant="ghost"
              size="sm"
              onClick={handleReset}
              className="text-xs text-muted-foreground hover:text-foreground"
            >
              <RotateCcw className="h-3 w-3 mr-1" />
              Reset
            </Button>
          </div>

          {/* Tabs */}
          <div className="flex gap-2 mt-4">
            {filterTabs.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              return (
                <motion.button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className={cn(
                    "flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-medium transition-all border",
                    isActive
                      ? "bg-foreground text-background border-foreground"
                      : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
                  )}
                >
                  <Icon className="h-4 w-4" />
                  {tab.label}
                </motion.button>
              );
            })}
          </div>
        </SheetHeader>

        {/* Filter Content */}
        <div className="flex-1 overflow-y-auto py-6">
          <AnimatePresence mode="wait">
            {activeTab === "housing" && (
              <motion.div
                key="housing"
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ duration: 0.2 }}
              >
                <HousingFiltersPanel
                  filters={pendingFilters.housing}
                  onFiltersChange={updateHousingFilters}
                />
              </motion.div>
            )}

            {activeTab === "events" && (
              <motion.div
                key="events"
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ duration: 0.2 }}
              >
                <EventFiltersPanel
                  filters={pendingFilters.events}
                  onFiltersChange={updateEventFilters}
                />
              </motion.div>
            )}

            {activeTab === "resources" && (
              <motion.div
                key="resources"
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ duration: 0.2 }}
              >
                <ResourceFiltersPanel
                  filters={pendingFilters.resources}
                  onFiltersChange={updateResourceFilters}
                />
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Footer */}
        <SheetFooter className="border-t border-border/50 pt-4 gap-3">
          <Button
            variant="outline"
            className="flex-1 h-12 rounded-xl"
            onClick={() => setIsOpen(false)}
          >
            Cancel
          </Button>
          <Button
            className="flex-1 h-12 rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700"
            onClick={handleApply}
          >
            <Check className="h-4 w-4 mr-2" />
            Apply Filters
            {pendingFilterCount > 0 && (
              <Badge
                variant="secondary"
                className="ml-2 bg-white/20 text-white hover:bg-white/20"
              >
                {pendingFilterCount}
              </Badge>
            )}
          </Button>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
}

/**
 * Inline Filter Bar Component
 * Shows active filters as chips with quick actions
 */
interface ActiveFiltersBarProps {
  filters: CampusConnectFilters;
  onFiltersChange: (filters: CampusConnectFilters) => void;
  className?: string;
}

export function ActiveFiltersBar({
  filters,
  onFiltersChange,
  className,
}: ActiveFiltersBarProps) {
  /**
   * Generate active filter chips
   */
  const activeChips = useMemo(() => {
    const chips: { id: string; label: string; category: string; onRemove: () => void }[] = [];

    // Housing filters
    if (filters.housing.location) {
      chips.push({
        id: "housing-location",
        label: filters.housing.location,
        category: "Housing",
        onRemove: () =>
          onFiltersChange({
            ...filters,
            housing: { ...filters.housing, location: undefined },
          }),
      });
    }
    if (filters.housing.propertyType.length > 0) {
      filters.housing.propertyType.forEach((type) => {
        chips.push({
          id: `housing-type-${type}`,
          label: type,
          category: "Housing",
          onRemove: () =>
            onFiltersChange({
              ...filters,
              housing: {
                ...filters.housing,
                propertyType: filters.housing.propertyType.filter((t) => t !== type),
              },
            }),
        });
      });
    }

    // Event filters
    if (filters.events.eventType.length > 0) {
      filters.events.eventType.forEach((type) => {
        chips.push({
          id: `event-type-${type}`,
          label: type,
          category: "Events",
          onRemove: () =>
            onFiltersChange({
              ...filters,
              events: {
                ...filters.events,
                eventType: filters.events.eventType.filter((t) => t !== type),
              },
            }),
        });
      });
    }
    if (filters.events.isFree !== undefined) {
      chips.push({
        id: "event-free",
        label: filters.events.isFree ? "Free" : "Paid",
        category: "Events",
        onRemove: () =>
          onFiltersChange({
            ...filters,
            events: { ...filters.events, isFree: undefined },
          }),
      });
    }

    // Resource filters
    if (filters.resources.subject.length > 0) {
      filters.resources.subject.forEach((subject) => {
        chips.push({
          id: `resource-subject-${subject}`,
          label: subject,
          category: "Resources",
          onRemove: () =>
            onFiltersChange({
              ...filters,
              resources: {
                ...filters.resources,
                subject: filters.resources.subject.filter((s) => s !== subject),
              },
            }),
        });
      });
    }
    if (filters.resources.difficulty) {
      chips.push({
        id: "resource-difficulty",
        label: filters.resources.difficulty,
        category: "Resources",
        onRemove: () =>
          onFiltersChange({
            ...filters,
            resources: { ...filters.resources, difficulty: undefined },
          }),
      });
    }

    return chips;
  }, [filters, onFiltersChange]);

  if (activeChips.length === 0) return null;

  return (
    <div className={cn("flex items-center gap-2 flex-wrap", className)}>
      <span className="text-xs text-muted-foreground">Active filters:</span>
      {activeChips.slice(0, 5).map((chip) => (
        <Badge
          key={chip.id}
          variant="secondary"
          className="gap-1 text-xs rounded-full px-3 py-1 capitalize"
        >
          {chip.label}
          <button onClick={chip.onRemove} className="ml-1 hover:text-foreground">
            <X className="h-3 w-3" />
          </button>
        </Badge>
      ))}
      {activeChips.length > 5 && (
        <Badge variant="secondary" className="text-xs rounded-full px-3 py-1">
          +{activeChips.length - 5} more
        </Badge>
      )}
    </div>
  );
}

export default FilterSheet;
