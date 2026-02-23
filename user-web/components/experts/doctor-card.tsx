"use client";

/**
 * DoctorCard - Clean, modern doctor card component
 * Supports grid card and list variants
 */

import { memo } from "react";
import { motion } from "framer-motion";
import { Star, BadgeCheck, Video, ArrowRight } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import type { Expert } from "@/types/expert";

interface DoctorCardProps {
  doctor: Expert;
  variant?: "default" | "list";
  onClick?: () => void;
  onBookClick?: () => void;
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
 * DoctorCard component - Clean modern design
 */
export const DoctorCard = memo(function DoctorCard({
  doctor,
  variant = "default",
  onClick,
  onBookClick,
  className,
}: DoctorCardProps) {
  // List variant - horizontal compact card
  if (variant === "list") {
    return (
      <motion.div
        whileHover={{ scale: 1.01 }}
        whileTap={{ scale: 0.99 }}
        transition={{ duration: 0.2 }}
        className={cn("cursor-pointer", className)}
        onClick={onClick}
      >
        <div className="flex items-center gap-4 p-4 rounded-xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 hover:border-violet-300 dark:hover:border-violet-700 hover:shadow-md transition-all duration-200">
          {/* Avatar */}
          <div className="relative shrink-0">
            <Avatar className="h-12 w-12 border-2 border-stone-100 dark:border-stone-800">
              <AvatarImage src={doctor.avatar} alt={doctor.name} />
              <AvatarFallback className="text-sm font-semibold bg-violet-100 dark:bg-violet-900/50 text-violet-700 dark:text-violet-300">
                {getInitials(doctor.name)}
              </AvatarFallback>
            </Avatar>
            {doctor.availability === "available" && (
              <span className="absolute -bottom-0.5 -right-0.5 h-3.5 w-3.5 bg-emerald-500 rounded-full border-2 border-white dark:border-stone-900" />
            )}
          </div>

          {/* Info */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5 mb-0.5">
              <h3 className="font-semibold text-foreground truncate">
                {doctor.name}
              </h3>
              {doctor.verified && (
                <BadgeCheck className="h-4 w-4 text-violet-500 shrink-0" />
              )}
            </div>
            <p className="text-sm text-muted-foreground truncate">
              {doctor.designation}
            </p>
          </div>

          {/* Rating */}
          <div className="flex items-center gap-1 px-2 py-1 rounded-lg bg-amber-50 dark:bg-amber-900/20">
            <Star className="h-3.5 w-3.5 fill-amber-500 text-amber-500" />
            <span className="text-sm font-semibold text-amber-700 dark:text-amber-400">
              {doctor.rating.toFixed(1)}
            </span>
          </div>

          {/* Price */}
          <div className="text-right shrink-0">
            <div className="text-lg font-bold text-foreground">
              {formatINR(doctor.pricePerSession)}
            </div>
          </div>

          {/* Arrow */}
          <ArrowRight className="h-4 w-4 text-muted-foreground" />
        </div>
      </motion.div>
    );
  }

  // Default variant - Grid card
  return (
    <motion.div
      whileHover={{ y: -4 }}
      whileTap={{ scale: 0.98 }}
      transition={{ duration: 0.2 }}
      className={cn("cursor-pointer h-full", className)}
      onClick={onClick}
    >
      <div className="h-full flex flex-col rounded-2xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 hover:border-violet-300 dark:hover:border-violet-700 hover:shadow-lg transition-all duration-200 overflow-hidden">
        {/* Top section with avatar */}
        <div className="relative p-5 pb-4">
          {/* Availability badge */}
          {doctor.availability === "available" && (
            <div className="absolute top-3 right-3 flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400 text-xs font-medium">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
              Online
            </div>
          )}

          {/* Avatar with gradient ring */}
          <div className="flex justify-center mb-4">
            <div className="relative">
              <div className="absolute -inset-1 bg-gradient-to-br from-violet-400 to-purple-500 rounded-full opacity-60" />
              <Avatar className="relative h-16 w-16 border-2 border-white dark:border-stone-900">
                <AvatarImage src={doctor.avatar} alt={doctor.name} />
                <AvatarFallback className="text-lg font-bold bg-gradient-to-br from-violet-100 to-purple-100 dark:from-violet-900 dark:to-purple-900 text-violet-700 dark:text-violet-300">
                  {getInitials(doctor.name)}
                </AvatarFallback>
              </Avatar>
            </div>
          </div>

          {/* Name & verification */}
          <div className="text-center">
            <div className="flex items-center justify-center gap-1.5 mb-1">
              <h3 className="font-semibold text-foreground truncate">
                {doctor.name}
              </h3>
              {doctor.verified && (
                <BadgeCheck className="h-4 w-4 text-violet-500 shrink-0" />
              )}
            </div>
            <p className="text-sm text-muted-foreground line-clamp-1">
              {doctor.designation}
            </p>
          </div>
        </div>

        {/* Stats row */}
        <div className="flex items-center justify-center gap-4 px-5 py-3 bg-stone-50 dark:bg-stone-800/50">
          <div className="flex items-center gap-1">
            <Star className="h-4 w-4 fill-amber-500 text-amber-500" />
            <span className="text-sm font-semibold">{doctor.rating.toFixed(1)}</span>
            <span className="text-xs text-muted-foreground">({doctor.reviewCount})</span>
          </div>
          <div className="w-px h-4 bg-stone-200 dark:bg-stone-700" />
          <div className="flex items-center gap-1 text-sm text-muted-foreground">
            <Video className="h-3.5 w-3.5" />
            <span>{doctor.totalSessions}+</span>
          </div>
        </div>

        {/* Bottom section with price and CTA */}
        <div className="mt-auto p-4 pt-3">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-xl font-bold text-foreground">
                {formatINR(doctor.pricePerSession)}
              </div>
              <div className="text-xs text-muted-foreground">per session</div>
            </div>
            <Button
              size="sm"
              onClick={(e) => {
                e.stopPropagation();
                onBookClick?.();
              }}
              className="bg-violet-600 hover:bg-violet-700 text-white shadow-sm"
            >
              Book
            </Button>
          </div>
        </div>
      </div>
    </motion.div>
  );
});

export default DoctorCard;
