"use client";

/**
 * SpecializationFilter - Capsule-style filter pills
 * Matches the Marketplace filter-bar style with horizontal scroll
 */

import { useRef } from "react";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import type { ExpertSpecialization } from "@/types/expert";

interface SpecializationFilterProps {
  selected: ExpertSpecialization | "all";
  onSelect: (specialization: ExpertSpecialization | "all") => void;
  className?: string;
}

/**
 * Specialization configuration
 */
const SPECIALIZATIONS: Array<{
  id: ExpertSpecialization | "all";
  label: string;
  emoji: string;
}> = [
  { id: "all", label: "All", emoji: "✨" },
  { id: "medicine", label: "Medicine", emoji: "🩺" },
  { id: "science", label: "Science", emoji: "🔬" },
  { id: "programming", label: "Code", emoji: "💻" },
  { id: "data_analysis", label: "Data", emoji: "📊" },
  { id: "mathematics", label: "Math", emoji: "📐" },
  { id: "research_methodology", label: "Research", emoji: "📚" },
  { id: "academic_writing", label: "Writing", emoji: "✍️" },
  { id: "business", label: "Business", emoji: "💼" },
  { id: "engineering", label: "Engineering", emoji: "⚙️" },
  { id: "law", label: "Law", emoji: "⚖️" },
  { id: "arts", label: "Arts", emoji: "🎨" },
];

/**
 * SpecializationFilter component - Capsule pills with horizontal scroll
 */
export function SpecializationFilter({
  selected,
  onSelect,
  className,
}: SpecializationFilterProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const prefersReducedMotion = useReducedMotion();

  const scroll = (direction: "left" | "right") => {
    if (scrollRef.current) {
      const scrollAmount = 200;
      scrollRef.current.scrollBy({
        left: direction === "left" ? -scrollAmount : scrollAmount,
        behavior: "smooth",
      });
    }
  };

  return (
    <div className={cn("relative group", className)}>
      {/* Scroll buttons */}
      <button
        onClick={() => scroll("left")}
        className="absolute left-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 rounded-full bg-white dark:bg-stone-800 shadow-md border border-stone-200 dark:border-stone-700 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <ChevronLeft className="h-4 w-4" />
      </button>
      <button
        onClick={() => scroll("right")}
        className="absolute right-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 rounded-full bg-white dark:bg-stone-800 shadow-md border border-stone-200 dark:border-stone-700 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <ChevronRight className="h-4 w-4" />
      </button>

      {/* Scrollable pills container */}
      <div
        ref={scrollRef}
        className="flex gap-2 overflow-x-auto scrollbar-hide px-1 py-1 -mx-1"
        style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
      >
        <AnimatePresence mode="popLayout">
          {SPECIALIZATIONS.map((spec, index) => {
            const isActive = selected === spec.id;

            return (
              <motion.button
                key={spec.id}
                layout
                initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                transition={{ duration: 0.2, delay: index * 0.02 }}
                whileHover={prefersReducedMotion ? {} : { scale: 1.03 }}
                whileTap={prefersReducedMotion ? {} : { scale: 0.97 }}
                onClick={() => onSelect(spec.id)}
                className={cn(
                  "flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all duration-200 shrink-0",
                  isActive
                    ? "bg-violet-600 text-white shadow-md shadow-violet-500/25"
                    : "bg-white dark:bg-stone-800 text-stone-600 dark:text-stone-300 border border-stone-200 dark:border-stone-700 hover:border-violet-300 dark:hover:border-violet-700 hover:bg-violet-50 dark:hover:bg-violet-950/30"
                )}
              >
                <span>{spec.emoji}</span>
                <span>{spec.label}</span>
              </motion.button>
            );
          })}
        </AnimatePresence>
      </div>
    </div>
  );
}

/**
 * Medical specialization filter specifically for doctors
 */
interface MedicalFilterProps {
  selected: string | "all";
  onSelect: (specialization: string | "all") => void;
  className?: string;
}

/**
 * Medical specializations
 */
const MEDICAL_SPECIALIZATIONS: Array<{
  id: string;
  label: string;
  emoji: string;
}> = [
  { id: "all", label: "All", emoji: "✨" },
  { id: "cardiology", label: "Heart", emoji: "❤️" },
  { id: "neurology", label: "Brain", emoji: "🧠" },
  { id: "pediatrics", label: "Kids", emoji: "👶" },
  { id: "orthopedics", label: "Bones", emoji: "🦴" },
  { id: "ophthalmology", label: "Eyes", emoji: "👁️" },
  { id: "general", label: "General", emoji: "🩺" },
  { id: "dermatology", label: "Skin", emoji: "✋" },
  { id: "psychiatry", label: "Mental", emoji: "🧘" },
];

/**
 * MedicalFilter component - Capsule pills with horizontal scroll
 */
export function MedicalFilter({
  selected,
  onSelect,
  className,
}: MedicalFilterProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const prefersReducedMotion = useReducedMotion();

  const scroll = (direction: "left" | "right") => {
    if (scrollRef.current) {
      const scrollAmount = 200;
      scrollRef.current.scrollBy({
        left: direction === "left" ? -scrollAmount : scrollAmount,
        behavior: "smooth",
      });
    }
  };

  return (
    <div className={cn("relative group", className)}>
      {/* Scroll buttons */}
      <button
        onClick={() => scroll("left")}
        className="absolute left-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 rounded-full bg-white dark:bg-stone-800 shadow-md border border-stone-200 dark:border-stone-700 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <ChevronLeft className="h-4 w-4" />
      </button>
      <button
        onClick={() => scroll("right")}
        className="absolute right-0 top-1/2 -translate-y-1/2 z-10 h-8 w-8 rounded-full bg-white dark:bg-stone-800 shadow-md border border-stone-200 dark:border-stone-700 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <ChevronRight className="h-4 w-4" />
      </button>

      {/* Scrollable pills container */}
      <div
        ref={scrollRef}
        className="flex gap-2 overflow-x-auto scrollbar-hide px-1 py-1 -mx-1"
        style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
      >
        <AnimatePresence mode="popLayout">
          {MEDICAL_SPECIALIZATIONS.map((spec, index) => {
            const isActive = selected === spec.id;

            return (
              <motion.button
                key={spec.id}
                layout
                initial={prefersReducedMotion ? {} : { opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                transition={{ duration: 0.2, delay: index * 0.02 }}
                whileHover={prefersReducedMotion ? {} : { scale: 1.03 }}
                whileTap={prefersReducedMotion ? {} : { scale: 0.97 }}
                onClick={() => onSelect(spec.id)}
                className={cn(
                  "flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all duration-200 shrink-0",
                  isActive
                    ? "bg-violet-600 text-white shadow-md shadow-violet-500/25"
                    : "bg-white dark:bg-stone-800 text-stone-600 dark:text-stone-300 border border-stone-200 dark:border-stone-700 hover:border-violet-300 dark:hover:border-violet-700 hover:bg-violet-50 dark:hover:bg-violet-950/30"
                )}
              >
                <span>{spec.emoji}</span>
                <span>{spec.label}</span>
              </motion.button>
            );
          })}
        </AnimatePresence>
      </div>
    </div>
  );
}

export default SpecializationFilter;
