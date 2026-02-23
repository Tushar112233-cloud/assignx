"use client";

import { ReactNode } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useStaggeredReveal } from "@/hooks/use-staggered-reveal";

interface PageSectionProps {
  children: ReactNode;
  className?: string;
  title?: string;
  action?: ReactNode;
}

/**
 * Page section with optional title and action
 * Animates in with stagger effect
 */
export function PageSection({
  children,
  className,
  title,
  action,
}: PageSectionProps) {
  const { item } = useStaggeredReveal({});

  return (
    <motion.section variants={item} className={cn("space-y-4", className)}>
      {(title || action) && (
        <div className="flex items-center justify-between">
          {title && (
            <h2 className="text-lg font-semibold text-foreground">{title}</h2>
          )}
          {action}
        </div>
      )}
      {children}
    </motion.section>
  );
}
