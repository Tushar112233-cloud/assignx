"use client"

import { motion } from "framer-motion"
import { Award, TrendingUp } from "lucide-react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

interface Client {
  id: string
  name: string
  avatar?: string | null
  revenue: number
  rank: number
}

interface TopClientsLeaderboardProps {
  clients: Client[]
}

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, x: -20 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      duration: 0.4,
      ease: "easeOut" as const,
    },
  },
}

export function TopClientsLeaderboard({ clients }: TopClientsLeaderboardProps) {
  // Sort clients by rank and take top 5
  const topClients = clients.sort((a, b) => a.rank - b.rank).slice(0, 5)

  const getRankBadge = (rank: number) => {
    switch (rank) {
      case 1:
        return (
          <div className="flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 shadow-lg">
            <Award className="h-4 w-4 text-white" />
          </div>
        )
      case 2:
        return (
          <div className="flex items-center justify-center w-7 h-7 rounded-full bg-gradient-to-br from-gray-300 to-gray-400 shadow-md">
            <Award className="h-3.5 w-3.5 text-white" />
          </div>
        )
      case 3:
        return (
          <div className="flex items-center justify-center w-7 h-7 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 shadow-md">
            <Award className="h-3.5 w-3.5 text-white" />
          </div>
        )
      default:
        return (
          <div className="flex items-center justify-center w-7 h-7 rounded-full bg-gray-100 text-gray-500 font-semibold text-sm">
            {rank}
          </div>
        )
    }
  }

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  return (
    <motion.div
      className="space-y-3"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {topClients.map((client, index) => {
        const isTopThree = client.rank <= 3
        const isFirst = client.rank === 1

        return (
          <motion.div
            key={client.id}
            variants={itemVariants}
            className={`
              flex items-center gap-3 p-3 rounded-xl transition-all duration-300
              ${isFirst ? 'bg-gradient-to-r from-orange-50 to-amber-50 border-2 border-orange-200 shadow-md scale-[1.02]' : ''}
              ${!isFirst && isTopThree ? 'bg-gray-50 border border-gray-200' : ''}
              ${!isTopThree ? 'bg-white border border-gray-100 hover:bg-gray-50' : ''}
              hover:shadow-lg hover:-translate-y-0.5 cursor-pointer
            `}
            whileHover={{ scale: isFirst ? 1.03 : 1.02 }}
            whileTap={{ scale: isFirst ? 1.01 : 0.99 }}
          >
            {/* Rank Badge */}
            <div className="flex-shrink-0">
              {getRankBadge(client.rank)}
            </div>

            {/* Avatar */}
            <Avatar className={`${isFirst ? 'h-12 w-12 ring-2 ring-orange-300' : 'h-10 w-10'}`}>
              <AvatarImage src={client.avatar || undefined} alt={client.name} />
              <AvatarFallback className={`${isFirst ? 'bg-orange-200 text-orange-700 text-sm font-bold' : 'bg-gray-200 text-gray-600 text-xs font-semibold'}`}>
                {getInitials(client.name)}
              </AvatarFallback>
            </Avatar>

            {/* Client Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <p className={`font-semibold truncate ${isFirst ? 'text-gray-900 text-base' : 'text-gray-800 text-sm'}`}>
                  {client.name}
                </p>
                {isTopThree && (
                  <TrendingUp className={`flex-shrink-0 ${isFirst ? 'h-4 w-4 text-orange-600' : 'h-3.5 w-3.5 text-gray-400'}`} />
                )}
              </div>
              <p className={`text-xs ${isFirst ? 'text-gray-600 font-medium' : 'text-gray-500'}`}>
                {client.rank === 1 && "Top Client"}
                {client.rank === 2 && "Runner Up"}
                {client.rank === 3 && "Third Place"}
                {client.rank > 3 && `Rank #${client.rank}`}
              </p>
            </div>

            {/* Revenue */}
            <div className="text-right flex-shrink-0">
              <p className={`font-bold ${isFirst ? 'text-orange-600 text-lg' : 'text-gray-900 text-base'}`}>
                ₹{client.revenue.toLocaleString("en-IN")}
              </p>
              {isFirst && (
                <p className="text-xs text-orange-500 font-medium">Revenue</p>
              )}
            </div>
          </motion.div>
        )
      })}

      {topClients.length === 0 && (
        <div className="text-center py-8">
          <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-3">
            <Award className="h-8 w-8 text-gray-400" />
          </div>
          <p className="text-gray-500 font-medium">No client data yet</p>
          <p className="text-gray-400 text-sm mt-1">Start tracking client revenue</p>
        </div>
      )}
    </motion.div>
  )
}
