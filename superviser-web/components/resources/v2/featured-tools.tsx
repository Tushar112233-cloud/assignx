/**
 * @fileoverview Featured tools section component displaying 3 main quality tools.
 * @module components/resources/v2/featured-tools
 */

"use client"

import { motion } from "framer-motion"
import { Search, Bot, SpellCheck, ArrowRight, Sparkles } from "lucide-react"
import { cn } from "@/lib/utils"

interface FeaturedTool {
  id: string
  title: string
  description: string
  icon: React.ElementType
  badge?: string
  usageCount?: number
  color: string
  bgColor: string
}

interface FeaturedToolsProps {
  onToolSelect: (toolId: string) => void
}

const tools: FeaturedTool[] = [
  {
    id: "plagiarism",
    title: "Plagiarism Checker",
    description: "Verify content originality and detect copied text across millions of sources",
    icon: Search,
    badge: "Essential",
    usageCount: 24,
    color: "text-[#F97316]",
    bgColor: "bg-orange-50"
  },
  {
    id: "ai-detector",
    title: "AI Content Detector",
    description: "Identify AI-generated content and ensure authentic human writing",
    icon: Bot,
    badge: "Essential",
    usageCount: 18,
    color: "text-purple-600",
    bgColor: "bg-purple-50"
  },
  {
    id: "grammar",
    title: "Grammar Checker",
    description: "Advanced grammar, spelling, and style analysis for polished content",
    icon: SpellCheck,
    usageCount: 12,
    color: "text-emerald-600",
    bgColor: "bg-emerald-50"
  }
]

/**
 * Individual featured tool card component
 */
function FeaturedToolCard({
  tool,
  index,
  onSelect
}: {
  tool: FeaturedTool
  index: number
  onSelect: (toolId: string) => void
}) {
  return (
    <motion.button
      onClick={() => onSelect(tool.id)}
      className="group relative bg-white rounded-2xl border border-gray-200 p-6 text-left
        hover:shadow-lg hover:border-orange-200 hover:-translate-y-1
        active:translate-y-0 transition-all duration-300"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.1 * index, duration: 0.4, ease: "easeOut" }}
    >
      {/* Badge */}
      {tool.badge && (
        <div className="absolute top-4 right-4">
          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full
            bg-orange-50 text-[#F97316] text-xs font-semibold">
            <Sparkles className="h-3 w-3" />
            {tool.badge}
          </span>
        </div>
      )}

      {/* Icon */}
      <div className={cn("w-14 h-14 rounded-xl flex items-center justify-center mb-4", tool.bgColor)}>
        <tool.icon className={cn("h-7 w-7", tool.color)} />
      </div>

      {/* Content */}
      <h3 className="text-lg font-semibold text-[#1C1C1C] mb-2">{tool.title}</h3>
      <p className="text-sm text-gray-500 mb-4 leading-relaxed whitespace-normal">
        {tool.description}
      </p>

      {/* Footer */}
      <div className="flex items-center justify-between">
        <span className="text-xs text-gray-400">{tool.usageCount} checks today</span>
        <div className="flex items-center gap-1 text-[#F97316] text-sm font-medium
          group-hover:gap-2 transition-all">
          Launch Tool
          <ArrowRight className="h-4 w-4" />
        </div>
      </div>
    </motion.button>
  )
}

/**
 * Featured tools section component that displays the 3 main quality tools prominently.
 *
 * @param props - Component props
 * @param props.onToolSelect - Callback when a tool is selected
 */
export function FeaturedTools({ onToolSelect }: FeaturedToolsProps) {
  return (
    <section className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center gap-3">
        <h2 className="text-xl font-semibold text-[#1C1C1C]">Quality Tools</h2>
        <div className="h-1 w-12 bg-[#F97316] rounded-full" />
      </div>

      {/* Tools Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {tools.map((tool, index) => (
          <FeaturedToolCard
            key={tool.id}
            tool={tool}
            index={index}
            onSelect={onToolSelect}
          />
        ))}
      </div>
    </section>
  )
}

export default FeaturedTools
