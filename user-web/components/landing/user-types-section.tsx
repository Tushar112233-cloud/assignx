"use client";

/**
 * User Types Section - Clear Segmentation
 *
 * Systematic Color Palette:
 * - Students: Orange/Amber (#FF6B35, #FFB88C)
 * - Employees: Indigo/Blue (#4F46E5, #818CF8)
 * - Business: Violet/Purple (#7C3AED, #A78BFA)
 *
 * Features:
 * - Three distinct user type cards
 * - Unique benefits for each segment
 * - Smooth gradient transitions
 */

import { motion } from "framer-motion";
import Link from "next/link";
import {
  GraduationCap,
  Briefcase,
  Building2,
  FileText,
  Users,
  BookOpen,
  TrendingUp,
  Target,
  Zap,
  ArrowRight,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * User segment definitions with systematic colors
 */
const USER_SEGMENTS = [
  {
    id: "students",
    title: "Students",
    tagline: "Academic Excellence",
    description: "From essays to dissertations, get expert help for all your academic needs",
    icon: GraduationCap,
    gradient: "from-orange-500 to-amber-500",
    lightBg: "from-orange-50/80 to-amber-50/80 dark:from-orange-950/20 dark:to-amber-950/20",
    iconBg: "bg-gradient-to-br from-orange-500 to-amber-600",
    features: [
      { icon: FileText, text: "Essays & Research Papers" },
      { icon: BookOpen, text: "Assignment Help" },
      { icon: Users, text: "1-on-1 Expert Tutoring" },
      { icon: Zap, text: "Quick Turnaround" },
    ],
    cta: "Get Academic Help",
    stats: { value: "5,000+", label: "Students Helped" },
  },
  {
    id: "employees",
    title: "Job Employees",
    tagline: "Professional Growth",
    description: "Advance your career with expert support for reports, presentations, and analysis",
    icon: Briefcase,
    gradient: "from-indigo-500 to-blue-500",
    lightBg: "from-indigo-50/80 to-blue-50/80 dark:from-indigo-950/20 dark:to-blue-950/20",
    iconBg: "bg-gradient-to-br from-indigo-500 to-blue-600",
    features: [
      { icon: FileText, text: "Business Reports" },
      { icon: TrendingUp, text: "Data Analysis" },
      { icon: Users, text: "Career Coaching" },
      { icon: Target, text: "Skill Development" },
    ],
    cta: "Boost Your Career",
    stats: { value: "3,000+", label: "Professionals Served" },
  },
  {
    id: "business",
    title: "Business Owners",
    tagline: "Scale Efficiently",
    description: "Focus on growth while experts handle your business plans, research, and content",
    icon: Building2,
    gradient: "from-violet-500 to-purple-500",
    lightBg: "from-violet-50/80 to-purple-50/80 dark:from-violet-950/20 dark:to-purple-950/20",
    iconBg: "bg-gradient-to-br from-violet-500 to-purple-600",
    features: [
      { icon: FileText, text: "Business Plans" },
      { icon: TrendingUp, text: "Market Research" },
      { icon: BookOpen, text: "Content Creation" },
      { icon: Target, text: "Strategy Consulting" },
    ],
    cta: "Scale Your Business",
    stats: { value: "2,000+", label: "Businesses Supported" },
  },
];

/**
 * User Types Section Component
 */
export function UserTypesSection() {
  return (
    <section className="relative py-20 md:py-32 overflow-hidden bg-gradient-to-b from-background via-slate-50/30 to-background dark:via-slate-900/30">
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
            <Users className="h-4 w-4 text-muted-foreground" />
            <span className="text-sm font-medium">Who We Serve</span>
          </div>

          <h2 className="text-4xl md:text-5xl font-bold tracking-tight mb-4">
            Designed for{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-orange-500 via-indigo-500 to-violet-500">
              Everyone
            </span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            Whether you're a student, professional, or entrepreneur - we have the perfect solution for you
          </p>
        </motion.div>

        {/* User Type Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {USER_SEGMENTS.map((segment, index) => {
            const Icon = segment.icon;

            return (
              <motion.div
                key={segment.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: index * 0.15 }}
                className="group relative"
              >
                <div className="relative overflow-hidden rounded-[28px] p-8 bg-white/80 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 hover:shadow-2xl hover:-translate-y-2 transition-all duration-500">
                  {/* Gradient overlay */}
                  <div className={cn(
                    "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none rounded-[28px]",
                    segment.lightBg
                  )} />

                  <div className="relative z-10">
                    {/* Icon */}
                    <div className={cn(
                      "h-16 w-16 rounded-2xl flex items-center justify-center mb-6 shadow-lg transition-all duration-500 group-hover:scale-110 group-hover:rotate-3",
                      segment.iconBg
                    )}>
                      <Icon className="h-8 w-8 text-white" strokeWidth={1.5} />
                    </div>

                    {/* Title & Tagline */}
                    <div className="mb-4">
                      <h3 className="text-2xl font-bold mb-1">{segment.title}</h3>
                      <p className={cn(
                        "text-sm font-medium bg-gradient-to-r bg-clip-text text-transparent",
                        segment.gradient
                      )}>
                        {segment.tagline}
                      </p>
                    </div>

                    {/* Description */}
                    <p className="text-sm text-muted-foreground leading-relaxed mb-6">
                      {segment.description}
                    </p>

                    {/* Features List */}
                    <div className="space-y-3 mb-6">
                      {segment.features.map((feature) => {
                        const FeatureIcon = feature.icon;
                        return (
                          <div key={feature.text} className="flex items-center gap-3">
                            <div className={cn(
                              "h-8 w-8 rounded-lg flex items-center justify-center shrink-0",
                              segment.lightBg
                            )}>
                              <FeatureIcon className="h-4 w-4" />
                            </div>
                            <span className="text-sm">{feature.text}</span>
                          </div>
                        );
                      })}
                    </div>

                    {/* Stats */}
                    <div className={cn(
                      "p-4 rounded-xl mb-6 backdrop-blur-sm",
                      segment.lightBg
                    )}>
                      <div className="text-2xl font-bold tabular-nums">{segment.stats.value}</div>
                      <div className="text-xs text-muted-foreground">{segment.stats.label}</div>
                    </div>

                    {/* CTA Button */}
                    <Link
                      href="/signup"
                      className={cn(
                        "group/btn relative flex items-center justify-between w-full px-6 py-3 rounded-xl text-white font-semibold shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5 bg-gradient-to-r",
                        segment.gradient
                      )}
                    >
                      <span>{segment.cta}</span>
                      <ArrowRight className="h-5 w-5 transition-transform duration-300 group-hover/btn:translate-x-1" />
                    </Link>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>

      {/* Smooth gradient fade to next section */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-b from-transparent to-background pointer-events-none" />
    </section>
  );
}
