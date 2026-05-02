"use client"

import { cn } from "@/lib/utils"
import { cva, type VariantProps } from "class-variance-authority"

const statusBadgeVariants = cva(
  "inline-flex items-center gap-1.5 font-medium",
  {
    variants: {
      variant: {
        info: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400",
        warning: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400",
        success: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400",
        error: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400",
        neutral: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-400",
        purple: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400",
      },
      size: {
        sm: "text-xs px-2 py-0.5",
        default: "text-xs px-2.5 py-1",
        lg: "text-sm px-3 py-1",
      },
    },
    defaultVariants: {
      variant: "neutral",
      size: "default",
    },
  }
)

interface StatusBadgeProps extends VariantProps<typeof statusBadgeVariants> {
  children: React.ReactNode
  icon?: React.ReactNode
  className?: string
}

export function StatusBadge({ children, icon, variant, size, className }: StatusBadgeProps) {
  return (
    <span className={cn(statusBadgeVariants({ variant, size }), "rounded-full", className)}>
      {icon}
      {children}
    </span>
  )
}
