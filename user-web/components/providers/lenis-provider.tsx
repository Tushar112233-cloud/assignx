"use client";

/**
 * LenisProvider - Smooth scroll provider using Lenis
 * Provides buttery smooth scrolling across the entire application
 */

import { ReactNode, useEffect, useRef } from "react";
import Lenis from "lenis";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

// Register GSAP plugins
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

interface LenisProviderProps {
  children: ReactNode;
  /** Scroll smoothness (lower = smoother, default: 0.1) */
  lerp?: number;
  /** Duration of scroll animation */
  duration?: number;
  /** Scroll direction */
  orientation?: "vertical" | "horizontal";
  /** Enable smooth scrolling on touch devices */
  touchMultiplier?: number;
  /** Infinite scroll */
  infinite?: boolean;
}

export function LenisProvider({
  children,
  lerp = 0.1,
  duration = 1.2,
  orientation = "vertical",
  touchMultiplier = 2,
  infinite = false,
}: LenisProviderProps) {
  const lenisRef = useRef<Lenis | null>(null);

  useEffect(() => {
    // Initialize Lenis
    const lenis = new Lenis({
      lerp,
      duration,
      orientation,
      touchMultiplier,
      infinite,
      smoothWheel: true,
      syncTouch: true,
    });

    lenisRef.current = lenis;

    // Connect Lenis to GSAP ScrollTrigger
    lenis.on("scroll", ScrollTrigger.update);

    // Add Lenis to GSAP ticker for smooth animation
    gsap.ticker.add((time) => {
      lenis.raf(time * 1000);
    });

    // Disable GSAP lag smoothing for better scroll sync
    gsap.ticker.lagSmoothing(0);

    // Cleanup
    return () => {
      lenis.destroy();
      gsap.ticker.remove((time) => {
        lenis.raf(time * 1000);
      });
    };
  }, [lerp, duration, orientation, touchMultiplier, infinite]);

  return <>{children}</>;
}

/**
 * Hook to access Lenis instance
 */
export function useLenis() {
  const lenisRef = useRef<Lenis | null>(null);

  useEffect(() => {
    // This is a simplified hook - in production you'd use context
    const lenis = new Lenis();
    lenisRef.current = lenis;

    return () => lenis.destroy();
  }, []);

  return lenisRef.current;
}
