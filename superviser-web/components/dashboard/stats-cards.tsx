/**
 * @fileoverview Professional dashboard statistics cards with mini-trends and visual enhancements.
 * @module components/dashboard/stats-cards
 */

"use client"

import { Card, CardContent } from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import {
  FolderKanban,
  Clock,
  CheckCircle2,
  Wallet,
  TrendingUp,
  TrendingDown,
  ArrowUpRight,
  LucideIcon,
} from "lucide-react"
import { cn } from "@/lib/utils"
import Link from "next/link"

interface StatCard {
  title: string
  value: string | number
  description: string
  icon: LucideIcon
  trend?: {
    value: number
    isPositive: boolean
  }
  href?: string
  gradient: string
  iconBg: string
  iconColor: string
}

interface StatsCardsProps {
  activeProjects?: number
  pendingQC?: number
  completedThisMonth?: number
  earningsThisMonth?: number
  isLoading?: boolean
  trends?: {
    activeProjects?: number
    pendingQC?: number
    completed?: number
    earnings?: number
  }
}

export function StatsCards({
  activeProjects = 0,
  pendingQC = 0,
  completedThisMonth = 0,
  earningsThisMonth = 0,
  isLoading = false,
  trends,
}: StatsCardsProps) {
  const stats: StatCard[] = [
    {
      title: "Active Projects",
      value: activeProjects,
      description: "Currently in progress",
      icon: FolderKanban,
      trend: trends?.activeProjects
        ? { value: trends.activeProjects, isPositive: trends.activeProjects > 0 }
        : undefined,
      href: "/projects?tab=ongoing",
      gradient: "from-[#E7F2EF] via-[#F3EBDD] to-transparent",
      iconBg: "bg-[#9FD6CC]/40",
      iconColor: "text-[#0F4C4A]",
    },
    {
      title: "Pending QC",
      value: pendingQC,
      description: "Awaiting your review",
      icon: Clock,
      trend: trends?.pendingQC
        ? { value: Math.abs(trends.pendingQC), isPositive: trends.pendingQC < 0 }
        : undefined,
      href: "/projects?tab=review",
      gradient: "from-[#F4E7D0] via-[#F3EBDD] to-transparent",
      iconBg: "bg-[#C8A96A]/30",
      iconColor: "text-[#7A5A2C]",
    },
    {
      title: "Completed",
      value: completedThisMonth,
      description: "This month",
      icon: CheckCircle2,
      trend: trends?.completed
        ? { value: trends.completed, isPositive: trends.completed > 0 }
        : undefined,
      href: "/projects?tab=completed",
      gradient: "from-[#E7F2EF] via-[#F7F1E8] to-transparent",
      iconBg: "bg-[#9FD6CC]/35",
      iconColor: "text-[#1B6F6A]",
    },
    {
      title: "Earnings",
      value: `₹${earningsThisMonth.toLocaleString("en-IN")}`,
      description: "This month",
      icon: Wallet,
      trend: trends?.earnings
        ? { value: trends.earnings, isPositive: trends.earnings > 0 }
        : undefined,
      href: "/earnings",
      gradient: "from-[#F7E1D6] via-[#F3EBDD] to-transparent",
      iconBg: "bg-[#E48B6A]/20",
      iconColor: "text-[#9A5A41]",
    },
  ]

  if (isLoading) {
    return (
      <div className="grid gap-4 grid-cols-2">
        {[1, 2, 3, 4].map((i) => (
          <Card key={i} className="relative overflow-hidden border border-[#E7DED0] bg-white/90">
            <CardContent className="p-6">
              <div className="flex items-start justify-between">
                <div className="space-y-3 flex-1">
                  <Skeleton className="h-4 w-24" />
                  <Skeleton className="h-9 w-20" />
                  <div className="flex items-center gap-2">
                    <Skeleton className="h-3 w-12" />
                    <Skeleton className="h-3 w-16" />
                  </div>
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
    <div className="grid gap-4 grid-cols-2">
      {stats.map((stat, index) => {
        const cardContent = (
          <Card
              className={cn(
                "relative overflow-hidden border border-[#E7DED0] bg-white/90 transition-all duration-300 group",
                stat.href && "cursor-pointer hover:shadow-[0_12px_24px_-16px_rgba(15,76,74,0.6)] hover:-translate-y-0.5",
                "animate-fade-in-up"
              )}
            style={{ animationDelay: `${index * 0.05}s` }}
          >
              {/* Gradient Background */}
              <div
                className={cn(
                  "absolute inset-0 bg-gradient-to-br opacity-60",
                  stat.gradient
                )}
              />

              <CardContent className="relative p-5">
                <div className="flex items-start justify-between">
                  <div className="space-y-1">
                    <p className="text-xs font-semibold uppercase tracking-[0.12em] text-[#7A8B87]">
                      {stat.title}
                    </p>
                    <div className="flex items-baseline gap-2">
                      <span className="text-3xl font-semibold tracking-tight text-[#122022]">
                        {stat.value}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 pt-1">
                      {stat.trend && (
                        <span
                          className={cn(
                            "inline-flex items-center gap-0.5 text-xs font-medium px-1.5 py-0.5 rounded-md",
                            stat.trend.isPositive
                              ? "text-[#0F4C4A] bg-[#E7F2EF]"
                              : "text-[#8A4C3A] bg-[#F7E1D6]"
                          )}
                        >
                          {stat.trend.isPositive ? (
                            <TrendingUp className="h-3 w-3" />
                          ) : (
                            <TrendingDown className="h-3 w-3" />
                          )}
                          {stat.trend.value}%
                        </span>
                      )}
                      <span className="text-xs text-[#6B7B78]">
                        {stat.description}
                      </span>
                    </div>
                  </div>

                  <div
                    className={cn(
                      "h-12 w-12 rounded-xl flex items-center justify-center transition-transform duration-300",
                      stat.iconBg,
                      stat.href && "group-hover:scale-110"
                    )}
                  >
                    <stat.icon className={cn("h-6 w-6", stat.iconColor)} />
                  </div>
                </div>

                {/* Hover Arrow Indicator */}
                {stat.href && (
                  <div className="absolute bottom-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                    <ArrowUpRight className="h-4 w-4 text-[#8FA3A0]" />
                  </div>
                )}
              </CardContent>
            </Card>
          )

        return stat.href ? (
          <Link key={stat.title} href={stat.href}>
            {cardContent}
          </Link>
        ) : (
          <div key={stat.title}>{cardContent}</div>
        )
      })}
    </div>
  )
}
