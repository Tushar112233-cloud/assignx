"use client";

/**
 * Hero Section Redesign - Premium Bento Grid Design
 *
 * Inspired by:
 * - Dashboard: Warm brown/stone theme with bento cards
 * - Projects: Glassmorphic cards with dark hero
 * - Campus Connect: Feature carousel
 * - Experts: Mesh gradient backgrounds
 * - Wallet: 2-column layout
 */

import { useState, useEffect, useMemo } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import {
  ArrowRight,
  Plus,
  Sparkles,
  CheckCircle,
  Users,
  FileText,
  GraduationCap,
  Zap,
  Star,
  TrendingUp,
  Shield,
  Clock,
  Award,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Get time-based gradient class
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 17) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

/**
 * Get greeting based on time
 */
function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "Morning";
  if (hour < 17) return "Afternoon";
  return "Evening";
}

/**
 * Feature cards data
 */
const FEATURES = [
  {
    id: "experts",
    icon: GraduationCap,
    title: "500+ Experts",
    description: "PhD scholars & professionals",
    gradient: "from-amber-400 to-orange-500",
    color: "text-amber-600 dark:text-amber-400",
  },
  {
    id: "quality",
    icon: Shield,
    title: "Quality Assured",
    description: "100% plagiarism-free work",
    gradient: "from-emerald-400 to-teal-500",
    color: "text-emerald-600 dark:text-emerald-400",
  },
  {
    id: "delivery",
    icon: Clock,
    title: "On-Time Delivery",
    description: "98% delivered before deadline",
    gradient: "from-violet-400 to-purple-500",
    color: "text-violet-600 dark:text-violet-400",
  },
  {
    id: "support",
    icon: Award,
    title: "24/7 Support",
    description: "Round-the-clock assistance",
    gradient: "from-blue-400 to-cyan-500",
    color: "text-blue-600 dark:text-blue-400",
  },
];

/**
 * Stats carousel data
 */
const STATS_CAROUSEL = [
  { value: "10,000+", label: "Happy Students", icon: Users },
  { value: "98%", label: "Success Rate", icon: TrendingUp },
  { value: "24hrs", label: "Avg. Delivery", icon: Clock },
  { value: "4.9/5", label: "Rating", icon: Star },
];

/**
 * Hero Section Component
 */
