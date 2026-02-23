/**
 * @fileoverview Trust Stats Section - Animated counters showcasing key metrics
 *
 * Displays trust indicators with animated number counters:
 * - 98% success rate
 * - 24-hour delivery
 * - 500+ experts
 */

"use client";

import { useRef, useEffect, useState } from "react";
import {
  motion,
  useReducedMotion,
  useInView,
  useSpring,
  useTransform,
} from "framer-motion";
import {
  CheckCircle2,
  Clock,
  Users,
  Award,
} from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";

/**
 * Stat configuration
 */
interface Stat {
  id: string;
  value: number;
  suffix: string;
  label: string;
  description: string;
  icon: React.ElementType;
}

const stats: Stat[] = [
  {
    id: "success",
    value: 98,
    suffix: "%",
    label: "Success Rate",
    description: "Projects delivered meeting client expectations",
    icon: CheckCircle2,
  },
  {
    id: "delivery",
    value: 24,
    suffix: "h",
    label: "Avg. Delivery",
    description: "Quick turnaround without compromising quality",
    icon: Clock,
  },
  {
    id: "experts",
    value: 500,
    suffix: "+",
    label: "Verified Experts",
    description: "Skilled professionals across all domains",
    icon: Users,
  },
  {
    id: "satisfaction",
    value: 4.9,
    suffix: "/5",
    label: "Client Rating",
    description: "Average rating from verified reviews",
    icon: Award,
  },
];

/**
 * Animated counter hook
 */
function useAnimatedCounter(
  end: number,
  isInView: boolean,
  duration: number = 2
) {
  const prefersReducedMotion = useReducedMotion();
  const isDecimal = end % 1 !== 0;

  const spring = useSpring(0, {
    stiffness: 50,
    damping: 30,
    restDelta: 0.01,
  });

  useEffect(() => {
    if (isInView) {
      spring.set(end);
    }
  }, [isInView, end, spring]);

  const rounded = useTransform(spring, (val) => {
    // Handle decimal numbers (like 4.9)
    if (isDecimal) {
      return val.toFixed(1);
    }
    return Math.round(val).toString();
  });

  // For reduced motion, return the end value immediately
  const initialValue = isDecimal ? end.toFixed(1) : "0";
  const [displayValue, setDisplayValue] = useState<string>(
    prefersReducedMotion ? (isDecimal ? end.toFixed(1) : end.toString()) : initialValue
  );

  useEffect(() => {
    if (prefersReducedMotion && isInView) {
      setDisplayValue(isDecimal ? end.toFixed(1) : end.toString());
      return;
    }

    const unsubscribe = rounded.on("change", (val) => {
      setDisplayValue(val);
    });

    return () => unsubscribe();
  }, [rounded, prefersReducedMotion, isInView, end, isDecimal]);

  return displayValue;
}

/**
 * Individual stat card component
 */
function StatCard({
  stat,
  index,
}: {
  stat: Stat;
  index: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.5 });
  const prefersReducedMotion = useReducedMotion();
  const animatedValue = useAnimatedCounter(stat.value, isInView);

  const Icon = stat.icon;

  return (
    <motion.div
      ref={ref}
      initial={prefersReducedMotion ? false : { opacity: 0, y: 30, scale: 0.95 }}
      animate={isInView ? { opacity: 1, y: 0, scale: 1 } : {}}
      transition={{
        delay: index * 0.1,
        duration: 0.6,
        ease: ASSIGNX_EASE,
      }}
      className="group relative"
    >
      <div
        className={cn(
          "relative text-center p-6 sm:p-8 rounded-2xl",
          "bg-white/60 backdrop-blur-lg",
          "border border-[var(--landing-border)]",
          "transition-all duration-500",
          "hover:border-[var(--landing-accent-light)]",
          "hover:shadow-lg hover:-translate-y-1"
        )}
      >
        {/* Icon */}
        <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-[var(--landing-accent-lighter)] mb-4 transition-transform duration-300 group-hover:scale-110">
          <Icon className="w-6 h-6 text-[var(--landing-accent-primary)]" />
        </div>

        {/* Counter */}
        <div className="mb-2">
          <span className="text-4xl sm:text-5xl font-bold text-[var(--landing-text-primary)] tabular-nums">
            {animatedValue}
          </span>
          <span className="text-2xl sm:text-3xl font-bold text-[var(--landing-accent-primary)]">
            {stat.suffix}
          </span>
        </div>

        {/* Label */}
        <h3 className="text-lg font-semibold text-[var(--landing-text-primary)] mb-1">
          {stat.label}
        </h3>

        {/* Description */}
        <p className="text-sm text-[var(--landing-text-muted)]">
          {stat.description}
        </p>
      </div>
    </motion.div>
  );
}

/**
 * Trust Stats Section
 */
export function TrustStats() {
  const ref = useRef<HTMLElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.2 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <section
      ref={ref}
      className="relative py-16 sm:py-24"
      style={{
        background: "var(--landing-bg-primary)",
      }}
    >
      {/* Top separator line */}
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-[var(--landing-border)] to-transparent" />

      {/* Decorative gradient */}
      <div className="absolute inset-0 landing-mesh-gradient opacity-50" />

      <div className="relative z-10 max-w-6xl mx-auto px-4 sm:px-6">
        {/* Section header */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, ease: ASSIGNX_EASE }}
          className="text-center max-w-2xl mx-auto mb-12 sm:mb-16"
        >
          <h2 className="landing-heading-md text-[var(--landing-text-primary)] mb-3">
            Trusted by thousands
          </h2>
          <p className="text-[var(--landing-text-secondary)]">
            Numbers that speak for our commitment to quality and reliability.
          </p>
        </motion.div>

        {/* Stats grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {stats.map((stat, index) => (
            <StatCard key={stat.id} stat={stat} index={index} />
          ))}
        </div>
      </div>
    </section>
  );
}
