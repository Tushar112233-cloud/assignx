"use client"

import { useState } from "react"
import { motion, AnimatePresence, useReducedMotion } from "framer-motion"
import { Filter, X, Search, SlidersHorizontal } from "lucide-react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { FilterBarSkeleton } from "@/components/ui/filter-skeleton"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Slider } from "@/components/ui/slider"
import type { ListingFilters, ListingType, MarketplaceCategory } from "@/services/marketplace.service"

/**
 * Props for FilterBar component
 */
interface FilterBarProps {
  filters: ListingFilters
  categories: MarketplaceCategory[]
  onFiltersChange: (filters: ListingFilters) => void
  className?: string
  isLoading?: boolean
}

/**
 * Listing type options (matches database enum)
 */
const listingTypes: { value: ListingType; label: string }[] = [
  { value: "sell", label: "For Sale" },
  { value: "housing", label: "Housing" },
  { value: "opportunity", label: "Opportunities" },
  { value: "community_post", label: "Community" },
]

/**
 * FilterBar component for marketplace filtering
 * Includes category chips, search, and advanced filters
 * Now with smooth animations and loading skeleton
 */
export function FilterBar({
  filters,
  categories,
  onFiltersChange,
  className,
  isLoading,
}: FilterBarProps) {
  const [searchTerm, setSearchTerm] = useState(filters.searchTerm || "")
  const [priceRange, setPriceRange] = useState<[number, number]>([
    filters.minPrice || 0,
    filters.maxPrice || 10000,
  ])
  const prefersReducedMotion = useReducedMotion()

  // Show skeleton during loading
  if (isLoading) {
    return <FilterBarSkeleton tabCount={5} className={className} />
  }

  const handleTypeChange = (type: ListingType | "all") => {
    onFiltersChange({
      ...filters,
      type: type === "all" ? undefined : type,
    })
  }

  const handleCategoryChange = (categoryId: string | "all") => {
    onFiltersChange({
      ...filters,
      categoryId: categoryId === "all" ? undefined : categoryId,
    })
  }

  const handleSearch = () => {
    onFiltersChange({
      ...filters,
      searchTerm: searchTerm || undefined,
    })
  }

  const handlePriceChange = () => {
    onFiltersChange({
      ...filters,
      minPrice: priceRange[0] || undefined,
      maxPrice: priceRange[1] || undefined,
    })
  }

  const clearFilters = () => {
    setSearchTerm("")
    setPriceRange([0, 10000])
    onFiltersChange({})
  }

  const hasActiveFilters =
    filters.type ||
    filters.categoryId ||
    filters.searchTerm ||
    filters.minPrice ||
    filters.maxPrice

  return (
    <div className={cn("space-y-4", className)}>
      {/* Search Bar */}
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search listings..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSearch()}
            className="pl-10"
          />
        </div>
        <Button onClick={handleSearch} variant="secondary">
          Search
        </Button>

        {/* Advanced Filters Sheet */}
        <Sheet>
          <SheetTrigger asChild>
            <Button variant="outline" size="icon">
              <SlidersHorizontal className="h-4 w-4" />
            </Button>
          </SheetTrigger>
          <SheetContent side="bottom" className="h-auto max-h-[80vh] rounded-t-xl">
            <SheetHeader>
              <SheetTitle>Filters</SheetTitle>
            </SheetHeader>

            <div className="mt-6 space-y-6">
              {/* Type Filter */}
              <div className="space-y-2">
                <label className="text-sm font-medium">Listing Type</label>
                <Select
                  value={filters.type || "all"}
                  onValueChange={(v) => handleTypeChange(v as ListingType | "all")}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="All types" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All types</SelectItem>
                    {listingTypes.map((type) => (
                      <SelectItem key={type.value} value={type.value}>
                        {type.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Category Filter */}
              <div className="space-y-2">
                <label className="text-sm font-medium">Category</label>
                <Select
                  value={filters.categoryId || "all"}
                  onValueChange={handleCategoryChange}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="All categories" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All categories</SelectItem>
                    {categories.map((cat) => (
                      <SelectItem key={cat.id} value={cat.id}>
                        {cat.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Price Range */}
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <label className="text-sm font-medium">Price Range</label>
                  <span className="text-sm text-muted-foreground">
                    ₹{priceRange[0]} - ₹{priceRange[1]}
                  </span>
                </div>
                <Slider
                  value={priceRange}
                  onValueChange={(v) => setPriceRange(v as [number, number])}
                  onValueCommit={handlePriceChange}
                  min={0}
                  max={10000}
                  step={100}
                />
              </div>

              {/* Clear Filters */}
              {hasActiveFilters && (
                <Button
                  variant="outline"
                  onClick={clearFilters}
                  className="w-full"
                >
                  <X className="mr-2 h-4 w-4" />
                  Clear All Filters
                </Button>
              )}
            </div>
          </SheetContent>
        </Sheet>
      </div>

      {/* Quick Filter Chips with animations */}
      <div className="flex flex-wrap gap-2">
        {/* Type Chips */}
        <AnimatePresence mode="popLayout">
          <motion.div
            key="all"
            layout
            initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
            whileHover={prefersReducedMotion ? {} : { scale: 1.02 }}
            whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
          >
            <Badge
              variant={!filters.type ? "default" : "outline"}
              className="cursor-pointer transition-colors"
              onClick={() => handleTypeChange("all")}
            >
              All
            </Badge>
          </motion.div>
          {listingTypes.map((type, index) => (
            <motion.div
              key={type.value}
              layout
              initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              transition={{
                duration: 0.2,
                delay: (index + 1) * 0.05,
                ease: [0.16, 1, 0.3, 1],
              }}
              whileHover={prefersReducedMotion ? {} : { scale: 1.02 }}
              whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
            >
              <Badge
                variant={filters.type === type.value ? "default" : "outline"}
                className="cursor-pointer transition-colors"
                onClick={() => handleTypeChange(type.value)}
              >
                {type.label}
              </Badge>
            </motion.div>
          ))}

          {/* Active Filters Display */}
          {hasActiveFilters && (
            <motion.div
              key="clear-filters"
              initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.8 }}
              transition={{ duration: 0.2 }}
              whileHover={prefersReducedMotion ? {} : { scale: 1.05 }}
              whileTap={prefersReducedMotion ? {} : { scale: 0.95 }}
            >
              <Badge
                variant="secondary"
                className="cursor-pointer gap-1 transition-colors"
                onClick={clearFilters}
              >
                <Filter className="h-3 w-3" />
                Clear
                <X className="h-3 w-3" />
              </Badge>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}
