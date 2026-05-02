"use client"

import { motion } from "framer-motion"
import {
  Star,
  Clock,
  Search,
  Bot,
  SpellCheck,
  DollarSign,
  BookOpen,
  ChevronRight,
  Bookmark
} from "lucide-react"
import { cn } from "@/lib/utils"

interface QuickAccessItem {
  id: string
  title: string
  icon: React.ElementType
  color: string
}

interface QuickAccessPanelProps {
  onItemSelect: (itemId: string) => void
  className?: string
}

const favorites: QuickAccessItem[] = [
  { id: "plagiarism", title: "Plagiarism Checker", icon: Search, color: "text-[#F97316]" },
  { id: "pricing", title: "Pricing Guide", icon: DollarSign, color: "text-emerald-600" }
]

const recentTools: QuickAccessItem[] = [
  { id: "ai-detector", title: "AI Detector", icon: Bot, color: "text-purple-600" },
  { id: "grammar", title: "Grammar Check", icon: SpellCheck, color: "text-emerald-600" },
  { id: "training", title: "Training Videos", icon: BookOpen, color: "text-indigo-600" }
]

function QuickAccessButton({
  item,
  onSelect
}: {
  item: QuickAccessItem
  onSelect: (id: string) => void
}) {
  return (
    <button
      onClick={() => onSelect(item.id)}
      className="group flex items-center gap-3 w-full p-2.5 rounded-xl
        hover:bg-gray-50 transition-colors text-left"
    >
      <item.icon className={cn("h-4 w-4", item.color)} />
      <span className="text-sm text-gray-600 group-hover:text-[#1C1C1C] flex-1">
        {item.title}
      </span>
      <ChevronRight className="h-4 w-4 text-gray-300 group-hover:text-[#F97316]
        opacity-0 group-hover:opacity-100 transition-all" />
    </button>
  )
}

export function QuickAccessPanel({ onItemSelect, className }: QuickAccessPanelProps) {
  return (
    <motion.aside
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.3 }}
      className={cn(
        "bg-white rounded-2xl border border-gray-200 p-5 space-y-6",
        "sticky top-24",
        "hidden lg:block w-[280px]",
        className
      )}
    >
      {/* Header */}
      <div className="flex items-center gap-2">
        <Bookmark className="h-5 w-5 text-[#F97316]" />
        <h3 className="font-semibold text-[#1C1C1C]">Quick Access</h3>
      </div>

      {/* Favorites Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Star className="h-4 w-4 text-amber-500" />
          <span className="text-xs font-semibold uppercase tracking-wider text-gray-400">
            Favorites
          </span>
        </div>
        <div className="space-y-2">
          {favorites.map((item) => (
            <QuickAccessButton key={item.id} item={item} onSelect={onItemSelect} />
          ))}
        </div>
      </div>

      {/* Divider */}
      <div className="h-px bg-gray-100" />

      {/* Recent Section */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Clock className="h-4 w-4 text-gray-400" />
          <span className="text-xs font-semibold uppercase tracking-wider text-gray-400">
            Recent
          </span>
        </div>
        <div className="space-y-2">
          {recentTools.map((item) => (
            <QuickAccessButton key={item.id} item={item} onSelect={onItemSelect} />
          ))}
        </div>
      </div>
    </motion.aside>
  )
}

export default QuickAccessPanel
