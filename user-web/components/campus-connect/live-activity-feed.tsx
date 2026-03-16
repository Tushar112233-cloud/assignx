"use client";

/**
 * LiveActivityFeed - Container managing floating post cards
 * Creates an infinite loop of rising cards showing recent activity
 * Cards are positioned around the globe for a dynamic effect
 */

import { useState, useEffect } from "react";
import { motion, useReducedMotion, AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";

// Sample posts data - represents recent activity
interface FloatingPost {
  id: string;
  title: string;
  category: "questions" | "housing" | "opportunities" | "events" | "marketplace" | "resources";
  college: string;
  timeAgo: string;
}

/**
 * Activity posts - populated from real data in production
 */
const samplePosts: FloatingPost[] = [];

const categoryColors: Record<string, { bg: string; text: string }> = {
  questions: { bg: "bg-blue-500/20", text: "text-blue-300" },
  housing: { bg: "bg-emerald-500/20", text: "text-emerald-300" },
  opportunities: { bg: "bg-violet-500/20", text: "text-violet-300" },
  events: { bg: "bg-amber-500/20", text: "text-amber-300" },
  marketplace: { bg: "bg-pink-500/20", text: "text-pink-300" },
  resources: { bg: "bg-cyan-500/20", text: "text-cyan-300" },
};

const categoryLabels: Record<string, string> = {
  questions: "Question",
  housing: "Housing",
  opportunities: "Job",
  events: "Event",
  marketplace: "Market",
  resources: "Resource",
};

// Fixed positions around the globe
const cardPositions = [
  { top: "8%", left: "5%", animDelay: 0 },
  { top: "25%", right: "0%", animDelay: 1.5 },
  { bottom: "30%", left: "0%", animDelay: 3 },
  { bottom: "8%", right: "8%", animDelay: 4.5 },
];

interface LiveActivityFeedProps {
  maxVisibleCards?: number;
  className?: string;
}

export function LiveActivityFeed({
  maxVisibleCards = 4,
  className,
}: LiveActivityFeedProps) {
  const prefersReducedMotion = useReducedMotion();
  const [visiblePosts, setVisiblePosts] = useState<number[]>([0, 1, 2, 3]);

  // No posts to display
  if (samplePosts.length === 0) {
    return (
      <div className={cn("relative w-full h-full flex items-center justify-center", className)}>
        <p className="text-xs text-white/40">No activity yet</p>
      </div>
    );
  }

  // Cycle through posts
  useEffect(() => {
    if (prefersReducedMotion) return;

    const interval = setInterval(() => {
      setVisiblePosts((prev) =>
        prev.map((idx) => (idx + 1) % samplePosts.length)
      );
    }, 8000);

    return () => clearInterval(interval);
  }, [prefersReducedMotion]);

  // For reduced motion, show static layout
  if (prefersReducedMotion) {
    return (
      <div className={cn("relative w-full h-full", className)}>
        {cardPositions.slice(0, 2).map((pos, i) => {
          const post = samplePosts[i];
          const colors = categoryColors[post.category];
          return (
            <div
              key={post.id}
              style={{
                position: "absolute",
                ...pos,
              }}
              className="w-48 p-3 rounded-xl bg-white/10 backdrop-blur-md border border-white/20"
            >
              <div className="flex items-center gap-2 mb-2">
                <div className="h-6 w-6 rounded-full bg-gradient-to-br from-violet-400 to-fuchsia-400 flex items-center justify-center text-[10px] font-bold text-white">
                  {post.college.charAt(0)}
                </div>
                <span className="text-[10px] text-white/60 truncate flex-1">
                  {post.college}
                </span>
              </div>
              <p className="text-xs font-medium text-white/90 line-clamp-2 mb-2">
                {post.title}
              </p>
              <span className={cn("px-2 py-0.5 rounded-full text-[10px] font-medium", colors.bg, colors.text)}>
                {categoryLabels[post.category]}
              </span>
            </div>
          );
        })}
      </div>
    );
  }

  return (
    <div className={cn("relative w-full h-full", className)}>
      <AnimatePresence mode="popLayout">
        {cardPositions.map((pos, i) => {
          const postIndex = visiblePosts[i];
          const post = samplePosts[postIndex];
          const colors = categoryColors[post.category];

          return (
            <motion.div
              key={`${postIndex}-${i}`}
              initial={{ opacity: 0, scale: 0.8, y: 20 }}
              animate={{
                opacity: 1,
                scale: 1,
                y: [0, -8, 0],
              }}
              exit={{ opacity: 0, scale: 0.8, y: -20 }}
              transition={{
                opacity: { duration: 0.5 },
                scale: { duration: 0.5 },
                y: {
                  duration: 4,
                  repeat: Infinity,
                  ease: "easeInOut",
                  delay: pos.animDelay,
                },
              }}
              style={{
                position: "absolute",
                top: pos.top,
                left: pos.left,
                right: pos.right,
                bottom: pos.bottom,
              }}
              className="w-52 p-3 rounded-xl bg-white/[0.08] backdrop-blur-lg border border-white/[0.12] shadow-xl shadow-black/10 hover:bg-white/[0.12] transition-colors cursor-pointer"
            >
              {/* Header */}
              <div className="flex items-center gap-2 mb-2">
                <div className="h-7 w-7 rounded-full bg-gradient-to-br from-violet-400 to-fuchsia-400 flex items-center justify-center text-[10px] font-bold text-white shrink-0">
                  {post.college.charAt(0)}
                </div>
                <span className="text-[10px] text-white/50 truncate flex-1">
                  {post.college}
                </span>
                <span className="text-[10px] text-white/30">{post.timeAgo}</span>
              </div>

              {/* Title */}
              <p className="text-xs font-medium text-white/90 line-clamp-2 mb-2.5 leading-relaxed">
                {post.title}
              </p>

              {/* Category Badge */}
              <div
                className={cn(
                  "inline-flex px-2 py-0.5 rounded-full text-[10px] font-medium border border-white/10",
                  colors.bg,
                  colors.text
                )}
              >
                {categoryLabels[post.category]}
              </div>
            </motion.div>
          );
        })}
      </AnimatePresence>
    </div>
  );
}

export default LiveActivityFeed;
