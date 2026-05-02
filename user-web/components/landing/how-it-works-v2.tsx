"use client";

/**
 * How It Works V2 - Systematic Flow
 *
 * Color System (Process Flow):
 * 1. Submit: Orange (start, action)
 * 2. Match: Indigo (intelligence, matching)
 * 3. Payment: Emerald (trust, security)
 * 4. Delivery: Violet (completion, success)
 */

import { motion } from "framer-motion";
import {
  Upload,
  Users,
  CreditCard,
  CheckCircle,
  ArrowRight,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Process steps with systematic colors
 */
const PROCESS_STEPS = [
  {
    number: "01",
    title: "Submit Your Project",
    description: "Upload requirements, set deadline, and specify your needs in minutes",
    icon: Upload,
    gradient: "from-orange-500 to-amber-500",
    bgGradient: "from-orange-50/80 to-amber-50/80 dark:from-orange-950/20 dark:to-amber-950/20",
    details: [
      "Simple project form",
      "Upload supporting files",
      "Set your timeline",
    ],
  },
  {
    number: "02",
    title: "Get Matched with Expert",
    description: "Our AI matches you with the perfect expert for your specific subject",
    icon: Users,
    gradient: "from-indigo-500 to-blue-500",
    bgGradient: "from-indigo-50/80 to-blue-50/80 dark:from-indigo-950/20 dark:to-blue-950/20",
    details: [
      "AI-powered matching",
      "Subject specialists",
      "Verified credentials",
    ],
  },
  {
    number: "03",
    title: "Secure Payment",
    description: "Pay securely with escrow protection and track progress in real-time",
    icon: CreditCard,
    gradient: "from-emerald-500 to-teal-500",
    bgGradient: "from-emerald-50/80 to-teal-50/80 dark:from-emerald-950/20 dark:to-teal-950/20",
    details: [
      "Multiple payment methods",
      "Escrow protection",
      "Money-back guarantee",
    ],
  },
  {
    number: "04",
    title: "Receive Quality Work",
    description: "Get your completed project on time with unlimited revisions included",
    icon: CheckCircle,
    gradient: "from-violet-500 to-purple-500",
    bgGradient: "from-violet-50/80 to-purple-50/80 dark:from-violet-950/20 dark:to-purple-950/20",
    details: [
      "On-time delivery",
      "Quality guarantee",
      "Free revisions",
    ],
  },
];

/**
 * How It Works V2
 */
export function HowItWorksV2() {
  return (
    <section className="relative py-20 md:py-32 overflow-hidden bg-gradient-to-b from-background via-slate-50/50 to-background dark:via-slate-900/50">
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
            <span className="text-sm font-medium">Simple Process</span>
          </div>

          <h2 className="text-4xl md:text-5xl font-bold tracking-tight mb-4">
            How It{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-orange-500 via-indigo-500 to-violet-500">
              Works
            </span>
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            From submission to delivery - a seamless 4-step journey
          </p>
        </motion.div>

        {/* Process Steps */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {PROCESS_STEPS.map((step, index) => {
            const Icon = step.icon;
            const isEven = index % 2 === 0;

            return (
              <motion.div
                key={step.number}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="relative group"
              >
                {/* Connector arrow for desktop */}
                {!isEven && index < PROCESS_STEPS.length - 1 && (
                  <div className="hidden md:block absolute -bottom-8 left-1/2 -translate-x-1/2 z-20">
                    <ArrowRight className="h-6 w-6 text-muted-foreground/30 rotate-90" />
                  </div>
                )}

                <div className="relative overflow-hidden rounded-[24px] p-8 bg-white/80 dark:bg-white/5 backdrop-blur-xl border border-white/50 dark:border-white/10 hover:shadow-xl hover:-translate-y-1 transition-all duration-500">
                  {/* Gradient overlay */}
                  <div className={cn(
                    "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none rounded-[24px]",
                    step.bgGradient
                  )} />

                  <div className="relative z-10">
                    {/* Step number & Icon */}
                    <div className="flex items-start justify-between mb-6">
                      <div className="text-5xl font-bold text-muted-foreground/10 group-hover:text-muted-foreground/20 transition-colors">
                        {step.number}
                      </div>
                      <div className={cn(
                        "h-14 w-14 rounded-2xl flex items-center justify-center shadow-lg transition-all duration-500 group-hover:scale-110 group-hover:rotate-6 bg-gradient-to-br",
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
