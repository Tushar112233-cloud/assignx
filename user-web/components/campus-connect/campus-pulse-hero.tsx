"use client";

/**
 * CampusPulseHero - Immersive "Live Campus Pulse" hero section
 *
 * Features:
 * - Left side: Value proposition with live stats
 * - Right side: 3D Globe with floating post cards
 * - Background: Deep gradient with animated orbs
 *
 * Creates FOMO and immediately communicates platform value
 */

import { useEffect, useState } from "react";
import Link from "next/link";
import { motion, useReducedMotion } from "framer-motion";
import {
  Plus,
  ArrowRight,
  Compass,
  Users,
  GraduationCap,
  MessageSquare,
  Zap,
  Sparkles,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { LiveStatsBadge } from "./live-stats-badge";
import { LiveActivityFeed } from "./live-activity-feed";
import { ActivityGlobe } from "./activity-globe";

// Animation variants
const fadeInUp = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

const staggerContainer = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.1, delayChildren: 0.1 },
  },
};

const pulseGlow = {
  initial: { scale: 1, opacity: 0.5 },
  animate: {
    scale: [1, 1.2, 1],
    opacity: [0.5, 0.8, 0.5],
    transition: {
      duration: 3,
      repeat: Infinity,
      ease: "easeInOut" as const,
    },
  },
};

interface CampusPulseHeroProps {
  /** User's first name for personalized greeting */
  firstName: string;
  /** Whether the user has verified their college */
  isVerified: boolean;
  /** Number of posts in the last hour (can be from API) */
  postsLastHour?: number;
  /** Number of students currently online */
  studentsOnline?: number;
  /** Number of active colleges */
  activeColleges?: number;
  /** Custom class name */
  className?: string;
}

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Morning";
  if (hour < 17) return "Afternoon";
  return "Evening";
}

