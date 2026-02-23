'use client'

import { memo, useMemo } from 'react'
import { motion, AnimatePresence, type Variants } from 'framer-motion'
import { X } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

/**
 * Animation variants for filter chips
 */
const filterChipVariants: Variants = {
  hidden: {
    opacity: 0,
    scale: 0.8,
    y: 10,
  },
  visible: {
    opacity: 1,
    scale: 1,
    y: 0,
    transition: {
      type: 'spring' as const,
      stiffness: 300,
      damping: 24,
    },
  },
  exit: {
    opacity: 0,
    scale: 0.9,
    transition: {
      duration: 0.2,
    },
  },
}

const clearButtonVariants: Variants = {
  hidden: {
    opacity: 0,
    y: -10,
    height: 0,
  },
  visible: {
    opacity: 1,
    y: 0,
    height: 'auto',
    transition: {
      type: 'spring' as const,
      stiffness: 260,
      damping: 20,
    },
  },
  exit: {
    opacity: 0,
    y: -10,
    height: 0,
    transition: {
      duration: 0.2,
    },
  },
}

const badgePulseVariants: Variants = {
  initial: { scale: 1 },
  pulse: {
    scale: [1, 1.1, 1],
    transition: {
      duration: 0.5,
      ease: 'easeInOut' as const,
    },
  },
}

/**
 * Active filter state
 */
export interface ActiveFilters {
  /** Status filter: all, active, review, completed, revision */
  status?: string
  /** Urgency filter: all, urgent, soon, on-track */
  urgency?: string
  /** Subject filter: dynamic based on available subjects */
  subject?: string
}

/**
 * Filter counts for displaying badge numbers
 */
export interface FilterCounts {
  /** Count map: key is filter value, value is count */
  [key: string]: number
}

interface QuickFiltersProps {
  /** Currently active filters */
  activeFilters: ActiveFilters
  /** Callback when filters change */
  onFilterChange: (filters: ActiveFilters) => void
  /** Counts for each filter option */
  counts: FilterCounts
  /** Available subjects for subject filter */
  subjects?: string[]
}

/** Status filter options */
const statusFilters = [
  { value: 'all', label: 'All Status' },
  { value: 'active', label: 'Active' },
  { value: 'review', label: 'Under Review' },
  { value: 'completed', label: 'Completed' },
  { value: 'revision', label: 'Needs Revision' },
]

/** Urgency filter options */
const urgencyFilters = [
  { value: 'all', label: 'All Urgency' },
  { value: 'urgent', label: 'Urgent' },
  { value: 'soon', label: 'Due Soon' },
  { value: 'on-track', label: 'On Track' },
]

/**
 * QuickFilters component
 * Horizontal scrollable filter chips with active states and count badges
 * Memoized for performance optimization
 *
 * @example
 * ```tsx
 * <QuickFilters
 *   activeFilters={{ status: 'active', urgency: 'urgent' }}
 *   onFilterChange={(filters) => setFilters(filters)}
 *   counts={{ active: 5, urgent: 3, 'Math': 12 }}
 *   subjects={['Math', 'Physics', 'Chemistry']}
 * />
 * ```
 */
