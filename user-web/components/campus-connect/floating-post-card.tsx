"use client";

/**
 * FloatingPostCard - Mini post preview card with rise animation
 * Used in the live activity feed to show recent posts floating up
 */

import { motion, Variants, useReducedMotion } from "framer-motion";
import { cn } from "@/lib/utils";

export interface FloatingPostData {
  id: string;
  title: string;
  category: "questions" | "housing" | "opportunities" | "events" | "marketplace" | "resources";
  college: string;
  avatar?: string;
  timeAgo: string;
}

interface FloatingPostCardProps {
  post: FloatingPostData;
  /** Animation delay in seconds */
  delay?: number;
  /** Position variant (affects starting x position) */
  position?: "left" | "center" | "right";
  /** Custom class name */
  className?: string;
  /** Inline styles for positioning */
  style?: React.CSSProperties;
}

const categoryColors = {
  questions: {
    bg: "bg-blue-500/20",
    text: "text-blue-300",
    border: "border-blue-500/30",
  },
  housing: {
    bg: "bg-emerald-500/20",
    text: "text-emerald-300",
    border: "border-emerald-500/30",
  },
  opportunities: {
    bg: "bg-violet-500/20",
    text: "text-violet-300",
    border: "border-violet-500/30",
  },
  events: {
    bg: "bg-amber-500/20",
    text: "text-amber-300",
    border: "border-amber-500/30",
  },
  marketplace: {
    bg: "bg-pink-500/20",
    text: "text-pink-300",
    border: "border-pink-500/30",
  },
  resources: {
    bg: "bg-cyan-500/20",
    text: "text-cyan-300",
    border: "border-cyan-500/30",
  },
};

const categoryLabels = {
  questions: "Question",
  housing: "Housing",
  opportunities: "Job",
  events: "Event",
  marketplace: "Market",
  resources: "Resource",
};

// Animation variants for the floating effect
export const floatingCardVariants: Variants = {
  initial: {
    y: 100,
    opacity: 0,
    scale: 0.8,
    rotateX: 15,
  },
  animate: {
    y: -200,
    opacity: [0, 1, 1, 0],
    scale: [0.8, 1, 1, 0.9],
    rotateX: [15, 0, 0, -5],
    transition: {
      duration: 10,
      ease: "linear",
      times: [0, 0.1, 0.85, 1],
    },
  },
};

// Static variant for reduced motion
const staticVariants: Variants = {
  initial: { opacity: 1 },
  animate: { opacity: 1 },
};

export function FloatingPostCard({
  post,
  delay = 0,
  position = "center",
  className,
  style,
}: FloatingPostCardProps) {
  const prefersReducedMotion = useReducedMotion();
  const colors = categoryColors[post.category];

  // Position offsets for variety
  const positionOffsets = {
    left: "-20%",
    center: "0%",
    right: "20%",
  };

  return (
    <motion.div
      variants={prefersReducedMotion ? staticVariants : floatingCardVariants}
      initial="initial"
      animate="animate"
      transition={{
        delay,
        repeat: Infinity,
        repeatDelay: 2,
      }}
      style={{
        x: positionOffsets[position],
        ...style,
      }}
      className={cn(
        "absolute w-56 p-3 rounded-xl",
        "bg-white/10 backdrop-blur-md border border-white/20",
        "shadow-lg shadow-black/10",
        className
      )}
    >
      {/* Header with avatar and time */}
      <div className="flex items-center gap-2 mb-2">
        {/* Avatar */}
        <div className="h-7 w-7 rounded-full bg-gradient-to-br from-violet-400 to-fuchsia-400 flex items-center justify-center text-xs font-bold text-white overflow-hidden">
          {post.avatar ? (
            <img
              src={post.avatar}
              alt=""
              className="h-full w-full object-cover"
            />
          ) : (
            post.college.charAt(0).toUpperCase()
          )}
        </div>

        {/* College name */}
        <span className="text-[10px] text-white/60 truncate flex-1">
          {post.college}
        </span>

        {/* Time ago */}
        <span className="text-[10px] text-white/40">{post.timeAgo}</span>
      </div>

      {/* Title */}
      <p className="text-xs font-medium text-white/90 line-clamp-2 mb-2">
        {post.title}
      </p>

      {/* Category badge */}
      <div
        className={cn(
          "inline-flex px-2 py-0.5 rounded-full text-[10px] font-medium border",
          colors.bg,
          colors.text,
          colors.border
        )}
      >
        {categoryLabels[post.category]}
      </div>
    </motion.div>
  );
}

export default FloatingPostCard;
