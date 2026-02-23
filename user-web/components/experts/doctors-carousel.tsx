"use client";

/**
 * DoctorsCarousel - Premium spotlight carousel for featured doctors
 * Clean, focused design with gradient accents and smooth animations
 */

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  ChevronLeft,
  ChevronRight,
  Star,
  BadgeCheck,
  Clock,
  Video,
  TrendingUp,
} from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import type { Expert } from "@/types/expert";

interface DoctorsCarouselProps {
  doctors: Expert[];
  onDoctorClick?: (doctor: Expert) => void;
  onBookClick?: (doctor: Expert) => void;
  className?: string;
}

/**
 * Get initials from name
 */
function getInitials(name: string): string {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

/**
 * DoctorsCarousel component - Spotlight design
 */
export function DoctorsCarousel({
  doctors,
  onDoctorClick,
  onBookClick,
  className,
}: DoctorsCarouselProps) {
  const [[currentIndex, direction], setSlide] = useState([0, 0]);
  const [isPaused, setIsPaused] = useState(false);

  const totalSlides = doctors.length;

  const goToSlide = useCallback(
    (index: number) => {
      const newDirection = index > currentIndex ? 1 : -1;
      setSlide([index, newDirection]);
    },
    [currentIndex]
  );

  const nextSlide = useCallback(() => {
    setSlide(([prev]) => [(prev + 1) % totalSlides, 1]);
  }, [totalSlides]);

  const prevSlide = useCallback(() => {
    setSlide(([prev]) => [(prev - 1 + totalSlides) % totalSlides, -1]);
  }, [totalSlides]);

  useEffect(() => {
    if (!isPaused && totalSlides > 1) {
      const interval = setInterval(nextSlide, 6000);
      return () => clearInterval(interval);
    }
  }, [isPaused, nextSlide, totalSlides]);

  if (doctors.length === 0) return null;

  const doctor = doctors[currentIndex];

  return (
    <div
      className={cn("relative", className)}
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      {/* Section Header - Clean and minimal */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <TrendingUp className="h-4 w-4 text-amber-500" />
          <h2 className="text-sm font-semibold text-foreground uppercase tracking-wide">
            Top Pick
          </h2>
        </div>

        {/* Navigation Controls */}
        {totalSlides > 1 && (
          <div className="flex items-center gap-2">
            <button
              onClick={prevSlide}
              className="h-8 w-8 rounded-full flex items-center justify-center bg-stone-100 dark:bg-stone-800 hover:bg-stone-200 dark:hover:bg-stone-700 transition-colors"
            >
              <ChevronLeft className="h-4 w-4" />
            </button>
            <div className="flex items-center gap-1.5">
              {doctors.map((_, i) => (
                <button
                  key={i}
                  onClick={() => goToSlide(i)}
                  className={cn(
                    "h-1.5 rounded-full transition-all duration-300",
                    i === currentIndex
                      ? "w-6 bg-violet-500"
                      : "w-1.5 bg-stone-300 dark:bg-stone-600 hover:bg-stone-400"
                  )}
                />
              ))}
            </div>
            <button
              onClick={nextSlide}
              className="h-8 w-8 rounded-full flex items-center justify-center bg-stone-100 dark:bg-stone-800 hover:bg-stone-200 dark:hover:bg-stone-700 transition-colors"
            >
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>

      {/* Spotlight Card */}
      <AnimatePresence mode="wait" initial={false}>
        <motion.div
          key={currentIndex}
          initial={{ opacity: 0, x: direction > 0 ? 40 : -40 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: direction > 0 ? -40 : 40 }}
          transition={{ duration: 0.3, ease: "easeOut" }}
        >
          <div
            onClick={() => onDoctorClick?.(doctor)}
            className={cn(
              "relative overflow-hidden rounded-2xl cursor-pointer",
              "bg-gradient-to-br from-violet-600 via-purple-600 to-indigo-700",
              "p-[1px]" // Gradient border trick
            )}
          >
            <div className="relative rounded-2xl bg-white dark:bg-stone-900 p-5 md:p-6">
              {/* Decorative gradient blur */}
              <div className="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-violet-500/20 to-purple-500/10 rounded-full blur-3xl" />

              <div className="relative flex flex-col sm:flex-row gap-5">
                {/* Left: Avatar with gradient ring */}
                <div className="flex flex-col items-center sm:items-start gap-3">
                  <div className="relative">
                    {/* Gradient ring */}
                    <div className="absolute -inset-1 bg-gradient-to-br from-violet-500 via-purple-500 to-indigo-500 rounded-full opacity-75" />
                    <Avatar className="relative h-20 w-20 border-3 border-white dark:border-stone-900">
                      <AvatarImage src={doctor.avatar} alt={doctor.name} />
                      <AvatarFallback className="text-lg font-bold bg-gradient-to-br from-violet-100 to-purple-100 dark:from-violet-900 dark:to-purple-900">
                        {getInitials(doctor.name)}
                      </AvatarFallback>
                    </Avatar>
                    {/* Online indicator */}
                    {doctor.availability === "available" && (
                      <span className="absolute bottom-0 right-0 h-5 w-5 bg-emerald-500 rounded-full border-3 border-white dark:border-stone-900" />
                    )}
                  </div>

                  {/* Rating badge */}
                  <div className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-amber-50 dark:bg-amber-900/30 border border-amber-200 dark:border-amber-800/50">
                    <Star className="h-3.5 w-3.5 fill-amber-500 text-amber-500" />
                    <span className="text-sm font-bold text-amber-700 dark:text-amber-400">
                      {doctor.rating.toFixed(1)}
                    </span>
                  </div>
                </div>

                {/* Center: Info */}
                <div className="flex-1 min-w-0 text-center sm:text-left">
                  <div className="flex items-center justify-center sm:justify-start gap-2 mb-1">
                    <h3 className="text-lg font-semibold text-foreground truncate">
                      {doctor.name}
                    </h3>
                    {doctor.verified && (
                      <BadgeCheck className="h-5 w-5 text-violet-500 shrink-0" />
                    )}
                  </div>

                  <p className="text-sm text-muted-foreground mb-3">
                    {doctor.designation}
                  </p>

                  {/* Quick stats */}
                  <div className="flex flex-wrap items-center justify-center sm:justify-start gap-3 text-xs text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <Video className="h-3.5 w-3.5" />
                      {doctor.totalSessions}+ sessions
                    </span>
                    <span className="flex items-center gap-1">
                      <Clock className="h-3.5 w-3.5" />
                      Quick response
                    </span>
                  </div>

                  {/* Bio snippet */}
                  {doctor.bio && (
                    <p className="mt-3 text-sm text-muted-foreground line-clamp-2 hidden md:block">
                      {doctor.bio}
                    </p>
                  )}
                </div>

                {/* Right: Price & CTA */}
                <div className="flex flex-col items-center sm:items-end justify-between gap-3 pt-3 sm:pt-0 border-t sm:border-t-0 border-stone-100 dark:border-stone-800">
                  <div className="text-center sm:text-right">
                    <div className="text-2xl font-bold text-foreground">
                      {formatINR(doctor.pricePerSession)}
                    </div>
                    <div className="text-xs text-muted-foreground">
                      per session
                    </div>
                  </div>

                  <Button
                    onClick={(e) => {
                      e.stopPropagation();
                      onBookClick?.(doctor);
                    }}
                    className="bg-gradient-to-r from-violet-600 to-purple-600 hover:from-violet-700 hover:to-purple-700 text-white shadow-lg shadow-violet-500/25 px-6"
                  >
                    Book Now
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </motion.div>
      </AnimatePresence>
    </div>
  );
}

export default DoctorsCarousel;
