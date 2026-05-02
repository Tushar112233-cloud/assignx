"use client"

import { motion } from "framer-motion"
import {
  DollarSign,
  FileText,
  HelpCircle,
  GraduationCap,
  ExternalLink,
  ArrowRight,
  type LucideIcon
} from "lucide-react"
import { cn } from "@/lib/utils"

interface CategoryTool {
  id: string
  title: string
  description: string
  icon: LucideIcon
  color: string
  bgColor: string
  external?: boolean
}

interface ToolCategoryGridProps {
  title: string
  tools: CategoryTool[]
  onToolSelect: (toolId: string) => void
  className?: string
}

interface ToolCardProps {
  tool: CategoryTool
  index: number
  onSelect: (toolId: string) => void
}

// Predefined categories
export const pricingGuides: CategoryTool[] = [
  {
    id: "pricing",
    title: "Pricing Guide",
    description: "Calculate prices based on complexity and urgency",
    icon: DollarSign,
    color: "text-emerald-600",
    bgColor: "bg-emerald-50"
  },
  {
    id: "guidelines",
    title: "Service Guidelines",
    description: "Quality standards and best practices",
    icon: FileText,
    color: "text-amber-600",
    bgColor: "bg-amber-50"
  },
  {
    id: "faq",
    title: "FAQ & Help",
    description: "Common questions and troubleshooting",
    icon: HelpCircle,
    color: "text-slate-600",
    bgColor: "bg-slate-100"
  }
]

export const trainingTools: CategoryTool[] = [
  {
    id: "training",
    title: "Training Library",
    description: "Video tutorials and skill development modules",
    icon: GraduationCap,
    color: "text-indigo-600",
    bgColor: "bg-indigo-50"
  },
  {
    id: "courses",
    title: "External Courses",
    description: "Recommended courses from industry experts",
    icon: ExternalLink,
    color: "text-violet-600",
    bgColor: "bg-violet-50",
    external: true
  }
]

export function ToolCard({ tool, index, onSelect }: ToolCardProps) {
  const IconComponent = tool.icon

  return (
    <motion.button
      onClick={() => onSelect(tool.id)}
      className={cn(
        "group relative bg-white rounded-2xl border border-gray-200 p-6 text-left",
        "hover:shadow-lg hover:border-orange-200 hover:-translate-y-1",
        "active:translate-y-0 transition-all duration-300 w-full"
      )}
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.1 * index }}
    >
      {tool.external && (
        <div className="absolute top-4 right-4">
          <span className="inline-flex items-center gap-1 rounded-full bg-violet-50 px-2.5 py-1 text-xs font-semibold text-violet-700">
            <ExternalLink className="h-3 w-3" />
            External
          </span>
        </div>
      )}

      {/* Icon */}
      <div className={cn(
        "w-14 h-14 rounded-xl flex items-center justify-center mb-4",
        tool.bgColor
      )}>
        <IconComponent className={cn("h-7 w-7", tool.color)} />
      </div>

      {/* Content */}
      <h3 className="text-lg font-semibold text-[#1C1C1C] mb-2">{tool.title}</h3>
      <p className="text-sm text-gray-500 mb-4 leading-relaxed whitespace-normal">
        {tool.description}
      </p>

      {/* Footer */}
      <div className="flex items-center justify-between">
        <span className="text-xs text-gray-400">Tap to open</span>
        <div className="flex items-center gap-1 text-[#F97316] text-sm font-medium group-hover:gap-2 transition-all">
          Launch Tool
          <ArrowRight className="h-4 w-4" />
        </div>
      </div>
    </motion.button>
  )
}

export function ToolCategoryGrid({ title, tools, onToolSelect, className }: ToolCategoryGridProps) {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={cn("space-y-5", className)}
    >
      {/* Section Header */}
      <div className="flex items-center gap-3">
        <h2 className="text-xl font-semibold text-[#1C1C1C]">{title}</h2>
        <div className="h-1 w-12 bg-[#F97316] rounded-full" />
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6 auto-rows-fr">
        {tools.map((tool, index) => (
          <ToolCard
            key={tool.id}
            tool={tool}
            index={index}
            onSelect={onToolSelect}
          />
        ))}
      </div>
    </motion.section>
  )
}

export type { CategoryTool, ToolCategoryGridProps, ToolCardProps }
