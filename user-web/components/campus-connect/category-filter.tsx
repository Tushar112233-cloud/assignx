"use client";

import { motion } from "framer-motion";
import {
  HelpCircle,
  Home,
  Briefcase,
  BookOpen,
  Calendar,
  ShoppingBag,
  Search,
  Car,
  Users,
  Trophy,
  Megaphone,
  MessageSquare,
  Sparkles,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";
import type { CampusConnectCategory } from "@/types/campus-connect";

/**
 * Category configuration with icons
 * Must match database enum values exactly
 */
interface CategoryConfig {
  id: CampusConnectCategory | "all";
  label: string;
  icon: LucideIcon;
}

const categories: CategoryConfig[] = [
  { id: "all", label: "All", icon: Sparkles },
  { id: "questions", label: "Questions", icon: HelpCircle },
  { id: "housing", label: "Housing", icon: Home },
  { id: "opportunities", label: "Opportunities", icon: Briefcase },
  { id: "resources", label: "Resources", icon: BookOpen },
  { id: "events", label: "Events", icon: Calendar },
  { id: "marketplace", label: "Marketplace", icon: ShoppingBag },
  { id: "lost_found", label: "Lost & Found", icon: Search },
  { id: "rides", label: "Rides", icon: Car },
  { id: "study_groups", label: "Study Groups", icon: Users },
  { id: "clubs", label: "Clubs", icon: Trophy },
  { id: "announcements", label: "Announcements", icon: Megaphone },
  { id: "discussions", label: "Discussions", icon: MessageSquare },
];

interface CategoryFilterProps {
  selectedCategory: CampusConnectCategory | "all";
  onCategoryChange: (category: CampusConnectCategory | "all") => void;
  className?: string;
  /** Show icons in pills */
  showIcons?: boolean;
  /** Compact mode for smaller pills */
  compact?: boolean;
}

/**
 * CategoryFilter - Horizontal scrolling category pill buttons
 * Pinterest-inspired design with smooth selection animation
 */
export function CategoryFilter({
  selectedCategory,
  onCategoryChange,
  className,
  showIcons = false,
  compact = false,
}: CategoryFilterProps) {
  return (
    <div className={cn("w-full", className)}>
      <div className="flex justify-center gap-2 flex-wrap">
        {categories.map((cat) => {
          const isActive = selectedCategory === cat.id;
          const Icon = cat.icon;

          return (
            <motion.button
              key={cat.id}
              onClick={() => onCategoryChange(cat.id)}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className={cn(
                "relative flex items-center gap-2 rounded-full font-medium transition-all border",
                compact ? "px-3 py-1.5 text-xs" : "px-4 py-2.5 text-sm",
                isActive
                  ? "bg-foreground text-background border-foreground shadow-md"
                  : "bg-muted/50 text-foreground/70 border-border/50 hover:bg-muted hover:text-foreground hover:border-border"
              )}
            >
              {showIcons && (
                <Icon className={cn("shrink-0", compact ? "h-3.5 w-3.5" : "h-4 w-4")} />
              )}
              <span>{cat.label}</span>

              {/* Selection indicator animation */}
              {isActive && (
                <motion.div
                  layoutId="category-pill-indicator"
                  className="absolute inset-0 rounded-full bg-foreground -z-10"
                  transition={{ type: "spring", stiffness: 500, damping: 30 }}
                />
              )}
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}

/**
 * CategoryFilterScrollable - Horizontally scrollable version for mobile
 */
export function CategoryFilterScrollable({
  selectedCategory,
  onCategoryChange,
  className,
  showIcons = true,
}: CategoryFilterProps) {
  return (
    <div className={cn("w-full overflow-x-auto scrollbar-hide", className)}>
      <div className="flex gap-2 px-4 md:px-0 md:justify-center min-w-max md:min-w-0 md:flex-wrap">
        {categories.map((cat) => {
          const isActive = selectedCategory === cat.id;
          const Icon = cat.icon;

          return (
            <motion.button
              key={cat.id}
              onClick={() => onCategoryChange(cat.id)}
              whileTap={{ scale: 0.95 }}
              className={cn(
                "flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all border",
                isActive
                  ? "bg-foreground text-background border-foreground"
                  : "bg-card text-foreground/70 border-border/50 hover:bg-muted hover:text-foreground"
              )}
            >
              {showIcons && <Icon className="h-4 w-4 shrink-0" />}
              <span>{cat.label}</span>
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}

export default CategoryFilter;
