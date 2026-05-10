/**
 * @fileoverview Hero Section - Clean, Canva/Linear inspired landing hero
 *
 * Simplified hero with:
 * - Clean typography
 * - Single clear CTA
 * - Subtle micro-animations
 * - Gradient background flows from page wrapper
 * - Integrated workflow animation showing client -> supervisor -> expert -> delivery
 */

"use client";

import { useRef } from "react";
import Link from "next/link";
import {
  motion,
  useReducedMotion,
  useScroll,
  useTransform,
  useSpring,
} from "framer-motion";
import { ArrowRight, Play } from "lucide-react";

import { cn } from "@/lib/utils";
import { ASSIGNX_EASE } from "@/lib/animations/constants";
import { HeroAnimation } from "./hero-animation";
import "@/app/landing.css";

/**
 * Clean Hero Section - Canva/Linear inspired
 */
export function HeroSection() {
  const ref = useRef<HTMLDivElement>(null);
  const prefersReducedMotion = useReducedMotion();

  // Parallax scroll effect
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  });

  const springScroll = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001,
  });

  const y = useTransform(springScroll, [0, 1], [0, -50]);

  return (
    <section
      ref={ref}
      id="hero"
      className={cn(
        "relative min-h-[90vh] flex items-center overflow-hidden",
        "pt-24 pb-16 sm:pt-28 sm:pb-20 md:pt-32 md:pb-24"
      )}
    >
      {/* Minimal grid pattern - subtle overlay */}
      <div className="absolute inset-0 landing-grid-pattern opacity-20 z-[1]" />

      <motion.div
        style={prefersReducedMotion ? {} : { y }}
        className="relative z-10 max-w-5xl mx-auto px-4 sm:px-6 w-full text-center"
      >
        {/* Hero content - positioned above gradient */}
        {/* Badge */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: ASSIGNX_EASE }}
          className="mb-8"
        >
          <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--landing-accent-lighter)] border border-[var(--landing-border)] text-sm font-medium text-[var(--landing-text-secondary)]">
            <span className="w-2 h-2 rounded-full bg-[var(--landing-accent-primary)] animate-pulse" />
            Trusted by 10,000+ users
          </span>
        </motion.div>

        {/* Main headline - Big and bold */}
        <motion.h1
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1, duration: 0.8, ease: ASSIGNX_EASE }}
          className="landing-heading-xl text-[var(--landing-text-primary)] mb-6"
        >
          Get expert help with
          <br />
          <span className="landing-text-gradient-animated">
            any task or project
          </span>
        </motion.h1>

        {/* Subheadline */}
        <motion.p
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.8, ease: ASSIGNX_EASE }}
          className="text-lg sm:text-xl text-[var(--landing-text-secondary)] max-w-2xl mx-auto mb-10 leading-relaxed"
        >
          Connect with verified experts who handle your projects from start to finish.
          Quality work, delivered on time.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.8, ease: ASSIGNX_EASE }}
          className="flex flex-col sm:flex-row items-center justify-center gap-4"
        >
          <Link
            href="/signup"
            className="landing-btn-primary inline-flex items-center gap-2 group px-8"
          >
            Get Started Free
            <motion.div
              animate={prefersReducedMotion ? {} : { x: [0, 4, 0] }}
              transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
            >
              <ArrowRight className="w-4 h-4" />
            </motion.div>
          </Link>

          <a
            href="#how-it-works"
            onClick={(e) => {
              e.preventDefault();
              const el = document.getElementById("how-it-works");
              if (el) {
                el.scrollIntoView({ behavior: "smooth" });
                window.location.hash = "how-it-works";
                // Dispatch scroll events to trigger GSAP ScrollTrigger
                const fireScroll = () => window.dispatchEvent(new Event("scroll"));
                setTimeout(fireScroll, 300);
                setTimeout(fireScroll, 600);
                setTimeout(fireScroll, 900);
                setTimeout(fireScroll, 1200);
              }
            }}
            className="landing-btn-secondary inline-flex items-center gap-2"
          >
            <Play className="w-4 h-4" />
            See How It Works
          </a>
        </motion.div>

        {/* Social proof mini-stats */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5, duration: 1, ease: ASSIGNX_EASE }}
          className="flex items-center justify-center gap-8 sm:gap-12 mt-12 pt-8 border-t border-[var(--landing-border)]"
        >
          {[
            { value: "98%", label: "Success Rate" },
            { value: "24h", label: "Avg. Delivery" },
            { value: "500+", label: "Experts" },
          ].map((stat, index) => (
            <motion.div
              key={stat.label}
              initial={prefersReducedMotion ? false : { opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{
                delay: 0.6 + index * 0.1,
                duration: 0.5,
                ease: ASSIGNX_EASE,
              }}
              className="text-center"
            >
              <div className="text-2xl sm:text-3xl font-bold text-[var(--landing-text-primary)] tabular-nums">
                {stat.value}
              </div>
              <div className="text-xs sm:text-sm text-[var(--landing-text-muted)]">
                {stat.label}
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Workflow Animation - Client -> Supervisor -> Expert -> Delivery */}
        <motion.div
          initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7, duration: 0.8, ease: ASSIGNX_EASE }}
          className="mt-16"
        >
          <HeroAnimation />
        </motion.div>
      </motion.div>

      {/* Scroll indicator */}
      <motion.div
        initial={prefersReducedMotion ? false : { opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1, duration: 1 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2"
      >
        <motion.div
          animate={prefersReducedMotion ? {} : { y: [0, 8, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
          className="w-6 h-10 rounded-full border-2 border-[var(--landing-border)] flex items-start justify-center p-2"
        >
          <motion.div
            animate={prefersReducedMotion ? {} : { y: [0, 8, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            className="w-1 h-2 bg-[var(--landing-accent-primary)] rounded-full"
          />
        </motion.div>
      </motion.div>
    </section>
  );
}
