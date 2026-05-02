"use client";

/**
 * How It Works Section - Wallet Inspired 2-Column Layout
 *
 * Features:
 * - Premium glassmorphic cards
 * - Step-by-step process
 * - Interactive animations
 */

import { motion } from "framer-motion";
import {
  Upload,
  Search,
  CreditCard,
  CheckCircle,
  FileText,
  MessageSquare,
  Download,
  Star,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Process steps
 */
const STEPS = [
  {
    number: "01",
    title: "Submit Your Project",
    description: "Upload your assignment details and requirements in minutes",
    icon: Upload,
    gradient: "from-blue-500 to-cyan-500",
    details: ["Fill simple form", "Upload files", "Set deadline"],
  },
  {
    number: "02",
    title: "Get Expert Match",
    description: "We match you with the perfect expert for your subject",
    icon: Search,
    gradient: "from-violet-500 to-purple-500",
    details: ["AI-powered matching", "Subject specialists", "Verified profiles"],
  },
  {
    number: "03",
    title: "Secure Payment",
    description: "Pay securely and track progress in real-time",
    icon: CreditCard,
    gradient: "from-emerald-500 to-teal-500",
    details: ["Multiple payment options", "Escrow protection", "Refund guarantee"],
  },
  {
    number: "04",
    title: "Receive & Review",
    description: "Get high-quality work delivered on time, every time",
    icon: CheckCircle,
    gradient: "from-amber-500 to-orange-500",
    details: ["Quality check", "Unlimited revisions", "Plagiarism report"],
  },
];

/**
 * Additional features
 */
const ADDITIONAL_FEATURES = [
  {
    icon: MessageSquare,
    title: "Direct Communication",
    description: "Chat with your expert anytime",
  },
  {
    icon: FileText,
    title: "Progress Updates",
    description: "Real-time project tracking",
  },
  {
    icon: Download,
    title: "Instant Delivery",
    description: "Download completed work instantly",
  },
  {
    icon: Star,
    title: "Quality Guarantee",
    description: "100% satisfaction or money back",
  },
];

/**
 * How It Works Component
 */
export function HowItWorksRedesign() {
  return (
    <section className="relative py-20 md:py-28 overflow-hidden mesh-background mesh-gradient-bottom-right-animated mesh-gradient-afternoon">
      <div className="relative z-10 max-w-[1400px] mx-auto px-4 md:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 mb-6">
            <span className="text-sm font-medium">Simple 4-Step Process</span>
          </div>

          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-4">
            How It{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-violet-600 via-purple-500 to-fuchsia-600">
              Actually Works
            </span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            From submission to delivery - your journey to academic success in 4 simple steps
          </p>
        </motion.div>

        {/* Steps Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
          {STEPS.map((step, index) => {
            const Icon = step.icon;

            return (
              <motion.div
                key={step.number}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="group relative overflow-hidden rounded-[24px] p-8 bg-white/70 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 hover:shadow-xl hover:shadow-black/5 hover:-translate-y-1 transition-all duration-500"
              >
                {/* Gradient overlay */}
                <div className={cn(
                  "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-10 transition-opacity duration-500 pointer-events-none rounded-[24px]",
                  step.gradient
                )} />

                <div className="relative z-10">
                  {/* Step Number & Icon */}
                  <div className="flex items-start justify-between mb-6">
                    <div className="text-6xl font-bold text-muted-foreground/20 group-hover:text-muted-foreground/30 transition-colors">
                      {step.number}
                    </div>
                    <div className={cn(
                      "h-14 w-14 rounded-2xl bg-gradient-to-br flex items-center justify-center shadow-lg transition-all duration-500 group-hover:scale-110 group-hover:rotate-6",
                      step.gradient
                    )}>
                      <Icon className="h-7 w-7 text-white" strokeWidth={1.5} />
                    </div>
                  </div>

                  {/* Content */}
                  <h3 className="text-2xl font-bold mb-3">{step.title}</h3>
                  <p className="text-muted-foreground mb-6 leading-relaxed">
                    {step.description}
                  </p>

                  {/* Details */}
                  <div className="space-y-2">
                    {step.details.map((detail) => (
                      <div key={detail} className="flex items-center gap-2">
                        <div className={cn(
                          "h-1.5 w-1.5 rounded-full bg-gradient-to-r",
                          step.gradient
                        )} />
                        <span className="text-sm text-muted-foreground">{detail}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* Additional Features */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="grid grid-cols-2 md:grid-cols-4 gap-4"
        >
          {ADDITIONAL_FEATURES.map((feature, index) => {
            const Icon = feature.icon;

            return (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, scale: 0.95 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.5 + index * 0.1 }}
                className="relative overflow-hidden rounded-2xl p-6 bg-white/60 dark:bg-white/5 backdrop-blur-sm border border-border/50 hover:bg-white dark:hover:bg-white/10 transition-all duration-300"
              >
                <Icon className="h-8 w-8 text-violet-500 mb-3" />
                <h4 className="font-semibold text-sm mb-1">{feature.title}</h4>
                <p className="text-xs text-muted-foreground">{feature.description}</p>
              </motion.div>
            );
          })}
        </motion.div>
      </div>
    </section>
  );
}