export const QuickFilters = memo(function QuickFilters({
  activeFilters,
  onFilterChange,
  counts,
  subjects = [],
}: QuickFiltersProps) {
  /** Check if any filters are active (not 'all') - memoized */
  const hasActiveFilters = useMemo(
    () =>
      (activeFilters.status && activeFilters.status !== 'all') ||
      (activeFilters.urgency && activeFilters.urgency !== 'all') ||
      Boolean(activeFilters.subject),
    [activeFilters]
  )

  /**
   * Handle filter click
   * @param category - Filter category (status, urgency, subject)
   * @param value - Filter value
   */
  const handleFilterClick = (category: keyof ActiveFilters, value: string) => {
    const newFilters = { ...activeFilters }

    // If clicking the same filter, reset to 'all'
    if (newFilters[category] === value) {
      if (category === 'subject') {
        delete newFilters.subject
      } else {
        newFilters[category] = 'all'
      }
    } else {
      newFilters[category] = value
    }

    onFilterChange(newFilters)
  }

  /**
   * Clear all filters
   */
  const handleClearAll = () => {
    onFilterChange({
      status: 'all',
      urgency: 'all',
    })
  }

  /**
   * Get count for a filter option
   * @param value - Filter value
   * @returns Count number or undefined
   */
  const getCount = (value: string): number | undefined => {
    return counts[value]
  }

  /**
   * Check if a filter is active
   * @param category - Filter category
   * @param value - Filter value
   * @returns True if active
   */
  const isActive = (category: keyof ActiveFilters, value: string): boolean => {
    return activeFilters[category] === value
  }

  return (
    <div className="space-y-3">
      {/* Status Filters */}
      <div className="space-y-2">
        <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
          Status
        </p>
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-thin">
          <AnimatePresence mode="popLayout">
            {statusFilters.map((filter) => {
              const active = isActive('status', filter.value)
              const count = getCount(filter.value)

              return (
                <motion.div
                  key={filter.value}
                  variants={filterChipVariants}
                  initial="hidden"
                  animate="visible"
                  exit="exit"
                  layout
                  transition={{ layout: { type: 'spring' as const, stiffness: 300, damping: 30 } }}
                >
                  <motion.button
                    onClick={() => handleFilterClick('status', filter.value)}
                    whileHover={{ scale: 1.05, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    transition={{ type: 'spring' as const, stiffness: 400, damping: 17 }}
                    className={cn(
                      'group relative inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-medium will-change-transform',
                      active
                        ? 'bg-gradient-to-r from-teal-500 to-emerald-600 text-white shadow-md shadow-teal-500/25'
                        : 'border border-border/70 bg-background/80 text-foreground hover:bg-accent hover:border-accent-foreground/20'
                    )}
                  >
                    {/* Active state glow effect */}
                    {active && (
                      <motion.div
                        layoutId="activeFilterGlow"
                        className="absolute inset-0 rounded-full bg-gradient-to-r from-teal-400 to-emerald-500 opacity-50 blur-md"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 0.5 }}
                        exit={{ opacity: 0 }}
                      />
                    )}

                    <span className="relative whitespace-nowrap">{filter.label}</span>
                    {count !== undefined && count > 0 && (
                      <motion.div
                        key={count}
                        variants={badgePulseVariants}
                        initial="initial"
                        animate="pulse"
                      >
                        <Badge
                          variant={active ? 'secondary' : 'outline'}
                          className={cn(
                            'rounded-full px-2 py-0.5 text-xs font-semibold',
                            active
                              ? 'bg-white/20 text-white border-0'
                              : 'bg-muted/50'
                          )}
                        >
                          {count}
                        </Badge>
                      </motion.div>
                    )}
                  </motion.button>
                </motion.div>
              )
            })}
          </AnimatePresence>
        </div>
      </div>

      {/* Urgency Filters */}
      <div className="space-y-2">
        <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
          Urgency
        </p>
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-thin">
          <AnimatePresence mode="popLayout">
            {urgencyFilters.map((filter) => {
              const active = isActive('urgency', filter.value)
              const count = getCount(filter.value)

              return (
                <motion.div
                  key={filter.value}
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  transition={{ duration: 0.15 }}
                >
                  <button
                    onClick={() => handleFilterClick('urgency', filter.value)}
                    className={cn(
                      'group relative inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-medium transition-all duration-200',
                      'hover:scale-[1.02] active:scale-[0.98]',
                      active
                        ? 'bg-gradient-to-r from-teal-500 to-emerald-600 text-white shadow-md shadow-teal-500/25'
                        : 'border border-border/70 bg-background/80 text-foreground hover:bg-accent hover:border-accent-foreground/20'
                    )}
                  >
                    <span className="whitespace-nowrap">{filter.label}</span>
                    {count !== undefined && count > 0 && (
                      <Badge
                        variant={active ? 'secondary' : 'outline'}
                        className={cn(
                          'rounded-full px-2 py-0.5 text-xs font-semibold transition-colors',
                          active
                            ? 'bg-white/20 text-white border-0'
                            : 'bg-muted/50'
                        )}
                      >
                        {count}
                      </Badge>
                    )}
                  </button>
                </motion.div>
              )
            })}
          </AnimatePresence>
        </div>
      </div>

      {/* Subject Filters (Dynamic) */}
      {subjects.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
            Subject
          </p>
          <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-thin">
            <AnimatePresence mode="popLayout">
              {subjects.map((subject) => {
                const active = isActive('subject', subject)
                const count = getCount(subject)

                return (
                  <motion.div
                    key={subject}
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.95 }}
                    transition={{ duration: 0.15 }}
                  >
                    <button
                      onClick={() => handleFilterClick('subject', subject)}
                      className={cn(
                        'group relative inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-medium transition-all duration-200',
                        'hover:scale-[1.02] active:scale-[0.98]',
                        active
                          ? 'bg-gradient-to-r from-teal-500 to-emerald-600 text-white shadow-md shadow-teal-500/25'
                          : 'border border-border/70 bg-background/80 text-foreground hover:bg-accent hover:border-accent-foreground/20'
                      )}
                    >
                      <span className="whitespace-nowrap">{subject}</span>
                      {count !== undefined && count > 0 && (
                        <Badge
                          variant={active ? 'secondary' : 'outline'}
                          className={cn(
                            'rounded-full px-2 py-0.5 text-xs font-semibold transition-colors',
                            active
                              ? 'bg-white/20 text-white border-0'
                              : 'bg-muted/50'
                          )}
                        >
                          {count}
                        </Badge>
                      )}
                    </button>
                  </motion.div>
                )
              })}
            </AnimatePresence>
          </div>
        </div>
      )}

      {/* Animated Clear All Button */}
      <AnimatePresence mode="wait">
        {hasActiveFilters && (
          <motion.div
            variants={clearButtonVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
          >
            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              transition={{ type: 'spring' as const, stiffness: 400, damping: 17 }}
            >
              <Button
                variant="ghost"
                size="sm"
                onClick={handleClearAll}
                className="group gap-2 text-muted-foreground hover:text-foreground"
              >
                <motion.div
                  animate={{ rotate: [0, -90, 0] }}
                  transition={{ duration: 0.3 }}
                >
                  <X className="h-4 w-4" />
                </motion.div>
                Clear all filters
              </Button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
})
