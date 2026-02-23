"use client";

import { ReactNode } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useStaggeredReveal } from "@/hooks/use-staggered-reveal";

interface HeroSectionProps {
  title: string;
  subtitle?: string;
  action?: ReactNode;
  children?: ReactNode;
  className?: string;
  height?: number;
  gradient?: "default" | "vibrant" | "subtle" | "dark";
  centered?: boolean;
}

const gradientClasses = {
  default: "bg-gradient-to-br from-muted/50 via-muted/30 to-background",
  vibrant: "bg-gradient-to-br from-primary/10 via-primary/5 to-background",
  subtle: "bg-muted/30",
  dark: "bg-gradient-to-br from-zinc-900 to-zinc-800",
};

/**
 * Hero section component for page headers
 * Provides consistent styling across all pages
 */
export function HeroSection({
  title,
  subtitle,
  action,
  children,
  className,
  height = 140,
  gradient = "default",
  centered = false,
}: HeroSectionProps) {
  const { item } = useStaggeredReveal({});

  return (
    <motion.div
      variants={item}
      className={cn(
        "rounded-2xl overflow-hidden",
        gradientClasses[gradient],
        className
      )}
      style={{ minHeight: `${height}px` }}
    >
      <div className={cn(
        "p-6 md:p-8 h-full flex flex-col",
        centered ? "items-center text-center justify-center" : "justify-center"
      )}>
        <h1 className={cn(
          "text-2xl md:text-3xl font-bold text-foreground",
          gradient === "dark" && "text-white"
        )}>
          {title}
        </h1>

        {subtitle && (
          <p className={cn(
            "mt-2 text-sm md:text-base text-muted-foreground max-w-md",
            gradient === "dark" && "text-zinc-400"
          )}>
            {subtitle}
          </p>
        )}

        {action && (
          <div className="mt-4">
            {action}
          </div>
        )}

        {children}
      </div>
    </motion.div>
  );
}
