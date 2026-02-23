/**
 * @fileoverview Chat list page - redesigned landing layout
 * @module app/(dashboard)/chat/page
 */

"use client"

import { useMemo, useState } from "react"
import { motion } from "framer-motion"
import {
  AlertCircle,
  ArrowRight,
  Bell,
  MessageSquare,
  RefreshCw,
  Search,
  User,
  UserCog,
  Users,
} from "lucide-react"

import { useAuth, useChatRooms, useUnreadMessages } from "@/hooks"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { CategoryTabs, type CategoryTab } from "@/components/chat/category-tabs"
import { ConversationsTimeline } from "@/components/chat/conversations-timeline"
import { MessagesQuickActions } from "@/components/chat/messages-quick-actions"
import { MessagesEmptyState } from "@/components/chat/messages-empty-state"

export type MessageFilter =
  | "all"
  | "unread"
  | "project_user_supervisor"
  | "project_supervisor_doer"
  | "project_all"

export default function ChatPage() {
  const [searchQuery, setSearchQuery] = useState("")
  const [activeTab, setActiveTab] = useState<MessageFilter>("all")

  const { user, isLoading: authLoading } = useAuth()
  const { rooms, isLoading, refetch, error } = useChatRooms()
  const { unreadByRoom, markAllAsRead } = useUnreadMessages()

  const stats = useMemo(() => {
    const totalConversations = rooms.length
    const unreadMessages = Object.values(unreadByRoom).reduce((sum, count) => sum + count, 0)
    const clientChats = rooms.filter((room) => room.room_type === "project_user_supervisor").length
    const expertChats = rooms.filter((room) => room.room_type === "project_supervisor_doer").length
    const groupChats = rooms.filter((room) => room.room_type === "project_all").length

    return {
      totalConversations,
      unreadMessages,
      clientChats,
      expertChats,
      groupChats,
    }
  }, [rooms, unreadByRoom])

  const firstName = user?.full_name?.split(" ")[0] ?? (authLoading ? "" : "there")
  const heroSubtitle = stats.unreadMessages === 0
    ? "All caught up. Your inbox is clear and calm."
    : stats.unreadMessages === 1
      ? "You have 1 unread message waiting for you."
      : `You have ${stats.unreadMessages} unread messages waiting for you.`

  const heroStats = useMemo(
    () => [
      {
        label: "Total Conversations",
        value: stats.totalConversations,
        icon: MessageSquare,
        tone: "bg-orange-50 text-orange-600",
      },
      {
        label: "Unread",
        value: stats.unreadMessages,
        icon: Bell,
        tone: "bg-amber-50 text-amber-600",
      },
      {
        label: "Client Chats",
        value: stats.clientChats,
        icon: User,
        tone: "bg-blue-50 text-blue-600",
      },
      {
        label: "Expert Chats",
        value: stats.expertChats,
        icon: UserCog,
        tone: "bg-emerald-50 text-emerald-600",
      },
      {
        label: "Group Rooms",
        value: stats.groupChats,
        icon: Users,
        tone: "bg-purple-50 text-purple-600",
        wide: true,
      },
    ],
    [stats]
  )

  const filteredRooms = useMemo(() => {
    let filtered = rooms

    if (activeTab === "unread") {
      filtered = filtered.filter((room) => (unreadByRoom[room.id] || 0) > 0)
    } else if (activeTab === "project_user_supervisor") {
      filtered = filtered.filter((room) => room.room_type === "project_user_supervisor")
    } else if (activeTab === "project_supervisor_doer") {
      filtered = filtered.filter((room) => room.room_type === "project_supervisor_doer")
    } else if (activeTab === "project_all") {
      filtered = filtered.filter((room) => room.room_type === "project_all")
    }

    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter((room) => {
        const projectTitle = room.projects?.title?.toLowerCase() || ""
        const projectNumber = room.projects?.project_number
          ? String(room.projects.project_number).toLowerCase()
          : ""
        const participants =
          room.chat_participants
            ?.map((p) => p.profiles?.full_name?.toLowerCase() || "")
            .join(" ") || ""

        return (
          projectTitle.includes(query) ||
          projectNumber.includes(query) ||
          participants.includes(query)
        )
      })
    }

    return filtered
  }, [rooms, activeTab, searchQuery, unreadByRoom])

  const handleFilterUnread = () => {
    setActiveTab("unread")
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-8">
        <div className="rounded-2xl border border-gray-200 bg-white p-8 text-center max-w-md">
          <AlertCircle className="h-10 w-10 text-red-500 mx-auto" />
          <h2 className="text-lg font-semibold text-[#1C1C1C] mt-4">Unable to load messages</h2>
          <p className="text-sm text-gray-500 mt-2">{error.message}</p>
          <Button
            onClick={refetch}
            className="mt-6 bg-[#F97316] hover:bg-[#EA580C] text-white"
          >
            <RefreshCw className="mr-2 h-4 w-4" />
            Try again
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="relative">
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute -top-24 right-8 h-56 w-56 rounded-full bg-orange-100/60 blur-3xl" />
          <div className="absolute top-32 left-8 h-48 w-48 rounded-full bg-amber-100/50 blur-3xl" />
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.3 }}
          className="relative max-w-[1400px] mx-auto p-8 lg:p-10"
        >
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: 0.1 }}
            className="relative overflow-hidden rounded-3xl border border-gray-200 bg-white p-8 lg:p-10 mb-10"
          >
            <div className="pointer-events-none absolute -top-16 right-0 h-44 w-44 rounded-full bg-orange-100/50 blur-3xl" />
            <div className="pointer-events-none absolute bottom-0 left-6 h-32 w-32 rounded-full bg-amber-100/40 blur-3xl" />

            <div className="grid gap-8 lg:grid-cols-[1.05fr_0.95fr] items-start">
              <div className="space-y-6">
                <div className="inline-flex items-center gap-2 rounded-full border border-gray-200 bg-white px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-gray-600">
                  Inbox Studio
                </div>

                <div>
                  <h1 className="text-4xl lg:text-5xl font-bold text-[#1C1C1C] tracking-tight">
                    Messages, {firstName}
                  </h1>
                  <p className="text-lg text-gray-600 mt-2">
                    {heroSubtitle}
                  </p>
                </div>

                <div className="flex flex-wrap gap-3">
                  <Button
                    onClick={handleFilterUnread}
                    className="bg-[#F97316] hover:bg-[#EA580C] text-white rounded-full px-6 h-11 font-medium shadow-lg shadow-orange-500/20 hover:shadow-xl hover:shadow-orange-500/30 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200"
                  >
                    View Unread
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                  <Button
                    variant="outline"
                    onClick={() => setActiveTab("all")}
                    className="rounded-full px-6 h-11 border-gray-200 text-gray-700 hover:bg-gray-100"
                  >
                    All Messages
                  </Button>
                  <Button
                    variant="outline"
                    onClick={markAllAsRead}
                    disabled={stats.unreadMessages === 0}
                    className="rounded-full px-6 h-11 border-gray-200 text-gray-700 hover:bg-gray-100"
                  >
                    Mark All Read
                  </Button>
                </div>

                <div className="flex flex-wrap items-center gap-2 text-xs text-gray-500">
                  <span className="px-3 py-1 rounded-full bg-gray-100">
                    Total {stats.totalConversations}
                  </span>
                  <span className="px-3 py-1 rounded-full bg-orange-50 text-orange-700">
                    Unread {stats.unreadMessages}
                  </span>
                  <span className="px-3 py-1 rounded-full bg-blue-50 text-blue-700">
                    Clients {stats.clientChats}
                  </span>
                  <span className="px-3 py-1 rounded-full bg-emerald-50 text-emerald-700">
                    Experts {stats.expertChats}
                  </span>
                  <span className="px-3 py-1 rounded-full bg-purple-50 text-purple-700">
                    Groups {stats.groupChats}
                  </span>
                </div>
              </div>

              <div className="grid gap-4">
                <div className="rounded-2xl border border-gray-200 bg-white p-5">
                  <div className="flex items-center justify-between">
                    <h3 className="text-sm font-semibold text-[#1C1C1C]">Inbox Pulse</h3>
                    <span className="text-xs text-gray-400">Live counts</span>
                  </div>
                  <div className="mt-4 grid grid-cols-2 gap-3">
                    {heroStats.map((stat) => {
                      const Icon = stat.icon
                      return (
                        <div
                          key={stat.label}
                          className={`rounded-xl border border-gray-100 bg-gray-50 p-3 ${
                            stat.wide ? "col-span-2" : ""
                          }`}
                        >
                          <div className="flex items-center justify-between">
                            <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">
                              {stat.label}
                            </p>
                            <div
                              className={`h-8 w-8 rounded-lg flex items-center justify-center ${
                                stat.tone
                              }`}
                            >
                              <Icon className="h-4 w-4" />
                            </div>
                          </div>
                          <p className="text-xl font-bold text-[#1C1C1C] mt-2">{stat.value}</p>
                        </div>
                      )
                    })}
                  </div>
                </div>

              </div>
            </div>
          </motion.section>

          <motion.section
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.2 }}
            className="rounded-2xl border border-gray-200 bg-white p-4 mb-8"
          >
            <div className="flex flex-col lg:flex-row items-start lg:items-center gap-4">
              <div className="relative w-full lg:max-w-md">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
                <Input
                  type="text"
                  placeholder="Search conversations..."
                  value={searchQuery}
                  className="pl-10 rounded-xl border-gray-200 focus-visible:ring-orange-500"
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>

              <CategoryTabs
                activeTab={activeTab as CategoryTab}
                onTabChange={(tab) => setActiveTab(tab as MessageFilter)}
                stats={{
                  unread: stats.unreadMessages,
                  clientChats: stats.clientChats,
                  expertChats: stats.expertChats,
                  groupChats: stats.groupChats,
                }}
              />
            </div>
          </motion.section>

          <motion.section
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.25 }}
            className="grid grid-cols-1 lg:grid-cols-[1fr_320px] gap-6"
          >
            <div className="min-w-0">
              {filteredRooms.length > 0 ? (
                <ConversationsTimeline
                  rooms={filteredRooms}
                  unreadCounts={unreadByRoom}
                  isLoading={isLoading}
                />
              ) : (
                <div className="bg-white rounded-2xl border border-gray-200 p-8">
                  <MessagesEmptyState
                    searchQuery={searchQuery.trim() ? searchQuery : undefined}
                    activeFilter={activeTab !== "all" ? activeTab : undefined}
                  />
                </div>
              )}
            </div>

            <div className="hidden lg:block">
              <div className="sticky top-24 rounded-2xl border border-gray-200 bg-white p-4">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                    Quick Actions
                  </h3>
                  <span className="text-xs text-gray-400">Inbox tools</span>
                </div>
                <MessagesQuickActions
                  unreadCount={stats.unreadMessages}
                  onMarkAllRead={markAllAsRead}
                  onRefresh={refetch}
                  onFilterUnread={handleFilterUnread}
                />
              </div>
            </div>
          </motion.section>
        </motion.div>
      </div>
    </div>
  )
}
