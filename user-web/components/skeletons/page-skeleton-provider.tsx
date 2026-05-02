"use client";

import { ReactNode } from "react";
import { motion, AnimatePresence, type Variants } from "framer-motion";
import { useMinimumLoadingTime } from "@/hooks/use-minimum-loading-time";
import { useStaggeredReveal } from "@/hooks/use-staggered-reveal";
import { useReducedMotion } from "@/hooks/use-reduced-motion";

interface PageSkeletonProviderProps {
  isLoading: boolean;
  skeleton: ReactNode;
  children: ReactNode;
  minimumDuration?: number;
  className?: string;
}

const skeletonVariants: Variants = {
  visible: {
    opacity: 1,
    filter: "blur(0px)",
  },
  exit: {
    opacity: 0,
    filter: "blur(4px)",
    transition: {
      duration: 0.3,
      ease: [0.4, 0, 1, 1] as const,
    },
  },
};

/**
 * Provider component that handles skeleton to content transitions
 * Ensures minimum loading time and choreographed reveal
 */
export function PageSkeletonProvider({
  isLoading,
  skeleton,
  children,
  minimumDuration = 1000,
  className = "",
}: PageSkeletonProviderProps) {
  const showSkeleton = useMinimumLoadingTime(isLoading, { minimumDuration });
  const { container, item } = useStaggeredReveal();
  const prefersReducedMotion = useReducedMotion();

  if (prefersReducedMotion) {
    return <div className={className}>{showSkeleton ? skeleton : children}</div>;
  }

  return (
    <AnimatePresence mode="wait">
      {showSkeleton ? (
        <motion.div
          key="skeleton"
          initial="visible"
          exit="exit"
          variants={skeletonVariants}
          className={className}
        >
          {skeleton}
        </motion.div>
      ) : (
        <motion.div
          key="content"
          initial="hidden"
          animate="visible"
          variants={container}
          className={className}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
}

/**
 * Wrapper for individual items that should stagger
 */
export function StaggerItem({
  children,
  className = ""
}: {
  children: ReactNode;
  className?: string;
}) {
  const { item } = useStaggeredReveal();

  return (
    <motion.div variants={item} className={className}>
      {children}
    </motion.div>
  );
}

export default PageSkeletonProvider;
