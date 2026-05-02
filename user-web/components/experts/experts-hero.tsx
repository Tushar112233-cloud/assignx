"use client";

/**
 * ExpertsHero - Clean, focused hero section for experts page
 * Features a prominent search bar and inline trust indicators
 */

import { useState } from "react";
import { motion } from "framer-motion";
import { Search, BadgeCheck, Star, Clock } from "lucide-react";
import { cn } from "@/lib/utils";

interface ExpertsHeroProps {
  onSearch?: (query: string) => void;
  className?: string;
}

/**
 * Trust indicators - compact inline display
 */
const TRUST_INDICATORS = [
  { icon: BadgeCheck, text: "500+ Verified", color: "text-violet-500" },
  { icon: Star, text: "4.9 Rating", color: "text-amber-500" },
  { icon: Clock, text: "24/7 Available", color: "text-emerald-500" },
];

/**
 * ExpertsHero component - Clean discovery-focused design
 */
export function ExpertsHero({ onSearch, className }: ExpertsHeroProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [isFocused, setIsFocused] = useState(false);

  const handleSearchChange = (value: string) => {
    setSearchQuery(value);
    onSearch?.(value);
  };

  return (
    <div className={cn("relative w-full", className)}>
      <div className="relative z-10 w-full py-6 md:py-8">
        {/* Compact Header */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-6"
        >
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-semibold tracking-tight text-foreground mb-2">
            Find Your{" "}
            <span className="bg-gradient-to-r from-violet-600 to-purple-600 dark:from-violet-400 dark:to-purple-400 bg-clip-text text-transparent">
              Expert
            </span>
          </h1>
          <p className="text-sm md:text-base text-muted-foreground max-w-lg mx-auto">
            Connect with verified professionals for consultations
          </p>
        </motion.div>

        {/* Prominent Search Bar */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="max-w-xl mx-auto mb-6"
        >
          <div
            className={cn(
              "relative rounded-2xl transition-all duration-300",
              isFocused
                ? "ring-2 ring-violet-500/40 ring-offset-2 ring-offset-background"
                : ""
            )}
          >
            {/* Search Icon */}
            <div className="absolute left-4 top-1/2 -translate-y-1/2 z-10">
              <Search
                className={cn(
                  "h-5 w-5 transition-colors duration-200",
                  isFocused ? "text-violet-500" : "text-muted-foreground"
                )}
                strokeWidth={2}
              />
            </div>

            {/* Search Input - Solid white background for visibility */}
            <input
              type="text"
              placeholder="Search by name, specialty, or condition..."
              value={searchQuery}
              onChange={(e) => handleSearchChange(e.target.value)}
              onFocus={() => setIsFocused(true)}
              onBlur={() => setIsFocused(false)}
              className={cn(
                "w-full h-14 pl-12 pr-4 text-base",
                "bg-white dark:bg-stone-900",
                "border-2 border-stone-200 dark:border-stone-700",
                "rounded-2xl shadow-lg shadow-stone-200/50 dark:shadow-stone-900/50",
                "placeholder:text-muted-foreground/60",
                "focus:outline-none focus:border-violet-400 dark:focus:border-violet-500",
                "transition-all duration-200"
              )}
            />

            {/* Shortcut hint */}
            <div className="absolute right-4 top-1/2 -translate-y-1/2 hidden sm:flex items-center gap-1">
              <kbd className="px-2 py-1 text-xs font-medium text-muted-foreground bg-stone-100 dark:bg-stone-800 rounded-md border border-stone-200 dark:border-stone-700">
                /
              </kbd>
            </div>
          </div>
        </motion.div>

        {/* Trust Indicators - Compact inline badges */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="flex flex-wrap items-center justify-center gap-3 md:gap-6"
        >
          {TRUST_INDICATORS.map((item, index) => (
            <motion.div
              key={item.text}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.3, delay: 0.25 + index * 0.05 }}
              className="flex items-center gap-1.5 text-sm text-muted-foreground"
            >
              <item.icon className={cn("h-4 w-4", item.color)} strokeWidth={2} />
              <span className="font-medium">{item.text}</span>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </div>
  );
}

export default ExpertsHero;
