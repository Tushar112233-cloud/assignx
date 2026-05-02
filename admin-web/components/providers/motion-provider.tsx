"use client";

import { LazyMotion, domAnimation } from "framer-motion";

interface MotionProviderProps {
  children: React.ReactNode;
}

/**
 * Motion provider using LazyMotion for optimized bundle size
 * Reduces framer-motion bundle from ~150KB to ~25KB by loading
 * only the DOM animation features on demand
 */
export function MotionProvider({ children }: MotionProviderProps) {
  return <LazyMotion features={domAnimation}>{children}</LazyMotion>;
}
