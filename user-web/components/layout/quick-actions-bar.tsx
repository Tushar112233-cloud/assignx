"use client";

import { ReactNode } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useStaggeredReveal } from "@/hooks/use-staggered-reveal";

interface QuickActionsBarProps {
  children: ReactNode;
  className?: string;
}

/**
 * Quick actions bar for filters and action buttons
 * Positioned below hero, above stats
 */
export function QuickActionsBar({ children, className }: QuickActionsBarProps) {
  const { item } = useStaggeredReveal({});

  return (
    <motion.div
      variants={item}
      className={cn(
        "flex items-center justify-between gap-4 flex-wrap",
        className
      )}
    >
      {children}
    </motion.div>
  );
}
