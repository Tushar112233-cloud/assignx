/**
 * @fileoverview Value Proposition Banner
 *
 * Prominent banner highlighting the key value proposition:
 * "Experts handle tasks end-to-end with proper supervision"
 */

"use client";

import { useRef } from "react";
import {
  motion,
  useReducedMotion,
  useInView,
} from "framer-motion";
import {
  Shield,
  Eye,
  CheckCircle,
  Sparkles,
} from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";

/**
 * Value proposition features
 */
const features = [
  {
    icon: Shield,
    title: "Quality Assured",
    description: "Every project reviewed before delivery",
  },
  {
    icon: Eye,
    title: "Supervised Experts",
    description: "Monitored workflow for consistent results",
  },
  {
    icon: CheckCircle,
    title: "End-to-End Handling",
    description: "From research to final polish",
  },
];

/**
 * Value Proposition Banner
 */
export function ValueProposition() {
  const ref = useRef<HTMLElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();

  return (
    <section
      ref={ref}
      className="relative py-16 sm:py-20 overflow-hidden"
    >
      {/* Dark background with gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#14110F] via-[#1C1916] to-[#34312D]" />

      {/* Animated mesh gradient overlay */}
      <div
        className={cn(
          "absolute inset-0",
          "bg-[radial-gradient(ellipse_at_top_right,_rgba(118,83,65,0.15)_0%,_transparent_50%)]",
          "bg-[radial-gradient(ellipse_at_bottom_left,_rgba(228,225,199,0.08)_0%,_transparent_50%)]"
        )}
      />

      {/* Grid pattern */}
      <div
        className="absolute inset-0 opacity-10"
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px)",
          backgroundSize: "60px 60px",
        }}
      />

      <div className="relative z-10 max-w-6xl mx-auto px-4 sm:px-6">
        {/* Main content */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: ASSIGNX_EASE }}
          className="text-center"
        >
          {/* Badge */}
          <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, scale: 0.9 }}
            animate={isInView ? { opacity: 1, scale: 1 } : {}}
            transition={{ delay: 0.1, duration: 0.5, ease: ASSIGNX_EASE }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/10 mb-6"
          >
            <Sparkles className="w-4 h-4 text-[#E4E1C7]" />
            <span className="text-sm font-medium text-white/90">Our Promise</span>
          </motion.div>

          {/* Headline */}
          <h2 className="landing-heading-lg text-white mb-4 max-w-4xl mx-auto">
            Experts handle your tasks{" "}
            <span className="text-[#E4E1C7]">end-to-end</span>{" "}
            with proper supervision
          </h2>

          {/* Subheadline */}
          <p className="text-lg text-white/70 max-w-2xl mx-auto mb-12">
            No middlemen, no compromises. Your work is completed by verified experts
            under quality supervision, ensuring excellence at every step.
          </p>

          {/* Features row */}
          <div className="grid sm:grid-cols-3 gap-6 sm:gap-8">
            {features.map((feature, index) => (
              <motion.div
                key={feature.title}
                initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{
                  delay: 0.3 + index * 0.1,
                  duration: 0.5,
                  ease: ASSIGNX_EASE,
                }}
                className="group"
              >
                <div
                  className={cn(
                    "relative p-6 rounded-xl",
                    "bg-white/5 backdrop-blur-sm",
                    "border border-white/10",
                    "transition-all duration-300",
                    "hover:bg-white/10 hover:border-white/20"
                  )}
                >
                  {/* Icon */}
                  <div className="inline-flex items-center justify-center w-12 h-12 rounded-lg bg-gradient-to-br from-[#765341] to-[#5C4233] mb-4 transition-transform duration-300 group-hover:scale-110">
                    <feature.icon className="w-6 h-6 text-white" />
                  </div>

                  {/* Text */}
                  <h3 className="text-lg font-semibold text-white mb-2">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-white/60">
                    {feature.description}
                  </p>
                </div>
              </motion.div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
