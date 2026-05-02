/**
 * @fileoverview Command Center Header - Clean, confident supervisor greeting.
 * Minimal design with purposeful typography.
 * @module components/dashboard/v2/command-center-header
 */

"use client"

import { motion } from "framer-motion"
import { Activity, Circle, Clock, ChevronRight } from "lucide-react"
import { useAuth } from "@/hooks"
import { cn } from "@/lib/utils"
import Link from "next/link"

interface CommandCenterHeaderProps {
  activeProjects: number
  pendingQC: number
  isAvailable: boolean
  className?: string
}

function getGreeting(): string {
  const hour = new Date().getHours()
  if (hour < 12) return "Good morning"
  if (hour < 17) return "Good afternoon"
  return "Good evening"
}

function getFormattedDate(): string {
  return new Date().toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
  })
}

export function CommandCenterHeader({
  activeProjects,
  pendingQC,
  isAvailable,
  className,
}: CommandCenterHeaderProps) {
  const { user } = useAuth()
  const greeting = getGreeting()
  const firstName = user?.full_name?.split(" ")[0] || "Supervisor"

  return (
    <motion.header
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: "easeOut" }}
      className={cn("relative", className)}
    >
      <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6">
        {/* Left - Greeting */}
        <div className="space-y-1">
          {/* Date & Status */}
          <div className="flex items-center gap-4 mb-2">
            <span className="text-[13px] text-stone-500">
              {getFormattedDate()}
            </span>
            <div className="flex items-center gap-1.5">
              <span className={cn(
                "w-2 h-2 rounded-full",
                isAvailable ? "bg-emerald-500" : "bg-stone-300"
              )} />
              <span className={cn(
                "text-[13px] font-medium",
                isAvailable ? "text-emerald-600" : "text-stone-400"
              )}>
                {isAvailable ? "Available" : "Away"}
              </span>
            </div>
          </div>

          {/* Greeting */}
          <h1 className="text-2xl lg:text-3xl font-semibold text-stone-900 tracking-tight">
            {greeting}, <span className="text-stone-600">{firstName}</span>
          </h1>

          <p className="text-sm text-stone-500">
            Here&apos;s what needs your attention today.
          </p>
        </div>

        {/* Right - Quick Stats */}
        <div className="flex items-center gap-3">
          {activeProjects > 0 && (
            <Link
              href="/projects?tab=ongoing"
              className="group flex items-center gap-3 px-4 py-2.5 rounded-xl bg-white border border-stone-200/60 hover:border-stone-300 hover:shadow-sm transition-all duration-200"
            >
              <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-orange-50">
                <Activity className="h-4 w-4 text-[#F97316]" />
              </div>
              <div>
                <p className="text-lg font-semibold text-stone-900 tabular-nums leading-none">
                  {activeProjects}
                </p>
                <p className="text-[11px] text-stone-500 mt-0.5">Active</p>
              </div>
              <ChevronRight className="h-4 w-4 text-stone-300 group-hover:text-stone-400 transition-colors" />
            </Link>
          )}

          {pendingQC > 0 && (
            <Link
              href="/projects?tab=review"
              className="group flex items-center gap-3 px-4 py-2.5 rounded-xl bg-amber-50/50 border border-amber-200/60 hover:border-amber-300 hover:shadow-sm transition-all duration-200"
            >
              <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-amber-100/80">
                <Clock className="h-4 w-4 text-amber-600" />
              </div>
              <div>
                <p className="text-lg font-semibold text-amber-700 tabular-nums leading-none">
                  {pendingQC}
                </p>
                <p className="text-[11px] text-amber-600/80 mt-0.5">Pending QC</p>
              </div>
              <ChevronRight className="h-4 w-4 text-amber-300 group-hover:text-amber-400 transition-colors" />
            </Link>
          )}
        </div>
      </div>
    </motion.header>
  )
}
