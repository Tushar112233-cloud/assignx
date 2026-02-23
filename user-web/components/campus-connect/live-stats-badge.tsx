"use client";

/**
 * LiveStatsBadge - Animated live statistics display
 * Shows pulsing dot indicator with animated number counter
 */

import { useState, useEffect } from "react";
import { motion, useSpring, useTransform, useReducedMotion } from "framer-motion";
import { cn } from "@/lib/utils";

interface LiveStatsBadgeProps {
  /** Initial value to display */
  value: number;
  /** Label text to show after the number */
  label: string;
  /** Icon component to display */
  icon: React.ElementType;
  /** Color for the pulsing dot and icon */
  color?: "violet" | "blue" | "emerald" | "amber";
  /** Whether to auto-increment the value */
  autoIncrement?: boolean;
  /** Increment interval in ms (default 30000-60000 random) */
  incrementInterval?: number;
  /** Custom class name */
  className?: string;
}

const colorMap = {
  violet: {
    dot: "bg-violet-500",
    icon: "text-violet-400",
    glow: "shadow-violet-500/50",
  },
  blue: {
    dot: "bg-blue-500",
    icon: "text-blue-400",
    glow: "shadow-blue-500/50",
  },
  emerald: {
    dot: "bg-emerald-500",
    icon: "text-emerald-400",
    glow: "shadow-emerald-500/50",
  },
  amber: {
    dot: "bg-amber-500",
    icon: "text-amber-400",
    glow: "shadow-amber-500/50",
  },
};

export function LiveStatsBadge({
  value,
  label,
  icon: Icon,
  color = "violet",
  autoIncrement = true,
  incrementInterval,
  className,
}: LiveStatsBadgeProps) {
  const prefersReducedMotion = useReducedMotion();
  const [currentValue, setCurrentValue] = useState(value);

  // Smooth number animation using spring
  const springValue = useSpring(currentValue, {
    mass: 1,
    damping: 30,
    stiffness: 100,
  });

  const displayValue = useTransform(springValue, (latest) => Math.round(latest));
  const [displayNumber, setDisplayNumber] = useState(value);

  // Update spring when currentValue changes
  useEffect(() => {
    springValue.set(currentValue);
  }, [currentValue, springValue]);

  // Subscribe to displayValue changes
  useEffect(() => {
    const unsubscribe = displayValue.on("change", (latest) => {
      setDisplayNumber(latest);
    });
    return unsubscribe;
  }, [displayValue]);

  // Auto-increment logic
  useEffect(() => {
    if (!autoIncrement) return;

    const getRandomInterval = () => {
      if (incrementInterval) return incrementInterval;
      return Math.random() * 30000 + 30000; // 30-60 seconds
    };

    const interval = setInterval(() => {
      setCurrentValue((prev) => prev + Math.floor(Math.random() * 3) + 1);
    }, getRandomInterval());

    return () => clearInterval(interval);
  }, [autoIncrement, incrementInterval]);

  const colors = colorMap[color];

  return (
    <div
      className={cn(
        "flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm",
        className
      )}
    >
      {/* Pulsing dot indicator */}
      <span className="relative flex h-2 w-2">
        <motion.span
          animate={
            prefersReducedMotion
              ? {}
              : {
                  scale: [1, 1.5, 1],
                  opacity: [1, 0.5, 1],
                }
          }
          transition={{
            duration: 2,
            repeat: Infinity,
            ease: "easeInOut",
          }}
          className={cn(
            "absolute inline-flex h-full w-full rounded-full opacity-75",
            colors.dot
          )}
        />
        <span
          className={cn(
            "relative inline-flex rounded-full h-2 w-2",
            colors.dot
          )}
        />
      </span>

      {/* Icon */}
      <Icon className={cn("h-4 w-4", colors.icon)} />

      {/* Animated number + label */}
      <span className="text-sm font-medium text-white">
        <motion.span key={displayNumber}>{displayNumber}</motion.span>
        {" "}
        {label}
      </span>
    </div>
  );
}

export default LiveStatsBadge;
