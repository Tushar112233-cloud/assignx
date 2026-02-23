"use client";

import { ReactNode } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useStaggeredReveal } from "@/hooks/use-staggered-reveal";

interface MasonryGridProps {
  children: ReactNode;
  columns?: 2 | 3 | 4;
  gap?: "sm" | "md" | "lg";
  className?: string;
}

const columnClasses = {
  2: "columns-2",
  3: "columns-2 md:columns-3",
  4: "columns-2 md:columns-3 lg:columns-4",
};

const gapClasses = {
  sm: "gap-3",
  md: "gap-4",
  lg: "gap-6",
};

/**
 * Masonry grid for Pinterest-style layouts
 */
export function MasonryGrid({
  children,
  columns = 4,
  gap = "md",
  className,
}: MasonryGridProps) {
  const { item } = useStaggeredReveal({});

  return (
    <motion.div
      variants={item}
      className={cn(
        columnClasses[columns],
        gapClasses[gap],
        className
      )}
    >
      {children}
    </motion.div>
  );
}
