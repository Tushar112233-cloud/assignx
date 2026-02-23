"use client";

/**
 * Housing Filters Component
 *
 * Provides filtering options for housing listings in Campus Connect:
 * - Location filter (city, area, distance from campus)
 * - Price range slider
 * - Property type selection (PG, Flat, Hostel, Shared)
 * - Amenities checkboxes (WiFi, AC, Food, Laundry, etc.)
 */

import { useState, useCallback } from "react";
import { motion } from "framer-motion";
import {
  MapPin,
  IndianRupee,
  Building2,
  Wifi,
  Wind,
  UtensilsCrossed,
  Shirt,
  Car,
  Shield,
  Dumbbell,
  Droplets,
  Tv,
  X,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Slider } from "@/components/ui/slider";
import { Checkbox } from "@/components/ui/checkbox";
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
 * Housing filter state interface
 */
export interface HousingFilters {
  location?: string;
  area?: string;
  distanceFromCampus?: string;
  priceRange: [number, number];
  propertyType: string[];
  amenities: string[];
}

/**
 * Default housing filters
 */
export const defaultHousingFilters: HousingFilters = {
  location: undefined,
  area: undefined,
  distanceFromCampus: undefined,
  priceRange: [0, 50000],
  propertyType: [],
  amenities: [],
};

/**
 * Property type options
 */
const propertyTypes = [
  { id: "pg", label: "PG", icon: Building2 },
  { id: "flat", label: "Flat", icon: Building2 },
  { id: "hostel", label: "Hostel", icon: Building2 },
  { id: "shared", label: "Shared Room", icon: Building2 },
  { id: "studio", label: "Studio", icon: Building2 },
  { id: "1bhk", label: "1 BHK", icon: Building2 },
  { id: "2bhk", label: "2 BHK", icon: Building2 },
];

/**
 * Amenity options with icons
 */
const amenities = [
  { id: "wifi", label: "WiFi", icon: Wifi },
  { id: "ac", label: "AC", icon: Wind },
  { id: "food", label: "Food/Mess", icon: UtensilsCrossed },
  { id: "laundry", label: "Laundry", icon: Shirt },
  { id: "parking", label: "Parking", icon: Car },
  { id: "security", label: "24/7 Security", icon: Shield },
  { id: "gym", label: "Gym", icon: Dumbbell },
  { id: "geyser", label: "Geyser", icon: Droplets },
  { id: "tv", label: "TV/Cable", icon: Tv },
];

/**
 * Distance options
 */
const distanceOptions = [
  { value: "0-1", label: "Within 1 km" },
  { value: "1-2", label: "1-2 km" },
  { value: "2-5", label: "2-5 km" },
  { value: "5-10", label: "5-10 km" },
  { value: "10+", label: "10+ km" },
];

/**
 * Sample locations (can be fetched from API)
 */
const locations = [
  { value: "delhi", label: "Delhi" },
  { value: "mumbai", label: "Mumbai" },
  { value: "bangalore", label: "Bangalore" },
  { value: "hyderabad", label: "Hyderabad" },
  { value: "chennai", label: "Chennai" },
  { value: "pune", label: "Pune" },
  { value: "kolkata", label: "Kolkata" },
];

interface HousingFiltersProps {
  filters: HousingFilters;
  onFiltersChange: (filters: HousingFilters) => void;
  className?: string;
}

/**
 * Housing Filters Component
 * Provides comprehensive filtering options for housing listings
 */
