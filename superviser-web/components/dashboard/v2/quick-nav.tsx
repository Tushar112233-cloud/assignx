/**
 * @fileoverview Quick Nav - Clean premium navigation shortcuts.
 * Minimal white cards with subtle hover effects and icon colors.
 * @module components/dashboard/v2/quick-nav
 */

"use client"

import { motion } from "framer-motion"
import {
  FolderKanban,
  Users,
  Wallet,
  BookOpen,
  ChevronRight
} from "lucide-react"
import { cn } from "@/lib/utils"
import Link from "next/link"

interface NavItem {
  href: string
  icon: typeof FolderKanban
  label: string
  description: string
  accent: "teal" | "amber" | "emerald" | "violet"
}

const navItems: NavItem[] = [
  {
    href: "/projects",
    icon: FolderKanban,
    label: "Projects",
    description: "Manage all projects",
    accent: "teal",
  },
  {
    href: "/doers",
    icon: Users,
    label: "Doers",
    description: "Expert network",
    accent: "violet",
  },
  {
    href: "/earnings",
    icon: Wallet,
    label: "Earnings",
    description: "Income & payouts",
    accent: "emerald",
  },
  {
    href: "/resources",
    icon: BookOpen,
    label: "Resources",
    description: "Tools & training",
    accent: "amber",
  },
]

const accentStyles = {
  teal: {
    icon: "text-[#F97316]",
    iconBg: "bg-orange-50 group-hover:bg-orange-100",
  },
  amber: {
    icon: "text-[#F97316]",
    iconBg: "bg-orange-500/10 group-hover:bg-orange-500/20",
  },
  emerald: {
    icon: "text-emerald-400",
    iconBg: "bg-emerald-500/10 group-hover:bg-emerald-500/20",
  },
  violet: {
    icon: "text-violet-400",
    iconBg: "bg-violet-500/10 group-hover:bg-violet-500/20",
  },
}

function NavItemCard({ item, index }: { item: NavItem; index: number }) {
  const styles = accentStyles[item.accent]
  const Icon = item.icon

  return (
    <motion.div
      initial={{ opacity: 0, y: 6 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.25, delay: index * 0.04 }}
    >
      <Link
        href={item.href}
        className={cn(
          "group flex items-center gap-4 p-4 rounded-xl",
          "bg-[#1C1C1C] border border-[#2D2D2D]",
          "hover:border-[#F97316]/30 hover:shadow-lg hover:shadow-orange-500/10 hover:scale-105",
          "transition-all duration-300"
        )}
      >
        <div className={cn(
          "flex items-center justify-center w-11 h-11 rounded-xl shrink-0 transition-all duration-300",
          styles.iconBg,
          "group-hover:scale-110"
        )}>
          <Icon className={cn("h-5 w-5", styles.icon)} />
        </div>

        <div className="flex-1 min-w-0">
          <p className="text-sm font-semibold text-white group-hover:text-[#F97316] transition-colors duration-300">
            {item.label}
          </p>
          <p className="text-[11px] text-gray-500 truncate group-hover:text-gray-400 transition-colors duration-300">
            {item.description}
          </p>
        </div>

        <ChevronRight className="h-5 w-5 text-gray-600 group-hover:text-[#F97316] group-hover:translate-x-1 shrink-0 transition-all duration-300" />
      </Link>
    </motion.div>
  )
}

interface QuickNavProps {
  className?: string
}

export function QuickNav({ className }: QuickNavProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay: 0.1, ease: "easeOut" }}
      className={cn(
        "rounded-2xl overflow-hidden",
        "bg-[#1C1C1C]",
        "border border-[#2D2D2D]",
        "shadow-xl shadow-black/30",
        className
      )}
    >
      {/* Header */}
      <div className="p-6 border-b border-[#2D2D2D]">
        <h3 className="text-base font-bold text-white">
          Quick Access
        </h3>
      </div>

      {/* Navigation Grid */}
      <div className="p-5 grid grid-cols-1 sm:grid-cols-2 gap-4 bg-[#141414]">
        {navItems.map((item, index) => (
          <NavItemCard key={item.href} item={item} index={index} />
        ))}
      </div>
    </motion.div>
  )
}
