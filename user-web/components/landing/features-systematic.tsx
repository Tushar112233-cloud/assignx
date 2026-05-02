"use client";

/**
 * Features Section - Systematic Design
 *
 * Color System:
 * - Quality/Trust: Teal/Emerald (success, reliability)
 * - Speed/Delivery: Amber/Orange (energy, action)
 * - Support/Communication: Indigo/Blue (trust, communication)
 * - Security/Privacy: Violet/Purple (premium, security)
 */

import { motion } from "framer-motion";
import {
  Shield,
  Clock,
  MessageCircle,
  Award,
  CheckCircle,
  Star,
  Lock,
  Zap,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Core features with systematic color coding
 */
const CORE_FEATURES = [
  {
    id: "quality",
    title: "100% Quality Guaranteed",
    description: "Every project undergoes rigorous quality checks and plagiarism screening",
    icon: Shield,
    gradient: "from-emerald-500 to-teal-500",
    lightBg: "from-emerald-50/80 to-teal-50/80 dark:from-emerald-950/20 dark:to-teal-950/20",
    iconColor: "text-emerald-600 dark:text-emerald-400",
    features: [
      "Plagiarism-free work",
      "Expert verification",
      "Unlimited revisions",
    ],
  },
  {
    id: "delivery",
    title: "Lightning Fast Delivery",
    description: "98% of projects delivered before deadline with 24/7 availability",
    icon: Clock,
    gradient: "from-amber-500 to-orange-500",
    lightBg: "from-amber-50/80 to-orange-50/80 dark:from-amber-950/20 dark:to-orange-950/20",
    iconColor: "text-amber-600 dark:text-amber-400",
    features: [
      "24h average delivery",
      "Rush orders available",
      "Real-time tracking",
    ],
  },
  {
    id: "support",
    title: "Round-the-Clock Support",
    description: "Get instant help from our dedicated support team anytime, anywhere",
    icon: MessageCircle,
    gradient: "from-indigo-500 to-blue-500",
    lightBg: "from-indigo-50/80 to-blue-50/80 dark:from-indigo-950/20 dark:to-blue-950/20",
    iconColor: "text-indigo-600 dark:text-indigo-400",
    features: [
      "24/7 live chat",
      "Direct expert contact",
      "Priority assistance",
    ],
  },
  {
    id: "security",
    title: "Secure & Confidential",
    description: "Bank-grade encryption ensures your data and projects stay 100% private",
    icon: Lock,
    gradient: "from-violet-500 to-purple-500",
    lightBg: "from-violet-50/80 to-purple-50/80 dark:from-violet-950/20 dark:to-purple-950/20",
    iconColor: "text-violet-600 dark:text-violet-400",
    features: [
      "End-to-end encryption",
      "Privacy guaranteed",
      "Secure payments",
    ],
  },
];

/**
 * Trust stats
 */
const TRUST_STATS = [
  { icon: Star, value: "4.9/5", label: "Average Rating", color: "text-amber-500" },
  { icon: Award, value: "10K+", label: "Projects Completed", color: "text-emerald-500" },
  { icon: CheckCircle, value: "98%", label: "On-Time Delivery", color: "text-indigo-500" },
  { icon: Zap, value: "24h", label: "Average Turnaround", color: "text-violet-500" },
];

/**
 * Features Section
 */
export function FeaturesSystematic() {
  return (
    <section className="relative py-20 md:py-32 overflow-hidden bg-gradient-to-b from-background via-white to-slate-50/50 dark:via-slate-950 dark:to-slate-900/50">
      {/* Smooth gradient transition from previous section */}
      <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-background to-transparent pointer-events-none" />

      <div className="relative z-10 max-w-[1400px] mx-auto px-4 md:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/60 dark:bg-white/5 backdrop-blur-sm border border-border/50 mb-6">
            <Award className="h-4 w-4 text-emerald-500" />
            <span className="text-sm font-medium">Why Choose Us</span>
          </div>

          <h2 className="text-4xl md:text-5xl font-bold tracking-tight mb-4">
            Built on{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-600 via-indigo-600 to-violet-600">
              Trust & Excellence
            </span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            Industry-leading quality, security, and support that sets us apart
          </p>
        </motion.div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16">
          {CORE_FEATURES.map((feature, index) => {
            const Icon = feature.icon;

            return (
              <motion.div
                key={feature.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="group relative"
              >
                <div className="relative overflow-hidden rounded-[24px] p-8 bg-white/80 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 hover:shadow-xl hover:-translate-y-1 transition-all duration-500">
                  {/* Gradient overlay */}
                  <div className={cn(
                    "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none rounded-[24px]",
                    feature.lightBg
                  )} />

                  <div className="relative z-10 flex gap-6">
                    {/* Icon */}
                    <div className={cn(
                      "h-14 w-14 rounded-2xl flex items-center justify-center shrink-0 shadow-lg transition-all duration-500 group-hover:scale-110 bg-gradient-to-br",
                      feature.gradient
                    )}>
                      <Icon className="h-7 w-7 text-white" strokeWidth={1.5} />
                    </div>

                    {/* Content */}
                    <div className="flex-1">
                      <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                      <p className="text-sm text-muted-foreground mb-4 leading-relaxed">
                        {feature.description}
                      </p>

                      {/* Feature list */}
                      <div className="space-y-2">
                        {feature.features.map((item) => (
                          <div key={item} className="flex items-center gap-2 text-sm">
                            <CheckCircle className={cn("h-4 w-4", feature.iconColor)} />
                            <span>{item}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* Trust Stats */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="grid grid-cols-2 md:grid-cols-4 gap-6"
        >
          {TRUST_STATS.map((stat, index) => {
            const Icon = stat.icon;

            return (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, scale: 0.95 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.5 + index * 0.1 }}
                className="relative overflow-hidden rounded-2xl p-6 bg-white/60 dark:bg-white/5 backdrop-blur-sm border border-border/50 text-center hover:bg-white dark:hover:bg-white/10 transition-all duration-300"
              >
                <Icon className={cn("h-8 w-8 mx-auto mb-3", stat.color)} />
                <div className="text-3xl font-bold tabular-nums mb-1">{stat.value}</div>
                <div className="text-xs text-muted-foreground">{stat.label}</div>
              </motion.div>
            );
          })}
        </motion.div>
      </div>

      {/* Smooth gradient fade to next section */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-b from-transparent to-background pointer-events-none" />
    </section>
  );
}
