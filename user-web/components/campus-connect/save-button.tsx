"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Bookmark } from "lucide-react";
import { cn } from "@/lib/utils";

interface SaveButtonProps {
  isSaved: boolean;
  onSave: () => void;
  size?: "sm" | "md" | "lg";
  showLabel?: boolean;
  className?: string;
}

/**
 * SaveButton - Animated bookmark button
 * Features smooth fill animation and scale effect
 */
export function SaveButton({
  isSaved,
  onSave,
  size = "md",
  showLabel = false,
  className,
}: SaveButtonProps) {
  const [isAnimating, setIsAnimating] = useState(false);

  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsAnimating(true);
    setTimeout(() => setIsAnimating(false), 300);
    onSave();
  };

  const sizeConfig = {
    sm: { icon: "h-4 w-4", text: "text-xs", padding: "p-1.5" },
    md: { icon: "h-5 w-5", text: "text-sm", padding: "p-2" },
    lg: { icon: "h-6 w-6", text: "text-base", padding: "p-2.5" },
  };

  const config = sizeConfig[size];

  return (
    <motion.button
      onClick={handleClick}
      whileTap={{ scale: 0.9 }}
      className={cn(
        "flex items-center gap-1.5 transition-colors",
        isSaved
          ? "text-primary"
          : "text-muted-foreground hover:text-primary",
        className
      )}
    >
      <motion.div
        animate={
          isAnimating
            ? { scale: [1, 1.3, 1], y: [0, -3, 0] }
            : {}
        }
        transition={{ duration: 0.3, ease: "easeOut" }}
        className={config.padding}
      >
        <Bookmark
          className={cn(
            config.icon,
            isSaved && "fill-primary"
          )}
        />
      </motion.div>
      {showLabel && (
        <span className={cn("font-medium", config.text)}>
          {isSaved ? "Saved" : "Save"}
        </span>
      )}
    </motion.button>
  );
}

/**
 * SaveButtonOutline - Outlined version with background
 */
export function SaveButtonOutline({
  isSaved,
  onSave,
  className,
}: SaveButtonProps) {
  const [isAnimating, setIsAnimating] = useState(false);

  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsAnimating(true);
    setTimeout(() => setIsAnimating(false), 300);
    onSave();
  };

  return (
    <motion.button
      onClick={handleClick}
      whileTap={{ scale: 0.95 }}
      className={cn(
        "flex items-center gap-2 px-4 py-2 rounded-full border transition-all",
        isSaved
          ? "bg-primary/10 border-primary/30 text-primary"
          : "bg-card border-border hover:bg-muted hover:border-border/80 text-foreground",
        className
      )}
    >
      <motion.div
        animate={isAnimating ? { scale: [1, 1.3, 1], y: [0, -2, 0] } : {}}
        transition={{ duration: 0.25 }}
      >
        <Bookmark
          className={cn(
            "h-5 w-5",
            isSaved && "fill-primary"
          )}
        />
      </motion.div>
      <span className="font-medium text-sm">
        {isSaved ? "Saved" : "Save"}
      </span>
    </motion.button>
  );
}

export default SaveButton;
