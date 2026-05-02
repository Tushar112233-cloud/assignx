"use client";

import { motion } from "framer-motion";
import { LucideIcon } from "lucide-react";

interface OnboardingSlideProps {
  icon: LucideIcon;
  title: string;
  description: string;
  isActive: boolean;
}

/**
 * Single onboarding slide component
 * Animates in/out based on active state
 */
export function OnboardingSlide({
  icon: Icon,
  title,
  description,
  isActive,
}: OnboardingSlideProps) {
  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: isActive ? 1 : 0, x: isActive ? 0 : 50 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.4 }}
      className="flex flex-col items-center text-center"
    >
      {/* Icon container */}
      <div className="mb-8 flex h-32 w-32 items-center justify-center rounded-full bg-primary/10">
        <Icon className="h-16 w-16 text-primary" />
      </div>

      {/* Title */}
      <h2 className="mb-4 text-2xl font-bold tracking-tight sm:text-3xl">
        {title}
      </h2>

      {/* Description */}
      <p className="max-w-md text-muted-foreground">{description}</p>
    </motion.div>
  );
}
