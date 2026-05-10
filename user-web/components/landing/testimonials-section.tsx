"use client";

/**
 * TestimonialsSection - Customer testimonials with parallax cards
 * Features GSAP parallax effects and staggered reveals
 */

import { useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { Star, Quote } from "lucide-react";

import { cn } from "@/lib/utils";
import { easings } from "@/lib/gsap/animations";

// Register plugin
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

const testimonials = [
  {
    id: 1,
    content:
      "The supervisor system is amazing! I always knew exactly what was happening with my project. Got an A on my research paper!",
    author: "Priya S.",
    role: "@priya_student",
    university: "AssignX client",
    rating: 5,
    avatar: "PS",
  },
  {
    id: 2,
    content:
      "Fast delivery and excellent quality. The expert understood exactly what I needed for my thesis proposal.",
    author: "Paul",
    role: "@paul_eng",
    university: "AssignX client",
    rating: 5,
    avatar: "P",
  },
  {
    id: 3,
    content:
      "I was skeptical at first, but the quality of work exceeded my expectations. Will definitely use again!",
    author: "Ananya K.",
    role: "@ananya_k",
    university: "AssignX client",
    rating: 5,
    avatar: "AK",
  },
  {
    id: 4,
    content:
      "The proofreading service saved my dissertation. Caught errors I completely missed. Highly recommend!",
    author: "Vikram P.",
    role: "@vikram_mba",
    university: "AssignX client",
    rating: 5,
    avatar: "VP",
  },
  {
    id: 5,
    content:
      "Professional communication throughout. My supervisor kept me updated at every stage. Great experience!",
    author: "Sneha R.",
    role: "@sneha_r",
    university: "AssignX client",
    rating: 5,
    avatar: "SR",
  },
  {
    id: 6,
    content:
      "Got my technical documentation done perfectly. The expert really knew their stuff. 10/10 would recommend.",
    author: "Arjun D.",
    role: "@arjun_dev",
    university: "AssignX client",
    rating: 5,
    avatar: "AD",
  },
];

export function TestimonialsSection() {
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

      // Cards with parallax effect
      const cards = cardsRef.current?.querySelectorAll(".testimonial-card");
      if (cards) {
        cards.forEach((card, index) => {
          // Initial reveal
          gsap.fromTo(
            card,
            { opacity: 0, y: 80 },
            {
              opacity: 1,
              y: 0,
              duration: 1,
              ease: easings.smooth,
              scrollTrigger: {
                trigger: card,
                start: "top 85%",
                toggleActions: "play none none reverse",
              },
            }
          );

          // Parallax movement
          const speed = index % 2 === 0 ? 30 : -30;
          gsap.to(card, {
            y: speed,
            ease: "none",
            scrollTrigger: {
              trigger: cardsRef.current,
              start: "top bottom",
              end: "bottom top",
              scrub: 1,
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
      id="testimonials"
      className="py-24 md:py-32 lg:py-40 overflow-hidden bg-white dark:bg-slate-900"
    >
      <div className="container px-6 md:px-8 lg:px-12">
        {/* Heading */}
        <div ref={headingRef} className="text-center max-w-3xl mx-auto mb-16 md:mb-20">
          <span className="inline-block text-sm font-semibold text-indigo-600 dark:text-indigo-400 uppercase tracking-wider mb-4">
            Client Reviews
          </span>
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-6 text-slate-900 dark:text-white">
            What people{" "}
            <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
              say about us
            </span>
          </h2>
          <p className="text-lg md:text-xl text-slate-600 dark:text-slate-300 leading-relaxed">
            Join thousands of satisfied clients who&apos;ve trusted us with their projects.
          </p>
        </div>

        {/* Testimonials grid */}
        <div
          ref={cardsRef}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 md:gap-8"
        >
          {testimonials.map((testimonial) => (
            <div
              key={testimonial.id}
              className={cn(
                "testimonial-card group relative p-6 md:p-8 rounded-2xl md:rounded-3xl",
                "bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700/50",
                "hover:border-indigo-300 dark:hover:border-indigo-500/50",
                "hover:shadow-xl hover:shadow-indigo-500/10",
                "transition-all duration-300"
              )}
            >
              {/* Quote icon */}
              <Quote className="absolute top-6 right-6 md:top-8 md:right-8 size-8 md:size-10 text-indigo-500/10" />

              {/* Rating */}
              <div className="flex gap-1 mb-4">
                {Array.from({ length: testimonial.rating }).map((_, i) => (
                  <Star
                    key={i}
                    className="size-5 fill-yellow-500 text-yellow-500"
                  />
                ))}
              </div>

              {/* Content */}
              <p className="text-slate-600 dark:text-slate-400 mb-6 relative z-10 leading-relaxed">
                "{testimonial.content}"
              </p>

              {/* Author */}
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 md:w-14 md:h-14 rounded-full bg-gradient-to-br from-indigo-500 to-purple-500 flex items-center justify-center text-white font-bold text-lg">
                  {testimonial.avatar}
                </div>
                <div>
                  <p className="font-bold text-slate-900 dark:text-white">{testimonial.author}</p>
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    {testimonial.role} • {testimonial.university}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
