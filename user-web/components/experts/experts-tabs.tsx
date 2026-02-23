"use client";

/**
 * ExpertsTabs - Premium tab navigation matching projects-pro design
 * Features glassmorphic container and animated indicator
 */

import { motion } from "framer-motion";
import { Stethoscope, GraduationCap, CalendarCheck } from "lucide-react";
import { cn } from "@/lib/utils";

export type ExpertsTabType = "doctors" | "all" | "bookings";

interface ExpertsTabsProps {
  activeTab: ExpertsTabType;
  onTabChange: (tab: ExpertsTabType) => void;
  bookingsCount?: number;
  className?: string;
}

/**
 * Tab configuration
 */
const TABS = [
  {
    id: "doctors" as const,
    label: "Doctors",
    icon: Stethoscope,
  },
  {
    id: "all" as const,
    label: "All Experts",
    icon: GraduationCap,
  },
  {
    id: "bookings" as const,
    label: "My Bookings",
    icon: CalendarCheck,
  },
];

/**
 * ExpertsTabs component - matching projects-pro tabs
 */
export function ExpertsTabs({
  activeTab,
  onTabChange,
  bookingsCount = 0,
  className,
}: ExpertsTabsProps) {
  return (
    <div className={cn("w-full", className)}>
      <div className="flex justify-center">
        {/* Glassmorphic container matching projects-pro */}
        <div className="inline-flex items-center gap-1 p-1.5 bg-white/60 dark:bg-white/5 backdrop-blur-xl rounded-2xl border border-white/50 dark:border-white/10">
          {TABS.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            const showBadge = tab.id === "bookings" && bookingsCount > 0;

            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={cn(
                  "relative flex items-center gap-2 px-4 py-2.5 text-sm font-medium rounded-xl transition-all duration-200",
                  isActive
                    ? "bg-foreground text-background shadow-lg"
                    : "text-muted-foreground hover:text-foreground hover:bg-white/50 dark:hover:bg-white/10"
                )}
              >
                <Icon className="h-4 w-4" />
                <span className="hidden sm:inline">{tab.label}</span>

                {/* Badge */}
                {showBadge && (
                  <span
                    className={cn(
                      "flex items-center justify-center min-w-[20px] h-5 px-1.5 rounded-full text-xs font-bold tabular-nums",
                      isActive
                        ? "bg-background/20 text-background"
                        : "bg-muted text-muted-foreground"
                    )}
                  >
                    {bookingsCount > 9 ? "9+" : bookingsCount}
                  </span>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default ExpertsTabs;
