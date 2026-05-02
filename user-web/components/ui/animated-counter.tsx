"use client";

import { useEffect, useRef, useState } from "react";
import { motion, useSpring, useTransform, useInView } from "framer-motion";
import { cn } from "@/lib/utils";

interface AnimatedCounterProps {
  value: number;
  className?: string;
  duration?: number;
  prefix?: string;
  suffix?: string;
  decimals?: number;
  formatFn?: (value: number) => string;
}

/**
 * Animated counter that counts up when in view
 */
export function AnimatedCounter({
  value,
  className,
  duration = 1.5,
  prefix = "",
  suffix = "",
  decimals = 0,
  formatFn,
}: AnimatedCounterProps) {
  const ref = useRef<HTMLSpanElement>(null);
  const isInView = useInView(ref, { once: true, margin: "-50px" });
  const [hasAnimated, setHasAnimated] = useState(false);

  const spring = useSpring(0, {
    duration: duration * 1000,
    bounce: 0,
  });

  const display = useTransform(spring, (current) => {
    if (formatFn) {
      return formatFn(Math.round(current));
    }
    const formatted = decimals > 0
      ? current.toFixed(decimals)
      : Math.round(current).toLocaleString();
    return `${prefix}${formatted}${suffix}`;
  });

  useEffect(() => {
    if (isInView && !hasAnimated) {
      spring.set(value);
      setHasAnimated(true);
    }
  }, [isInView, value, spring, hasAnimated]);

  // Update value if it changes after initial animation
  useEffect(() => {
    if (hasAnimated) {
      spring.set(value);
    }
  }, [value, spring, hasAnimated]);

  return (
    <motion.span ref={ref} className={cn("tabular-nums", className)}>
      {display}
    </motion.span>
  );
}

/**
 * Simple number that animates on change
 */
interface AnimatedNumberProps {
  value: number;
  className?: string;
}

export function AnimatedNumber({ value, className }: AnimatedNumberProps) {
  return (
    <motion.span
      key={value}
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      className={cn("tabular-nums", className)}
    >
      {value.toLocaleString()}
    </motion.span>
  );
}

/**
 * Currency counter with rupee formatting
 */
interface CurrencyCounterProps {
  value: number;
  className?: string;
  duration?: number;
}

export function CurrencyCounter({
  value,
  className,
  duration = 1.5,
}: CurrencyCounterProps) {
  return (
    <AnimatedCounter
      value={value}
      className={className}
      duration={duration}
      formatFn={(val) => `₹${val.toLocaleString()}`}
    />
  );
}

/**
 * Percentage counter
 */
interface PercentageCounterProps {
  value: number;
  className?: string;
  duration?: number;
}

export function PercentageCounter({
  value,
  className,
  duration = 1.5,
}: PercentageCounterProps) {
  return (
    <AnimatedCounter
      value={value}
      className={className}
      duration={duration}
      suffix="%"
    />
  );
}
