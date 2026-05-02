"use client";

/**
 * AnimatedCard - Card component with hover lift and micro-interactions
 * Features smooth shadow transitions and optional press feedback
 */

import * as React from "react";
import { motion, type HTMLMotionProps } from "framer-motion";

import { cn } from "@/lib/utils";
import { cardHover, fadeInUp, springs } from "@/lib/animations/variants";

type MotionDivProps = HTMLMotionProps<"div">;

export interface AnimatedCardProps extends Omit<MotionDivProps, "ref"> {
  /** Disable hover lift animation */
  disableHover?: boolean;
  /** Enable press/tap feedback */
  pressable?: boolean;
  /** Entry animation on mount */
  animateOnMount?: boolean;
  /** Custom hover scale (default: lift -4px) */
  hoverScale?: number;
}

const AnimatedCard = React.forwardRef<HTMLDivElement, AnimatedCardProps>(
  (
    {
      className,
      disableHover = false,
      pressable = false,
      animateOnMount = false,
      hoverScale,
      children,
      ...props
    },
    ref
  ) => {
    const hoverProps = disableHover
      ? {}
      : {
          variants: cardHover,
          initial: "rest",
          whileHover: "hover",
          whileTap: pressable ? "tap" : undefined,
        };

    const mountProps = animateOnMount
      ? {
          initial: "hidden",
          animate: "visible",
          variants: fadeInUp,
        }
      : {};

    return (
      <motion.div
        ref={ref}
        data-slot="animated-card"
        className={cn(
          "bg-card text-card-foreground flex flex-col gap-6 rounded-2xl border py-6",
          "shadow-card transition-shadow duration-200",
          pressable && "cursor-pointer",
          className
        )}
        {...hoverProps}
        {...mountProps}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);

AnimatedCard.displayName = "AnimatedCard";

/**
 * AnimatedCardHeader - Header section with optional action slot
 */
const AnimatedCardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    data-slot="animated-card-header"
    className={cn(
      "grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6",
      "has-data-[slot=card-action]:grid-cols-[1fr_auto]",
      className
    )}
    {...props}
  />
));

AnimatedCardHeader.displayName = "AnimatedCardHeader";

/**
 * AnimatedCardTitle - Title with optional icon animation
 */
const AnimatedCardTitle = React.forwardRef<
  HTMLHeadingElement,
  React.HTMLAttributes<HTMLHeadingElement> & { icon?: React.ReactNode }
>(({ className, icon, children, ...props }, ref) => (
  <h3
    ref={ref}
    data-slot="animated-card-title"
    className={cn(
      "flex items-center gap-2 text-lg font-semibold leading-none tracking-tight",
      className
    )}
    {...props}
  >
    {icon && (
      <motion.span
        className="inline-flex text-primary"
        whileHover={{ scale: 1.1, rotate: 5 }}
        transition={springs.bouncy}
      >
        {icon}
      </motion.span>
    )}
    {children}
  </h3>
));

AnimatedCardTitle.displayName = "AnimatedCardTitle";

/**
 * AnimatedCardDescription - Subtle description text
 */
const AnimatedCardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    data-slot="animated-card-description"
    className={cn("text-sm text-muted-foreground", className)}
    {...props}
  />
));

AnimatedCardDescription.displayName = "AnimatedCardDescription";

/**
 * AnimatedCardAction - Action slot in header (top-right)
 */
const AnimatedCardAction = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    data-slot="card-action"
    className={cn(
      "col-start-2 row-span-2 row-start-1 self-start justify-self-end",
      className
    )}
    {...props}
  />
));

AnimatedCardAction.displayName = "AnimatedCardAction";

/**
 * AnimatedCardContent - Main content area
 */
const AnimatedCardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    data-slot="animated-card-content"
    className={cn("px-6", className)}
    {...props}
  />
));

AnimatedCardContent.displayName = "AnimatedCardContent";

/**
 * AnimatedCardFooter - Footer with optional border
 */
const AnimatedCardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & { bordered?: boolean }
>(({ className, bordered = false, ...props }, ref) => (
  <div
    ref={ref}
    data-slot="animated-card-footer"
    className={cn(
      "flex items-center px-6",
      bordered && "border-t pt-6",
      className
    )}
    {...props}
  />
));

AnimatedCardFooter.displayName = "AnimatedCardFooter";

export {
  AnimatedCard,
  AnimatedCardHeader,
  AnimatedCardTitle,
  AnimatedCardDescription,
  AnimatedCardAction,
  AnimatedCardContent,
  AnimatedCardFooter,
};
