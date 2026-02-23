"use client";

/**
 * StatsSection - Animated statistics with counting numbers
 * Features GSAP countUp animation on scroll
 */

import { useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

import { cn } from "@/lib/utils";
import { easings } from "@/lib/gsap/animations";

// Register plugin
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

const stats = [
  {
    value: 50000,
    suffix: "+",
    label: "Projects Completed",
    description: "Successfully delivered",
  },
  {
    value: 10000,
    suffix: "+",
    label: "Happy Students",
    description: "Across 50+ countries",
  },
  {
    value: 99,
    suffix: "%",
    label: "Satisfaction Rate",
    description: "Based on reviews",
  },
  {
    value: 500,
    suffix: "+",
    label: "Expert Tutors",
    description: "Verified professionals",
  },
];

export function StatsSection() {
  const containerRef = useRef<HTMLElement>(null);
  const statsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      // Stats container reveal
      gsap.fromTo(
        statsRef.current,
        { opacity: 0, y: 60 },
        {
          opacity: 1,
          y: 0,
          duration: 1,
          ease: easings.smooth,
          scrollTrigger: {
            trigger: statsRef.current,
            start: "top 80%",
            toggleActions: "play none none reverse",
          },
        }
      );

      // Number counting animation
      const statNumbers = statsRef.current?.querySelectorAll(".stat-number");
      if (statNumbers) {
        statNumbers.forEach((el, index) => {
          const target = stats[index].value;
          const obj = { value: 0 };

          gsap.to(obj, {
            value: target,
            duration: 2.5,
            ease: "power2.out",
            scrollTrigger: {
              trigger: el,
              start: "top 85%",
              toggleActions: "play none none none",
            },
            onUpdate: () => {
              (el as HTMLElement).textContent = Math.floor(obj.value).toLocaleString();
            },
          });
        });
      }
    }, containerRef);

    return () => ctx.revert();
  }, []);

  return (
    <section
      ref={containerRef}
      className="py-20 md:py-28 bg-gradient-to-br from-indigo-600 via-purple-600 to-indigo-700"
    >
      <div className="container px-6 md:px-8 lg:px-12">
        <div
          ref={statsRef}
          className="grid grid-cols-2 lg:grid-cols-4 gap-8 md:gap-12"
        >
          {stats.map((stat) => (
            <div
              key={stat.label}
              className="text-center"
            >
              {/* Number */}
              <div className="flex items-baseline justify-center gap-1 mb-3">
                <span className="stat-number text-5xl md:text-6xl lg:text-7xl font-bold text-white">
                  0
                </span>
                <span className="text-4xl md:text-5xl font-bold text-white/80">
                  {stat.suffix}
                </span>
              </div>

              {/* Label */}
              <h3 className="text-lg md:text-xl font-semibold text-white mb-1">
                {stat.label}
              </h3>
              <p className="text-sm md:text-base text-white/70">{stat.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
