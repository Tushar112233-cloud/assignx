"use client"

import { motion } from "framer-motion"
import {
  FileText,
  Zap,
  Clock,
  FileSearch,
  CheckCircle2,
  Search,
  LucideIcon,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

interface ProjectsEmptyStateProps {
  variant: "new" | "ready" | "ongoing" | "review" | "completed" | "search"
  searchQuery?: string
  onClearSearch?: () => void
}

interface EmptyStateConfig {
  icon: LucideIcon
  iconBg: string
  iconColor: string
  title: string
  description: string
}

const emptyStateConfig: Record<ProjectsEmptyStateProps["variant"], EmptyStateConfig> = {
  new: {
    icon: FileText,
    iconBg: "bg-emerald-100",
    iconColor: "text-emerald-500",
    title: "No new requests",
    description: "New project requests will appear here for you to claim",
  },
  ready: {
    icon: Zap,
    iconBg: "bg-blue-100",
    iconColor: "text-blue-500",
    title: "No projects to assign",
    description: "Paid projects waiting for doer assignment will appear here",
  },
  ongoing: {
    icon: Clock,
    iconBg: "bg-orange-100",
    iconColor: "text-orange-500",
    title: "No ongoing projects",
    description: "Projects will appear here once assigned to experts",
  },
  review: {
    icon: FileSearch,
    iconBg: "bg-amber-100",
    iconColor: "text-amber-500",
    title: "No projects for review",
    description: "Projects awaiting QC will appear here",
  },
  completed: {
    icon: CheckCircle2,
    iconBg: "bg-gray-100",
    iconColor: "text-gray-400",
    title: "No completed projects",
    description: "Completed projects will appear here",
  },
  search: {
    icon: Search,
    iconBg: "bg-gray-100",
    iconColor: "text-gray-400",
    title: "No results found",
    description: "Try adjusting your search or filters",
  },
}

export function ProjectsEmptyState({
  variant,
  searchQuery,
  onClearSearch,
}: ProjectsEmptyStateProps) {
  const config = emptyStateConfig[variant]
  const Icon = config.icon

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="relative overflow-hidden rounded-2xl border border-gray-200 bg-white px-6 py-12 text-center"
    >
      <div className="absolute -top-20 right-0 h-40 w-40 rounded-full bg-orange-100/60 blur-3xl" />
      <div className="absolute -bottom-24 left-0 h-40 w-40 rounded-full bg-amber-100/50 blur-3xl" />

      <div
        className={cn(
          "relative w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4",
          config.iconBg
        )}
      >
        <Icon className={cn("h-8 w-8", config.iconColor)} />
      </div>

      <h3 className="text-lg font-semibold text-[#1C1C1C]">{config.title}</h3>
      <p className="text-sm text-gray-500 mt-2 max-w-sm mx-auto">
        {variant === "search" && searchQuery
          ? `No projects found for "${searchQuery}"`
          : config.description}
      </p>
      <p className="text-xs text-gray-400 mt-2">No items in this lane right now.</p>

      {variant === "search" && onClearSearch && (
        <Button
          variant="outline"
          onClick={onClearSearch}
          className="mt-5 rounded-xl"
        >
          Clear Search
        </Button>
      )}
    </motion.div>
  )
}
