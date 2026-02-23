"use client";

/**
 * ExpertCard - Clean, modern expert card component
 * Supports list and compact variants
 */

import { memo } from "react";
import { motion } from "framer-motion";
import { Star, BadgeCheck, Video, ArrowRight } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { formatINR } from "@/lib/utils";
import type { Expert, ExpertSpecialization } from "@/types/expert";

interface ExpertCardProps {
  expert: Expert;
  onClick?: () => void;
  onBook?: () => void;
  variant?: "default" | "compact" | "featured";
  className?: string;
}

/**
 * Specialization label mapping
 */
const SPEC_LABELS: Record<ExpertSpecialization, string> = {
  academic_writing: "Writing",
  research_methodology: "Research",
  data_analysis: "Data",
  programming: "Code",
  mathematics: "Math",
  science: "Science",
  business: "Business",
  engineering: "Engineering",
  law: "Law",
  medicine: "Medicine",
  arts: "Arts",
  other: "Other",
};

/**
 * Get initials from name for avatar fallback
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
 * Expert card component displaying expert information
 */
export const ExpertCard = memo(function ExpertCard({
  expert,
  onClick,
  onBook,
  variant = "default",
  className,
}: ExpertCardProps) {
  // Compact variant - Small card for grids
  if (variant === "compact") {
    return (
      <motion.div
        whileHover={{ y: -3 }}
        whileTap={{ scale: 0.98 }}
        transition={{ duration: 0.2 }}
        className={cn("cursor-pointer h-full", className)}
        onClick={onClick}
      >
        <div className="h-full flex flex-col p-4 rounded-xl bg-white dark:bg-stone-900 border border-stone-200 dark:border-stone-800 hover:border-violet-300 dark:hover:border-violet-700 hover:shadow-md transition-all duration-200">
          {/* Avatar and name */}
          <div className="flex items-center gap-3 mb-3">
            <div className="relative">
              <Avatar className="h-10 w-10 border border-stone-100 dark:border-stone-800">
                <AvatarImage src={expert.avatar} alt={expert.name} />
                <AvatarFallback className="text-xs font-semibold bg-violet-100 dark:bg-violet-900/50 text-violet-700 dark:text-violet-300">
                  {getInitials(expert.name)}
                </AvatarFallback>
              </Avatar>
              {expert.availability === "available" && (
                <span className="absolute -bottom-0.5 -right-0.5 h-3 w-3 bg-emerald-500 rounded-full border-2 border-white dark:border-stone-900" />
              )}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1">
                <h3 className="font-semibold text-sm text-foreground truncate">
                  {expert.name}
                </h3>
                {expert.verified && (
                  <BadgeCheck className="h-3.5 w-3.5 text-violet-500 shrink-0" />
                )}
              </div>
              <p className="text-xs text-muted-foreground truncate">
                {expert.designation}
              </p>
            </div>
          </div>

          {/* Rating and sessions */}
          <div className="flex items-center gap-2 text-xs mb-3">
            <div className="flex items-center gap-1 px-2 py-0.5 rounded-md bg-amber-50 dark:bg-amber-900/20">
              <Star className="h-3 w-3 fill-amber-500 text-amber-500" />
              <span className="font-semibold text-amber-700 dark:text-amber-400">
                {expert.rating.toFixed(1)}
              </span>
            </div>
            <span className="text-muted-foreground">
              {expert.totalSessions}+ sessions
            </span>
          </div>

          {/* Price and book */}
          <div className="mt-auto flex items-center justify-between pt-3 border-t border-stone-100 dark:border-stone-800">
            <div>
              <span className="text-base font-bold text-foreground">
                {formatINR(expert.pricePerSession)}
              </span>
              <span className="text-xs text-muted-foreground">/hr</span>
            </div>
            <Button
              size="sm"
              variant="outline"
              className="h-7 text-xs border-violet-200 dark:border-violet-800 text-violet-600 dark:text-violet-400 hover:bg-violet-50 dark:hover:bg-violet-950/30"
              onClick={(e) => {
                e.stopPropagation();
                onBook?.();
              }}
            >
              Book
            </Button>
          </div>
        </div>
      </motion.div>
    );
  }

  // Default variant - List card (horizontal)
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
          <Avatar className="h-14 w-14 border-2 border-stone-100 dark:border-stone-800">
            <AvatarImage src={expert.avatar} alt={expert.name} />
            <AvatarFallback className="text-sm font-semibold bg-violet-100 dark:bg-violet-900/50 text-violet-700 dark:text-violet-300">
              {getInitials(expert.name)}
            </AvatarFallback>
          </Avatar>
          {expert.availability === "available" && (
            <span className="absolute -bottom-0.5 -right-0.5 h-4 w-4 bg-emerald-500 rounded-full border-2 border-white dark:border-stone-900" />
          )}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-1.5 mb-0.5">
            <h3 className="font-semibold text-foreground truncate">
              {expert.name}
            </h3>
            {expert.verified && (
              <BadgeCheck className="h-4 w-4 text-violet-500 shrink-0" />
            )}
          </div>
          <p className="text-sm text-muted-foreground truncate mb-2">
            {expert.designation}
          </p>

          {/* Specializations as capsules */}
          <div className="flex flex-wrap gap-1.5">
            {expert.specializations.slice(0, 3).map((spec) => (
              <span
                key={spec}
                className="px-2 py-0.5 text-xs font-medium rounded-full bg-stone-100 dark:bg-stone-800 text-stone-600 dark:text-stone-400"
              >
                {SPEC_LABELS[spec]}
              </span>
            ))}
            {expert.specializations.length > 3 && (
              <span className="px-2 py-0.5 text-xs font-medium rounded-full bg-stone-100 dark:bg-stone-800 text-stone-500">
                +{expert.specializations.length - 3}
              </span>
            )}
          </div>
        </div>

        {/* Stats */}
        <div className="hidden sm:flex flex-col items-center gap-1 px-4 border-l border-stone-200 dark:border-stone-800">
          <div className="flex items-center gap-1">
            <Star className="h-4 w-4 fill-amber-500 text-amber-500" />
            <span className="text-sm font-bold">{expert.rating.toFixed(1)}</span>
          </div>
          <div className="flex items-center gap-1 text-xs text-muted-foreground">
            <Video className="h-3 w-3" />
            <span>{expert.totalSessions}+</span>
          </div>
        </div>

        {/* Price & CTA */}
        <div className="shrink-0 text-right">
          <div className="text-lg font-bold text-foreground">
            {formatINR(expert.pricePerSession)}
          </div>
          <div className="text-xs text-muted-foreground mb-2">/session</div>
          <Button
            size="sm"
            onClick={(e) => {
              e.stopPropagation();
              onBook?.();
            }}
            className="bg-violet-600 hover:bg-violet-700 text-white"
          >
            Book
          </Button>
        </div>

        {/* Arrow on hover */}
        <ArrowRight className="h-4 w-4 text-muted-foreground hidden sm:block" />
      </div>
    </motion.div>
  );
});

export default ExpertCard;
