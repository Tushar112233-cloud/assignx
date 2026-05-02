"use client";

/**
 * CTA Section Redesign - Dark Hero Style from Projects
 *
 * Features:
 * - Dark gradient background
 * - Decorative elements
 * - Compelling call-to-action
 */

import { motion } from "framer-motion";
import Link from "next/link";
import {
  ArrowRight,
  Plus,
  Sparkles,
  Users,
  Star,
  Shield,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Final stats
 */
const FINAL_STATS = [
  { value: "10,000+", label: "Students Helped", icon: Users },
  { value: "4.9/5", label: "Average Rating", icon: Star },
  { value: "100%", label: "Secure Platform", icon: Shield },
];

/**
 * CTA Section Component
 */
export function CTASectionRedesign() {
  return (
    <section className="relative py-20 md:py-32 overflow-hidden">
      {/* Main CTA Card - Dark Hero Style */}
      <div className="relative z-10 max-w-[1200px] mx-auto px-4 md:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="relative overflow-hidden rounded-[32px] p-10 md:p-16 lg:p-20 bg-gradient-to-br from-stone-800 via-stone-900 to-neutral-900 dark:from-stone-800 dark:via-stone-900 dark:to-neutral-950 text-white"
        >
          {/* Decorative gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-br from-orange-500/15 via-transparent to-rose-500/10 pointer-events-none" />

          {/* Decorative circles */}
          <div className="absolute -top-20 -right-20 w-64 h-64 bg-gradient-to-br from-orange-400/20 to-amber-500/10 rounded-full blur-3xl" />
          <div className="absolute -bottom-20 -left-20 w-64 h-64 bg-gradient-to-tr from-rose-400/15 to-transparent rounded-full blur-3xl" />
          <div className="absolute top-1/2 right-1/4 w-48 h-48 bg-gradient-to-br from-violet-400/10 to-purple-500/5 rounded-full blur-2xl" />

          <div className="relative z-10 text-center max-w-4xl mx-auto">
            {/* Badge */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 mb-8"
            >
              <Sparkles className="h-4 w-4 text-amber-400" />
              <span className="text-sm font-medium text-white/90">Join 10,000+ Successful Students</span>
            </motion.div>

            {/* Headline */}
            <motion.h2
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-6"
            >
              Ready to Excel in
              <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-400 via-orange-300 to-rose-400">
                Your Academics?
              </span>
            </motion.h2>

            {/* Description */}
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="text-lg md:text-xl text-white/70 mb-10 max-w-2xl mx-auto leading-relaxed"
            >
              Start your journey with expert assistance today. Get matched with the perfect expert in minutes.
            </motion.p>

            {/* CTA Buttons */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.5 }}
              className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-12"
            >
              <Link
                href="/signup"
                className="group relative flex items-center gap-3 px-8 py-4 rounded-2xl bg-white text-stone-900 font-semibold shadow-2xl shadow-white/20 hover:shadow-white/30 hover:scale-105 transition-all duration-300"
              >
                <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-orange-400 to-rose-500 flex items-center justify-center">
                  <Plus className="h-5 w-5 text-white" strokeWidth={2.5} />
                </div>
                <span className="text-lg">Get Started Free</span>
                <ArrowRight className="h-5 w-5 transition-transform duration-300 group-hover:translate-x-1" />
              </Link>

              <Link
                href="#features"
                className="px-8 py-4 rounded-2xl bg-white/10 backdrop-blur-sm border border-white/20 text-white font-medium hover:bg-white/20 transition-all duration-300"
              >
                Learn More
              </Link>
            </motion.div>

            {/* Stats */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.6 }}
              className="flex flex-wrap items-center justify-center gap-8 pt-8 border-t border-white/10"
            >
              {FINAL_STATS.map((stat, index) => {
                const Icon = stat.icon;

                return (
                  <motion.div
                    key={stat.label}
                    initial={{ opacity: 0, scale: 0.9 }}
                    whileInView={{ opacity: 1, scale: 1 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.5, delay: 0.7 + index * 0.1 }}
                    className="flex items-center gap-3"
                  >
                    <div className="h-12 w-12 rounded-xl bg-white/10 backdrop-blur-sm flex items-center justify-center">
                      <Icon className="h-6 w-6 text-amber-400" />
                    </div>
                    <div className="text-left">
                      <div className="text-2xl font-bold tabular-nums">{stat.value}</div>
                      <div className="text-sm text-white/60">{stat.label}</div>
                    </div>
                  </motion.div>
                );
              })}
            </motion.div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
