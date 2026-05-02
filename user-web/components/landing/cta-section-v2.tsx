"use client";

/**
 * CTA Section V2 - Final Conversion
 *
 * Design:
 * - Smooth gradient transition from previous section
 * - Dark premium background
 * - Multi-segment CTA options
 * - No abrupt ending
 */

import { motion } from "framer-motion";
import Link from "next/link";
import {
  ArrowRight,
  GraduationCap,
  Briefcase,
  Building2,
  CheckCircle,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Quick CTA options for each user segment
 */
const CTA_OPTIONS = [
  {
    id: "students",
    title: "Students",
    icon: GraduationCap,
    gradient: "from-orange-500 to-amber-500",
    description: "Get academic help",
  },
  {
    id: "employees",
    title: "Employees",
    icon: Briefcase,
    gradient: "from-indigo-500 to-blue-500",
    description: "Advance your career",
  },
  {
    id: "business",
    title: "Business",
    icon: Building2,
    gradient: "from-violet-500 to-purple-500",
    description: "Scale efficiently",
  },
];

/**
 * Final benefits
 */
const FINAL_BENEFITS = [
  "Start in 5 minutes",
  "No credit card required",
  "Expert matching included",
  "100% satisfaction guarantee",
];

/**
 * CTA Section V2
 */
export function CTASectionV2() {
  return (
    <section className="relative py-20 md:py-32 overflow-hidden bg-gradient-to-b from-background to-slate-50 dark:to-slate-900">
      {/* Smooth gradient transition from previous section */}
      <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-background to-transparent pointer-events-none" />

      <div className="relative z-10 max-w-[1200px] mx-auto px-4 md:px-6 lg:px-8">
        {/* Main CTA Card */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="relative overflow-hidden rounded-[32px] p-10 md:p-16 bg-gradient-to-br from-stone-800 via-stone-900 to-neutral-900 dark:from-stone-800 dark:via-stone-900 dark:to-neutral-950"
        >
          {/* Decorative gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-indigo-500/5 to-violet-500/10 pointer-events-none" />

          {/* Decorative elements */}
          <div className="absolute -top-20 -right-20 w-64 h-64 bg-gradient-to-br from-orange-400/15 to-amber-500/10 rounded-full blur-3xl" />
          <div className="absolute -bottom-20 -left-20 w-64 h-64 bg-gradient-to-tr from-violet-400/15 to-purple-500/10 rounded-full blur-3xl" />
          <div className="absolute top-1/2 right-1/4 w-48 h-48 bg-gradient-to-br from-indigo-400/10 to-blue-500/5 rounded-full blur-2xl" />

          <div className="relative z-10 text-center max-w-3xl mx-auto">
            {/* Headline */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 mb-8">
                <CheckCircle className="h-4 w-4 text-emerald-400" />
                <span className="text-sm font-medium text-white/90">Join 10,000+ Satisfied Users</span>
              </div>

              <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight text-white mb-6">
                Ready to Get Started?
              </h2>
              <p className="text-lg md:text-xl text-white/70 mb-10 leading-relaxed">
                Choose your path and get matched with the perfect expert in minutes
              </p>
            </motion.div>

            {/* User Type CTAs */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-10"
            >
              {CTA_OPTIONS.map((option) => {
                const Icon = option.icon;

                return (
                  <Link
                    key={option.id}
                    href="/signup"
                    className="group relative overflow-hidden rounded-2xl p-6 bg-white/10 backdrop-blur-sm border border-white/20 hover:bg-white/15 transition-all duration-300 hover:-translate-y-1"
                  >
                    <div className={cn(
                      "h-12 w-12 mx-auto rounded-xl flex items-center justify-center mb-3 bg-gradient-to-br",
                      option.gradient
                    )}>
                      <Icon className="h-6 w-6 text-white" />
                    </div>
                    <div className="text-white font-semibold mb-1">{option.title}</div>
                    <div className="text-sm text-white/60">{option.description}</div>
                  </Link>
                );
              })}
            </motion.div>

            {/* Primary CTA */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.5 }}
              className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-10"
            >
              <Link
                href="/signup"
                className="group relative flex items-center gap-3 px-8 py-4 rounded-2xl bg-white text-stone-900 font-semibold shadow-2xl shadow-white/20 hover:shadow-white/30 hover:scale-105 transition-all duration-300"
              >
                <span className="text-lg">Get Started Free</span>
                <ArrowRight className="h-5 w-5 transition-transform duration-300 group-hover:translate-x-1" />
              </Link>

              <Link
                href="#features"
                className="px-8 py-4 rounded-2xl bg-white/10 backdrop-blur-sm border border-white/20 text-white font-semibold hover:bg-white/20 transition-all duration-300"
              >
                Learn More
              </Link>
            </motion.div>

            {/* Benefits */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.6 }}
              className="flex flex-wrap items-center justify-center gap-6 pt-8 border-t border-white/10"
            >
              {FINAL_BENEFITS.map((benefit) => (
                <div key={benefit} className="flex items-center gap-2 text-white/80">
                  <CheckCircle className="h-4 w-4 text-emerald-400" />
                  <span className="text-sm">{benefit}</span>
                </div>
              ))}
            </motion.div>
          </div>
        </motion.div>
      </div>

      {/* Smooth gradient fade - no abrupt ending */}
      <div className="absolute bottom-0 left-0 right-0 h-64 bg-gradient-to-b from-transparent via-slate-50/50 to-slate-50 dark:via-slate-900/50 dark:to-slate-900 pointer-events-none" />
    </section>
  );
}
