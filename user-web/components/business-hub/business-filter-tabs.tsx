"use client";

/**
 * BusinessFilterTabs - Horizontally scrollable category filter tabs
 * Filters the business hub post feed by category
 */

import { useRef } from "react";
import { motion } from "framer-motion";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { BUSINESS_HUB_CATEGORIES, type BusinessHubCategory } from "@/types/business-hub";

interface BusinessFilterTabsProps {
  /** Currently selected category */
  activeCategory: BusinessHubCategory;
  /** Callback when a category is selected */
  onCategoryChange: (category: BusinessHubCategory) => void;
}

export function BusinessFilterTabs({
  activeCategory,
  onCategoryChange,
}: BusinessFilterTabsProps) {
  const scrollRef = useRef<HTMLDivElement>(null);

  const scrollBy = (direction: "left" | "right") => {
    if (scrollRef.current) {
      const amount = direction === "left" ? -200 : 200;
      scrollRef.current.scrollBy({ left: amount, behavior: "smooth" });
    }
  };

  return (
    <div className="relative group">
      {/* Left scroll button */}
      <Button
        variant="ghost"
        size="icon"
        className="absolute left-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 bg-background/80 backdrop-blur-sm shadow-sm opacity-0 group-hover:opacity-100 transition-opacity hidden md:flex"
        onClick={() => scrollBy("left")}
      >
        <ChevronLeft className="h-4 w-4" />
      </Button>

      {/* Scrollable tabs */}
      <div
        ref={scrollRef}
        className="flex gap-2 overflow-x-auto scrollbar-hide px-1 py-1"
      >
        {BUSINESS_HUB_CATEGORIES.map((category) => {
          const isActive = activeCategory === category.id;

          return (
            <button
              key={category.id}
              onClick={() => onCategoryChange(category.id)}
              className={cn(
                "relative flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium transition-colors whitespace-nowrap",
                isActive
                  ? "text-white"
                  : "text-muted-foreground hover:text-foreground hover:bg-muted"
              )}
            >
              {isActive && (
                <motion.div
                  layoutId="business-filter-pill"
                  className={cn(
                    "absolute inset-0 rounded-full bg-gradient-to-r",
                    category.gradient
                  )}
                  transition={{ type: "spring", bounce: 0.2, duration: 0.4 }}
                />
              )}
              <span className="relative z-10">{category.label}</span>
            </button>
          );
        })}
      </div>

      {/* Right scroll button */}
      <Button
        variant="ghost"
        size="icon"
        className="absolute right-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 bg-background/80 backdrop-blur-sm shadow-sm opacity-0 group-hover:opacity-100 transition-opacity hidden md:flex"
        onClick={() => scrollBy("right")}
      >
        <ChevronRight className="h-4 w-4" />
      </Button>
    </div>
  );
}
