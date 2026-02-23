"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

interface Tab {
  id: string;
  label: string;
  count?: number;
  badgeColor?: string;
}

interface AnimatedTabsProps {
  tabs: Tab[];
  activeTab: string;
  onTabChange: (tabId: string) => void;
  layoutId?: string;
}

export function AnimatedTabs({
  tabs,
  activeTab,
  onTabChange,
  layoutId = "activeTabIndicator",
}: AnimatedTabsProps) {
  return (
    <div className="relative border-b border-gray-100 px-2">
      <div className="flex items-center overflow-x-auto scrollbar-hide">
        {tabs.map((tab) => {
          const isActive = activeTab === tab.id;

          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={cn(
                "relative flex items-center gap-1.5 px-4 py-3 text-sm font-medium whitespace-nowrap",
                "transition-colors focus-visible:outline-none",
                isActive ? "text-[var(--color-sage)]" : "text-muted-foreground hover:text-foreground"
              )}
            >
              <span>{tab.label}</span>
              {tab.count !== undefined && tab.count > 0 && (
                <span
                  className={cn(
                    "flex items-center justify-center min-w-[1.25rem] h-5 px-1.5 rounded-full text-xs font-medium",
                    tab.badgeColor || "bg-gray-100 text-gray-600"
                  )}
                >
                  {tab.count}
                </span>
              )}

              {/* Active indicator - sliding animation */}
              {isActive && (
                <motion.div
                  layoutId={layoutId}
                  className="absolute bottom-0 left-0 right-0 h-0.5 rounded-full bg-[var(--color-sage)]"
                  transition={{ type: "spring", stiffness: 500, damping: 30 }}
                />
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}

export default AnimatedTabs;
