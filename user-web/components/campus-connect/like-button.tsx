"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Heart } from "lucide-react";
import { cn } from "@/lib/utils";

interface LikeButtonProps {
  isLiked: boolean;
  likeCount: number;
  onLike: () => void;
  size?: "sm" | "md" | "lg";
  showCount?: boolean;
  className?: string;
}

/**
 * LikeButton - Animated heart button with like count
 * Features smooth scale animation and color transition
 */
export function LikeButton({
  isLiked,
  likeCount,
  onLike,
  size = "md",
  showCount = true,
  className,
}: LikeButtonProps) {
  const [isAnimating, setIsAnimating] = useState(false);

  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsAnimating(true);
    setTimeout(() => setIsAnimating(false), 400);
    onLike();
  };

  const sizeConfig = {
    sm: { icon: "h-4 w-4", text: "text-xs", padding: "p-1.5", gap: "gap-1" },
    md: { icon: "h-5 w-5", text: "text-sm", padding: "p-2", gap: "gap-1.5" },
    lg: { icon: "h-6 w-6", text: "text-base", padding: "p-2.5", gap: "gap-2" },
  };

  const config = sizeConfig[size];

  return (
    <motion.button
      onClick={handleClick}
      whileTap={{ scale: 0.9 }}
      className={cn(
        "flex items-center transition-colors",
        config.gap,
        isLiked
          ? "text-red-500"
          : "text-muted-foreground hover:text-red-500",
        className
      )}
    >
      <motion.div
        animate={
          isAnimating
            ? {
                scale: [1, 1.3, 0.9, 1.1, 1],
                rotate: [0, -15, 15, -5, 0],
              }
            : {}
        }
        transition={{ duration: 0.4, ease: "easeOut" }}
        className={config.padding}
      >
        <Heart
          className={cn(
            config.icon,
            isLiked && "fill-red-500"
          )}
        />
      </motion.div>
      {showCount && (
        <span className={cn("font-medium", config.text)}>
          {likeCount}
        </span>
      )}
    </motion.button>
  );
}

/**
 * LikeButtonOutline - Outlined version with background on hover
 */
export function LikeButtonOutline({
  isLiked,
  likeCount,
  onLike,
  className,
}: LikeButtonProps) {
  const [isAnimating, setIsAnimating] = useState(false);

  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsAnimating(true);
    setTimeout(() => setIsAnimating(false), 400);
    onLike();
  };

  return (
    <motion.button
      onClick={handleClick}
      whileTap={{ scale: 0.95 }}
      className={cn(
        "flex items-center gap-2 px-4 py-2 rounded-full border transition-all",
        isLiked
          ? "bg-red-50 border-red-200 text-red-600 dark:bg-red-950/30 dark:border-red-800"
          : "bg-card border-border hover:bg-muted hover:border-border/80",
        className
      )}
    >
      <motion.div
        animate={
          isAnimating
            ? { scale: [1, 1.4, 1], rotate: [0, -10, 10, 0] }
            : {}
        }
        transition={{ duration: 0.3 }}
      >
        <Heart
          className={cn(
            "h-5 w-5",
            isLiked && "fill-red-500 text-red-500"
          )}
        />
      </motion.div>
      <span className="font-medium text-sm">{likeCount}</span>
    </motion.button>
  );
}

export default LikeButton;
