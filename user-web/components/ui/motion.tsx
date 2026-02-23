"use client";

import { motion, type HTMLMotionProps, type Variants } from "framer-motion";
import { forwardRef } from "react";
import { cn } from "@/lib/utils";

/**
 * Common animation variants
 */
export const fadeIn: Variants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: 0.3 } },
};

export const fadeInUp: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4, ease: "easeOut" } },
};

export const fadeInDown: Variants = {
  hidden: { opacity: 0, y: -20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4, ease: "easeOut" } },
};

export const scaleIn: Variants = {
  hidden: { opacity: 0, scale: 0.9 },
  visible: { opacity: 1, scale: 1, transition: { duration: 0.3 } },
};

export const slideInLeft: Variants = {
  hidden: { opacity: 0, x: -20 },
  visible: { opacity: 1, x: 0, transition: { duration: 0.3 } },
};

export const slideInRight: Variants = {
  hidden: { opacity: 0, x: 20 },
  visible: { opacity: 1, x: 0, transition: { duration: 0.3 } },
};

/**
 * Stagger container for list animations
 */
export const staggerContainer: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.1,
    },
  },
};

export const staggerItem: Variants = {
  hidden: { opacity: 0, y: 15 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.3, ease: "easeOut" },
  },
};

/**
 * Card hover animation
 */
export const cardHover: Variants = {
  rest: { scale: 1, y: 0 },
  hover: {
    scale: 1.02,
    y: -2,
    transition: { duration: 0.2, ease: [0.4, 0, 0.2, 1] },
  },
  tap: { scale: 0.98 },
};

/**
 * Button tap animation
 */
export const buttonTap = {
  tap: { scale: 0.97 },
};

/**
 * Icon hover animation
 */
export const iconHover = {
  rest: { scale: 1, rotate: 0 },
  hover: { scale: 1.1, transition: { duration: 0.2 } },
};

export const iconBounce = {
  rest: { scale: 1 },
  hover: {
    scale: [1, 1.2, 1],
    transition: { duration: 0.3 },
  },
};

/**
 * Motion div with common defaults
 */
export const MotionDiv = motion.div;
export const MotionSpan = motion.span;
export const MotionButton = motion.button;
export const MotionLi = motion.li;
export const MotionUl = motion.ul;

/**
 * Animated Card component with hover effects
 */
interface AnimatedCardProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  className?: string;
  hoverEffect?: boolean;
}

export const AnimatedCard = forwardRef<HTMLDivElement, AnimatedCardProps>(
  ({ children, className, hoverEffect = true, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        initial="rest"
        whileHover={hoverEffect ? "hover" : undefined}
        whileTap={hoverEffect ? "tap" : undefined}
        variants={cardHover}
        className={cn(
          "rounded-xl border border-border bg-card transition-colors",
          className
        )}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);
AnimatedCard.displayName = "AnimatedCard";

/**
 * Animated list container with stagger effect
 */
interface AnimatedListProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  className?: string;
}

export const AnimatedList = forwardRef<HTMLDivElement, AnimatedListProps>(
  ({ children, className, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        initial="hidden"
        animate="visible"
        variants={staggerContainer}
        className={className}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);
AnimatedList.displayName = "AnimatedList";

/**
 * Animated list item
 */
interface AnimatedListItemProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  className?: string;
}

export const AnimatedListItem = forwardRef<HTMLDivElement, AnimatedListItemProps>(
  ({ children, className, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        variants={staggerItem}
        className={className}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);
AnimatedListItem.displayName = "AnimatedListItem";

/**
 * Fade in wrapper
 */
interface FadeInProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  className?: string;
  direction?: "up" | "down" | "left" | "right" | "none";
  delay?: number;
}

export const FadeIn = forwardRef<HTMLDivElement, FadeInProps>(
  ({ children, className, direction = "up", delay = 0, ...props }, ref) => {
    const variants = {
      up: fadeInUp,
      down: fadeInDown,
      left: slideInLeft,
      right: slideInRight,
      none: fadeIn,
    };

    return (
      <motion.div
        ref={ref}
        initial="hidden"
        animate="visible"
        variants={variants[direction]}
        transition={{ delay }}
        className={className}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);
FadeIn.displayName = "FadeIn";

/**
 * Scale in wrapper
 */
interface ScaleInProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  className?: string;
  delay?: number;
}

export const ScaleIn = forwardRef<HTMLDivElement, ScaleInProps>(
  ({ children, className, delay = 0, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        initial="hidden"
        animate="visible"
        variants={scaleIn}
        transition={{ delay }}
        className={className}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);
ScaleIn.displayName = "ScaleIn";

/**
 * Hover scale wrapper for icons/buttons
 */
interface HoverScaleProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  className?: string;
  scale?: number;
}

export const HoverScale = forwardRef<HTMLDivElement, HoverScaleProps>(
  ({ children, className, scale = 1.05, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        whileHover={{ scale }}
        whileTap={{ scale: 0.95 }}
        transition={{ duration: 0.2 }}
        className={className}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);
HoverScale.displayName = "HoverScale";
