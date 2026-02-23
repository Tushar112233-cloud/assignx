"use client";

import { useRef } from "react";
import { ChevronLeft, ChevronRight, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { TutorCard } from "./tutor-card";
import { cn } from "@/lib/utils";
import type { Tutor } from "@/types/connect";

interface FeaturedTutorsProps {
  tutors: Tutor[];
  onTutorClick: (tutor: Tutor) => void;
  onBookTutor: (tutor: Tutor) => void;
  className?: string;
}

/**
 * Featured tutors carousel section
 * Displays top-rated tutors in a horizontal scrolling layout
 */
export function FeaturedTutors({
  tutors,
  onTutorClick,
  onBookTutor,
  className,
}: FeaturedTutorsProps) {
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  const scroll = (direction: "left" | "right") => {
    if (scrollContainerRef.current) {
      const scrollAmount = 320;
      scrollContainerRef.current.scrollBy({
        left: direction === "left" ? -scrollAmount : scrollAmount,
        behavior: "smooth",
      });
    }
  };

  if (!tutors.length) return null;

  return (
    <section className={cn("relative", className)}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Sparkles className="h-5 w-5 text-yellow-500" />
          <h2 className="text-lg font-semibold">Featured Tutors</h2>
        </div>

        {/* Desktop Navigation */}
        <div className="hidden lg:flex items-center gap-2">
          <Button
            variant="outline"
            size="icon"
            className="h-8 w-8"
            onClick={() => scroll("left")}
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            className="h-8 w-8"
            onClick={() => scroll("right")}
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Carousel */}
      <div
        ref={scrollContainerRef}
        className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide snap-x snap-mandatory"
      >
        {tutors.map((tutor) => (
          <div key={tutor.id} className="shrink-0 w-[300px] snap-start">
            <TutorCard
              tutor={tutor}
              variant="featured"
              onClick={() => onTutorClick(tutor)}
              onBook={() => onBookTutor(tutor)}
            />
          </div>
        ))}
      </div>
    </section>
  );
}
