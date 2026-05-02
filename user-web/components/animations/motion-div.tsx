"use client";

import { motion, HTMLMotionProps } from "framer-motion";
import { forwardRef } from "react";

export interface MotionDivProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
}

export const MotionDiv = forwardRef<HTMLDivElement, MotionDivProps>(
  ({ children, ...props }, ref) => {
    return (
      <motion.div ref={ref} {...props}>
        {children}
      </motion.div>
    );
  }
);

MotionDiv.displayName = "MotionDiv";
