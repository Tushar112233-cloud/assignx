"use client";

/**
 * FeaturesSection - Animated features grid with scroll reveals
 * Features GSAP stagger animations and hover effects
 */

import { useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import {
  Shield,
  Clock,
  Star,
  Users,
  Zap,
  HeadphonesIcon,
  CheckCircle,
  Lock,
} from "lucide-react";

import { cn } from "@/lib/utils";
import { easings } from "@/lib/gsap/animations";

// Register plugin
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

const features = [
  {
    icon: Shield,
    title: "Quality Guaranteed",
    description:
      "Every project is reviewed by experts to ensure the highest quality standards.",
    color: "bg-indigo-500",
    bgColor: "bg-indigo-100 dark:bg-indigo-900/30",
  },
  {
    icon: Clock,
    title: "On-Time Delivery",
    description:
      "We respect deadlines. Get your work delivered on or before the promised date.",
    color: "bg-green-500",
    bgColor: "bg-green-100 dark:bg-green-900/30",
  },
  {
    icon: Star,
    title: "Expert Professionals",
    description:
      "Work with verified experts in your field. All professionals are vetted.",
    color: "bg-yellow-500",
    bgColor: "bg-yellow-100 dark:bg-yellow-900/30",
  },
  {
    icon: Users,
    title: "Dedicated Support",
    description:
      "Get matched with a dedicated team member who understands your needs.",
    color: "bg-purple-500",
    bgColor: "bg-purple-100 dark:bg-purple-900/30",
  },
  {
    icon: Zap,
    title: "Fast Turnaround",
    description:
      "Need it urgently? Our express service delivers within 24-48 hours.",
    color: "bg-orange-500",
    bgColor: "bg-orange-100 dark:bg-orange-900/30",
  },
  {
    icon: HeadphonesIcon,
    title: "24/7 Assistance",
    description:
      "Our support team is available around the clock to help you.",
    color: "bg-pink-500",
    bgColor: "bg-pink-100 dark:bg-pink-900/30",
  },
  {
    icon: CheckCircle,
    title: "Satisfaction Promise",
    description:
      "Not happy? We offer unlimited revisions until you're satisfied.",
    color: "bg-cyan-500",
    bgColor: "bg-cyan-100 dark:bg-cyan-900/30",
  },
  {
    icon: Lock,
    title: "Secure & Private",
    description:
      "Your data and projects are protected with enterprise-grade security.",
    color: "bg-red-500",
    bgColor: "bg-red-100 dark:bg-red-900/30",
  },
];

export function FeaturesSection() {
  const containerRef = useRef<HTMLElement>(null);
  const headingRef = useRef<HTMLDivElement>(null);
  const cardsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      // Heading animation
      gsap.fromTo(
        headingRef.current,
        { opacity: 0, y: 50 },
        {
          opacity: 1,
          y: 0,
          duration: 1,
          ease: easings.smooth,
          scrollTrigger: {
            trigger: headingRef.current,
            start: "top 80%",
            toggleActions: "play none none reverse",
          },
        }
      );

      // Cards stagger animation
      const cards = cardsRef.current?.querySelectorAll(".feature-card");
      if (cards) {
        gsap.fromTo(
          cards,
          { opacity: 0, y: 60, scale: 0.95 },
          {
            opacity: 1,
            y: 0,
            scale: 1,
            duration: 0.8,
            stagger: 0.1,
            ease: easings.smooth,
            scrollTrigger: {
              trigger: cardsRef.current,
              start: "top 80%",
              toggleActions: "play none none reverse",
            },
          }
        );
      }
    }, containerRef);

    return () => ctx.revert();
  }, []);

  return (
    <section
      ref={containerRef}
      id="features"
      className="py-24 md:py-32 lg:py-40 bg-white dark:bg-slate-900"
    >
      <div className="container px-6 md:px-8 lg:px-12">
        {/* Heading */}
        <div ref={headingRef} className="text-center max-w-3xl mx-auto mb-16 md:mb-20">
          <span className="inline-block text-sm font-semibold text-indigo-600 dark:text-indigo-400 uppercase tracking-wider mb-4">
            Why Choose Us
          </span>
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-6 text-slate-900 dark:text-white">
            Built for Your{" "}
            <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
              Success
            </span>
          </h2>
          <p className="text-lg md:text-xl text-slate-600 dark:text-slate-300 leading-relaxed">
            We combine expertise, reliability, and care to deliver an exceptional
            experience for every student and professional.
          </p>
        </div>

        {/* Features grid */}
        <div
          ref={cardsRef}
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 md:gap-8"
        >
          {features.map((feature) => {
            const Icon = feature.icon;
            return (
              <div
                key={feature.title}
                className={cn(
                  "feature-card group relative p-6 md:p-8 rounded-2xl md:rounded-3xl",
                  "bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700/50",
                  "hover:border-indigo-300 dark:hover:border-indigo-500/50",
                  "hover:shadow-xl hover:shadow-indigo-500/10",
                  "transition-all duration-300"
                )}
              >
                {/* Background gradient on hover */}
                <div className="absolute inset-0 rounded-2xl md:rounded-3xl bg-gradient-to-br from-indigo-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity" />

                {/* Icon */}
                <div
                  className={cn(
                    "relative w-14 h-14 rounded-2xl flex items-center justify-center mb-6",
                    feature.bgColor
                  )}
                >
                  <Icon className={cn("size-7", feature.color.replace("bg-", "text-"))} />
                </div>

                {/* Content */}
                <h3 className="relative text-xl font-bold mb-3 text-slate-900 dark:text-white group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
                  {feature.title}
                </h3>
                <p className="relative text-slate-600 dark:text-slate-400 leading-relaxed">
                  {feature.description}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
