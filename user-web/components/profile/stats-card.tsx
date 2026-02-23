"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { motion, useReducedMotion, AnimatePresence } from "framer-motion";
import { Wallet, FolderCheck, Plus, ArrowUpRight } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { getWallet, getProjects } from "@/lib/actions/data";
import { cardHover, fadeInUp, springs } from "@/lib/animations/variants";

/**
 * Stats Card Component
 * Floating card with Wallet Balance + Total Projects Completed
 * Implements U87 from feature spec
 * Enhanced with Framer Motion micro-interactions
 */
export function StatsCard() {
  const [walletBalance, setWalletBalance] = useState<number | null>(null);
  const [projectsCompleted, setProjectsCompleted] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const prefersReducedMotion = useReducedMotion();

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [wallet, projects] = await Promise.all([
          getWallet(),
          getProjects("completed"),
        ]);
        setWalletBalance(wallet?.balance || 0);
        setProjectsCompleted(projects?.length || 0);
      } finally {
        setIsLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (isLoading) {
    return (
      <Card className="overflow-hidden">
        <CardContent className="p-0">
          <div className="grid grid-cols-2 divide-x">
            <div className="p-4">
              <Skeleton className="h-4 w-16 mb-2" />
              <Skeleton className="h-8 w-24" />
            </div>
            <div className="p-4">
              <Skeleton className="h-4 w-16 mb-2" />
              <Skeleton className="h-8 w-12" />
            </div>
          </div>
        </CardContent>
      </Card>
    );
  }

  const MotionCard = prefersReducedMotion ? Card : motion(Card);
  const cardProps = prefersReducedMotion ? {} : {
    variants: cardHover,
    initial: "rest",
    whileHover: "hover",
    whileTap: "tap",
  };

  return (
    <MotionCard
      className="overflow-hidden shadow-lg border-0 bg-gradient-to-r from-primary/5 to-primary/10"
      {...cardProps}
    >
      <CardContent className="p-0">
        <div className="grid grid-cols-2 divide-x divide-primary/10">
          {/* Wallet Balance */}
          <Link href="/wallet" className="block p-4 hover:bg-primary/5 transition-colors group">
            <motion.div
              className="flex items-center gap-2 mb-1"
              initial={prefersReducedMotion ? {} : { opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.1 }}
            >
              <motion.div
                whileHover={prefersReducedMotion ? {} : { scale: 1.15, rotate: 5 }}
                transition={springs.bouncy}
              >
                <Wallet className="h-4 w-4 text-primary" />
              </motion.div>
              <span className="text-xs text-muted-foreground font-medium">
                Wallet Balance
              </span>
            </motion.div>
            <motion.div
              className="flex items-baseline gap-1"
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
            >
              <span className="text-2xl font-bold text-primary">
                ₹{walletBalance?.toLocaleString("en-IN") || "0"}
              </span>
              <motion.div
                className="opacity-0 group-hover:opacity-100 transition-opacity"
                whileHover={prefersReducedMotion ? {} : { x: 2, y: -2 }}
              >
                <ArrowUpRight className="h-4 w-4 text-muted-foreground" />
              </motion.div>
            </motion.div>
            <p className="text-[10px] text-muted-foreground mt-1">
              Available Credits
            </p>
          </Link>

          {/* Projects Completed */}
          <Link href="/projects?tab=history" className="block p-4 hover:bg-primary/5 transition-colors group">
            <motion.div
              className="flex items-center gap-2 mb-1"
              initial={prefersReducedMotion ? {} : { opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.15 }}
            >
              <motion.div
                whileHover={prefersReducedMotion ? {} : { scale: 1.15, rotate: -5 }}
                transition={springs.bouncy}
              >
                <FolderCheck className="h-4 w-4 text-green-600" />
              </motion.div>
              <span className="text-xs text-muted-foreground font-medium">
                Projects Done
              </span>
            </motion.div>
            <motion.div
              className="flex items-baseline gap-1"
              initial={prefersReducedMotion ? {} : { opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.25 }}
            >
              <span className="text-2xl font-bold text-foreground">
                {projectsCompleted}
              </span>
              <motion.div
                className="opacity-0 group-hover:opacity-100 transition-opacity"
                whileHover={prefersReducedMotion ? {} : { x: 2, y: -2 }}
              >
                <ArrowUpRight className="h-4 w-4 text-muted-foreground" />
              </motion.div>
            </motion.div>
            <p className="text-[10px] text-muted-foreground mt-1">
              Completed
            </p>
          </Link>
        </div>

        {/* Top-up button */}
        <motion.div
          className="border-t border-primary/10 p-3"
          initial={prefersReducedMotion ? {} : { opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Button variant="outline" size="sm" className="w-full group" asChild>
            <Link href="/wallet?action=topup">
              <motion.span
                className="inline-flex items-center"
                whileHover={prefersReducedMotion ? {} : { scale: 1.02 }}
                whileTap={prefersReducedMotion ? {} : { scale: 0.98 }}
              >
                <Plus className="h-4 w-4 mr-2 group-hover:rotate-90 transition-transform duration-200" />
                Add Money to Wallet
              </motion.span>
            </Link>
          </Button>
        </motion.div>
      </CardContent>
    </MotionCard>
  );
}