export function HeroSectionRedesign() {
  const [currentStat, setCurrentStat] = useState(0);
  const gradientClass = useMemo(() => getTimeBasedGradientClass(), []);

  // Auto-rotate stats
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentStat((prev) => (prev + 1) % STATS_CAROUSEL.length);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <section
      className={cn(
        "relative min-h-screen overflow-hidden",
        "mesh-background mesh-gradient-bottom-right-animated",
        gradientClass
      )}
    >
      {/* Decorative Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-gradient-to-br from-orange-400/10 to-amber-500/5 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-gradient-to-br from-violet-400/10 to-purple-500/5 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 h-full px-4 py-20 md:px-6 md:py-24 lg:px-8 lg:py-28">
        <div className="max-w-[1400px] mx-auto">
          {/* ═══════════════════════════════════════════════════════════ */}
          {/* MAIN CONTENT - Two Column Layout */}
          {/* ═══════════════════════════════════════════════════════════ */}
          <div className="flex flex-col lg:flex-row gap-12 lg:gap-16 items-center justify-between min-h-[80vh]">

            {/* LEFT COLUMN - Greeting & Content */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, ease: [0.25, 0.1, 0.25, 1] }}
              className="flex-1 max-w-2xl space-y-8"
            >
              {/* Greeting Badge */}
              <div className="flex items-center gap-3">
                <span className="px-4 py-2 rounded-full bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 text-sm font-medium">
                  <span className="inline-flex items-center gap-2">
                    <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                    Good {getGreeting()}! 👋
                  </span>
                </span>
              </div>

              {/* Main Headline */}
              <div>
                <h1 className="text-4xl md:text-5xl lg:text-6xl xl:text-7xl font-bold tracking-tight text-foreground mb-4">
                  Get Expert Help
                  <br />
                  <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-600 via-orange-500 to-rose-500">
                    For Any Assignment
                  </span>
                </h1>
                <p className="text-lg md:text-xl text-muted-foreground leading-relaxed max-w-xl">
                  Connect with verified PhD experts who handle your essays, research papers, and projects from start to finish. Quality guaranteed.
                </p>
              </div>

              {/* CTA Buttons */}
              <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
                <Link
                  href="/signup"
                  className="group relative overflow-hidden rounded-2xl px-8 py-4 bg-gradient-to-br from-stone-800 via-stone-900 to-neutral-900 dark:from-stone-800 dark:via-stone-900 dark:to-neutral-950 text-white transition-all duration-300 hover:shadow-2xl hover:shadow-stone-900/30 hover:-translate-y-1"
                >
                  {/* Decorative gradient overlay */}
                  <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-transparent to-rose-500/5 pointer-events-none" />

                  <div className="relative z-10 flex items-center gap-3">
                    <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-orange-400 to-rose-500 flex items-center justify-center shadow-lg shadow-orange-500/25">
                      <Plus className="h-5 w-5 text-white" strokeWidth={2.5} />
                    </div>
                    <div className="text-left">
                      <div className="font-semibold text-base">Start Your Project</div>
                      <div className="text-xs text-white/60">Free consultation</div>
                    </div>
                    <ArrowRight className="h-5 w-5 ml-2 transition-transform duration-300 group-hover:translate-x-1" />
                  </div>
                </Link>

                <Link
                  href="#features"
                  className="px-6 py-3 rounded-xl bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 hover:bg-white dark:hover:bg-white/10 transition-all duration-300 text-sm font-medium"
                >
                  Explore Features
                </Link>
              </div>

              {/* Animated Stats Carousel */}
              <div className="pt-8">
                <AnimatePresence mode="wait">
                  <motion.div
                    key={currentStat}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ duration: 0.5 }}
                    className="flex items-center gap-4 p-4 rounded-2xl bg-white/60 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10"
                  >
                    {(() => {
                      const stat = STATS_CAROUSEL[currentStat];
                      const Icon = stat.icon;
                      return (
                        <>
                          <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center shadow-lg shadow-violet-500/20">
                            <Icon className="h-6 w-6 text-white" />
                          </div>
                          <div>
                            <div className="text-2xl font-bold tabular-nums">{stat.value}</div>
                            <div className="text-sm text-muted-foreground">{stat.label}</div>
                          </div>
                        </>
                      );
                    })()}
                  </motion.div>
                </AnimatePresence>

                {/* Stat indicators */}
                <div className="flex items-center gap-2 mt-3 justify-center lg:justify-start">
                  {STATS_CAROUSEL.map((_, index) => (
                    <button
                      key={index}
                      onClick={() => setCurrentStat(index)}
                      className={cn(
                        "h-1.5 rounded-full transition-all duration-300",
                        index === currentStat ? "w-8 bg-violet-500" : "w-1.5 bg-muted-foreground/30"
                      )}
                    />
                  ))}
                </div>
              </div>
            </motion.div>

            {/* RIGHT COLUMN - Premium Bento Grid */}
            <motion.div
              initial={{ opacity: 0, x: 30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2, ease: [0.25, 0.1, 0.25, 1] }}
              className="w-full lg:w-auto lg:flex-shrink-0"
            >
              <div className="grid grid-cols-2 gap-4 w-full lg:w-[500px]">
                {FEATURES.map((feature, index) => {
                  const Icon = feature.icon;

                  return (
                    <motion.div
                      key={feature.id}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 0.6, delay: 0.3 + index * 0.1 }}
                      className="group relative overflow-hidden rounded-[20px] p-6 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 transition-all duration-300 hover:shadow-xl hover:shadow-black/5 hover:-translate-y-1 hover:bg-white dark:hover:bg-white/10"
                    >
                      {/* Gradient overlay */}
                      <div className={cn(
                        "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none rounded-[20px]",
                        `${feature.gradient.replace("from-", "from-").replace("to-", "to-")}/10`
                      )} />

                      <div className="relative z-10">
                        <div className={cn(
                          "h-14 w-14 rounded-2xl bg-gradient-to-br flex items-center justify-center mb-4 shadow-lg transition-transform duration-300 group-hover:scale-110",
                          feature.gradient
                        )}>
                          <Icon className="h-6 w-6 text-white" strokeWidth={1.5} />
                        </div>

                        <h3 className="font-semibold text-foreground text-base mb-1.5">
                          {feature.title}
                        </h3>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                          {feature.description}
                        </p>
                      </div>
                    </motion.div>
                  );
                })}
              </div>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  );
}
