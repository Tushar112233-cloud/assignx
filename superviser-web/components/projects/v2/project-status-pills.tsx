"use client"

import { motion } from "framer-motion"
import { LucideIcon } from "lucide-react"
import { cn } from "@/lib/utils"

interface StatusPill {
  id: string
  label: string
  count: number
  icon: LucideIcon
  badgeColor?: string
}

interface ProjectStatusPillsProps {
  pills: StatusPill[]
  activeId: string
  onSelect: (id: string) => void
}

export function ProjectStatusPills({ pills, activeId, onSelect }: ProjectStatusPillsProps) {
  const maxCount = Math.max(...pills.map((pill) => pill.count), 1)

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.2, duration: 0.5 }}
      className="space-y-3"
    >
      {pills.map((pill, index) => {
        const isActive = pill.id === activeId
        const progress = Math.round((pill.count / maxCount) * 100)

        return (
          <motion.button
            key={pill.id}
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.06 * index, duration: 0.3 }}
            onClick={() => onSelect(pill.id)}
            className={cn(
              "relative group flex items-center gap-4 w-full p-4 rounded-2xl border transition-all duration-300 text-left",
              isActive
                ? "bg-[#1C1C1C] border-[#1C1C1C] text-white shadow-lg"
                : "bg-white border-gray-200 hover:border-orange-200 hover:shadow-md"
            )}
          >
            <span
              className={cn(
                "absolute left-0 top-3 bottom-3 w-1 rounded-full",
                isActive ? "bg-[#F97316]" : "bg-transparent"
              )}
            />
            <div
              className={cn(
                "w-11 h-11 rounded-xl flex items-center justify-center transition-colors",
                isActive ? "bg-white/10" : "bg-orange-100"
              )}
            >
              <pill.icon
                className={cn(
                  "h-5 w-5",
                  isActive ? "text-white" : "text-orange-600"
                )}
              />
            </div>
            <div className="flex-1 min-w-0">
              <p
                className={cn(
                  "text-[11px] uppercase tracking-wide font-medium",
                  isActive ? "text-white/70" : "text-gray-500"
                )}
              >
                {pill.label}
              </p>
              <div className="flex items-center justify-between gap-2">
                <p
                  className={cn(
                    "text-lg font-bold truncate",
                    isActive ? "text-white" : "text-[#1C1C1C]"
                  )}
                >
                  {pill.count}
                </p>
                {pill.badgeColor && pill.count > 0 && !isActive && (
                  <span
                    className="w-2.5 h-2.5 rounded-full animate-pulse"
                    style={{ backgroundColor: pill.badgeColor }}
                  />
                )}
              </div>
              <div className={cn(
                "mt-2 h-1.5 rounded-full overflow-hidden",
                isActive ? "bg-white/10" : "bg-gray-100"
              )}>
                <div
                  className={cn(
                    "h-full rounded-full transition-all",
                    isActive ? "bg-[#F97316]" : "bg-gray-300"
                  )}
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          </motion.button>
        )
      })}
    </motion.div>
  )
}
