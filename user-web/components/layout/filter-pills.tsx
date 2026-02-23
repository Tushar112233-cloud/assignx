"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";

interface FilterOption {
  id: string;
  label: string;
  icon?: LucideIcon;
  count?: number;
}

interface FilterPillsProps {
  options: FilterOption[];
  selected: string;
  onChange: (id: string) => void;
  className?: string;
}

/**
 * Filter pills component for category/status filtering
 */
export function FilterPills({
  options,
  selected,
  onChange,
  className,
}: FilterPillsProps) {
  return (
    <div className={cn("flex items-center gap-2 overflow-x-auto pb-1", className)}>
      {options.map((option) => {
        const isSelected = selected === option.id;
        const Icon = option.icon;

        return (
          <motion.button
            key={option.id}
            onClick={() => onChange(option.id)}
            whileTap={{ scale: 0.95 }}
            className={cn(
              "inline-flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-medium",
              "border transition-all duration-200 whitespace-nowrap",
              isSelected
                ? "bg-primary text-primary-foreground border-primary"
                : "bg-background text-muted-foreground border-border hover:border-foreground/20 hover:text-foreground"
            )}
          >
            {Icon && <Icon className="h-4 w-4" />}
            {option.label}
            {option.count !== undefined && (
              <span className={cn(
                "ml-1 px-1.5 py-0.5 rounded-full text-xs",
                isSelected
                  ? "bg-primary-foreground/20"
                  : "bg-muted"
              )}>
                {option.count}
              </span>
            )}
          </motion.button>
        );
      })}
    </div>
  );
}
