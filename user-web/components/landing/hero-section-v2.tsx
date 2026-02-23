"use client";

/**
 * Hero Section V2 - Clear User Type Segmentation
 *
 * Design System:
 * - Students: Warm Orange/Peach (#FF6B35, #FFB88C)
 * - Employees: Professional Blue/Indigo (#4F46E5, #818CF8)
 * - Business: Premium Purple/Violet (#7C3AED, #A78BFA)
 * - Base: Brown/Stone neutral foundation
 *
 * Features:
 * - Clear 3 user type indicators
 * - Seamless gradient flow
 * - Professional systematic colors
 */

import { useState, useMemo } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import {
  ArrowRight,
  GraduationCap,
  Briefcase,
  Building2,
  Users,
  CheckCircle,
  Sparkles,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * User type configuration - Systematic color palette
 */
const USER_TYPES = [
  {
    id: "students",
    title: "Students",
    description: "Academic excellence made easy",
    icon: GraduationCap,
    gradient: "from-orange-500 to-amber-500",
    bgGradient: "from-orange-50 to-amber-50 dark:from-orange-950/20 dark:to-amber-950/20",
    textColor: "text-orange-600 dark:text-orange-400",
    benefits: ["Essays & Research", "Expert Tutoring", "Campus Connect"],
  },
  {
    id: "employees",
    title: "Job Employees",
    description: "Professional growth support",
    icon: Briefcase,
    gradient: "from-indigo-500 to-blue-500",
    bgGradient: "from-indigo-50 to-blue-50 dark:from-indigo-950/20 dark:to-blue-950/20",
    textColor: "text-indigo-600 dark:text-indigo-400",
    benefits: ["Reports & Analysis", "Career Coaching", "Skill Development"],
  },
  {
    id: "business",
    title: "Business Owners",
    description: "Scale with expert assistance",
    icon: Building2,
    gradient: "from-violet-500 to-purple-500",
    bgGradient: "from-violet-50 to-purple-50 dark:from-violet-950/20 dark:to-purple-950/20",
    textColor: "text-violet-600 dark:text-violet-400",
    benefits: ["Business Plans", "Market Research", "Content Creation"],
  },
];

/**
 * Get time-based gradient
 */
function getTimeBasedGradientClass(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "mesh-gradient-morning";
  if (hour >= 12 && hour < 17) return "mesh-gradient-afternoon";
  return "mesh-gradient-evening";
}

/**
 * Hero Section V2
 */
export function HeroSectionV2() {
  const [selectedType, setSelectedType] = useState<string>("students");
  const gradientClass = useMemo(() => getTimeBasedGradientClass(), []);
  const currentType = USER_TYPES.find(t => t.id === selectedType) || USER_TYPES[0];

  return (
    <section
      className={cn(
        "relative min-h-screen overflow-hidden",
        "mesh-background mesh-gradient-bottom-right-animated",
        gradientClass
      )}
    >
      {/* Continuous gradient overlay - no abrupt ending */}
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-background/5 to-background/40 pointer-events-none" />

      <div className="relative z-10 h-full px-4 py-24 md:px-6 md:py-32 lg:px-8">
        <div className="max-w-[1400px] mx-auto">

          {/* Main Content */}
          <div className="text-center max-w-4xl mx-auto mb-16">
            {/* User Type Selector Pills */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              className="inline-flex items-center gap-2 p-2 rounded-full bg-white/60 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 mb-8"
            >
              {USER_TYPES.map((type) => {
                const Icon = type.icon;
                const isActive = selectedType === type.id;

                return (
                  <button
                    key={type.id}
                    onClick={() => setSelectedType(type.id)}
                    className={cn(
                      "relative flex items-center gap-2 px-4 py-2.5 rounded-full font-medium text-sm transition-all duration-300",
                      isActive
                        ? "text-white shadow-lg"
                        : "text-muted-foreground hover:text-foreground"
                    )}
                  >
                    {isActive && (
                      <motion.div
                        layoutId="activeUserType"
                        className={cn(
                          "absolute inset-0 rounded-full bg-gradient-to-r",
                          type.gradient
                        )}
                        transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                      />
                    )}
                    <Icon className="h-4 w-4 relative z-10" />
                    <span className="relative z-10">{type.title}</span>
                  </button>
                );
              })}
            </motion.div>

            {/* Dynamic Headline */}
            <AnimatePresence mode="wait">
              <motion.div
                key={selectedType}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.5 }}
              >
                <h1 className="text-4xl md:text-5xl lg:text-6xl xl:text-7xl font-bold tracking-tight text-foreground mb-6">
                  Expert Help for
                  <br />
                  <span className={cn(
                    "text-transparent bg-clip-text bg-gradient-to-r",
                    currentType.gradient
                  )}>
                    {currentType.title}
                  </span>
                </h1>
                <p className="text-lg md:text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
                  {currentType.description}
                </p>

                {/* Dynamic Benefits */}
                <div className="flex flex-wrap items-center justify-center gap-3 mb-10">
                  {currentType.benefits.map((benefit) => (
                    <div
                      key={benefit}
                      className={cn(
                        "flex items-center gap-2 px-4 py-2 rounded-full backdrop-blur-sm border",
                        currentType.bgGradient,
                        "border-current/20"
                      )}
                    >
                      <CheckCircle className={cn("h-4 w-4", currentType.textColor)} />
                      <span className="text-sm font-medium">{benefit}</span>
                    </div>
                  ))}
                </div>
              </motion.div>
            </AnimatePresence>

            {/* CTA Buttons */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="flex flex-col sm:flex-row items-center justify-center gap-4"
            >
              <Link
                href="/signup"
                className={cn(
                  "group relative overflow-hidden rounded-2xl px-8 py-4 text-white font-semibold shadow-xl transition-all duration-300 hover:shadow-2xl hover:-translate-y-1 bg-gradient-to-r",
                  currentType.gradient
                )}
              >
                <div className="relative z-10 flex items-center gap-2">
                  Get Started Free
                  <ArrowRight className="h-5 w-5 transition-transform duration-300 group-hover:translate-x-1" />
                </div>
              </Link>

              <Link
                href="#how-it-works"
                className="px-8 py-4 rounded-2xl bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 hover:bg-white dark:hover:bg-white/10 transition-all duration-300 font-semibold"
              >
                See How It Works
              </Link>
            </motion.div>

            {/* Trust Indicators */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.5 }}
              className="flex items-center justify-center gap-8 mt-12 pt-8 border-t border-border/40"
            >
              <div className="text-center">
                <div className="text-2xl font-bold tabular-nums">10,000+</div>
                <div className="text-xs text-muted-foreground">Happy Users</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold tabular-nums">98%</div>
                <div className="text-xs text-muted-foreground">Success Rate</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold tabular-nums">24h</div>
                <div className="text-xs text-muted-foreground">Avg Delivery</div>
              </div>
            </motion.div>
          </div>
        </div>
      </div>

      {/* Smooth gradient fade to next section */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-b from-transparent to-background pointer-events-none" />
    </section>
  );
}
