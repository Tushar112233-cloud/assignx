"use client";

/**
 * Features Bento Grid - Campus Connect Inspired
 *
 * Vibrant feature showcase with:
 * - Category-based sections
 * - Interactive cards
 * - Glassmorphic design
 */

import { motion } from "framer-motion";
import {
  FileText,
  Users,
  Sparkles,
  Shield,
  Clock,
  MessageCircle,
  BookOpen,
  GraduationCap,
  Briefcase,
  Star,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Service categories
 */
const SERVICES = [
  {
    id: "academic",
    title: "Academic Writing",
    description: "Essays, research papers, and dissertations",
    icon: FileText,
    gradient: "from-blue-400 to-cyan-500",
    features: ["PhD Experts", "Plagiarism Free", "Unlimited Revisions"],
  },
  {
    id: "experts",
    title: "1-on-1 Consultations",
    description: "Video sessions with subject experts",
    icon: Users,
    gradient: "from-violet-400 to-purple-500",
    features: ["50+ Specializations", "Flexible Scheduling", "Instant Booking"],
  },
  {
    id: "campus",
    title: "Campus Connect",
    description: "Find opportunities, housing & events",
    icon: GraduationCap,
    gradient: "from-emerald-400 to-teal-500",
    features: ["10K+ Students", "500+ Colleges", "Verified Posts"],
  },
];

/**
 * Trust indicators
 */
const TRUST_POINTS = [
  { icon: Shield, text: "100% Secure Payment", color: "text-emerald-500" },
  { icon: Clock, text: "On-Time Delivery", color: "text-blue-500" },
  { icon: Star, text: "4.9/5 Rating", color: "text-amber-500" },
  { icon: MessageCircle, text: "24/7 Support", color: "text-violet-500" },
];

/**
 * Features Bento Grid Component
 */
export function FeaturesBento() {
  return (
    <section className="relative py-20 md:py-28 overflow-hidden bg-gradient-to-b from-white via-slate-50/50 to-white dark:from-slate-950 dark:via-slate-900/50 dark:to-slate-950">
      {/* Decorative background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-br from-blue-400/5 to-purple-400/5 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-gradient-to-br from-cyan-400/5 to-teal-400/5 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 max-w-[1400px] mx-auto px-4 md:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/80 dark:bg-white/5 backdrop-blur-sm border border-border/50 mb-6">
            <Sparkles className="h-4 w-4 text-amber-500" />
            <span className="text-sm font-medium">Everything You Need</span>
          </div>

          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-4">
            One Platform,{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 via-violet-500 to-purple-600">
              Endless Possibilities
            </span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            From academic help to career opportunities - everything a student needs in one place
          </p>
        </motion.div>

        {/* Services Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
          {SERVICES.map((service, index) => {
            const Icon = service.icon;

            return (
              <motion.div
                key={service.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="group relative overflow-hidden rounded-[24px] p-8 bg-white/80 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 hover:shadow-2xl hover:shadow-black/5 hover:-translate-y-2 transition-all duration-500"
              >
                {/* Gradient overlay */}
                <div className={cn(
                  "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-10 transition-opacity duration-500 pointer-events-none",
                  service.gradient
                )} />

                <div className="relative z-10">
                  {/* Icon */}
                  <div className={cn(
                    "h-16 w-16 rounded-2xl bg-gradient-to-br flex items-center justify-center mb-6 shadow-lg transition-all duration-500 group-hover:scale-110 group-hover:rotate-3",
                    service.gradient
                  )}>
                    <Icon className="h-8 w-8 text-white" strokeWidth={1.5} />
                  </div>

                  {/* Content */}
                  <h3 className="text-xl font-bold mb-2">{service.title}</h3>
                  <p className="text-sm text-muted-foreground mb-6 leading-relaxed">
                    {service.description}
                  </p>

                  {/* Features */}
                  <div className="space-y-2">
                    {service.features.map((feature) => (
                      <div key={feature} className="flex items-center gap-2 text-sm">
                        <div className={cn(
                          "h-1.5 w-1.5 rounded-full bg-gradient-to-r",
                          service.gradient
                        )} />
                        <span className="text-muted-foreground">{feature}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Hover effect border */}
                <div className="absolute inset-0 rounded-[24px] opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none">
                  <div className={cn(
                    "absolute inset-0 rounded-[24px] bg-gradient-to-r p-[2px]",
                    service.gradient
                  )}>
                    <div className="h-full w-full rounded-[23px] bg-white dark:bg-slate-950" />
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* Trust Points */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="flex flex-wrap items-center justify-center gap-8 py-8"
        >
          {TRUST_POINTS.map((point, index) => {
            const Icon = point.icon;

            return (
              <motion.div
                key={point.text}
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.5 + index * 0.1 }}
                className="flex items-center gap-3 px-6 py-3 rounded-full bg-white/60 dark:bg-white/5 backdrop-blur-sm border border-border/50"
              >
                <Icon className={cn("h-5 w-5", point.color)} />
                <span className="text-sm font-medium">{point.text}</span>
              </motion.div>
            );
          })}
        </motion.div>
      </div>
    </section>
  );
}
