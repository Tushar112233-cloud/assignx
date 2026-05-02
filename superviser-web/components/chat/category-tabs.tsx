"use client";

import { motion, AnimatePresence } from "framer-motion";
import { MessageSquare, Bell, User, UserCog, Users, LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

export type CategoryTab = "all" | "unread" | "project_user_supervisor" | "project_supervisor_doer" | "project_all";

interface CategoryStats {
  unread: number;
  clientChats: number;
  expertChats: number;
  groupChats: number;
}

interface CategoryTabsProps {
  activeTab: CategoryTab;
  onTabChange: (tab: CategoryTab) => void;
  stats: CategoryStats;
}

interface TabConfig {
  id: CategoryTab;
  label: string;
  icon: LucideIcon;
  countKey?: keyof CategoryStats;
}

const tabs: TabConfig[] = [
  {
    id: "all",
    label: "All Messages",
    icon: MessageSquare,
  },
  {
    id: "unread",
    label: "Unread",
    icon: Bell,
    countKey: "unread",
  },
  {
    id: "project_user_supervisor",
    label: "Clients",
    icon: User,
    countKey: "clientChats",
  },
  {
    id: "project_supervisor_doer",
    label: "Experts",
    icon: UserCog,
    countKey: "expertChats",
  },
  {
    id: "project_all",
    label: "Groups",
    icon: Users,
    countKey: "groupChats",
  },
];

export function CategoryTabs({ activeTab, onTabChange, stats }: CategoryTabsProps) {
  return (
    <div className="w-full overflow-x-auto scrollbar-hide">
      <div className="flex items-center gap-2 p-1 bg-gray-100 rounded-2xl min-w-max">
        {tabs.map((tab) => {
          const isActive = activeTab === tab.id;
          const Icon = tab.icon;
          const count = tab.countKey ? stats[tab.countKey] : undefined;

          return (
            <motion.button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={cn(
                "relative flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200",
                isActive
                  ? "bg-white text-[#1C1C1C] shadow-sm"
                  : "text-gray-600 hover:text-gray-900 hover:bg-white/60"
              )}
              whileHover={{ scale: isActive ? 1 : 1.02 }}
              whileTap={{ scale: 0.98 }}
              transition={{ duration: 0.15 }}
            >
              {/* Orange left border indicator for active tab */}
              <AnimatePresence>
                {isActive && (
                  <motion.div
                    className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-[#F97316] rounded-l-xl"
                    layoutId="activeTabIndicator"
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.8 }}
                    transition={{ type: "spring", stiffness: 300, damping: 30 }}
                  />
                )}
              </AnimatePresence>

              {/* Icon */}
              <Icon
                className={cn(
                  "w-4 h-4 transition-colors duration-200",
                  isActive ? "text-[#F97316]" : "text-gray-500"
                )}
              />

              {/* Label */}
              <span className="whitespace-nowrap">{tab.label}</span>

              {/* Count badge */}
              {count !== undefined && count > 0 && (
                <motion.span
                  className={cn(
                    "ml-2 px-2 py-0.5 rounded-full text-xs font-semibold transition-colors duration-200",
                    isActive
                      ? "bg-[#F97316] text-white"
                      : "bg-gray-200 text-gray-600"
                  )}
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ duration: 0.2 }}
                >
                  {count > 99 ? "99+" : count}
                </motion.span>
              )}
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}
