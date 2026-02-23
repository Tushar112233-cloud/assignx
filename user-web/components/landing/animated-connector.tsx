/**
 * @fileoverview AnimatedConnector - Connecting line component for workflow animation
 *
 * Features:
 * - SVG animated dashed line with flowing effect
 * - Flowing particle effect along the path
 * - Color gradient along the path
 * - Responsive (horizontal on desktop, vertical on mobile)
 * - Gemini-style pulse animation
 */

"use client";

import { motion, useReducedMotion } from "framer-motion";

import { cn } from "@/lib/utils";

/**
 * Props for AnimatedConnector component
 */
interface AnimatedConnectorProps {
  /** Start color for the gradient (hex) */
  startColor: string;
  /** End color for the gradient (hex) */
  endColor: string;
  /** Animation delay in seconds */
  delay?: number;
  /** Orientation of the connector */
  orientation?: "horizontal" | "vertical";
  /** Unique identifier for SVG gradient */
  id: string;
  /** Index for unique gradient IDs */
  index?: number;
}

/**
 * AnimatedConnector - Connecting line between workflow stages
 *
 * Creates an animated path with:
 * - Gradient color transition
 * - Flowing dash animation
 * - Particle dots traveling along the path
 * - Pulse glow effect
 *
 * @example
 * ```tsx
 * <AnimatedConnector
 *   startColor="#765341"
 *   endColor="#8D6A58"
 *   delay={0.5}
 *   orientation="horizontal"
 *   id="connector-1"
 * />
 * ```
 */
export function AnimatedConnector({
  startColor,
  endColor,
  delay = 0,
  orientation = "horizontal",
  id,
  index = 0,
}: AnimatedConnectorProps) {
  const prefersReducedMotion = useReducedMotion();

  const isHorizontal = orientation === "horizontal";
  const gradientId = `gradient-${id}-${index}`;
  const glowId = `glow-${id}-${index}`;

  return (
    <div
      className={cn(
        "relative flex items-center justify-center",
        isHorizontal ? "w-16 sm:w-24 md:w-32 h-2" : "h-12 sm:h-16 w-2"
      )}
    >
      <svg
        className={cn(
          "overflow-visible",
          isHorizontal ? "w-full h-full" : "w-full h-full"
        )}
        viewBox={isHorizontal ? "0 0 100 10" : "0 0 10 100"}
        preserveAspectRatio="none"
      >
        <defs>
          {/* Gradient definition */}
          <linearGradient
            id={gradientId}
            x1={isHorizontal ? "0%" : "50%"}
            y1={isHorizontal ? "50%" : "0%"}
            x2={isHorizontal ? "100%" : "50%"}
            y2={isHorizontal ? "50%" : "100%"}
          >
            <stop offset="0%" stopColor={startColor} />
            <stop offset="100%" stopColor={endColor} />
          </linearGradient>

          {/* Glow filter */}
          <filter id={glowId} x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur stdDeviation="2" result="coloredBlur" />
            <feMerge>
              <feMergeNode in="coloredBlur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        {/* Background line (static) */}
        <motion.line
          x1={isHorizontal ? 0 : 5}
          y1={isHorizontal ? 5 : 0}
          x2={isHorizontal ? 100 : 5}
          y2={isHorizontal ? 5 : 100}
          stroke={`url(#${gradientId})`}
          strokeWidth="2"
          strokeOpacity="0.2"
          initial={{ pathLength: 0 }}
          whileInView={{ pathLength: 1 }}
          viewport={{ once: true }}
          transition={{ delay, duration: 0.8, ease: "easeOut" }}
        />

        {/* Animated dashed line */}
        <motion.line
          x1={isHorizontal ? 0 : 5}
          y1={isHorizontal ? 5 : 0}
          x2={isHorizontal ? 100 : 5}
          y2={isHorizontal ? 5 : 100}
          stroke={`url(#${gradientId})`}
          strokeWidth="2"
          strokeDasharray="6 4"
          strokeLinecap="round"
          filter={`url(#${glowId})`}
          initial={{ pathLength: 0, strokeDashoffset: 0 }}
          whileInView={{ pathLength: 1 }}
          viewport={{ once: true }}
          transition={{ delay, duration: 0.8, ease: "easeOut" }}
          animate={
            prefersReducedMotion
              ? {}
              : {
                  strokeDashoffset: [0, -20],
                }
          }
          style={
            prefersReducedMotion
              ? {}
              : {
                  animation: "dash-flow 1.5s linear infinite",
                }
          }
        />

        {/* Flowing particles */}
        {!prefersReducedMotion && (
          <>
            {/* Primary particle */}
            <motion.circle
              r="3"
              fill={startColor}
              filter={`url(#${glowId})`}
              initial={{
                cx: isHorizontal ? 0 : 5,
                cy: isHorizontal ? 5 : 0,
                opacity: 0,
              }}
              animate={{
                cx: isHorizontal ? [0, 100] : 5,
                cy: isHorizontal ? 5 : [0, 100],
                opacity: [0, 1, 1, 0],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                delay: delay + 0.5,
                ease: "linear",
              }}
            />

            {/* Secondary particle (offset) */}
            <motion.circle
              r="2"
              fill={endColor}
              opacity={0.7}
              initial={{
                cx: isHorizontal ? 0 : 5,
                cy: isHorizontal ? 5 : 0,
                opacity: 0,
              }}
              animate={{
                cx: isHorizontal ? [0, 100] : 5,
                cy: isHorizontal ? 5 : [0, 100],
                opacity: [0, 0.7, 0.7, 0],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                delay: delay + 1.5,
                ease: "linear",
              }}
            />
          </>
        )}
      </svg>

      {/* Pulse effect at midpoint */}
      {!prefersReducedMotion && (
        <motion.div
          className={cn(
            "absolute rounded-full",
            isHorizontal ? "w-2 h-2" : "w-2 h-2"
          )}
          style={{
            background: `linear-gradient(135deg, ${startColor}, ${endColor})`,
            left: "50%",
            top: "50%",
            transform: "translate(-50%, -50%)",
          }}
          animate={{
            scale: [1, 1.5, 1],
            opacity: [0.5, 0.8, 0.5],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            delay: delay + 0.3,
            ease: "easeInOut",
          }}
        />
      )}

      {/* CSS for dash animation */}
      <style jsx>{`
        @keyframes dash-flow {
          from {
            stroke-dashoffset: 0;
          }
          to {
            stroke-dashoffset: -20;
          }
        }
      `}</style>
    </div>
  );
}
