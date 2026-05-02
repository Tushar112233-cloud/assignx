"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { CheckCircle2, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";

interface SuccessAnimationProps {
  onComplete: () => void;
}

/**
 * Success animation with confetti effect
 * Displayed after successful signup
 */
export function SuccessAnimation({ onComplete }: SuccessAnimationProps) {
  const [showContent, setShowContent] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setShowContent(true);
    }, 800);

    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-background">
      {/* Confetti particles */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {Array.from({ length: 50 }).map((_, i) => (
          <motion.div
            key={i}
            className="absolute h-3 w-3 rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              backgroundColor: [
                "#1e3a5f",
                "#3b82f6",
                "#64748b",
                "#22c55e",
                "#f59e0b",
              ][Math.floor(Math.random() * 5)],
            }}
            initial={{ y: -20, opacity: 1 }}
            animate={{
              y: "100vh",
              opacity: 0,
              rotate: Math.random() * 360,
            }}
            transition={{
              duration: 2 + Math.random() * 2,
              delay: Math.random() * 0.5,
              ease: "easeOut",
            }}
          />
        ))}
      </div>

      {/* Success icon */}
      <motion.div
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{
          type: "spring",
          stiffness: 200,
          damping: 15,
        }}
        className="relative mb-8"
      >
        <div className="relative">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: [0, 1.2, 1] }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="flex h-24 w-24 items-center justify-center rounded-full bg-green-500/10"
          >
            <CheckCircle2 className="h-16 w-16 text-green-500" />
          </motion.div>

          {/* Sparkles */}
          <motion.div
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.5 }}
            className="absolute -right-2 -top-2"
          >
            <Sparkles className="h-6 w-6 text-yellow-500" />
          </motion.div>
          <motion.div
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.7 }}
            className="absolute -bottom-1 -left-2"
          >
            <Sparkles className="h-5 w-5 text-yellow-500" />
          </motion.div>
        </div>
      </motion.div>

      {/* Content */}
      {showContent && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center"
        >
          <h1 className="mb-2 text-3xl font-bold">Welcome to AssignX!</h1>
          <p className="mb-8 text-muted-foreground">
            Your account has been created successfully
          </p>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
          >
            <Button size="lg" onClick={onComplete}>
              Get Started
            </Button>
          </motion.div>
        </motion.div>
      )}
    </div>
  );
}
