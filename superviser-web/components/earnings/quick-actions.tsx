"use client"

import { motion } from "framer-motion"
import { ArrowUpRight, Receipt, FileText, ChevronRight } from "lucide-react"
import Link from "next/link"
import { cn } from "@/lib/utils"

interface QuickAction {
  label: string
  description: string
  icon: React.ElementType
  color: string
  href?: string
  onClick?: () => void
}

interface QuickActionsProps {
  className?: string
  onWithdrawClick?: () => void
  onExportClick?: () => void
}

export function QuickActions({
  className,
  onWithdrawClick,
  onExportClick
}: QuickActionsProps) {
  const actions: QuickAction[] = [
    {
      label: "Request Withdrawal",
      description: "Transfer to bank",
      icon: ArrowUpRight,
      color: "bg-orange-50 text-[#F97316]",
      onClick: onWithdrawClick
    },
    {
      label: "View Full Ledger",
      description: "Transaction history",
      icon: Receipt,
      color: "bg-emerald-50 text-emerald-600",
      href: "#transactions"
    },
    {
      label: "Export Statement",
      description: "Download PDF",
      icon: FileText,
      color: "bg-purple-50 text-purple-600",
      onClick: onExportClick
    },
  ]

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.1
      }
    }
  }

  const itemVariants = {
    hidden: { opacity: 0, x: 20 },
    visible: {
      opacity: 1,
      x: 0,
      transition: {
        duration: 0.3,
        ease: "easeOut" as const
      }
    }
  }

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className={cn("space-y-3", className)}
    >
      {actions.map((action) => {
        const ActionContent = (
          <motion.div
            variants={itemVariants}
            className="group flex items-center gap-4 p-4 bg-white rounded-2xl border border-gray-200 hover:border-orange-200 hover:shadow-md hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200 cursor-pointer"
          >
            <div className={cn(
              "w-12 h-12 rounded-xl flex items-center justify-center transition-colors",
              action.color
            )}>
              <action.icon className="h-6 w-6" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-semibold text-[#1C1C1C] group-hover:text-orange-600 transition-colors">
                {action.label}
              </p>
              <p className="text-sm text-gray-500">{action.description}</p>
            </div>
            <ChevronRight className="h-5 w-5 text-gray-400 group-hover:text-orange-500 group-hover:translate-x-0.5 transition-all" />
          </motion.div>
        )

        if (action.href) {
          return (
            <Link key={action.label} href={action.href}>
              {ActionContent}
            </Link>
          )
        }

        return (
          <button
            key={action.label}
            type="button"
            onClick={action.onClick}
            className="w-full text-left"
          >
            {ActionContent}
          </button>
        )
      })}
    </motion.div>
  )
}

export default QuickActions
