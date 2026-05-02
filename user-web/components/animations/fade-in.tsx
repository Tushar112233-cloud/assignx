"use client";

import { motion, HTMLMotionProps, useInView } from "framer-motion";
import { forwardRef, useRef } from "react";

type FadeDirection = "up" | "down" | "none" | "scale";

export interface FadeInProps extends Omit<HTMLMotionProps<"div">, "variants"> {
  children: React.ReactNode;
  direction?: FadeDirection;
  delay?: number;
  duration?: number;
  triggerOnView?: boolean;
  once?: boolean;
}

const variantMap = {
  up: {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 },
  },
  down: {
    hidden: { opacity: 0, y: -20 },
    visible: { opacity: 1, y: 0 },
  },
  none: {
    hidden: { opacity: 0 },
    visible: { opacity: 1 },
  },
  scale: {
    hidden: { opacity: 0, scale: 0.95 },
    visible: { opacity: 1, scale: 1 },
  },
};

export const FadeIn = forwardRef<HTMLDivElement, FadeInProps>(
  ({ children, direction = "up", delay = 0, duration = 0.25, triggerOnView = false, once = true, ...props }, ref) => {
    const internalRef = useRef<HTMLDivElement>(null);
    const isInView = useInView(internalRef, { once, margin: "-100px" });

    const variants = variantMap[direction];
    const shouldAnimate = triggerOnView ? isInView : true;

    return (
      <motion.div
        ref={ref || internalRef}
        variants={variants}
        initial="hidden"
        animate={shouldAnimate ? "visible" : "hidden"}
        transition={{ delay, duration, ease: [0.25, 0.1, 0.25, 1] }}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);

FadeIn.displayName = "FadeIn";
