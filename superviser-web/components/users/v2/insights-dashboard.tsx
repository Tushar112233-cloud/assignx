"use client"

import { motion } from "framer-motion"
import { TrendingUp, Award } from "lucide-react"
import { UserGrowthChart } from "./user-growth-chart"
import { TopClientsLeaderboard } from "./top-clients-leaderboard"

interface DataPoint {
  month: string
  value: number
}

interface Client {
  id: string
  name: string
  avatar?: string | null
  revenue: number
  rank: number
}

interface InsightsDashboardProps {
  growthData: DataPoint[]
  topClients: Client[]
  growthPercentage?: number
}

const cardVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: "easeOut" as const,
    },
  },
}

export function InsightsDashboard({
  growthData,
  topClients,
  growthPercentage = 0,
}: InsightsDashboardProps) {
  return (
    <motion.div
      className="grid grid-cols-1 lg:grid-cols-2 gap-6"
      initial="hidden"
      animate="visible"
      variants={{
        visible: {
          transition: {
            staggerChildren: 0.15,
          },
        },
      }}
    >
      {/* User Growth Chart Card */}
      <motion.div
        variants={cardVariants}
        className="bg-white rounded-2xl border border-gray-200 p-6 hover:shadow-lg transition-shadow duration-300"
      >
        {/* Card Header */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-orange-600" />
              User Growth
            </h3>
            <p className="text-sm text-gray-500 mt-1">Client acquisition trend over 6 months</p>
          </div>
          {growthPercentage !== 0 && (
            <div
              className={`flex items-center gap-1 px-3 py-1.5 rounded-full text-sm font-semibold ${
                growthPercentage > 0
                  ? "bg-emerald-50 text-emerald-600"
                  : "bg-red-50 text-red-600"
              }`}
            >
              <TrendingUp className={`h-4 w-4 ${growthPercentage < 0 ? "rotate-180" : ""}`} />
              {growthPercentage > 0 ? "+" : ""}
              {growthPercentage}%
            </div>
          )}
        </div>

        {/* Chart */}
        <div className="mt-4">
          <UserGrowthChart data={growthData} />
        </div>

        {/* Chart Footer Stats */}
        <div className="flex items-center justify-between mt-6 pt-4 border-t border-gray-100">
          <div>
            <p className="text-2xl font-bold text-gray-900">
              {growthData[growthData.length - 1]?.value || 0}
            </p>
            <p className="text-xs text-gray-500 mt-0.5">Current Month</p>
          </div>
          <div>
            <p className="text-2xl font-bold text-gray-900">
              {growthData[0]?.value || 0}
            </p>
            <p className="text-xs text-gray-500 mt-0.5">6 Months Ago</p>
          </div>
          <div>
            <p className="text-2xl font-bold text-orange-600">
              {growthData.reduce((sum, point) => sum + point.value, 0)}
            </p>
            <p className="text-xs text-gray-500 mt-0.5">Total Growth</p>
          </div>
        </div>
      </motion.div>

      {/* Top Clients Leaderboard Card */}
      <motion.div
        variants={cardVariants}
        className="bg-white rounded-2xl border border-gray-200 p-6 hover:shadow-lg transition-shadow duration-300"
      >
        {/* Card Header */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
            <Award className="h-5 w-5 text-orange-600" />
            Top Clients
          </h3>
          <p className="text-sm text-gray-500 mt-1">Highest revenue contributors</p>
        </div>

        {/* Leaderboard */}
        <TopClientsLeaderboard clients={topClients} />

        {/* Card Footer */}
        {topClients.length > 0 && (
          <div className="mt-6 pt-4 border-t border-gray-100">
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600">Total Revenue (Top 5)</span>
              <span className="font-bold text-gray-900">
                ₹
                {topClients
                  .slice(0, 5)
                  .reduce((sum, client) => sum + client.revenue, 0)
                  .toLocaleString("en-IN")}
              </span>
            </div>
          </div>
        )}
      </motion.div>
    </motion.div>
  )
}
