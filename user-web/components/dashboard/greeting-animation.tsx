"use client";

/**
 * GreetingAnimation Component
 * Lottie animation displayed near the greeting text
 * Uses the game.json animation from public folder
 */

import { useEffect, useState } from "react";
import dynamic from "next/dynamic";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

// Dynamically import Lottie to avoid SSR issues
const Lottie = dynamic(() => import("lottie-react"), { ssr: false });

interface GreetingAnimationProps {
  className?: string;
  size?: number;
}

/**
 * GreetingAnimation - Lottie animation for dashboard greeting
 * Fetches animation data from public/lottie/icons/game.json
 */
export function GreetingAnimation({ className, size = 120 }: GreetingAnimationProps) {
  const [isClient, setIsClient] = useState(false);
  const [animationData, setAnimationData] = useState<object | null>(null);

  useEffect(() => {
    setIsClient(true);
    // Fetch the animation data from public folder
    fetch("/lottie/icons/game.json")
      .then((res) => res.json())
      .then((data) => setAnimationData(data))
      .catch((err) => console.error("Failed to load animation:", err));
  }, []);

  if (!isClient || !animationData) {
    // SSR fallback or loading state - empty div with same dimensions
    return <div style={{ width: size, height: size }} className={className} />;
  }

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: 0.3, duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
      className={cn("pointer-events-none", className)}
      style={{ width: size, height: size }}
    >
      <Lottie
        animationData={animationData}
        loop={true}
        autoplay={true}
        style={{ width: "100%", height: "100%" }}
      />
    </motion.div>
  );
}

/**
 * CSS-based fallback animation for browsers without Lottie support
 * Uses floating dots with staggered animations
 */
export function GreetingAnimationFallback({ className }: { className?: string }) {
  return (
    <div className={cn("relative w-24 h-24", className)}>
      {[...Array(5)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-2 h-2 rounded-full bg-primary/40"
          initial={{ opacity: 0, scale: 0 }}
          animate={{
            opacity: [0, 0.6, 0],
            scale: [0, 1, 0],
            x: [0, (i % 2 === 0 ? 1 : -1) * (10 + i * 5)],
            y: [0, -15 - i * 8],
          }}
          transition={{
            duration: 2.5,
            delay: i * 0.3,
            repeat: Infinity,
            ease: "easeOut",
          }}
          style={{
            left: `${30 + i * 10}%`,
            top: `${50 + (i % 3) * 10}%`,
          }}
        />
      ))}
    </div>
  );
}
