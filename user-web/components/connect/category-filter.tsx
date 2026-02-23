"use client";

import { useRef } from "react";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import { Grid3X3, GraduationCap, FileText, Users, MessageCircle, ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { CategoryFilterSkeleton } from "@/components/ui/filter-skeleton";
import { cn } from "@/lib/utils";
import type { ConnectCategory } from "@/types/connect";

interface CategoryFilterProps {
  selected: ConnectCategory;
  onChange: (category: ConnectCategory) => void;
  className?: string;
  isLoading?: boolean;
}

const categories: { id: ConnectCategory; label: string; icon: React.ElementType }[] = [
  { id: "all", label: "All", icon: Grid3X3 },
  { id: "tutors", label: "Tutors", icon: GraduationCap },
  { id: "resources", label: "Resources", icon: FileText },
  { id: "study-groups", label: "Study Groups", icon: Users },
  { id: "qa", label: "Q&A", icon: MessageCircle },
];

/**
 * Horizontal scrolling category filter chips
 * Used to filter content on the Student Connect page
 * Now with smooth animations and loading skeleton
 */
export function CategoryFilter({ selected, onChange, className, isLoading }: CategoryFilterProps) {
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const prefersReducedMotion = useReducedMotion();

  const scroll = (direction: "left" | "right") => {
    if (scrollContainerRef.current) {
      const scrollAmount = 150;
      scrollContainerRef.current.scrollBy({
        left: direction === "left" ? -scrollAmount : scrollAmount,
        behavior: "smooth",
      });
    }
  };

  // Show skeleton during loading
  if (isLoading) {
    return <CategoryFilterSkeleton count={5} className={className} />;
  }

  return (
    <div className={cn("relative", className)}>
      {/* Scroll buttons - hidden on mobile, visible on larger screens */}
      <Button
        variant="ghost"
        size="icon"
        className="absolute -left-2 top-1/2 z-10 hidden h-8 w-8 -translate-y-1/2 rounded-full bg-background shadow-md lg:flex"
        onClick={() => scroll("left")}
      >
        <ChevronLeft className="h-4 w-4" />
      </Button>
      <Button
        variant="ghost"
        size="icon"
        className="absolute -right-2 top-1/2 z-10 hidden h-8 w-8 -translate-y-1/2 rounded-full bg-background shadow-md lg:flex"
        onClick={() => scroll("right")}
      >
        <ChevronRight className="h-4 w-4" />
      </Button>

      {/* Scrollable container with animations */}
      <div
        ref={scrollContainerRef}
        className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide lg:px-4"
      >
        <AnimatePresence mode="popLayout">
          {categories.map((category, index) => {
            const Icon = category.icon;
            const isSelected = selected === category.id;

            return (
              <motion.button
                key={category.id}
                layout
                initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                transition={{
                  duration: 0.2,
                  delay: index * 0.05,
                  ease: [0.16, 1, 0.3, 1],
                }}
                whileHover={prefersReducedMotion ? {} : { scale: 1.02 }}
                whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
                onClick={() => onChange(category.id)}
                className={cn(
                  "flex shrink-0 items-center gap-2 rounded-full px-4 py-2 text-sm font-medium transition-colors",
                  isSelected
                    ? "bg-primary text-primary-foreground shadow-md"
                    : "bg-muted text-muted-foreground hover:bg-muted/80"
                )}
              >
                <Icon className="h-4 w-4" />
                <span>{category.label}</span>
              </motion.button>
            );
          })}
        </AnimatePresence>
      </div>
    </div>
  );
}
