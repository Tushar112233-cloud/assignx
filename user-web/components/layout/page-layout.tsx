"use client";

import { ReactNode } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useStaggeredReveal } from "@/hooks/use-staggered-reveal";

interface PageLayoutProps {
  children: ReactNode;
  className?: string;
}

/**
 * Unified page layout wrapper that provides consistent structure
 * Used by all four core pages: Dashboard, Projects, Marketplace, Wallet
 */
export function PageLayout({ children, className }: PageLayoutProps) {
  const { container } = useStaggeredReveal({ staggerChildren: 0.1 });

  return (
    <motion.div
      variants={container}
      initial="hidden"
      animate="visible"
      className={cn("space-y-6 p-4 md:p-6 pb-28", className)}
    >
      {children}
    </motion.div>
  );
}
