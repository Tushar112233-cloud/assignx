"use client";

import { motion } from "framer-motion";
import { MessageSquare, Bell, User, UserCog, Users, LucideIcon } from "lucide-react";

export type CategoryTab = "all" | "unread" | "clients" | "experts" | "groups";

interface CategoryStats {
  unread: number;
  clientChats: number;
  expertChats: number;
  groupChats: number;
}

interface CategoryCardsProps {
  activeTab: CategoryTab;
  onTabChange: (tab: CategoryTab) => void;
  stats: CategoryStats;
}

interface CategoryCard {
  id: CategoryTab;
  label: string;
  icon: LucideIcon;
  count?: number;
}

export function CategoryCards({ activeTab, onTabChange, stats }: CategoryCardsProps) {
  const categories: CategoryCard[] = [
    {
      id: "all",
      label: "All Messages",
      icon: MessageSquare,
    },
    {
      id: "unread",
      label: "Unread",
      icon: Bell,
      count: stats.unread,
    },
    {
      id: "clients",
      label: "Client Chats",
      icon: User,
      count: stats.clientChats,
    },
    {
      id: "experts",
      label: "Expert Chats",
      icon: UserCog,
      count: stats.expertChats,
    },
    {
      id: "groups",
      label: "Group Chats",
      icon: Users,
      count: stats.groupChats,
    },
  ];

  return (
    <div className="w-full overflow-x-auto scrollbar-hide">
      <div className="flex gap-3 md:grid md:grid-cols-5 md:gap-4 min-w-max md:min-w-0 pb-2 md:pb-0">
        {categories.map((category) => {
          const isActive = activeTab === category.id;
          const Icon = category.icon;

          return (
            <motion.button
              key={category.id}
              onClick={() => onTabChange(category.id)}
              className={`
                relative flex items-center gap-3 px-4 py-3 rounded-lg border transition-all duration-200
                ${
                  isActive
                    ? "bg-[#1C1C1C] text-white border-[#1C1C1C]"
                    : "bg-white text-gray-700 border-gray-200 hover:border-gray-300 hover:shadow-sm"
                }
              `}
              whileHover={{ scale: isActive ? 1 : 1.02 }}
              whileTap={{ scale: 0.98 }}
              transition={{ duration: 0.15 }}
            >
              {/* Orange left border for active card */}
              {isActive && (
                <motion.div
                  className="absolute left-0 top-0 bottom-0 w-1 bg-orange-500 rounded-l-lg"
                  layoutId="activeIndicator"
                  transition={{ type: "spring", stiffness: 300, damping: 30 }}
                />
              )}

              {/* Icon */}
              <div className={`flex-shrink-0 ${isActive ? "text-orange-500" : "text-gray-500"}`}>
                <Icon className="w-5 h-5" />
              </div>

              {/* Label */}
              <span className={`text-sm font-medium whitespace-nowrap ${isActive ? "text-white" : "text-gray-700"}`}>
                {category.label}
              </span>

              {/* Count badge */}
              {category.count !== undefined && category.count > 0 && (
                <motion.span
                  className={`
                    ml-auto flex-shrink-0 px-2 py-0.5 rounded-full text-xs font-semibold
                    ${
                      isActive
                        ? "bg-orange-500 text-white"
                        : "bg-gray-100 text-gray-700"
                    }
                  `}
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ duration: 0.2 }}
                >
                  {category.count > 99 ? "99+" : category.count}
                </motion.span>
              )}
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}