export function CampusPulseHero({
  firstName,
  isVerified,
  postsLastHour = 47,
  studentsOnline = 234,
  activeColleges = 12,
  className,
}: CampusPulseHeroProps) {
  const prefersReducedMotion = useReducedMotion();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={staggerContainer}
      className={cn(
        "relative overflow-hidden rounded-3xl mb-8",
        "bg-gradient-to-br from-slate-900 via-violet-950 to-indigo-950",
        className
      )}
    >
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        {/* Gradient Orbs */}
        <motion.div
          variants={prefersReducedMotion ? {} : pulseGlow}
          initial="initial"
          animate="animate"
          className="absolute top-0 right-1/4 w-96 h-96 bg-gradient-to-br from-violet-500/30 to-fuchsia-500/20 rounded-full blur-3xl"
        />
        <motion.div
          variants={prefersReducedMotion ? {} : pulseGlow}
          initial="initial"
          animate="animate"
          transition={{ delay: 1 }}
          className="absolute bottom-0 left-0 w-80 h-80 bg-gradient-to-br from-blue-500/20 to-cyan-500/20 rounded-full blur-3xl translate-y-1/2 -translate-x-1/2"
        />
        <motion.div
          variants={prefersReducedMotion ? {} : pulseGlow}
          initial="initial"
          animate="animate"
          transition={{ delay: 2 }}
          className="absolute top-1/2 right-0 w-64 h-64 bg-gradient-to-br from-fuchsia-500/20 to-pink-500/15 rounded-full blur-3xl translate-x-1/2"
        />

        {/* Grid Pattern */}
        <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.02)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.02)_1px,transparent_1px)] bg-[size:50px_50px]" />

        {/* Sparkle particles (subtle) */}
        {!prefersReducedMotion && mounted && (
          <>
            {[...Array(6)].map((_, i) => (
              <motion.div
                key={i}
                className="absolute h-1 w-1 bg-white/30 rounded-full"
                style={{
                  left: `${20 + i * 15}%`,
                  top: `${30 + (i % 3) * 20}%`,
                }}
                animate={{
                  opacity: [0, 1, 0],
                  scale: [0, 1, 0],
                }}
                transition={{
                  duration: 3,
                  repeat: Infinity,
                  delay: i * 0.5,
                  ease: "easeInOut",
                }}
              />
            ))}
          </>
        )}
      </div>

      {/* Main Content Grid */}
      <div className="relative z-10 grid grid-cols-1 lg:grid-cols-[1fr_1.2fr] gap-8 lg:gap-12 p-6 md:p-8 lg:p-12 min-h-[420px] md:min-h-[480px] lg:min-h-[520px]">
        {/* Left Side - Value Proposition */}
        <div className="flex flex-col justify-center space-y-5">
          {/* Badge */}
          <motion.div variants={fadeInUp} className="flex items-center gap-3">
            <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center shadow-lg shadow-violet-500/30">
              <Compass className="h-5 w-5 text-white" />
            </div>
            <span className="text-sm font-medium text-violet-300 tracking-wide uppercase">
              Campus Connect
            </span>
          </motion.div>

          {/* Dynamic Headline */}
          <motion.div variants={fadeInUp}>
            <h1 className="text-2xl md:text-3xl lg:text-4xl xl:text-5xl font-bold text-white leading-tight mb-2">
              Good {getGreeting()},{" "}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-violet-400 to-fuchsia-400">
                {firstName}
              </span>
            </h1>
            <p className="text-xl md:text-2xl lg:text-3xl xl:text-4xl font-bold text-white flex items-center gap-2 flex-wrap leading-tight">
              Your Campus is{" "}
              <span className="relative inline-flex items-center">
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-400 via-violet-400 to-cyan-400">
                  BUZZING
                </span>
                <Zap className="h-5 w-5 md:h-6 md:w-6 text-amber-400 ml-1" />
              </span>
            </p>
          </motion.div>

          {/* Live Stats */}
          <motion.div variants={fadeInUp} className="flex flex-wrap gap-2.5">
            <LiveStatsBadge
              value={postsLastHour}
              label="posts in last hour"
              icon={MessageSquare}
              color="violet"
            />
            <LiveStatsBadge
              value={studentsOnline}
              label="students online"
              icon={Users}
              color="emerald"
            />
            <LiveStatsBadge
              value={activeColleges}
              label="colleges active"
              icon={GraduationCap}
              color="blue"
              autoIncrement={false}
            />
          </motion.div>

          {/* Description */}
          <motion.p
            variants={fadeInUp}
            className="text-sm md:text-base text-slate-300/90 max-w-md leading-relaxed"
          >
            Join conversations, discover opportunities, and connect with students
            across 500+ colleges. Your campus community awaits.
          </motion.p>

          {/* CTA Buttons */}
          <motion.div variants={fadeInUp} className="flex flex-wrap gap-3 pt-1">
            {isVerified ? (
              <Link
                href="/campus-connect/create"
                className="group flex items-center gap-2.5 px-5 py-2.5 rounded-xl bg-gradient-to-r from-violet-600 to-fuchsia-600 text-white font-medium shadow-lg shadow-violet-500/25 hover:shadow-xl hover:shadow-violet-500/35 hover:-translate-y-0.5 transition-all text-sm"
              >
                <Plus className="h-4 w-4" />
                <span>Create Post</span>
                <ArrowRight className="h-3.5 w-3.5 opacity-70 group-hover:translate-x-0.5 transition-transform" />
              </Link>
            ) : (
              <Link
                href="/verify-college"
                className="group flex items-center gap-2.5 px-5 py-2.5 rounded-xl bg-gradient-to-r from-amber-500 to-orange-500 text-white font-medium shadow-lg shadow-amber-500/25 hover:shadow-xl hover:shadow-amber-500/35 hover:-translate-y-0.5 transition-all text-sm"
              >
                <GraduationCap className="h-4 w-4" />
                <span>Verify College to Post</span>
                <ArrowRight className="h-3.5 w-3.5 opacity-70 group-hover:translate-x-0.5 transition-transform" />
              </Link>
            )}
            <button className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/10 backdrop-blur-sm text-white font-medium hover:bg-white/15 transition-all border border-white/10 text-sm">
              <Sparkles className="h-4 w-4" />
              <span>Explore</span>
            </button>
          </motion.div>
        </div>

        {/* Right Side - Live Activity Visualization */}
        <div className="relative hidden lg:flex items-center justify-center min-h-[380px]">
          {/* Globe in the center background */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="relative w-[380px] h-[380px] xl:w-[420px] xl:h-[420px]">
              <ActivityGlobe className="w-full h-full" />
            </div>
          </div>

          {/* Floating cards positioned around the globe */}
          <div className="absolute inset-0">
            <LiveActivityFeed maxVisibleCards={4} />
          </div>
        </div>

        {/* Mobile Activity Indicator */}
        <motion.div
          variants={fadeInUp}
          className="lg:hidden flex items-center justify-center gap-4 pt-2"
        >
          <div className="flex -space-x-2">
            {[...Array(4)].map((_, i) => (
              <div
                key={i}
                className="h-8 w-8 rounded-full bg-gradient-to-br from-violet-400 to-fuchsia-400 border-2 border-slate-900"
                style={{ zIndex: 4 - i }}
              />
            ))}
          </div>
          <span className="text-sm text-white/70">
            <span className="font-semibold text-white">{studentsOnline}+</span> students
            active now
          </span>
        </motion.div>
      </div>
    </motion.div>
  );
}

export default CampusPulseHero;
