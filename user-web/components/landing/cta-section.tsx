/**
 * @fileoverview CTA Section - Final call to action
 *
 * Dark section with email capture form.
 * Uses unique warm/cool color palette.
 */

"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import { motion, useReducedMotion, useInView } from "framer-motion";
import { cn } from "@/lib/utils";
import { ASSIGNX_EASE, DURATIONS } from "@/lib/animations/constants";
import { Zap, Clock, CheckCircle, ArrowRight } from "lucide-react";
import "@/app/landing.css";

export function CTASection() {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.3 });
  const prefersReducedMotion = useReducedMotion();
  const [email, setEmail] = useState("");

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: DURATIONS.entrance,
        ease: ASSIGNX_EASE,
      },
    },
  };

  const trustPoints = [
    {
      icon: Zap,
      text: "First 500 students get 20% off",
      color: "text-[var(--landing-accent-tertiary)]",
    },
    {
      icon: Clock,
      text: "24/7 Support",
      color: "text-[var(--landing-accent-primary)]",
    },
    {
      icon: CheckCircle,
      text: "100% Satisfaction Guarantee",
      color: "text-[var(--landing-accent-secondary)]",
    },
  ];

  return (
    <section
      ref={ref}
      className="py-20 sm:py-28 md:py-32 bg-[var(--landing-accent-primary)]"
    >
      <motion.div
        variants={prefersReducedMotion ? {} : containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
        className="max-w-2xl mx-auto px-4 sm:px-6 text-center"
      >
        {/* Headline */}
        <motion.h2
          variants={prefersReducedMotion ? {} : itemVariants}
          className="landing-heading landing-heading-lg text-white mb-4"
        >
          Ready to excel in
          <br />
          your studies?
        </motion.h2>

        {/* Subheadline */}
        <motion.p
          variants={prefersReducedMotion ? {} : itemVariants}
          className="text-lg text-white/70 mb-10"
        >
          Join thousands of successful students. Get matched with expert help
          for your assignments today.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div
          variants={prefersReducedMotion ? {} : itemVariants}
          className="mb-10"
        >
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/signup"
              className={cn(
                "h-14 px-8 rounded-xl flex items-center justify-center gap-2",
                "bg-white text-[var(--landing-accent-primary)] font-medium",
                "hover:bg-white/90 transition-all hover:shadow-lg"
              )}
            >
              Get Started Free
              <ArrowRight className="w-4 h-4" />
            </Link>
            <Link
              href="#how-it-works"
              className={cn(
                "h-14 px-8 rounded-xl flex items-center justify-center gap-2",
                "bg-transparent border border-white/30 text-white font-medium",
                "hover:bg-white/10 transition-colors"
              )}
            >
              Learn More
            </Link>
          </div>
          <p className="text-xs text-white/50 mt-4">
            No credit card required • Start your first project today
          </p>
        </motion.div>

        {/* Trust Points */}
        <motion.div
          variants={prefersReducedMotion ? {} : itemVariants}
          className="flex flex-col sm:flex-row items-center justify-center gap-4 sm:gap-8 text-sm"
        >
          {trustPoints.map((point, i) => (
            <div key={i} className="flex items-center gap-2 text-white/70">
              <point.icon className="h-4 w-4 text-white" />
              <span>{point.text}</span>
            </div>
          ))}
        </motion.div>
      </motion.div>
    </section>
  );
}
