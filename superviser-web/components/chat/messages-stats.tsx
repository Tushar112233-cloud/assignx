"use client"

import { motion } from "framer-motion"
import { Inbox, Bell, User, UserCog } from "lucide-react"
import Link from "next/link"
import { cn } from "@/lib/utils"

interface MessagesStatsProps {
  totalConversations: number
  unreadMessages: number
  clientChats: number
  expertChats: number
}

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 10 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.3 },
  },
}

export function MessagesStats({
  totalConversations,
  unreadMessages,
  clientChats,
  expertChats,
}: MessagesStatsProps) {
  const statsItems = [
    {
      label: "Total Conversations",
      value: totalConversations,
      icon: Inbox,
      href: "/messages",
    },
    {
      label: "Unread",
      value: unreadMessages,
      icon: Bell,
      href: "/messages?filter=unread",
    },
    {
      label: "Client Chats",
      value: clientChats,
      icon: User,
      href: "/messages?filter=clients",
    },
    {
      label: "Expert Chats",
      value: expertChats,
      icon: UserCog,
      href: "/messages?filter=experts",
    },
  ]

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className="grid grid-cols-2 lg:grid-cols-4 gap-3"
    >
      {statsItems.map((item) => (
        <Link key={item.label} href={item.href}>
          <motion.div
            variants={itemVariants}
            className={cn(
              "group flex items-center gap-3 p-4 rounded-2xl border transition-all duration-300",
              "bg-white border-gray-200 hover:border-gray-300 hover:shadow-md"
            )}
          >
            <div
              className={cn(
                "w-10 h-10 rounded-xl flex items-center justify-center transition-colors",
                "bg-gray-100 group-hover:bg-orange-100"
              )}
            >
              <item.icon
                className={cn(
                  "h-5 w-5",
                  "text-gray-600 group-hover:text-orange-600"
                )}
              />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs font-medium text-gray-500">{item.label}</p>
              <p className="text-lg font-bold text-[#1C1C1C]">{item.value}</p>
            </div>
          </motion.div>
        </Link>
      ))}
    </motion.div>
  )
}
