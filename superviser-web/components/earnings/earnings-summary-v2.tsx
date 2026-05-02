/**
 * @fileoverview Earnings summary cards component matching dashboard design system.
 * @module components/earnings/earnings-summary-v2
 */

"use client"

import { Card, CardContent } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Wallet,
  Clock,
  TrendingUp,
  Calendar,
  LucideIcon,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { useWallet, useEarningsStats } from "@/hooks/use-wallet"
import { motion } from "framer-motion"

interface StatCard {
  title: string
  value: string | number
  description: string
  icon: LucideIcon
  iconBg: string
  iconColor: string
  trend?: {
    value: number
    isPositive: boolean
  }
}

interface EarningsSummaryV2Props {
  className?: string
}

export function EarningsSummaryV2({ className }: EarningsSummaryV2Props) {
  const { wallet, isLoading: walletLoading } = useWallet()
  const { stats, isLoading: statsLoading } = useEarningsStats()

  const isLoading = walletLoading || statsLoading

  // Calculate available balance (balance - pending payouts)
  const availableBalance = (wallet?.balance || 0) - (stats?.pendingPayouts || 0)
  const pendingEarnings = stats?.pendingPayouts || 0
  const totalEarnings = stats?.allTime || 0
  const thisMonthEarnings = stats?.thisMonth || 0
  const monthlyGrowth = stats?.monthlyGrowth || 0

  const earningsStats: StatCard[] = [
    {
      title: "Available Balance",
      value: `₹${availableBalance.toLocaleString("en-IN")}`,
      description: "Ready to withdraw",
      icon: Wallet,
      iconBg: "bg-orange-500/20",
      iconColor: "text-orange-600",
    },
    {
      title: "Pending Earnings",
      value: `₹${pendingEarnings.toLocaleString("en-IN")}`,
      description: "In processing",
      icon: Clock,
      iconBg: "bg-amber-500/20",
      iconColor: "text-amber-600",
    },
    {
      title: "Total Earnings",
      value: `₹${totalEarnings.toLocaleString("en-IN")}`,
      description: "All time",
      icon: TrendingUp,
      iconBg: "bg-blue-500/20",
      iconColor: "text-blue-600",
    },
    {
      title: "This Month",
      value: `₹${thisMonthEarnings.toLocaleString("en-IN")}`,
      description: monthlyGrowth !== 0 ? `${monthlyGrowth > 0 ? "+" : ""}${monthlyGrowth}% from last month` : "Current month",
      icon: Calendar,
      iconBg: "bg-violet-500/20",
      iconColor: "text-violet-600",
      trend: monthlyGrowth !== 0 ? {
        value: Math.abs(monthlyGrowth),
        isPositive: monthlyGrowth > 0
      } : undefined,
    },
  ]

  if (isLoading) {
    return (
      <div className={cn("grid grid-cols-2 lg:grid-cols-4 gap-3", className)}>
        {[1, 2, 3, 4].map((i) => (
          <Card key={i} className="rounded-2xl border border-gray-200 bg-white">
            <CardContent className="p-6">
              <div className="flex items-start justify-between">
                <div className="space-y-3 flex-1">
                  <Skeleton className="h-3 w-24" />
                  <Skeleton className="h-8 w-20" />
                  <Skeleton className="h-3 w-28" />
                </div>
                <Skeleton className="h-12 w-12 rounded-xl" />
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <div className={cn("grid grid-cols-2 lg:grid-cols-4 gap-3", className)}>
      {earningsStats.map((stat, index) => (
        <motion.div
          key={stat.title}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{
            duration: 0.4,
            delay: index * 0.1,
            ease: [0.21, 0.47, 0.32, 0.98]
          }}
        >
          <Card
            className={cn(
              "rounded-2xl border border-gray-200 bg-white",
              "transition-all duration-300",
              "hover:shadow-md hover:-translate-y-0.5"
            )}
          >
            <CardContent className="p-6">
              <div className="flex items-start justify-between">
                <div className="space-y-2 flex-1">
                  <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">
                    {stat.title}
                  </p>
                  <div className="flex items-baseline gap-2">
                    <span className="text-3xl font-bold tracking-tight text-gray-900">
                      {stat.value}
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    {stat.trend && (
                      <span
                        className={cn(
                          "inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-md",
                          stat.trend.isPositive
                            ? "text-green-700 bg-green-50"
                            : "text-red-700 bg-red-50"
                        )}
                      >
                        <TrendingUp
                          className={cn(
                            "h-3 w-3",
                            !stat.trend.isPositive && "rotate-180"
                          )}
                        />
                        {stat.trend.value}%
                      </span>
                    )}
                    <span className="text-xs text-gray-500">
                      {stat.description}
                    </span>
                  </div>
                </div>

                <div
                  className={cn(
                    "h-12 w-12 rounded-xl flex items-center justify-center",
                    "transition-transform duration-300 hover:scale-110",
                    stat.iconBg
                  )}
                >
                  <stat.icon className={cn("h-6 w-6", stat.iconColor)} />
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      ))}
    </div>
  )
}
