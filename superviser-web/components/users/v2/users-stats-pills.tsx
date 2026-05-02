"use client"

import { motion } from "framer-motion"
import { Users, Activity, Wallet, TrendingUp, UserPlus } from "lucide-react"

interface UsersStatsPillsProps {
  totalClients: number
  activeThisMonth: number
  totalRevenue: number
  avgProjectValue: number
  newThisWeek: number
  onPillClick?: (metric: string) => void
  activeKey?: string
}

const statPills = [
  {
    key: "total-clients",
    label: "Total Clients",
    icon: Users,
    getValue: (props: UsersStatsPillsProps) => props.totalClients.toLocaleString(),
  },
  {
    key: "active-month",
    label: "Active This Month",
    icon: Activity,
    getValue: (props: UsersStatsPillsProps) => props.activeThisMonth.toLocaleString(),
  },
  {
    key: "total-revenue",
    label: "Total Revenue",
    icon: Wallet,
    getValue: (props: UsersStatsPillsProps) => `₹${props.totalRevenue.toLocaleString("en-IN")}`,
  },
  {
    key: "avg-project",
    label: "Average Project Value",
    icon: TrendingUp,
    getValue: (props: UsersStatsPillsProps) => `₹${props.avgProjectValue.toLocaleString("en-IN")}`,
  },
  {
    key: "new-week",
    label: "New This Week",
    icon: UserPlus,
    getValue: (props: UsersStatsPillsProps) => props.newThisWeek.toLocaleString(),
  },
]

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const pillVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.4,
      ease: "easeOut" as const,
    },
  },
}

export function UsersStatsPills(props: UsersStatsPillsProps) {
  const { onPillClick, activeKey } = props

  return (
    <motion.div
      className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {statPills.map((stat) => {
        const Icon = stat.icon
        const value = stat.getValue(props)
        const isActive = activeKey === stat.key

        return (
          <motion.button
            key={stat.key}
            variants={pillVariants}
            onClick={() => onPillClick?.(stat.key)}
            className={
              `rounded-2xl p-4 transition-all duration-300 text-left group border ${
                isActive
                  ? "bg-orange-50 border-orange-300 shadow-lg"
                  : "bg-white/90 border-gray-200/80 hover:shadow-lg hover:-translate-y-1 hover:border-orange-300"
              }`
            }
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <div className="flex items-start justify-between mb-3">
              <div className={`p-2.5 rounded-lg transition-colors ${isActive ? "bg-orange-200" : "bg-orange-100 group-hover:bg-orange-200"}`}>
                <Icon className="h-5 w-5 text-orange-600" />
              </div>
            </div>

            <div className="space-y-1">
              <div className="text-2xl font-bold text-[#1C1C1C] tracking-tight">
                {value}
              </div>
              <div className="text-sm text-gray-600 font-medium">
                {stat.label}
              </div>
            </div>
          </motion.button>
        )
      })}
    </motion.div>
  )
}
