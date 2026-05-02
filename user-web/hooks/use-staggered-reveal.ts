"use client";

import { useMemo } from "react";
import type { Variants, Easing } from "framer-motion";

interface StaggerConfig {
  staggerChildren?: number;
  delayChildren?: number;
  duration?: number;
  ease?: Easing;
}

/**
 * Hook that generates staggered animation variants for Framer Motion
 * Used for choreographed content reveal after skeleton
 */
export function useStaggeredReveal(config: StaggerConfig = {}) {
  const {
    staggerChildren = 0.05,
    delayChildren = 0.1,
    duration = 0.4,
    ease = [0.25, 0.46, 0.45, 0.94] as const,
  } = config;

  const variants = useMemo<{ container: Variants; item: Variants }>(() => ({
    container: {
      hidden: { opacity: 0 },
      visible: {
        opacity: 1,
        transition: {
          staggerChildren,
          delayChildren,
        },
      },
    },
    item: {
      hidden: {
        opacity: 0,
        y: 12,
        scale: 0.98,
      },
      visible: {
        opacity: 1,
        y: 0,
        scale: 1,
        transition: {
          duration,
          ease,
        },
      },
    },
  }), [staggerChildren, delayChildren, duration, ease]);

  return variants;
}

export default useStaggeredReveal;
