"use client";

import { motion } from "framer-motion";
import { Inbox, Bell, User, UserCog, Search, RefreshCw, CheckCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface MessagesHeaderProps {
  totalConversations: number;
  unreadMessages: number;
  clientChats: number;
  expertChats: number;
  onRefresh: () => void;
  onMarkAllRead: () => void;
  onSearch: (query: string) => void;
}

export function MessagesHeader({
  totalConversations,
  unreadMessages,
  clientChats,
  expertChats,
  onRefresh,
  onMarkAllRead,
  onSearch,
}: MessagesHeaderProps) {
  const stats = [
    {
      icon: Inbox,
      label: "Total",
      value: totalConversations,
      color: "text-blue-600",
      bgColor: "bg-blue-50",
    },
    {
      icon: Bell,
      label: "Unread",
      value: unreadMessages,
      color: "text-orange-600",
      bgColor: "bg-orange-50",
    },
    {
      icon: User,
      label: "Clients",
      value: clientChats,
      color: "text-green-600",
      bgColor: "bg-green-50",
    },
    {
      icon: UserCog,
      label: "Experts",
      value: expertChats,
      color: "text-purple-600",
      bgColor: "bg-purple-50",
    },
  ];

  return (
    <div className="relative h-[100px] overflow-hidden border-b border-neutral-200 bg-white">
      {/* Background decorative elements */}
      <div className="absolute inset-0 bg-gradient-to-br from-orange-50/30 via-white to-blue-50/30" />
      <div className="absolute -right-20 -top-20 h-40 w-40 rounded-full bg-orange-500/5 blur-3xl" />
      <div className="absolute -left-20 -bottom-20 h-40 w-40 rounded-full bg-blue-500/5 blur-3xl" />

      {/* Content */}
      <div className="relative flex h-full items-center justify-between gap-6 px-6">
        {/* Left section: Title + Badge */}
        <div className="flex items-center gap-3">
          <h1 className="text-3xl font-bold text-neutral-900">Messages</h1>
          {unreadMessages > 0 && (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="flex h-6 min-w-6 items-center justify-center rounded-full bg-orange-500 px-2 text-xs font-semibold text-white"
            >
              {unreadMessages > 99 ? "99+" : unreadMessages}
            </motion.div>
          )}
        </div>

        {/* Center section: Search */}
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-neutral-400" />
          <Input
            type="text"
            placeholder="Search conversations..."
            className="pl-10 focus-visible:ring-orange-500"
            onChange={(e) => onSearch(e.target.value)}
          />
        </div>

        {/* Right section: Stats + Actions */}
        <div className="flex items-center gap-3">
          {/* Stats pills */}
          <div className="flex items-center gap-2">
            {stats.map((stat, index) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                className="flex items-center gap-2 rounded-xl border border-neutral-200 bg-white px-3 py-2 shadow-sm"
              >
                <div className={`rounded-lg ${stat.bgColor} p-1.5`}>
                  <stat.icon className={`h-4 w-4 ${stat.color}`} />
                </div>
                <div className="flex flex-col">
                  <span className="text-xs text-neutral-500">{stat.label}</span>
                  <span className="text-sm font-semibold text-neutral-900">
                    {stat.value}
                  </span>
                </div>
              </motion.div>
            ))}
          </div>

          {/* Action buttons */}
          <div className="flex items-center gap-2 border-l border-neutral-200 pl-3">
            <Button
              variant="outline"
              size="sm"
              onClick={onRefresh}
              className="h-9"
            >
              <RefreshCw className="mr-2 h-4 w-4" />
              Refresh
            </Button>

            {unreadMessages > 0 && (
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
              >
                <Button
                  variant="outline"
                  size="sm"
                  onClick={onMarkAllRead}
                  className="h-9 border-orange-200 bg-orange-50 text-orange-600 hover:bg-orange-100 hover:text-orange-700"
                >
                  <CheckCheck className="mr-2 h-4 w-4" />
                  Mark All Read
                </Button>
              </motion.div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
