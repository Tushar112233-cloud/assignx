"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useStaggeredReveal } from "@/hooks/use-staggered-reveal";
import { LucideIcon } from "lucide-react";

interface StatItem {
  icon: LucideIcon;
  label: string;
  value: string | number;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  color?: "default" | "success" | "warning" | "error";
}

interface StatsRowProps {
  stats: StatItem[];
  className?: string;
}

const colorClasses = {
  default: "text-foreground",
  success: "text-emerald-600 dark:text-emerald-400",
  warning: "text-amber-600 dark:text-amber-400",
  error: "text-red-600 dark:text-red-400",
};

/**
 * Stats row component - 4 column grid
 * Provides consistent stat display across all pages
 */
export function StatsRow({ stats, className }: StatsRowProps) {
  const { item } = useStaggeredReveal({});

  return (
    <motion.div
      variants={item}
      className={cn("grid grid-cols-2 md:grid-cols-4 gap-4", className)}
    >
      {stats.map((stat, index) => (
        <StatCard key={index} stat={stat} index={index} />
      ))}
    </motion.div>
  );
}

function StatCard({ stat, index }: { stat: StatItem; index: number }) {
  const Icon = stat.icon;
  const colorClass = colorClasses[stat.color || "default"];

  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05, duration: 0.3 }}
      className={cn(
        "p-4 md:p-5 rounded-xl border border-border bg-card",
        "hover:shadow-md hover:border-border/80 transition-all duration-200"
      )}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="p-2 rounded-lg bg-muted">
          <Icon className="h-5 w-5 text-muted-foreground" />
        </div>
        {stat.trend && (
          <span className={cn(
            "text-xs font-medium",
            stat.trend.isPositive ? "text-emerald-600" : "text-red-600"
          )}>
            {stat.trend.isPositive ? "+" : ""}{stat.trend.value}%
          </span>
        )}
      </div>

      <p className={cn("text-2xl font-bold", colorClass)}>
        {stat.value}
      </p>
      <p className="text-xs text-muted-foreground mt-1">
        {stat.label}
      </p>
    </motion.div>
  );
}