export function HousingFiltersPanel({
  filters,
  onFiltersChange,
  className,
}: HousingFiltersProps) {
  /**
   * Update a single filter field
   */
  const updateFilter = useCallback(
    <K extends keyof HousingFilters>(key: K, value: HousingFilters[K]) => {
      onFiltersChange({ ...filters, [key]: value });
    },
    [filters, onFiltersChange]
  );

  /**
   * Toggle property type selection
   */
  const togglePropertyType = useCallback(
    (typeId: string) => {
      const current = filters.propertyType;
      const updated = current.includes(typeId)
        ? current.filter((t) => t !== typeId)
        : [...current, typeId];
      updateFilter("propertyType", updated);
    },
    [filters.propertyType, updateFilter]
  );

  /**
   * Toggle amenity selection
   */
  const toggleAmenity = useCallback(
    (amenityId: string) => {
      const current = filters.amenities;
      const updated = current.includes(amenityId)
        ? current.filter((a) => a !== amenityId)
        : [...current, amenityId];
      updateFilter("amenities", updated);
    },
    [filters.amenities, updateFilter]
  );

  /**
   * Format price for display
   */
  const formatPrice = (value: number) => {
    if (value >= 1000) {
      return `${(value / 1000).toFixed(0)}K`;
    }
    return value.toString();
  };

  /**
   * Count active filters
   */
  const activeFilterCount =
    (filters.location ? 1 : 0) +
    (filters.area ? 1 : 0) +
    (filters.distanceFromCampus ? 1 : 0) +
    (filters.priceRange[0] > 0 || filters.priceRange[1] < 50000 ? 1 : 0) +
    filters.propertyType.length +
    filters.amenities.length;

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
            onClick={() => onFiltersChange(defaultHousingFilters)}
            className="text-xs text-muted-foreground hover:text-foreground"
          >
            Clear all
          </Button>
        </div>
      )}

      {/* Location Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <MapPin className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Location</Label>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Select
            value={filters.location || ""}
            onValueChange={(value) =>
              updateFilter("location", value || undefined)
            }
          >
            <SelectTrigger className="h-10 rounded-xl">
              <SelectValue placeholder="Select city" />
            </SelectTrigger>
            <SelectContent>
              {locations.map((loc) => (
                <SelectItem key={loc.value} value={loc.value}>
                  {loc.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Select
            value={filters.distanceFromCampus || ""}
            onValueChange={(value) =>
              updateFilter("distanceFromCampus", value || undefined)
            }
          >
            <SelectTrigger className="h-10 rounded-xl">
              <SelectValue placeholder="Distance" />
            </SelectTrigger>
            <SelectContent>
              {distanceOptions.map((opt) => (
                <SelectItem key={opt.value} value={opt.value}>
                  {opt.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* Price Range Section */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <IndianRupee className="h-4 w-4 text-muted-foreground" />
            <Label className="text-sm font-medium">Monthly Rent</Label>
          </div>
          <span className="text-sm text-muted-foreground">
            {formatPrice(filters.priceRange[0])} -{" "}
            {formatPrice(filters.priceRange[1])}
          </span>
        </div>
        <Slider
          value={filters.priceRange}
          onValueChange={(value) =>
            updateFilter("priceRange", value as [number, number])
          }
          min={0}
          max={50000}
          step={1000}
          className="py-2"
        />
        <div className="flex justify-between text-xs text-muted-foreground">
          <span>Rs. 0</span>
          <span>Rs. 50,000+</span>
        </div>
      </div>

      {/* Property Type Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Building2 className="h-4 w-4 text-muted-foreground" />
          <Label className="text-sm font-medium">Property Type</Label>
        </div>
        <div className="flex flex-wrap gap-2">
          {propertyTypes.map((type) => {
            const isSelected = filters.propertyType.includes(type.id);
            return (
              <motion.button
                key={type.id}
                onClick={() => togglePropertyType(type.id)}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className={cn(
                  "flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-medium transition-all border",
                  isSelected
                    ? "bg-foreground text-background border-foreground"
                    : "bg-white/80 dark:bg-white/5 text-muted-foreground border-border/50 hover:border-border hover:text-foreground"
                )}
              >
                {type.label}
                {isSelected && <X className="h-3 w-3" />}
              </motion.button>
            );
          })}
        </div>
      </div>

      {/* Amenities Section */}
      <div className="space-y-3">
        <Label className="text-sm font-medium">Amenities</Label>
        <div className="grid grid-cols-2 gap-3">
          {amenities.map((amenity) => {
            const Icon = amenity.icon;
            const isChecked = filters.amenities.includes(amenity.id);
            return (
              <div
                key={amenity.id}
                className="flex items-center space-x-3 cursor-pointer"
                onClick={() => toggleAmenity(amenity.id)}
              >
                <Checkbox
                  id={`amenity-${amenity.id}`}
                  checked={isChecked}
                  onCheckedChange={() => toggleAmenity(amenity.id)}
                  className="data-[state=checked]:bg-foreground data-[state=checked]:border-foreground"
                />
                <label
                  htmlFor={`amenity-${amenity.id}`}
                  className={cn(
                    "flex items-center gap-2 text-sm cursor-pointer",
                    isChecked ? "text-foreground" : "text-muted-foreground"
                  )}
                >
                  <Icon className="h-4 w-4" />
                  {amenity.label}
                </label>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default HousingFiltersPanel;
