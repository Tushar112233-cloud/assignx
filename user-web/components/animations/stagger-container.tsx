"use client";

import { motion, HTMLMotionProps } from "framer-motion";
import { forwardRef } from "react";

export interface StaggerContainerProps extends Omit<HTMLMotionProps<"div">, "variants"> {
  children: React.ReactNode;
  staggerDelay?: number;
  delayChildren?: number;
}

export const StaggerContainer = forwardRef<HTMLDivElement, StaggerContainerProps>(
  ({ children, staggerDelay = 0.05, delayChildren = 0.1, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        variants={{
          hidden: { opacity: 0 },
          visible: {
            opacity: 1,
            transition: { staggerChildren: staggerDelay, delayChildren },
          },
        }}
        initial="hidden"
        animate="visible"
        exit="hidden"
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);

StaggerContainer.displayName = "StaggerContainer";

export interface StaggerItemProps extends Omit<HTMLMotionProps<"div">, "variants"> {
  children: React.ReactNode;
}

export const StaggerItem = forwardRef<HTMLDivElement, StaggerItemProps>(
  ({ children, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        variants={{
          hidden: { opacity: 0, y: 20 },
          visible: { opacity: 1, y: 0, transition: { duration: 0.25 } },
        }}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);

StaggerItem.displayName = "StaggerItem";
